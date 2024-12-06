---
draft: true
socialshare: true
date: 2024-12-06T13:26:00+09:00
lastmod: 2024-12-06T13:26:00+09:00
title: "한국어 미지원 스팀 게임에 대한 비공식 한국어 패치 만들기"
description: "게임 엔진별 한국어 패치 제작 방법"
featured_image: "https://upload.wikimedia.org/wikipedia/en/timeline/p5fnoxd13tfvmrtxgy91nph8fruz54p.png"
images: ["https://upload.wikimedia.org/wikipedia/en/timeline/p5fnoxd13tfvmrtxgy91nph8fruz54p.png"]
tags:
  - reverse-engineering
  - game-localization
categories:
  - wiki
---

# 개요

- 저작권 그리고 위법성에 대해.
- 게임 개발사마다 대응이 다름.
  - 대부분 호의적
  - 일부는 고소까지
- 해커의 마음에 따라
  - 선: 화이트햇 해커
  - 악: 블랙햇 해커
  - 마찬가지로 게임 치트(핵)와 한끗 차이

# 대표적인 게임 엔진

- SteamDB 기준

# 게임 엔진별 한국어 패치 제작 방법

## 언팩 도구 사용하기

인기 있는 게임 엔진들은 이미 언팩 도구가 존재합니다.

### Unity

### Unreal Engine 4

### Godot Engine

### GameMaker Studio 2

## 파일 카빙 (File Carving)

만약 적절한 언팩 도구가 없는 경우 직접 파일을 추출해야 합니다.
이는 리버스 엔지니어링 기술이 필요합니다.
우선 파일 시그니처(Magic Number)를 확인하고 파일을 추출합니다.
이후 다시 파일을 재패키징하여 게임에 적용합니다.

### Love2D

Love2D 게임은 `.love` 파일로 패키징되어 있습니다.
`.love` 파일은 ZIP 파일 기반의 포맷입니다.
일반적인 unzip 도구로 압축을 풀면 게임 파일을 확인할 수 있지만,
패치 도구(Patch)를 만들기 위해 직접 Unpack 하려면 파일 시그니처를 찾아야 합니다.
ZIP 포맷의 파일 시그니처는 `PK`이기 때문에 이를 찾아내어 파일을 추출하고,
Love2D 개발툴을 사용해서 다시 패키징합니다.

# 더 읽을거리

- [저작권법과 유저 한글패치](https://kr.bignox.com/blog/noxplay1696557618i7bNOeCmnuqjtJFGds5M9/)
