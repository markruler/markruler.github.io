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
- [image라는 단어](#image라는-단어)
  - [IT 기술에서의 이미지](#it-기술에서의-이미지)
- [화질(Quality)을 결정하는 요소](#화질quality을-결정하는-요소)
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
  - [사전 로딩 (Preload)](#사전-로딩-preload)
  - [이미지 스프라이트 (Image Sprite)](#이미지-스프라이트-image-sprite)
  - [브라우저 캐싱](#브라우저-캐싱)
  - [압축 알고리즘 최적화](#압축-알고리즘-최적화)
  - [단순 장식용 이미지는 CSS로](#단순-장식용-이미지는-css로)
- [웹 접근성: alt 속성](#웹-접근성-alt-속성)
  - [왜 `alt` 속성이 중요한가](#왜-alt-속성이-중요한가)
  - [좋은 `alt` 텍스트를 작성하는 방법](#좋은-alt-텍스트를-작성하는-방법)
- [이미지 보안](#이미지-보안)
- [결론](#결론)
- [더 읽을 거리](#더-읽을-거리)

# 개요

이미지는 인터넷에서 매우 큰 비중을 차지합니다.
d 웹페이지 기준으로 이미지가 차지하는 데이터 용량은 전체의 51%에 달하므로[^1],
이미지의 속도나 크기를 개선하면 웹 성능에 상당한 영향을 미칩니다.

이 글에서는 웹 개발자가 반드시 알아야 할 이미지 관련 지식을 총정리합니다.
올바른 이미지 포맷 선택부터 다양한 최적화 기법, 접근성 고려 사항, 그리고 성능 및 SEO에 미치는 영향까지 다룹니다.

# image라는 단어

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

## IT 기술에서의 이미지

IT 기술에서는 시스템, 파일, 환경의 상태를 하나의 단일 단위로 묶은 복제본을
리눅스 컨테이너 이미지, 디스크 이미지, 머신 이미지 등으로 부릅니다.
또 다른 '복제'라는 단어로 clone이 있습니다.
clone은 즉시 A에서 B 위치로 복제하는 것을 말한다면, image는 원본을 복제해서 어디서나 복원할 준비가 된 상태를 말합니다.

**스냅샷**(**Snapshot**)은 순간적인 장면을 촬영한 사진을 말합니다.
인물 사진에서는 자연스러운 동작이나 표정을 재빠르게 포착한 사진을 의미합니다.
IT 기술에서는 특정 시점의 상태를 저장한 것을 말합니다.

# 화질(Quality)을 결정하는 요소

일반적으로 **해상도**(**Resolution**)는 디지털 이미지의 픽셀 단위 크기를 의미합니다.
이는 가로와 세로 방향의 픽셀 수 (ex: 1920×1080처럼 픽셀 수로 표기)로 표현되어
이미지에 얼마나 **정보**가 담겨 있는지 나타냅니다.
해상도가 높을수록 더 많은 픽셀로 구성되어 있어 이미지의 디테일이 풍부해지고 선명해집니다.
인쇄나 스캔 맥락에서의 해상도는 단위 길이당 **픽셀(점) 밀도**로 정의되며
주로 PPI(Pixels Per Inch) 또는 DPI(Dots Per Inch)로 측정합니다.

사진에 사용되는 색상 모델(color model)은 빛의 삼원색을 기반으로 한 [RGB 모델](https://en.wikipedia.org/wiki/RGB_color_model)이 사용됩니다.
반면 물체의 색은 빛의 반사에 의해 결정되므로, 물체의 색을 표현하기 위해서는 빛의 삼원색의 2차색을 색의 삼원색(CMY)으로 사용합니다.
색의 삼원색은 혼합할수록 어두워지지만 완전한 검정은 만들기 어려워서 검정(Black)색을 추가하여
[CMYK 모델](https://en.wikipedia.org/wiki/CMYK_color_model)이 주로 사용됩니다.

다시 말하면 RGB 모델은 빛의 삼원색을 조합하여 색을 표현하는 **가산혼합 방식**을 사용합니다.
반면 CMYK 모델은 흰 빛에서 RGB 색을 빼는 **감산혼합 방식**을 사용합니다.
흰 배경(종이) 위에 잉크를 덧칠하여 빛을 흡수시키는 방식으로 색이 만들어집니다.
예를 들어, 파란 빛을 빼면 노란색이 남고, 빨간 빛을 빼면 청록색이 남습니다.

디지털 디스플레이나 조명은 RGB 모델을 사용하고, 인쇄물이나 물감은 물체의 색을 표현하기 위해 CMYK 모델을 사용합니다.
그래서 인쇄물의 디지털 작업 시 RGB에서 CMYK로 변환하는 과정이 필요할 뿐만 아니라
RGB 모니터에서 보는 색과 인쇄물에서 보이는 색이 다를 수 있습니다.
이를 보정하기 위해 sRGB와 같은 표준 색 공간과 컬러 매니지먼트가 사용됩니다.

비트 깊이(bit depth) 또는 **색 깊이(color depth)**는 각 픽셀 색상을 표현하기 위해 사용되는 비트 수를 의미합니다.
다시 말해, 하나의 픽셀 당 표현 가능한 색상의 가짓수를 결정하는 지표입니다.
디지털 이미지에서 흔히 쓰이는 24비트 색상은 픽셀 당 24비트로 색을 표현한다는 뜻으로,
보통 RGB 각 채널 8비트씩 (8비트+8비트+8비트) 구성되어 있습니다.
이렇게 하면 총 2^24가지 색상 — 약 16,777,216가지의 색을 표현할 수 있어 흔히 트루 컬러(True Color)라고 부릅니다.
표준 컬러 이미지 포맷(JPEG, PNG 등)과 대부분의 웹 이미지가 이 모드를 사용합니다.

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
빛을 받아 RAW 데이터[^2](RGB)로 저장합니다.
이 RAW 데이터는 노출, 색온도, 선명도 등의 조정 여지가 많아 전문 편집에서 자주 사용되죠.

![이미지 센서](/images/multimedia/image-in-web/image-processing.avif)

*[이미지 출처: 삼성전자](https://semiconductor.samsung.com/kr/support/tools-resources/dictionary/semiconductor-glossary-image-sensor/)*

## ISP: 이미지 신호 처리

디지털 촬영 후에는 일반적으로 카메라에 내장된
[이미지 신호 처리장치(ISP, Image Signal Processor)](https://en.wikipedia.org/wiki/Image_processor)가 이미지를 압축-보정해 저장합니다.[^3]
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

하지만 WebP가 모든 이미지에 압축률이 높은 것은 아닙니다.[^4]
또한 프로그레시브 렌더링(progressive JPEG처럼 저화질로 먼저 보여주고 점차 선명해지는 기능)을 지원하지 않습니다[^5].

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
일부 CDN 서비스에서는 최초 요청 시 리사이징하거나 워터마크를 추가하는 기능을 지원하기도 합니다.
`WebP`, `AVIF`와 같은 평균 이미지 압축률이 높은 포맷을 사용합니다[^6].

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

`decoding="async"` 속성을 추가하면 브라우저가 이미지를 비동기적으로 디코딩하여
메인 스레드 블로킹을 줄일 수 있습니다.

```html
<img src="image.jpg" decoding="async">
```

## 사전 로딩 (Preload)

초기 화면에 꼭 보여야 하는 중요한 이미지는 최우선으로 가져오도록(**preloading**) 브라우저에 힌트 줄 수 있습니다.

```html
<head>
  <link rel="preload" as="image">
</head>
```

이때 `fetchpriority="high"`와 함께 쓰면 더욱 확실하게 우선순위를 높일 수 있습니다.
다만 남용하면 다른 리소스가 늦어질 수 있으니 핵심 이미지에만 사용합니다.

## 이미지 스프라이트 (Image Sprite)

다수의 작은 이미지가 있을 경우 **HTTP/2의 멀티플렉싱**으로 한 연결에서 병렬 전송하거나,
**HTTP/3의 개선된 전송**으로 지연을 줄일 수 있습니다.
하지만 경우에 따라 최초 요청 시 Disk cache를 확보하기 위해 대기 시간(Wait Time)이 발생할 수 있습니다.

이미지 스프라이트나 inlining (작은 아이콘 데이터 URI를 인라인) 기법도 상황에 따라 고려합니다.
**이미지 스프라이트**를 사용해서 여러 이미지를 하나의 이미지로 합치면
한 번의 요청으로 여러 이미지를 불러올 수 있습니다.
크롬 브라우저는 다음 [3가지 이유로 대기](https://github.com/GoogleChrome/developer.chrome.com/blob/e262dd234c039ab14e4ad7c3451153d7636ac12d/site/en/docs/devtools/network/reference/index.md?plain=1#L541-L546)할 수 있습니다.

- There are higher priority requests.
- There are already six TCP connections open for this origin, which is the limit. Applies to HTTP/1.0 and HTTP/1.1 only.
- The browser is briefly allocating space in the disk cache.

`Queueing`은 **Connection Start 전** 위 3가지 이유로 대기하는 상태입니다.
Disable cache 옵션을 활성화하고 Hard Reload(혹은 처음 접속해서 캐시가 없는 경우) 시
요청 리소스가 많을 경우 Queueing이 길게 유지되는 것을 확인할 수 있습니다.
`Stalled`는 **Connection Start 후** 위 3가지 이유로 대기하는 상태입니다.
이를 줄이기 위해 적절한 사이즈의 Sprite 이미지를 사용할 수 있습니다.

## 브라우저 캐싱

`Cache-Control` 헤더를 설정하여 한 번 받은 이미지를 사용자가 재방문 시 재활용하도록 합니다.
변경이 드문 자원은 `max-age`를 길게 주고, 파일명에 버전 해시를 붙여 캐시 갱신을 관리하는 패턴이 일반적입니다.

## 압축 알고리즘 최적화

JPEG의 프로그레시브(progressive) 옵션을 켜서
초기 러프한 버전을 빨리 보여주고 점진적으로 화질을 올리게 하거나,
PNG의 팔레트 최적화, GIF의 디더링 수준 조정 등 세부 설정으로 용량을 조금이라도 더 줄일 수 있습니다.

## 단순 장식용 이미지는 CSS로

단순 장식용 이미지는 `<img>` 대신 CSS `background-image`로 넣어 콘텐츠 이미지와 구분합니다.
이렇게 하면 필요 시 해당 영역을 아예 로드 안 하도록 (ex: 모바일에서 숨김) 처리하기도 쉽습니다.
또한 `<picture>` 요소를 사용하면 CSS `background-image`의 미디어쿼리 대응처럼
`<source media>`로 다양한 상황별 이미지를 지정할 수도 있습니다.

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

# 이미지 보안

[XSS(Cross-Site Scripting)](https://www.invicti.com/web-vulnerability-scanner/vulnerabilities/cross-site-scripting-via-file-upload/)는
악성 스크립트를 삽입해 사용자 브라우저에서 실행시키는 공격입니다.
일반적으로는 텍스트 입력에 `<script>` 태그 등을 넣어 발생하지만, 이미지를 통해서도 XSS가 발생할 수 있습니다.

이미지 XSS를 막으려면 입력 검증과 출력 인코딩 원칙을 지키는 것이 중요합니다.
이미지 업로드 시 서버 측에서 **파일 시그니처**(**매직 넘버**)를 검사하여 실제 이미지 포맷이 맞는지 확인해야 합니다.
업로드 폴더는 실행 권한을 끄고, 검증되지 않은 확장자는 거부해야 합니다.
이미지 사용 시 파일 이름이나 메타데이터를 HTML에 출력할 일이 있다면 반드시 **HTML 이스케이프**를 거쳐야 합니다.
이미지의 EXIF(이미지 메타데이터)에 스크립트를 심어두고, 웹앱이 그 EXIF 정보를 화면에 뿌리면 XSS가 될 수 있습니다.

이미지 URL에 너무 많은 정보를 담지 않도록 합니다.
예를 들어 `/uploads/2025/04/14/user123_profile.png`처럼 경로에 사용자 ID가 드러나면 그걸로 **정보 유출**이 될 수 있습니다.
해시나 UUID를 쓰는 것이 일반적입니다.
또한 업로드 폴더를 공개 디렉토리로 둘 경우 디렉토리 listing이 막혀있는지 확인해야 합니다.

**Content Security Policy** (**CSP**)를 설정하여, 이미지 내 스크립트 실행 등을 방지할 수 있습니다.
[img-src](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/img-src) 지시어로 허용 도메인을 제한하고,
[object-src 'none'](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/object-src) 등으로
플러그인이나 `<object>`를 통한 이미지 악용을 막습니다.
`<meta http-equiv="Content-Security-Policy: ...">`를 SVG 내부에 넣어두어 SVG 스크립트를 억제할 수도 있습니다.

프라이버시 문제도 고려해야 합니다.
사진의 EXIF 메타데이터에는 촬영 장소의 GPS 정보 등이 포함될 수 있습니다.
사용자가 모르는 사이에 위치 정보가 노출될 우려가 있으므로,
서비스에서 유저 사진을 공개 갤러리에 보여줄 때는 EXIF에서 위치 데이터를 제거하는 것이 좋습니다.

# 결론

웹 개발에서 이미지는 필수적이지만, 그만큼 성능 저하의 주범이 되기도 쉽습니다. 오늘 살펴본 것처럼,
상황에 맞는 **최적의 이미지 포맷**을 선택하고,
압축, 리사이징, 반응형 기법, 지연 로딩 등 **다양한 최적화 방법**을 적극적으로 활용하며,
`alt` 텍스트를 통해 **웹 접근성**을 확보하는 습관을 들인다면,
여러분의 웹사이트는 사용자에게 훨씬 더 쾌적한 경험을 제공하고,
검색 엔진에서도 좋은 평가를 받을 수 있을 것입니다.

# 더 읽을 거리

- [웹 페이지 성능 측정과 최적화](/posts/web/web-page-performance-optimization/)
  - [Image file type and format guide](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Image_types) | MDN
  - [Digital Image Processing](https://en.wikipedia.org/wiki/Digital_image_processing) | Wikipedia
  - [Image performance](https://web.dev/learn/performance/image-performance) | web.dev
- How Digital Photography Works-Que | Ron White, Timothy Edward Downs (2007)

[^1]: [Optimizing images on the web](https://blog.cloudflare.com/optimizing-images/)
[^2]: [RAW 이미지 포맷](https://en.wikipedia.org/wiki/Raw_image_format)이란 이미지 센서에서 처리되지 않았거나 최소한으로 처리된 이미지 데이터 | Wikipedia
[^3]: [디지털 신호 처리장치(DSP, Digital Signal Processor)](https://en.wikipedia.org/wiki/Digital_signal_processor)의 일종.
[^4]: [WebP 기술의 장단점 분석 (2021)](https://news.hada.io/topic?id=12375) — [원본: WebP is so great… except it's not](https://eng.aurelienpierre.com/2021/10/webp-is-so-great-except-its-not/)
[^5]: [WebP FAQ](https://developers.google.com/speed/webp/faq) | Google
[^6]: [Serve images in modern formats](https://developer.chrome.com/docs/lighthouse/performance/uses-webp-images) | web.dev
