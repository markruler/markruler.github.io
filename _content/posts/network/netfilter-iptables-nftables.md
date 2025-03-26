---
draft: true
socialshare: true
date: 2025-03-27T08:13:00+09:00
lastmod: 2025-03-27T08:13:00+09:00
title: "Netfilter 프레임워크와 리눅스의 기본 방화벽 iptables 그리고 nftables"
description: "네트워크 패킷 필터링"
# featured_image: ["/images/master/markruler-wave.webp"]
images: ["/images/master/markruler-wave.webp"]
tags:
  - network
  - firewall
categories:
  - wiki
---

- [Netfilter](#netfilter)
- [iptables](#iptables)
  - [테이블 (Tables)](#테이블-tables)
  - [체인 (Chains)](#체인-chains)
  - [타겟 (Target)](#타겟-target)
  - [예시 명령어](#예시-명령어)
- [nftables](#nftables)
- [더 읽을 거리](#더-읽을-거리)

# Netfilter

**Netfilter**는 **Linux 커널**에 내장된 네트워크 프레임워크로, 패킷을 검사하고 필터링할 수 있는 기능을 제공합니다.
Netfilter는 특정한 훅(hook) 지점에서 네트워크 패킷을 잡아내어 조작하거나 전달 여부를 결정할 수 있도록 설계되었습니다.
네트워크 패킷이 **입력(IN), 출력(OUT), 포워드(FORWARD)** 등 네트워크 스택의 특정 지점에 도달하면 Netfilter가 해당 패킷을 가로채어 필터링하거나 수정할 수 있습니다.
주요 기능으로는 다음과 같은 것들이 있습니다.

- 패킷 필터링 (DROP, ACCEPT 등)
- 네트워크 주소 변환 (NAT: Network Address Translation)
- 포트 포워딩
- 패킷 로깅

<!-- https://saysecurity.tistory.com/15 -->

- `NF_IP_PRE_ROUTING` — 외부에서 온 Packet이 Linux Kernel의 Network Stack을 통과하기 전 발생하는 Hook입니다. Packet을 Routing하기 전에 발생합니다.
- `NF_IP_LOCAL_IN` — Packet이 Routing된 후 목적지가 자신일 경우, Packet을 Process에 전달하기 전에 발생하는 Hook입니다.
- `NF_IP_FORWARD` — Packet이 Routing된 후 목적지가 자신이 아닐 경우, Packet을 다른 곳으로 Forwarding 하는 경우 발생하는 Hook입니다.
- `NF_IP_LOCAL_OUT` — Packet이 Process에서 나와 Network Stack을 통과하기 전에 발생하는 Hook입니다.
- `NF_IP_POST_ROUTING` — Packet이 Network Stack을 통과한 후 밖으로 보내기 전 발생하는 Hook입니다.

# iptables

iptables는 대표적인 Linux 방화벽 소프트웨어입니다.
Linux 커널의 네트워크 스택에 있는 패킷 필터링 Hook을 사용해서 동작합니다.
이 Hook이 Netfilter입니다.
네트워킹 시스템으로 들어오는 모든 패킷은 네트워크 스택을 지날 때마다 해당되는 Hook을 발생(trigger)시킵니다.
하지만 Linux, Unix, Windows 시스템을 방화벽(Firewall)으로 사용하는 것을 권장하지 않습니다[^1].
모든 기능을 갖춘 범용 목적의 운영체제 실행에는 본질적으로 보안 취약이 따르기 때문입니다.

[^1]: 유닉스/리눅스 시스템 관리 핸드북 5/e

<!-- https://www.booleanworld.com/depth-guide-iptables-linux-firewall/ -->

- **iptables**는 Netfilter 프레임워크를 제어하기 위한 **명령어 기반 사용자 공간 도구**입니다.
- Netfilter에 설정할 **규칙(rule)** 을 작성하고 관리하는 데 사용됩니다.
- **iptables** 명령어를 통해 **방화벽 규칙**을 설정할 수 있으며, 패킷을 필터링하거나 라우팅 동작을 조작할 수 있습니다.
- iptables의 규칙은 여러 **테이블**과 **체인**으로 구분됩니다.

## 테이블 (Tables)

- `filter`: 기본 테이블, 패킷의 필터링을 처리합니다 (ACCEPT, DROP 등).
- `nat`: 네트워크 주소 변환(NAT)을 처리합니다.
- `mangle`: 패킷 헤더를 수정합니다.
- `raw`: 커넥션 추적과 관련된 처리를 제어합니다.
- `security`: 강화된 보안을 위해 SELinux와 같은 보안 정책을 적용합니다.

## 체인 (Chains)

- `INPUT`: 패킷이 로컬 시스템에 들어올 때 적용됩니다.
- `OUTPUT`: 로컬 시스템에서 나가는 패킷에 적용됩니다.
- `FORWARD`: 패킷이 다른 시스템으로 전달될 때 적용됩니다.
- `PREROUTING`: 패킷이 네트워크 인터페이스에 들어오는 즉시 적용됩니다.
- `POSTROUTING`: 패킷이 라우팅 결정 후 네트워크를 나갈 때 적용됩니다.

## 타겟 (Target)

한 체인을 구성하는 각각의 룰은 패킷이 일치될 때 수행할 일을 결정하는 `target` 절을 갖습니다.

- `ACCEPT`
- `DROP`
- `REJECT`
- `LOG`
- `ULOG`
- `REDIRECT`
- `RETURN`
- `MIRROR`
- `QUEUE`

<!-- https://erlerobotics.gitbooks.io/erle-robotics-introduction-to-linux-networking/content/security/introduction_to_iptables.html -->

## 예시 명령어

```sh
systemctl status iptables
```

```sh
iptables -A [체인] -p [프로토콜] --dport [포트번호] -j [동작]
```

- `-A`: 체인에 규칙을 추가합니다.
- `-p`: 프로토콜 지정 (TCP, UDP, ICMP 등)
- `--dport`: 대상 포트 지정
- `-j`: 동작 (ACCEPT, DROP 등)

TCP 포트 22(SSH)를 차단하는 규칙입니다.

```sh
iptables -A INPUT -p tcp --dport 22 -j DROP
```

HTTP 포트 80으로 나가는 패킷을 허용합니다.

```sh
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
```

현재 설정된 규칙들을 확인합니다.

```sh
iptables -L -v
```

# nftables

<!-- https://developers.redhat.com/blog/2017/04/11/benchmarking-nftables -->

# 더 읽을 거리

- [netfilter.org](https://www.netfilter.org/)
- [Netfilter](https://en.wikipedia.org/wiki/Netfilter) | Wikipedia
- [Linux Kernel Netfilter](https://pr0gr4m.github.io/linux/kernel/netfilter/) | 박강민 (pr0gr4m)
