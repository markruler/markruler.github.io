---
date: 2022-08-21T23:04:00+09:00
lastmod: 2024-11-27T17:04:00+09:00
title: "X Desktop Group"
description: "리눅스 데스크탑을 사용하면 계속 xdg 어쩌구가 나오는데, 이건 뭐지?"
featured_image: "/images/gui/xdg/dall-e-x-window-system.webp"
images: ["/images/gui/xdg/dall-e-x-window-system.webp"]
socialshare: true
tags:
  - xdg
  - GUI
categories:
  - note
---

- [freedesktop.org](#freedesktoporg)
- [관련 소프트웨어](#관련-소프트웨어)
  - [XDG user directories](#xdg-user-directories)
  - [X Window System](#x-window-system)
    - [X11 Forwarding](#x11-forwarding)
  - [GNOME Desktop](#gnome-desktop)
- [GUI Toolkit](#gui-toolkit)
  - [GTK: GIMP ToolKit](#gtk-gimp-toolkit)
  - [Qt](#qt)
- [GUI 데스크탑 환경과 관련된 추가 소프트웨어](#gui-데스크탑-환경과-관련된-추가-소프트웨어)
  - [VNC: Virtual Network Computing](#vnc-virtual-network-computing)
  - [RDP: Remote Desktop Protocol](#rdp-remote-desktop-protocol)
- [참조](#참조)

# freedesktop.org

XDG는 `X Desktop Group`의 약자로, [freedesktop.org](https://freedesktop.org)의 옛 이름이다.

> freedesktop.org hosts the development of free and open source software, focused on interoperability and shared technology for open-source graphical and desktop systems.
> \
> \
> freedesktop.org는 오픈 소스 그래픽 및 데스크탑 시스템을 위한 상호 운용성과 공유 기술에 중점을 둔 무료 및 오픈 소스 소프트웨어의 개발을 주도합니다.

# 관련 소프트웨어

## XDG user directories

- [xdg-user-dirs](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)는 사용자 홈 디렉터리에서 "well known" 디렉토리를 관리하기 위한 도구입니다.
  - well known 디렉토리? Downloads, Documents, Music, Pictures, Videos 등 사용자 홈 디렉터리에 자주 사용되는 디렉토리를 말한다.
  - [XDG user directories](https://wiki.archlinux.org/title/XDG_user_directories) - archilinux

```bash
printenv | grep XDG_
# XDG_SESSION_ID=57404
# XDG_RUNTIME_DIR=/run/user/1000
# XDG_SESSION_TYPE=tty
# XDG_SESSION_CLASS=user
```

```sh
man xdg-user-dirs-update
# xdg-user-dirs-update - Update XDG user dir configuration
```

```sh
man xdg-user-dir
# xdg-user-dir - Find an XDG user dir
```

```sh
xdg-user-dir DESKTOP
# /home/markruler/Desktop
```

```sh
cat /etc/xdg/user-dirs.conf
...
# the XDG_CONFIG_HOME and/or XDG_CONFIG_DIRS to override this
enabled=True
filename_encoding=UTF-8
```

```sh
cat /etc/xdg/user-dirs.defaults
# DESKTOP=Desktop
# DOWNLOAD=Downloads
# TEMPLATES=Templates
# PUBLICSHARE=Public
# DOCUMENTS=Documents
# MUSIC=Music
# PICTURES=Pictures
# VIDEOS=Videos
```

## X Window System

- [X.Org](http://www.x.org/)은 [X 윈도우 시스템](https://en.wikipedia.org/wiki/X_Window_System)(X Window System, X11)을 만들었다.
- 유닉스 계열 운영 체제에서 일반적으로 사용되는 [비트맵](https://en.wikipedia.org/wiki/Bitmap) 디스플레이용 [윈도우 시스템](https://en.wikipedia.org/wiki/Windowing_system)이다.

### X11 Forwarding

- macOS에서 [XQuartz](https://www.xquartz.org/)를 사용하여 원격으로 X11 포워딩을 할 수 있다.
  - SSH 데몬 설정에 X11 포워딩을 허용해야 한다.
  - RHEL에서 `xorg-x11-apps` 패키지는 [9부터 deprecated](https://access.redhat.com/solutions/3887371).

```sh
# sshd_config
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
```

```sh
sshd -t | sshd -T
systemctl reload sshd
```

- macOS에서 XQuartz 설치 후 X11 연결

```sh
# macOS
brew install --cask xquartz
```

```sh
# 재시작
reboot
```

```sh
ssh -X user@host
# Activate the web console with: systemctl enable --now cockpit.socket
```

- X Window System이 동작하는지 확인

```sh
firefox
# No matching fbConfigs or visuals found
```

![Firefox](/images/gui/xdg/x-firefox.png)

혹은 xterm 으로 확인

```sh
# dnf provides xterm
dnf install xterm
xterm
```

## GNOME Desktop

The [GNOME Desktop](https://www.freedesktop.org/wiki/GNOME/) is an attractive and useful desktop environment created by the GNU project.

- GNOME 설정법[^1]
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

# GUI Toolkit

[출처](https://www.kernelpanic.kr/25)

|                    | GTK                   | QT                       |
| ------------------ | --------------------- | ------------------------ |
| 지원언어           | C, C++, Python 등     | C++, Python 등           |
| 플랫폼             | Linux, Windows, MacOS | Linux, WIndows, MacOS    |
| 라이센스           | LGPL2.1               | LGPL, GPL, 상용 라이센스 |
| 대표 데스크탑 환경 | GNOME, Xfce           | KDE                      |

## GTK: GIMP ToolKit

- [Wikipedia](https://en.wikipedia.org/wiki/GTK)
- GNOME Desktop: desktop environment
- [GIMP (GNU Image Manipulation Program)](https://www.gimp.org/): raster graphics editor
- [LibreOffice](https://www.libreoffice.org/): office suite
- [Mozilla Firefox](https://www.mozilla.org/firefox/): web browser
- [Mozilla Thunderbird](https://www.thunderbird.net/): email client

## Qt

Qt("cute"로 발음)는 GUI 프로그램 개발에 널리 쓰이는 크로스 플랫폼 소프트웨어다.
서버용 콘솔과 명령 줄 도구와 같은 CLI 프로그램 개발에도 사용된다.
그래픽 사용자 인터페이스를 사용하는 경우에는 Qt를
[Widget toolkit](https://en.wikipedia.org/wiki/Widget_toolkit)으로 분류한다.[^2]

- [KDE](https://en.wikipedia.org/wiki/KDE): K(ool) Desktop Environment
  - [kdenlive](https://kdenlive.org/): video editing software

# GUI 데스크탑 환경과 관련된 추가 소프트웨어

## VNC: Virtual Network Computing

- RFB 프로토콜(Remote Frame Buffer protocol)을 이용하여 원격으로 다른 컴퓨터를 제어하는 그래픽 데스크탑 공유 시스템이다.
- RealVNC, TightVNC, TigerVNC 등이 있다.

## RDP: Remote Desktop Protocol

- RDP는 Microsoft에서 만든 프로토콜로 Windows에서는 [MSTSC](https://learn.microsoft.com/windows-server/administration/windows-commands/mstsc)(Microsoft Terminal Services Client)를 사용하여 원격 데스크탑을 사용할 수 있다.
- XRDP, MS 원격 데스크탑, 팀뷰어 등이 있다.
- [XRDP](https://github.com/neutrinolabs/xrdp)는 리눅스 서버에 RDP로 연결할 수 있다.
  - XDG에서 만든 건 아니다.
- [Ubuntu에 원격 데스크탑을 사용하도록 xrdp 설치 및 구성](https://learn.microsoft.com/azure/virtual-machines/linux/use-remote-desktop) - Microsoft

# 참조

- [freedesktop.org](https://en.wikipedia.org/wiki/Freedesktop.org) - Wikipedia

[^1]: [Ask Ubuntu](https://askubuntu.com/questions/249887/gconf-dconf-gsettings-and-the-relationship-between-them)
[^2]: [Qt](https://en.wikipedia.org/wiki/Qt_(software)) - Wikipedia
