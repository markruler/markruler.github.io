---
draft: false
socialshare: true
date: 2025-01-13T19:13:00+09:00
lastmod: 2025-01-13T19:13:00+09:00
title: "네트워크 대역폭과 NFS 지연"
description: "사실 아직도 정확히 이해하지 못한 문제"
images: ["/images/network/nfs-network-bandwidth/static-file-server.png"]
tags:
  - NFS
categories:
  - blog
---

IDC마다 다르겠지만 일반적으로 Outbound 네트워크 트래픽 양에 따라 비용을 부과합니다.
제가 속한 팀은 트래픽 비용을 줄이기 위해 기존에 사설망(private network) 없이
내부 서버 간 통신하던 시스템에 사설망을 추가했습니다.

![static-file-server.png](/images/network/nfs-network-bandwidth/static-file-server.png)

DB 백업을 위해 Veeam을 사용하다가 expdp와 RMAN을 사용하기 시작했고,
NFS 마운트 된 스토리지에 백업본을 저장했습니다.

# 문제

NFS 마운트 된 정적 파일들(이미지, 스크립트 파일)을 조회하는 서버에서만 부하가 발생하기 시작했습니다.

확인해보니 DB 서버 회선에서 허용되는 네트워크 대역폭(1Gbps)의 100%를 사용하는 경우가 계속 발생했고,
덩달아 NFS 접근도 느려진 것입니다.
백업 기능을 변경한 후 발생했습니다.

![static-file-server.png](/images/network/nfs-network-bandwidth/inbound-db-server.png)

*Inbound (DB server)*

![static-file-server.png](/images/network/nfs-network-bandwidth/outbound-storage-server.png)

*Outbound (Storage server)*

레거시 서버에서 파일 업로드 기능 중 NFS 마운트 된 스토리지 서버에 저장하는 기능이 있었는데,
해당 기능에 DB 트랜잭션도 함께 묶이면서 DB에도 영향이 있었습니다.
가장 큰 문제는 레거시 프로젝트에 DB 트랜잭션 타임아웃 설정이 없어서 지속적으로 대기하는 상황이 발생했습니다.

# 결론

전체 시스템에 장애를 발생시킨 직접적인 원인은 트랜잭션 타임아웃이었지만,
근본적인 원인은 NFS 마운트 된 디렉토리에 과도한 입출력이 발생한 것이었습니다.
DB 트랜잭션 타임아웃 설정과 함께 DB 백업 경로를 수정해서 해결은 되었습니다.

하지만 장애가 발생한 후 확인하는 것이 아닌 발생하기 전 예방하는 것이 좋다고 생각합니다.
기능 설계 시 처리 가능한 트래픽 양을 계산하고, 부하 테스트를 통해 내구성을 테스트해야 합니다.
