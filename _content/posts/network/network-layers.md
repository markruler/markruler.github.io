---
draft: true
socialshare: true
date: 2025-01-27T01:03:00+09:00
lastmod: 2025-01-27T01:03:00+09:00
title: "네트워크 레이어"
description: "OSI 모델을 중심으로"
featured_image: "/images/network/network-layers/osi-7-layer-bytebytego.png"
images: ["/images/network/network-layers/osi-7-layer-bytebytego.png"]
tags:
  - network
categories:
  - wiki
---

# 개요

- 4계층으로 단순화시킨 TCP/IP 모델도 있습니다.
- 실제 업무에서는 TCP/IP 모델보다 OSI 모델의 명칭을 더 많이 사용합니다. 예를 들어, Layer 3은 L3로 줄여서 얘기하죠. 네트워크 계층이라고 하는 사람을 보진 못했습니다.

![](/images/network/network-layers/osi-7-layer-bytebytego.png)

*[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)*

![](/images/network/network-layers/linux-network-protocol-stack.png)

*[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)*

# Layer 1 - Physical Layer

- 비트(0과 1)를 전기 신호나 광신호로 변환하여 전송하는 계층
- 주요 장비: 허브, 리피터, 케이블, 커넥터 등
- 주요 기능:
  - 비트 단위의 데이터 전송
  - 전송 매체의 물리적 특성 정의 (전압, 전류, 주파수 등)
  - 물리적 토폴로지 정의
  - 단순 데이터 전달만 담당 (에러 검출/제어 기능 없음)

# Layer 2 - Data Link Layer

- 물리적으로 연결된 두 장치 간의 신뢰성 있는 데이터 전송을 담당
- 주요 장비: 스위치, 브리지
- 주요 기능:
  - MAC 주소를 이용한 통신
  - 프레임 단위의 데이터 전송
  - 흐름 제어 및 오류 제어
  - CSMA/CD, CSMA/CA 등의 매체 접근 제어
- 대표적인 프로토콜: Ethernet, PPP, HDLC

# Layer 3 - Network Layer

- 서로 다른 네트워크 간의 통신을 위한 경로 설정과 패킷 전달을 담당
- 주요 장비: 라우터
- 주요 기능:
  - IP 주소를 이용한 라우팅
  - 패킷 단위의 데이터 전송
  - 혼잡 제어
  - QoS(서비스 품질) 보장
- 대표적인 프로토콜: IP, ICMP, OSPF, BGP

# Layer 4 - Transport Layer

- 종단 간(end-to-end) 신뢰성 있는 데이터 전송을 담당
- 주요 기능:
  - 포트 번호를 이용한 프로세스 간 통신
  - 세그먼트 단위의 데이터 전송
  - 연결 지향/비연결 지향 서비스 제공
  - 흐름 제어 및 오류 제어
- 대표적인 프로토콜: TCP, UDP, SCTP

# Layer 5 - Session Layer

- 두 응용 프로그램 간의 대화를 관리하고 동기화하는 계층
- 통신하는 프로세스들 간의 논리적인 연결을 담당
- 주요 기능:
  - 통신 세션 구축 및 유지
  - 데이터 전송 동기화 지점(체크포인트) 설정
  - 데이터 전송 중단 시 재개 지점 관리
  - 전이중(Full-duplex), 반이중(Half-duplex) 통신 방식 관리
  - 토큰 관리를 통한 상호배제(Mutual Exclusion) 보장
- 보안 기능:
  - 인증(Authentication)
  - 허가(Authorization)
  - 세션 복구(Session Recovery)

- 양 끝단의 응용 프로세스가 통신을 관리하기 위한 방법을 제공
- 주요 기능:
  - 세션 연결의 설정/유지/종료
  - 동기화
  - 대화 제어
  - 데이터 교환 관리
- 대표적인 프로토콜: NetBIOS, RPC

# Layer 6 - Presentation Layer

- 데이터의 형식을 변환하고 암호화하는 계층
- 주요 기능:
  - 문자 코드, 압축, 암호화 등의 데이터 변환
  - 데이터의 인코딩/디코딩
  - 데이터의 암호화/복호화
- 대표적인 프로토콜: SSL/TLS, JPEG, MPEG

# Layer 7 - Application Layer

- 사용자와 가장 가까운 계층으로 응용 프로그램 간의 데이터 교환을 담당
- 주요 기능:
  - 사용자 인터페이스 제공
  - 전자메일, 파일 전송 등의 서비스 제공
- 대표적인 프로토콜: HTTP, FTP, SMTP, DNS, SSH
