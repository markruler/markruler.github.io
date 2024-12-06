---
draft: true
socialshare: true
date: 2024-12-05T11:05:00+09:00
lastmod: 2024-12-05T11:05:00+09:00
title: "리눅스 프로세스 관련 명령어 도구 모음"
description: "PID는 Process IDentifier, PPID는 Parent PID"
featured_image: "/images/gui/xdg/dall-e-x-window-system.webp"
images: ["/images/gui/xdg/dall-e-x-window-system.webp"]
tags:
  - linux
  - process
categories:
  - wiki
---

# 개요

## Command

```sh
top -c
```

```sh
# 시간대별 프로세스 사용량
sar
```

```sh
# 실시간 프로세스 사용량 (1초마다)
sar 1
```

```sh
# ps 명령어로 PID와 PPID 확인 후 루트 PID로 확인
sudo pstree -p 1392
```
