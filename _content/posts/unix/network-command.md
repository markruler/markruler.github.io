---
draft: true
socialshare: true
date: 2024-12-05T11:04:00+09:00
lastmod: 2024-12-05T11:04:00+09:00
title: "리눅스 네트워크 체크리스트"
description: "뭐가 문제일까"
featured_image: "/images/gui/xdg/dall-e-x-window-system.webp"
images: ["/images/gui/xdg/dall-e-x-window-system.webp"]
tags:
  - linux
  - network
categories:
  - wiki
---

# 개요

- 네트워크 문제가 발생했을 때 사용하기 위한 체크리스트입니다.
- 우선순위가 높은 순서(맨위가 우선순위 가장 높음)부터 작성합니다.
- 다각도로 확인할 필요가 있습니다.
  - 예를 들어, `Connection refused` 에러가 서버가 아닌 방화벽 같은 네트워크 보안 장비에서 발생할 수도 있습니다.

# Commands

먼저 네트워크 문제를 진단하기 위한 명령어 도구들을 소개합니다.

## netstat

네트워크 연결 상태를 확인합니다.
습관적으로 `t`, `u` 옵션을 사용하면 놓치게 되는 프로세스도 있어서 `-npl`를 많이 사용합니다.

```sh
netstat -npl | less
```

좀비 프로세스의 경우 `LISTEN` 상태가 아닐 수 있습니다.
조회되는 프로세스가 없는 경우 `sudo`를 사용해서 root 권한으로 확인해보거나 `l` 대신 `a` 옵션을 사용해서
모든 프로세스를 찾아봅니다.

```sh
sudo netstat -npa | grep "8080"
```

- `-a`
  - all
- `-n`
  - `호스트명:예약된_포트명`이 아닌 숫자(`IP:PORT`)로 출력
- `-l`
  - LISTEN 상태만 출력
- `-t`
  - TCP
- `-u`
  - UDP
- `-p`
  - PID 출력

## lsof

특정 포트나 PID로 열린 파일을 확인합니다.

```sh
# by port
lsof -n -i :8080
```

```sh
# by PID
lsof -an -p 214301 -i
```

- `-a`
  - This option causes list selection options to be ANDed, as described above.
  - 옵션들을 AND로 연결
- `-p`
  - excludes or selects the listing of files for the processes whose optional process IDentification (PID) numbers
    are in the comma-separated set s - e.g., `123` or `123,^456`.  (There should be no spaces in the set.)
- `-g`
  - PGID(Process Group ID)
- `-i`
  - selects  the  listing  of files any of whose Internet address matches the address specified in i.  If no address is specified,
    this option selects the listing of all Internet and x.25 (HP-UX) network files.
- `-u`
  - username or UID
- `-n`
  - This option inhibits the conversion of network numbers to host names for network files.
    Inhibiting conversion may make lsof run faster.
    It is also useful when host name lookup is not working properly.
  - 네트워크 번호를 호스트 이름으로 변환하지 않음. (출력이 더 빨라짐)

## sar

```sh
sar -n TCP,ETCP 1
```

## iftop

네트워크 인터페이스 정보를 확인할 수 있습니다.

```sh
# sudo apt install iftop
sudo iftop
sudo iftop -i <interface>
```

## nethogs

```sh
# sudo apt install nethogs
nethogs
# To run nethogs without being root you need to enable capabilities on the program (cap_net_admin, cap_net_raw), see the documentation for details.

sudo nethogs
```

## iperf

네트워크 대역폭을 측정할 수 있습니다.

```sh
# server
iperf -s -p 5050
# ------------------------------------------------------------
# Server listening on TCP port 5050
# TCP window size: 85.3 KByte (default)
# ------------------------------------------------------------
# [  4] local 10.10.10.175 port 5050 connected with 111.222.111.222 port 42250 (peer 2.1.5)
# [ ID] Interval       Transfer     Bandwidth
# [  4]  0.0-10.0 sec   493 MBytes   413 Mbits/sec
```

```sh
# client
iperf -c 10.10.10.175 -p 5050
# ------------------------------------------------------------
# Client connecting to 61.111.18.175, TCP port 5050
# TCP window size: 64.0 KByte (default)
# ------------------------------------------------------------
# [  1] local 192.168.0.33 port 42250 connected with 61.111.18.175 port 5050
# [ ID] Interval       Transfer     Bandwidth
# [  1] 0.0000-10.0399 sec   493 MBytes   412 Mbits/sec

```

# TCP/IP

## Could not resolve host

클라이언트가 서버의 호스트명을 찾을 수 없는 경우

- [CURLE_COULDNT_RESOLVE_HOST](https://github.com/curl/curl/blob/bc21c505e4d625df38e2f584ac1b7f6d9b923543/lib/strerror.c#L79)

```sh
curl api.example.com
# curl: (6) Could not resolve host: api.example.com; Name or service not known
```

- [ ] DNS 설정이 누락되었는가 (`dig`, `nslookup`)
- [ ] `/etc/resolv.conf` - `nameserver`가 잘 구성되어있는가
  - [ ] NetworkManager가 제어하고 있지 않은가
- [ ] 호스트 파일 `/etc/hosts`에서 직접 설정한 호스트명이 있는가

## `ETIMEDOUT` connection timed out

서버와 연결되지 않는 경우

- [ ] 서버가 실행중인가
- [ ] 호스트 머신 방화벽(ex: `iptables`) 설정이 있는가
  - [ ] `iptables` 규칙 순서가 올바르게 정렬되었는가
- [ ] 별도 보안 장비에 방화벽 설정이 있는가

```sh
nslookup api.example.com
# ;; connection timed out; no servers could be reached
```

## `ECONNREFUSED` Connection refused

서버와 L3(IP) 연결은 되었지만 L4(TCP)가 연결되지 않은 경우 (ex: port가 LISTEN 상태가 아님)

```sh
curl api.example.com
```

- [ ] 서버가 실행중인가 (port가 LISTEN 상태인가)
- [ ] 호스트 머신 방화벽이 포트를 차단하고 있는가

## `ENETUNREACH` / `EHOSTUNREACH` Network is unreachable

```sh
curl api.example.com
```

```sh
# stdout
curl: (7) Failed to connect to api.example.com port 80: Network is unreachable
```

## `ECONNRESET` Recv failure: Connection reset by peer

- 연결 중 상대방이 일방적으로 연결을 종료하는 경우
- 프로토콜이 호환되지 않는 경우
- 종료된 커넥션을 재사용하려고 시도하는 경우

```sh
curl localhost:3000
```

```sh
# stdout
curl: (56) Recv failure: Connection reset by peer
```

- [ ] 서버가 재시작 되었는가

## SSH 연결 시 아무 응답이 없을 때

```sh
ssh -v username@111.222.111.222
```

```sh
# stdout
OpenSSH_8.9p1 Ubuntu-3, OpenSSL 3.0.2 15 Mar 2022
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 19: include /etc/ssh/ssh_config.d/*.conf matched no files
debug1: /etc/ssh/ssh_config line 21: Applying options for *
debug1: Connecting to 111.222.111.222 [111.222.111.222] port 22.
# 이후 아무 출력이 없음
```

- [ ] 원격 호스트에서 SSH 서비스(`sshd`)가 실행중인가
- [ ] SSH 포트가 22번인가
