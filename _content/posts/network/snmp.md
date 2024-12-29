---
date: 2024-07-23T19:08:00+09:00
lastmod: 2024-07-23T19:08:00+09:00
title: "네트워크 장비 모니터링을 위한 SNMP"
description: "Simple Network Management Protocol"
featured_image: "/images/network/snmp/pexels-googledeepmind-17485706.webp"
images: ["/images/network/snmp/pexels-googledeepmind-17485706.webp"]
tags:
  - network
  - monitoring
categories:
  - wiki
---

# 개요

주로 네트워크 장비의 Metric을 확인하는 모니터링 용도로 사용하지만, SNMP를 지원하는 컴퓨팅 머신이라면 모두 활용할 수 있습니다.

# 전제 조건

- IP 네트워크 환경이 있다.
- 관리용 서버(SNMP 서버)가 있다.
- SNMP 프로토콜을 지원하는 기기다.

# 구성 요소

- 매니저 (SNMP 서버)
  - 네트워크 감시 장치(서버)에 설치해서 사용하는 소프트웨어
- 에이전트 (네트워크 기기/서버)
  - 네트워크 기기나 서버가 가진 기기의 상태 정보를 통보하는 기능
- SNMP 프로토콜 (TCP/IP)
  - UDP 패킷에 실어서 주고받으며, 포트 번호는 161(SNMP), 162(TRAP)를 사용합니다.
