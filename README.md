# GitHub Page와 Hugo를 이용한 블로그

- [GitHub Page와 Hugo를 이용한 블로그](#github-page와-hugo를-이용한-블로그)
  - [로컬 환경](#로컬-환경)
  - [콘텐츠 추가](#콘텐츠-추가)
    - [Docker](#docker)
    - [Linux](#linux)
    - [Windows](#windows)
  - [실행](#실행)
  - [배포](#배포)
    - [Bash](#bash)
    - [PowerShell](#powershell)
  - [Theme 변경](#theme-변경)
    - [submodule 삭제](#submodule-삭제)

## 로컬 환경

- [Hugo 설치](https://gohugo.io/getting-started/installing/)
- version <= 0.92.0
  - [0.93.0](https://github.com/gohugoio/hugo/releases/tag/v0.93.0)부터는 SCSS가 빌드되지 않는데 원인을 모름.

## 콘텐츠 추가

- about 페이지: `_content/about/`
- 포스트: `_content/posts/`
- 이미지: `_content/images/`

```sh
# AI 이미지 생성
중앙에 케이블이 여러개 연결된 이미지를 그려줘.
검은색 배경에 노란색으로 강조해.
미니멀리즘 스타일로 그려줘.
결과 이미지 비율은 4:3으로 만들어.
```

### Docker

```sh
# User가 root이기 때문에 실행만 하고 빌드는 하지 않는다.
docker run --rm -it \
  -v $(pwd)/_blog:/src \
  -p 1313:1313 \
  klakegg/hugo:0.92.0 \
  server
```

### Linux

```sh
cd /tmp
wget https://github.com/gohugoio/hugo/releases/download/v0.92.0/hugo_0.92.0_Linux-64bit.tar.gz
tar -xvf hugo_0.92.0_Linux-64bit.tar.gz
```

```sh
echo $PATH
# /usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/var/lib/snapd/snap/bin:...
sudo mv hugo /usr/local/bin
```

```sh
hugo version
# hugo v0.92.0-B3549403 linux/amd64 BuildDate=2022-01-12T08:23:18Z VendorInfo=gohugoio
```

### Windows

```ps1
# Windows
choco list hugo -a -r
choco install hugo --version=0.92.0
```

```ps1
hugo version
# hugo v0.92.0-B3549403 windows/amd64 BuildDate=2022-01-12T08:23:18Z VendorInfo=gohugoio
```

```ps1
choco upgrade hugo --version=0.92.0 --allow-downgrade
```

## 실행

```bash
cd _blog

./scripts/startup.sh
```

## 배포

### Bash

```bash
cd _blog

./scripts/deploy.sh
```

### PowerShell

```ps1
cd _blog

./scripts/windows.deploy.ps1
```

## Theme 변경

```sh
git submodule add -b main git@github.com:AmazingRise/hugo-theme-diary.git themes/hugo-theme-diary
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
