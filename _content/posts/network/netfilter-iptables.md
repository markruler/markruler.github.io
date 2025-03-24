---
draft: true
socialshare: true
date: 2025-03-24T11:13:00+09:00
lastmod: 2025-03-24T11:13:00+09:00
title: "Netfilter 프레임워크와 리눅스의 기본 방화벽: iptables"
description: "네트워크 패킷 필터링"
# featured_image: ["/images/master/markruler-wave.webp"]
images: ["/images/master/markruler-wave.webp"]
tags:
  - network
  - firewall
categories:
  - wiki
---

# Netfilter

**Netfilter**는 **Linux 커널**에 내장된 네트워크 프레임워크로, 패킷을 검사하고 필터링할 수 있는 기능을 제공합니다.
Netfilter는 특정한 훅(hook) 지점에서 네트워크 패킷을 잡아내어 조작하거나 전달 여부를 결정할 수 있도록 설계되었습니다.
네트워크 패킷이 **입력(IN), 출력(OUT), 포워드(FORWARD)** 등 네트워크 스택의 특정 지점에 도달하면 Netfilter가 해당 패킷을 가로채어 필터링하거나 수정할 수 있습니다.
주요 기능으로는 다음과 같은 것들이 있습니다.

- 패킷 필터링 (DROP, ACCEPT 등)
- 네트워크 주소 변환 (NAT: Network Address Translation)
- 포트 포워딩
- 패킷 로깅

# iptables

- **iptables**는 Netfilter 프레임워크를 제어하기 위한 **명령어 기반 사용자 공간 도구**입니다.
- Netfilter에 설정할 **규칙(rule)** 을 작성하고 관리하는 데 사용됩니다.
- **iptables** 명령어를 통해 **방화벽 규칙**을 설정할 수 있으며, 패킷을 필터링하거나 라우팅 동작을 조작할 수 있습니다.
- iptables의 규칙은 여러 **테이블**과 **체인**으로 구분됩니다.

## 테이블 (Tables)

- **filter**: 기본 테이블, 패킷의 필터링을 처리합니다 (ACCEPT, DROP 등).
- **nat**: 네트워크 주소 변환(NAT)을 처리합니다.
- **mangle**: 패킷 헤더를 수정합니다.
- **raw**: 커넥션 추적과 관련된 처리를 제어합니다.
- **security**: 강화된 보안을 위해 SELinux와 같은 보안 정책을 적용합니다.

## 체인 (Chains)

- **INPUT**: 패킷이 로컬 시스템에 들어올 때 적용됩니다.
- **OUTPUT**: 로컬 시스템에서 나가는 패킷에 적용됩니다.
- **FORWARD**: 패킷이 다른 시스템으로 전달될 때 적용됩니다.
- **PREROUTING**: 패킷이 네트워크 인터페이스에 들어오는 즉시 적용됩니다.
- **POSTROUTING**: 패킷이 라우팅 결정 후 네트워크를 나갈 때 적용됩니다.

## 예시 명령어

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

# 더 읽을 거리

- [netfilter.org](https://www.netfilter.org/)
- [Netfilter](https://en.wikipedia.org/wiki/Netfilter) | Wikipedia
- [Linux Kernel Netfilter](https://pr0gr4m.github.io/linux/kernel/netfilter/) | 박강민 (pr0gr4m)
