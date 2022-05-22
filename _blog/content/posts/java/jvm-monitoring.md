---
date: 2022-05-23T00:09:00+09:00
title: "JVM 모니터링"
description: "이게 왜 죽지..?"
featured_image: "/images/java/jvm-monitoring/visualgc-with-visualvm.png"
images: ["/images/java/jvm-monitoring/visualgc-with-visualvm.png"]
socialshare: true
tags:
  - java
  - spring
  - tomcat
  - monitoring
categories:
  - java
  - monitoring
---

> [모니터링과 타임아웃의 중요성](/posts/java/java-timeout-monitoring/)은 아무리 강조해도 지나치지 않는다.
> 최근 회사에서 아주 느린 API(약 15초)를 발견했는데 분명 매일 트래픽이 발생하는데도 2년동안 방치되고 있었다.
> 이런 레거시는 유지 보수할 일이 없다면 개발팀에서도 확인하기 어렵다.
> 사용자가 리포팅해주길 기대하는 것보다 모니터링 도구를 통해 파악하는 것이 좋다.
> 심지어 굉장히 간단한 문제여서 파악하고 수정하는 데에 1시간도 안걸렸지만 약 15초 걸리던 API를 100ms까지 줄였다.

# 쓰레드 덤프 (Thread Dump)

- 특정 특정 Thread에서 병목 현상이 의심될 때 사용한다.
- JVM Stack 조회

```bash
> jstack -l ${PID} > thread_dump.txt
```

## Non-Daemon Thread

- `thread.setDaemon(false)`
- Non-Daemon Thread가 실행 중인 경우 JVM은 종료되지 않는다.
- 기본적으로 모든 Thread는 Non-Daemon Thread이다.
- Main Thread도 Non-Daemon Thread이다.

```java
// java.lang.Thread
/* Whether or not the thread is a daemon thread. */
private boolean daemon = false;
```

## Daemon Thread

- `thread.setDaemon(true)`
- Daemon Thread는 JVM 종료 시 자동으로 강제 종료한다.
- 언제든지 죽어도 상관없는 작업에 사용한다.
  - Garbage Collector

# Heap Dump

## OutOfMemoryError

JVM 실행 시 아래 옵션을 추가하면 `OutOfMemoryError` 발생으로 JVM이 종료될 때 Heap Dump를 생성한다.

- `-XX:HeapDumpPath`를 생략하면 `JAVA_PATH`에 `java_pid<pid>.hprof` 형태로 파일이 생성된다.
- `-XX:+PrintClassHistogramAfterFullGC`, `-XX:+PrintClassHistogramBeforeFullGC` 등의 옵션으로
  Full GC 전후의 메모리 상태를 간략히 덤프할 수 있다.

```bash
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=jvm.hprof
```

## JDK Tools

![Java Platform Standard Edition 8 Documentation](/images/java/java-conceptual-diagram.png)

