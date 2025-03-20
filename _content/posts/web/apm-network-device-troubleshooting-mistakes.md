---
date: 2024-07-25T01:22:00+09:00
lastmod: 2024-07-25T01:22:00+09:00
title: "APM만큼 중요한 네트워크 모니터링"
description: "네트워크 장비 문제로 인한 레이턴시 증가 사례"
# featured_image: "/images/web/apm-network-device-troubleshooting-mistakes/pexels-artyusufpatel-10440498.webp"
images: ["/images/web/apm-network-device-troubleshooting-mistakes/pexels-artyusufpatel-10440498.webp"]
tags:
  - network
  - monitoring
  - APM
categories:
  - blog
---

APM은 애플리케이션 성능 모니터링(Application Performance Monitoring)입니다.
저희 팀이 사용하는 모니터링 서비스 데이터독(Datadog)은 APM에서 많은 것을 확인할 수 있습니다.
(인프라, 로그, 호스트의 프로세스, JVM 런타임 메트릭, 각 리소스별 레이턴시 등등)

# 문제

![First](/images/web/apm-network-device-troubleshooting-mistakes/first.png)

어느날 체감이 될 정도로 서비스의 레이턴시가 높아지고, 정각마다 스파이크 발생했습니다.
또한 서비스 전체에 영향이 있었습니다.

# 분석: 쉽게 간과했던 문제

[Oracle Session 히스토리](https://markruler.github.io/posts/db/oracle-dbms-session-diagnosis/)를 남겨서 확인했을 때
DB에 부하를 일으키면서 반복적으로 보이는 느린 쿼리가 없었습니다.
DB 문제는 아니었습니다.

![Oracle Session 히스토리](/images/web/apm-network-device-troubleshooting-mistakes/oracle-session.webp)

발생 시점에 반영된 소스 코드를 보니까 Public IP로 요청하던 내부 API를 Private IP로 요청하도록 변경했습니다.
이 시점에는 이게 문제라고 생각하지 않았습니다.

> **"Private IP로 요청하면 더 빠른 거 아냐?"**

모니터링 할 수 있는 모든 지표를 확인했지만, 레이턴시가 높아지는 시점에 아무런 이상이 없었습니다.
혹시 몰라서 라우터 장비에 [SNMP](/posts/network/snmp/) 모니터링을 추가했습니다.
IDC 매니저와 확인해보니 Private IP 망에 연결된 라우터의 UDP 케이블 전송 속도가 예상 속도 1Gbps가 아닌 10Mbps가 나오고 있었습니다.

![Network Router](/images/web/apm-network-device-troubleshooting-mistakes/network-router.webp)

# 해결

정말 간단하게... 케이블을 교체해서 해결되었습니다.

![Solved](/images/web/apm-network-device-troubleshooting-mistakes/solved.png)

정각마다 발생하는 스파이크는 DB 백업 솔루션에서 정각마다 실행하는 프로그램이 있어서 발생한 것입니다.

![Replace UDP Cable](/images/web/apm-network-device-troubleshooting-mistakes/replace-udp-cable.webp)

순간의 오판으로 시간을 허비했습니다.
익숙한 것도 의심하고, 모니터링의 한계점을 파악할 필요가 있다고 느꼈습니다.
