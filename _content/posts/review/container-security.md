---
date: 2021-02-21T11:47:00+09:00
lastmod: 2021-02-21T11:47:00+09:00
title: "책 \"컨테이너 보안\""
description: "Liz Rice"
# featured_image: "/images/review/container-security.jpeg"
images: ["/images/review/container-security.jpeg"]
socialshare: true
tags:
  - container
  - kubernetes
  - docker
Categories:
  - review
---

> 한빛미디어의 지원을 받아 작성되었습니다.

# 거두절미

컨테이너에 관심 있으신 분이라면 필수 소장 도서입니다.
저도 컨테이너, 쿠버네티스, 도커, 클라우드 관련 도서를 많이 읽어봤지만
컨테이너를 이렇게 간명하고 깊게 다루는 책은 없었습니다.
컨테이너 '보안'을 설명하기 위해 컨테이너가 어떻게 동작하는지
설명하는 데에 책의 대부분을 차지합니다.
다만 200 페이지에 많은 내용을 압축한 만큼 도해는 많지 않습니다.

먼저 저자의 [katacoda (An Introduction to Containers for Go programmers)](https://www.katacoda.com/lizrice/courses/containers-and-go)로
실습해보시거나 [발표(What is a container, really? Let's write one in Go from scratch)](https://youtu.be/HPuvDm8IC-4)를 보시길 추천드립니다.

# 저자 리즈 라이스에 대해

저자 리즈 라이스(Liz Rice)는 아쿠아 시큐리티(Aqua Security)의 오픈 소스 엔지니어링
부사장(VP Open Source Engineering)이자 클라우드 네이티브 보안 전문가입니다.
저자는 수년 전부터 꾸준히 `컨테이너`와 `보안`에 관련된 좋은 글을 내고 발표를 하고 있습니다.
저는 한빛미디어의 <나는 리뷰어다 2021> 리뷰어로 선정되어 책의 리뷰를 쓰게 되었지만
이전부터 저자의 [블로그](https://www.lizrice.com/)나
[트위터](https://twitter.com/lizrice)를 챙겨볼 정도로 팬이 되었습니다.

# 대상 독자

도커와 쿠버네티스 등 컨테이너 관련 도구들을 조금은 다뤄보셨고 리눅스의
기본 명령어를 알고 계신 분에게 추천드리지만
하나씩 찾아보면서 읽어보겠다 하는 분들도 충분히 읽으실 수 있습니다.
컨테이너 네트워크를 설명할 때 방화벽과 OSI 레이어부터 설명할 정도니까요.

# 번역

컴퓨터 분야 기술 번역으로 꽤 오래 활동하신 류광님이 번역해주셨습니다.
[공식 한글화 쿠버네티스 문서](https://kubernetes.io/ko/docs/contribute/localization_ko/)나
한국 커뮤니티에서 쓰이는 용어와 다소 차이가 있어서 자연스럽게 읽히진 않습니다.
사실 영어와 한국어가 정확히 일대일로 치환되는 것은 아니기 때문에
역자의 고민이 묻어나는 부분이긴 하지만 독자에 따라 호불호가 있을 수 있습니다.

|원문|번역|커뮤니티에서 흔히 볼 수 있는 번역|
|-|-|-|
|deployment|배치본|디플로이먼트|
|controller|제어기|컨트롤러|
|namespace|이름공간|네임스페이스|
|multitenancy|다중 입주|멀티테넌시|

# 더 읽을 거리

책이 압축되어 있는 만큼 중간중간 별도의 링크를 남겨 더 읽을 거리를
제공합니다. 저도 컨테이너 분야를 공부하면서
[도움되었던 자료들](https://markruler.github.io/posts/container/container-study-guide/)을
모으며 번역하고 있습니다. 필요하신 분들에게 도움이 되었으면 좋겠습니다.
