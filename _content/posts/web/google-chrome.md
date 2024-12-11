---
draft: false
socialshare: true
date: 2024-07-29T00:51:00+09:00
lastmod: 2024-09-15T23:25:00+09:00
title: "유용한 구글 크롬(Google Chrome)의 기능"
description: "개발 편의성을 높일 수 있는 기능을 소개합니다."
featured_image: "/images/web/google-chrome/google-chrome-1200x630wa.png"
images: ["/images/web/google-chrome/google-chrome-1200x630wa.png"]
tags:
  - web
  - browser
Categories:
  - wiki
---

- [Chrome URLs](#chrome-urls)
- [북마클릿 Bookmarklet](#북마클릿-bookmarklet)
  - [유용한 북마클릿](#유용한-북마클릿)
  - [자바스크립트 스니펫](#자바스크립트-스니펫)
- [개발자 도구 DevTools](#개발자-도구-devtools)
  - [Performance 패널](#performance-패널)
  - [Network 패널](#network-패널)
    - [Network Log](#network-log)
    - [Network Conditions](#network-conditions)
    - [HTML 문서 생명주기](#html-문서-생명주기)
    - [Network 패널에서 HAR 가져오기](#network-패널에서-har-가져오기)
  - [Sources 패널](#sources-패널)
    - [로컬 재정의 (Local Overrides)](#로컬-재정의-local-overrides)
    - [Override 파일을 저장할 폴더 지정](#override-파일을-저장할-폴더-지정)
  - [Console](#console)
- [참조](#참조)

# Chrome URLs

크롬 URL은 Google Chrome 브라우저에서 설정 페이지나 특정 기능으로 빠르게 접근할 수 있게 해주는 내부 주소다.

- `chrome://about/`
  - 크롬 URL 목록
- `chrome://net-internals/#hsts`
  - HSTS 조회 및 비활성화
- `chrome://inspect#devices`
  - USB로 **모바일 디바이스**를 연결해서 개발자 도구(DevTools)로 모바일 크롬 앱을 확인할 수 있다.

# 북마클릿 Bookmarklet

북마클릿(Bookmarklet)이라는 단어는 북마크(Bookmark)와 애플릿(Applet)의 합성어다.
이 단어는 다음과 같은 이유로 만들어졌다.

1. 북마크(Bookmark)
   - 웹 브라우저에서 특정 웹 페이지를 빠르게 접근할 수 있도록 저장하는 기능이다.
    북마크는 사용자가 자주 방문하는 페이지를 저장해 두고 클릭만으로 쉽게 이동할 수 있게 한다.
2. 애플릿(Applet)
   - 플러그인의 일종으로, 웹 브라우저나 제어판 등의 프로그램에서 실행되는 작은 응용 프로그램이다.
     전용 위젯 엔진이나 더 큰 프로그램 범위 내에서 특정한 작업을 수행하며, 독립적으로 사용되지 않는다.

북마클릿은 자바스크립트 코드를 포함하고 있는 북마크로,
사용자가 클릭하면 해당 코드가 실행되어 특정 작업을 수행한다.
이 용어는 북마크의 편리함과 애플릿의 실행 기능을 결합한 형태를 잘 나타낸다.

북마클릿은 1990년대 후반에 등장했으며,
특히 브라우저에서 반복적인 작업을 자동화하거나 웹 페이지를 개인화하기 위한 도구로 널리 사용되었다.
그 후로 웹 개발자들과 사용자들 사이에서 인기를 끌게 되었다.

## 유용한 북마클릿

```js
// 1000ms(1초) 후에 모든 이미지에 빨간 테두리 추가
javascript: (async () => {
  async function sleep() {
    return new Promise((r) => setTimeout(r, 1_000));
  }
  await sleep().then(() => {
    const images = document.querySelectorAll("img");
    images.forEach((img) => {
      img.style.border = "2px solid red";
    });
  });
})();
```

```js
// 현재 탭 복제
javascript:void(window.open(location));
```

```js
// wayback - wayback machine에 현재 페이지 저장
javascript:void(window.open("https://web.archive.org/save/"+document.location.href));
```

```js
// Decoded URL - 현재 페이지의 디코딩된 URL를 복사한다.
javascript:console.log(prompt('copy (Control+C) this link:', decodeURIComponent(window.location)));
```

```js
// Webpage Stats - 페이지 통계
javascript:(function(){var el=document.createElement('script');el.type='text/javascript';el.src='https://micmro.github.io/performance-bookmarklet/dist/performanceBookmarklet.min.js';el.onerror=function(){alert("Looks like the Content Security Policy directive is blocking the use of bookmarklets\n\nYou can copy and paste the content of:\n\n\"https://micmro.github.io/performance-bookmarklet/dist/performanceBookmarklet.min.js\"\n\ninto your console instead\n\n(link is in console already)");console.log("https://micmro.github.io/performance-bookmarklet/dist/performanceBookmarklet.min.js");};document.getElementsByTagName('body')[0].appendChild(el);})();
```

```js
// PageSpeed Insights - 현재 페이지 분석
javascript:void(open('https://pagespeed.web.dev/analysis?url=' + encodeURIComponent(location.href)));
```

```js
// EyeDropper - 색상의 HEX 코드를 찾을 수 있는 Eye Dropper를 실행
javascript:void(async()=>{try{prompt('Selected HEX color:',(await new EyeDropper().open()).sRGBHex);}catch(e){alert(e);}})();
```

```js
// 3D Webpage - 현재 페이지를 3D로 보여준다.
javascript:(function(){var js=document.body.appendChild(document.createElement("script"));js.onerror=function(){alert("Error! The Script Could Not Be Loaded!")};js.src="https://rawgit.com/Krazete/bookmarklets/master/tri.js"})();
```

## 자바스크립트 스니펫

- [자바스크립트 스니펫 실행](https://goo.gle/devtools-snippets) | Run snippets of JavaScript
  - 공식 문서에서도 북마클릿의 대체재라고 언급하지만,
    '딸깍' 클릭만 하면 되는 북마클릿이 더 편하다...

![Run snippets of JavaScript](/images/web/google-chrome/the-devtools-documentatio-b98254f550319_856.png)

# 개발자 도구 DevTools

## Performance 패널

브라우저에서 페이지 성능을 체크할 수 있다.
아래 스크린샷처럼 Core Web Vitals(CWV)도 함께 확인할 수 있다.

![Performance Panel](/images/web/google-chrome/performance-panel.webp)

## Network 패널

아마 가장 많이 사용하는 패널이 아닌가 싶다.

### Network Log

![Network Log](https://developer.chrome.com/static/docs/devtools/network/image/the-network-log-f17acc2e02c0a_856.png)

*[Inspect network activity](https://developer.chrome.com/docs/devtools/network)*

- Preserve log
  - 새로고침을 하더라도 이전 로그를 유지한다.
- [요청 필터링](https://developer.chrome.com/docs/devtools/network/reference?#filter)
  - 앞에 `-`를 붙이면 해당 조건에 해당하는 요청을 제외한다.
  - `domain:*.example.com` | example.com 도메인만 필터링
  - `method:POST` | POST 메소드만 필터링
  - `status-code:200` | 200 상태 코드만 필터링
  - `larger-than:400k` | 400KB 이상의 리소스만 필터링
  - `mime-type:image/webp` | webp 이미지만 필터링
  - `has-response-header:content-encoding` | content-encoding 헤더가 있는 것만 필터링
  - `is:running` | 실행 중인 요청만 필터링
  - `scheme:https` | HTTPS 프로토콜만 필터링
  - `is:from-cache` | 캐시에서 가져온 요청만 필터링
  - `cookie-name:django_language` | django_language 쿠키가 있는 요청만 필터링

### Network Conditions

- Disable cache
  - 캐시를 비활성화하고 새로고침을 하면 캐시를 사용하지 않는다.
- User agent
  - 요청 User-Agent 헤더를 커스텀 할 수 있다.
- Network throttling
  - 네트워크 속도를 조절할 수 있다.
  - `Slow 4G`, `Fast 4G`, `3G`, `Offline` 등.

![More network conditions](/images/web/google-chrome/more-network-conditions.png)

![network conditions](/images/web/google-chrome/network-conditions.png)

### HTML 문서 생명주기

네트워크 성능을 체크할 때
[HTML 문서 생명주기](https://ko.javascript.info/onload-ondomcontentloaded)를 알아두면 도움이 된다.

- [Document](https://developer.mozilla.org/en-US/docs/Web/API/Document/readyState)
  - `document.readyState:loading` - `document` 객체가 생성되고 아직 로드되지 않은 상태.
  - `document.readyState:interactive` - DOM 트리가 완성된 상태. 해당 상태로 변경된 직후 `DOMContentLoaded` 이벤트가 발생한다. DOM 요소에 접근 가능하다.
    - [document/DOMContentLoaded](https://developer.mozilla.org/en-US/docs/Web/API/Document/DOMContentLoaded_event) - 브라우저가 HTML을 전부 읽고 DOM 트리를 완성하는 즉시 발생한다.
  - `document.readyState:complete` - HTML 문서와 모든 리소스(img, js, css)가 로드된 상태. 해당 상태로 변경된 직후 `window/load` 이벤트가 발생한다.
- [Page Lifecycle API](https://developer.chrome.com/docs/web-platform/page-lifecycle-api)
  - [window/load](https://developer.mozilla.org/en-US/docs/Web/API/Window/load_event)
  - [window/beforeunload](https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event)
    - 알러트 창을 띄운다. ("You have unsaved changes that will be lost.")
  - [window/pagehide](https://developer.mozilla.org/en-US/docs/Web/API/Window/pagehide_event)
  - ~~[window/unload](https://developer.mozilla.org/en-US/docs/Web/API/Window/unload_event)~~ - deprecated

### Network 패널에서 HAR 가져오기

- [자세한 내용](https://developer.chrome.com/docs/devtools/network/reference?hl=ko#export)
- [Chrome 62](https://developer.chrome.com/blog/new-in-devtools-62?hl=ko#har-imports) | HAR imports in the Network panel
- HAR 파일을 가져와서 Network 패널에 로드하면 동일한 요청-응답 정보를 다시 볼 수 있다.
  - 그럼 주고 받은 요청-응답 정보를 다른 사람과 공유하거나, 본인도 나중에 다시 확인 수 있다.

![Save all network requests to a HAR file](/images/web/google-chrome/selecting-save-as-har-c-543367c2a7051_856.png)

## Sources 패널

### 로컬 재정의 (Local Overrides)

- [Chrome 65](https://developer.chrome.com/blog/new-in-devtools-65?hl=ko#overrides)
- [더 자세한 내용](https://developer.chrome.com/docs/devtools/overrides?hl=ko)
- 개발자 도구 Source 패널에서 정적 파일을 수정 후 해당 페이지를 새로고침하면 모두 리로드된다.
- Local Override는 Source 패널에서 수정 후 저장하면, 이후 해당 페이지를 새로고침해도 수정한 내용이 유지된다.

![Local Overrides](/images/web/google-chrome/persisting-css-change-ac-3da090318c534.gif)

### Override 파일을 저장할 폴더 지정

- [Chrome 66](https://developer.chrome.com/blog/new-in-devtools-66?hl=ko#overrides)
- 위 로컬 재정의 기능에서 파일 수정 후 저장하면 해당 경로로 파일이 저장된다.
- 이후 해당 페이지는 항상 Override된 파일을 참조하기 때문에 디버깅 후 해당 파일을 삭제하는 것이 좋다.

![Local Overrides now works with some styles defined in HTML](/images/web/google-chrome/an-example-styles-define-a24be5796e36a_856.png)

## Console

- [Chrome 126](https://developer.chrome.com/blog/new-in-devtools-126#self-xss-flag)
- Console에 자바스크립트 코드를 붙여넣으면 발생하는 [self-XSS 경고](https://developer.chrome.com/blog/self-xss)

```js
Warning:
Don’t paste code into the DevTools Console that you don’t understand or haven’t reviewed yourself.
This could allow attackers to steal your identity or take control of your computer.
Please type ‘allow pasting’ below and hit Enter to allow pasting.
```

웹 브라우저에 따라 입력하는 것이 다르다.

```js
// Google Chrome
allow pasting
```

```js
// Microsoft Edge
console.profile()
```

# 참조

- [DevTools의 새로운 기능](https://developer.chrome.com/docs/devtools/news?hl=ko) | What's New in DevTools
