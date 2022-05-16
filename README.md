# GitHub Page와 Hugo를 이용한 블로그

- [GitHub Page와 Hugo를 이용한 블로그](#github-page와-hugo를-이용한-블로그)
  - [로컬 환경](#로컬-환경)
    - [Windows](#windows)
    - [Linux](#linux)
    - [실행](#실행)
  - [배포](#배포)
    - [Bash](#bash)
    - [PowerShell](#powershell)

## 로컬 환경

- [Hugo 설치](https://gohugo.io/getting-started/installing/)

### Windows

- version <= 0.92.0
  - 0.93.0부터는 SCSS가 빌드되지 않는데 원인을 모름.

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

### Linux

```bash
# Debian
sudo apt-get install hugo
```

```bash
# Fedora
sudo dnf install hugo
```

### 실행

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
