---
draft: false
socialshare: true
date: 2025-03-20T23:03:00+09:00
lastmod: 2025-03-21T23:08:00+09:00
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

L1(물리 계층)은 실제 물리 매체를 통해 **디지털 신호를 전기 신호나 광신호 등으로 변환**하여 송수신합니다.
L1은 데이터 전송의 가장 기본적인 단위를 담당하며, 전송 매체의 물리적 특성을 정의합니다.
케이블이나 커넥터 형태, 핀 배열 등 물리적인 사양에 관해 모두 정의되어 있는 계층입니다.

## NIC (Network Interface Card)

NIC는 컴퓨터를 네트워크에 연결하기 위해 필요한 하드웨어입니다.
네트워크 인터페이스, 네트워크 어댑터라고도 부릅니다.
모바일 기기를 포함한 모든 네트워크 단말기는 애플리케이션과 운영체제가 처리한 패킷을
NIC를 통해 LAN 케이블이나 전파로 보냅니다.

## 리피터 (Repeater)

일반 구리선 LAN(Local Area Network) 케이블에 흐르는 전기 신호는
전송 거리가 길수록 감쇠(Signal Attenuation)하며, 100m 정도 되면 파형이 깨집니다.[^2]
리피터는 파형을 한 번 더 증폭해서 정돈한 뒤 다른 쪽으로 전송합니다.

