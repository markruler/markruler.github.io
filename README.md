# GitHub Page와 Hugo를 이용한 블로그

- [GitHub Page와 Hugo를 이용한 블로그](#github-page와-hugo를-이용한-블로그)
  - [로컬 환경](#로컬-환경)
    - [Hugo 설치](#hugo-설치)
    - [실행](#실행)
  - [배포](#배포)
    - [Bash](#bash)
    - [PowerShell](#powershell)

## 로컬 환경

### [Hugo 설치](https://gohugo.io/getting-started/installing/)

```bash
# Debian
sudo apt-get install hugo
```

### 실행

```bash
cd _blog

./scripts/startup.sh
```

## 배포

### Bash

```bash
./bash.deploy.sh
```

### PowerShell

```ps1
./windows.deploy.ps1
```
