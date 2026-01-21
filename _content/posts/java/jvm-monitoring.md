---
draft: false
socialshare: true
date: 2022-05-23T00:09:00+09:00
lastmod: 2025-04-08T22:00:00+09:00
title: "JVM 모니터링"
description: "Java Virtual Machine"
# featured_image: "/images/java/jvm-monitoring/visualgc-with-visualvm.png"
images: ["/images/java/jvm-monitoring/visualgc-with-visualvm.png"]
tags:
  - observability
  - java
  - spring
categories:
  - wiki
---

# 개요

[모니터링과 타임아웃의 중요성](/posts/java/java-timeout-monitoring/)은 아무리 강조해도 지나치지 않습니다.
회사에서 아주 느린 API(약 15초)를 발견했는데 분명 매일 요청이 있는 데도 2년 동안 방치되고 있었습니다.
이런 API는 사용자가 말해주길 기대하는 것보다 모니터링 도구를 통해 파악하는 것이 좋습니다.
만약 모니터링 설정을 하지 않았다면 API를 수정할 일이 생긴다거나 에러가 발생하지 않는다면 계속 방치되고 있었을 겁니다.
심지어 굉장히 간단한 문제여서 파악하고 수정하는 데에 1시간도 걸리지 않았습니다.
결국 15초 걸리던 API를 100ms까지 줄였죠.

이 글에서는 JVM 모니터링을 위한 도구와 방법에 대해 알아보겠습니다.
가장 먼저 JVM 모니터링을 위한 표준 사양인 JMX부터 알아보겠습니다.

# JMX

