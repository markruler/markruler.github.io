---
date: 2024-12-30T18:38:00+09:00
lastmod: 2024-12-30T18:38:00+09:00
title: "일상에서의 Wireshark"
description: "네트워크 문제 해결에 도움이 될 패킷 분석하기"
featured_image: "/images/network/wireshark/wireshark.jpg"
images: ["/images/network/wireshark/wireshark.jpg"]
tags:
  - network
categories:
  - wiki
---

GUI가 꽤 편하기 때문에 Windows나 macOS에서는
[Wireshark](https://www.wireshark.org/docs/man-pages/wireshark.html)를 사용하는 경우가 많습니다.
하지만 여기서는 CLI 환경에서도 사용할 수 있는
[TShark](https://www.wireshark.org/docs/man-pages/tshark.html)를 소개합니다.

# 설치

```sh
# CLI
sudo apt install tshark
# GUI
sudo apt install wireshark
```

wireshark 그룹 추가 후 컴퓨터를 재부팅해야 합니다.

```sh
sudo usermod -aG wireshark $USER
```

```sh
reboot
```

```sh
tshark -h
# TShark (Wireshark) 3.6.2 (Git v3.6.2 packaged as 3.6.2-2)
# Dump and analyze network traffic.
# See https://www.wireshark.org for more information.
# Usage: tshark [options] ...
```

# 네트워크 인터페이스 조회

```sh
# tshark --list-interfaces
tshark -D
```

```sh
1. enp2s0
2. docker0
3. vetha1d3dea
4. any
5. lo (Loopback)
# ...
```

# 패킷 분석 시 사용할 수 있는 옵션

## Network interface

- `-i`, `--interface` 인터페이스의 이름 혹은 인덱스를 지정
  - `-i eth0` `eth0` 인터페이스 캡처
  - `-i 2` 2번째 인터페이스 캡처

## Processing

- `-f` libpcap filter syntax를 사용하여 패킷 필터링
  - `-f "tcp port 80"` TCP port 80 패킷 필터링
- `-Y`, `--display-filter` Wireshark displa**Y** filter syntax 사용하여 패킷 표시
  - `-Y "http.request"` HTTP request 패킷 표시

## Stop conditions

- `-c` stop after n packets (def: infinite)
  - `-c 10` - stop after 10 packets
- `-a <autostop cond.> ...`, `--autostop <autostop cond.> …`
  - `duration:NUM` stop after NUM seconds
  - `filesize:NUM` stop this file after NUM KB
  - `files:NUM` stop after NUM files
  - `packets:NUM` stop after NUM packets

## Write

- `-w`, `--write-file` set the filename to write to (or '-' for stdout)
  - `-w file` write to file
- `-e <field>` field to print if -Tfields selected (e.g. tcp.port, _ws.col.Info)
  - `-e tcp.port` print the TCP port field
  - this option can be repeated to print multiple fields
- `-t a|ad|adoy|d|dd|e|r|u|ud|udoy` output format of time stamps (def: r: rel. to first)
- `--color` color output text similarly to the Wireshark GUI, requires a terminal with 24-bit color support Also supplies color attributes to pdml and psml formats (Note that attributes are nonstandard)

## Read file

- `-r`, `--read-file` set the filename to read from (or '-' for stdin)
  - `-r file` read from file

## Diagnostic output

## Miscellaneous

# 패킷 분석

기본적으로 특정 네트워크 인터페이스를 지정해서 실시간으로 패킷을 캡처하거나
이미 캡처된 pcap 파일을 열어서 분석할 수 있습니다.

## 모든 인터페이스 캡쳐

```sh
tshark -i any
```

## localhost(lo, loopback) 주소의 8080 포트 캡쳐

```sh
tshark -i lo -Y 'tcp.port == 8080' --color
```

![Wireshark TUI](/images/network/wireshark/wireshark-tui.png)

## HTTP body 출력

- 전체 body

```sh
tshark -i lo -Y 'tcp.port == 8080' -T fields -e http.file_data --color
```

- response body만 출력

```sh
tshark -i lo -Y 'tcp.port == 8080 && http.response' -T fields -e http.file_data --color
```

## 특정 도메인에서의 패킷 캡쳐

```sh
# youtube
tshark -i any -f 'host www.youtube.com' --color
```

```sh
tshark -i any -f 'host localhost' --color
```

## 파일로 출력

```sh
tshark -i any -w capture.pcap
```

```sh
# tshark로 파일 읽기
tshark -r capture.pcap --color
```

```sh
# wireshark GUI로 파일 읽기
wireshark capture.pcap
```
