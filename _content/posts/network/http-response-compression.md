---
draft: false
socialshare: true
date: 2025-03-23T00:10:00+09:00
lastmod: 2025-03-23T00:10:00+09:00
title: "HTTP 응답 패킷을 압축해서 Outbound 네트워크 비용 절약하기"
description: "gzip compression"
# featured_image: ["/images/network/network-layer/osi-7-layer-bytebytego.png"]
images: ["/images/network/network-layer/osi-7-layer-bytebytego.png"]
tags:
  - network
  - http
categories:
  - wiki
---

클라이언트 로딩 시간을 줄이기 위해 API 하나에 많은 걸 담기 시작했습니다.
브라우저에서는 HTTP/1.1 연결 시 최대 6개의 커넥션만 허용해주기 때문입니다.[^1]
그래서 서버 응답 데이터의 사이즈가 점점 커지기 시작했고,
덩달아 CDN과 IDC 네트워크 트래픽(outbound) 비용이 늘기 시작했습니다.
그 중에는 변하지 않는 데이터도 포함되어 있고, 변하는 데이터도 포함되어 있습니다.
변하지 않는 데이터는 중간 레이어에서 캐시를 통해 해결할 수도 있지만,
이 글에서는 서버에서 응답 데이터를 압축해서 보내는 방법을 소개합니다.

[^1]: [Chrome Docs](https://github.com/GoogleChrome/developer.chrome.com/blob/e262dd234c039ab14e4ad7c3451153d7636ac12d/site/en/docs/devtools/network/reference/index.md?plain=1#L541-L546) 참조.
최신 브라우저나 프록시 서버는 대부분 HTTP/2 혹은 HTTP/3를 지원하지만,
여러 개의 요청으로 나눈다해도 그만큼의 네트워크 트래픽이 발생합니다.

# Spring Boot 애플리케이션 설정

서버에서 클라이언트에 응답 시 응답 데이터를 압축해서 보낼 수 있습니다.
Spring Boot 애플리케이션이라면 간단하게 `application.yaml` 파일에 아래 설정만 추가하면 됩니다.

```yaml
server:
  compression:
    enabled: true
    mime-types: text/html,text/xml,text/plain,text/css,application/javascript,application/json
    min-response-size: 1024
```

Servlet Filter에서 Response의 OutputStream을 `GZIPOutputStream`으로 교체하면
좀 더 세밀하게 설정할 수 있습니다.
예를 들면, 특정 경로만 압축한다거나 압축 정도를 조절할 수 있습니다.[^2]

[^2]: [Spring 특정 API의 Response 압축하기](https://jongmin4943.tistory.com/entry/Spring-특정-API의-Response-압축하기)

# 결과

Akamai CDN을 통해서 확인해보니
[offload](https://techdocs.akamai.com/ion/docs/configure-the-origin-offload-rule#caching)
(Edge Server에서 캐시되어 Origin에서 더 이상 불러오지 않는) 트래픽 양이 확연히 늘었고,
Origin 응답 트래픽 양이 줄어들었습니다.

![Akamai CDN load compression](/images/network/http-response-compression/akamai-load-compression.png)

네트워크 대역폭과 처리량에 따라 응답 사이즈가 크지 않다면 속도에는 별 차이 없는 것 같습니다.
하지만 사이즈 자체가 작아지면서 네트워크 비용을 줄일 수 있습니다.

![before and after http response compression](/images/network/http-response-compression/before-after-http-response-compression.png)

# 더 읽을 거리

- [Compression in HTTP](https://developer.mozilla.org/docs/Web/HTTP/Guides/Compression) | MDN
- [Content-Encoding](https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Content-Encoding) | MDN
- [Transfer-Encoding](https://developer.mozilla.org/docs/Web/HTTP/Reference/Headers/Transfer-Encoding) | MDN
