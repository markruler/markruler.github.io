---
date: 2023-03-20T21:58:00+09:00
title: "Too many open files"
description: "소켓 '파일'을 몰랐을 때의 위험"
featured_image: "/images/java/too-many-open-files/swimming-pool-lane-pattern-stable-diffusion.jpg"
images: ["/images/java/too-many-open-files/swimming-pool-lane-pattern-stable-diffusion.jpg"]
socialshare: true
tags:
  - socket
  - linux
  - file
categories:
  - linux
---

> 커버 이미지 출처: [Stable diffusion](https://stablediffusionweb.com/) "swimming pool lane pattern"

# 증상

Spring framework로 만든 웹 애플리케이션에서 비동기로 HTTP 요청하는 기능을 개발하고 있었다.
요구 사항을 위해 동시에 1,000개 이상의 요청을 보낼 때가 있는데, `Too many open files` 에러가 발생했다.
작업 PC(Ubuntu 22.04)에서 문제 없이 동작하던 프로그램이
IDC에 위치한 서버(CentOS 7)에서는 `OutOfMemoryError`가 발생하면서 동작하지 않았다.

```sh
java.lang.OutOfMemoryError: unable to create new native thread
...
java.util.concurrent.ExecutionException: com.markruler.RuntimeException: request error
...
Caused by: java.net.SocketException: Too many open files
```

`SocketException`인데 `Too many open files`? **이게 OOM**?
이해되지 않았다.

문제를 정의하기 위해 먼저 이해부터 해야 했다.

# 분석

## Too many open files

근본적인 원인이 되는 `Too many open files`는
프로세스에서 열려 있는 파일 디스크립터의 수가 시스템 제한을 초과하면 발생한다.
로컬 환경(Ubuntu 22.04)에서 먼저 테스트해봤다.

```sh
# 우선 별도의 세션을 연다.
bash
```

`prlimit`를 이용해 현재 프로세스의 파일 디스크립터 제한을 확인한다.

```sh
prlimit -n
```

기본적으로 **4096**이 설정되어 있었다.

```sh
RESOURCE DESCRIPTION              SOFT    HARD UNITS
NOFILE   max number of open files 4096 1048576 files
```

`ulimit`를 이용해 열 수 있는 파일 디스크립터 수를 제한한다.

```sh
ulimit -n 0
```

그리고 `cat` 명령어를 실행하면 `Too many open files`가 발생한다.

```sh
cat /etc/os-release
# bash: start_pipeline: pgrp pipe: Too many open files
# ls: error while loading shared libraries: libselinux.so.1: cannot open shared object file: Error 24
```

다시 나갔다가 새로운 세션을 연다.
limit을 4로 설정하면 파일 내용이 정상적으로 출력된다.
하지만 에러가 발생한다.

```sh
ulimit -n 4
```

```sh
cat /etc/os-release
# bash: start_pipeline: pgrp pipe: Too many open files
# PRETTY_NAME="Ubuntu 22.04.2 LTS"
# ...
```

5로 설정하면 에러가 발생하지 않고 정상적으로 출력된다.

```sh
ulimit -n 5
```

```sh
cat /etc/os-release
# PRETTY_NAME="Ubuntu 22.04.2 LTS"
# ...
```

이유가 무엇일까?

## 파일 디스크립터 (File descriptor)

리눅스에서는 파일을 열면(open) 파일 디스크립터를 반환한다.
반환된 파일 디스크립터는 `fd_array`의 인덱스를 나타내며, 파일을 읽고 쓰는데 사용된다.

```c
// https://github.com/torvalds/linux/blob/v6.2/include/linux/sched.h#L1088
stuct task_struct {
    ...
  /* Filesystem information: */
  struct fs_struct    *fs;

  /* Open file information: */
  struct files_struct *files;
  ...
};
```

```c
// https://github.com/torvalds/linux/blob/v6.2/include/linux/fdtable.h#L49
/*
 * Open file table structure
 */
struct files_struct {
  ...
  struct file __rcu * fd_array[NR_OPEN_DEFAULT];
};
```

`fd_array` 배열의 첫 번째 인덱스[0]는 표준 입력(`stdin`), 두 번째 인덱스[1]는 표준 출력(`stdout`).
세 번째 인덱스[2]는 표준 에러(`stderr`)다.
네 번째 인덱스[3]부터 어떤 작업을 수행하는 프로세스가 필요한 파일을 가리킨다.
그래서 `ulimit -n 4`로 설정하면 정상적으로 `cat`의 출력이 나오는 것이다.

다시 문제로 돌아가서 그럼 `java.net.SocketException: Too many open files`는 왜 발생했던 걸까?

Linux에서는 Socket도 파일로 취급한다.
그래서 소켓을 열 때마다 파일 디스크립터가 증가하고,
시스템 제한을 초과하면 `Too many open files` 에러가 발생하는 것이다.

문제가 발생했던 서버의 시스템 제한을 확인해봤다.

```sh
prlimit -n
```

SOFT 값이 1024로 1024개의 파일 디스크립터를 열 수 있다.

```sh
RESOURCE DESCRIPTION              SOFT    HARD UNITS
NOFILE   max number of open files 1024 1048576 files
```

이 제한을 늘리면 문제가 해결될 것 같았다.
그런데 다시 생각해보면 1024 만큼의 요청이 발생할 필요 없는 서버였다.
갑자기 요청이 늘어난 원인이 무엇일까?

혼자가 아닌 함께 개발할 때,
내가 사용하려는 인터페이스가 이미 팀 내에서 통용되어 사용되고 있다면
해당 소스 코드를 복사해서 사용하는 경우가 많았다.
`OkHttpClient`도 그대로 복사해서 사용했었다.

```java
OkHttpClient client = new OkHttpClient();
```

하지만 `OkHttpClient`를 생성자로 생성하면 OkHttp ConnectionPool 스레드가 생성된다.
파일 개수 제한이 4096인 로컬 환경에서 4,000개의 요청을 보내도록 테스트해봤다.

[VisualVM](https://markruler.github.io/posts/java/jvm-monitoring/#visualvm)을 사용해서 스레드를 확인해봤다.

![visualvm-bad-okhttp-connectionpool](/images/java/too-many-open-files/visualvm-bad-okhttp-connectionpool.png)

OkHttp ConnectionPool의 스레드가 4,000개가 채 못 되어 `java.net.SocketException: Too many open files`이 발생했다.

# 문제 정의

실제 문제는 불필요한 스레드가 과다 생성되어 발생한 것이다.
**이 에러가 특히 위험한 이유는 시스템 제한을 초과했기 때문에 동일한 머신에 있는 다른 프로세스에도 영향을 준다는 것이다.**

# 해결

`OkHttp ConnectionPool`을 재사용하기 위해 Spring Bean으로 등록했다.
**이는 [공식 문서](https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/)에도 있는 내용이다.**

> **OkHttpClients Should Be Shared**
>\
> OkHttp performs best when you create a single OkHttpClient instance
> and reuse it for all of your HTTP calls.
> This is because each client holds its own connection pool and thread pools.
> Reusing connections and threads reduces latency and saves memory.
> Conversely, creating a client for each request wastes resources on idle pools.

```java
import okhttp3.OkHttpClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OkHttpConfig {

    @Bean
    public OkHttpClient okHttpClient() {
        return new OkHttpClient();
    }

}
```

```java
import okhttp3.OkHttpClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class MyHttpClient {

    private final OkHttpClient httpClient;

    @Autowired
    public MyHttpClient(OkHttpClient httpClient) {
        this.httpClient = httpClient;
    }

    // ...
}
```

다시 4,000개의 요청을 보내도록 테스트했다.

![visualvm okhttpclient bean](/images/java/too-many-open-files/visualvm-okhttpclient-bean.png)

더 이상 불필요하게 스레드가 늘어나지 않았고,
스레드를 새로 생성할 필요도 없으니 성능 또한 개선되었다.
(평균 10초 → 3초)

시스템 제한 설정을 변경할 필요 없이
`Too many open files` 에러도 발생하지 않았다.