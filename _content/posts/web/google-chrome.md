---
date: 2024-07-29T00:51:00+09:00
lastmod: 2024-07-29T00:51:00+09:00
title: "👾 웹 개발자가 알면 유용한 구글 크롬(Google Chrome)의 기능"
description: "개발 편의성을 높일 수 있는 기능을 소개합니다."
featured_image: "/images/web/google-chrome/dall-e-browser-with-bug.webp"
images: ["/images/web/google-chrome/dall-e-browser-with-bug.webp"]
socialshare: true
tags:
  - web
  - browser
Categories:
  - how-to
---

- [Chrome URLs](#chrome-urls)
- [북마클릿 Bookmarklet](#북마클릿-bookmarklet)
  - [자바스크립트 스니펫](#자바스크립트-스니펫)
- [개발자 도구 DevTools](#개발자-도구-devtools)
  - [Chrome 62](#chrome-62)
  - [Chrome 65](#chrome-65)
  - [Chrome 66](#chrome-66)
  - [Chrome 126](#chrome-126)
- [참조](#참조)

# Chrome URLs

크롬 URL은 Google Chrome 브라우저에서 설정 페이지나 특정 기능으로 빠르게 접근할 수 있게 해주는 내부 주소다.

- `chrome://about/`
  - 크롬 URL 목록
- `chrome://net-internals/#hsts`
  - HSTS 조회 및 비활성화
- `chrome://inspect#devices`
  - USB로 모바일 디바이스를 연결해서 개발자 도구(DevTools)로 모바일 크롬 앱을 확인할 수 있다.

# 북마클릿 Bookmarklet

`북마클릿(Bookmarklet)`이라는 단어는 `북마크(Bookmark)`와 `애플릿(Applet)`의 합성어다.
이 단어는 다음과 같은 이유로 만들어졌다:

1. **북마크(Bookmark)**:
  웹 브라우저에서 특정 웹 페이지를 빠르게 접근할 수 있도록 저장하는 기능이다.
  북마크는 사용자가 자주 방문하는 페이지를 저장해 두고 클릭만으로 쉽게 이동할 수 있게 한다.

2. **애플릿(Applet)**:
   작은 애플리케이션 프로그램을 의미하는 단어로,
   보통 웹 브라우저 내에서 실행되는 작은 자바 프로그램을 의미한다.
   그러나 "애플릿"은 여기서 작은 규모의 프로그램 또는 스크립트를 의미한다.

북마클릿은 자바스크립트 코드를 포함하고 있는 북마크로,
사용자가 클릭하면 해당 코드가 실행되어 특정 작업을 수행한다.
이 용어는 북마크의 편리함과 애플릿의 실행 기능을 결합한 형태를 잘 나타낸다.

북마클릿은 1990년대 후반에 등장했으며,
특히 브라우저에서 반복적인 작업을 자동화하거나 웹 페이지를 개인화하기 위한 도구로 널리 사용되었다.
그 후로 웹 개발자들과 사용자들 사이에서 인기를 끌게 되었다.

```js
// background를 노란색으로 변경
javascript: (function () {
  document.body.style.backgroundColor = "yellow";
})();
```

```js
// 3000ms(3초) 후에 이미지에 빨간 테두리 추가
javascript: (async () => {
  async function sleep() {
    return new Promise((r) => setTimeout(r, 3000));
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
// 탭 복제
javascript:void(window.open(location));
```

```js
// wayback machine에 현재 페이지 저장
javascript:void(window.open("https://web.archive.org/save/"+document.location.href));
```

## 자바스크립트 스니펫

- [자바스크립트 스니펫 실행](https://goo.gle/devtools-snippets) | Run snippets of JavaScript
  - 공식 문서에서도 북마클릿의 대체재라고 언급하지만,
    '딸깍' 클릭만 하면 되는 북마클릿이 더 편하다...

![Run snippets of JavaScript](https://developer.chrome.com/static/docs/devtools/javascript/snippets/image/the-devtools-documentatio-b98254f550319_856.png)

# 개발자 도구 DevTools

## Chrome 62

- [Network 패널에서 HAR 가져오기](https://developer.chrome.com/blog/new-in-devtools-62?hl=ko#har-imports) | HAR imports in the Network panel
  - [자세한 내용](https://developer.chrome.com/docs/devtools/network/reference?hl=ko#export)

![Save all network requests to a HAR file](https://developer.chrome.com/static/docs/devtools/network/reference/image/selecting-save-as-har-c-543367c2a7051_856.png)

## Chrome 65

- [로컬 재정의 (Local Overrides)](https://developer.chrome.com/blog/new-in-devtools-65?hl=ko#overrides)
  - [더 자세한 내용](https://developer.chrome.com/docs/devtools/overrides?hl=ko)

![Local Overrides](https://developer.chrome.com/static/blog/new-in-devtools-65/image/persisting-css-change-ac-3da090318c534.gif)

## Chrome 66

- [Override 파일을 저장할 폴더 지정](https://developer.chrome.com/blog/new-in-devtools-66?hl=ko#overrides)
  - 원본 소스에서 파일 수정 후 저장하면 해당 경로로 파일이 저장됨.
  - 이후 해당 페이지는 항상 Override된 파일을 참조하기 때문에 디버깅 후 해당 파일은 삭제함.

![Local Overrides now works with some styles defined in HTML](https://developer.chrome.com/static/blog/new-in-devtools-66/image/an-example-styles-define-a24be5796e36a_856.png)

## Chrome 126

- Console에 자바스크립트 코드를 붙여넣으면 발생하는 [self-XSS 경고](https://developer.chrome.com/blog/self-xss)
  - [self-XSS 경고 비활성화](https://developer.chrome.com/blog/new-in-devtools-126#self-xss-flag)

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

- ChatGPT
- [DevTools의 새로운 기능](https://developer.chrome.com/docs/devtools/news?hl=ko) | What's New in DevTools
