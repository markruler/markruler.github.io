---
date: 2020-09-13T20:58:08+09:00
lastmod: 2024-09-09T18:35:00+09:00
title: "MEC 아키텍처 초심자 가이드"
description: "Faisal Khan"
# featured_image: "/images/mec/mec-architecture-according-to-etsi.jpg"
images: ["/images/mec/mec-architecture-according-to-etsi.jpg"]
tags:
  - mec
  - nfv
  - virtualization
  - cloud
categories:
  - translate
---

> Faisal Khan의 [Beginners Guide to MEC Architecture (Multi-access Edge Computing)](https://www.telcocloudbridge.com/blog/beginners-guide-to-mec-architecture-multi-access-edge-computing/)을 번역한 글입니다.
> 저자의 허락을 받아 번역했습니다.

MEC[^1] 아키텍처 가이드에 오신 것을 환영합니다!

MEC는 5G의 저지연(low-latency) 서비스를 활용하려는 이동통신사들의 새로운 투자 물결을 가져올 것입니다.
이는 소비자와 더 가까운 곳, 즉 무선 기지국(radio site)과 가까운 곳에서 서비스를 운영하겠다는 것을 의미합니다.

MEC는 서비스 사업자들에게 새로운 서비스 분야와 수익 창출의 수단입니다.
예를 들어 더 빠른 게임 경험, 증강/가상 현실, 커넥티드 카 등이 있습니다.

이러한 잠재력 때문에 Azure, AWS, Google과 같은 웹 스케일러(web scaler)도
이 흐름에 뛰어들어 갑자기 자신들의 MEC 플랫폼을 구축하는 데 자금을 투입하기 시작한 것입니다.

이 MEC 아키텍처 가이드는 사실상 MEC 표준 기구인 ETSI 모델을 기반으로 하고 있습니다.
MEC 아키텍처를 처음부터 단계적으로 설명하며, 사전 지식이 없더라도 이해할 수 있도록 구성되어 있습니다.

MEC 아키텍처를 이해하면

- 서비스 사업자는 표준 기반 MEC 플랫폼/아키텍처로 전환하는 방법을 알게 됩니다.
- 벤더와 개발사는 솔루션 제품이 ETSI MEC 모델에 얼마나 부합하는지 고객에게 설명할 수 있습니다.

그럼 바로 시작해 보겠습니다!

- [1. MEC의 정의](#1-mec의-정의)
- [2. ETSI에 따른 MEC 아키텍처](#2-etsi에-따른-mec-아키텍처)
  - [2-0. 가상화 인프라 매니저 (VIM, Virtualization Infrastructure Manager)](#2-0-가상화-인프라-매니저-vim-virtualization-infrastructure-manager)
  - [2-1. MEC Host](#2-1-mec-host)
    - [2-1-1. MEC 애플리케이션](#2-1-1-mec-애플리케이션)
    - [2-1-2. MEC 플랫폼](#2-1-2-mec-플랫폼)
      - [2-1-2-1. MEC 서비스](#2-1-2-1-mec-서비스)
      - [2-1-2-2. 트래픽 규칙 제어 (Traffic Rules Control)](#2-1-2-2-트래픽-규칙-제어-traffic-rules-control)
      - [2-1-2-3. DNS 핸들링](#2-1-2-3-dns-핸들링)
  - [2-2. MEC 플랫폼 매니저 (MEC Platform Manager)](#2-2-mec-플랫폼-매니저-mec-platform-manager)
  - [2-3. 멀티 액세스 에지 오케스트레이터 (Multi-access Edge Orchestrator)](#2-3-멀티-액세스-에지-오케스트레이터-multi-access-edge-orchestrator)
  - [CFS Portal](#cfs-portal)
  - [사용자 애플리케이션 수명 주기 관리 프록시 (User App LCM Proxy)](#사용자-애플리케이션-수명-주기-관리-프록시-user-app-lcm-proxy)
  - [참조](#참조)

우리는 밑바닥부터 블록 단위로 MEC 아키텍처를 구축할 것입니다. 🙂

# 1. MEC의 정의

[ETSI](https://www.etsi.org/technologies/multi-access-edge-computing)에 따르면 MEC는 다음과 같이 정의됩니다.

> Multi-access Edge Computing (MEC) offers application developers and content providers
> cloud-computing capabilities and an IT service environment at the edge of the network.
> This environment is characterized by ultra-low latency and high bandwidth
> as well as real-time access to radio network information that can be leveraged by applications.\
> \
> 멀티 액세스 에지 컴퓨팅(MEC)은 애플리케이션 개발자와 콘텐츠 제공자에게
> 네트워크 에지(edge)에서 클라우드 컴퓨팅 기능과 IT 서비스 환경을 제공합니다.
> 이 환경은 초저지연과 고대역폭으로 특정지어지며,
> 애플리케이션에서 활용할 수 있는 무선 네트워크 정보에 대한 접근을 제공합니다.

# 2. ETSI에 따른 MEC 아키텍처

그럼 아래에 표시된 것처럼 완전한 MEC ETSI 아키텍처를 살펴보겠습니다.

![mec-architecture-according-to-etsi](/images/mec/mec-architecture-according-to-etsi.jpg)

MEC 호스트, MEC 플랫폼 매니저, MEC 오케스트레이터라는 세 가지 주요 블록(block)이 있습니다.

그러나 이 세 블록을 살펴보기 전에 가장 기본적인 블록인
가상화 인프라 매니저(Virtualization Infrastructure Manager, VIM)부터 시작해보겠습니다.

가상 네트워크에서는 항상 서버가 필요하며, 이 서버 위에서 가상 머신(VM)을 구동할 수 있어야 합니다.
그리고 이러한 VM에는 관리 계층이 필요합니다.

## 2-0. 가상화 인프라 매니저 (VIM, Virtualization Infrastructure Manager)

VIM은 [NFV의 VIM](../../nfv/cheat-sheet-understanding-nfv-architecture/#5-vim-virtualized-infrastructure-manager)과 유사한 기능을 합니다.
물리적 인프라(컴퓨팅, 스토리지, 네트워킹) 위에 VM을 관리하는 것이 목적입니다.
'가상화 인프라'의 가상 자원을 할당, 유지, 해제하는 역할을 담당합니다.
왼쪽에는 가상화된 인프라로 전환된 서버가 있고, 오른쪽에는 이러한 서버 위의 가상 자원을 관리하는 VIM이 있습니다.

![virtualization-infrastructure-manager](/images/mec/virtualization-infrastructure-manager.jpg)

VIM과 가상 자원을 이해한 후, 이제 그 위에 MEC 플랫폼과 MEC 애플리케이션을 구축해보겠습니다.

## 2-1. MEC Host

가상화 인프라, MEC 애플리케이션, MEC 플랫폼을 함께 묶어 MEC 호스트라고 부릅니다.

MEC 애플리케이션부터 살펴보겠습니다.

### 2-1-1. MEC 애플리케이션

우리가 MEC를 실행하는 이유는 무엇일까요? 바로 애플리케이션을 실행하기 위해서입니다.

MEC 애플리케이션은 MEC에서 VM 위에서 실행되는 실제 애플리케이션입니다.
쉽게 말해, MEC에서 실행되는 실제 앱들은 게임 애플리케이션이나 가상 현실(VR) 또는 증강 현실(AR)과 같은 것입니다.

아래 다이어그램은 가상화 인프라 내의 가상 머신 위에 MEC 애플리케이션을 실행하는 모습을 보여줍니다.

![mec-application](/images/mec/mec-application.jpg)

### 2-1-2. MEC 플랫폼

이제 다음 단계로 나아가서 우리의 빌딩 블록에 MEC 플랫폼을 추가해 보겠습니다.
MEC 플랫폼 안에는 여러 구성 요소가 있습니다.
그중에서 가장 중요한 것은 **MEC 서비스**입니다.

![mec-platform](/images/mec/mec-platform.jpg)

#### 2-1-2-1. MEC 서비스

'MEC 서비스'는 MEC에서 중요한 블록입니다.
네트워크 관련 API는 MEC 서비스에 의해 노출되며, 위에 표시된 참조점(Reference Point) `Mp1`을 통해 MEC 애플리케이션에 제공됩니다.
또한 MEC 플랫폼도 이러한 서비스를 사용할 수 있습니다.

여전히 헷갈리시나요?

MEC ETSI 아키텍처의 장점은 MEC 애플리케이션들이 네트워크 정보를 알고 있다는 점입니다.
즉, MEC 애플리케이션이 네트워크 상태에 따라 조치를 취할 수 있습니다.
여기서 MEC 서비스는 API를 통해 네트워크 정보를 노출시켜 도움을 줄 수 있습니다.

ETSI에 따르면 'MEC 서비스'에 의해 적어도 세 가지 유형의 서비스를 노출시켜야 하며,
이들은 서비스 레지스트리의 일부입니다.

- 무선 네트워크 상태
- 위치 정보 (예: 사용자 장비[^2]의 위치)
- 대역폭 관리자 - 이 서비스를 사용하면 MEC 애플리케이션과 관련된 트래픽에 대해 대역폭을 할당하고 우선순위를 지정할 수 있도록 해줍니다.

MEC 서비스에 대해 논의한 후, 우리는 MEC 플랫폼의 다른 두 가지 구성요소도 알아야 합니다.

#### 2-1-2-2. 트래픽 규칙 제어 (Traffic Rules Control)

이것은 MEC 플랫폼의 중요한 부분입니다.
MEC 플랫폼은 여러 애플리케이션을 동시에 서비스하므로 '트래픽 규칙 제어' 를 통해 우선순위를 할당할 수 있어야 합니다.

#### 2-1-2-3. DNS 핸들링

모바일 에지 플랫폼은 모든 사용자 장비로부터 수신된 DNS 트래픽을
로컬 DNS 서버/프록시로 라우팅하는 기능을 제공해야 합니다.

이것이 왜 중요할까요? MEC의 이점은 많은 정보를 인터넷으로 보내지 않고 MEC 내에서 로컬로 처리하는 것입니다.
따라서 트래픽이 인터넷으로 전송되는 대신 로컬에서 처리되도록 로컬 DNS 서버에 DNS 리다이렉션을 처리할 수 있는 방법이 있어야 합니다.

또한 `Mp3` 인터페이스를 통해 기존 MEC 호스트에 연결된 다른 MEC 호스트가 있을 수 있다는 점도 유의해야 합니다.

지금까지 VIM, MEC 플랫폼, MEC 애플리케이션을 다뤘지만,
MEC 플랫폼과 애플리케이션 자체의 관리는 어떻게 이루어질까요?
여기서 **MEC 플랫폼 매니저**가 등장합니다.

## 2-2. MEC 플랫폼 매니저 (MEC Platform Manager)

![mec-platform-manager](/images/mec/mec-platform-manager.jpg)

NFV의 VNFM에 대해 알고 있으시죠?

MEC 플랫폼 매니저는 VNFM과 동일하거나 더 많은 기능을 수행합니다. 다음과 같은 기능들을 포함합니다.

- MEC 애플리케이션의 수명 주기 관리: VM에서 MEC 애플리케이션을 생성(instantiating), 유지(maintaining), 종료(tearing down)하는 작업
- 요소 관리: MEC 플랫폼의 FCAPS[^3] 관리
- 애플리케이션 규칙, 트래픽 규칙, DNS 구성 관리

지금까지는 MEC 플랫폼을 관리할 수 있게 되었지만 아직 끝난 것이 아닙니다.
여러 MEC 호스트가 있을 수 있으므로 MEC 플랫폼 관리자도 여러 개 있을 수 있습니다.
따라서 다양한 MEC 플랫폼 매니저들 간의 조정을 담당할 상위 계층이 필요합니다.
여기서 **MEC 오케스트레이터**가 등장하며, 이를 통해 ETSI 아키텍처가 완성됩니다.

## 2-3. 멀티 액세스 에지 오케스트레이터 (Multi-access Edge Orchestrator)

MEC 오케스트레이터는 여기서 NFVO 오케스트레이터와 비유할 수 있습니다.

다음과 같은 기능을 수행합니다.

- MEC 애플리케이션 수명 주기 관리(MEC 플랫폼 매니저와 비교해보면 유사한 기능을 수행할 수 있습니다).
  오케스트레이터는 MEC 플랫폼 매니저를 통해 애플리케이션과 통신하여 이 기능을 수행합니다.
- 패키지 무결성(integrity) 및 신뢰성(authenticity) 검증 기능을 포함하여
  애플리케이션 패키지를 설치(on-boarding)합니다.
- 지연 시간, 사용 가능한 자원, 제공 가능한 서비스와 같은 제약 조건을 고려하여
  애플리케이션 생성(instantiation)에 적합한 MEC 호스트를 선택합니다.

![multi-access-edge-orchestrator](/images/mec/multi-access-edge-orchestrator.jpg)

마지막으로 몇 가지 언급해야 할 것들이 있습니다.

## CFS Portal

CFS는 '고객 대면 서비스(Customer Facing Service)'를 의미합니다.
CFS를 통해 이동통신사의 고객은 새로운 MEC 애플리케이션을 주문하거나
서비스의 SLA(Service Level Agreement, 서비스 수준 계약)를 모니터링할 수 있습니다.

## 사용자 애플리케이션 수명 주기 관리 프록시 (User App LCM Proxy)

이것은 MEC 시스템에서 선택적 기능입니다.
이를 위해 시스템은 `UserApps`라는 기능을 지원해야 합니다.

모바일 에지 시스템이 `UserApps` 기능을 지원할 때,
시스템은 사용자 장비(디바이스 애플리케이션이 실행되는 장비)와
특정 모바일 에지 애플리케이션(ME App) 인스턴스 간의 연결을 허용합니다.

사용자 애플리케이션 LCM 프록시를 지원한다면
디바이스 애플리케이션이 사용자 애플리케이션의 설치(on-boarding), 생성(instantiation), 종료(termination)를 요청할 수 있게 해줍니다.

간단히 말해, 이 기능이 MEC 시스템에서 지원되면
사용자는 자신의 디바이스에서 MEC 시스템 내 특정 애플리케이션을 실행할 수 있게 됩니다.

이것으로 MEC 아키텍처 초심자 가이드를 마칩니다.
이제 이 아키텍처에 대해 궁금한 것이 있으면 언제든 질문해 주세요.

## 참조

- [ETSI GS MEC 002 V1.1.1 (2016-03)](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/01.01.01_60/gs_MEC003v010101p.pdf)
- [ETSI GS MEC 003 V2.1.1 (2019-01)](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/02.01.01_60/gs_MEC003v020101p.pdf)

[^1]: 처음에는 MEC가 [Mobile Edge Computing](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/01.01.01_60/gs_MEC003v010101p.pdf) 의 줄임말이었지만 현재는 [Multi-access Edge Computing](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/02.01.01_60/gs_MEC003v020101p.pdf)입니다.
[^2]: 사용자 장비(UE, User Equipment)는 휴대폰을 의미할 수 있습니다. 모바일 동글이 있는 노트북을 의미하기도 합니다.
[^3]: [FCAPS](https://ko.wikipedia.org/wiki/FCAPS): **F**ault(장애), **C**onfiguration(구성), **A**ccounting(계정), **P**erformance(성능), **S**ecurity(보안)
