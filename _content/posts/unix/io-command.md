---
draft: true
socialshare: true
date: 2024-12-05T11:05:00+09:00
lastmod: 2024-12-05T11:05:00+09:00
title: "리눅스 파일 관련 명령어 도구 모음"
description: ""
featured_image: "/images/gui/xdg/dall-e-x-window-system.webp"
images: ["/images/gui/xdg/dall-e-x-window-system.webp"]
tags:
  - linux
  - io
categories:
  - wiki
---

# Command

## fio

```sh
sudo yum install fio
```

```sh
fio --name=write_test --directory=/data3 --size=1G --bs=4k --rw=write --direct=1 --numjobs=1
write_test: (g=0): rw=write, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=psync, iodepth=1
fio-3.7
Starting 1 process
write_test: Laying out IO file (1 file / 1024MiB)
^Cbs: 1 (f=1): [W(1)][8.9%][r=0KiB/s,w=5277KiB/s][r=0,w=1319 IOPS][eta 03m:15s]
fio: terminating on signal 2

write_test: (groupid=0, jobs=1): err= 0: pid=156612: Thu Dec  5 16:51:10 2024
  write: IOPS=1232, BW=4929KiB/s (5048kB/s)(91.6MiB/19024msec)
    clat (usec): min=336, max=266946, avg=809.41, stdev=2745.05
     lat (usec): min=336, max=266948, avg=809.68, stdev=2745.06
    clat percentiles (usec):
     |  1.00th=[  392],  5.00th=[  412], 10.00th=[  429], 20.00th=[  453],
     | 30.00th=[  465], 40.00th=[  478], 50.00th=[  486], 60.00th=[  490],
     | 70.00th=[  498], 80.00th=[  515], 90.00th=[  562], 95.00th=[  611],
     | 99.00th=[14877], 99.50th=[15926], 99.90th=[24249], 99.95th=[25560],
     | 99.99th=[45876]
   bw (  KiB/s): min= 2368, max= 7032, per=99.99%, avg=4928.50, stdev=924.36, samples=38
   iops        : min=  592, max= 1758, avg=1232.08, stdev=231.09, samples=38
  lat (usec)   : 500=71.29%, 750=26.18%, 1000=0.15%
  lat (msec)   : 2=0.03%, 4=0.01%, 10=0.45%, 20=1.77%, 50=0.12%
  lat (msec)   : 500=0.01%
  cpu          : usr=0.47%, sys=1.77%, ctx=45854, majf=0, minf=30
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,23444,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=4929KiB/s (5048kB/s), 4929KiB/s-4929KiB/s (5048kB/s-5048kB/s), io=91.6MiB (96.0MB), run=19024-19024msec
```

```sh
fio --name=read_test --directory=/data3 --size=1G --bs=4k --rw=read --direct=1 --numjobs=1
read_test: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=psync, iodepth=1
fio-3.7
Starting 1 process
read_test: Laying out IO file (1 file / 1024MiB) # 테스트할 파일 생성
Jobs: 1 (f=1): [R(1)][99.1%][r=16.5MiB/s,w=0KiB/s][r=4215,w=0 IOPS][eta 00m:01s]
read_test: (groupid=0, jobs=1): err= 0: pid=169588: Thu Dec  5 16:55:40 2024
   read: IOPS=2414, BW=9658KiB/s (9890kB/s)(1024MiB/108572msec)
    clat (usec): min=173, max=38020k, avg=412.42, stdev=74295.26
     lat (usec): min=173, max=38020k, avg=412.52, stdev=74295.26
    clat percentiles (usec):
     |  1.00th=[  184],  5.00th=[  196], 10.00th=[  206], 20.00th=[  210],
     | 30.00th=[  212], 40.00th=[  215], 50.00th=[  217], 60.00th=[  223],
     | 70.00th=[  233], 80.00th=[  251], 90.00th=[  269], 95.00th=[  273],
     | 99.00th=[  306], 99.50th=[  363], 99.90th=[ 1500], 99.95th=[10814],
     | 99.99th=[83362]
   bw (  KiB/s): min=   24, max=20672, per=100.00%, avg=14854.58, stdev=5599.90, samples=141
   iops        : min=    6, max= 5168, avg=3713.61, stdev=1399.99, samples=141
  lat (usec)   : 250=79.62%, 500=20.12%, 750=0.09%, 1000=0.03%
  lat (msec)   : 2=0.05%, 4=0.02%, 10=0.02%, 20=0.01%, 50=0.01%
  lat (msec)   : 100=0.03%, 250=0.01%, 500=0.01%, 1000=0.01%
  cpu          : usr=0.43%, sys=2.19%, ctx=498949, majf=0, minf=45
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=9658KiB/s (9890kB/s), 9658KiB/s-9658KiB/s (9890kB/s-9890kB/s), io=1024MiB (1074MB), run=108572-108572msec
```
