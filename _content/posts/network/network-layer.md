---
draft: false
socialshare: true
date: 2025-03-20T23:03:00+09:00
lastmod: 2025-03-20T23:03:00+09:00
title: "네트워크 레이어"
description: "OSI 모델을 중심으로"
images: ["/images/network/network-layer/osi-7-layer-bytebytego.png"]
tags:
  - network
categories:
  - wiki
---

**OSI 모델**은 다양한 통신 시스템이 통신할 수 있도록 국제표준화기구(ISO)에서 만든 개념 모델입니다.[^1]
각 계층(Layer)은 특정한 역할을 담당합니다.
이 글에서는 각 계층의 주요 기능과 특징을 살펴보겠습니다.

[^1]: [OSI 모델이란](https://www.cloudflare.com/learning/ddos/glossary/open-systems-interconnection-model-osi/) | Cloudflare

# 용어

먼저 공통 용어를 정리하며 시작하겠습니다.

1 계층은 영어로 Layer 1, 줄여서 L1이라고 부릅니다.
이 글에서도 글을 줄여 쓰기 위해서 물리 계층은 L1이라고 표기하겠습니다.

계층에서 처리하는 한 덩어리의 데이터 단위를 **PDU**(Protocol Data Unit)라고 부릅니다.
PDU는 제어 정보를 포함한 헤더(header), 데이터 자체인 페이로드(payload)로 구성되어 있습니다.
웹 서비스를 개발해보셨다면 HTTP 헤더와 바디를 생각하시면 됩니다.

이처럼 PDU를 부르는 명칭도 계층마다 다릅니다.
L1에서는 비트(bit), L2에서는 프레임(frame), L3에서는 패킷(packet), L4 TCP에서는 세그먼트(segment), L4 UDP에서는 데이터그램(datagram), L7에서는 메시지(message)로 부릅니다.
특히 L3의 **IP 패킷은 넓은 의미로 네트워크를 통해 흐르는 데이터 그 자체**를 일컫는 경우도 많습니다.

송신 측에서 데이터를 보낼 때는 **상위 계층의 데이터에 하위 계층의 헤더(header)를 붙여서 캡슐화(encapsulation)하며** 내려가고,
수신 측에서는 그 과정을 역순으로 **디캡슐화(decapsulation)하여** 상위 계층으로 전달합니다

<!-- ![](/images/network/network-layers/osi-7-layer-bytebytego.png) -->

<!-- *[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)* -->

<!-- ![](/images/network/network-layers/linux-network-protocol-stack.png) -->

<!-- *[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)* -->

# Layer 1 - Physical Layer

물리 계층(L1)은 실제 물리 매체를 통해 **디지털 신호를 전기 신호나 광신호 등으로 변환**하여 송수신합니다.
L1은 데이터 전송의 가장 기본적인 단위를 담당하며, 전송 매체의 물리적 특성을 정의합니다.
주요 장비로는 허브, 리피터, 케이블, 커넥터, 모뎀 등이 있으며, 비트 단위의 데이터 전송과 신호 변조 및 복조를 수행합니다.
물리 계층은 단순히 데이터를 전달하는 역할만 하며, 에러 검출이나 제어 기능은 포함되지 않습니다.

# Layer 2 - Data Link Layer

데이터 링크 계층(L2)은 **직접 연결된 인접 노드(장치) 간 데이터 전송을 담당**합니다.
L2는 MAC 주소를 이용해 통신하며, 프레임 단위로 데이터를 전송합니다.
또한, 흐름 제어와 오류 제어를 통해 데이터 전송의 안정성을 보장합니다.
주요 장비로는 스위치와 브리지가 있으며, Ethernet, PPP, HDLC와 같은 프로토콜이 사용됩니다.

# Layer 3 - Network Layer

네트워크 계층(L3)은 **다른 네트워크들을 연결**하고
**패킷(Packet) 단위의 데이터가 출발지에서 최종 목적지까지 전달되도록 경로를 선택**하는 계층입니다.
L3는 IP 주소를 이용해 데이터를 라우팅하고, 패킷 단위로 데이터를 전송합니다.
또한, 혼잡 제어와 QoS(서비스 품질) 보장을 통해 네트워크의 효율성을 높입니다.
주요 장비로는 라우터가 있으며, IP, ICMP, OSPF, BGP와 같은 프로토콜이 사용됩니다.

# Layer 4 - Transport Layer

전송 계층(L4)은 **종단 간(end-to-end) 신뢰성 있는 데이터 전송**을 담당합니다.
L4는 포트 번호를 이용해 프로세스 간 통신을 가능하게 하며, 세그먼트 단위로 데이터를 전송합니다.
연결 지향 서비스(TCP)와 비연결 지향 서비스(UDP)를 제공하며, 흐름 제어와 오류 제어를 통해 데이터 전송의 안정성을 보장합니다.
주요 프로토콜로는 TCP, UDP, SCTP가 있습니다.

# Layer 5 - Session Layer

세션 계층(L5)은 **두 응용 프로그램 간의 대화(Session)를 관리하고 동기화**하는 역할을 합니다.
L5는 통신 세션을 구축하고 유지하며, 데이터 전송 중단 시 재개 지점을 관리합니다.
또한, 전이중(Full-duplex) 및 반이중(Half-duplex) 통신 방식을 관리하고, 토큰 관리를 통해 상호배제를 보장합니다.
보안 기능으로는 인증(Authentication), 허가(Authorization), 세션 복구(Session Recovery)가 포함됩니다.
주요 표준으로는 NFS(Network File System), RPC(Remote Procedure Call)​가 있습니다.

# Layer 6 - Presentation Layer

표현 계층(L6)은 데이터의 구문과 표현을 담당하는 계층으로,
**한 시스템의 애플리케이션 계층에서 보내는 데이터를 다른 시스템에서도 이해할 수 있는 형태로 변환**해 줍니다.
문자 인코딩, 데이터 포맷 변환, 압축 및 암호화와 같은 작업들이 이 계층에서 이루어집니다.
L6는 문자 코드 변환, 데이터 압축, 암호화 및 복호화를 수행하며, 데이터의 인코딩과 디코딩을 담당합니다.
주요 표준으로는 파일 포맷 (JPEG, PNG, MP3), 문자 인코딩 (ASCII, Unicode), 암호화 프로토콜 (SSL, TLS) 등이 있습니다.

# Layer 7 - Application Layer

응용 계층(L7)은 사용자와 가장 가까운 계층으로, **응용 프로그램이 네트워크 서비스를 이용할 수 있도록 인터페이스를 제공**합니다.
이 계층은 파일 전송, 이메일, 원격 로그인, 디렉터리 서비스, 화상 통화 등 다양한 네트워크 응용 서비스에 대한 프로토콜을 정의하고 구현합니다.
주요 프로토콜로는 HTTP, FTP, SMTP, DNS, SSH 등이 있습니다.

# 더 읽을 거리

- [그림으로 공부하는 TCP/IP 구조](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791191600414) | 미야타 히로시
- [IT 엔지니어를 위한 네트워크 입문](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791165213183) | 고재성, 이상훈