*[Java Platform Standard Edition 8 Documentation](https://docs.oracle.com/javase/8/docs/)*

- [JDK Tools and Utilities](https://docs.oracle.com/javase/8/docs/technotes/tools/index.html)
- jps: JVM Process Status

```bash
> jps -v
${PID} Bootstrap -Djava...
```

- jcmd: 성능 관련 카운터 조회

```bash
> jcmd ${PID} PerfCounter.print
java.threads.daemon=42
java.threads.live=49
java.threads.livePeak=52
java.threads.started=3951
...
```

- jmap: JVM Heap 조회

```bash
> jmap -heap ${PID}
Attaching to process ID 3838860, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.292-b10

using thread-local object allocation.
Parallel GC with 10 thread(s)

Heap Configuration:
   MinHeapFreeRatio         = 0
   MaxHeapFreeRatio         = 100
   MaxHeapSize              = 8348762112 (7962.0MB)
   NewSize                  = 174063616 (166.0MB)
   MaxNewSize               = 2782920704 (2654.0MB)
   OldSize                  = 348127232 (332.0MB)
   NewRatio                 = 2
   SurvivorRatio            = 8
   MetaspaceSize            = 21807104 (20.796875MB)
   CompressedClassSpaceSize = 1073741824 (1024.0MB)
   MaxMetaspaceSize         = 17592186044415 MB
   G1HeapRegionSize         = 0 (0.0MB)

Heap Usage:
PS Young Generation
Eden Space:
   capacity = 2094006272 (1997.0MB)
   used     = 398200696 (379.75377655029297MB)
   free     = 1695805576 (1617.246223449707MB)
   19.0162131472355% used
From Space:
   capacity = 82837504 (79.0MB)
   used     = 0 (0.0MB)
   free     = 82837504 (79.0MB)
   0.0% used
To Space:
   capacity = 78643200 (75.0MB)
   used     = 0 (0.0MB)
   free     = 78643200 (75.0MB)
   0.0% used
PS Old Generation
   capacity = 467140608 (445.5MB)
   used     = 107232904 (102.26526641845703MB)
   free     = 359907704 (343.23473358154297MB)
   22.955166423896078% used

47952 interned Strings occupying 5230216 bytes.
```

- jmap: JVM Heap dump 저장
  - 실 서비스 Heap dump 약 6GB, VPN 접속 시 다운로드 시간 15분

```bash
> jmap -dump:format=b,file=/path/app.hprof 3838860 
Dumping heap to /path/app.hprof ...
Heap dump file created

> file /path/app.hprof
app.hprof: Java HPROF dump, created Tue May 17 01:15:39 2022
```

- jhat: Java Heap Analyzer Tool
  - JDK 9에서 제거되었다.

```bash
> jhat -J-Xmx6g -port 7000 /path/app.hprof
```

# GC Monitoring

GC 모니터링이란 JVM이 어떻게 GC를 수행하고 있는지 알아내는 과정을 말한다.

- 처음이라면 Naver D2에 올라온 글 '[Garbage Collection 모니터링 방법](https://d2.naver.com/helloworld/6043)'이 굉장히 도움된다.

## jstat: JVM Statistics Monitoring

- [공식 문서](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html)

```bash
# 1초마다 gc 확인
> jstat -gc <PID> 1000
```

```bash
$ jstat -options
-class
-compiler
-gc
-gccapacity
-gccause
-gcmetacapacity
-gcnew
-gcnewcapacity
-gcold
-gcoldcapacity
-gcutil
-printcompilation
```

| 옵션           | 기능                                                                                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| gc             | 각 힙(heap) 영역의 현재 크기와 현재 사용량(Eden 영역, Survivor 영역, Old 영역등), 총 GC 수행 횟수, 누적 GC 소요 시간을 보여 준다.                             |
| gccapactiy     | 각 힙 영역의 최소 크기(ms), 최대 크기(mx), 현재 크기, 각 영역별 GC 수행 횟수를 알 수 있는 정보를 보여 준다. 단, 현재 사용량과 누적 GC 소요 시간은 알 수 없다. |
| gccause        | -gcutil 옵션이 제공하는 정보와 함께 마지막 GC 원인과 현재 발생하고 있는 GC의 원인을 알 수 있는 정보를 보여 준다.                                              |
| gcnew          | New 영역에 대한 GC 수행 정보를 보여 준다.                                                                                                                     |
| gcnewcapacity  | New 영역의 크기에 대한 통계 정보를 보여 준다.                                                                                                                 |
| gcold          | Old 영역에 대한 GC 수행 정보를 보여 준다.                                                                                                                     |
| gcoldcapacity  | Old 영역의 크기에 대한 통계 정보를 보여 준다.                                                                                                                 |
| gcpermcapacity | Permanent 영역에 대한 통계 정보를 보여 준다.                                                                                                                  |
| gcutil         | 각 힙 영역에 대한 사용 정도를 백분율로 보여 준다. 아울러 총 GC 수행 횟수와 누적 GC 시간을 알 수 있다.                                                         |

## Visual GC

JVM이 어떻게 GC를 수행하고 있는지 확인할 수 있다.

![VisualGC Plugin](/images/java/jvm-monitoring/visualgc-plugin.png)

VisualVM의 Tools > Plugins에서 다운로드 할 수 있다.

![Untitled](/images/java/jvm-monitoring/visualgc-with-visualvm.png)

# Monitoring Tools

## Eclipse Memory Analyzer (MAT)

- [MAT](https://www.eclipse.org/mat/)는 힙 덤프를 분석할 수 있게 도와주는 프로그램이다.
- JDK를 찾지 못하는 경우 아래와 같이 옵션을 추가한다.

```bash
# ${MAT_HOME}/MemoryAnalyzer.ini
-vm
${JAVA_HOME}/bin

# -vmargs 보다 위에 추가해야 한다.
-vmargs
...
```

기본 Heap Size가 1024m이다. Heap Dump 파일이 이보다 큰 경우 Parsing할 때 아래와 같은 에러가 발생한다.

```bash
An internal error occurred during:
    "Parsing heap dump from '/path/java_pid1234.hprof'".
Java heap space
```

설정 파일에 JVM 옵션을 추가하면 확인할 수 있다.

```bash
# ${MAT_HOME}/MemoryAnalyzer.ini
-vmargs
#-Xmx1024m
-Xms6g
-Xmx6g
```

## VisualVM

- [VisualVM](https://visualvm.github.io/download.html)은 힙 덤프도 분석할 수 있지만 애플리케이션을 실시간으로 분석하는 데 주로 사용한다.
- [IntelliJ IDEA Plugin](https://plugins.jetbrains.com/plugin/7115-visualvm-launcher/)을 사용하면 Run with VisualVM 기능을 사용할 수 있다.

```bash
# etc/visualvm.conf
visualvm_jdkhome="$JAVA_HOME"
```

```bash
> ./bin/visualvm
```

![visualvm-tomcat-threads](/images/java/jvm-monitoring/visualvm-tomcat-threads.png)

- Dump 파일을 확인하거나 Remote로 연결해서 실시간으로 확인할 수 있다.
  - File > Load > *.hprof 선택

![visualvm-heap-dump](/images/java/jvm-monitoring/visualvm-heap-dump.png)

- Remote로 연결하기 위해서는 WAS에 JMX 설정이 필요하다.
  - [Apache](https://tomcat.apache.org/download-70.cgi)
  - [Tomcat](https://archive.apache.org/dist/tomcat/)

```bash
# 버전에 맞춰서 다운로드
> ${CATALINA_HOME}/bin/catalina.sh version

> curl -LO https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.41/bin/extras/catalina-jmx-remote.jar

> ${CATALINA_HOME}/bin/catalina.sh start \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.local.only=false \
-Dcom.sun.management.jmxremote.port=1099 \
-Dcom.sun.management.jmxremote.rmi.port=1099 \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Djava.rmi.server.hostname=127.0.0.1 \
-jar
```

## JConsole

```bash
> jconsole
```

![jconsole-overview](/images/java/jvm-monitoring/jconsole-overview.png)

## Datadog

- [Enabling the Java Profiler](https://docs.datadoghq.com/tracing/profiler/enabling/java/)

```bash
-Ddd.profiling.enabled=true \
-XX:FlightRecorderOptions=stackdepth=256
```

## 이 외 도구들

- [Oracle](https://www.oracle.com/java/technologies/jdk-mission-control.html) JDK Mission Control
- [Java Profiler Features](https://www.yourkit.com/java/profiler) - YourKit
- [Pinpoint](https://github.com/pinpoint-apm/pinpoint) - NAVER에서 만든 오픈소스 APM
- [JProfiler](https://www.ej-technologies.com/products/jprofiler/overview.html) (유료)

# 더 읽을 거리

다른 개발자들의 실제 사례를 보면 얻을 수 있는 인사이트가 많다.

## Thread Stack

- [스레드 덤프 분석하기](https://d2.naver.com/helloworld/10963) - Naver D2
- [How to Read a Thread Dump](https://dzone.com/articles/how-to-read-a-thread-dump) - DZone

## Heap Memory

- [하나의 메모리 누수를 잡기까지](https://d2.naver.com/helloworld/1326256) - Naver D2
- [도움이 될수도 있는 JVM memory leak 이야기](https://techblog.woowahan.com/2628/) - 우아한 형제들
- [자바 애플리케이션 성능 튜닝의 도(道)](https://d2.naver.com/helloworld/184615) - Naver D2
- [Java 애플리케이션 트러블 슈팅](https://d2.naver.com/helloworld/1286587) - Naver D2
- [Java Memory Analysis](https://kwonnam.pe.kr/wiki/java/memory) - 권남
- [JVM Crash 문제 해결하기](https://www.whatap.io/ko/blog/28/) - 와탭
- [JMap, JHat으로 Heap Dump 분석](https://cselabnotes.com/kr/2021/03/26/39/) - 삐멜
- [자바 메모리누수(with 힙덤프) 분석하기](http://honeymon.io/tech/2019/05/30/java-memory-leak-analysis.html) - 김지헌
- [Java Heap Dump 를 이용한 문제 해결](https://lng1982.tistory.com/352) - 탁구치는 개발자
- [JVM의 default Heap Size가 궁금하세요?](https://sarc.io/index.php/java/1092-jvm-default-heap-size) - 삵(sarc)
- [생애 첫 Heap 메모리 분석기](https://perfectacle.github.io/2019/04/28/heap-memory-analytics-with-eclipse-mat/) - 양권성
- [Eclipse Memory Analyzer 소개](https://spoqa.github.io/2012/02/06/eclipse-mat.html) - spoqa
- [Eclipse MAT — Incoming, Outgoing References](https://dzone.com/articles/eclipse-mat-incoming-outgoing-references) - DZone
- [Remote Monitoring with VisualVM and JMX](https://www.baeldung.com/visualvm-jmx-remote)
- [아파치 톰캣(Apache Tomcat)을 JMX로 Remote Monitoring 하기](https://www.lesstif.com/java/apache-tomcat-jmx-monitoring-20776824.html)
- 전문가를 위한 스프링 5 (15장 애플리케이션 모니터링)

## Garbage Collection

- <[자바 성능을 결정짓는 코딩 습관과 튜닝 이야기](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788979145229)>라는
  책의 저자가 쓰신 글들은 모두 재밌고 유용하다.
  - [Garbage Collection 모니터링 방법](https://d2.naver.com/helloworld/6043) - Naver D2
  - [Garbage Collection과 Statement Pool](https://d2.naver.com/helloworld/4717) - Naver D2
    - [DBCP 사용시 poolPreparedStatements 속성이 성능에 미치는 영향](https://zzikjh.tistory.com/entry/DBCP-%EC%82%AC%EC%9A%A9%EC%8B%9C-poolPreparedStatements-%EC%86%8D%EC%84%B1%EC%9D%B4-%EC%84%B1%EB%8A%A5%EC%97%90-%EB%AF%B8%EC%B9%98%EB%8A%94-%EC%98%81%ED%96%A5)

## 기타

- [Java 프로파일링 도구](https://blog.naver.com/pcmola/222064546600) - 메이커 꾸러기
- [OpenJDK 9: Life Without HPROF and jhat](https://www.infoq.com/news/2015/12/OpenJDK-9-removal-of-HPROF-jhat/) - InfoQ
- [Everything I Ever Learned About JVM Performance Tuning at Twitter](https://youtu.be/8wHx31mvSLY) - Attila Szegedi