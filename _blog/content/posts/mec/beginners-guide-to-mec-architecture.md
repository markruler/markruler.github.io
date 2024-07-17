---
date: 2020-09-13T20:58:08+09:00
title: "MEC 아키텍처 초심자 가이드"
description: "Faisal Khan"
featured_image: "/images/mec/mec-architecture-according-to-etsi.jpg"
# images: ["/images/mec/mec-architecture-according-to-etsi.jpg"]
tags:
  - mec
  - nfv
  - virtualization
  - cloud
categories:
  - translate
---

> - Faisal Khan의 [Beginners Guide to MEC Architecture (Multi-access Edge Computing)](https://www.telcocloudbridge.com/blog/beginners-guide-to-mec-architecture-multi-access-edge-computing/)을 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.
> - 처음에는 MEC가 [Mobile Edge Computing](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/01.01.01_60/gs_MEC003v010101p.pdf) 의 줄임말이었지만 현재는 [Multi-access Edge Computing](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/02.01.01_60/gs_MEC003v020101p.pdf) 입니다.

MEC 아키텍처 가이드에 오신 것을 환영합니다!

MEC는 5G의 저지연(low-latency) 서비스를 활용하려는 모바일 사업자들에 의해 새로운 투자 물결을 가져올 것입니다.
이는 소비자와 더 가까운 곳(무선 기지국)에서 서비스를 운영하겠다는 것을 의미합니다.

MEC는 서비스 사업자들에게 새로운 서비스 분야와 수익 창출의 수단입니다.
예를 들어 더 빠른 게임 경험, 증강/가상 현실, 커넥티드 카 등이 있습니다.

Azure, AWS, Google과 같은 웹 스케일러(web scaler)도 대세에 뛰어들어
MEC 플랫폼을 구축하기 시작한 이유는 그만큼 잠재력을 가지고 있기 때문입니다.

본 가이드는 MEC 표준 기관인 ETSI 모델에 기반을 둡니다.
MEC 아키텍처를 맨 처음부터 구축하며 사전 지식을 요구하지 않습니다.

MEC 아키텍처를 이해하면

- 서비스 사업자는 표준 기반 MEC 플랫폼/아키텍처로 전환하는 방법을 알게 됩니다.
- 벤더와 개발자는 솔루션이 ETSI MEC 모델에 얼마나 부합하는지 고객에게 설명할 수 있습니다.

더 이상 고민하지 말고 바로 시작합시다!

밑바닥부터 블록 단위(block by block)로 MEC 아키텍처를 구축하겠습니다 🙂

# 1. MEC 정의

[ETSI](https://www.etsi.org/technologies/multi-access-edge-computing)에 따르면 MEC는 다음과 같이 정의됩니다.

"멀티 액세스 에지 컴퓨팅(MEC)은 애플리케이션 개발자와 콘텐츠 사업자에게 네트워크 에지(edge)에 있는
IT 서비스 환경과 클라우드 컴퓨팅 기능을 제공한다. 이 환경은 매우 짧은 대기 시간(초저지연)과 높은
대역폭은 물론 애플리케이션에서 활용될 수 있는 무선 네트워크 정보에 대한 실시간 접근이 특징이다."

# 2. ETSI에 따른 MEC 아키텍처

아래 그림과 같이 완전 MEC ETSI 아키텍처를 살펴보겠습니다.

![mec-architecture-according-to-etsi](/images/mec/mec-architecture-according-to-etsi.jpg)

MEC 호스트, MEC 플랫폼 매니저, MEC 오케스트레이터라는 세 가지 블록(block)이 있습니다.

이 세 블록을 보기 전에 가상화 인프라 매니저라는 가장 기본적인 블록부터 시작하겠습니다.

모든 가상 네트워크에서는 가상 머신(VM)을 돌릴 수 있도록 서버가 있어야 하며 이러한 VM에는 관리 계층이 필요합니다.

## 2-0. 가상화 인프라 관리자 (VIM, Virtualization Infrastructure Manager)

[NFV의 VIM](../../nfv/cheat-sheet-understanding-nfv-architecture/)과
유사한 기능을 가지고 있습니다. 물리적 인프라(컴퓨팅, 스토리지, 네트워킹)를 기반으로 VM 을 관리하는
것이 목적입니다. ‘가상화 인프라’의 가상 자원을 할당, 유지, 해제하는 역할을 담당합니다. 왼쪽에는 가상화된
인프라로 전환된 서버가 있고 오른쪽에는 이러한 서버의 가상 리소스를 관리하는 VIM이 있습니다.

![virtualization-infrastructure-manager](/images/mec/virtualization-infrastructure-manager.jpg)

VIM 및 가상 리소스를 이해한 후 MEC 플랫폼 및 MEC 애플리케이션을 그 위에 구축하겠습니다.

## 2-1. MEC 호스트
가상화 인프라와 함께 MEC 애플리케이션 및 MEC 플랫폼을 묶어 MEC 호스트라고 합니다.

MEC 애플리케이션부터 시작하겠습니다.

### 2-1-1. MEC 애플리케이션
우리는 왜 MEC를 운영할까요? 애플리케이션을 실행하기 위해서죠?

MEC 애플리케이션은 MEC에서 VM을 기반으로 실행되는 실제 애플리케이션입니다.
즉, MEC에서 실행되는 게임용 애플리케이션이나 가상 현실 또는 증강 현실 애플리케이션과 같은 실제 애플리케이션입니다.

아래 다이어그램은 가상화 인프라의 가상 머신 위에 MEC 애플리케이션을 실행하고 있음을 보여 줍니다.

![mec-application](/images/mec/mec-application.jpg)

### 2-1-2. MEC 플랫폼

더 나아가 MEC 플랫폼을 우리의 빌딩 블록에 추가하겠습니다. MEC 플랫폼에는 여러 구성 요소가 있습니다. 그 중 가장 중요한 것이 MEC 서비스입니다.

![mec-platform](/images/mec/mec-platform.jpg)

#### MEC 서비스

'MEC 서비스'는 MEC에서 중요한 블록입니다. 네트워크 관련 API들은 MEC 서비스에서 참조점(Reference Point) Mp1을
통해 MEC 애플리케이션에 노출됩니다. 또한 MEC 플랫폼은 이러한 서비스를 사용할 수 있습니다.

여전히 헷갈리시나요?

MEC ETSI 아키텍처의 장점은 MEC 애플리케이션들이 네트워크 정보를 알고 있으며(MEC 애플리케이션들이 그에 기반한
조치를 취할 수 있도록), MEC 서비스가 API를 통해 네트워크 정보를 노출시켜 도움을 줄 수 있다는 점입니다.

ETSI에 따르면 'MEC 서비스'에 의해 적어도 세 가지 유형의 서비스를 노출시켜야 하며, 이러한 서비스 유형은 (서비스 레지스트리의 일부분으로)

- 무선 네트워크 상태
- 위치 정보 (예: UE의 위치)
- 대역폭 관리자 - 이 서비스를 사용하면 MEC 애플리케이션에(서) 라우팅 된 특정 트래픽에 대역폭을 할당하고 우선 순위를 지정할 수 있습니다.

(PS: UE는 사용자 장비(User Equipment)를 의미하며 여기서 휴대폰을 의미할 수 있습니다. 모바일 동글이 있는 노트북을 의미하기도 합니다.)

MEC 서비스에 대해 논의한 후, 우리는 MEC 플랫폼의 다른 두 가지 구성요소를 알아야 합니다.

#### 트래픽 규칙 제어 (Traffic Rules Control)

이것은 MEC 플랫폼의 중요한 부분입니다. MEC 플랫폼은 여러 애플리케이션을 동시에 서비스하므로 "트래픽 규칙 제어" 를 통해 우선순위를 할당할 수 있어야 합니다.

#### DNS 핸들링

모바일 에지 플랫폼은 모든 UE에서 로컬 DNS 서버/프록시로 수신되는 모든 DNS 트래픽을 라우팅할 수 있는 기능을 제공해야 합니다.

이것이 왜 중요할까요? MEC의 이점은 많은 정보를 인터넷으로 보내지 않고 MEC에서 로컬로 처리하는 것입니다.
따라서 트래픽이 인터넷으로 전송되는 대신 로컬에서 처리되도록 로컬 DNS 서버에 DNS 리다이렉션을 처리할 수 있는 방법이 있어야 합니다.

## 2-2. MEC 플랫폼 관리자 (MEC Platform Manager)

![mec-platform-manager](/images/mec/mec-platform-manager.jpg)

NFV의 VNFM에 대해 알고 있으시죠?

MEC 플랫폼 관리자는 VNFM보다 동일하거나 더 적은 기능을 수행합니다. 여기에는 다음 기능이 포함됩니다.

- MEC 애플리케이션의 라이프사이클 관리: VM에서 MEC 애플리케이션을 실행(instantiating), 유지(maintaining), 해제(tearing down)
- 요소 관리: MEC 플랫폼용 FCAPS 관리
- 애플리케이션 규칙, 트래픽 규칙, DNS 구성을 관리합니다.

(역주: [FCAPS](https://ko.wikipedia.org/wiki/FCAPS): 장애 *Fault*, 구성 *Configuration*, 계정 *Accounting*, 성능 *Performance*, 보안 *Security*)

여기까지 만으로도 MEC 플랫폼을 관리할 수 있겠지만 아직 끝나지 않았습니다.
여러 MEC 호스트가 있을 수 있으므로 MEC 플랫폼 관리자도 여러 개 있을 수 있습니다.
따라서 서로 다른 MEC 플랫폼 관리자 간 조정을 할 수 있는 MEC 플랫폼 관리자 위의 계층이 있어야 합니다.
여기서 MEC 오케스트레이터가 등장하고 ETSI 아키텍처를 효과적으로 완성합니다.

## 2-3. 멀티 액세스 에지 오케스트레이터 (Multi-access Edge Orchestrator)

MEC 오케스트레이터에 대한 비유를 NFVO 오케스트레이터에 적용할 수 있습니다.

다음과 같은 기능을 수행합니다.

- MEC 애플리케이션 라이프사이클 관리(유사한 기능을 수행할 수 있는 MEC 플랫폼 관리자와 비교해보세요).
  오케스트레이터는 MEC 플랫폼 관리자를 통해 애플리케이션과 통신하여 이 기능을 수행합니다.
- 패키지 무결성(integrity) 및 신뢰성(authenticity) 검증 기능을 포함하는 애플리케이션 패키지 설치(on-boarding).
- 지연 시간, 사용 가능한 리소스, 사용 가능한 서비스와 같은 제약 조건을 기반으로 애플리케이션 생성(instantiation)에 적합한 MEC 호스트를 선택.

![multi-access-edge-orchestrator](/images/mec/multi-access-edge-orchestrator.jpg)

마지막으로 몇 가지 언급해야 할 것들이 있습니다:

## CFS Portal

모바일 사업자의 고객(the mobile operators’ customers)은 CFS(Customer Facing Service, 고객 대면 서비스)를 통해 새로운 MEC 애플리케이션을 주문하거나 서비스 SLA(Service Level Agreement, 서비스 수준 협약)를 모니터링할 수 있다.

## 사용자 애플리케이션 수명 주기 관리 프록시 (User App LCM Proxy)

이것은 MEC 시스템 선택 기능입니다. 이를 위해 시스템은 `UserApps`라는 기능을 지원해야 합니다.

모바일 에지 시스템이 `UserApps` 기능을 지원할 때, 시스템은 (디바이스 애플리케이션을 실행하는) UE와 모바일 에지 애플리케이션(ME App)의 특정 인스턴스 간 연결 설정을 허용해야 합니다.

사용자 애플리케이션 LCM 프록시를 지원한다면 디바이스 애플리케이션이 설치(on-boarding), 생성(instantiation), 사용자 애플리케이션 종료(termination) 요청을 할 수 있습니다.

간단히 말해, 이 기능이 MEC 시스템에서 지원되면 사용자는 자신의 장치에서 MEC 시스템의 특정 애플리케이션을 작동시킬 수 있습니다.

> - [원문 링크](https://www.telcocloudbridge.com/blog/beginners-guide-to-mec-architecture-multi-access-edge-computing/)

MEC 아키텍처 초심자 가이드가 끝났습니다. 이제 아키텍처에 대해 질문해주세요.


## 참조
- [ETSI GS MEC 002 V1.1.1 (2016-03)](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/01.01.01_60/gs_MEC003v010101p.pdf)
- [ETSI GS MEC 003 V2.1.1 (2019-01)](https://www.etsi.org/deliver/etsi_gs/MEC/001_099/003/02.01.01_60/gs_MEC003v020101p.pdf)
