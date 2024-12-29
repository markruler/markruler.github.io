---
date: 2022-11-14T00:38:00+09:00
title: "Jenkins Workspace 동시성 문제"
description: "WorkspaceList"
featured_image: "/images/ci/jenkins-logo.webp"
images: ["/images/ci/jenkins-logo.webp"]
socialshare: true
tags:
  - ci
  - cd
  - jenkins
  - devops
categories:
  - blog
---

# 개요

Jenkins Pipeline을 사용해서 잡 스케줄러를 실행하기 위해
[triggers](https://www.jenkins.io/doc/book/pipeline/syntax/#triggers) directive를 사용했습니다.

```groovy
pipeline {
    agent any

    triggers {
        cron("* * * * *") // HERE
    }

    stages {...}

    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [
                        [pattern: '.git/**', type: 'EXCLUDE'],
                        [pattern: '.gitignore', type: 'EXCLUDE'],
                        [pattern: '.meta/**', type: 'EXCLUDE'],
                    ]
            )
        }
    }
}
```

해당 Job은 빌드 간 메타데이터(`.meta/`)를 공유해야 했기 때문에
[cleanWs](https://plugins.jenkins.io/ws-cleanup/) 플러그인에서도
`.git` 디렉토리와 함께 삭제되지 않도록 설정했습니다.

하지만 무슨 이유인지 메타데이터가 간헐적으로 누락되었고,
작업도 원하는대로 동작하지 않고 있었습니다.

# WorkspaceList

Jenkins에서 Job을 실행할 경우 말그대로 작업 공간을 위한
Workspace(`$JENKINS_HOME/workspace`) 디렉토리가 생성됩니다.

```java
// hudson.slaves.WorkspaceList
public synchronized Lease allocate(@NonNull FilePath base, Object context) throws InterruptedException {
    for (int i = 1; ; i++) {
        FilePath candidate = i == 1 ? base : base.withSuffix("@" + i);
        Entry e = inUse.get(candidate.getRemote());
        if (e != null && !e.quick && e.context != context)
            continue;
        return acquire(candidate, false, context);
    }
}
```

Jenkins는 Workspace 목록을 별도의 메타데이터 파일에 저장해서 관리하지 않습니다.
Jenkins 런타임의 [WorkspaceList 객체](https://github.com/jenkinsci/jenkins/blob/jenkins-2.374/core/src/main/java/hudson/slaves/WorkspaceList.java)에
전체 Workspace 목록을 저장합니다.

```java
// hudson.slaves.WorkspaceList
/**
 * Used by {@link Computer} to keep track of workspaces that are actively in use.
 */
public final class WorkspaceList {

    private static final class AllocationAt extends Exception {...}
    
    /**
      * Book keeping for workspace allocation.
      */
    public static final class Entry {...}
    
    /**
     * Represents a leased workspace that needs to be returned later.
     */
    public abstract static class Lease implements /*Auto*/Closeable {...}

    // ...
}
```

## 문제

만약 파이프라인에서 `Concurrent Build` 옵션을 허용한 채
여러 개의 빌드를 동시에 실행하면 간혹 `job_name` workspace에서 실행되지 않고
`job_name@2` 에서만 실행되는 경우가 있습니다.
그런데 메타데이터 파일을 공유해서 사용해야 하는 경우
`job_name` workspace에서 실행되기를 보장해야 합니다.

## 해결

**Jenkins Master 프로세스를 재시작**해서 `WorkspaceList`를 초기화하거나
**새로운 이름의 Job을 생성**하면 새로운 이름의 workspace에서 빌드할 수 있습니다.
이후 [스레드 안전성](https://en.wikipedia.org/wiki/Thread_safety)을 보장하기 위해
`Concurrent Build` 옵션을 허용하지 않은 채 빌드합니다.

```groovy
pipeline {
    agent any

    triggers {
        cron("* * * * *")
    }
    
    // https://www.jenkins.io/doc/book/pipeline/syntax/#options
    options {
        // cron 설정에 따라 빌드 간 겹치지 않도록 타임아웃을 설정합니다.
        timeout(time: 50, unit: 'SECONDS')
    
        // 빌드 스케줄이 2개 생성되면 'job_name', 'job_name@2' workspace가 생성되고
        // metadata를 각각 관리하게 됩니다. abortPrevious 값을 true로 설정하면
        // 이미 빌드 중인 프로세스와 겹쳐서 'job_name@2' workspace가 생성되더라도
        // 이후 빌드부터는 기존 빌드 프로세스가 제거되고 'job_name' workspace에서 실행됩니다.
        disableConcurrentBuilds(abortPrevious: true)
    }

    stages {...}
}
```

# timeout과 cron

Crontab(Unix의 Job Scheduler)처럼 Jenkins는 `cron` 설정을 통해 잡 스케줄러를 만들 수 있습니다.
Jenkins `cron`의 최소 간격은 1분(`* * * * *`)입니다.

## 문제

`timeout` 설정도 `cron` 설정과 같이 1분으로 두면 timeout abort 되기 전
`job_name@2` workspace 디렉토리가 생성되고 별도의 메타데이터를 갖는 Job이 실행될 수 있습니다.

## 해결

만약 `cron` 간격을 1분으로 설정했다면 `timeout`을 50초로 설정하는 등 차이를 둡니다. (55초는 살짝 겹쳤습니다...)

```groovy
timeout(time: 50, unit: 'SECONDS')
```
