---
date: 2020-10-01T22:23:00+09:00
title: "NFV의 컴퓨팅 도메인에 대한 오해!"
description: "Faisal Khan"
featured_image: "/images/nfv/computer-domain-in-nfv.png"
tags:
  - nfv
  - virtualization
  - cloud
categories:
  - translate
---

> - [Faisal Khan의 The Misunderstood Facts about Compute Domain in NFV!](https://telcocloudbridge.com/blog/the-misunderstood-facts-about-compute-domain-in-nfv/)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

NFV에 대해 생각해 보세요! 그리고 x86 프로세서를 생각해 보세요... 둘은 뗄 수 없는 사이입니다. 그렇죠?

프로세서(컴퓨팅 파트)가 아무리 단순하게 들리더라도 NFV의 컴퓨팅 도메인(compute domain)이 노드의 컴퓨팅 프로세서(compute processor)가 같지 않다는 사실을 모르는 사람이 많을 것입니다. 사실... 훨씬 더 많습니다.

NFV의 "Compute Domain"과 "Compute Node"는 ETSI 정의에 따르면 동일한 것을 의미하지 않습니다. 이를 잘 알고 있으면 NFV 기본 아키텍처를 이해하는 데 많은 혼란을 피할 수 있으며, 벤더 및 고객과 이 주제에 대해 소통하는 과정에서 오해를 피할 수 있습니다.

물론 NFV의 뼈대를 제대로 세우고 싶을 겁니다. 그렇죠?

뿐만 아니라 끝까지 읽으신다면 COTs, NIC, 하드웨어 가속기와 같이 매일 듣는 서버의 필수 용어가 명확해질 것입니다.

# 우선 ETSI의 용어로 "Compute Domain"과 "Compute Node"는 무엇일까요?

![computer-domain-in-nfv](/images/nfv/computer-domain-in-nfv.png)

(NFV 아키텍처에 대한 자세한 내용을 보려면 [NFV 아키텍처](../beginners-guide-to-nfv-mano/) 또는 [NFV MANO 치트 시트](../cheat-sheet-understanding-nfv-architecture)에 대한 글을 읽는 것이 좋습니다.)

위의 NFV Infrastructure (NFVI) 블록에 명확히 나와 있듯이 컴퓨팅 도메인에는 컴퓨팅 하드웨어와 스토리지 하드웨어가 포함됩니다. 컴퓨팅 도메인은 상위 집합이며, 그 중 컴퓨팅 하드에어와 노드는 한 부분에 불과합니다.

놀랍죠? 스토리지를 컴퓨팅 도메인의 일부로 생각하는 사람이 얼마나 되겠습니까?

이제 컴퓨팅 도메인에 무엇이 포함되는지 자세히 살펴보겠습니다.

# 컴퓨팅 도메인의 세 가지 부분

## 1. 컴퓨팅 노드 (Compute Node)

상용 제품(COTS, Commercial Off-the-Shelf) 아키텍처에서 컴퓨팅 노드에는 멀티 코어 프로세서와 칩셋이 포함되어 있으며, 여기에는 다음과 같은 물리적 리소스가 포함될 수 있습니다.

- CPU 및 칩셋 (예: x86, ARM etc.)
- 메모리 하위 집합.
- 임의의 하드웨어 가속기 (예: co-processor)
- NICs (임의의 가속기를 포함한 네트워크 인터페이스 카드)
- 블레이드 내부 스토리지 (비휘발성 메모리, 로컬 디스크 스토리지)
- BIOS/부트 로더 (실행 환경의 일부)

COTS 서버 블레이드는 컴퓨팅 노드의 한 가지 예입니다.

## 2. 네트워크 인터페이스 카드 (NIC) 및 I/O 가속기

이전 섹션에서 컴퓨팅 노드의 일부로 NIC를 언급했습니다. 이건 사실입니다.
위의 경우 NIC 기능이 서버에 있기 때문입니다.
그러나 최근 세분화된 모델(예: [Open Compute Project, OCP](http://www.opencompute.org/about/)) 트렌드가 있습니다.
이 폼-팩터(form-factor)에서 CPU 블레이드/섀시는 NIC/가속기 섀시 및 스토리지 섀시와 분리됩니다.
이 블레이드/섀시들 간의 상호 연결은 광섬유를 통해 이루어질 수 있습니다.
이러한 이유로 NIC가 중요하기 때문에 별도로 설명합니다.

NIC의 주요 기능은 CPU에 네트워크 I/O 기능을 제공하는 것입니다.

NFV의 비전은 standard generic x86 서버에서 네트워크 기능을 실행하는 것입니다. 그러나 실제로 머신의 I/O 처리량을 향상시키기 위해 가속 기술을 요구하는 많은 I/O 집약적 애플리케이션(예: 가상 라우터)이 있습니다.

일부 하드웨어 가속 기술에는 다음이 포함됩니다.

- 디지털 신호 처리(DSP, Digital Signal Processing), 패킷 헤더 처리, 패킷 버퍼링 및 스케줄링과 같은 하드웨어 가속.
- 캐시 관리 기능.

이외에 새로운 소프트웨어 가속 기능을 구현하는 명령어 집합 아키텍처(ISA, Instruction Set Architecture)(예: x86, ARMv8 등)가 있습니다.

## 3. 스토리지 빌딩 블록

스토리지 인프라는 주요 드라이브 유형들을 포함합니다. 반드시 이해하고 넘어가야 하는 하드 디스크 드라이브(HDD), 솔리드 스테이트 디스크(SDD), 캐시 스토리지 등이 있습니다.

### 3.1 Hard Disk Drives (HDD)

하드 디스크는 마그네틱 스토리지를 사용하여 마그네틱 재질로 코팅된 하나 이상의
견고한 고속 회전 디스크(플래터)를 사용하여 디지털 정보를 저장하고 검색하는 데이터 저장 장치입니다.
플래터는 표면에 데이터를 읽고 쓰는 자기 헤드(magnetic heads)와 쌍을 이룹니다.
데이터는 랜덤 액세스 방식으로 접근하므로 어느 순서로도 데이터를 검색할 수 있다는 장점이 있습니다.
HDD는 비휘발성 스토리지입니다. 즉, 전원이 꺼진 상태에서도 저장된 데이터를 유지할 수 있습니다.

### 3.2 Solid State Disks (SSD)

SSD는 HDD와 달리 움직이는 부품이 없습니다.
따라서 HDD에 비해 SSD는 일반적으로 물리적 충격에 더 강하고,
조용히 실행되며, 액세스 시간과 대기 시간이 짧습니다.
따라서 SSD는 상당한 랜덤 액세스가 필요한 애플리케이션에서 사용하기 적합한 기술입니다.
하지만 HDD에 비해 상대적으로 비쌉니다.

### 3.3 Hybrid Disk Drive

점점 인기를 얻고 있는 하이브리드 하드 드라이브는 기존의 회전 플래터와
소량의 고속 플래시 메모리를 단일 드라이브에 배치하여 SSD 속도의 HDD 기능을 제공합니다.
그래서 SSD를 고속 캐시(또는 tier로 사용 가능)로 사용하고
HDD를 영구 스토리지에 사용한다는 것이 장점입니다.

"Compute Node", "NIC" 및 "Storage" 세 부분을 이해하면 컴퓨팅 도메인의 그림이 완성되고
완전한 NFV 아키텍처 서버를 만들기 때문에 정말 중요합니다.
