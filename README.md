# GitHub Page와 Hugo를 이용한 블로그

- [GitHub Page와 Hugo를 이용한 블로그](#github-page와-hugo를-이용한-블로그)
  - [로컬 환경](#로컬-환경)
    - [Docker](#docker)
    - [Linux](#linux)
    - [Windows](#windows)
  - [실행](#실행)
  - [배포](#배포)
    - [Bash](#bash)
    - [PowerShell](#powershell)

## 로컬 환경

- [Hugo 설치](https://gohugo.io/getting-started/installing/)
- version <= 0.92.0
  - [0.93.0](https://github.com/gohugoio/hugo/releases/tag/v0.93.0)부터는 SCSS가 빌드되지 않는데 원인을 모름.

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
