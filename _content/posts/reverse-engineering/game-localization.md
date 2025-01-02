---
draft: false
socialshare: true
date: 2024-12-16T21:26:00+09:00
lastmod: 2025-01-02T19:43:00+09:00
title: "한국어를 지원하지 않는 게임의 비공식 한국어 패치 만들기"
description: "한국어 패치 제작자분들 감사합니다"
featured_image: "/images/reverse-engineering/game-localization/jupiter-hell.png"
images: ["/images/reverse-engineering/game-localization/jupiter-hell.png"]
tags:
  - reverse-engineering
  - game-localization
categories:
  - wiki
---

스팀(Steam) 게임들은 PC에 파일이 설치되기 때문에 다른 플랫폼보다 게임 모드(Mod)나 패치 도구가 꽤 많습니다.
그래서 콘솔이나 고전게임보다 한국어 패치 제작 난이도가 쉽습니다.
한국어 패치 제작에 입문하기 좋은 플랫폼이라고 생각합니다.

- [게임 저작권과 한국어 패치](#게임-저작권과-한국어-패치)
- [대표적인 게임 엔진별 한국어 패치 제작 방법](#대표적인-게임-엔진별-한국어-패치-제작-방법)
  - [언팩 도구 사용하기](#언팩-도구-사용하기)
    - [유니티 (Unity)](#유니티-unity)
    - [언리얼 엔진 (Unreal Engine)](#언리얼-엔진-unreal-engine)
    - [게임메이커 (GameMaker Studio 2)](#게임메이커-gamemaker-studio-2)
    - [렌파이 (Ren'Py - PyGame)](#렌파이-renpy---pygame)
    - [고도 (Godot)](#고도-godot)
  - [파일 카빙 (File Carving)](#파일-카빙-file-carving)
    - [Love2D](#love2d)
    - [고전 게임](#고전-게임)
  - [실시간 번역](#실시간-번역)
    - [XUnity Auto Translator](#xunity-auto-translator)
    - [MORT (MonkeyHead's OCR Realtime Translator)](#mort-monkeyheads-ocr-realtime-translator)
- [더 읽을거리](#더-읽을거리)

# 게임 저작권과 한국어 패치

먼저 저작권부터 이야기해야 할 것 같습니다.
엄연히 게임 파일을 수정하고 배포하는 것은 저작권법 위반입니다.
당연히 배포가 목적이라면 게임 개발사에 허락을 받아야 합니다.[^1]

[^1]: [제101조의4(프로그램코드역분석)](https://www.law.go.kr/법령/저작권법/(20240828,20358,20240227)/제101조의4)

한국어 패치 제작자들은 호의로 패치하는 경우가 대부분이고,
인디 게임 개발사에서는 번역할 여건이 되지 않기 때문에 이에 긍정적으로 반응하는 경우가 대부분입니다.
제가 번역한 게임의 개발사도 크레딧(Credit)에 제 이름을 명시해주겠다는 제의까지 해주셨습니다.
하지만 일부 개발사들은 고소까지 하는 사례도 있다고 하니 법적인 책임을 반드시 숙지해야 합니다.

고소까지 하는 저작권자의 마음도 충분히 이해가 갑니다.
첫번째 이유는 이미 한국어 패치를 계획하고 있다면
게임 개발사, 유통사, 번역사 모두에게 손해가 발생할 수 있기 때문입니다.
두번째 이유는 게임 데이터를 얻고 변조한다는 점에서
한국어 패치 제작과 게임 핵 제작은 한끗 차이이기 때문입니다.
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

언팩-리팩 과정은 [UABEA](https://github.com/nesrak1/UABEA)를 사용합니다.[^3]

[^3]: 원본 패치 툴인 [UABE (Unity Asset Bundle Extractor)](https://github.com/SeriousCache/UABE)는 업데이트가 중단되었습니다.

[SDF(Signed Distance Fields)](https://docs.unity3d.com/Packages/com.unity.textmeshpro@4.0/manual/FontAssetsSDF.html) 폰트 생성 시
Glyph 관련 부분을 제외한 모든 부분을 원본과 동일하게 만들어야 한다는 것에 유의해야 합니다.
자세한 폰트 교체 방법은 [Snowyegret](https://snowyegret.tistory.com/21)님의 글을 참고하세요.

IL2CPP[^4]로 빌드된 유니티 게임은 [nesrak1/AddressablesTools](https://github.com/nesrak1/AddressablesTools)을 사용해서
`catalog.json` 파일을 수정해야 합니다.

[^4]: [IL2CPP](https://docs.unity3d.com/6000.0/Documentation/Manual/scripting-backends-il2cpp.html)는 유니티의 스크립트를 C++로 컴파일하는 기술입니다.
유니티는 기본적으로 **Mono** 런타임을 사용해 C# 코드를 **Intermediate Language — IL**로 컴파일하고,
이를 런타임에서 Just-In-Time (JIT) 방식으로 실행합니다.
**AOT**(Ahead-of-Time Compilation) 컴파일은 런타임에서 코드를 컴파일하는 것이 아니라
미리 네이티브 코드로 컴파일하는 방식입니다.
JIT를 사용할 수 없는 플랫폼(ex: iOS, WebGL, Console)에서 사용됩니다.
IL2CPP는 AOT 방식의 일종으로 IL 코드를 C++ 코드로 변환 후 네이티브 코드로 컴파일합니다.
C++ 언어는 대부분의 플랫폼에서 지원되기 때문에 이 방식을 사용하면 플랫폼 호환성이 높아집니다.

```sh
Example patchcrc catalog.json
```

### 언리얼 엔진 (Unreal Engine)

5는 툴이 없어서 시도해보지 못했습니다.
4는 해외 커뮤니티에서 [masagrator라는 유저가 작성한 글과 툴](https://gbatemp.net/threads/how-to-unpack-and-repack-unreal-engine-4-files.531784/)을 참고하세요.

다른 게임과 달리 Epic Games는 언팩 도구(`UnrealPak`)를 직접 제공합니다.
패치 파일을 원본 pak 파일 위치에 `_p`라는 접미사를 붙이면 적용됩니다.

### 게임메이커 (GameMaker Studio 2)

언팩-리팩 과정은 언더테일 모드 툴인 [UnderminersTeam/UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool/releases)을 사용합니다.

자세한 폰트 교체 방법은 [Snowyegret](https://snowyegret.tistory.com/65)님의 글을 참고하세요.
폰트 교체 시 데이터 구조를 알고 파이썬과 같은 스크립트 언어를 안다면 좀 더 수월하게 패치할 수 있습니다.

### 렌파이 (Ren'Py - PyGame)

[rpatool](https://github.com/shizmob/rpatool)로 패치할 파일을 언팩-리팩해서 게임 경로에 두면 적용됩니다.

```sh
git clone git@github.com:shizmob/rpatool.git

# origin.rpa에 포함된 파일 목록 조회
python3 rpatool -l origin.rpa

# RPA 파일을 추출해서 patch라는 폴더에 저장
python3 rpatool -o output -x origin.rpa

# 수정 후 패치 파일 리팩
python3 rpatool -c patch.rpa output
```

### 고도 (Godot)

[GDRETools/gdsdecomp](https://github.com/GDRETools/gdsdecomp)

~~`translation.csv` 파일 추출을 지원하지 않아서 시도하지 못했었는데, [v0.8.0](https://github.com/GDRETools/gdsdecomp/releases/tag/v0.8.0) 버전부터 가능해졌다고 합니다.~~

먼저 GDRE로 언팩할 때 암호화가 되어 있어서 에러가 발생했다면 encryption key를 찾아야 합니다.
[Godot 3.5.2](https://github.com/godotengine/godot/tree/3.5.2-stable) 기준
Ghidra를 사용해서 `script_encryption_key`를 찾습니다.
변수명과 함수명 등은 컴파일 과정에서 모두 사라지기 때문에
근처에 하드코딩된 문자열을 찾아서 키를 유추해야 합니다.

준비가 되었다면 `.pck` 파일을 언팩합니다.
번역 파일이 만약 `csv`나 `po`와 같은 텍스트 파일이라면 간단하게 에디터로 수정 후
GDRE에서 `PCK` > `Create PCK archive from folder...`로 패키징하면 됩니다.
만약 `.translation` 파일처럼 바이너리 형태라면 헥사 에디터와 같은 도구를 사용해서
바이트 크기를 정확하게 맞춰서 수정해야 합니다.
`translation` 파일을 텍스트 형식으로 편집할 수 있는 툴은 아직 없는 것 같습니다.

## 파일 카빙 (File Carving)

만약 적절한 언팩 도구가 없는 경우 직접 파일을 추출해야 합니다.
이때 [파일 카빙](../file-signature/#1-시그니처-기반-카빙)이 필요합니다.
우선 파일 시그니처를 찾거나 유추해서 파일을 추출합니다.
이후 파일을 다시 패키징(repack)하여 게임에 적용합니다.

### Love2D

Love2D 게임은 `.love` 파일로 패키징되어 있습니다.
`.love` 파일은 ZIP 파일 기반의 포맷입니다.
일반적인 unzip 도구로 압축을 풀면 게임 파일을 확인할 수 있지만,
패치 도구(Patch)를 만들기 위해 직접 언팩하려면 파일 시그니처를 찾아야 합니다.
ZIP 포맷의 파일 시그니처는 `PK`이기 때문에 이를 찾아내어 파일을 추출하고,
Love2D 개발툴을 사용해서 다시 패키징합니다.

### 고전 게임

고전 게임은 롬 카트리지에 저장되어 있습니다.[^5]
구동 가능한 롬 파일을 직접 제작하거나 구해야 하는데, 아직 이 부분은 저도 모르겠습니다.
YY-CHR와 같은 툴로 롬 파일을 열어서 스프라이트 폰트를 수정하고,
HxD와 같은 Hex Editor로 폰트 매핑과 스크립트를 수정합니다.
패치 과정 자체는 스팀 게임과 동일하지만 Hex Editor를 들여다보는 일에 많은 인내가 필요합니다.

[^5]: 롬 카트리지([ROM cartridge](https://en.wikipedia.org/wiki/ROM_cartridge))에 저장된 패키지 게임입니다.
예를 들어, SFC(Super Famicom), GBA(Gameboy Advance), SNK NEOGEO, PS1, PCE(PC Engine) 등의 콘솔 게임들이 있습니다.
파일 시그니처를 모른채 직접 패턴을 파악해야 해서 난이도가 어렵다고 생각합니다.

## 실시간 번역

화면에 스크립트가 렌더링되고 텍스트를 추출해서 번역하는 방식입니다.
그래서 딜레이가 꽤 있습니다.
번역 방식은 인터넷을 통해 기계 번역하는 방법과 미리 번역된 파일을 활용해서 치환하는 방법이 있습니다.

### XUnity Auto Translator

한국어가 없는 신규 출시 유니티 게임을 플레이하고 싶을 때 유저들이 많이 사용하는 편입니다.
**BepInEx**을 사용해서 게임 텍스트를 추출하고 치환합니다.
다만 게임과의 충돌로 인해 게임이 실행되지 않을 수도 있고, 게임 플레이 도중에 진행 불가 버그가 발생할 수도 있습니다.

- [bbepis/XUnity.AutoTranslator](https://github.com/bbepis/XUnity.AutoTranslator)
  - [사용 방법](https://page.onstove.com/indie/global/view/9835166)

### MORT (MonkeyHead's OCR Realtime Translator)

국내 유저가 만들고 계속 업데이트 중인 툴입니다.
유니티 외 게임에서도 사용할 수 있습니다.
**OCR**을 사용해서 화면에 출력된 텍스트를 읽는다고 합니다.
그래서 게임 텍스트 자체를 치환하는 것이 아닌 추가 레이어를 두기 때문에 게임 플레이 시 몰입을 방해할 수 있습니다.

- [MORT](https://blog.naver.com/killkimno/223497997082)

# 더 읽을거리

- [[인터뷰] 저작권법과 유저 한글패치](https://www.inven.co.kr/webzine/news/?news=289168) - 인벤 & 이철우 게임·엔터테인먼트 전문 변호사
- [더 다양한 한국어 패치 방법](https://cafe.naver.com/hansicgu/19375) - 한식구
- [한글 완성형 인코딩](https://ko.wikipedia.org/wiki/%ED%95%9C%EA%B8%80_%EC%99%84%EC%84%B1%ED%98%95_%EC%9D%B8%EC%BD%94%EB%94%A9) - 위키백과
- [완성형 한글](https://namu.wiki/w/%EC%99%84%EC%84%B1%ED%98%95) - 나무위키
