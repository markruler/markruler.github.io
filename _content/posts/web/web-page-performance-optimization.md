---
draft: false
socialshare: true
date: 2025-03-27T00:45:00+09:00
lastmod: 2025-03-27T00:45:00+09:00
title: "웹 페이지 성능 측정과 최적화"
description: "WebPageTest, Lighthouse와 CDN"
# featured_image: ["/images/master/markruler-wave.webp"]
images: ["/images/master/markruler-wave.webp"]
tags:
  - network
  - http
categories:
  - wiki
---

# 성능 지표

먼저 웹 페이지의 성능을 개선하려면 어떤 지표를 기준으로 삼을 것인지 정해야 합니다.

Google이 제공하는 **Web Vitals**는 사용자 경험을 측정하는 지표입니다.
이 중 가장 중요한 측정 항목 3개를 모아서 Core Web Vitals이라고 합니다.

- [LCP (Largest Contentful Paint)](https://web.dev/articles/lcp): 가장 큰 콘텐츠가 화면에 표시되는 시간으로 **로드 성능**을 측정.
- [INP (Interaction to Next Paint)](https://web.dev/articles/inp): 사용자 입력에 대한 응답 시간으로 **상호작용**을 측정. ([FID, First Input Delay](https://web.dev/articles/fid)에서 대체)
- [CLS (Cumulative Layout Shift)](https://web.dev/articles/cls): **시각적 안정성**을 측정.

이 외에도 웹 접근성(Web Accessibility)[^1], SEO, PWA 등을 고려하여 웹 페이지의 품질을 측정할 수 있습니다.

[^1]: 웹 사이트, 도구, 기술이 장애를 가진 사용자들이 사용할 수 있도록 설계 및 개발된 것을 말합니다.
([W3C](https://www.w3.org/WAI/fundamentals/accessibility-intro/))
[다양한 진단 도구](https://nuli.navercorp.com/education/tools)가 있습니다.

이 중 **성능(Performance)과 관련된 지표**은 LCP, INP, 그리고
리소스에 대한 요청과 응답의 첫 바이트가 도착하는 사이의 시간인 [Time to First Byte (TTFB)](https://web.dev/articles/ttfb),
사용자가 처음으로 페이지로 이동한 시간부터 페이지 콘텐츠의 일부가 화면에 렌더링되는 시간까지의 시간인 [First Contentful Paint (FCP)](https://web.dev/articles/fcp)가 있습니다.

# 성능 측정

앞서 언급한 성능 지표들은 모두
[Google Chrome의 Performance 패널](https://developer.chrome.com/docs/devtools/performance/overview)에서
측정할 수 있습니다.
이 방법으로 로컬에서 간단히 측정하는 것도 중요하긴 하지만,
캐시 없이 첫 방문하는 유저나 다른 지역의 유저들을 고려하여
서버에서 측정하는 것도 중요합니다.

Google Chrome의 [Lighthouse](https://github.com/GoogleChrome/lighthouse)는
대표적인 웹 페이지 성능 측정 CLI 도구입니다.
성능 측정 외에도 웹 접근성, SEO, PWA 등을 평가할 수 있습니다.
Google Chrome의 dev tools에도 내장되어 있어서 웹 브라우저에서도 성능 측정할 수 있고,
[CI 도구](https://github.com/GoogleChrome/lighthouse-ci)로도 제공되기 때문에
CI/CD 파이프라인에 통합하여 성능 테스트를 자동화할 수 있습니다.[^2]

[^2]: [Kakao Entertainment의 사례](https://fe-developers.kakaoent.com/2022/220602-lighthouse-with-github-actions/),
[ChungJungSoo님의 사례](https://blog.chungjungsoo.dev/dev-posts/lighthouse-ci-server/)

```sh
# npm install -g lighthouse
lighthouse http://example.com --output=json --output-path=./report.json
```

[Google PageSpeed Insights](https://pagespeed.web.dev/)와 같은 온라인 툴에서도 Lighthouse 기능을 제공합니다.

Catchpoint의 [WebPageTest](https://github.com/catchpoint/WebPageTest)는
오픈 소스로 제공되는 웹 페이지 성능 측정 도구입니다.
Waterfall 방식의 시각화와 다양한 성능 지표를 제공하기 때문에
실제로 성능 측정 시 주로 WebPageTest를 사용합니다.
여기에는 Lighthouse도 포함합니다.[^3]

[^3]: [GoogleChrome/lighthouse/README](https://github.com/GoogleChrome/lighthouse/blob/main/readme.md?plain=1#L329)

Datadog의 Synthetic Testing 중 [Browser Testing](https://docs.datadoghq.com/synthetics/browser_tests/?tab=requestoptions) 기능을
사용하면 주기적으로 국가별[^4] 성능 측정을 할 수 있습니다.
글로벌 서비스를 제공하는 경우 유용할 수 있지만 유료 기능이기 때문에,
서비스 지역이 제한적이라면 직접 클라우드 서비스의 컴퓨팅 리소스를 사용해서 성능 측정하는 것도 좋은 방법입니다.

[^4]: AWS와 같은 클라우드 서비스를 사용하기 때문에 리전에 종속적입니다.

# 성능 개선

성능은 다방면으로 개선할 수 있습니다.

## HTML, CSS, JS 최적화

**웹 브라우저**는 웹 페이지를 사용자에게 보여주기 위해 일련의 **렌더링 과정**을 거칩니다.
먼저 HTML 파일을 파싱해서 DOM 트리를 만들고,
CSS 파일을 파싱해서 CSSOM 트리를 만들고,
이 두 트리를 결합해서 렌더 트리(Render Tree)를 만듭니다.
이후 렌더 트리를 기반으로 레이아웃을 계산하고,
레이아웃을 기반으로 픽셀을 그리는 과정(Painting)을 거칩니다.

HTML 파서(parser)는 기본적으로 위에서부터 아래로 읽는데
Javascript가 중간에 있을 경우 혹은 리소스가 많을 경우 로딩 및 실행이 끝날 때까지 기다리게 됩니다.
이를 [렌더 블로킹(Render Blocking)](https://developer.chrome.com/docs/lighthouse/performance/render-blocking-resources)이라고 합니다.
렌더 블로킹을 줄이기 위해 CSS, JS 파일을 압축하고
`defer`, `async` 속성을 사용해서 지연 로딩(Lazy Loading)하면 불러오는 타이밍을 조절할 수 있습니다.[^5]
다만 CSS 파일을 `defer`로 불러오거나
Javascript에서 직접 DOM이나 CSSOM을 조작할 경우 **Reflow**(**Layout Shift**), Repaint가 발생할 수 있습니다.
여기서 Reflow의 경우 레이아웃을 다시 계산해야 하기 때문에 CLS 지표에 악영향을 끼칩니다.
그래서 Javascript에서 **직접 DOM이나 CSSOM 조작하는 것을 줄이고**,
**중요하지 않은 CSS 파일만 `defer`로 불러오는 것**이 좋습니다.[^6]

**Font**의 경우 `preload`를 사용해서 이미 연결된 호스트(ex: CDN)에서 미리 불러오면 성능을 개선할 수 있습니다.

[^5]: [async vs defer attributes](https://www.growingwiththeweb.com/2014/02/async-vs-defer-attributes.html)
[^6]: [Defer non-critical CSS](https://web.dev/articles/defer-non-critical-css) | web.dev

## 이미지 최적화

`WebP`, `AVIF`와 같은 평균 이미지 압축률이 높은 포맷을 사용하거나[^7]
**지연 로딩**(**Lazy Loading**)을 사용해서
LCP 지표를 개선합니다.

[^7]: [Serve images in modern formats](https://developer.chrome.com/docs/lighthouse/performance/uses-webp-images) | web.dev

**Sprite 이미지**를 사용해서 여러 이미지를 하나의 이미지로 합치면
한 번의 요청으로 여러 이미지를 불러올 수 있습니다.
최근에는 HTTP/2와 HTTP/3를 사용하면서
여러 리소스를 병렬로 불러올 수 있지만
최초 요청 시 Disk cache를 확보하기 위해 대기 시간(Wait Time)이 발생합니다.
크롬 브라우저는 다음 [3가지 이유로 대기](https://github.com/GoogleChrome/developer.chrome.com/blob/e262dd234c039ab14e4ad7c3451153d7636ac12d/site/en/docs/devtools/network/reference/index.md?plain=1#L541-L546)할 수 있습니다.

- There are higher priority requests.
- There are already six TCP connections open for this origin, which is the limit. Applies to HTTP/1.0 and HTTP/1.1 only.
- The browser is briefly allocating space in the disk cache.

`Queueing`은 **Connection Start 전** 위 3가지 이유로 대기하는 상태입니다.
Disable cache 옵션을 활성화하고 Hard Reload(혹은 처음 접속해서 캐시가 없는 경우) 시
요청 리소스가 많을 경우 Queueing이 길게 유지되는 것을 확인할 수 있습니다.
`Stalled`는 **Connection Start 후** 위 3가지 이유로 대기하는 상태입니다.
이를 줄이기 위해 적절한 사이즈의 Sprite 이미지를 사용할 수 있습니다.

## 비디오 최적화

비디오를 **HLS 프로토콜**([RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216))을
사용하기 위해 `M3U` 같은 포맷으로 트랜스코딩하고,
사용자의 환경(네트워크, 디바이스)에 맞게 최적화합니다.
예를 들어, Youtube의 경우 기본적으로 낮은 화질을 제공하고 사용자의 환경에 맞게 화질을 조정합니다.

## 캐시 활용

### CDN (Content Delivery Network)

**사용자와 가까운 곳에 위치한 서버**에서 콘텐츠를 제공하면 더 빠르게 콘텐츠를 받을 수 있습니다.
예를 들어, 영국에서 접속한 유저에게 영국에 위치한 서버에서 콘텐츠를 제공하면
한국에 위치한 서버에서 콘텐츠를 제공하는 것보다 더 빠르게 콘텐츠를 제공할 수 있습니다.

### 브라우저 캐시

브라우저 캐시를 활용해서 이미 불러온 리소스를 다시 불러오지 않도록 합니다.
대표적으로 **메모리 캐시**(Memory Cache), **디스크 캐시**(Disk Cache)가 있습니다.
메모리 캐시는 브라우저를 종료하면 사라지고, 디스크 캐시는 브라우저가 종료되어도 유지됩니다.

대표적으로
[Back-forward cache(bfcache)](https://developer.mozilla.org/en-US/docs/Glossary/bfcache)는
뒤로가기, 앞으로가기 버튼을 눌렀을 때 사용자 경험을 개선하기 위해 사용되는 메모리 캐시입니다.
Google Chrome Dev tools의 Application 패널 > Background services > Back-forward cache에서 확인할 수 있습니다.
이를 활용하면 뒤로가기, 앞으로가기 시 서버에 요청하지 않고 캐시된 리소스를 즉시 로딩할 수 있습니다.
다만 다른 출처의 iframe이나
WebSocket, WebRTC와 같은 실시간 연결 중인 페이지
혹은 'unload', 'beforeunload' 이벤트를 사용하는 경우 등
특정 상황에서는 bfcache가 적용되지 않습니다.
간혹 뒤로가기, 앞으로가기 시
항상 서버에 리소스를 새로 요청하도록 'Cache-Control: no-store' 헤더를 사용하거나
뒤로가기 버튼을 눌렀을 때 이전 페이지를 새로 요청하는 경우가 있습니다.
그럼 불필요한 오리진 서버 요청이 늘어날 수 있기 때문에
반드시 최신 데이터를 요청해야 하는 경우가 아니라면 캐시를 활용하는 것이 좋다고 생각합니다.

# 더 읽을 거리

- [유용한 구글 크롬(Google Chrome)의 기능](https://markruler.github.io/posts/web/google-chrome/)
- [웹 페이지 응답 방법과 프레임워크](/posts/web/respond-web-page/)
- [Core Web Vitals](https://web.dev/articles/vitals) | web.dev
  - [Optimize CLS](https://web.dev/articles/optimize-cls) | web.dev
  - [Optimize TTFB](https://web.dev/articles/optimize-ttfb) | web.dev
  - [Optimize LCP](https://web.dev/articles/optimize-lcp) | web.dev
  - [Time to Interactive (TTI)](https://web.dev/articles/tti)
  - [Browser-level image lazy loading for the web](https://web.dev/articles/browser-level-image-lazy-loading) | web.dev
  - [Best Practices for fonts](https://web.dev/articles/font-best-practices) | web.dev
- [Web performance](https://developer.mozilla.org/en-US/docs/Web/Performance) | MDN Web Docs
- [웹 서비스 캐시 똑똑하게 다루기](https://toss.tech/article/smart-web-service-cache) | toss tech
