# GitHub Pages와 Hugo를 이용한 블로그

- [GitHub Pages와 Hugo를 이용한 블로그](#github-pages와-hugo를-이용한-블로그)
  - [Install Hugo](#install-hugo)
  - [Install Dart Sass](#install-dart-sass)
  - [로컬 실행](#로컬-실행)
  - [배포](#배포)
  - [Theme 변경](#theme-변경)
    - [submodule 삭제](#submodule-삭제)
  - [Install Make](#install-make)

## Install Hugo

- [Linux](https://gohugo.io/installation/linux/)

```sh
sudo snap install hugo
# sudo snap refresh hugo
# sudo snap refresh
```

- [macOS](https://gohugo.io/installation/macos/)

```sh
brew install hugo
# brew upgrade hugo
```

- [Windows](https://gohugo.io/installation/windows/)

```ps1
choco install hugo-extended
# choco upgrade hugo-extended
# choco upgrade all
```

## Install Dart Sass

[link](https://gohugo.io/hugo-pipes/transpile-sass-to-css/#installing-in-a-development-environment)

- [Linux](https://github.com/jmooring/dart-sass-snap)

```sh
sudo snap install dart-sass
```

- macOS

```sh
brew install sass/sass/sass
```

- [Windows](https://community.chocolatey.org/packages/sass)

```sh
choco install sass
```

## 로컬 실행

```sh
make run
```

## 배포

```sh
make deploy
```

## Theme 변경

```sh
# git submodule add -b main git@github.com:AmazingRise/hugo-theme-diary.git themes/hugo-theme-diary
git submodule add -b develop git@github.com:markruler/hugo-theme-diary.git themes/hugo-theme-diary
```

```sh
hugo --contentDir content --destination .
```

```sh
# Init themes
git submodule update --init --recursive

# Update themes
git submodule update --remote --merge

# theme submodule 삭제 시
git rm -f ./hugo-theme-diary
rm -rf .git/modules/themes/hugo-theme-diary
```

### submodule 삭제

```sh
git submodule deinit -f themes/hugo-theme-diary
rm -rf .git/modules/themes/hugo-theme-diary
git rm -f themes/hugo-theme-diary
```

## Install Make

- [Windows 11](https://gnuwin32.sourceforge.net/packages/make.htm)
- 설치 후 환경 변수 추가
  - `sysdm.cpl` > 시스템 변수
  - `Path`: `C:\Program Files (x86)\GnuWin32\bin`

```sh
make -v
```
