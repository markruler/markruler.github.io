---
date: 2024-12-30T18:38:00+09:00
lastmod: 2024-12-31T13:16:00+09:00
title: "일상에서의 Wireshark"
description: "네트워크 문제 분석 시 필요한 패킷 분석 도구"
featured_image: "/images/network/wireshark/wireshark.jpg"
images: ["/images/network/wireshark/wireshark.jpg"]
tags:
  - network
categories:
  - wiki
---

Wireshark란 오픈 소스 네트워크 프로토콜 분석기입니다.
GUI와 CLI 환경 모두에서 사용할 수 있으며, 네트워크 문제를 분석할 때 많이 사용됩니다.
플랫폼 또한 Windows, macOS, Linux 등 다양한 운영체제에서 사용할 수 있습니다.
GUI가 꽤 편하기 때문에 Windows나 macOS에서는
[Wireshark](https://www.wireshark.org/docs/man-pages/wireshark.html)를 사용하는 경우가 많습니다.
여기서는 CLI 환경에서도 사용할 수 있는
[TShark](https://www.wireshark.org/docs/man-pages/tshark.html)를 소개합니다.

# 설치

Ubuntu 22.04에서 설치하는 방법을 소개합니다.

```sh
# CLI
sudo apt install tshark
# GUI
sudo apt install wireshark
```

`wireshark` 그룹 추가 후 컴퓨터를 재부팅해야 합니다.

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

먼저 TShark로 사용할 수 있는 네트워크 인터페이스를 조회합니다.

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

# 패킷 캡처 시 사용할 수 있는 옵션

`tshark` 라는 명령어를 옵션없이 실행하면 기본적으로 모든 네트워크 인터페이스를 경유하는 패킷을 캡처합니다.
네트워크 분석하기에는 너무 많은 패킷이 캡처되기 때문에
네트워크 인터페이스, 프로토콜, 호스트, 포트 등을 지정해서 필터링합니다.

```sh
tshark
```

## Network interface

- `-i`, `--interface` 인터페이스의 이름 혹은 인덱스를 지정
  - `-i eth0` `eth0` 인터페이스 캡처
  - `-i 2` 2번째 인터페이스 캡처

## Processing

- `-f` [pcap-filter syntax](https://www.tcpdump.org/manpages/pcap-filter.7.html)를 사용하여 패킷 필터링
  - `-f "tcp port 80"` TCP port 80 패킷 필터링
- `-Y`, `--display-filter` [Wireshark displa**Y** filter syntax](https://www.wireshark.org/docs/wsug_html_chunked/ChWorkBuildDisplayFilterSection.html) 사용하여 패킷 표시
  - `-Y "http.request"` HTTP request 패킷 표시

## Stop writing

- `-a <autostop cond.> ...`, `--autostop <autostop cond.> …`
  - `duration:NUM` NUM 초(seconds) 후 중지 (기본값 무한, 소수점 사용 가능)
  - `filesize:NUM` NUM kB 이상 캡처 후 중지 (최대 2GiB)
  - `packets:NUM` NUM 개 패킷 캡처 후 중지 (`-c`와 같음)
- `-c` n개 패킷 캡처 후 중지
  - `-c 10` 10개 패킷 캡처 후 중지

## Write

- `-w`, `--write-file` 파일에 쓰기 위한 파일 이름 설정 (stdout의 경우 '-')
  - `-w file` file 이름으로 쓰기
- `-T` 출력 형식을 선택
  - `-T fields` 필드를 출력
  - `-T pdml` Packet Details Markup Language (PDML) 출력
  - `-T psml` Packet Summary Markup Language (PSML) 출력
  - `-T json` JSON 출력
  - `-T jsonraw` JSON 출력 (no formatting)
  - `-T ek` Elasticsearch bulk format
- `-e <field>` 위 출력 옵션 중 `ek`, `fields`, `json`, `pdml` 사용 시 출력할 필드 지정
  - `-e tcp.port` TCP port 출력
  - 이 옵션은 여러 필드를 출력하기 위해 반복할 수 있습니다.
    - `-e tcp.port -e tcp.flags` TCP port와 flags 출력
- `-t a|ad|adoy|d|dd|e|r|u|ud|udoy` output format of time stamps (def: r: rel. to first)
- `--color` Wireshark GUI와 유사하게 텍스트를 색상으로 출력하며, 24비트 색상을 지원하는 터미널이 필요합니다. 또한 PDML 및 PSML 형식에 색상 속성을 제공합니다(이 속성은 비표준임).

## Read file

- `-r`, `--read-file` 파일에서 읽기
  - `-r file` file에서 읽기

# 패킷 분석

![Wireshark TUI](/images/network/wireshark/wireshark-tui.png)

기본적으로 특정 네트워크 인터페이스를 지정해서 실시간으로 패킷을 캡처하거나
이미 캡처된 pcap 파일을 열어서 분석할 수 있습니다.

## 웹 앱 패킷 캡처

```sh
# Youtube
tshark -i any -f 'host www.youtube.com' --color
```

```sh
tshark -i any -f 'host www.youtube.com' -T fields -e ip.src -e ip.dst -e tcp.port
```

```sh
# 테스트 모바일 앱에서 로컬 서버로 들어오는 패킷 캡처 (앱에서 서버 도메인을 private ip로 설정)
tshark -i any -Y 'http and (tcp.port == 15500 or tcp.port == 33000) and ip.dst == 192.168.0.15' -T json
```

```sh
# Postman처럼 localhost로 요청하는 패킷 캡처
tshark -i lo -Y 'http and (tcp.port == 15500 or tcp.port == 33000)' -T json
```

```sh
# localhost의 15500 혹은 33000 포트로 요청하는 패킷에서 http body 출력
tshark -i lo -Y 'http and (tcp.dstport == 15500 or tcp.dstport == 33000)' -T fields -e http.file_data
tshark -i lo -Y 'http.request and (tcp.port == 15500 or tcp.port == 33000)' -T fields -e http.file_data
# localhost의 15500 혹은 33000 포트에서 응답하는 패킷에서 http body 출력
tshark -i lo -Y 'http and (tcp.srcport == 15500 or tcp.srcport == 33000)' -T fields -e http.file_data
tshark -i lo -Y 'http.response and (tcp.port == 15500 or tcp.port == 33000)' -T fields -e http.file_data
# localhost의 15500 혹은 33000 포트를 경유하는 모든 패킷에서 http body 출력
tshark -i lo -Y 'http and (tcp.port == 15500 or tcp.port == 33000)' -T fields -e http.file_data
```

## 파일 출력

**파일로 출력할 때**는 pcap-filter(`-f`)를 사용할 수 있지만, Wireshark display-filter(`-Y`)를 사용할 수 없습니다.

> tshark: Display filters aren't supported when capturing and saving the captured packets.

```sh
# tcp 프로토콜의 port 15500을 경유하는 패킷 5초간 캡처해서 capture.pcap 파일로 저장
tshark -i lo -f 'tcp port 15500' -w capture.pcap -a duration:5
```

## 파일 읽기

```sh
# tshark로 파일 읽기
tshark -r capture.pcap --color
```

```sh
# JSON 형식으로 읽기
tshark -r capture.pcap -T json | less
```

```sh
# wireshark GUI로 파일 읽기
wireshark capture.pcap
```
