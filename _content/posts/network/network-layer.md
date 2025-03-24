---
draft: false
socialshare: true
date: 2025-03-20T23:03:00+09:00
lastmod: 2025-03-21T23:08:00+09:00
title: "네트워크 레이어 - OSI 모델"
description: "상향식 접근"
# featured_image: ["/images/network/network-layer/osi-7-layer-bytebytego.png"]
images: ["/images/network/network-layer/osi-7-layer-bytebytego.png"]
tags:
  - network
categories:
  - wiki
---

**TCP/IP 모델**은 1970년대 미국 국방부 연구기관 DARPA에서
인터넷 초기 설계(ARPANet)에 사용한 모델로 4계층으로 구성되어 있습니다.
실제 인터넷을 구현하기 위해 실용적 목적으로 개발되었습니다.

반면 **OSI 모델**은 다양한 컴퓨터 시스템이 서로 통신할 수 있도록
1984년 국제표준화기구(ISO)에서 만든 개념 모델입니다.[^1]

실제 네트워크에서는 TCP/IP 모델이 사용됩니다.
하지만 개념을 이해하고 설명하기에는 OSI 모델이 더 적합하기 때문에 OSI 모델이 통용됩니다.

이 글에서는 각 계층의 주요 기능과 특징을 살펴보기 위해
일반적으로 사용되는 **OSI 모델을 따르지만 5~7계층은 TCP/IP 모델처럼 합쳐진 5계층 모델**을 설명합니다.

<!-- 첫 책 p12 -->

