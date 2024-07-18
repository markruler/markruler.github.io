---
date: 2024-06-13T17:40:00+09:00
title: "🕸️ 서버 to 서버 요청 시 발생한 DNS 레이턴시"
description: "LG야 힘내"
featured_image: "/images/network/image-20240611-080044.webp"
images: ["/images/network/image-20240611-080044.webp"]
socialshare: true
tags:
  - web
  - network
  - latency
Categories:
  - case
---

- [배경](#배경)
- [분석: dig 으로 테스트](#분석-dig-으로-테스트)
  - [nameserver 8.8.8.8 로 지정](#nameserver-8888-로-지정)
  - [nameserver는 `resolv.conf` 설정을 따름](#nameserver는-resolvconf-설정을-따름)
  - [비교](#비교)
- [해결: 호스트 파일 수정](#해결-호스트-파일-수정)

# 배경

- 약 200ms 응답 속도가 예상되는 API가 불규칙적으로 2s까지 스파이크가 발생함.
  - 해당 API에는 서버 to 서버로 요청하는 기능이 여러 개 포함되어 있음.
- 환경: On-Premise(IDC) 환경에 애플리케이션 서버는 컨테이너가 아닌 스탠드얼론 호스트로 실행됨.

# 분석: dig 으로 테스트

## nameserver 8.8.8.8 로 지정

```sh
dig @8.8.8.8 api.example.com
```

첫번째 요청 292 msec

```sh
;; Query time: 292 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Tue Jun 11 11:00:54 KST 2024
;; MSG SIZE  rcvd: 154
```

2번째 요청 36 msec

```sh
;; Query time: 36 msec
;; SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
;; WHEN: Tue Jun 11 11:00:57 KST 2024
;; MSG SIZE  rcvd: 154
```

## nameserver는 `resolv.conf` 설정을 따름

```sh
# /etc/resolv.conf
# LG 메인 네임 서버
nameserver 164.124.101.2
# LG 보조 네임 서버
nameserver 203.248.252.2
```

```sh
dig api.example.com
```

첫번째 시도

```sh
;; Query time: 17 msec
;; SERVER: 164.124.101.2#53(164.124.101.2)
;; WHEN: 화  6월 11 17:14:45 KST 2024
;; MSG SIZE  rcvd: 154
```

두번째 시도: 간헐적으로 튀는 걸 확인할 수 있었음.

```sh
;; Query time: 230 msec
;; SERVER: 164.124.101.2#53(164.124.101.2)
;; WHEN: 화  6월 11 17:25:41 KST 2024
;; MSG SIZE  rcvd: 154
```

## 비교

`LG DNS`는 캐시가 되는 것 같은데 200~300 msec 응답 속도가 불규칙적으로 자주 발생함.
(현재 서버가 위치한 IDC 회선이 LG라서 LG DNS 사용)

```sh
watch -n 1 "dig @164.124.101.2 api.example.com | grep \"Query time\""
# ;; Query time: 3 msec
# ;; Query time: 227 msec
# ;; Query time: 5 msec
# ;; Query time: 5 msec
# ;; Query time: 4 msec
# ;; Query time: 5 msec
# ;; Query time: 7 msec
# ;; Query time: 228 msec
# ;; Query time: 4 msec
# ;; Query time: 14 msec
# ;; Query time: 3 msec
# ;; Query time: 5 msec
# ;; Query time: 3 msec
# ;; Query time: 10 msec
# ...
```

`8.8.8.8` 은 더 심함.

```sh
watch -n 1 "dig @8.8.8.8 api.example.com | grep \"Query time\""
# ;; Query time: 303 msec
# ;; Query time: 121 msec
# ;; Query time: 342 msec
# ;; Query time: 49 msec
# ;; Query time: 239 msec
# ;; Query time: 305 msec
# ;; Query time: 49 msec
# ;; Query time: 239 msec
# ;; Query time: 129 msec
# ;; Query time: 120 msec
# ;; Query time: 50 msec
# ;; Query time: 39 msec
# ;; Query time: 162 msec
# ;; Query time: 48 msec
# ;; Query time: 37 msec
# ;; Query time: 37 msec
# ;; Query time: 277 msec
# ;; Query time: 173 msec
# ;; Query time: 50 msec
# ;; Query time: 334 msec
# ...
```

# 해결: 호스트 파일 수정

server -> L4 Switch -> server는 프록시 없이 설정할 수 없다고 함.
실제로 호스트 파일(`/etc/hosts`)에 아래와 같이 설정하면 Connection도 얻지 못하고 타임아웃 발생함.

```sh
# <L4_IP_ADDRESS> api.example.com
```

아래와 같이 설정해서 각 노드에 있는 web server에서 서버 A, B로 로드 밸런싱 되도록 설정함.

```sh
127.0.0.1 api.example.com
```

![Datadog Timeseries](/images/network/image-20240611-080044.webp)

- 처음에 서버 A(빨간색) 먼저 수정 후 응답 속도가 줄어든 것을 확인함.
- 이후 서버 B(초록색)도 수정 후 응답 속도 줄어듦.
