---
date: 2020-10-02T16:24:00+09:00
title: "마이크로서비스 기반 observability 용어 정리"
description: "observability"
featured_image: "/images/cloud/jaeger-embed-trace-view.png"
tags:
  - cloud
categories:
  - cloud
---

observability 관련 용어를 명확히 설명하기 힘들어서 공부하는 중.

## Observability

- 관측성
- 관찰성
- 관측 가능성

> 제어 이론에서 'observability'라는 용어는 시스템의 내부 상태와 그에 따른 행동을 시스템에 대한 입력과 출력만 보고 결정할 수 있다면 그 시스템이 관측 가능하다는 것을 나타낸다. - <마스터링 분산 추적> p6

## Logging

> [CNCF Landscape](https://landscape.cncf.io/) : [Fluentd](https://www.fluentd.org/)\
> [Elastic](https://www.elastic.co/)

![kibana5-fluentd](/images/cloud/kibana5-fluentd.png)
*Fluentd-Kibana*

로그는 시스템 프로세스의 개별 이벤트를 기록하는 것이다.
하지만 각 로그 스트림은 한 서비스의 단일 인스턴스에 대해서만 알려주기 때문에 마이크로서비스에서 전체적인 모니터링을 하기에는 어려움이 있다.

## Tracing

> [CNCF Landscape](https://landscape.cncf.io/) : [Jaeger](https://www.jaegertracing.io/), [OpenTracing](https://opentracing.io/)

> [Difference between Tracking and Tracing](https://ell.stackexchange.com/questions/34391/difference-between-track-and-trace):\
> \
> To trace: follow the completed path backwards from its current point to where it began.\
> To track: follow the emerging path forwards from your starting point to wherever the thing currently is.\
> \
> When you "trace" a cellphone call, you try to determine its origin. This is the same whether done right now, or for a call made a month ago. You go backward to the starting point.\
> When you "track" a cellphone, you monitor its current location, right now, and follow it wherever it goes in the future.

![jaeger-embed-trace-view](/images/cloud/jaeger-embed-trace-view.png)
*Jaeger*

사용자의 트래픽이 지나가는 애플리케이션의 전체 스택을 추적한다.
리눅스에서 쓰이는 strace, 구글 크롬의 [Network log](https://developers.google.com/web/tools/chrome-devtools/network/) 등
흔히 접하는 것들도 트레이싱 도구다.
주로 서비스를 최적화하는 데 사용된다.
예를 들어, 특정 서비스에 병목이 예상되는 경우
트레이싱해서 어떤 부분인지 확인하고 최적화를 시도해볼 수 있다.
결국 트레이싱은 구조화된 형태의 로그 이벤트일 뿐이다.

### Distributed tracing

> <마스터링 분산 추적> p58

분산 추적은 종단 간 또는 워크플로 중심 추적이라고도 하며, 분산 시스템의 구성 요소에 의해 수행되는 인과관계가 있는 활동의 상세한 실행 정보를 수집하는 것을 목적으로 하는 일련의 기법이다. 기존의 코드 프로파일러나 dtrace 같은 호스트 레벨 추적 도구와는 달리 종단 간 추적은 주로 여러 다른 프로세스에 의해 협력적으로 수행되는 개별 실행 정보를 프로파일링하는 데 초점을 맞추고 있으며, 이와 같은 환경은 현대적이고 클라우드 네이티브한 마이크로서비스 기반 애플리케이션이 대표적이다.

## Monitoring

> [CNCF Landscape](https://landscape.cncf.io/) : [Prometheus](https://prometheus.io/), [Thanos](https://thanos.io/)

![grafana-visualize](/images/cloud/grafana-visualize.jpg)
*Grafana*

애플리케이션을 계측하고
메트릭 수집(collect), 집계(aggregate), 분석(analyze)을 포함하는 시스템이다.
진단 목적으로 가장 많이 사용되고, 문제가 발생했을 경우 관리자에게 경고를 보낸다.


## Profiling

> [Android Profiler](https://developer.android.com/studio/profile)

![android-profiler-callouts](/images/cloud/android-profiler-callouts.png)

~~(Monitoring + Tracing)~~
모니터링과 달리 벤치마킹에 주 목적이 있다.
분산 환경보다 단일 애플리케이션을 배포하기 전 성능 테스트 및 통계에 쓰인다.

---

## 참조

- <마스터링 분산 추적> - 유리 슈쿠로
- [Tracing vs Logging vs Monitoring: What’s the Difference?](https://www.bmc.com/blogs/monitoring-logging-tracing)
- [Logging vs Tracing vs Monitoring](https://winderresearch.com/logging-vs-tracing-vs-monitoring/)
- [Monitoring demystified: A guide for logging, tracing, metrics](https://techbeacon.com/enterprise-it/monitoring-demystified-guide-logging-tracing-metrics)
- [What is Distributed Tracing? - OpenTracing](https://opentracing.io/docs/overview/what-is-tracing/)