[^1]: [OSI 모델이란](https://www.cloudflare.com/learning/ddos/glossary/open-systems-interconnection-model-osi/) | Cloudflare

- [용어](#용어)
- [Layer 1 - Physical Layer](#layer-1---physical-layer)
  - [L1 주요 기기](#l1-주요-기기)
- [Layer 2 - Data Link Layer](#layer-2---data-link-layer)
  - [L2 주요 기기](#l2-주요-기기)
  - [L2 주요 프로토콜](#l2-주요-프로토콜)
- [Layer 3 - Network Layer](#layer-3---network-layer)
  - [L3 주요 기기](#l3-주요-기기)
  - [L3 주요 프로토콜](#l3-주요-프로토콜)
    - [IP 주소 체계](#ip-주소-체계)
    - [IP 라우팅](#ip-라우팅)
- [Layer 4 - Transport Layer](#layer-4---transport-layer)
  - [L4 주요 기기](#l4-주요-기기)
  - [L4 주요 프로토콜](#l4-주요-프로토콜)
    - [포트 번호](#포트-번호)
- [Layer 7 - Application Layer](#layer-7---application-layer)
  - [L7 주요 프로토콜](#l7-주요-프로토콜)
- [더 읽을 거리](#더-읽을-거리)

# 용어

먼저 공통 용어를 정리하며 시작하겠습니다.

**1 계층**은 영어로 Layer 1, **줄여서 L1**이라고 부릅니다.
이 글에서도 글을 줄여 쓰기 위해서 물리 계층은 L1이라고 표기하겠습니다.

계층에서 처리하는 한 덩어리의 데이터 단위를 **PDU**(**Protocol Data Unit**)라고 부릅니다.
PDU는 제어 정보를 포함한 헤더(header), 데이터 자체인 페이로드(payload)로 구성되어 있습니다.
웹 서비스를 개발해보셨다면 HTTP 헤더와 바디를 생각하시면 됩니다.

PDU를 부르는 명칭도 계층마다 다릅니다.
L1에서는 비트(bit), L2에서는 프레임(frame), L3에서는 패킷(packet), L4 TCP에서는 세그먼트(segment), L4 UDP에서는 데이터그램(datagram), L7에서는 메시지(message)로 부릅니다.
특히 L3의 **IP 패킷은 넓은 의미로 네트워크를 통해 흐르는 데이터 그 자체**를 일컫기도 합니다.
뭉뚱그려서 '**패킷**'[^2]이라고 부르죠.

[^2]: Packet Capture, Packet Sniffing, Packet Loss, Packet Analyzer 등

송신 측에서 데이터를 보낼 때는 **상위 계층의 데이터에 하위 계층의 헤더(header)를 붙여서 캡슐화(encapsulation)하며** 내려가고,
수신 측에서는 그 과정을 역순으로 **디캡슐화(decapsulation)하여** 상위 계층으로 전달합니다.

**호스트**(**Host**)는 네트워크에 연결된 장치를 의미합니다.

네트워크 기기는 눈에 보이는 실제 기기인 **물리 어플라이언스**(Physical Appliance)와
가상화 소프트웨어 위에서 동작하는 논리적 네트워크 기기인 **가상 어플라이언스**(Virtual Appliance)dd로 나뉩니다.

인터넷의 통신 방식은 크게 반이중화 통신과 전이중화 통신으로 나뉩니다.
**반이중화 통신**(**half duplex**)은 전송로가 1개이기 때문에 송신과 수신을 번갈아가며 하는 방식입니다.
**전이중화 통신**(**full duplex**)은 송신용 전송로와 수신용 전송로를 별도로 준비하고,
송신과 수신을 동시에 할 수 있는 방식입니다.

<!-- ![](/images/network/network-layers/osi-7-layer-bytebytego.png) -->

<!-- *[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)* -->

<!-- ![](/images/network/network-layers/linux-network-protocol-stack.png) -->

<!-- *[ByteByteGo](https://blog.bytebytego.com/p/network-protocols-run-the-internet)* -->

# Layer 1 - Physical Layer

L1(물리 계층)은 실제 물리 매체를 통해 **디지털 신호를 전기 신호나 광신호 등으로 상호 변환**하여 송수신합니다.
L1은 데이터 전송의 가장 기본적인 단위를 담당하며, 전송 매체의 물리적 특성을 정의합니다.
케이블이나 커넥터 형태, 핀 배열 등 물리적인 사양에 관해 모두 정의되어 있는 계층입니다.

## L1 주요 기기

**NIC**(**Network Interface Card**)는 컴퓨터를 네트워크에 연결하기 위해 필요한 하드웨어입니다.
네트워크 인터페이스, 네트워크 어댑터라고도 부릅니다.
모바일 기기를 포함한 모든 네트워크 단말기는 애플리케이션과 운영체제가 처리한 패킷을
NIC를 통해 LAN 케이블이나 전파로 보냅니다.
**MAC**(**Medium access control**) 주소는 네트워크 인터페이스 카드(NIC)에 할당된 고유한 주소입니다.

유선 LAN인 **이더넷 케이블**은 IEEE 802.3로 표준화하고 있습니다.
대표적으로 트위스트 페어 케이블, 광섬유 케이블, 동축 케이블이 있습니다.
**트위스트 페어 케이블**은 구리로 만든 LAN 케이블로 흔히 UTP(Unshielded Twisted Pair)가 사용됩니다.
UTP는 실드 처리가 없기 때문에 전자석 노이즈에 약합니다.
공장 등 전자석 노이즈가 많은 환경에서는 비싸지만 안정적인 STP(Shielded Twisted Pair)를 사용합니다.
**동축 케이블**(Coaxial cable)은 고주파(높은 주파수) 전송에 적합하기 때문에 주로 TV나 오디오 신호 케이블로 사용됩니다.
트위스트 페어 케이블과 마찬가지로 구리로 만들어졌습니다.
**광섬유 케이블**(Optic fiber cable)은 광 신호를 전달하는 케이블로 유리로 만들어집니다.
줄여서 광 케이블이라고도 부릅니다.
다중 모드 광섬유 케이블은 단파장(Short Wavelength) 레이저를 사용하며, 단거리 전송에 적합합니다.
단일 모드 광섬유 케이블은 장파장(Long Wavelength) 레이저를 사용하며, 장거리 전송에 적합합니다.
전기 신호는 감쇠가 심한 반면 광 케이블은 멀리(수십 km)까지 보낼 수 있습니다.
해저 광 케이블[^3]의 경우 추가 리피터없이 300km까지 전송이 가능하다고 합니다.
다만 광 케이블은 구리선에 비해 비싼 편입니다.

[^3]: [전세계 해저 케이블 지도](https://www.submarinecablemap.com/)

일반 구리선 LAN(Local Area Network) 케이블에 흐르는 전기 신호는
전송 거리가 길수록 감쇠(Signal Attenuation)하며, 100m 정도 되면 파형이 깨지고 데이터 수신에 문제가 발생합니다.[^4]
**리피터**(**Repeater**)는 파형을 한 번 더 증폭해서 정돈한 뒤 다른 쪽으로 전송합니다.

[^4]: [실제 테스트하는 영상](https://youtu.be/WMOr3WSsu6Q)

**미디어 컨버터**(**Media Converter**)는 전기 신호와 광 신호를 서로 변환하는 기기입니다.
광 케이블을 연결하지 못하는 기기만 있는 상황에서
장거리 전송을 위해 광 케이블을 사용하고자 할 때,
또는 전자파 간섭이 심한 환경에서 안정적인 통신을 위해
기존의 전기 신호 기반 네트워크와 광 신호 기반 네트워크를 연결하는 데 사용됩니다.

**무선 LAN**은 **전파를 이용해 통신**합니다.
무선 LAN은 주파수 대역에 따라 2.4GHz, 5GHz 대역으로 나뉩니다.
2.4GHz 대역은 장애물에 강하기 때문에 옥내외에서 사용할 수 있습니다.
하지만 일상생활에서 사용되는 전자레인지, 블루투스 등에서 전파 간섭을 일으키는 경우가 많습니다.
전파 간섭이 발생하면 갑자기 연결이 끊어지거나 패킷이 소실되어 버립니다.
5GHz 대역은 사용할 수 있는 채널이 많고 동시에 사용할 수 있기 때문에
깨끗한 전파 환경을 구축할 수 있습니다.
하지만 장애물에 약하며, 옥외에서는 특정 주파수 대역(W56)만 사용할 수 있습니다.

**액세스 포인트**(**Access Point**)는 **패킷을 전파로 변조 및 복조**하는 기기입니다.
디지털 데이터를 아날로그 전파로 변환하는 것을 변조(modulation)라고 합니다.
그 반대를 복조(demodulation)라고 하죠.
쉽게 말하면 무선과 유선 사이의 다리 역할을 합니다.

# Layer 2 - Data Link Layer

L2(데이터 링크 계층)는 **직접 연결된 인접 노드(장치) 간 데이터 전송을 담당**합니다.
L2는 **MAC 주소**를 이용해 통신하며, **프레임** 단위로 데이터를 전송합니다.
다른 계층과 달리 페이로드 뒤에 **트레일러**(**trailer**)가 포함될 수 있습니다.
예를 들어, 이더넷의 **CRC**(Cyclic Redundancy Check)는 오류 검출하는 용도로 트레일러에 추가됩니다.
TCP/IP 모델에서는 L1과 L2를 합쳐 Network Access Layer로 표현합니다.

## L2 주요 기기

**브리지**(**Bridge**)는 포트와 포트 사이의 '다리 bridge' 역할을 합니다.
단말에서 받아들인 MAC 주소를 테이블(MAC address table)로 관리하고 전송합니다.
이 전송 처리를 브리징(bridging)이라고 합니다.
최근에는 L2 스위치가 브리지의 기능을 포함하고 있어서 단일 기기를 이용하지는 않습니다.

## L2 주요 프로토콜

[IEEE 802](https://en.wikipedia.org/wiki/IEEE_802)는 LAN(Local Area Network)과
MAN(Metropolitan Area Network)을 위한 표준을 정의하는 국제 표준화 기구입니다.
하위 워킹 그룹(working group)에 따라 다양한 프로토콜이 정의되어 있습니다.

**유선 LAN 프로토콜**(**IEEE 802.3**)은 이더넷(Ethernet)에 대한 표준입니다.

**무선 LAN 프로토콜**(**IEEE 802.11**)은 영어로 Wireless LAN(WLAN)이라고 하며, 와이파이(Wi-fi)가 대표적입니다.

**IEEE 802.15**는 10m 정도 이내의 **초근거리 통신인 WPAN**(**Wireless Personal Area Network**)에 대한 표준입니다.
하위 워킹 그룹으로 정말 다양한 프로토콜이 있습니다.

그 중 대표적인 것이 **IEEE 802.15.1**인 **블루투스**(**Bluetooth**)입니다.
블루투스는 저전력 근거리 통신 프로토콜입니다.
무선 LAN에 비해 전속 속도나 통신 거리가 부족하지만
소비 전력이 적고 다양한 장치를 간단히 페어링할 수 있게 때문에 널리 보급되었습니다.
초기 버전이었던 Classic Bluetooth(BR/EDR)을 넘어
현재는 BLE(Bluetooth Low Energy) 스택이 널리 사용되고 있습니다.
BLE는 주기적으로 신호를 송신하는 소형 무선 장치인 비콘(Beacon)에서도 사용됩니다.

**지그비 Zigbee**는 **IEEE 802.15.4**에서 표준화된 저전력 단거리 무선 프로토콜입니다.
무선 LAN에 비해 전송 속도나 전송 거리가 열악합니다.
하지만 데이터 송수신 시 소비 전력이 적고 슬립 시 대기 전력이 블루투스보다도 적기 때문에
스마트홈 가전이나 제조 공장의 센서 등
필요할 때만 통신하는 일이 많은 **IoT**(**Internet of Things**)에서 사용됩니다.

IEEE 802 그룹 외에도 다양한 프로토콜도 있습니다.

**RFID**(**Radio-Frequency Identification**)는 무선 주파수로 **태그**와 **리더**기 간 통신 기술입니다.
**NFC**(**Near Field Communication**)는 기본적으로 RFID를 기반으로 만들어졌습니다.
**13.56 MHz** 주파수를 사용하는 10cm 이내 초근거리 통신 기술입니다.

**PPP**(**Point-to-Point Protocol**)는 **직렬 통신**을 위한 프로토콜입니다.
전화선을 통해 인터넷에 접속하는 '다이얼업 접속'에서 사용된 프로토콜입니다.
과거 인터넷 접속 시에 사용되던 모뎀은 PPP 프로토콜을 사용했습니다.
이더넷 네트워크에서도 사용할 수 있도록 확장한 PPPoE(PPP over Ethernet)도 있습니다.

<!-- https://youtu.be/LnGHcfcC-nE -->

PPTP(Point-to-Point Tunneling Protocol)는 인터넷상에 가상 전용선(터널)을 만드는 **VPN** 프로토콜입니다.
[RFC2637](https://datatracker.ietf.org/doc/html/rfc2637)에 정의되어 있습니다.
인증 메커니즘이 취약하고 암호화 방식이 약하여 보안적으로 약점이 많아서 현재는 사용하지 않는 추세입니다.
macOS도 [Sierra(10.12)](https://support.apple.com/HT206844)부터 대응을 중단했습니다.

L2TP(Layer 2 Tunneling Protocol)도 PPTP와 마찬가지로 인터넷상에 가상 전용선을 만드는 프로토콜입니다.
[RFC2661](https://datatracker.ietf.org/doc/html/rfc2661)에 정의되어 있습니다.
보안 기능을 가진 IPsec을 함께 사용해
[L2TP over IPsec(RFC3193)](https://datatracker.ietf.org/doc/html/rfc3193)으로 사용하는 경우가 대부분입니다.

**ARP**(**Address Resolution Protocol**)는 MAC 주소와 L3에 해당되는 IP 주소를 매핑하는 프로토콜입니다.
L2와 L3 사이에 있다고 볼 수 있습니다.

# Layer 3 - Network Layer

L3(네트워크 계층)는 **다른 네트워크들을 연결**하고
**패킷(Packet) 단위의 데이터가 출발지에서 최종 목적지까지 전달되도록 경로를 선택**하는 계층입니다.
L3는 **IP 주소**를 이용해 데이터를 라우팅하고, **패킷** 단위로 데이터를 전송합니다.
또한, 혼잡 제어와 QoS(서비스 품질) 보장을 통해 네트워크의 효율성을 높입니다.

## L3 주요 기기

**라우터**(**Router**)는 단말로부터 받은 IP 패킷의 목적지 IP 주소를 보고,
라우팅 테이블을 참조하여 최적의 경로를 선택합니다.
그리고 그 경로로 패킷을 전달합니다.
이 과정을 패키지 릴레이(Package Relay)라고 하며, 흔히 라우팅(routing)이라고 합니다.
자신이 속한 네트워크 내에서도 발생할 수 있으며,
다른 네트워크로 패킷을 전달하는 경우도 포함됩니다.

**L3 스위치**(**Layer 3 Switch**)는 라우터에 L2 스위치(포트가 많은 브리지)를 추가한 기기입니다.

## L3 주요 프로토콜

**IP**(**Internet Protocol**)는
[RFC791](https://datatracker.ietf.org/doc/html/rfc791)에 정의된 프로토콜로, **패킷**을 전송하는 역할을 합니다.
패킷을 전송하기 위해 송신지 IP 주소와 수적지 IP 주소가 IP 헤더에 포함됩니다.

```plaintext
 0               1               2               3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         IP Payload (TCP Segment / UDP Datagram) ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+...
```

**ICMP**(**Internet Control Message Protocol**)는
IP 패킷을 전송하면서 발생하는 오류를 알리는 프로토콜입니다.
대표적으로 `ping`이 Echo Request와 Echo Reply 패킷을 사용해서
L3 네트워크에 접속된 단말이 살아있는지 확인하는 데 사용됩니다.

IP 패킷 헤더에는 **TTL**(**Time To Live**)이라는 패킷의 수명을 나타내는 1바이트(8비트) 필드가 있습니다.
IP 패킷의 수명은 '경유하는 라우터(Hop)의 수'를 의미합니다.
하지만 실제로 TTL 값은 L3 이상에서 동작하는 모든 기기에서 1씩 감소합니다.
값이 0이 되면 패킷이 파기되고, `Time-to-live excceded`라는 ICMPv4 패킷을 반환하고, 송신지 단말에 전달합니다.
이는 라우팅 루프 방지와 통신 경로 확인(traceroute)을 위해 사용됩니다.

### IP 주소 체계

IP 주소는 L3 네트워크에 접속된 단말을 식별하는 주소입니다.
IPv4는 32비트 주소체계를 사용하고, IPv6는 128비트 주소체계를 사용합니다.
**듀얼 스택**(**Dual Stack**)은 IPv4와 IPv6를 동시에 사용하는 방식입니다.

IPv4를 10진수로 표현할 때 8비트(1바이트)씩 점(.)으로 구분하는데,
구분된 그룹은 8비트씩 묶여서 옥텟(octet)이라고 부릅니다.
보통 IPv4 주소는 **서브넷 마스크**(**subnet mask**)와 함께 사용됩니다.
서브넷 마스크는 IP 주소를 네트워크 부분과 호스트 부분으로 나누는 역할을 합니다.
서브넷 마스크는 32비트 중 네트워크 부분을 1로, 호스트 부분을 0으로 표현합니다.
서브넷 마스크를 IP 주소와 AND 연산하면 네트워크 주소를 얻을 수 있습니다.
CIDR 표기로는 IPv4 주소 뒤에 서브넷 마스크의 '1'의 비트 수를 표기합니다.

IPv4 주소에는 예외적인 주소들이 있습니다.
루프백(Loopback) 주소인 `127.0.0.1/8`은 호스트 자기 자신을 가리키는 주소입니다.
[RFC1122](https://datatracker.ietf.org/doc/html/rfc1122)에 정의되어 있습니다.
Private IP 주소는 특정 범위의 IP 주소로, 인터넷에 공개되지 않습니다.
내부 네트워크에서만 사용할 수 있으며, 인터넷에 접속하기 위해서는 NAT와 같은 기술을 사용해야 합니다.
[RFC1918](https://datatracker.ietf.org/doc/html/rfc1918)에 정의되어 있습니다.

| Class | Start Address | End Address     | Subnet Mask       | Maximum Hosts          |
| ----- | ------------- | --------------- | ----------------- | ---------------------- |
| A     | 10.0.0.0      | 10.255.255.255  | 255.0.0.0   (/8)  | 16,777,214 (=2^24 - 2) |
| B     | 172.16.0.0    | 172.132.255.255 | 255.240.0.0 (/12) | 1,048,574  (=2^20 - 2) |
| C     | 192.168.0.0   | 192.168.255.255 | 255.0.0.0   (/16) | 65,534     (=2^16 - 2) |

**NAT**(**Network Address Translation**)는
사설(Private) IP 주소를 공인(Public) IP 주소로 상호 변환하는 기술입니다.
NAT를 사용하면 같은 사설 IP 주소를 사용하는 여러 단말이 하나의 공인 IP 주소로 인터넷에 접속할 수 있습니다.
NAT 기기를 넘어 단말끼리 직접 통신하도록 하기 위한 NAT 트래버설(NAT Traversal)이라는 기술이 있습니다.
이 중 **포트 포워딩**(**Port Forwarding**)은 특정 `IP주소:포트`로 들어온 패킷을 특정 단말로 전달하는 기술입니다.
내부(LAN)에 있는 서버를 외부(인터넷)에 공개할 때 사용합니다.

### IP 라우팅

라우터는 라우팅 테이블(Routing Table)을 통해
수신지 네트워크 정보와 IP 패킷을 전송할 근접 기기의 IP 주소를 나타내는 네트워크 홉 정보를 관리함으로써
IP 패킷의 전송 대상자를 바꿉니다.
IP 패킷의 전송 대상자를 바꾸는 기능을 **라우팅**(**Routing**)이라고 합니다.

**라우팅 프로토콜**은 그 제어 범위에 따라 IGP(Interior Gateway Protocol)와
EGP(Exterior Gateway Protocol)로 나뉩니다.
하나의 정책에 따라 관리되는 네트워크 집합을 **AS**(**Autonomous System**)라고 하는데,
AS 내부에서 라우팅하는 프로토콜을 IGP로, AS 간 라우팅하는 프로토콜을 EGP로 분류합니다.
여기서 AS는 ISP(Internet Service Provider), 기업, 연구 기관, 특정 거점 등이 될 수 있습니다.

대표적인 IGP로 **OSPF**(**Open Shortest Path First**)가 있습니다.
다익스트라 알고리즘을 기반으로 하는 링크 상태 라우팅 프로토콜(Link-state routing protocol)입니다.
링크 상태를 활용해 최적 경로를 계산합니다.

또 다른 IGP로 **RIP**(**Routing Information Protocol**)가 있습니다.
디스턴스 벡터 라우팅 프로토콜(Distance-vector routing protocol)로, 벨만-포드 알고리즘을 기반으로 합니다.
거리(distnace)와 방향(vector)를 활용해서 경로를 계산합니다.
여기에서의 거리는 수신지에 이를 때까지 경유하는 라우터의 수(홉 수)를 의미합니다.

대표적인 EGP로 **BGP**(**Border Gateway Protocol**)가 있습니다.
BGP는 AS 간 라우팅을 담당하는 프로토콜로, 경로 벡터 라우팅 프로토콜(Path-vector routing protocol)입니다.
경로(path)와 방향(vector)를 활용해서 경로를 계산합니다.
여기에서 경로는 수신지까지 경유하는 AS, 방향은 BGP peer를 나타냅니다.
BGP는 EGP이지만 AS 안에서도 사용할 수 있습니다.
AS 내부에서 사용하는 BGP를 **iBGP**(**Internal BGP**),
AS 간에 사용하는 BGP를 **eBGP**(**External BGP**)라고 부릅니다.

# Layer 4 - Transport Layer

L4(전송 계층)는 **종단 간(end-to-end) 신뢰성 있는 데이터 전송**을 담당합니다.
L4는 포트 번호를 이용해 프로세스 간 통신을 가능하게 하며, **세그먼트** 단위로 데이터를 전송합니다.
연결 지향 서비스(TCP)와 비연결 지향 서비스(UDP)를 제공하며,
흐름 제어와 오류 제어를 통해 데이터 전송의 안정성을 보장합니다.

## L4 주요 기기

**L4 로드 밸런서**(**Load Balancer**)는 여러 서버에 들어오는 트래픽(Load)을 분산(Balancing)하는 장치입니다.
L4 로드 밸런서는 L4 스위치 또는 애플리케이션 스위치라고 불리기도 합니다.
IP 혹은 Port 기반으로 헬스 체크(HC, Health Check)해서 서버의 상태를 확인하고,
사용자가 지정한 로드 밸런싱 방식을 이용해 가용성 확보를 목표로 합니다.
로드 밸런서는 L7에도 사용됩니다.[^5]

[^5]: AWS의 로드 밸런서인 ELB(Elastic Load Balancer)는 대표적으로 2가지 종류가 있습니다.
NLB(Network Load Balancer)는 L4,
ALB(Application Load Balancer)는 L7을 지원합니다.

**방화벽**(**Firewall**)은 단말 사이에서 교환되는 패킷을 검사하여 허용할지 막을지 결정하는 기기입니다.
패킷의 IP 주소나 포트 번호를 보고, 통신을 허가하거나 차단합니다.
이 통신 제어 기능을 스테이트풀 인스펙션(Stateful Inspection)이라고 합니다.
별도의 하드웨어로도 사용하지만, Netfilter 프레임워크를 이용한 iptables 같은 소프트웨어 방화벽도 널리 사용됩니다.

## L4 주요 프로토콜

**TCP**(**Transmission Control Protocol**)는
데이터 전송의 신뢰성을 요구하는 통신에서 사용합니다.
([RFC793](https://datatracker.ietf.org/doc/html/rfc793))

```plaintext
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Source Port          |       Destination Port        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Sequence Number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Acknowledgment Number                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Data |           |U|A|P|R|S|F|                               |
| Offset| Reserved  |R|C|S|S|Y|I|            Window             |
|       |           |G|K|H|T|N|N|                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           Checksum            |         Urgent Pointer        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|              TCP Payload (Application data) ...                              
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+...
```

먼저 **3 Way Handshake**를 통해 연결을 열어서 통신합니다.

```plaintext
    TCP A                                                TCP B

1.  CLOSED                                               LISTEN

2.  SYN-SENT    --> <SEQ=100><CTL=SYN>                --> SYN-RECEIVED

3.  ESTABLISHED <-- <SEQ=300><ACK=101><CTL=SYN,ACK>   <-- SYN-RECEIVED

4.  ESTABLISHED --> <SEQ=101><ACK=301><CTL=ACK>       --> ESTABLISHED

--- 통신 시작

5.  ESTABLISHED --> <SEQ=101><ACK=301><CTL=ACK><DATA> --> ESTABLISHED
```

통신이 끝나면 **4 Way Handshake**를 통해 연결을 닫습니다.[^6]

[^6]: 이 연결을 맺고 끊는 과정에서 발생하는 대기(WAIT)는 TCP가 UDP보다 느려지게 만드는 주요 원인입니다.

```plaintext
    TCP A                                                TCP B
1.  ESTABLISHED                                          ESTABLISHED

2.  (Close)
    FIN-WAIT-1  --> <SEQ=100><ACK=300><CTL=FIN,ACK>  --> CLOSE-WAIT

3.  FIN-WAIT-2  <-- <SEQ=300><ACK=101><CTL=ACK>      <-- CLOSE-WAIT

4.                                                       (Close)
    TIME-WAIT   <-- <SEQ=300><ACK=101><CTL=FIN,ACK>  <-- LAST-ACK

5.  TIME-WAIT   --> <SEQ=101><ACK=301><CTL=ACK>      --> CLOSED

6.  (2 MSL)
    CLOSED
```

여기서 **연결(Connection)이란 프로세스 간의 안정적이고 논리적인 통신 통로**를 말합니다.
이 때 연결을 위해 **소켓**(**Socket**)이라는 네트워크 통신을 위한 추상화된 인터페이스를 사용합니다.
소켓은 기본적으로 L3까지 포함하지만 속도를 높이기 위해 Loopback 통신이 필요한 경우
L3를 거치지 않는 **UDS**(**Unix Domain Socket**)를 사용하기도 합니다.
대표적으로 Docker, MySQL, Python Gunicorn 등의 `.sock` 파일이 UDS입니다.

네트워크에서는 L3까지 Unreliable 통신입니다.
Unreliable 통신에선 네트워크가 **혼잡**(**Congestion**)한 상태가 될 수 있습니다.
패킷 손실(packet loss), 패킷 순서 뒤바뀜(out of order), 패킷 중복 전송(duplicate), 과부하(network overload) 등의 오류가 발생할 수 있죠.

TCP는 데이터 전송의 신뢰성을 확보하기 위해 흐름 제어, 혼잡 제어를 제공합니다.
**흐름 제어**(**Flow Control**)는 수신자가 송신자의 속도를 따라가도록 수신자의 흐름양을 조정합니다.
대표적으로 슬라이딩 윈도우(Sliding Window) 기법이 있습니다.
**혼잡 제어**(**Congestion Control**)는 네트워크의 혼잡 상태를 감지하고 송신자의 흐름양을 조정합니다.
대표적으로 AIMD(Additive Increase/Multiplicative Decrease), 저속 시작(Slow Start), 혼잡 회피(congestion avoidance), 빠른 재전송(Fast Retransmit), 빠른 회복(Fast Recovery) 등이 있습니다.

**UDP**(**User Datagram Protocol**)는 실시간성을 요하는 애플리케이션에 사용되는
**비연결**(Connectionless) 지향 프로토콜입니다.([RFC768](https://datatracker.ietf.org/doc/html/rfc768))

```plaintext
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Source Port          |       Destination Port        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            Length             |            Checksum           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|              UDP Payload (Application data) ...                              
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+...
```

### 포트 번호

**포트 번호**(**Port Number**)는 **프로세스 간 통신을 위한 번호**입니다.

| Range         | Name                            | For                                                                      |
| ------------- | ------------------------------- | ------------------------------------------------------------------------ |
| 0 ~ 1023      | Well-Known ports (System ports) | System processes (with superuser privileges)                             |
| 1024 ~ 49151  | Registered ports                | User processes (without superuser privileges)                            |
| 49152 ~ 65535 | Dynamic, private ports          | for temporary purposes, and for automatic allocation of ephemeral ports. |

# Layer 7 - Application Layer

L7(응용 계층)은 **응용 프로그램이 네트워크 서비스를 이용할 수 있도록 인터페이스를 제공**합니다.
L4까지는 시스템 수준의 네트워크라면,
L7은 사용자 수준의 네트워크로 시스템에서 제공되는 인터페이스를 사용하여 통신합니다.
이 계층은 파일 전송, 이메일, 원격 로그인, 디렉터리 서비스, 화상 통화 등 다양한 네트워크 응용 서비스에 대한 프로토콜을 정의하고 구현합니다.

## L7 주요 프로토콜

**HTTP**(**HyperText Transfer Protocol**)는
웹 서버와 웹 클라이언트 간의 통신을 위한 프로토콜입니다.

**DNS**(**Domain Name System**)는
도메인 이름으로 IP 주소를 찾는 프로토콜입니다.

**FTP**(**File Transfer Protocol**)는
파일 전송을 위한 프로토콜입니다.

**SMTP**(**Simple Mail Transfer Protocol**)는
이메일을 전송하는 프로토콜입니다.

**SSH**(**Secure Shell**)는 원격 로그인을 위한 프로토콜입니다.
([more](/posts/network/ssh/))

**SNMP**(**Simple Network Management Protocol**)는
네트워크 장비의 상태를 모니터링하고 관리하기 위한 프로토콜입니다.
([more](/posts/network/snmp/))

**DHCP**(**Dynamic Host Configuration Protocol**)는
단말에 대해 자동으로 IP 주소를 설정하는 방법입니다.

**LDAP**(**Lightweight Directory Access Protocol**)는
디렉터리 서비스를 위한 프로토콜입니다.

**MQTT**(**Message Queuing Telemetry Transport**)는
경량 발행-구독 메시징 프로토콜로 IoT 기기 간 메시지 전달에 적합합니다.

**SIP**(**Session Initiation Protocol**)는
음성, 비디오, 메시징 애플리케이션을 포함하는 통신 세션을 시작, 유지, 종료하는 데 사용되는 신호 프로토콜입니다.
흔히 VoIP 통화를 위해 사용됩니다.

# 더 읽을 거리

- 네트워크 일반
  - [컴퓨터 네트워킹 하향식 접근](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791185475318) | James F. Kurose, Keith W. Ross
  - [IT 엔지니어를 위한 네트워크 입문](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791165213183) | 고재성, 이상훈
  - [TCP/IP Illustrated, Volume 1](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791161755632) | 케빈 폴,리차드 스티븐스
  - [데이터 통신과 네트워킹](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788960552890) | Behrouz A. Forouzan
- TCP/IP
  - [그림으로 공부하는 TCP/IP 구조](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791191600414) | 미야타 히로시
  - [(Youtube) TCP 송/수신 원리](https://youtu.be/K9L9YZhEjC0) | 널널한 개발자
  - [(Youtube) TCP Connection 이론편](https://youtu.be/X73Jl2nsqiE) | 쉬운코드
  - [(Youtube) TCP Connection 실제편](https://youtu.be/WwseO8l8rZc) | 쉬운코드
  - [(Youtube) byte-stream protocol vs message-oriented protocol](https://youtu.be/lLb2lMQpKbY) | 쉬운코드
- DNS
  - [DNS 실전 교과서](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791191600445) | 와타나베 유이, 사토 신타, 후지와라 가즈노리
- HTTP
  - [HTTP 완벽 가이드](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788966261208) | 데이빗 고울리, 브라이언 토티, 마조리 세이어, 세일루 레디, 안슈 아가왈
  - [HTTP/2 in Action](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791161754475) | 배리 폴라드
