---
date: 2020-09-23T00:58:08+09:00
lastmod: 2020-09-23T00:58:08+09:00
title: "NFV MANO 초심자 가이드"
description: "Faisal Khan"
# featured_image: "/images/nfv/mano-in-nfv.png"
images: ["/images/nfv/mano-in-nfv.png"]
tags:
  - nfv
  - virtualization
  - cloud
categories:
  - translate
---

> - [Faisal Khan의 A Beginner's Guide to NFV Management & Orchestration (MANO)](https://www.telcocloudbridge.com/blog/a-beginners-guide-to-nfv-management-orchestration-mano/)을 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

- [NFV에서 MANO란?](#nfv에서-mano란)
- [1. Virtualized Infrastructure Manager (VIM)](#1-virtualized-infrastructure-manager-vim)
- [2. Virtual Network Function Manager (VNFM)](#2-virtual-network-function-manager-vnfm)
- [3. NFV Orchestrator (NFVO)](#3-nfv-orchestrator-nfvo)
  - [Resource Orchestration](#resource-orchestration)
  - [Service Orchestration](#service-orchestration)
- [4. Repositories](#4-repositories)
  - [VNF Catalog](#vnf-catalog)
  - [Network Services (NS) Catalog](#network-services-ns-catalog)
  - [NFV Instances](#nfv-instances)
  - [NFVI Resources](#nfvi-resources)
- [5. Element Management (EM)](#5-element-management-em)
- [6. OSS/BSS](#6-ossbss)
- [7. Reference Points](#7-reference-points)

NFV가 처음이라면 NFV Management & Orchestration (NFV MANO)를 이해하려고 할 때 두 가지 어려운 점이 있습니다.

첫번째로 기존의 네트워크는 EMS, NMS 또는 OSS가 지원하는 것처럼 하나의 관리 시스템만 필요하지만
NFV 네트워크는 VIM 관리자, VNF 관리자, 오케스트레이터와 같이 여러 관리자가 필요합니다.
이것도 괜찮다면 기존 EMS와 OSS/BSS가 있습니다.
즉, 5개의 다른 관리 시스템이 필요합니다.
이 정도만 해도 NFV 초심자에게는 충분히 어렵습니다.

두번째로 NFV MANO 모델을 단순하게 설명하는 정보가 부족합니다.
예를 들어 Google의 많은 기술들은 주로 벤더의 MANO 구현 방식을 설명합니다.

ETSI 표준과 같이 MANO 아키텍처를 정의하는 표준 레퍼런스 문서가 있다고 해도
초심자가 그 문서들을 따라가기는 쉽지 않습니다.

하지만 ETSI의 MANO 모델을 이해하는 것은 굉장히 중요합니다.
우선 ETSI는 NFV 아키텍처와 프레임워크 정의에 상당한 작업을 한 최초이자 유일한 표준 기관입니다.
따라서 ETSI 모델을 이해하여 MANO를 이해할 만한 가치가 있습니다.

이 글은 가능한 한 간단하게 ETSI MANO 모델을 보여주려는 조그만 시도입니다.

그 전에 하나만 묻겠습니다!

먼저 NFV MANO에 대해 아는 것이 왜 중요할까요?

그 이유는 MANO가 NFV 아키텍처의 심장과 두뇌 역할을 하며
MANO를 이해하는 것은 전체 NFV 아키텍처를 명확하게 해줄 것이기 때문입니다.

두번째로 ETSI 모델을 참조하여 모든 벤더의 NFV 솔루션을 이해하고 벤치마킹하는 데 도움이 될 것입니다.

아니면 당신은 곧 RFP 작성을 끝내야하며 MANO 부분에 무엇을 포함해야 하는지 알고 싶을 수도 있습니다.

목표가 무엇이든 이 가이드로부터 무언가 얻고 가시기를 바랍니다.

(NFV 용어를 다시 상기해야 할 경우 [NFV 아키텍처의 치트 시트](../cheat-sheet-understanding-nfv-architecture/)를 참조하세요)

# NFV에서 MANO란?

MANO는 관리 및 오케스트레이션(Management and Orchestration)을 의미합니다.

MANO는 아래 다이어그램에서 세 가지 관리자를 포함하는 회색 블록입니다.

1. Virtualized Infrastructure Manager (VIM).
2. VNF Manager (VNFM).
3. NFV Orchestrator (VNFO).

그리고 리포지토리 그룹까지(블록 4, 그 밑에 더 있음)

![mano-in-nfv](/images/nfv/mano-in-nfv.png)

MANO 내부에 있는 4개의 블록 외에도, 외부에 기존의 요소 관리(EM)와 OSS/BSS라는 두 개의 블록이 있습니다.
두 블록은 MANO에 직접 속하지 않지만 MANO와 정보를 교환하기 때문에, 초심자는 MANO 블록과 적절한 위치에 두어야 합니다.

가상화 인프라 매니저(VIM)부터 6개 블록에 대해 설명드리겠습니다.

# 1. Virtualized Infrastructure Manager (VIM)

VIM은 `하나의 도메인`에서 NFVI 리소스를 관리합니다.

- NFVI는 NFV 환경의 물리 자원(서버, 스토리지 등), 가상 자원(가상 머신), 소프트웨어 자원(하이퍼바이저)을 포함하는 NFV 인프라(Network Functions Virtualization Infrastructure)입니다.

여기에서 `하나의 도메인`이라는 단어를 기억하세요.
NFV 아키텍처에는 각각의 NFVI 도메인을 관리하는 `multiple VIM`이 있을 수 있습니다.
오케스트레이터 섹션에서 다시 볼 것이므로 `multiple VIM`이라는 개념을 염두에 두세요.

그렇다면 VIM이 일반적으로 처리하는 작업은 무엇일까요?

다음과 같은 작업을 처리합니다.

- NFVI 도메인에 있는 가상 자원의 라이프사이클 관리. 즉, NFVI 도메인의 물리 자원으로부터 VM(가상 머신)을 생성, 유지, 해제하는 것
- 물리 자원과 연결된 가상 머신(VM) 목록 유지
- 하드웨어, 소프트웨어, 가상 자원의 성능 및 장애 관리
- Northbound API를 유지하여 물리/가상 자원을 다른 관리 시스템에 노출

# 2. Virtual Network Function Manager (VNFM)

VIM이 NFVI을 위한 것이라면 VNFM은 VNF을 위한 것입니다.

즉, VNFM은 VNF를 관리합니다.

> VNF는 라우터 VNF, 스위치 VNF 등과 같은 가상화된 네트워크 요소입니다.

구체적으로 VNFM은 다음을 수행합니다.

- VNFM은 VNF의 라이프사이클을 관리. 즉, VNF 인스턴스를 생성, 유지, 종료(VIM이 생성하고 관리하는 VM에 설치됨)
- VNF의 FCAPS(즉, VNF의 장애, 구성, 계정, 성능, 보안) 관리
- VNF를 스케일 업/다운하여 CPU 사용량을 스케일 업/다운

별도의 VNF를 관리하는 VNFM이 여러 개 있을 수도 있고,
여러 VNF를 관리하는 하나의 VNFM이 있을 수도 있습니다.

# 3. NFV Orchestrator (NFVO)

위의 섹션 1과 2를 살펴보셨다면 NFVO가 왜 필요한지 알 수 있을 것입니다.

위의 섹션 1에서 보았듯이, 각각의 NFVI 도메인을 관리하는 VIM이 여러 개 있을 수 있습니다. 이것은 `과제 1`을 만듭니다.

> 과제 1
>
> 동일한 또는 서로 다른 PoP(Point of Presence)에 여러 VIM이 있는 경우, 누가 다른 VIM의 자원을 관리/조정할까요?
> 섹션 2에서 언급한 바와 같이, 각각의 VNF를 관리하는 VNFM이 여러 개 있을 수 있습니다. 이것은 `과제 2`를 만듭니다.

> 과제 2
>
> 서로 다른 VNFM 도메인의 VNF를 포함하는 종단 간(end-to-end) 서비스 생성을
> 누가 관리/조정할까요?

이러한 과제는 NFVO의 다음 두 가지 기능이 해결해 줍니다.

## Resource Orchestration

NFVO는 서로 다른 PoP 간에 또는 하나의 PoP 내에서 NFVI 자원을 조정, 승인, 해제, 결합합니다.
이는 NFVI 자원을 직접 사용하는 대신 Northbound API를 통해 VIM과 직접 연결함으로써 수행합니다.

이 기능은 서로 다른 VIM의 자원 할당하는 `과제 1`을 직접 해결합니다.

## Service Orchestration

서비스 오케스트레이션은 서로 다른 VNF(다른 VNFM이 관리할 수 있는) 간에 종단 간 서비스를 생성하는 `과제 2`를 해결합니다.

다음과 같은 방법으로 해결합니다.

- 서비스 오케스트레이션은 VNF와 직접 통신할 필요가 없도록 각 VNFM과 조정하여 서로 다른 VNF 간에 종단 간 서비스를 생성합니다.
  예를 들면 한 벤더의 기지국 VNF와 다른 벤더의 중심 노드 VNF 사이에 서비스를 생성하는 것입니다.
- 서비스 오케스트레이션은 해당되는 VNFM을 인스턴스화할 수 있습니다.
- 네트워크 서비스 인스턴스의 토폴로지([VNF Forwarding Graph](https://docs.openstack.org/tacker/queens/user/vnffg_usage_guide.html), `VNFFG`라고도 함)도 관리합니다.

NFVO가 서로 다른 기능을 결합하고 서로 다른 방법으로 분산된 NFV 환경에서 종단 간 서비스를 생성하며 자원을 조정하는,
NFV의 접착제와 같다는 점을 알 수 있습니다.

# 4. Repositories

NFV MANO에서 서로 다른 정보를 저장하는 리포지토리(파일/목록)를 이해하는 것은 매우 중요합니다.
리포지토리에는 네 가지 유형이 있습니다.

## VNF Catalog

VNF 카탈로그는 사용 가능한 모든 VNFD(VNF Descriptor)의 저장소입니다.

VNFD는 VNF의 배포 및 동작 요구 사항 측면에서 VNF를 설명하는 배포 템플릿(deployment template)입니다.
주로 VNFM이 VNF 인스턴스화 및 VNF 인스턴스의 라이프사이클 관리 프로세스에서 사용합니다.
VNFD에서 제공된 정보는 NFVO가 NFVI의 네트워크 서비스와 가상화된 자원을 관리 및 조정하는 데도 사용됩니다.

> [역주] 예시
>
> - [VNF Descriptor (VNFD) Overview | ETSI](https://docbox.etsi.org/ISG/NFV/Open/other/Tutorials/201810-Tutorials-SDN_NFV_World_Congress-The_Haque/ETSI_NFV_Layer123_SDN_NFV_WC_2018_VNFD_RX15002.pdf)
> - [VNF Descriptor Template Guide | Openstack](https://docs.openstack.org/tacker/newton/devref/vnfd_template_description.html)

## Network Services (NS) Catalog

사용 가능한 네트워크 서비스의 목록입니다.
가상 링크를 통한 연결에 대한 설명과 VNF 측면에서 네트워크 서비스를 위한 배포 템플릿은 향후 사용을 위해 NS 카탈로그에 저장됩니다.

## NFV Instances

NFV 인스턴스 목록에는 네트워크 서비스 인스턴스 및 관련 VNF 인스턴스에 대한 모든 세부 정보가 들어 있습니다.

## NFVI Resources

NFV 서비스 구축에 활용되는 NFVI 자원의 리포지토리입니다.

다음 두 가지 관리 시스템은 NFV MANO에 속하지 않지만 NFVO MANO 기능 블록과 정보를 교환하기 때문에 설명합니다.

# 5. Element Management (EM)

EM은 MANO에 속하지 않지만 중요한 역할을 합니다.

EM은 VNF의 기능 부분에 대한 FCAPS를 담당합니다.
VNFM은 VNF의 FCAPS도 하지만 가상 부분에서만 합니다.

명확히 하기 위해 예를 들면, 일반적으로 MANO는 가상과 물리적 세계의 델타에만 책임이 있습니다.
VNFM을 예로 들면 VNF의 라이프사이클 관리와 FCAPS를 수행합니다.
장애 관리(fault management) 측면에서 VNF를 실행하는 데 문제가 있으면 VNFM이 보고하지만,
기능과 관련된 장애인 경우(예: 모바일 코어에서 일부 신호 전달 문제) EM이 보고합니다.

> 델타(delta): 수학에서 `'차이'`, `'변화'`를 나타냄.

VNFM은 운영자가 모든 종류의 FCAPS(가상 + 기능)에 대해 단일 GUI를 사용하고자 하는 경우에 대비하여 EM에 인터페이스를 노출시킵니다.

# 6. OSS/BSS

OSS/BSS는 서비스 사업자가 사업을 운영하기 위해 사용하는 시스템/애플리케이션 모음을 포함합니다.

> - OSS: Operations Support Systems
> - BSS: Business Support Systems

NFV는 OSS/BSS와 같이 동작해야 합니다.

원칙적으로는 VNF와 NFVI를 직접 관리하기 위해 기존 OSS/BSS의 기능을 확장할 수 있지만,
그것은 벤더의 독점적 구현일 수 있습니다.
(적어도 현재까지는 ETSI가 EM과 VNF 간의 인터페이스는 정의하지 않았습니다.)
NFV는 오픈 플랫폼(open platform)이기 때문에 MANO처럼 오픈 인터페이스(open interfaces)를 통해 NFV 엔터티를 관리하는 것이 더 타당합니다.

그러나 기존의 OSS/BBS는 NFV MANO의 특정 구현으로 인해 지원되지 않는 경우,
추가 기능을 제공함으로써 NFV MANO에 부가 가치를 만들 수 있습니다.
이는 NFV MANO와 기존 OSS/BSS 사이의 [오픈 참조점(open reference point)](https://telcocloudbridge.com/blog/open-ran-tutorial/)(Or-Ma-NFVO)을 통해 이루어집니다.

# 7. Reference Points

마지막으로 `참조점`에 대해 언급할 가치가 있습니다.

MANO에는 그림과 같이 기능 블록 간의 연결 포인트(interconnection point)로 표시되는 여러 참조점이 있습니다.
Or-Vi, NF-Vi, Or-Vnfm 등입니다.

왜 MANO는 그들을 인터페이스가 아닌 참조점이라고 부를까요?

`인터페이스`가 엔터티 간의 양방향 통신을 허용하는 것과 관련이 있기 때문에 MANO는 참조점을 인터페이스라고 부르지 않습니다.
참조점은 기능 블록의 외부 관점(external view)을 정의하고 노출하는 아키텍처 개념입니다.
그리고 MANO는 기능 블록에 대해 이야기하기 때문에 `참조점`이라는 단어를 대신 사용합니다.

이것이 NFV MANO에 대한 전부입니다.

> 당신의 견해를 알려주세요.
> 최종 사용자라면 NFV의 여러 관리 시스템에 대해 어떻게 생각하시나요?
> 그들이 당신에게 타당한가요?
> 기존 EMS/OSS와 어떻게 비교하시나요?\
>\
> 벤더라면 NFV MANO에서 구현 중인 부분과 힘든 점은 무엇인가요?
> 어떠한 견해라도 알려주세요.
