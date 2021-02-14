---
date: 2021-01-13T23:05:00+09:00
title: "쿠버네티스 레벨 트리거링 및 조정"
description: "James Bowes"
featured_image: "/images/kubernetes/k8s-triggering.png"
images: ["/images/kubernetes/k8s-triggering.png"]
socialshare: true
tags:
  - kubernetes
  - James-Bowes
  - translate
Categories:
  - cloud
---

> - James Bowes([@jrbowes](https://twitter.com/jrbowes))의 [Level Triggering and Reconciliation in Kubernetes](https://hackernoon.com/level-triggering-and-reconciliation-in-kubernetes-1f17fe30333d)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

{{< youtube tCht7FvIDdY >}}

# 시스템 프로그래밍 개념으로 보는 쿠버네티스가 클러스터를 관리하는 방법

[쿠버네티스](https://kubernetes.io/)는 현재
[가장 있기 있는](https://techcrunch.com/2017/12/18/as-kubernetes-surged-in-popularity-in-2017-it-created-a-vibrant-ecosystem/)
컨테이너 오케스트레이터입니다. 이런 성공의 밑받침은 신뢰성입니다. 모든
소프트웨어에는 버그가 있죠. 그러나 컨테이너를 실행하는 데 있어서 쿠버네티스는
다른 소프트웨어보다 버그가 적습니다.

쿠버네티스는 원하는 수의 컨테이너를 제때에 실행합니다.
그리고 그 숫자를 계속해서 유지하죠.
[공식 문서](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)에
따르면 쿠버네티스가 **자가 치유(self-healing)** 하는 것이라고 말합니다.
이런 동작 방식은 쿠버네티스 설계의 핵심 철학에서 비롯됩니다.

> "제어 루프(control loop)의 목표 탐색 행위는 매우 안정적입니다.
> 이것은 쿠버네티스에서 입증되었죠.
> 근본적으로는 제어 루프가 안정적이고 시간이 지나면 알아서 교정하기 때문에
> 버그가 있어도 알아챌 수 없었거든요.\
> \
> 에지 트리거링은 상태를 망가뜨리고 다시 원상태를 생성하지 못하게 할 위험이 있습니다.
> 레벨 트리거링은 굉장히 포용적이고, 교정되어야 할 컴포넌트가 그렇지
> 못할 경우 다시 교정될 수 있도록 여지를 줍니다. 이것이 쿠버네티스가 잘 동작하는 이유입니다."\
> \
> ― Joe Beda[^1], Heptio CTO ([Cloud Native Infrastructure](http://shop.oreilly.com/product/0636920075837.do)에서 발췌)

[^1]: 쿠버네티스 창시자 중 한 명

**잠깐: 다음은 동일한 신호에 대한 에지 및 레벨 트리거링입니다.**

![edge-and-level-triggering-for-the-same-signal](/images/kubernetes/edge-and-level-triggering-for-the-same-signal.png)

에지 및 레벨 트리거링은 전자 공학 및 [시스템 프로그래밍](https://en.wikipedia.org/wiki/Interrupt#Types_of_interrupts)에서 나온 개념입니다.
이것은 시스템이 시간에 따라 전기 신호(또는 디지털 논리) 형태에
어떻게 반응해야 하는지를 나타냅니다. 시스템은 신호가 로우(low)에서 하이(high)로,
하이에서 로우로 **바뀔 때** 신경써야 할까요, 아니면 하이에
**있는 지 여부**에 신경써야 할까요?

아래처럼 간단한 덧셈 연산을 통해 설명해보겠습니다.

```javascript
> let a = 3;
> a += 4;
< 7
```

에지 트리거링 관점에서 위 연산은 다음과 같습니다.

```javascript
add 4 to a
```

더하는 순간 한 번 발생합니다.

레벨 트리거링 관점에서는 다음과 같습니다.

```javascript
a is 7
```

더할 때부터 다음 이벤트가 발생할 때까지 계속 이러한 상태가 유지됩니다.

## 분산 시스템에서 에지 트리거링과 레벨 트리거링

추상적으로는 에지 트리거링과 레벨 트리거링 사이에 명확한 차이가 없습니다.
하지만 현실에서는 시스템 프로그래밍 수준에서도 실질적인 한계에 대처해야 합니다.
흔히 만날 수 있는 한계는 [샘플링 레이트(sampling rate)](https://en.wikipedia.org/wiki/Sampling_%28signal_processing%29#Sampling_rate)입니다.
시스템이 신호를 충분히 자주 샘플링하지 않으면 에지 트리거링에서 신호가 변할 때나
레벨 트리거링에서 짧은 변화가 일어났을 때 신호를 놓칠 수 있습니다.

대규모 컴퓨팅, 대규모 네트워킹에서는 다루어야 할
[문제들이 더 많습니다](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing).
[네트워크](http://www.cbc.ca/news/canada/nova-scotia/cellular-service-outage-bell-mobility-tellus-1.4235624)는 신뢰할 수 없고요.
사람들은 [실수를 저지릅니다](https://hothardware.com/news/dont-trip-over-the-power-cord-human-error-caused-massive-time-warner-network-outage).
다람쥐는 [말을 듣지 않고요](http://cybersquirrel1.com/).
어떤 면에선 이러한 문제들은 정확하지 않거나 일관되지 않은 샘플링 레이트와 같습니다.
신호를 보는 우리의 시야를 가리거든요.

# 신호 교란이 관측 결과를 바꿉니다

에지 및 레벨 트리거 시스템에서 신호 교란이 관측 결과에
어떤 영향을 미치는지 살펴보겠습니다.

## 이상적인 상황

![ideal-conditions](/images/kubernetes/ideal-conditions.png)

*에지 및 레벨 트리거 시스템이 신호를 해석하는 방식입니다.*

이상적인 상황에서는 에지 트리거 시스템과 레벨 트리거 시스템 모두 신호를 올바르게
관측할 수 있습니다. 신호가 사라진 직후 둘 다 신호가 사라졌다고 관측합니다.

## 두 번의 신호 교란

![two-disruptions](/images/kubernetes/two-disruptions.png)

*상승 및 하강에 신호 교란이 발생하면 에지 트리거 시스템에서 상승 신호가 손실되지만 마지막에는 올바른 상태가 됩니다.*

신호가 변할 때 두 번 발생된 신호 교란을 보면 에지 및 레벨 트리거 시스템 간의 차이가
분명해집니다. 에지 트리거 관점에서는 첫 번째 상승을 놓칩니다. 레벨 트리거 시스템은
신호가 다르게 보일 때까지 마지막으로 관측된 상태라고 가정합니다. 이는 대부분의 관측
신호가 정확하지만 신호 교란이 사라질 때까지는 그렇지 않습니다.

## 한 번의 장애

![one-disruptions](/images/kubernetes/one-disruption.png)

*에지 트리거 시스템에서는 신호 교란 하나가 중요한 곳에 생기면 큰 영향이 미칠 수 있습니다.*

신호 교란이 적다고 해서 항상 더 나은 결과를 낳는 것은 아닙니다. 신호 교란 한번으로
하강하는 신호가 가려지면 레벨 트리거 시스템은 대부분 다시 교정하지만,
에지 트리거 시스템은 두 번의 상승만 볼 수 있기 때문에 본래의 신호를 잃어버립니다.

다시 덧셈 연산으로 레벨 트리거 시스템의 신호를 나타내면 다음과 같습니다.

```javascript
> let a = 1;
> a += 1;
> a -= 1;
> a += 1;
< 2
```

그러나 에지 트리거 시스템에서는 아래와 같이 관측됩니다.

```javascript
> let a = 1;
> a += 1;
> a += 1;
< 3
```

# 희망 상태와 실제 상태 조정하기

쿠버네티스는 하나의 신호만 관측하지 않고 **희망하는(desired)** 클러스터
상태와 **실제(actual)** 클러스터 상태 두 가지를 관측합니다.
희망 상태는 클러스터를 사용하는 사람이 바라는 상태를 말합니다.
(*"애플리케이션 컨테이너 인스턴스를 두 개 실행해주세요"*)
실제 상태와 희망 상태는 가능하면 일치해야 하지만 수많은 하드웨어 오류와
유해 프로그램의 영향을 받기 쉽습니다. 희망 상태와 멀어지게 만들 수 있죠.
실제 상태가 희망 상태와 즉시 일치할 수는 없기 때문에 시간조차도 하나의
요인입니다. 예를 들면 레지스트리에서 컨테이너 이미지를 다운로드하고
애플리케이션을 정상적으로 종료하려면 시간이 필요합니다.

쿠버네티스는 실제 상태를 희망 상태로 **조정(reconcile)**[^2]해야 합니다.
계속 반복해서 두 상태를 가져오고, 차이나는 부분을 가려내고,
실제 상태를 희망 상태로 만들기 위해 어떤 변경이든 적용합니다.

[^2]: 조정(reconciliation)이란 실제 클러스터 상태를 사용자가 정의한 상태로 제어하는 것을 말합니다. 이에 대한 자세한 내용은
[소스 코드에 달린 주석](https://github.com/kubernetes-sigs/controller-runtime/blob/v0.7.0/pkg/reconcile/reconcile.go#L53-L87)을 읽어보세요.

## 쿠버네티스 디플로이먼트 스케일링

![scaling-a-deployment-in-kubernetes](/images/kubernetes/scaling-a-deployment-in-kubernetes.png)

*에지 트리거 시스템에서는 원하는 결과와 크게 달라질 수 있습니다.*

신호 교란이 없더라도 에지 트리거 시스템은 두 상태를
조정하려고 하기 때문에 잘못된 결과를 초래할 수 있습니다.

단일 컨테이너 레플리카로 시작해서 5개의 레플리카로 확장한 후
2개의 레플리카로 축소하려는 경우,
에지 트리거 시스템은 희망 상태를 아래와 같이 관측합니다.

```javascript
> let replicas = 1;
> replicas += 4;
> replicas -= 3;
```

시스템의 실제 상태는 이러한 명령에 즉시 반응할 수 없습니다.
위 다이어그램처럼 실행 중인 레플리카가 3개만 있을 때 3개의 레플리카를
종료할 수도 있습니다. 그럼 레플리카가 하나도 안 남겠죠.

레벨 트리거 시스템에서는 항상 희망 상태와 실제 상태 전체를 비교합니다.
이렇게 하면 상태 동기화 실패(state desynchronization) 버그가 발생할 가능성이 줄어듭니다.

# 안정적으로 만들기

본질적으로 에지 트리거링이 안 좋은 것은 아닙니다.
레벨 트리거링에 비해 이점도 있습니다.
에지 트리거링은 신호가 변경되었을 때 변경된 부분만 전달합니다.

신호 교란과 관련된 에지 트리거 시스템의 문제를 줄일 수도 있습니다.
흔히 레벨 트리거 시스템이 동작하는 것처럼 전체 상태를 주기적으로
조정하면서 해결합니다. 명확한 이벤트 순서와 버전 관리를 통해
신호 교란을 줄일 수도 있습니다.

분산 컴퓨팅 고유의 문제에도 불구하고 쿠버네티스는 위 문제를
레벨 트리거 시스템 관점으로 바라봄으로써 간명하고
사용자가 원하는 것을 수행하는 아키텍처가 되었습니다.

이 글에 포함된 다이어그램을 그려준 [Meg Smith](https://medium.com/@megthesmith)에게 특별히 감사드립니다.

> 역주: 쿠버네티스의 조정(Reconciliation)과 관련하여 [컨트롤러 패턴](https://kubernetes.io/docs/concepts/architecture/controller/),
> 파드 실행 흐름 등을 같이 익히는 것이 좋다고 생각합니다. 조 베다(Joe Beda)가 작성한 [좋은 글](https://blog.heptio.com/core-kubernetes-jazz-improv-over-orchestration-a7903ea92ca)이 있습니다.
> [책 <쿠버네티스 패턴>](http://book.naver.com/bookdb/book_detail.nhn?bid=16320585)도 좋았습니다.

![typical-flow-scheduling-pod](/images/kubernetes/typical-flow-scheduling-pod.png)

*출처: Core Kubernetes: Jazz Improv over Orchestration - Joe Beda*
