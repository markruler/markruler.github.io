---
date: 2020-10-02T16:24:00+09:00
title: "Observability 용어 정리"
description: "observability"
featured_image: "/images/cloud/jaeger-embed-trace-view.png"
tags:
  - cloud
categories:
  - wiki
---

# Observability

- 관측성
- 관찰성
- 관측 가능성

제어 이론에서 'observability'라는 용어는
시스템의 내부 상태 변수와 그에 따른 행동을
시스템에 대한 입력과 출력만 보고 결정할 수 있다면
그 시스템이 관측 가능하다는 것을 나타낸다.

# Event Logging

![kibana5-fluentd](/images/cloud/kibana5-fluentd.png)
*Fluentd-Kibana*

로그는 시스템 프로세스의 개별 이벤트를 기록하는 것이다.
하지만 각 로그 스트림은 단일 인스턴스에 대해서만 알려주기 때문에
마이크로서비스에서 전체적인 모니터링을 하기에는 어려움이 있다.

- [Fluentd](https://www.fluentd.org/)
- [Elastic](https://www.elastic.co/)
- [Datadog Log Management](https://docs.datadoghq.com/logs/)

# Software Tracing

![jaeger-embed-trace-view](/images/cloud/jaeger-embed-trace-view.png)
*Jaeger*

사용자의 트래픽이 지나가는 애플리케이션의 전체 스택을 추적한다.
주로 서비스를 최적화하는 데 사용된다.
예를 들어, 특정 서비스에 병목이 예상되는 경우
트레이싱해서 어떤 부분인지 확인하고 최적화를 시도해볼 수 있다.
결국 트레이싱은 구조화된 형태의 로그 이벤트일 뿐이다.

- [Jaeger](https://www.jaegertracing.io/)
- [OpenTracing](https://opentracing.io/)
- [strace](https://linux.die.net/man/1/strace) - Linux man page
- 구글 크롬의 [Network log](https://developers.google.com/web/tools/chrome-devtools/network/)

## Logging : Tracing

| Event logging                                                                                                           | Software tracing                                       |
| ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Consumed primarily by system administrators                                                                             | Consumed primarily by developers                       |
| Logs "high level" information (e.g. failed installation of a program)                                                   | Logs "low level" information (e.g. a thrown exception) |
| Must not be too "noisy" (containing many duplicate events or information that is not helpful for its intended audience) | Can be noisy                                           |
| A standards-based output format is often desirable, sometimes even required                                             | Few limitations on output format                       |
| Event log messages are often localized                                                                                  | Localization is rarely a concern                       |
| Addition of new types of events, as well as new event messages, need not be agile                                       | Addition of new tracing messages must be agile         |

## Trace : Track

- track은 시작 지점에서 시작해서 현재 지점으로 새로운 경로를 계속 따라가는 것이다.
  - To track: follow the emerging path forwards from your starting point to wherever the thing currently is.
  - When you "track" a cellphone, you monitor its current location,
    right now, and follow it wherever it goes in the future.
- trace는 현재 지점에서 시작된 지점까지 이미 완료된 경로를 따라가는 것이다.
  - To trace: follow the completed path backwards from its current point to where it began.
  - When you "trace" a cellphone call, you try to determine its origin.
    This is the same whether done right now, or for a call made a month ago.
    You go backward to the starting point.

## Distributed tracing

분산 추적은 종단 간 또는 워크플로 중심 추적이라고도 하며,
분산 시스템의 구성 요소에 의해 수행되는 인과관계가 있는 활동의 상세한 실행 정보를 수집하는 것을 목적으로 하는 일련의 기법이다.
기존의 코드 프로파일러나 dtrace 같은 호스트 레벨 추적 도구와는 달리
종단 간 추적은 주로 여러 다른 프로세스에 의해 협력적으로 수행되는 개별 실행 정보를 프로파일링하는 데 초점을 맞추고 있으며,
이와 같은 환경은 현대적이고 클라우드 네이티브한 마이크로서비스 기반 애플리케이션이 대표적이다.

# Monitoring

![grafana-visualize](/images/cloud/grafana-visualize.jpg)
*Grafana*

애플리케이션 계측(measure), 메트릭 수집(collect), 집계(aggregate), 분석(analyze) 등을 포함하는 시스템이다.
진단 목적으로 가장 많이 사용되고, 문제가 발생했을 경우 관리자에게 알람을 보낸다.
예를 들어 설정한 임계점(threshold)을 넘을 경우 이메일을 보내거나 슬랙 채널에 메시지를 보낼 수 있다.

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Thanos](https://thanos.io/)
- [Datadog](https://docs.datadoghq.com/getting_started/)

# Profiling

![android-profiler-callouts](/images/cloud/android-profiler-callouts.png)

프로그램의 공간(메모리) 또는 시간 복잡성, 특정 명령의 사용 또는 빈도를 측정하는
[동적 프로그램 분석(Dynamic program analysis)](https://en.wikipedia.org/wiki/Dynamic_program_analysis)의 한 형태다.
모니터링과 달리 벤치마킹에 주 목적이 있다.
분산 환경보다 단일 애플리케이션을 배포하기 전 성능 테스트 및 통계에 쓰인다.

- [A Guide to Java Profilers](https://www.baeldung.com/java-profilers)
- [Datadog Continuous Profiler](https://docs.datadoghq.com/tracing/profiler/)
- [Android Profiler](https://developer.android.com/studio/profile)

---

# 참조

- Observability
  - 유리 슈쿠로 <마스터링 분산 추적> 6쪽
  - [Observability](https://en.wikipedia.org/wiki/Observability) - Wikipedia
  - [CNCF Landscape](https://landscape.cncf.io/)
- Logging
  - [Logging](https://en.wikipedia.org/wiki/Logging_(software)) - Wikipedia
  - [Log management](https://en.wikipedia.org/wiki/Log_management) - Wikipedia
  - [Log analysis](https://en.wikipedia.org/wiki/Log_analysis) - Wikipedia
- Tracing
  - 유리 슈쿠로 <마스터링 분산 추적> 58쪽
  - [Tracing](https://en.wikipedia.org/wiki/Tracing_(software)) - Wikipedia
  - [Audit trail](https://en.wikipedia.org/wiki/Audit_trail) - Wikipedia
  - [Difference between Tracking and Tracing](https://ell.stackexchange.com/questions/34391/difference-between-track-and-trace)
  - [What is Distributed Tracing? - OpenTracing](https://opentracing.io/docs/overview/what-is-tracing/)
  - [Tracing vs Logging vs Monitoring: What’s the Difference?](https://www.bmc.com/blogs/monitoring-logging-tracing)
  - [Logging vs Tracing vs Monitoring](https://winderresearch.com/logging-vs-tracing-vs-monitoring/)
- Monitoring
  - [Application performance management](https://en.wikipedia.org/wiki/Application_performance_management) - Wikipedia
  - [Event monitoring](https://en.wikipedia.org/wiki/Event_monitoring) - Wikipedia
  - [Log monitor](https://en.wikipedia.org/wiki/Log_monitor) - Wikipedia
  - [Monitoring demystified: A guide for logging, tracing, metrics](https://techbeacon.com/enterprise-it/monitoring-demystified-guide-logging-tracing-metrics)
- Profiling
  - [Profiling](https://en.wikipedia.org/wiki/Profiling_(computer_programming)) - Wikipedia
