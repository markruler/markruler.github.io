---
draft: false
date: 2024-09-05T21:13:00+09:00
lastmod: 2024-09-05T21:13:00+09:00
title: "일상에서의 스왑 메모리 (Swap Memory)"
description: "스왑 메모리 설정과 모니터링"
# featured_image: "/images/os/swap-memory/pexels-artyusufpatel-9203123.jpg"
featured_image: "/images/os/swap-memory/pexels-crazy-motions-80195021-12198537.jpg"
images: ["/images/os/swap-memory/pexels-crazy-motions-80195021-12198537.jpg"]
tags:
  - linux
  - memory
categories:
  - how-to
---

**스왑 메모리는 물리 메모리 용량이 부족할 때 사용되는 가상 메모리 영역**이다.
고사양 작업 중 메모리가 부족해서 컴퓨터가 자주 멈춘다면 스왑 메모리를 늘려보는 것도 하나의 방법이다.
이 글은 **Ubuntu 24.04**에서 **스왑 메모리를 file로 설정**하고, 나의 환경에 맞게 조정하기 위해 **모니터링 하는 방법**을 설명한다.

먼저 현재 스왑 메모리 사용량 확인한다.

```sh
sudo swapon --show
```

설정되어 있지 않다면 아무것도 출력되지 않는다.
Ubuntu 24.04 기준으로는 기본적으로 설정되어 있다.
이 글은 설정되어 있지 않다는 전제로 진행한다.

```sh
NAME      TYPE SIZE USED PRIO
/swap.img file   8G   0B   -2
```

# 스왑 설정: file

## 스왑 파일 생성

`dd` 명령으로 16 GiB 크기의 `/swapfile` 이라는 파일을 생성한다.
(파일명은 뭘로 해도 상관없다.)

```sh
sudo dd if=/dev/zero of=/swapfile bs=1M count=16K
# 16384+0 records in
# 16384+0 records out
# 17179869184 bytes (17 GB, 16 GiB) copied, 11.2337 s, 1.5 GB/s
```

`swapon` 매뉴얼에도 명시[^1]되어 있지만 `fallocate`는 사용하지 않는 것을 권장한다.[^2]
연속된 블록에 실제 데이터를 파일에 쓰는 `dd`와 달리 `fallocate`는 논리적인 파일의 크기만 설정하고 데이터를 쓰지 않기 때문이다.

> 스왑 파일은 물리 메모리가 부족할 때 디스크에 데이터를 저장하는 역할을 한다.
> 그리고 파일 시스템과 커널은 스왑 파일에 데이터를 효율적으로 읽고 쓰기 위해 파일의 실제 물리적 위치가 명확한 것이 좋다.
> 물리적으로 할당되지 않은 블록을 포함할 수 있는 **Sparse file은 파일의 논리적인 크기와 실제 디스크에 할당된 크기가 다를 수 있기 때문에**
> 스왑이 예상대로 동작하지 않을 수 있다.

## 권한 설정

Swap 파일을 root만 읽고 쓰도록 권한을 설정한다.

```sh
sudo chmod 600 /swapfile
```

```sh
sudo ls -hal /swapfile
# -rw------- 1 root root 16.0G  3월  9 16:43 /swapfile
```

## 파일 형태 변경

파일 형태를 확인해보면 `data` 파일이다.

```sh
sudo file /swapfile
# /swapfile: data
```

Swap 파일을 Linux swap file로 설정한다.

```sh
sudo mkswap /swapfile
# Setting up swapspace version 1, size = 16 GiB (17179865088 bytes)
# no label, UUID=ec298bfb-0c82-4cd1-98aa-5466773f8a09
```

```sh
sudo file /swapfile
# /swapfile: Linux swap file, 4k page size, little endian, version 1, size 4194303 pages, 0 bad pages, no label, UUID=ec298bfb-0c82-4cd1-98aa-5466773f8a09
```

## Swap 영역 설정

만든 Swap 파일을 swap 영역으로 설정한다.

```sh
sudo swapon /swapfile
```

## 설정 확인

```sh
sudo swapon --show
```

```sh
NAME      TYPE SIZE USED PRIO
/swapfile file  16G   0B   -2
```

사용되는 부분이 생기면 아래처럼 `USED` 부분에 사이즈가 커짐.

```sh
NAME      TYPE SIZE   USED PRIO
/swapfile file  16G 153.3M   -2
```

- `TYPE` : Swap 메모리의 종류
  - `file`: 파일
  - `partition`: 디스크 파티션
