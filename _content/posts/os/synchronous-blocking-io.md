---
draft: true
socialshare: true
date: 2025-01-28T00:03:00+09:00
lastmod: 2025-01-28T00:03:00+09:00
title: "Synchronous/Asynchronous - Blocking/Non-Blocking 입출력"
description: "실행할 수 있는 Java 코드로 직접 확인합니다"
featured_image: "/images/os/synchronous-blocking-io/figure1.png"
images: ["/images/os/synchronous-blocking-io/figure1.png"]
tags:
  - network
categories:
  - wiki
---

> 실행할 수 있는 Java 코드: [markruler/synchronous-blocking](https://github.com/markruler/synchronous-blocking)

> 이미지 출처: *[IBM](https://developer.ibm.com/articles/l-async/)*

![Figure 1. Simplified matrix of basic Linux I/O models](/images/os/synchronous-blocking-io/figure1.png)

# 개요

Syncronous/Asynchronous, Blocking/Non-Blocking 입출력에 대해 알아봅니다.
웹 서버-클라이언트 환경에서는 브라우저나 Tomcat과 같은 웹 서버로 인해 4가지 경우에 대해서 구현하기가 어렵습니다.
기본적으로 해당 프로그램들이 멀티스레드나 비동기 처리를 먼저 처리해주기 떄문이죠.
여기서는 간단한 프로그램을 작성해서 이해해보겠습니다.

# 개념 설명

## 동기(Synchronous)와 비동기(Asynchronous)

호출된 함수의 작업 완료 여부를 함수가 체크하는가?

**동기(Synchronous)**
호출된 함수의 작업 완료 여부를 호출한 함수가 체크합니다.
예를 들어, 파일을 읽는 작업이 완료될 때까지 프로그램이 대기하는 경우가 이에 해당합니다.

**비동기(Asynchronous)**
호출된 함수의 작업 완료 여부를 신경 쓰지 않습니다.
별도의 프로세스 혹은 스레드에서 실행하고 완료하면 호출한 쪽에 리턴합니다.
예를 들어, 비동기 HTTP 요청을 보내고, 응답을 기다리는 동안 다른 작업을 수행하는 경우가 이에 해당합니다.

## 블로킹(Blocking)과 논블로킹(Non-Blocking)

호출된 함수가 리턴할 때까지 대기하는가? 아니면 제어권을 넘겨주고 다른 일을 할 수 있도록 하는가?

**블로킹(Blocking)**
호출된 함수가 작업이 완료될 때까지 제어권을 가지고, 해당 스레드가 대기합니다.
예를 들어, 파일을 읽는 동안 해당 스레드는 다른 작업을 수행할 수 없습니다.

**논블로킹(Non-Blocking)** 작업이 진행되는 동안 스레드가 대기하지 않고 다른 작업을 수행할 수 있습니다.
예를 들어, 파일을 읽는 동안 다른 작업을 계속 수행할 수 있으며, 파일 읽기가 완료되면 결과를 처리하는 방식입니다.

# 4개의 케이스

## Asynchronous-Blocking

![Asynchronous-Blocking](/images/os/synchronous-blocking-io/asynchronous-blocking-io.png)

Java에서 Future 혹은 Javascript에서 async-await를 사용하는 경우가 이에 해당합니다.

```java
import java.util.concurrent.*;

public class AsynchronousBlockingExample {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        System.out.println("비동기 블로킹 시작");

        ExecutorService executor = Executors.newSingleThreadExecutor();

        // 비동기 작업 실행
        Future<Integer> future = executor.submit(() -> {
            Thread.sleep(2_000);
            return 42;
        });

        System.out.println("다른 작업 수행 중...");
        int result = future.get(); // 결과를 기다리며 Blocking
        System.out.println("결과: " + result);

        executor.shutdown();
    }
}
```

## Asynchronous-NonBlocking

![Asynchronous-NonBlocking](/images/os/synchronous-blocking-io/asynchronous-non-blocking-io.png)

```java
import java.util.concurrent.*;

public class AsynchronousNonBlockingExample {
    public static void main(String[] args) {
        System.out.println("비동기 논블로킹 시작");

        // 비동기 작업 실행
        CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(2_000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "Hello, World!";
        }).thenAccept(result -> {
            System.out.println("결과: " + result);
        });

        System.out.println("Main thread 다른 작업 수행 중...");

        try {
            System.out.println("Sleeping...");
            Thread.sleep(3_000); // 메인 스레드 종료 방지
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

## Synchronous-Blocking

![Synchronous-Blocking](/images/os/synchronous-blocking-io/synchronous-blocking-io.png)

```java
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;

public class SynchronousBlockingExample {
    public static void main(String[] args) throws IOException {
        System.out.println("동기 블로킹 시작");

        // example.txt 파일 생성
        Path path = Path.of("example.txt");
        String content = "test1\ntest2\n";
        try (FileOutputStream fos = new FileOutputStream(path.toFile())) {
            fos.write(content.getBytes());
        }

        // InputStream이 블로킹되며 파일 읽기 완료를 기다림
        try (FileInputStream fis = new FileInputStream("example.txt")) {
            int data;
            while ((data = fis.read()) != -1) { // 데이터가 올 때까지 대기
                System.out.print((char) data);
            }
        }
        System.out.println("\n동기 블로킹 종료");

        Files.deleteIfExists(path);
    }
}
```

## Synchronous-NonBlocking

![Synchronous-NonBlocking](/images/os/synchronous-blocking-io/synchronous-non-blocking-io.png)

```java
import java.nio.channels.FileChannel;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * 작업의 완료를 직접 확인하면서도(Sync),
 * 작업이 준비되지 않았을 때 블로킹되지 않고(Non-blocking) 다른 작업을 수행할 수 있습니다.
 */
public class SynchronousNonBlockingExample {
    private static String getCurrentThreadInfo() {
        Thread currentThread = Thread.currentThread();
        return String.format("[%s/%d]", currentThread.getName(), currentThread.getId());
    }

    public static void main(String[] args) throws IOException {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        System.out.printf("%s [%s] 동기 논블로킹 시작%n", 
            getCurrentThreadInfo(), LocalTime.now().format(formatter));

        // 두 개의 파일을 동시에 처리
        Path path1 = Paths.get("file1.txt");
        Path path2 = Paths.get("file2.txt");

        // 줄 번호가 있는 내용 생성
        String content1 = IntStream.range(0, 10)
                .mapToObj(i -> String.format("[%02d] 파일 1의 내용", i))
                .collect(Collectors.joining("\n"));
        String content2 = IntStream.range(0, 10)
                .mapToObj(i -> String.format("[%02d] 파일 2의 내용", i))
                .collect(Collectors.joining("\n"));

        // UTF-8로 테스트용 파일 생성
        Files.writeString(path1, content1, StandardCharsets.UTF_8);
        Files.writeString(path2, content2, StandardCharsets.UTF_8);

        // 두 파일을 동시에 읽기 위한 채널과 버퍼 준비
        FileChannel channel1 = FileChannel.open(path1, StandardOpenOption.READ);
        FileChannel channel2 = FileChannel.open(path2, StandardOpenOption.READ);
        ByteBuffer buffer1 = ByteBuffer.allocate(100);
        ByteBuffer buffer2 = ByteBuffer.allocate(100);

        int totalRead1 = 0, totalRead2 = 0;

        while (totalRead1 != -1 || totalRead2 != -1) {
            // 첫 번째 파일 읽기 시도
            if (totalRead1 != -1) {
                totalRead1 = channel1.read(buffer1);
                if (buffer1.position() > 0) {
                    buffer1.flip();
                    String content = StandardCharsets.UTF_8.decode(buffer1).toString();
                    System.out.printf("%s [%s] 파일1 읽음: %s%n", 
                        getCurrentThreadInfo(), LocalTime.now().format(formatter), content);
                    buffer1.clear();
                }
            }

            // 다른 작업 수행 가능
            System.out.printf("%s [%s] 다른 작업 수행 중...%n", 
                getCurrentThreadInfo(), LocalTime.now().format(formatter));

            // 두 번째 파일 읽기 시도
            if (totalRead2 != -1) {
                totalRead2 = channel2.read(buffer2);
                if (buffer2.position() > 0) {
                    buffer2.flip();
                    String content = StandardCharsets.UTF_8.decode(buffer2).toString();
                    System.out.printf("%s [%s] 파일2 읽음: %s%n", 
                        getCurrentThreadInfo(), LocalTime.now().format(formatter), content);
                    buffer2.clear();
                }
            }
        }

        channel1.close();
        channel2.close();

        System.out.printf("%s [%s] 동기 논블로킹 종료%n", 
            getCurrentThreadInfo(), LocalTime.now().format(formatter));

        // 테스트 파일 정리
        Files.deleteIfExists(path1);
        Files.deleteIfExists(path2);
    }
}
```

# 참조

- ChatGPT로 소스 코드 생성
- [Boost application performance using asynchronous I/O](https://developer.ibm.com/articles/l-async/) | IBM
- [Blocking-NonBlocking-Synchronous-Asynchronous](https://homoefficio.github.io/2017/02/19/Blocking-NonBlocking-Synchronous-Asynchronous/) | HomoEfficio
- 개발자 기술 면접 노트 | 이남희