[^2]: [실제 테스트하는 영상](https://youtu.be/WMOr3WSsu6Q)

## 미디어 컨버터 (Media Converter)

전기 신호와 광 신호를 서로 교환하는 기기입니다.
광 섬유 케이블(Optic fiber cable, 광 케이블)을 연결하지 못하는 기기만 있는 상황에서
네트워크를 연장하고자 할 때 사용합니다.
전기 신호는 감쇠가 심한 반면 광 케이블은 멀리(수십 km)까지 보낼 수 있습니다.
해저 광 케이블[^3]의 경우 추가 리피터없이 300km까지 전송이 가능하다고 한다.
다만 광 케이블과 장비는 비싼 편입니다.

[^3]: [전세계 해저 케이블 지도](https://www.submarinecablemap.com/)

## 액세스 포인트 (Access Point)

패킷을 전파로 변조/복조하는 기기입니다.
쉽게 말하면 무선과 유선 사이의 다리 역할을 합니다.

## L1 표준

- 유선 프로토콜
- 무선 프로토콜

# Layer 2 - Data Link Layer

L2(데이터 링크 계층)는 **직접 연결된 인접 노드(장치) 간 데이터 전송을 담당**합니다.
L2는 **MAC 주소**를 이용해 통신하며, **프레임** 단위로 데이터를 전송합니다.
또한, 흐름 제어와 오류 제어를 통해 데이터 전송의 안정성을 보장합니다.

## 브리지 (Bridge)

포트와 포트 사이의 '다리 bridge' 역할을 합니다.
단말에서 받아들인 MAC 주소를 테이블(MAC address table)로 관리하고 전송합니다.
이 전송 처리를 브리징(bridging)이라고 합니다.
최근에는 L2 스위치가 대부분의 브리지 역할을 포함하기 때문에 단일 기기를 이용하지는 않습니다.

## L2 표준

- 유선 프로토콜
- 무선 프로토콜
- ARP (Address Resolution Protocol)
- PPP (Point-to-Point Protocol)
- L2TP (Layer 2 Tunneling Protocol)
- HDLC (High-Level Data Link Control)

# Layer 3 - Network Layer

L3(네트워크 계층)는 **다른 네트워크들을 연결**하고
**패킷(Packet) 단위의 데이터가 출발지에서 최종 목적지까지 전달되도록 경로를 선택**하는 계층입니다.
L3는 **IP 주소**를 이용해 데이터를 라우팅하고, **패킷** 단위로 데이터를 전송합니다.
또한, 혼잡 제어와 QoS(서비스 품질) 보장을 통해 네트워크의 효율성을 높입니다.

## 라우터 (Router)

단말로부터 받은 IP 패킷의 목적지 IP 주소를 보고,
자신이 속한 네트워크를 넘은 범위에 있는 단말로 전달하거나 중계하는 역할을 담당합니다.
이 과정을 패키지 릴레이(Package Relay)라고 하며, 라우팅이라고 합니다.
라우터는 라우팅 테이블을 기반으로 패킷을 전달할 대상자를 관리합니다.

## L3 스위치 (Layer 3 Switch)

라우터에 L2 스위치(포트가 많은 브리지)를 추가한 기기입니다.

## L3 프로토콜

- IP (Internet Protocol)
  - NAT (Network Address Translation)
- ICMP (Internet Control Message Protocol)
- OSPF (Open Shortest Path First)
- BGP (Border Gateway Protocol)

# Layer 4 - Transport Layer

L4(전송 계층)는 **종단 간(end-to-end) 신뢰성 있는 데이터 전송**을 담당합니다.
L4는 포트 번호를 이용해 프로세스 간 통신을 가능하게 하며, **세그먼트** 단위로 데이터를 전송합니다.
연결 지향 서비스(TCP)와 비연결 지향 서비스(UDP)를 제공하며,
흐름 제어와 오류 제어를 통해 데이터 전송의 안정성을 보장합니다.

## 방화벽 (Firewall)

단말 사이에서 교환되는 패킷을 검사하여 허용할지 막을지 결정하는 기기입니다.
패킷의 IP 주소나 포트 번호를 보고, 통신을 허가하거나 차단합니다.
이 통신 제어 기능을 스테이트풀 인스펙션(Stateful Inspection)이라고 합니다.
별도의 하드웨어로도 사용하지만, Netfilter 프레임워크를 이용한 iptables 같은 소프트웨어 방화벽도 널리 사용됩니다.

## L4 프로토콜

- TCP (Transmission Control Protocol)
- UDP (User Datagram Protocol)

# Layer 5 - Session Layer

L5(세션 계층)는 **두 응용 프로그램 간의 대화(Session)를 관리하고 동기화**하는 역할을 합니다.
L5는 통신 세션을 구축하고 유지하며, 데이터 전송 중단 시 재개 지점을 관리합니다.
또한, 전이중(Full-duplex) 및 반이중(Half-duplex) 통신 방식을 관리하고, 토큰 관리를 통해 상호배제를 보장합니다.
보안 기능으로는 인증(Authentication), 허가(Authorization), 세션 복구(Session Recovery)가 포함됩니다.

## L5 프로토콜

- RPC (Remote Procedure Call)

# Layer 6 - Presentation Layer

L6(표현 계층)는 데이터의 구문과 표현을 담당하는 계층으로,
**한 시스템의 애플리케이션 계층에서 보내는 데이터를 다른 시스템에서도 이해할 수 있는 형태로 변환**해 줍니다.
문자 인코딩, 데이터 포맷 변환, 압축 및 암호화와 같은 작업들이 이 계층에서 이루어집니다.
L6는 문자 코드 변환, 데이터 압축, 암호화 및 복호화를 수행하며, 데이터의 인코딩과 디코딩을 담당합니다.

## L6 프로토콜

- 파일 포맷
  - JPEG (Joint Photographic Experts Group)
  - PNG (Portable Network Graphics)
  - MP3 (MPEG-1 Audio Layer III)
- 문자 인코딩
  - ASCII (American Standard Code for Information Interchange)
  - Unicode
- 압축
  - ZIP
  - GZIP
- 암호화
  - SSL (Secure Sockets Layer)
  - TLS (Transport Layer Security)

# Layer 7 - Application Layer

L7(응용 계층)은 사용자와 가장 가까운 계층으로, **응용 프로그램이 네트워크 서비스를 이용할 수 있도록 인터페이스를 제공**합니다.
이 계층은 파일 전송, 이메일, 원격 로그인, 디렉터리 서비스, 화상 통화 등 다양한 네트워크 응용 서비스에 대한 프로토콜을 정의하고 구현합니다.

## L7 로드 밸런서 (Load Balancer)

로드 밸런서는 여러 서버에 들어오는 트래픽(Load)을 분산(Balancing)하는 장치입니다.
L7 로드 밸런서는 L7 스위치 또는 애플리케이션 스위치라고 불리기도 합니다.
헬스 체크(HC, Health Check)를 통해 서버의 상태를 확인하고,
사용자가 지정한 로드 밸런싱 방식을 이용해 가용성 확보를 목표로 합니다.
로드 밸런서는 L4에도 사용됩니다.[^4]

[^4]: AWS의 로드 밸런서인 ELB(Elastic Load Balancer)는 대표적으로 2가지 종류가 있습니다.
NLB(Network Load Balancer)는 L4,
ALB(Application Load Balancer)는 L7을 지원합니다.

## L7 프로토콜

- HTTP (HyperText Transfer Protocol)
- FTP (File Transfer Protocol)
- SMTP (Simple Mail Transfer Protocol)
- DNS (Domain Name System)
- SSH (Secure Shell)
- SNMP (Simple Network Management Protocol)
- SIP (Session Initiation Protocol)

# 더 읽을 거리

- [그림으로 공부하는 TCP/IP 구조](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791191600414) | 미야타 히로시
- [IT 엔지니어를 위한 네트워크 입문](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791165213183) | 고재성, 이상훈