- `SIZE` : Swap 메모리의 크기
- `USED` : Swap 메모리의 사용량
- `PRIO` : Swap 메모리의 우선순위. 값이 클수록 우선적으로 사용된다.

# 부팅 시 자동 마운트 설정

Ubuntu 24.04 기준 기본 설정값에는 `/swap.img` 파일이 있다.

```sh
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/swap.img       none    swap    sw      0       0
```

(위 설정이 없다는 전제 하에)
새로 추가한 스왑 영역을 추가한다.

```sh
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

# 용량 늘리기

스왑 메모리 크기는 시스템의 물리 메모리 용량과 사용 용도에 따라 결정된다.

```sh
free -h
#                total        used        free      shared  buff/cache   available
# Mem:            31Gi        24Gi       490Mi       3.9Gi       5.8Gi       2.0Gi
# Swap:          2.0Gi       1.3Gi       677Mi
```

사이즈를 늘리기 전 swap을 끈다.

```sh
sudo swapoff /swapfile
```

사이즈를 추가한다.

```sh
# 4GiB 추가
sudo dd if=/dev/zero of=/swapfile bs=1M count=4K oflag=append conv=notrunc
# 4096+0 records in
# 4096+0 records out
# 4294967296 bytes (4.3 GB, 4.0 GiB) copied, 4.60434 s, 933 MB/s
```

사이즈 늘린 것을 적용하려면 `swapon -v` 명령어로 다시 설정해야 한다.

```sh
sudo mkswap /swapfile
# mkswap: /swapfile: warning: wiping old swap signature.
# Setting up swapspace version 1, size = 8 GiB (8589930496 bytes)
# no label, UUID=1516c52d-9ed8-4a52-939f-30a892aff73f
```

```sh
sudo swapon -v /swapfile                                                                                                 ✭ ✱
# swapon: /swapfile: found signature [pagesize=4096, signature=swap]
# swapon: /swapfile: pagesize=4096, swapsize=8589934592, devsize=8589934592
# swapon /swapfile
```

```sh
free -h
#                total        used        free      shared  buff/cache   available
# Mem:            31Gi        24Gi       433Mi       4.0Gi       5.8Gi       1.5Gi
# Swap:          8.0Gi       1.3Gi       6.7Gi
```

# 비활성화

```sh
sudo swapoff /swapfile
```

`/etc/fstab` 파일에서 Swap 파일 설정을 제거한다.

```sh
# /etc/fstab
# /swapfile none swap sw 0 0
```

# Kubernetes에서 Swap 기능을 비활성화해야 하는 이유

가장 큰 이유는 스왑 메모리가 있다면 Kubernetes는 메모리 부족 상황을 정확하게 파악할 수 없다는 것이다.[^3]
**안정성을 위해** 스왑 메모리를 비활성화하는 것이 좋다.
스왑이 자주 발생하면 디스크 입출력이 증가하면서 성능이 저하되는 문제도 있다.

# Prometheus node-exporter를 이용한 모니터링

[이 리포지터리](https://github.com/markruler/node-monitoring)를 클론해서
Prometheus와 Grafana를 실행해서 모니터링 할 수 있다.

```sh
sudo docker compose up -d
```

![Node Monitoring with Prometheus and Grafana](/images/os/swap-memory/grafana-prometheus-swap-memory.png)

본인의 컴퓨팅 작업 시 사용량을 확인하면서 메모리 사용량이 항상 90% 이상이면 스왑 메모리를 늘리는 것을 고려해볼 수 있다.

# 더 읽을거리

- [Swap Management | kernel.org](https://www.kernel.org/doc/gorman/html/understand/understand014.html)
- [Virtualization 101 - (3.1) 메모리 오버커밋과 메모리 여유공간 확보 방법 | 송주환](https://velog.io/@sjuhwan/Virtualization-101-3-1-메모리-오버커밋과-메모리-여유공간-확보-방법)
- [kubelet swap on 체크 PR#31996](https://github.com/kubernetes/kubernetes/pull/31996)

[^1]: [swapon(8) | Linux manual page](https://man7.org/linux/man-pages/man8/swapon.8.html#NOTES)
[^2]: [fallocatte vs. dd | StackExchange](https://askubuntu.com/questions/927854/how-do-i-increase-the-size-of-swapfile-without-removing-it-in-the-terminal)
[^3]: [최초 이슈 kuberenetes#31676](https://github.com/kubernetes/kubernetes/issues/31676)
