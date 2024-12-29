---
draft: false
date: 2024-11-24T23:32:00+09:00
lastmod: 2024-12-29T19:34:00+09:00
title: "웹 페이지 응답 방법과 프레임워크"
description: "서버 응답 속도가 빨라도 웹 페이지 응답이 느려서야"
featured_image: "/images/web/respond-web-page/bottleneck.webp"
images: ["/images/web/respond-web-page/bottleneck.webp"]
tags:
  - network
  - web
  - frontend
categories:
  - wiki
---

- [CGI (Common Gateway Interface)](#cgi-common-gateway-interface)
- [SSR (Server-Side Rendering)](#ssr-server-side-rendering)
- [서버 템플릿 엔진](#서버-템플릿-엔진)
- [CSR (Client-side Rendering)](#csr-client-side-rendering)
  - [SPA (Single Page Application)](#spa-single-page-application)
  - [Web API: Web Component](#web-api-web-component)
  - [PWA (Progressive Web Apps)](#pwa-progressive-web-apps)
- [SSG (Static Site Generation)](#ssg-static-site-generation)
- [CMS (Content Management System)](#cms-content-management-system)
- [Micro Frontend Architecture (MFA)](#micro-frontend-architecture-mfa)
- [아일랜드 아키텍쳐 Island Architecture](#아일랜드-아키텍쳐-island-architecture)
- [웹뷰(WebView) - 모바일 앱에서](#웹뷰webview---모바일-앱에서)
- [더 읽을거리](#더-읽을거리)

# CGI (Common Gateway Interface)

웹 서버와 외부 프로그램(애플리케이션) 간에 데이터를 주고받기 위한 인터페이스입니다.
웹 서버가 클라이언트(브라우저)로부터 요청을 받으면, CGI 프로그램을 호출하여 동적으로 콘텐츠를 생성한 뒤, 그 결과를 클라이언트에 반환합니다.

# SSR (Server-Side Rendering)

서버에서 콘텐츠를 렌더링하여 완전한 HTML을 클라이언트에게 전달합니다.

- 여기서 렌더링한다는 의미는 화면을 그린다는 게 아니라 DOM 구조를 만든다는 것입니다.
- 렌더링을 서버에서 수행하기 때문에 CSR에 비해 상대적으로 최초 페이지 응답 속도가 느립니다.
  - 서버가 한국에 있고 클라이언트가 해외에 있다면 빈 페이지도 받지 못하고 오래 기다리게 됩니다.
- 검색 엔진 봇이 완전한 HTML을 받기 때문에 SEO에 유리합니다.

# 서버 템플릿 엔진

- Tomcat의 Jasper
  - JSP(JavaServer Pages) 파일을 서블릿 코드로 변환하고 컴파일하는 데 사용되는 JSP 엔진입니다.
  - include 지시어를 사용해서 여러 부분으로 코드 조각을 나눌 수 있습니다.
  - static include 방식을 이용해 빌드된 React, Vue 프로젝트의 `index.html`을 포함시킬 수도 있습니다.
- Microsoft의 Razor
  - C# 코드와 HTML을 결합합니다.
- Twig, Smarty, Blade
  - PHP 템플릿 엔진들입니다.

# CSR (Client-side Rendering)

클라이언트(브라우저)에서 콘텐츠를 렌더링합니다.

- 물을 부어 보충한다는 의미로 Hydration한다고도 합니다. 초기 렌더링(SSR)과 구분지어 표현하기 위해 사용하는 듯합니다.
- 서버에서 HTML 문서를 응답받아서 브라우저가 DOM을 렌더링 한 후 추가로 렌더링합니다.
- 경우에 따라 오리진 서버에서 받을 필요가 없기 때문에 캐시된 문서를 받을 수 있습니다.
- 동일한 페이지라면 서버에서 렌더링하는 SSR보다 페이지 응답 속도가 빠릅니다.
- 검색 엔진 봇이 크롤링할 때 빈 페이지로 보입니다. 이 경우 화면이 그려질 때까지 기다렸다가 스크래핑하는 경우도 있습니다.

## SPA (Single Page Application)

- Vue, React, Angular
- 사용자가 웹 애플리케이션 상호 작용할 때 전체 페이지를 새로 고치지 않고, 필요한 데이터만 서버와 교환하여 동적으로 콘텐츠를 업데이트하는 웹 애플리케이션 구조입니다.
- Vue를 JSP와 비교해서 예를 들면,
  - Vue App
    - JSP 페이지 하나와 동일.
    - 컴포넌트들의 모임.
    - 여러 JSP로 분리시켜서 include한다면 include 지시어가 명시된 root 페이지가 app
    - 정확하게는 다름. JSP는 Component 단위별로 분리하는 것이 아니라 head, footer, 공통 스크립트 등으로 분리하는 경우가 많음.
  - Vue Component
    - 공통 컴포넌트.
    - 분리된 JSP.

## Web API: Web Component

- 기능들을 나머지 코드로부터 캡슐화하여 재사용 가능한 커스텀 엘리먼트를 생성하고 웹 앱에서 활용할 수 있도록 해주는 다양한 기술들의 모음입니다.
- Web 생태계에서 [표준적으로 사용](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Client-side_APIs)되기 때문에 React, Vue와 같은 프레임워크에 종속되지 않습니다.
  - [Web APIs](https://developer.mozilla.org/en-US/docs/Web/API)

## PWA (Progressive Web Apps)

단일 코드베이스로 모든 기기의 모든 웹 사용자에게 도달하는 동시에 향상된 기능을 제공하기 위해 최신 API로 빌드되고 향상된 웹 앱입니다.

- 캐시된 페이지를 기반으로 오프라인에서도 동작할 수 있습니다.
- 웹 앱이지만 모바일 앱처럼 설치할 수 있습니다.

# SSG (Static Site Generation)

- Gatsby(Javascript), Hugo(Go), Jekyll(Ruby)
- 주로 템플릿을 활용해서 정적 웹 페이지를 생성 후 웹 서버로 서빙합니다.
- DB가 필요없는 경우 사용합니다.
- [블로그](https://markruler.github.io/)나 [웹진](https://beott.kr/), 혹은 회사 소개 페이지 등에 사용할 수 있습니다.

# CMS (Content Management System)

웹사이트나 애플리케이션의 콘텐츠를 생성, 수정, 관리, 출판할 수 있는 시스템입니다.

- 구축되면 개발자가 아닌 사람도 쉽게 글을 작성할 수 있습니다.
- 잼스택(JAMStack)
  - DB 없이 JavaScript, API, Markup을 기반으로 하는 웹 아키텍처입니다.
  - 내 블로그처럼 Hugo로 빌드한 웹 사이트를 GitHub Pages로 배포한 것도 JAMStack에 해당합니다.
- DB 사용
  - 스트라피(Strapi), 워드프레스(WordPress), 줌라(Joomla), 드루팔(Drupal)
  - CMS를 위한 별도 DB와 서버를 사용합니다.

# Micro Frontend Architecture (MFA)

각 '마이크로-프론트엔드'는 독립적으로 개발 및 배포가 가능합니다.

- 각자 다른 기술 스택을 사용할 수도 있습니다.
- 대규모 프로젝트에서 서로 다른 팀들이 각각의 프론트엔드 파트를 개발하는 데 적합합니다.
- 하나의 app(페이지)에 여러 app 혹은 component가 포함됩니다.
- 혹은 하나의 프로젝트에 여러 app이 포함됩니다.
  - 어떤 페이지는 JSP, 어떤 페이지는 React, 어떤 페이지는 Vue.

# 아일랜드 아키텍쳐 Island Architecture

- 웹페이지의 필요에 따라 일부는 SSG로 렌더링하고, 일부는 Progressive Hydration(Re-hydration)합니다.
  - 필요할 때만 자바스크립트를 로드하여 성능을 최적화합니다.
  - 전체 페이지가 아니라 개별 컴포넌트 단위로 자바스크립트를 실행해 불필요한 코드 로드를 방지합니다.
  - 하나의 app(페이지)에 여러 프레임워크의 Component가 있을 수 있습니다.
- 대표적으로 Astro, Ebay의 Marko 같은 도구가 Island Architecture를 지원합니다.

# 웹뷰(WebView) - 모바일 앱에서

웹뷰란 네이티브 앱에 내재되어 있는 웹 브라우저입니다.

- 특별한 경우가 아니라면 앱 스토어의 검수를 받을 필요가 없기 때문에 자주 업데이트 할 수 있습니다.
- 네이티브 앱은 서버에서 웹 페이지를 응답 받을 필요없이 디바이스에서 바로 렌더링합니다. 반면 웹뷰는 서버에서 웹 페이지를 받아야 하기 때문에 레이턴시가 발생합니다.
- 네이티브 앱은 수정 사항을 배포할 때 앱 스토어의 검수가 필요합니다. (약 1~3일 소요)
- 웹뷰만으로 구성된 앱은 스토어 심사가 어려울 수도 있습니다.
- 추가로 고려해야 할 부분: 웹뷰 간 이동, 웹뷰-네이티브 간 이동, 뒤로가기 제스처나 버튼, DeepLink

# 더 읽을거리

- [모던 웹 앱 디자인 패턴](https://patterns-dev-kr.github.io/) | Patterns.dev.kr
  - [origin](https://www.patterns.dev/) | Patterns.dev
- CMS
  - [Strapi 1년이면 풀스택을 읊는다](https://medium.com/pinkfong/strapi-1년이면-풀스택을-읊는다-part-1-2-5641f5651097) | 더핑크퐁컴퍼니
- PWA
  - [What are Progressive Web Apps?](https://web.dev/articles/what-are-pwas) | web.dev
- Web Components
  - [Web Components](https://developer.mozilla.org/ko/docs/Web/API/Web_components) | MDN Web Docs
  - [Using custom elements](https://developer.mozilla.org/ko/docs/Web/API/Web_components/Using_custom_elements) | MDN Web Docs
  - [Using shadow DOM](https://developer.mozilla.org/ko/docs/Web/API/Web_components/Using_shadow_DOM) | MDN Web Docs
  - [Using templates and slots](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_templates_and_slots) | MDN Web Docs
  - [웹 컴포넌트(5) - lit-html로 React 처럼 코딩하기](https://ui.toast.com/posts/ko_20171215) | TOAST UI
- 아일랜드 아키텍쳐
  - [The Island Architecture](https://patterns-dev-kr.github.io/rendering-patterns/the-island-architecture/) | Patterns.dev.kr
- 웹뷰
  - [웹뷰(WebView)](https://docs.tosspayments.com/resources/glossary/webview) | Toss Payments 용어 사전
  - [아니, 여기도 웹뷰였어요?](https://youtu.be/4UD4EB00AME) | 2024 당근 테크 밋업
  - [병원 상세 웹뷰 통신 및 크로스 브라우징](https://boostbrothers.github.io/hospital-detail-webview/) | BBROS
