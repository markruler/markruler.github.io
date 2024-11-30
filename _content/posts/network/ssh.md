---
date: 2024-07-17T22:40:00+09:00
lastmod: 2024-08-28T22:42:00+09:00
title: "일상에서의 SSH"
description: "Secure Shell"
featured_image: "/images/network/ssh/pexels-mo-eid-1268975-8347500.webp"
images: ["/images/network/ssh/pexels-mo-eid-1268975-8347500.webp"]
tags:
  - network
  - shell
  - security
categories:
  - wiki
---

- [SSH key 생성](#ssh-key-생성)
- [SSH Server](#ssh-server)
  - [authoized\_keys](#authoized_keys)
  - [주로 사용하는 Server 설정](#주로-사용하는-server-설정)
- [SSH Client](#ssh-client)
  - [설정 파일 우선 순위](#설정-파일-우선-순위)
  - [known\_hosts](#known_hosts)
  - [주로 사용하는 Host 설정](#주로-사용하는-host-설정)
  - [Git](#git)
  - [Local Forward](#local-forward)
- [Password 입력 없이 SSH Key로 Client에서 Server로 접속하기](#password-입력-없이-ssh-key로-client에서-server로-접속하기)
- [참조](#참조)

> 업무에서 자주 사용하는 SSH 설정을 정리합니다.

# SSH key 생성

```sh
# RSA
ssh-keygen -t rsa -b 4096 -C ""

# ED25519
ssh-keygen -t ed25519 -f $HOME/.ssh/my-ed25519 -C "comment" -N "password"
```

# SSH Server

SSH 데몬 설정 파일은 `/etc/ssh/sshd_config`이다.

```sh
sudo apt install openssh-server
```

```sh
systemctl status ssh
```

## authoized_keys

- 역할: SSH 서버가 접속을 허용할 클라이언트의 공개키를 저장하는 파일이다. (사용자 인증 방식)
- 위치: 보통 사용자의 홈 디렉토리 아래의 `~/.ssh/authorized_keys`에 위치한다.
- 내용: 클라이언트의 공개 키가 저장된다.
  서버는 클라이언트의 접속 시도 시,
  이 파일에 저장된 공개 키와 클라이언트가 제공한 키를 비교하여 인증을 수행한다.
- 보안: 비밀번호 대신 공개 키를 사용하여 인증하기 때문에,
  공개 키 인증 방식이 비밀번호 인증보다 더 안전하다.
  특히, 비밀번호를 통한 무차별 대입 공격에 대한 저항력이 높다.

SSH 데몬(sshd) 설치 혹은 실행 시 `/etc/ssh` 디렉토리에 비대칭키 쌍이 생성 및 저장된다.
만약 설치 시 생성되지 않았다면, 맨 처음 실행할 때 생성된다.
`ssh-keygen` 명령어를 사용해서 수동으로 생성 및 교체할 수도 있다.

```sh
> ls /etc/ssh | grep "ssh_host"
ssh_host_ecdsa_key
ssh_host_ecdsa_key.pub
ssh_host_ed25519_key
ssh_host_ed25519_key.pub
ssh_host_rsa_key
ssh_host_rsa_key.pub
```

수동으로 교체하는 명령어는 다음과 같다.

```sh
# 새 키 생성
sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key_new

# 새 키를 기존 키로 대체
sudo mv /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key_old
sudo mv /etc/ssh/ssh_host_rsa_key_new /etc/ssh/ssh_host_rsa_key
sudo mv /etc/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key_old.pub
sudo mv /etc/ssh/ssh_host_rsa_key_new.pub /etc/ssh/ssh_host_rsa_key.pub

# SSH 서버 재시작
sudo systemctl restart sshd
```

## 주로 사용하는 Server 설정

설정 완료 후 데몬 재시작(`systemctl restart sshd`)해야 적용된다.

```sh
## /etc/ssh/sshd_config
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# SSH 서버가 Listen할 포트 지정
Port 22

# 서버의 호스트 키 파일 경로를 지정
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# 루트 로그인 허용 여부
PermitRootLogin no # yes, prohibit-password

# 비밀번호 인증 허용 여부
PasswordAuthentication no # yes

# 공개키 인증 허용 여부
PubkeyAuthentication yes # no

# 허용할 사용자 및 그룹
AllowUsers user1 user2
AllowGroups sshusers

# 거부할 사용자 및 그룹
DenyUsers user3 user4
DenyGroups nogroup

# 비밀번호 인증 시도 횟수 제한
MaxAuthTries 3 # default 6

# 비밀번호 인증 시도 간격
LoginGraceTime 120 # seconds == 2m
```

`/etc/hosts.allow` 파일에 허용할 IP를 설정할 수 있다.

```sh
# 모든 호스트 허용
sshd: ALL
# 하나의 IP를 허용할 경우
sshd: 192.168.1.33
# IP 대역으로 허용할 경우
sshd: 192.168.1.0/24
# 특정 도메인을 허용할 경우
sshd: .example.com
```

# SSH Client

system-wide 설정 파일은 `/etc/ssh/ssh_config`이다.

```sh
sudo apt install openssh-client
```

## 설정 파일 우선 순위

1. 명령줄 옵션: 가장 우선한다.
2. 환경 변수
3. `$HOME/.ssh/config`: 사용자별 설정 파일
4. `/etc/ssh/ssh_config`: 전역 설정 파일

## known_hosts

- 역할: SSH 클라이언트가 접속하려는 서버의 HostKey(공개키)를 저장하는 파일이다. (서버 인증 방식)
- 위치: 보통 사용자의 홈 디렉토리 아래의 `~/.ssh/known_hosts`에 위치한다.
- 내용: 서버의 호스트 키 정보가 저장된다.
  클라이언트가 처음 특정 서버에 접속할 때,
  서버의 호스트 키를 확인하고 `known_hosts` 파일에 저장한다.
  이후 동일 서버에 접속할 때는 이 파일을 참조하여 서버의 신원을 확인한다.
- 보안: 서버의 호스트 키가 변경되면 SSH 클라이언트는 보안 경고를 출력하고 접속을 차단한다.
  이는 중간자 공격(MITM, Man-in-the-Middle Attack)을 방지하기 위한 메커니즘이다.

## 주로 사용하는 Host 설정

```sh
# $HOME/.ssh/config
Host my-host
  User markruler
  HostName 111.222.111.222
  IdentityFile ~/.ssh/my-key.pem
  IdentitiesOnly yes
  LogLevel VERBOSE
```

remote host의 SSH 데몬이 최신 키를 지원하지 않는 오래된 버전인 경우

```sh
Host old-host
  HostName 111.222.111.222
  User markruler
  HostKeyAlgorithms = +ssh-rsa,ssh-dss
  LogLevel VERBOSE
```

- [HostKeyAlgorithms](https://cloud.ibm.com/docs/hp-virtual-servers?topic=hp-virtual-servers-generate_ssh)
  - ssh-ed25519
  - ssh-rsa
  - ssh-dss
  - ecdsa-sha2-nistp256

## Git

```sh
# 회사 계정과 분리하고 싶을 경우
Host work.github.com
  HostName github.com
  IdentityFile ~/.ssh/github_work_ed25519
  User git

Host github.com
  IdentityFile ~/.ssh/github_ed25519
  User git

Host bitbucket.org
  IdentityFile ~/.ssh/bitbucket_ed25519
  User git
```

위에서 Github 주소를 회사 repository와 구분해서 관리할 경우 remote repository 주소도 변경해야 한다.
새로 clone 받는 경우에는 clone 받을 때 주소만 변경해주면 된다.

```sh
git clone git@work.github.com:xpdojo/kubernetes.git
```

```toml
# .git/config
[remote "origin"]
  url = git@work.github.com:xpdojo/kubernetes.git
  fetch = +refs/heads/*:refs/remotes/origin/*
```

## Local Forward

- Bastion Host를 두고 Local Forwarding이 필요한 경우

```sh
Host tost
  User markruler
  HostName ec2-111.222.111.222.ap-northeast-2.compute.amazonaws.com
  LocalForward localhost:14000 something.abcd.ap-northeast-2.rds.amazonaws.com:1521
  IdentityFile ~/.ssh/my-rds-key.pem
  LogLevel VERBOSE
```

```sh
ssh -f -N tost
```

커넥션을 끊어야 할 경우 PID을 직접 죽인다.

```sh
ps -ef | grep tost
# markrul+   38624    4372  0 08:37 ?        00:00:00 ssh -f -N tost
kill -TERM 38624
```

**위 설정과 동일한 명령어**는 다음과 같다.

```sh
ssh -vv -f -N \
  -i "~/.ssh/my-rds-key.pem" \
  -L 14000:something.abcd.ap-northeast-2.rds.amazonaws.com:1521 \
  ec2-111.222.111.222.ap-northeast-2.compute.amazonaws.com
```

# Password 입력 없이 SSH Key로 Client에서 Server로 접속하기

Server에서 authorized_keys 파일에 공개키를 등록하고 Client에서 개인키를 사용하여 접속한다.
(AWS에서 EC2 인스턴스 생성 시, Key Pair를 생성하고 PEM 파일을 다운로드 하는 이유)

```sh
# server: SSH Key 생성
touch ~/.ssh/authorized_keys
# 600(rw)
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/mykey.pub >> ~/.ssh/authorized_keys

# server > client private key 전달 (최대한 안전한 방식으로)
# scp ~/.ssh/mykey client@host2:~/.ssh/mykey

# client
# 700(rwx)
chmod 700 ~/.ssh
# 400(r)
chmod 400 ~/.ssh/mykey

# client ~/.ssh/config
Host host1
  User markruler
  IdentitiesOnly yes
  IdentityFile ~/.ssh/mykey
  HostName 192.168.0.10
  Port 22
  LogLevel VERBOSE

# client
ssh host1
```

# 참조

- ChatGPT
- Client
  - [SSH config file for OpenSSH client](https://www.ssh.com/academy/ssh/config) - SSH Academy
  - [ssh_config(5)](https://linux.die.net/man/5/ssh_config) - Linux man page
- Server
  - [sshd_config(5)](https://linux.die.net/man/5/sshd_config) - Linux man page
- 원리
  - [보안 그리고 암호화 알고리즘](https://naleejang.tistory.com/218) - 장현정(naleejang)
  - [SSH 동작원리 및 EC2 SSH 접속](https://medium.com/@labcloud/ssh-%EC%95%94%ED%98%B8%ED%99%94-%EC%9B%90%EB%A6%AC-%EB%B0%8F-aws-ssh-%EC%A0%91%EC%86%8D-%EC%8B%A4%EC%8A%B5-33a08fa76596) - redwood
- [Managing multiple Bitbucket user SSH keys on one device](https://support.atlassian.com/bitbucket-cloud/docs/managing-multiple-bitbucket-user-ssh-keys-on-one-device/) - Bitbucket
  - [Git 계정 여러 개 동시 사용하기](https://blog.outsider.ne.kr/1448) - Outsider's Dev Story
