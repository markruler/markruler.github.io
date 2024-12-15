---
draft: true
socialshare: true
date: 2024-12-15T12:26:00+09:00
lastmod: 2024-12-15T12:26:00+09:00
title: "한국어를 지원하지 않는 스팀 게임의 비공식 한국어 패치 만들기"
description: "한국어 패치 제작 방식의 종류"
featured_image: "/images/reverse-engineering/game-localization/jupiter-hell.png"
images: ["/images/reverse-engineering/game-localization/jupiter-hell.png"]
tags:
  - reverse-engineering
  - game-localization
categories:
  - wiki
---

스팀(Steam) 게임들을 위한 모드나 패치 도구가 많아서 고전게임(ROM에 저장된 패키지 게임: NES, GBA, NEOGEO, PS1)보다 비교적 난이도가 쉽습니다.

# 게임 저작권과 한국어 패치

엄연히 게임 파일을 수정하고 배포하는 것은 저작권법 위반입니다.
배포가 목적이라면 반드시 게임 개발사에 허락을 먼저 받아야 합니다.[^1]

[^1]: [제101조의4(프로그램코드역분석)](https://www.law.go.kr/법령/저작권법/(20240828,20358,20240227)/제101조의4)

한국어 패치 제작자들은 호의적으로 패치하는 경우가 대부분이며,
인디 게임 개발사에서는 번역할 여건이 되지 않아서 이에 호의적으로 반응하는 경우가 많습니다.
제가 번역한 게임의 개발사도 크레딧(Credit)에 제 이름을 명시해주겠다는 제의까지 해주었습니다.
하지만 일부 개발사들은 고소까지 하는 사례도 있다고 하니 법적인 책임은 반드시 숙지해야 합니다.

고소까지 하는 게임 개발사의 마음도 충분히 이해됩니다.
첫번째 이유는 이미 한국어 패치를 계획하고 있다면
게임 개발사, 유통사, 번역사 모두에게 손해가 발생할 수 있기 때문입니다.
두번째 이유는 게임 데이터를 얻고 변조한다는 점에서
한국어 패치 파일을 만든다는 것이 게임 핵을 만드는 것과 한끗 차이이기 때문입니다.
패치 제작자의 의도에 따라 완전히 다른 패치 프로그램(Patcher)이 만들어지는 것이죠.
그래서 멀티 게임을 운영하는 개발사에서는 유독 민감하게 반응하는 것 같습니다.

# 대표적인 게임 엔진별 한국어 패치 제작 방법

> SteamDB 기준 가장 많이 사용된 게임 엔진부터 나열했습니다.[^2]

[^2]: [What are games built with and what technologies do they use?](https://steamdb.info/tech/) - SteamDB

기본적으로 제가 패치하는 방법은 다음과 같습니다.

1. 게임 엔진별 언팩 도구를 사용하여 게임 파일을 추출합니다(unpack).
2. 스크립트(script 혹은 dialog)를 번역하고 수정합니다.
3. 한글을 지원하지 않는 폰트인 경우 폰트를 생성합니다.
4. 번역된 스크립트와 폰트를 다시 패키징하여(repack) 게임에 적용합니다.

한 가지 언어(주로 영어)만 제공하는 게임은 스크립트가 별도로 있지 않고,
게임 장면에 직접 포함되어 있는 경우가 있습니다.
이 경우 파일 카빙을 하거나 개발사에 직접 요청해야 합니다.
폰트도 한글을 지원하지 않는 경우가 많습니다.

## 언팩 도구 사용하기

인기 있는 게임 엔진들은 이미 언팩(unpack) 도구가 존재합니다.

### 유니티 (Unity)

[UABEA](https://github.com/nesrak1/UABEA)를 사용합니다.
원본 패치 툴인 [UABE (Unity Asset Bundle Extractor)](https://github.com/SeriousCache/UABE)는 업데이트가 중단되었습니다.
자세한 사용법은 [Snowyegret](https://snowyegret.tistory.com/21)님의 글을 참고하세요.

- 폰트 생성 시 Font 부분을 제외한 모든 부분을 원본과 동일하게 만들어야 한다는 것에 유의해야 합니다.

### 언리얼 엔진 (Unreal Engine)

5는 툴이 없어서 시도해보지 못했습니다.
4는 해외 커뮤니티에서 [masagrator라는 유저가 작성한 글과 툴](https://gbatemp.net/threads/how-to-unpack-and-repack-unreal-engine-4-files.531784/)을 참조하시면 됩니다.

유니티와 달리 Epic Games는 언패키지 도구(`UnrealPak`)를 직접 제공합니다.
패치 파일을 원본 pak 파일 위치에 `_p`라는 접미사를 붙이면 적용됩니다.

### 게임메이커 (GameMaker Studio 2)

언더테일 모드 툴인 [UnderminersTeam/UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool/releases)을 사용합니다.
방법은 [Sonwyegret](https://snowyegret.tistory.com/65)님의 글을 참고하세요.

- 폰트 교체 시 데이터 구조를 알고 파이썬과 같은 스크립트 언어를 안다면 좀 더 수월하게 패치할 수 있습니다.

### 렌파이 (Ren'Py - PyGame)

[unrpa](https://github.com/Lattyware/unrpa) 모듈을 사용해서 패치할 파일을 언팩-리팩해서 게임 경로에 두면 적용됩니다.

```sh
python -m pip install unrpa
# RPA 파일 추출
python -m unrpa yourfile.rpa
# 수정 후 패치 파일 리팩
python -m unrpa -mp .\patch .\patch.rpa
```

### 고도 (Godot)

[GDRETools/gdsdecomp](https://github.com/GDRETools/gdsdecomp)

`translation.csv` 파일 추출을 지원하지 않아서 시도하지 못했었는데,
[v0.8.0](https://github.com/GDRETools/gdsdecomp/releases/tag/v0.8.0) 버전부터 가능해졌다고 합니다.

## 파일 카빙 (File Carving)

만약 적절한 언팩 도구가 없는 경우 직접 파일을 추출해야 합니다.
이때 [리버스 엔지니어링](../file-signature/#1-시그니처-기반-카빙)이 필요합니다.
우선 파일 시그니처(Magic Number)를 확인하고 파일을 추출합니다.
이후 파일을 다시 패키징(repack)하여 게임에 적용합니다.

### Love2D

Love2D 게임은 `.love` 파일로 패키징되어 있습니다.
`.love` 파일은 ZIP 파일 기반의 포맷입니다.
일반적인 unzip 도구로 압축을 풀면 게임 파일을 확인할 수 있지만,
패치 도구(Patch)를 만들기 위해 직접 언팩하려면 파일 시그니처를 찾아야 합니다.
ZIP 포맷의 파일 시그니처는 `PK`이기 때문에 이를 찾아내어 파일을 추출하고,
Love2D 개발툴을 사용해서 다시 패키징합니다.

## 실시간 번역

화면에 스크립트가 렌더링되고 텍스트를 추출해서 번역하는 방식입니다.
그래서 딜레이가 꽤 있습니다.
번역 방식은 인터넷을 통해 기계 번역하는 방법과 미리 번역된 파일을 활용해서 치환하는 방법이 있습니다.

### XUnity Auto Translator

한국어가 없는 신규 출시 유니티 게임에 많이 사용되는 편입니다.

> 게임과의 충돌로 인해 게임이 실행되지 않을 수도 있고, 게임 플레이 도중에 진행 불가 버그가 발생할 수도 있습니다.

### OCR을 이용한 방식

국내 유저가 만들고 계속 업데이트 중인 [MORT (MonkeyHead's OCR Realtime Translator)](https://blog.naver.com/killkimno/223497997082)라는 툴이 있습니다.

# 더 읽을거리

- [[인터뷰] 저작권법과 유저 한글패치](https://www.inven.co.kr/webzine/news/?news=289168) - 인벤 & 이철우 게임·엔터테인먼트 전문 변호사
- [더 다양한 한국어 패치 방법](https://cafe.naver.com/hansicgu/19375) - 한식구
- [한글 완성형 인코딩](https://ko.wikipedia.org/wiki/%ED%95%9C%EA%B8%80_%EC%99%84%EC%84%B1%ED%98%95_%EC%9D%B8%EC%BD%94%EB%94%A9) - 위키백과
- [완성형 한글](https://namu.wiki/w/%EC%99%84%EC%84%B1%ED%98%95) - 나무위키
