---
draft: true
socialshare: true
date: 2025-03-23T12:10:00+09:00
lastmod: 2025-03-23T12:10:00+09:00
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

# 성능 측정

Google Chrome의 [Lighthouse](https://github.com/GoogleChrome/lighthouse)는
대표적인 웹 페이지 성능 측정 CLI 도구입니다.
성능 측정 외에도 웹 접근성, SEO, PWA 등을 평가할 수 있습니다.
Google Chrome의 dev tools에도 내장되어 있어서 웹 브라우저에서도 성능 측정할 수 있고,
[CI 도구](https://github.com/GoogleChrome/lighthouse-ci)로도 제공되기 때문에
CI/CD 파이프라인에 통합하여 성능 테스트를 자동화할 수 있습니다.[^1]

[^1]: [Kakao Entertainment의 사례](https://fe-developers.kakaoent.com/2022/220602-lighthouse-with-github-actions/),
[ChungJungSoo님의 사례](https://blog.chungjungsoo.dev/dev-posts/lighthouse-ci-server/)

```sh
# npm install -g lighthouse
lighthouse http://example.com --output=json --output-path=./report.json
```

[Google PageSpeed Insights](https://pagespeed.web.dev/)와 같은 온라인 툴을 사용할 수도 있습니다.

Catchpoint의 [WebPageTest](https://github.com/catchpoint/WebPageTest)는 오픈 소스로 제공되는 웹 페이지 성능 측정 도구입니다.

# 성능 개선

## CDN (Content Delivery Network)

사용자와 가까운 곳에 위치한 서버에서 콘텐츠를 제공하면 더 빠르게 콘텐츠를 받을 수 있습니다.

## HTML, CSS, JS 최적화

CSS, JS 파일을 압축하여 사용합니다.
Lazy Loading을 사용해서 Blocking을 줄입니다.

## 이미지 최적화

WEBP, AVIF와 같은 이미지 포맷을 사용하거나 이미지를 압축하여 사용합니다.
Lazy Loading을 사용해서 LCP(Largest Contentful Paint) 지표를 개선합니다.
Sprite 이미지를 사용합니다.

## 비디오 최적화

비디오를 M3U8과 같은 포맷으로 인코딩하고, 사용자의 네트워크 환경에 맞게 최적화합니다.
Youtube의 경우 기본적으로 낮은 화질을 제공하고
사용자의 설정에 맞게 네트워크 환경이 좋을 경우 높은 화질을 제공합니다.

# 더 읽을 거리

- [웹 페이지 응답 방법과 프레임워크](/posts/web/respond-web-page/)
- [Core Web Vitals](https://web.dev/articles/vitals) | web.dev
- [Web performance](https://developer.mozilla.org/en-US/docs/Web/Performance) | MDN Web Docs
