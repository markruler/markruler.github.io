---
date: 2020-09-22T21:58:08+09:00
title: "\"NFV 아키텍처\" 이해를 위한 치트 시트"
description: "Faisal Khan"
featured_image: "/images/nfv/nfv-architecture.png"
tags:
  - nfv
  - virtualization
  - cloud
categories:
  - translate
---

> - [Faisal Khan의 A Cheat Sheet for Understanding "NFV Architecture"](https://www.telcocloudbridge.com/blog/a-cheat-sheet-for-understanding-nfv-architecture/)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

시간이 없으신가요?

쉽게 이해할 수 있는 NFV 용어/아키텍처에 대한 빠른 업데이트가 필요하신가요?

그렇다면 NFV 아키텍처를 시작하는 데 필요한 모든 정보를 얻을 수 있는 아래 7가지 주요 블록을 보세요. 블록 번호 및 정의를 따라가세요.

![nfv-architecture](/images/nfv/nfv-architecture.png)

## 1. VNF (Virtual Network Function)

VNF는 가상화된 네트워크 요소로 NFV 아키텍처의 기본 블록입니다.
예를 들어 라우터를 가상화하면 라우터 VNF라고 부르고, 다른 예는 기지국(base station) VNF도 있습니다.
네트워크 요소의 한 가지 하위 기능(sub-function)만 가상화해도 VNF라고 합니다.
예를 들어 라우터의 다양한 하위 기능은 가상 라우터로서 함께 작동하는 별도의 VNF가 될 수 있다.

VNF의 다른 예로는 방화벽(firewall), IPS, GGSN, SGSN, RNC, EPC 등이 있습니다.

## 2. EM (Element Management)

EM은 VNF의 요소 관리 시스템(EMS)입니다.
이것은 VNF(즉, FCAPS: Fault, Configuration, Accounting, Perfomance, Security) 기능을 관리합니다.
독점적 인터페이스를 통해 VNF를 관리할 수도 있습니다.
VNF당 1개의 EMS가 있을 수도 있고 하나의 EMS가 여러 개의 VNF를 관리할 수도 있습니다.
EMS 자체가 VNF일 수 있습니다.

## 3. VNF Manager

VNF 매니저는 하나 또는 여러 VNF 인스턴스의 라이프사이클을 관리합니다.
라이프사이클 관리란 VNF를 할당, 유지, 해제하는 것을 말합니다.

또한 VNFM(VNF 매니저)은 VNF의 가상 부분에 대해 FCAPS를 수행한다.

EM 및 VNFM의 차이에 유의해야 합니다.
EM은 기능 요소를 관리하는 반면, VNFM은 가상 요소를 관리합니다.
다음 예시로 명확하게 설명하겠습니다. 모바일 코어가 가상화된 경우,
EM은 기능 부분(예: 모바일 신호 전달)을 관리하고,
VNFM은 가상 부분(예: 자체 VNF 생성)을 관리합니다.

## 4. NFVI (Network Function Virtualization Infrastructure)

NFVI는 VNF가 실행되는 환경입니다.
여기에는 아래에 설명된 물리 자원, 가상 자원 및 가상화 계층이 포함된다.

### 4.1 Compute, Memory and Networking Resources

NFVI의 물리적인 부분입니다.
가상 자원은 이러한 물리 자원에 의해 인스턴스화 됩니다.
모든 물리 스위치 또는 물리 서버, 물리 스토리지 서버는 이 범주에 포함됩니다.

### 4.2 Virtual Compute, Virtual Memory and Virtual Networking Resources

NFVI의 가상 부분입니다.
물리 자원은 궁극적으로 VNF가 활용하는 가상 자원으로 추상화됩니다.

### 4.3 Virtualization Layer

가상화 계층은 물리 자원을 가상 자원으로 추상화하는 역할을 담당합니다. 일반적인 산업 용어로 `하이퍼바이저`라고 합니다.
이 계층은 소프트웨어가 하드웨어로부터 독립적으로 실행될 수 있도록 합니다.

가상화 계층이 없다고 가정할 때, VNF가 물리 자원에서 직접 실행될 수 있다고 생각할 수 있습니다.
그러나 정의상 VNF라고 부를 수 없으며 NFV 아키텍처라고도 할 수 없습니다.
적절하게 PNF(물리 네트워크 기능)라고 불릴 수 있습니다.

## 5. VIM (Virtualized Infrastructure Manager)

NFVI를 위한 관리 시스템입니다.
한 사업자의 인프라 도메인 내에서 NFVI 컴퓨팅, 네트워크 및 스토리지 리소스를 제어하고 관리합니다.
성능 측정 및 이벤트 수집도 담당합니다.

## 6. NFV Orchestrator

VNF의 네트워크 서비스를 직접 생성, 유지, 해제합니다.
VNF가 여러 개 있는 경우 여러 VNF 종단 간(end-to-end) 서비스를 생성할 수 있도록 합니다.

NFVI 자원의 전역 자원(global resource)도 관리합니다.
예를 들어 네트워크에 있는 여러 VIM 간에 컴퓨팅, 스토리지 및 네트워킹 자원 등의 NFVI 자원을 관리합니다.

오케스트레이터는 VNF와 직접 통신하지 않고 VNFM과 VIM을 통해 기능을 수행합니다.

예시:
종단 간 서비스를 생성하기 위해 체인을 연결해야 하는 VNF가 여러 개 있다고 가정해 봅시다.
이러한 사례의 한 예는 가상 기지국과 가상 EPC입니다. 이것들은 동일하거나 다른 벤더일 수 있습니다.
양쪽의 VNF를 모두 사용하여 종단 간 서비스를 생성해야 할 것입니다.
이를 위해서는 서비스 오케스트레이터가 두 VNF와 통신하여 종단 간 서비스를 생성해야 합니다.

## 7. OSS/BSS(Operation Support System/Business Support System)

OSS/BSS는 사업자의 OSS/BSS를 말한다.
OSS는 네트워크, 장애, 구성, 서비스를 관리합니다.
BSS는 고객, 제품, 주문 등을 관리합니다.

NFV 아키텍처에서 사업자의 현재 BSS/OSS는 표준 인터페이스를 통해 NFV MANO (Management and Orchestration)와 통합할 수 있습니다.

이게 전부입니다!

> - [원문 링크](https://www.telcocloudbridge.com/blog/a-cheat-sheet-for-understanding-nfv-architecture/)

사용 사례 및 SDN과의 관계를 포함한 NFV에 대한 자세한 내용을 보려면
헤더 섹션의 링크에서 NFV 마인드맵을 다운로드하세요.
개념을 더 쉽게 따라가기 위해 레퍼런스로 사용할 수 있도록 NFV 마인드 맵을 만들었습니다.

코멘트를 남겨서 NFV 아키텍처용 `치트 시트`에 대해 어떻게 생각하는지 알려주세요.