[JMX(Java Management eXtensions)](https://en.wikipedia.org/wiki/Java_Management_Extensions)는
애플리케이션을 관리하고 모니터링하기 위한 Java API입니다.

![JMX Architecture](/images/java/jvm-monitoring/jmx-architecture.png)

Probe Level의 MBean(Managed Bean)은 리소스 계측에 사용되는 객체입니다.
모니터링 및 관리할 수 있는 속성, 연산, 알림을 제공합니다.
Standard MBean, Dynamic MBean 등으로 구분되며 구현체를 만들 수 있습니다.
스프링 애플리케이션에서도 빈을 MBean으로 노출할 수 있습니다.

MBean Server는 MBean을 관리하고 제공하는 JMX 인프라의 핵심 구성 요소입니다.
애플리케이션은 MBean Server에 등록된 MBean을 조회하고 조작할 수 있습니다.

Remote Management Level은 커넥터와 어댑터를 통해 MBean Server에 원격으로 접근할 수 있습니다.

# 스레드 덤프 (Thread Dump)

[스레드 덤프](https://docs.oracle.com/cd/E13150_01/jrockit_jvm/jrockit/geninfo/diagnos/using_threaddumps.html)란
모든 스레드 상태의 스냅샷(Snapshot)입니다.

![java-thread-state-machine](/images/java/jvm-monitoring/java-thread-state-machine.png)

*[Java Thread States and Life Cycle](https://www.uml-diagrams.org/java-thread-uml-state-machine-diagram-example.html)*

스레드 덤프에 메서드 콜 스택 정보를 가진 스택 프레임(Stack Frame)은 없습니다.

![Debugging in IntelliJ](/images/java/jvm-monitoring/debugging-in-intellij.png)

*IntelliJ에서 디버깅하면 볼 수 있는 스택 프레임*

```shell
Thread1   Thread2   Thread3
+-------+ +-------+ +-------+
|       | |       | |       |
|       | |       | | frame |
|       | |       | | frame |
| frame | |       | | frame |
| frame | | frame | | frame |
+-------+ +-------+ +-------+
```

## 데몬 스레드 (Daemon Thread)

데몬 스레드란 JVM 종료 시 자동으로 강제 종료합니다.
그래서 언제든지 죽어도 상관없는 작업에 사용합니다.
예를 들면 가비지 컬렉터(Garbage Collector),  JMX 에이전트(JMX Agent) 등이 있습니다.

```java
thread.setDaemon(true);
```

반대로 Non-Daemon Thread가 실행 중인 경우 JVM은 종료되지 않습니다.
기본적으로 개발자가 새로 생성하는 스레드는 Non-Daemon Thread입니다.
메인 스레드(Main Thread)도 대표적인 Non-Daemon Thread입니다.

```java
thread.setDaemon(false);
```

```java
// java.lang.Thread
/* Whether or not the thread is a daemon thread. */
private boolean daemon = false;
```

## 스레드 덤프 분석 도구

저는 주로 스레드 간 교착 현상(deadlock)이나
단일 스레드의 병목 현상이 의심될 때 사용합니다.
이 외의 다양한 상황에서도 스레드 덤프를 확인해 볼 수 있습니다.[^1]

### jstack

스레드 스택(Java Thread Stack)을 확인할 수 있는 CLI 도구입니다.

```sh
jstack -l ${PID} > thread_dump.txt
```

### VisualVM

VisualVM을 사용하면 실시간으로 스레드 스택의 상태를 확인할 수 있습니다.

![visualvm-tomcat-threads](/images/java/jvm-monitoring/visualvm-tomcat-threads.png)

*VisualVM에서 확인한 Thread Stack. [OkHttp ConnectionPool이 여러 개 생긴 것으로 문제가 발생](/posts/java/too-many-open-files/)했었습니다.*

공식 홈페이지에서 다운로드한 후 `bin` 디렉토리의 실행 파일을 실행합니다.
실행하면 로컬 환경의 모든 JVM 프로세스를 확인할 수 있습니다.

```sh
bin/visualvm
```

IntelliJ 플러그인 [VisualVM Launcher](https://plugins.jetbrains.com/plugin/7115-visualvm-launcher)도 있습니다.
기본적으로 실행했을 때 모든 JVM 프로세스를 확인할 수 있어서
VisualVM을 사용하는 데에 큰 불편함이 없었습니다.

# 힙 덤프 (Heap Dump)

힙 덤프는 JVM 힙의 모든 Object를 담은 스냅샷입니다.[^2]

## OutOfMemoryError

JVM 실행 시 아래 옵션을 추가하면 `OutOfMemoryError` 발생으로 JVM이 종료될 때 힙 덤프를 생성합니다.

```sh
-XX:+HeapDumpOnOutOfMemoryError
```

`-XX:HeapDumpPath` 옵션을 생략하면 기본적으로
JVM 프로세스를 실행시킨 곳에 `java_pid<pid>.hprof` 라는 이름으로 파일이 생성됩니다.[^3]

`-XX:+PrintClassHistogramAfterFullGC`, `-XX:+PrintClassHistogramBeforeFullGC` 등의 옵션으로
Full GC 전후의 메모리 상태를 간략히 덤프할 수도 있습니다.

## 힙 덤프 분석 도구

`OutOfMemoryError`가 발생한 게 아니라면 `jmap`을 사용해서 힙 덤프를 확인할 수 있습니다.

```shell
# jmap -dump:format=b,file=/path/app.hprof ${PID}
jmap -dump:file=/path/app.hprof ${PID}
Dumping heap to /path/app.hprof ...
Heap dump file created

> file /path/app.hprof
app.hprof: Java HPROF dump, created Tue May 17 01:15:39 2022
```

### Eclipse Memory Analyzer

[MAT(Eclipse Memory Analyzer)](https://www.eclipse.org/mat/)는 힙 덤프를 분석할 수 있게 도와주는 프로그램입니다.

- JDK를 찾지 못하는 경우 경로를 직접 설정해야 합니다.

```shell
# ${MAT_HOME}/MemoryAnalyzer.ini
-vm
${JAVA_HOME}/bin

# -vmargs 보다 위에 추가해야 합니다.
-vmargs
...
```

기본 Heap Size는 `1024m` 입니다.
Heap Dump 파일이 이보다 큰 경우 Parsing할 때 아래와 같은 에러가 발생합니다.

```sh
An internal error occurred during:
    "Parsing heap dump from '/path/java_pid1234.hprof'".
Java heap space
```

JVM 옵션으로 메모리를 확장하면 이를 피할 수 있습니다.

```sh
# ${MAT_HOME}/MemoryAnalyzer.ini
-vmargs
#-Xmx1024m
-Xms6g
-Xmx6g
```

### VisualVM

[VisualVM](https://visualvm.github.io/download.html)은 애플리케이션을 **실시간으로 분석**하는 데 주로 사용합니다.

```sh
# $VISUALVM_HOME/etc/visualvm.conf
# Default location of JDK:
#
# It can be overridden on command line by using --jdkhome <dir>
# Be careful when changing jdkhome.
# There are two VisualVM launchers for Windows (32-bit and 64-bit) and
# installer points to one of those in the VisualVM application shortcut
# based on the Java version selected at installation time.
#
#visualvm_jdkhome="/path/to/jdk"
visualvm_jdkhome="$JAVA_HOME"
```

```sh
# 실행
./bin/visualvm
```

미리 저장된 힙 덤프를 간략히 확인할 수도 있습니다. (`File > Load > *.hprof`)
하지만 기능이 더 다양한 [MAT](#eclipse-memory-analyzer-mat)가 있기 때문에
VisualVM은 주로 실시간으로 확인하는 용도로 사용합니다.

![visualvm-heap-dump](/images/java/jvm-monitoring/visualvm-heap-dump.png)

*VisuamVM에서 확인한 Heap Dump*

Remote에서 모니터링하기 위해서는 JVM 애플리케이션에 JMX 옵션을 추가해야 합니다.
[Apache Tomcat](https://archive.apache.org/dist/tomcat/)을 사용한다면 아래와 같이 추가합니다.

```sh
# Tomcat 다운로드
curl -LO https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.41/bin/extras/catalina-jmx-remote.jar
```

```sh
${CATALINA_HOME}/bin/catalina.sh version
```

```sh
${CATALINA_HOME}/bin/catalina.sh start \
  -Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.local.only=false \
  -Dcom.sun.management.jmxremote.port=1099 \
  -Dcom.sun.management.jmxremote.rmi.port=1099 \

  -Dcom.sun.management.jmxremote.ssl=false \

  -Dcom.sun.management.jmxremote.authenticate=false \
  # -Dcom.sun.management.jmxremote.authenticate=true \
  # -Dcom.sun.management.jmxremote.password.file=$CATALINA_BASE/conf/jmxremote.password \
  # -Dcom.sun.management.jmxremote.access.file=$CATALINA_BASE/conf/jmxremote.access \

  # -Djava.rmi.server.hostname=${REAL_HOST} \
  -Djava.rmi.server.hostname=255.255.255.255 \

  -jar
```

이후 VisualVM에서 다음과 같이 설정합니다.

- `File > Add JMX Connection`

![File > Add JMX Connection](/images/java/jvm-monitoring/visualvm-file-add-jmx-connection.png)

JVM 옵션으로 추가한 RMI(Remote Method Invocation) `HOST`와 `PORT`를 입력합니다.

![Setting JMX Connection](/images/java/jvm-monitoring/visualvm-setting-jmx-connection.png)

추가하면 다음과 같이 스레드를 실시간으로 모니터링 할 수 있습니다.
스레드와 힙 메모리의 스냅샷을 저장할 수도 있습니다.

![Setting JMX Connection](/images/java/jvm-monitoring/visualvm-jmx-monitoring.png)

여러 호스트를 동시에 모니터링 할 수도 있습니다.

![Setting JMX Connection](/images/java/jvm-monitoring/visualvm-double-jmx-monitoring.png)

# 가비지 컬렉션 (Garbage Collection)

GC(Garbage Collection)는 JVM이 사용하지 않는 메모리를 자동으로 회수하는 프로세스입니다.
GC 모니터링이란 JVM이 어떻게 GC를 수행하고 있는지 알아내는 과정을 말합니다.

## GC 모니터링 도구

[jps](https://docs.oracle.com/en/java/javase/24/docs/specs/man/jps.html)는
JVM Process Status를 출력하는 명령어로
현재 머신에서 실행중인 JVM 프로세스의 PID나 실행 옵션을 확인할 수 있습니다.

```sh
jps -v
# ${PID} Bootstrap -Djava...
```

[jstat](https://docs.oracle.com/en/java/javase/17/troubleshoot/diagnostic-tools.html#GUID-370616DE-AB80-49EB-9802-C278AF75AAE8)은
HotSpot JVM에 있는 모니터링 도구입니다.
데몬 형태인 [jstatd](https://docs.oracle.com/en/java/javase/17/troubleshoot/diagnostic-tools.html#GUID-469DA1E0-66B6-47F7-A937-18826B3BBE67)도 있습니다.

```shell
# 1초마다 gc 확인
jstat -gc <PID> 1000
```

```shell
jstat -options
```

| 옵션           | 기능                                                                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **gc**         | 각 힙(heap) 영역의 현재 크기와 현재 사용량(Eden 영역, Survivor 영역, Old 영역등), 총 GC 수행 횟수, 누적 GC 소요 시간.                             |
| **gccapactiy** | 각 힙 영역의 최소 크기(ms), 최대 크기(mx), 현재 크기, 각 영역별 GC 수행 횟수를 알 수 있는 정보. 단, 현재 사용량과 누적 GC 소요 시간은 알 수 없다. |
| **gccause**    | gcutil 옵션이 제공하는 정보와 함께 마지막 GC 원인과 현재 발생하고 있는 GC의 원인을 알 수 있는 정보.                                               |
| gcnew          | New 영역에 대한 GC 수행 정보                                                                                                                      |
| gcnewcapacity  | New 영역의 크기에 대한 통계 정보                                                                                                                  |
| gcold          | Old 영역에 대한 GC 수행 정보                                                                                                                      |
| gcoldcapacity  | Old 영역의 크기에 대한 통계 정보                                                                                                                  |
| gcpermcapacity | Permanent 영역에 대한 통계 정보                                                                                                                   |
| **gcutil**     | 각 힙 영역에 대한 사용 정도를 백분율로 표시. 아울러 총 GC 수행 횟수와 누적 GC 시간을 알 수 있다.                                                  |

더 자세한 내용은 NAVER D2의 [Garbage Collection 모니터링 방법](https://d2.naver.com/helloworld/6043)을 참고하세요.

### Visual GC

JVM이 어떻게 GC를 수행하고 있는지 확인할 수 있습니다.

![VisualGC Plugin](/images/java/jvm-monitoring/visualgc-plugin.png)

*VisualVM의 Tools > Plugins에서 다운로드 할 수 있다.*

![visualgc-with-visualvm](/images/java/jvm-monitoring/visualgc-with-visualvm.png)

# 함께 사용하는 도구들

## JDK Tools

- [JDK Tools and Utilities](https://docs.oracle.com/javase/8/docs/technotes/tools/index.html) | Java 8
- [Diagnostic Tools](https://docs.oracle.com/en/java/javase/24/troubleshoot/diagnostic-tools.html) | Java 24

![Java Platform Standard Edition 8 Documentation](/images/java/java-conceptual-diagram.png)

*[Java Platform Standard Edition 8 Documentation](https://docs.oracle.com/javase/8/docs/)*

- `jcmd` 성능 관련 카운터 조회

```sh
jcmd ${PID} PerfCounter.print
# java.threads.daemon=42
# java.threads.live=49
# java.threads.livePeak=52
# java.threads.started=3951
# ...
```

- `jmap` JVM Heap 조회

```sh
jmap -heap ${PID}
```

```sh
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

- `jhat` Java Heap Analyzer Tool
  - JDK 9에서 제거되었습니다.

```sh
jhat -J-Xmx6g -port 7000 /path/app.hprof
```

## Datadog

- [Enabling the Java Profiler](https://docs.datadoghq.com/tracing/profiler/enabling/java/)

```shell
-Ddd.profiling.enabled=true \
-XX:FlightRecorderOptions=stackdepth=256
```

## 이 외의 도구들

- [JDK Mission Control](https://www.oracle.com/java/technologies/jdk-mission-control.html) | Oracle
- [Java Profiler Features](https://www.yourkit.com/java/profiler) | YourKit
- [JProfiler](https://www.ej-technologies.com/products/jprofiler/overview.html) (유료)

# 더 읽을거리

- JMX
  - [JSR 3: JMX Specification](https://www.jcp.org/en/jsr/detail?id=3)
  - [Java Management Extensions (JMX) Technology](https://www.oracle.com/java/technologies/javase/javamanagement.html) | Oracle
    - [JMX (Java Management Extensions)](https://docs.oracle.com/en/java/javase/24/jmx/introduction-jmx-technology.html) | Oracle
  - [Basic Introduction to JMX](https://www.baeldung.com/java-management-extensions) | Baeldung
    - [Remote Monitoring with VisualVM and JMX](https://www.baeldung.com/visualvm-jmx-remote) | Baeldung
  - [Key metrics for monitoring Tomcat](https://www.datadoghq.com/blog/tomcat-architecture-and-performance/) | Datadog
  - [<전문가를 위한 스프링 5> (15장 애플리케이션 모니터링)](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9791160508864)
- Thread Stack
  - [How to Read a Thread Dump](https://dzone.com/articles/how-to-read-a-thread-dump) | DZone
  - [JVM stack과 frame](https://johngrib.github.io/wiki/jvm-stack/) | 기계인간 John Grib
- Heap Memory
  - [하나의 메모리 누수를 잡기까지](https://d2.naver.com/helloworld/1326256) | NAVER D2
  - [도움이 될수도 있는 JVM memory leak 이야기](https://web.archive.org/web/20190601030848/http://woowabros.github.io/tools/2019/05/24/jvm_memory_leak.html) | 우아한 형제들
  - [자바 애플리케이션 성능 튜닝의 도(道)](https://d2.naver.com/helloworld/184615) | NAVER D2
  - [Java 애플리케이션 트러블 슈팅](https://d2.naver.com/helloworld/1286587) | NAVER D2
  - [Java Memory Analysis](https://kwonnam.pe.kr/wiki/java/memory) | 권남
  - [JVM Crash 문제 해결하기](https://web.archive.org/web/20201204225836/https://www.whatap.io/ko/blog/28/) | 와탭
  - [자바 메모리누수(with 힙덤프) 분석하기](https://web.archive.org/web/20191009034727/http://honeymon.io/tech/2019/05/30/java-memory-leak-analysis.html) | honeymon
  - [Java Heap Dump 를 이용한 문제 해결](https://web.archive.org/web/20250408135610/https://lng1982.tistory.com/352) | 탁구치는 개발자
  - [JVM의 default Heap Size가 궁금하세요?](https://web.archive.org/web/20250408135653/https://sarc.io/index.php/java/1092-jvm-default-heap-size) | 삵(sarc)
  - [생애 첫 Heap 메모리 분석기](https://perfectacle.github.io/2019/04/28/heap-memory-analytics-with-eclipse-mat/) | 양권성
  - [Eclipse Memory Analyzer 소개](https://web.archive.org/web/20250408135840/https://spoqa.github.io/2012/02/06/eclipse-mat.html) | spoqa
  - [Eclipse MAT — Incoming, Outgoing References](https://dzone.com/articles/eclipse-mat-incoming-outgoing-references) | DZone
- Garbage Collection
  - [<JVM 밑바닥까지 파헤치기>](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788966264414) | 저우즈밍
  - [<자바 성능을 결정짓는 코딩 습관과 튜닝 이야기>](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788979145229) | 이상민
    - [Garbage Collection 모니터링 방법](https://d2.naver.com/helloworld/6043) | NAVER D2
    - [Garbage Collection과 Statement Pool](https://d2.naver.com/helloworld/4717) | NAVER D2
      - [DBCP 사용시 poolPreparedStatements 속성이 성능에 미치는 영향](https://web.archive.org/web/20160114012952/https://zzikjh.tistory.com/entry/DBCP-사용시-poolPreparedStatements-속성이-성능에-미치는-영향)

## 기타

- [Java 프로파일링 도구](https://blog.naver.com/pcmola/222064546600) | 메이커 꾸러기
- [OpenJDK 9: Life Without HPROF and jhat](https://www.infoq.com/news/2015/12/OpenJDK-9-removal-of-HPROF-jhat/) | InfoQ
- [Everything I Ever Learned About JVM Performance Tuning at Twitter](https://youtu.be/8wHx31mvSLY) | Attila Szegedi

[^1]: [스레드 덤프 분석하기](https://d2.naver.com/helloworld/10963) | NAVER D2
[^2]: [Java VisualVM - Browsing a Heap Dump](https://docs.oracle.com/javase/8/docs/technotes/guides/visualvm/heapdump.html) | Oracle
[^3]: [Java HotSpot VM Command-Line Options](https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/clopts001.html) | Oracle
