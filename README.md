# GitHub Page와 Hugo를 이용한 블로그

- [GitHub Page와 Hugo를 이용한 블로그](#github-page와-hugo를-이용한-블로그)
  - [로컬 환경](#로컬-환경)
    - [Docker](#docker)
  - [배포](#배포)
    - [Bash](#bash)
    - [PowerShell](#powershell)

## 로컬 환경

- [Hugo 설치](https://gohugo.io/getting-started/installing/)

### Docker

```sh
docker run --rm -it \
  -v $(pwd)/_blog:/src \
  -p 1313:1313 \
  klakegg/hugo:0.92.0 \
  server
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
