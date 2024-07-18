---
date: 2022-08-21T23:04:00+09:00
title: "X-based desktop"
description: "리눅스 데스크탑을 사용하면 계속 xdg 어쩌구가 나오는데, 이건 뭐지?"
featured_image: "/images/master/markruler-wave.png"
images: ["/images/master/markruler-wave.png"]
socialshare: true
tags:
  - xdg
  - x.org
  - linux
  - GUI
categories:
  - note
---

# XDG: X Development Group

XDG는 `FreeDesktop.org` 의 옛 이름이다.

> [freedesktop.org](http://freedesktop.org/) hosts the development of free and open source software, focused on interoperability and shared technology for open-source graphical and desktop systems.

# 관련 소프트웨어

## XDG user directories

- [xdg-user-dirs](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/) is a tool to handle well known directories in the users homedir.
- [XDG user directories](https://wiki.archlinux.org/title/XDG_user_directories) - archilinux

```bash
> echo $XDG_
$XDG_DATA_DIRS    $XDG_RUNTIME_DIR

> man xdg-user-dirs-update
# xdg-user-dirs-update - Update XDG user dir configuration
> man xdg-user-dir
# xdg-user-dir - Find an XDG user dir

> xdg-user-dir DESKTOP

> cat /etc/xdg/user-dirs.conf
...
# the XDG_CONFIG_HOME and/or XDG_CONFIG_DIRS to override this
enabled=True
filename_encoding=UTF-8

> cat /etc/xdg/user-dirs.defaults
DESKTOP=Desktop
DOWNLOAD=Downloads
TEMPLATES=Templates
PUBLICSHARE=Public
DOCUMENTS=Documents
MUSIC=Music
PICTURES=Pictures
VIDEOS=Videos
```

## X Window System

- [X.Org](http://www.x.org/) is an implementation of the X Window System[^1], known as X11.

[비트맵](https://en.wikipedia.org/wiki/Bitmap) 디스플레이용 [윈도우 시스템](https://en.wikipedia.org/wiki/Windowing_system)이다.

## GUI 도구

[출처](https://www.kernelpanic.kr/25)

|                    | GTK                   | QT                       |
| ------------------ | --------------------- | ------------------------ |
| 지원언어           | C, C++, Python 등     | C++, Python 등           |
| 플랫폼             | Linux, Windows, MacOS | Linux, WIndows, MacOS    |
| 라이센스           | LGPL2.1               | LGPL, GPL, 상용 라이센스 |
| 대표 데스크탑 환경 | Gnome, Xfce           | KDE                      |

## GNOME Desktop

The [GNOME Desktop](https://www.freedesktop.org/wiki/GNOME/) is an attractive and useful desktop environment created by the GNU project.

- GNOME 설정법[^2]
  - **Gconf** - XML based database (backend system). The older one.
  - **Dconf** - BLOB based database (backend system). The newer one.
  - **Gsettings** - CLI tool to edit settings. Looks like it works only with Dconf (although I saw somewhere that it might work with Gconf).

```bash
gnome-shell --version
# GNOME Shell 41.8.1

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED # 투명도 모드
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.6 # 배경 투명도
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style DASHES # 실행 중인 앱 표시 형태
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode FOCUS_APPLICATION_WINDOWS
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32 # 범위: 16-64
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false # 화면에 아이콘이 꽉 차지 않을 때 여백을 두지 않음
gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true # 모니터가 여러 개일 때 어느 모니터에서든 dock을 볼 수 있음
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action cycle-windows # 아이콘 위에서 마우스 스크롤하면 여러 윈도우를 이동할 수 있음
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys true # `super`+`num`
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-show-dock true
gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false
```

### GTK: GIMP ToolKit

- [Wikipedia](https://en.wikipedia.org/wiki/GTK)

## KDE: K(ool) Desktop Environment

- [Wikipedia](https://en.wikipedia.org/wiki/KDE)

### Qt

Qt("cute"로 발음)는 GUI 프로그램 개발에 널리 쓰이는 크로스 플랫폼 소프트웨어다.
서버용 콘솔과 명령 줄 도구와 같은 CLI 프로그램 개발에도 사용된다.
그래픽 사용자 인터페이스를 사용하는 경우에는 Qt를
[Widget toolkit](https://en.wikipedia.org/wiki/Widget_toolkit)으로 분류한다.[^3]

[^1]: [Wikipedia: X Windows System](https://en.wikipedia.org/wiki/X_Window_System)
[^2]: [Ask Ubuntu](https://askubuntu.com/questions/249887/gconf-dconf-gsettings-and-the-relationship-between-them)
[^3]: [Wikipedia: Qt](https://en.wikipedia.org/wiki/Qt_(software))