- MIB (Management Information Base)
  - SNMP로 관리되는 네트워크 기기나 서버가 자신의 상태를 외부에 알리기 위해서 공개하는 관리 정보.
  - [RFC 1156](https://datatracker.ietf.org/doc/html/rfc1156)으로 규정된 MIB1,
    [RFC 1213](https://datatracker.ietf.org/doc/html/rfc1213)으로 규정된 MIB2
  - MIB를 지원하는 기기에 일반적으로 포함된 표준 MIB와 기기 제조사마다 사양이 다른 사설(Private) MIB가 있습니다.
  - MIB의 구조는 트리 구조이며, 트리 구조의 마디(노드)는 번호를 붙여서 나타냅니다. 이 번호열을 OID(Object ID)라고 합니다.

## 매니저-에이전트 역할

- 정보의 요청과 응답
  - 매니저가 에이전트에게 대상 기기의 정보를 요청 → 에이전트는 정보를 매니저에게 응답
- 설정의 요청과 응답
  - 매니저가 에이전트에게 대상 기기의 설정 변경을 요청 → 에이전트는 설정을 변경하며 그 결과를 매니저에게 응답
- 상태 변화의 통보
  - 에이전트가 매니저에게 대상 기기의 상태 변화를 통보

## 매니저-에이전트 통신 방식

- 폴링 (Polling)
  - 매니저가 정기적으로 에이전트로부터 관리 정보를 추출합니다.
- 트랩 (Trap)
  - 에이전트인 라우터나 스위치가 자신의 상태에 어떤 변화가 발생했을 때(장애 발생 등) 자발적으로 매니저인 SNMP 서버에게 정보를 통보합니다.

## 커뮤니티 이름

- 매니저와 에이전트는 커뮤니티 이름으로 그룹화합니다.
- 매니저와 에이전트는 커뮤니티 이름이 같을 때만 통신합니다.

# 버전별 차이

## v1

- 커뮤니티 이름이 포함된 패킷을 평문으로 전달합니다.
- 기본적인 관리 정보 베이스(MIB)와 트랩 메시지를 사용합니다.

## v2

- 커뮤니티 이름이 포함된 패킷을 암호화해서 전달합니다.
- 추가된 PDU 타입(예: [GetBulkRequest](http://www.ktword.co.kr/test/view/view.php?m_temp1=5270))을 통해 대량의 데이터를 한 번에 전송할 수 있습니다.

## v2c

- 커뮤니티 값을 암호화하여 전달하는 것이 복잡해서 v1처럼 평문으로 전달할 수 있도록 원복되었습니다.

## v3

- (username, password) 인증 기능이 추가되었습니다.
- 이 외 다양한 보안 기능 추가되었습니다.

# 관련 명령어 도구

## snmpget

정확한 OID를 입력해야 합니다.

```sh
snmpget -v2c -l NoAuthNoPriv -c Auto_Wini3 61.111.18.165:161 1.3.6.1.2.1.1.1.0 
```

```sh
# output
iso.3.6.1.2.1.1.1.0 = STRING: "Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(58)SE2, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2011 by Cisco Systems, Inc.
Compiled Thu 21-Jul-11 02:13 by prod_rel_team"
```

## snmpwalk

```sh
snmpwalk -v2c -l NoAuthNoPriv -c public <ip_address>:<port> [OID]
```

- 도움말
  - `-h` : help
  - `-H` : 사용 가능한 옵션
- `-v` : SNMP 버전 (`1` | `2c` | `3`)
- `-l` : security level (`noAuthNoPriv` | `authNoPriv` | `authPriv`)
- `-c` : the community string

```sh
snmpwalk -v2c -l NoAuthNoPriv -c Auto_Wini3 61.111.18.165:161 1.3.6.1.2.1.1
```

# MIB-2 OID (Object ID)

![OID Tree](https://media.licdn.com/dms/image/C5112AQEFj7XwbdMicQ/article-inline_image-shrink_400_744/0/1574511512079?e=1726704000&v=beta&t=C8IfB-cyl1xnT9KHPDPx_RwA4jrP918cEjGYjQkeDqY)

*[SNMP Explained: What You Must Know About Monitoring via MIB and OIDs](https://www.linkedin.com/pulse/snmp-explained-what-you-must-know-monitoring-via-mib-oids-kumari)*

## ex: 1.3.6.1.2.1 분해

- 첫번째 자리
  - [1: ISO assigned](https://www.alvestrand.no/objectid/1.html)
- 두번째 자리
  - 0: ISO Standard
  - [3: Identified Organization (org)](https://www.alvestrand.no/objectid/1.3.html)
- 세번째 자리
  - [6: US Department of Defense (dod)](https://www.alvestrand.no/objectid/1.3.6.html)
- 네번째 자리
  - [1: Internet](https://www.alvestrand.no/objectid/1.3.6.1.html)
- 다섯번째 자리
  - [2: Management (mgmt)](https://www.alvestrand.no/objectid/1.3.6.1.2.html)
  - [4: Private](https://www.alvestrand.no/objectid/1.3.6.1.4.html)
    - [1.3.6.1.4.1.9: Cisco](https://www.alvestrand.no/objectid/1.3.6.1.4.1.9.html)
- 여섯번째 자리
  - [1: SNMP MIB-2](https://www.alvestrand.no/objectid/1.3.6.1.2.1.html)

## 1.3.6.1.2.1.1 system

| ID                | Object      | Description        | Link                                         |
| ----------------- | ----------- | ------------------ | -------------------------------------------- |
| `1.3.6.1.2.1.1.1` | sysDescr    | System Description | [oidref](https://oidref.com/1.3.6.1.2.1.1.1) |
| `1.3.6.1.2.1.1.2` | sysObjectID |                    |                                              |
| `1.3.6.1.2.1.1.3` | sysUpTime   |                    |                                              |
| `1.3.6.1.2.1.1.4` | sysContact  |                    |                                              |
| `1.3.6.1.2.1.1.5` | sysName     |                    | [oidref](https://oidref.com/1.3.6.1.2.1.1.5) |
| `1.3.6.1.2.1.1.6` | sysLocation |                    |                                              |
| `1.3.6.1.2.1.1.7` | sysServices |                    | [oidref](https://oidref.com/1.3.6.1.2.1.1.7) |

## 1.3.6.1.2.1.2 interfaces

| ID                     | Object     | Description           | Link                                              |
| ---------------------- | ---------- | --------------------- | ------------------------------------------------- |
| `1.3.6.1.2.1.2.2.1.2`  | ifDescr    | Interface Description | [oidref](https://oidref.com/1.3.6.1.2.1.2.2.1.2)  |
| `1.3.6.1.2.1.2.2.1.4`  | ifMtu      |                       | [oidref](https://oidref.com/1.3.6.1.2.1.2.2.1.4)  |
| `1.3.6.1.2.1.2.2.1.5`  | ifSpeed    |                       | [oidref](https://oidref.com/1.3.6.1.2.1.2.2.1.5)  |
| `1.3.6.1.2.1.2.2.1.10` | ifInOctets |                       | [oidref](https://oidref.com/1.3.6.1.2.1.2.2.1.10) |

## 1.3.6.1.2.1.3 at - Address Translation

| ID              | Object | Description         | Link                                       |
| --------------- | ------ | ------------------- | ------------------------------------------ |
| `1.3.6.1.2.1.3` | at     | Address translation | [oidref](https://oidref.com/1.3.6.1.2.1.3) |

## 1.3.6.1.2.1.4 ip - Internet Protocol

| ID                 | Object            | Description                   | Link                                          |
| ------------------ | ----------------- | ----------------------------- | --------------------------------------------- |
| `1.3.6.1.2.1.4.22` | ipNetToMediaTable | SEQUENCE OF IpNetToMediaEntry | [oidref](https://oidref.com/1.3.6.1.2.1.4.22) |

## 1.3.6.1.2.1.31 ifMIB

| ID                        | Object        | Description                 | Link                                                                                                                                                                                                                                                                                 |
| ------------------------- | ------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `1.3.6.1.2.1.31.1`        | ifMIBObjects  |                             |                                                                                                                                                                                                                                                                                      |
| `1.3.6.1.2.1.31.1.1`      | ifXTable      |                             |                                                                                                                                                                                                                                                                                      |
| `1.3.6.1.2.1.31.1.1.1`    | ifXEntry      |                             |                                                                                                                                                                                                                                                                                      |
| `1.3.6.1.2.1.31.1.1.1.6`  | ifHCInOctets  | 인터페이스의 입력 바이트 수 | [CNRS](https://cric.grenoble.cnrs.fr/Administrateurs/Outils/MIBS/?oid=1.3.6.1.2.1.31.1.1.1.6). 데이터독에선 [ifBandwidthInUsage](https://github.com/DataDog/integrations-core/blame/df2bc0d17af490491651d7578e67d9928941df62/snmp/datadog_checks/snmp/snmp.py#L505)라는 별칭을 씀.   |
| `1.3.6.1.2.1.31.1.1.1.10` | ifHCOutOctets | 인터페이스의 출력 바이트 수 | [CNRS](https://cric.grenoble.cnrs.fr/Administrateurs/Outils/MIBS/?oid=1.3.6.1.2.1.31.1.1.1.10). 데이터독에선 [ifBandwidthOutUsage](https://github.com/DataDog/integrations-core/blame/df2bc0d17af490491651d7578e67d9928941df62/snmp/datadog_checks/snmp/snmp.py#L506)라는 별칭을 씀. |

# 참조

- [<네트워크 운용 및 유지 보수의 모든 것>](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791192469287) - 오카노 신
- [SNMP 쉽게 이해하기 #1](https://aws-hyoh.tistory.com/179) - 네트워크 엔지니어 환경
- OID
  - [CNRS](https://cric.grenoble.cnrs.fr/Administrateurs/Outils/MIBS/?oid=1)
  - [Alvestrand Data](https://www.alvestrand.no/objectid/top.html)
  - [CISCO-STACK-MIB](https://www.circitor.fr/Mibs/Html/C/CISCO-STACK-MIB.php)
  - [Reference record for OID 1.3.6.1.2.1](https://oidref.com/1.3.6.1.2.1)
