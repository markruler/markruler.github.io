---
draft: false
socialshare: true
date: 2025-04-13T22:38:00+09:00
lastmod: 2025-04-13T22:38:00+09:00
title: "웹과 멀티미디어: 이미지"
description: "image"
# featured_image: ["/images/master/markruler-wave.webp"]
images: ["/images/master/markruler-wave.webp"]
tags:
  - web
  - multimedia
  - image
categories:
  - wiki
---

- [개요](#개요)
- [image 관련 용어](#image-관련-용어)
- [이미지 파이프라인 (Image Pipeline)](#이미지-파이프라인-image-pipeline)
  - [카메라: 필름 vs 디지털 센서](#카메라-필름-vs-디지털-센서)
  - [ISP: 이미지 신호 처리](#isp-이미지-신호-처리)
- [이미지 포맷](#이미지-포맷)
  - [래스터 이미지](#래스터-이미지)
    - [JPG: 손실 압축 이미지 포맷](#jpg-손실-압축-이미지-포맷)
    - [GIF: 팔레트 기반 애니메이션 포맷](#gif-팔레트-기반-애니메이션-포맷)
    - [PNG: 무손실 압축 이미지 포맷](#png-무손실-압축-이미지-포맷)
    - [WebP](#webp)
    - [AVIF: AV1 기반 이미지 포맷](#avif-av1-기반-이미지-포맷)
  - [벡터 이미지](#벡터-이미지)
    - [SVG](#svg)
- [웹 페이지에서 이미지 최적화](#웹-페이지에서-이미지-최적화)
  - [반응형 이미지 (Responsive Images)](#반응형-이미지-responsive-images)
  - [지연 로딩 (Lazy Loading)](#지연-로딩-lazy-loading)
  - [이미지 스프라이트 (Image Sprite)](#이미지-스프라이트-image-sprite)
- [웹 접근성: alt 속성](#웹-접근성-alt-속성)
  - [왜 `alt` 속성이 중요한가](#왜-alt-속성이-중요한가)
  - [좋은 `alt` 텍스트를 작성하는 방법](#좋은-alt-텍스트를-작성하는-방법)
- [결론](#결론)
- [더 읽을 거리](#더-읽을-거리)

# 개요

웹 페이지에서 이미지는 사용자 경험을 풍부하게 하고 정보를 효과적으로 전달하는 핵심 요소입니다.
하지만 제대로 관리되지 않은 이미지는 웹사이트 로딩 속도를 저하시키고,
사용자 이탈률을 높이며, 결국 비즈니스 목표 달성에 부정적인 영향을 미칩니다.

이 글에서는 웹 개발자가 반드시 알아야 할 이미지 관련 지식을 총정리합니다.
올바른 이미지 포맷 선택부터 다양한 최적화 기법, 접근성 고려 사항, 그리고 성능 및 SEO에 미치는 영향까지 다룹니다.

# image 관련 용어

"image"는 라틴어에서 유래했습니다.
라틴어 명사인 "imago"는 "모습, 상, 형태, 그림"을 뜻하며, 구체적으로 어떤 대상을 시각적으로 재현한 것을 의미합니다.
이 단어는 라틴어 동사 "imitor"(흉내 내다, 모방하다)와 연관이 있습니다.
즉, 어떤 것을 흉내 내거나 모방한 결과로서의 형상이라는 개념을 내포하고 있습니다.

대표적인 유사어로는 Photo, Picture가 있습니다.

| 단어    | 의미                  | 사용 맥락              |
| ------- | --------------------- | ---------------------- |
| Photo   | 카메라로 찍은 이미지  | 구체적, 기술적         |
| Picture | 사진, 그림, 시각 표현 | 일상적, 포괄적         |
| Image   | 시각적 재현 (추상적)  | 형식적, 기술적, 디지털 |

IT 기술에서는 시스템, 파일, 환경의 상태를 하나의 단일 단위로 묶은 복제본을
리눅스 컨테이너 이미지, 디스크 이미지, 머신 이미지 등으로 부릅니다.
또 다른 '복제'라는 단어로 clone이 있습니다.
clone은 즉시 A에서 B 위치로 복제하는 것을 말한다면, image는 원본을 복제해서 어디서나 복원할 준비가 된 상태를 말합니다.

스냅샷(Snapshot)은 순간적인 장면을 촬영한 사진을 말합니다.
인물 사진에서는 자연스러운 동작이나 표정을 재빠르게 포착한 사진을 의미합니다.
IT 기술에서는 특정 시점의 상태를 저장한 것을 말합니다.

# 이미지 파이프라인 (Image Pipeline)

이미지 소스(카메라, 스캐너, 컴퓨터 게임의 렌더링 엔진)와
이미지 렌더러(모니터, 프린터, 시네마 스크린) 사이의 모든 과정을
[이미지 파이프라인](https://en.wikipedia.org/wiki/Color_image_pipeline)이라고 합니다.

![이미지 파이프라인](/images/multimedia/image-in-web/image-pipeline-v2.png)

## 카메라: 필름 vs 디지털 센서

이미지는 사진이나 컴퓨터 그래픽으로부터 시작됩니다.
그 중 **사진**은 촬영 장비의 특성에 따라 이미지 품질과 후처리 방식이 달라집니다.
**필름 카메라**는 물리적 필름에 빛을 감광시켜 현상(現像, Photographic Development) 과정을 거칩니다.
이후 인터넷에 업로드하기 위해서는 이미지 스캐너(Image Scanner)를 통해 디지털화해야 합니다.
**디지털 카메라**는 이미지 센서([CCD](https://semiconductor.samsung.com/kr/support/tools-resources/dictionary/semiconductor-glossary-ccd-image-sensor/),
[CMOS](https://semiconductor.samsung.com/kr/support/tools-resources/dictionary/semiconductor-glossary-cmos-image-sensor-cis/))가
빛을 받아 RAW 데이터([RGB](https://en.wikipedia.org/wiki/RGB_color_model))로 저장합니다.
이 RAW 데이터는 노출, 색온도, 선명도 등의 조정 여지가 많아 전문 편집에서 자주 사용되죠.

![이미지 센서](/images/multimedia/image-in-web/image-processing.avif)

*[이미지 출처: 삼성전자](https://semiconductor.samsung.com/kr/support/tools-resources/dictionary/semiconductor-glossary-image-sensor/)*

## ISP: 이미지 신호 처리

디지털 촬영 후에는 일반적으로 카메라에 내장된
[이미지 신호 처리장치(ISP, Image Signal Processor)](https://en.wikipedia.org/wiki/Image_processor)가 이미지를 압축-보정해 저장합니다.[^1]
(RAW → JPEG, PNG 등)
여기서 압축(손실/무손실), 보정(화이트 밸런스, 노출 보정, 색상 보정 등), 인코딩(포맷 변환) 등의 과정을 거칩니다.

# 이미지 포맷

다양한 이미지 포맷이 존재하며, 각 포맷은 고유한 특징과 장단점을 가지고 있습니다.
상황에 맞는 최적의 포맷을 선택하는 것이 이미지 최적화의 첫걸음입니다.

## 래스터 이미지

래스터(raster) 이미지는 픽셀로 구성된 정적 비트맵 이미지입니다.

### JPG: 손실 압축 이미지 포맷

JPEG(Joint Photographic Experts Group)는 사진 이미지를 효율적으로 저장하기 위해 설계된 손실 압축 포맷입니다.
줄여서 JPG라고도 부릅니다.
[이산 코사인 변환(DCT)](https://en.wikipedia.org/wiki/Discrete_cosine_transform)
기반의 손실 압축을 사용하여 인간 시각에 덜 중요하게 여겨지는 정보는 버리고 용량을 줄입니다.
압축률(퀄리티)을 조절 가능하여 고품질부터 고압축 저품질까지 선택할 수 있으며,
일반적으로 동일 화질 대비 PNG보다 파일 크기가 훨씬 작게 저장됩니다.
다만 압축률이 높을수록 블록 노이즈 등의 압축 아티팩트(손실로 인한 왜곡)가 생길 수 있습니다.

JPEG 포맷은 [알파 채널](https://en.wikipedia.org/wiki/Alpha_compositing)을 지원하지 않으므로
투명도(Transparency)를 표현할 수 없습니다.
또한 프레임 기반 애니메이션(멀티프레임)은 지원하지 않는 정적 이미지 포맷입니다.

### GIF: 팔레트 기반 애니메이션 포맷

GIF(Graphics Interchange Format)는 1987년 도입된 초기 웹 그래픽 포맷으로,
256색 팔레트(8비트) 기반의 래스터 이미지를 무손실 압축(LZW)으로 저장합니다.

### PNG: 무손실 압축 이미지 포맷

PNG(Portable Network Graphics)는 무손실 압축을 지원하는 래스터 이미지 포맷입니다.
PKZIP(`.zip`)처럼 Deflate 알고리즘(LZ77+허프만 코딩)으로 압축하여 품질 저하 없이 용량을 줄입니다.
트루 컬러(24비트)와 인덱스 컬러(8비트) 모드를 지원하며, 투명도를 표현할 수 있습니다.
특허가 있는 LZW 압축 알고리즘을 사용한느 GIF를 대체하기 위해 개발되었다고 합니다.

### WebP

WebP는 구글에서 2010년경 발표한 현대적인 이미지 포맷으로,
손실 압축과 무손실 압축을 모두 지원하며 투명도와 애니메이션까지 가능한 만능 포맷입니다.
WebP는 내부적으로 비디오 코덱인 **VP8**를 기반으로 한 프레임 압축을 사용합니다.

WebP의 손실 압축 효율은 매우 뛰어나서,
동일 화질 기준 JPEG 대비 25~35% 정도 파일 크기가 작다고 알려져 있습니다.
무손실 WebP 역시 PNG보다 약 26% 더 작게 저장되는 것으로 보고되었습니다.
또한 8비트 알파 채널을 지원하여 PNG처럼 투명 배경 이미지를 저장할 수 있고,
애니메이션 WebP는 GIF나 APNG보다 뛰어난 압축 효율로 다중 프레임을 저장합니다.

하지만 WebP가 모든 이미지에 압축률이 높은 것은 아닙니다.[^2]
또한 프로그레시브 렌더링(progressive JPEG처럼 저화질로 먼저 보여주고 점차 선명해지는 기능)을 지원하지 않습니다[^3].

### AVIF: AV1 기반 이미지 포맷

Alliance for Open Media에서 개발한 이미지 파일 포맷으로 1.0.0 버전은 2019년에 출시했습니다.
AVIF(AV1 Image File Format)는 **AV1** 비디오 코덱을 통해 인코딩된 I-프레임을 그대로 이미지로 사용할 수 있도록
AOMedia에서 별도의 이미지 컨테이너로 개발한 것입니다.
WebP의 뒤를 잇는 차세대 웹 이미지 포맷으로 각광받고 있지만
현재는 브라우저 지원이 부족하여 사용에 주의가 필요합니다.

## 벡터 이미지

픽셀 대신 벡터(vector) 형태로 그래픽을 표현하는 이미지 포맷입니다.

### SVG

SVG(Scalable Vector Graphics)는
XML 코드로 정의된 벡터 기반 이미지 포맷입니다.
해상도에 관계없이 깨끗하게 표현되며,
CSS와 JavaScript로 스타일링 및 애니메이션을 적용할 수 있습니다.
텍스트 기반이므로 파일 크기가 작고,
복잡한 그래픽을 표현할 수 있습니다.
웹에서 로고, 아이콘, 단순한 그래픽을 표현하는 데 적합합니다.

![SVG와 PNG 비교](/images/multimedia/image-in-web/svg-vs-png.png)

*[이미지 출처: Stack Overflow](https://stackoverflow.com/questions/2336522/what-are-the-different-usecases-of-png-vs-gif-vs-jpeg-vs-svg)*

결론적으로, **사진**에는 JPEG 또는 WebP/AVIF,
**로고나 아이콘**에는 SVG 또는 PNG,
**애니메이션**에는 GIF 또는 WebP를 사용하는 것이 일반적인 권장 사항입니다.
상황에 따라 최적의 포맷을 선택하는 것이 중요합니다.

# 웹 페이지에서 이미지 최적화

웹 페이지에 400x300 픽셀 크기로 표시될 이미지를 4000x3000 픽셀 원본 그대로 사용하는 것은 심각한 낭비입니다.
이는 불필요하게 큰 파일을 다운로드하게 만듭니다.
이미지가 표시될 최대 크기를 고려하여 이미지 자체의 해상도를 미리 조절(리사이징)하여 제공해야 합니다.
`WebP`, `AVIF`와 같은 평균 이미지 압축률이 높은 포맷을 사용합니다[^4].

## 반응형 이미지 (Responsive Images)

데스크톱, 태블릿, 모바일 등 다양한 디바이스 환경에 맞춰 최적화된 크기 또는 해상도의 이미지를 제공하는 기술입니다.
`<img>` 태그의 [srcset](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/img#srcset),
[sizes](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/img#sizes)
속성을 사용해서 브라우저가 현재 뷰포트 크기와
디바이스 해상도에 가장 적합한 이미지를 선택하도록 여러 이미지 후보를 제공합니다.

```html
<img
  srcset="image-small.jpg 480w,
          image-medium.jpg 800w,
          image-large.jpg 1200w"
  sizes="(max-width: 600px) 100vw,
        (max-width: 900px) 90vw,
        50vw"
  src="image-large.jpg"
  alt="이미지에 대한 설명">
```

**`<picture>` 요소**는 특정 조건(화면 크기, 지원 포맷)에 따라
다른 이미지를 명시적으로 보여주고 싶을 때 사용합니다.
WebP/AVIF 같은 최신 포맷을 지원하지 않는 브라우저를 위한 대체(fallback) 이미지를 제공하는 데 유용합니다.

```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="대체 이미지">
</picture>
```

## 지연 로딩 (Lazy Loading)

**지연 로딩**은 사용자가 스크롤하여 이미지가 화면에 실제로 보여지기 직전까지 이미지 로딩을 지연시키는 기술입니다.
페이지 초기 로딩 시 불필요한 이미지 다운로드를 막아 초기 로딩 속도(LCP 등)를 크게 개선하고 데이터 사용량을 절약합니다.
HTML `<img>` 태그에 `loading="lazy"` 속성을 추가하는 것만으로 간단하게 구현할 수 있습니다.

```html
<img src="image.jpg" loading="lazy">
```

## 이미지 스프라이트 (Image Sprite)

**이미지 스프라이트**를 사용해서 여러 이미지를 하나의 이미지로 합치면
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

# 웹 접근성: alt 속성

이미지를 최적화하는 것만큼이나 웹 개발자에게 중요한 과제가 바로 **웹 접근성(accessibility)**입니다.
특히 `<img>` 태그의 `alt` 속성, 즉 **대체 텍스트(Alternative Text)**는 단순한 보조 정보가 아니라,
모든 사용자가 웹페이지의 정보를 동등하게 이해할 수 있도록 돕는 **핵심적인 수단**입니다.

## 왜 `alt` 속성이 중요한가

첫째, 시각 장애가 있는 사용자들은 웹페이지를 스크린 리더(screen reader)를 통해 탐색합니다.
이때 스크린 리더는 이미지의 시각적 내용을 읽어줄 수 없기 때문에,
`alt` 속성에 작성된 대체 텍스트를 대신 읽어줍니다.
즉, 이 텍스트는 이미지의 의미를 음성으로 전달해주는 유일한 수단이 됩니다.

둘째, 이미지가 네트워크 오류나 기타 문제로 인해 제대로 로딩되지 않을 때,
`alt` 텍스트는 이미지 대신 화면에 표시되어 사용자가 어떤 이미지가 있어야 했는지를 유추할 수 있게 해줍니다.
이는 콘텐츠의 연속성과 이해를 돕는 데 중요한 역할을 합니다.

셋째, 검색 엔진 최적화(SEO) 측면에서도 `alt` 속성은 유용합니다.
검색 엔진은 이미지 자체의 시각적 내용을 이해하지 못하므로,
`alt` 텍스트를 통해 해당 이미지가 무엇을 의미하는지 파악합니다.
이는 이미지 검색 결과에 노출될 가능성을 높이고,
페이지 전체의 검색 순위에도 긍정적인 영향을 줄 수 있습니다.

## 좋은 `alt` 텍스트를 작성하는 방법

`alt` 텍스트는 단순히 "있는 것보다 낫다" 수준에서 끝나는 것이 아니라,
**명확하고, 간결하고, 의미 있는** 내용으로 작성되어야 합니다.

- **이미지의 내용과 맥락을 정확하게 설명**해야 합니다. 예를 들어 제품 이미지라면, 단순히 "스마트폰"이 아니라 "파란색 케이스를 씌운 스마트폰 정면"처럼 구체적인 묘사가 필요합니다.
- "사진", "그림"과 같은 표현은 **굳이 포함하지 않아도 됩니다**. 스크린 리더는 해당 요소가 이미지라는 것을 이미 인식하고 있으므로, 중복된 설명은 피하는 것이 좋습니다.
- 이미지가 **링크 역할을 할 경우**, 단순한 설명보다는 **링크의 목적지나 기능**을 설명해야 합니다. (ex: "장바구니 페이지로 이동")
- 반대로, 이미지가 **순수하게 장식용**이라면, `alt` 속성을 빈 값(`alt=""`)으로 설정해야 스크린 리더가 그것을 무시할 수 있습니다. 시각적으로만 의미 있는 요소까지 읽게 되면, 오히려 사용자에게 혼란을 줄 수 있기 때문입니다.

# 결론

웹 개발에서 이미지는 필수적이지만, 그만큼 성능 저하의 주범이 되기도 쉽습니다. 오늘 살펴본 것처럼,
상황에 맞는 **최적의 이미지 포맷**을 선택하고,
압축, 리사이징, 반응형 기법, 지연 로딩 등 **다양한 최적화 방법**을 적극적으로 활용하며,
`alt` 텍스트를 통해 **웹 접근성**을 확보하는 습관을 들인다면,
여러분의 웹사이트는 사용자에게 훨씬 더 쾌적한 경험을 제공하고,
검색 엔진에서도 좋은 평가를 받을 수 있을 것입니다.

# 더 읽을 거리

- [웹 페이지 성능 측정과 최적화](/posts/web/web-page-performance-optimization/)
- [Digital Image Processing](https://en.wikipedia.org/wiki/Digital_image_processing) | Wikipedia
- How Digital Photography Works-Que | Ron White, Timothy Edward Downs (2007)
- [Image performance](https://web.dev/learn/performance/image-performance) | web.dev

[^1]: [디지털 신호 처리장치(DSP, Digital Signal Processor)](https://en.wikipedia.org/wiki/Digital_signal_processor)의 일종.
[^2]: [WebP 기술의 장단점 분석 (2021)](https://news.hada.io/topic?id=12375) — [원본: WebP is so great… except it's not](https://eng.aurelienpierre.com/2021/10/webp-is-so-great-except-its-not/)
[^3]: [WebP FAQ](https://developers.google.com/speed/webp/faq) | Google
[^4]: [Serve images in modern formats](https://developer.chrome.com/docs/lighthouse/performance/uses-webp-images) | web.dev
