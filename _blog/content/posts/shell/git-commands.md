---
date: 2021-12-01T23:28:00+09:00
title: "CLI 환경에서 소스 코드 관리하기"
description: "자주 쓰는 Git 명령어"
featured_image: "/images/shell/git-logo-2color.png"
images: ["/images/shell/git-logo-2color.png"]
socialshare: true
tags:
  - git
  - shell
Categories:
  - how-to
---

- [Git Internal](#git-internal)
  - [차이가 아니라 스냅샷](#차이가-아니라-스냅샷)
  - [데이터의 무결성](#데이터의-무결성)
  - [Git 프로젝트의 세 가지 단계](#git-프로젝트의-세-가지-단계)
- [Git directory](#git-directory)
  - [HEAD](#head)
  - [refs](#refs)
  - [info](#info)
  - [objects](#objects)
    - [tree](#tree)
    - [blob (binary large object)](#blob-binary-large-object)
    - [commit](#commit)
    - [tag](#tag)
  - [index](#index)
  - [Hash Function](#hash-function)
  - [config](#config)
- [SCM: Source Code Management](#scm-source-code-management)
- [포셀린(Porcelain) 명령어](#포셀린porcelain-명령어)
  - [init](#init)
  - [clone](#clone)
  - [submodule](#submodule)
  - [subtree](#subtree)
  - [branch](#branch)
    - [xargs](#xargs)
  - [tag](#tag-1)
  - [switch](#switch)
    - [upstream](#upstream)
  - [status](#status)
  - [add](#add)
  - [fetch](#fetch)
  - [commit](#commit-1)
  - [merge](#merge)
  - [pull](#pull)
  - [rebase](#rebase)
    - [squash와 fixup](#squash와-fixup)
  - [cherry-pick](#cherry-pick)
  - [stash](#stash)
    - [How git stash works](#how-git-stash-works)
  - [reset](#reset)
  - [restore](#restore)
  - [revert](#revert)
  - [Git으로 버그 찾기](#git으로-버그-찾기)
    - [blame](#blame)
    - [bisect](#bisect)
  - [show](#show)
  - [log](#log)
    - [Triple Dot(...)](#triple-dot)
  - [reflog: Reference logs](#reflog-reference-logs)
  - [diff](#diff)
  - [push](#push)
- [플러밍(Plumbing) 명령어](#플러밍plumbing-명령어)
  - [rev-parse](#rev-parse)
  - [hash-object](#hash-object)
  - [ls-tree](#ls-tree)
  - [ls-files](#ls-files)
  - [cat-file](#cat-file)
  - [write-tree](#write-tree)
  - [commit-tree](#commit-tree)
  - [read-tree](#read-tree)
  - [update-index](#update-index)
- [Advanced](#advanced)
  - [Git Hooks](#git-hooks)
  - [Garbage Collection](#garbage-collection)
    - [Packfiles](#packfiles)
    - [gc](#gc)
  - [prune](#prune)
- [Git Server](#git-server)
  - [Fork](#fork)
  - [Branch protection rules](#branch-protection-rules)
- [참고](#참고)

> Git의 모든 기능을 지원하는 것은 CLI 뿐이다.
> GUI 프로그램의 대부분은 Git 기능 중 일부만 구현하기 때문에 비교적 단순하다.
> CLI를 사용할 줄 알면 GUI도 사용할 수 있지만 반대는 성립하지 않는다. -
> <[Pro Git](https://git-scm.com/book/en/v2)> Scott Chacon, Ben Straub

# Git Internal

## 차이가 아니라 스냅샷

- [Commits are snapshots, not diffs](https://github.blog/2020-12-17-commits-are-snapshots-not-diffs/)

CVS, Subversion, Perforce, Bazaar 등의 시스템은 각 파일의 변화를 시간순으로 관리하면서 파일들의 집합을 관리한다.

![Storing data as changes to a base version of each file](/images/shell/git/storing-data-as-changes.png)

*[Storing data as changes to a base version of each file](https://git-scm.com/book/en/v2/Getting-Started-What-is-Git%3F)*

Git은 데이터를 스냅샷의 스트림처럼 취급한다. 파일이 달라지지 않았으면 이전 상태의 파일에 대한 링크만 저장한다.

![Storing data as snapshots of the project over time](/images/shell/git/storing-data-as-snapshots.png)

*[Storing data as snapshots of the project over time](https://git-scm.com/book/en/v2/Getting-Started-What-is-Git%3F)*

## 데이터의 무결성

Git에서 데이터를 저장하기 전에 가장 먼저 하는 작업은 Hash function을 사용해서 체크섬을 계산하는 것이다.
그리고 이 체크섬으로 데이터를 관리한다.

왜 데이터의 무결성을 검사해야 할까?
[데이터를 신뢰하기 위해서다](https://www.youtube.com/watch?v=4XpnKHJAok8&t=56m25s).
예를 들어 내가 오늘 작성한 파일이 내일 혹은 10년 뒤에도 같다고 믿을 수 있게 된다.

```bash
$ echo "test" > test.txt
$ git hash-object test.txt
9daeafb9864cf43055ae93beb0afd6c7d144bfa4

# 파일명을 변경하더라도 체크섬은 바뀌지 않는다.
$ mv test.txt test2.md
$ git hash-object test2.md
9daeafb9864cf43055ae93beb0afd6c7d144bfa4

# 내용을 변경하면 체크섬은 바뀐다.
$ echo " " >> test2.md
$ git hash-object test2.md
d698e83c7a0b75a29e815371e584973062b4cab9
```

Git은 SHA-1 알고리즘을 사용하여 체크섬을 구한다.
만든 체크섬은 40자 길이의 16진수 문자열이다.
파일의 내용이나 디렉터리 구조를 이용하여 체크섬을 구한다.

> _[Git을 쓰는 사람들은 언젠가 SHA-1 값이 중복될까 봐 걱정한다.
> 정말 그렇게 되면 어떤 일이 벌어질까?](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-%EB%A6%AC%EB%B9%84%EC%A0%84-%EC%A1%B0%ED%9A%8C%ED%95%98%EA%B8%B0)_

이미 있는 SHA-1 값이 Git 데이터베이스에 커밋되면 새로운 객체라고 해도 이미 커밋된 것으로 생각하고 이전의 커밋을 재사용한다.
그래서 해당 SHA-1 값의 커밋을 Checkout 하면 항상 처음 저장한 커밋만 Checkout 된다.

그러나 해시 값이 중복되는 일은 일어나기 어렵다.
SHA-1 값의 크기는 20 Bytes(160 Bits)다.
해시 값이 중복될 확률이 50%가 되는 데 필요한 객체의 수는 2^80이다.

([2018년부터 SHA-256으로 전환하고 있고](https://lore.kernel.org/git/20180609224913.GC38834@genre.crustytoothpaste.net/), Git 2.29부터 지원하고 있다)

```bash
# 해시 값 앞부분이 중복되지 않으면 checksum은 앞 4자만 있어도 된다.
$ git ls-tree ee85

# 앞부분이 중복된다면 아래와 같은 에러가 발생한다.
ferror: short object ID ee85 is ambiguous
hint: The candidates are:
hint:   ee8597496 commit 2022-01-12 - 제가 작성한 커밋 메시지입니다
hint:   ee85c50d6 tree
hint:   ee8574581 blob
fatal: Not a valid object name ee85

# 몇 글자를 더 입력해주면 정상적으로 동작한다.
$ git ls-tree ee859
```

## Git 프로젝트의 세 가지 단계

Git은 파일을 세 가지 상태로 관리한다.

![The lifecycle of the status of your files](/images/shell/git/lifecycle-file-status.png)

*[The lifecycle of the status of your files](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)*

- Modified - 수정한 파일을 아직 로컬 데이터베이스에 커밋하지 않은 상태다.
- Staged - 현재 수정한 파일을 곧 커밋할 것이라고 표시한 상태다.
  파일을 Stage하면 Git 저장소에 파일을 Blob으로 저장하고 Staging Area에 해당 파일의 체크섬을 저장한다.
  - Tracked - 관리 대상에 있는 파일이다. 이미 스냅샷에 포함되어 있던 파일이다.
  - Untracked - Unmodified, Modified, Staged 상태가 아닌 나머지 파일은 모두 Untracked 파일이다.
    다시 말해서 Staging Area(index)에도 포함되지 않았고 스냅샷으로 저장되어 있지 않은 파일이다.
- Committed - 데이터가 로컬 데이터베이스에 안전하게 저장된 상태다.
  루트 디렉토리와 각 하위 디렉토리의 트리 객체(Object)를 체크섬과 함께 저장소에 저장한다.
  그 후 커밋 객체를 만들고 메타데이터와 루트 디렉터리 트리 객체를 가리키는 포인터 정보를 커밋 객체에 넣어 저장한다.
  그래서 필요하면 언제든지 스냅샷을 다시 만들 수 있다.
- 아래는 커밋의 객체들을 나타낸다.

![A commit and its tree](/images/shell/git/commit-and-its-tree.png)

*[A commit and its tree](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)*

- 아래는 커밋과 이전 커밋들을 나타낸다.

![Commits and their parents](/images/shell/git/commit-and-its-parent.png)

*[Commits and their parents](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)*

파일의 세 가지 상태는 Git 프로젝트의 세 가지 단계와 연결된다.

![Working tree, staging area, and Git directory](/images/shell/git/git-three-step.png)

*[Working tree, staging area, and Git directory](https://git-scm.com/book/en/v2/Getting-Started-What-is-Git%3F#_the_three_states)*

- Working Tree - 프로젝트의 특정 버전을 Checkout 한 것이다.
  Git Directory 안에 압축된 DB에서 파일을 가져와 워킹 트리를 만든다.
- Staging Area - 곧 커밋할 파일에 대한 정보를 담고 있으며 Git Directory 안(`.git/index`)에 저장된다.
  Index라고도 불리지만 Staging Area가 거의 표준이다.
  - `stage`라는 용어는 두루 쓰이기 때문에 한번 생각해 볼 만하다.
    stage는 "과정이나 발전, 성장 등의 단계"라는 뜻을 가지고 있다.
    그래서 "목표로 하는 것의 직전 단계"라고 생각하면 쉽다.
    Git에서의 staging area는 저장소에 커밋되기 직전 단계이고,
    배포 환경에서의 staging 서버는 production 서버에 배포하기 직전 단계에 있는 서버다.

Git으로 하는 일은 기본적으로 아래와 같다.

1. Working Tree에서 파일을 수정한다.
2. Staging Area에 파일을 Stage 해서 커밋할 스냅샷을 만든다.
3. Staging Area에 있는 파일들을 커밋해서 Git Direcoty에 영구적인 스냅샷으로 저장한다.

# Git directory

`.git/`

Git이 프로젝트의 메타데이터와 객체 데이터베이스를 저장하는 곳이다.
description 파일은 기본적으로 GitWeb 프로그램에서만 사용하기 때문에 이 파일은 신경쓰지 않아도 된다.

```bash
$ tree -L 2 .git

.git
├── branches
├── COMMIT_EDITMSG
├── config
├── description
├── FETCH_HEAD
├── HEAD
├── hooks
│   ├── commit-msg.sample
│   ├── prepare-commit-msg.sample
│   ├── pre-push.sample
│   ├── ...
├── index
├── info
│   └── exclude
├── logs
│   ├── HEAD
│   └── refs
├── objects
│   ├── 00
│   ├── 01
│   ├── 02
│   ├── 03
│   ├── 04
│   ├── 05
│   ├── ...
│   ├── info
│   └── pack
├── ORIG_HEAD
├── packed-refs
└── refs
    ├── heads
    ├── remotes
    ├── stash
    └── tags
```

## HEAD

```bash
$ cat HEAD
ref: refs/heads/main

$ cat refs/heads/main
4436e4b582c7a8c942f11746d54cf4338325442c
```

| 이름                                                        | 설명                                                | 파일 내용                                                                                                        |
| ----------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| HEAD                                                        | 지금 작업하고 있는 로컬 브랜치를 가리키는 포인터. 로컬 브랜치는 해당 브랜치의 마지막 커밋을 가리킨다. | ref: refs/heads/main                                                                                             |
| ORIG_HEAD                                                   | HEAD의 이전 커밋을 백업                              | ec2a7f1e03bca5485627b8af6b76129aa3f49b8a                                                                         |
| FETCH_HEAD                                                  | 가장 최근에 fetch한 브랜치와 그 브랜치의 HEAD            | 2a6464fe3e243a15ceeef19c32e930374481e87f not-for-merge branch 'main' of github.com:markruler/markruler.github.io |
| MERGE_HEAD, CHERRY_PICK_HEAD, REVERT_HEAD, BISECT_HEAD, ... | -                                                | -                                                                                                                |

## refs

commit 객체의 포인터를 저장한다.

## info

저장소에 관한 추가 정보들은 이 디렉터리 안에 저장된다.
`.gitignore` 파일처럼 무시할 파일의 패턴을 적어둘 수 있다.
다만 `.git/info/exclude`은 `.git` 디렉토리 안에 있기 때문에 동료와 공유할 수 없다.

## objects

다른 VCS의 저장소처럼 Git의 저장소는 파일에 대한 유지, 복제, 수정 등의 이력을 관리하는데 필요한 모든 데이터를 포함하는 데이터베이스다.
하지만 Git의 이런 작업들을 처리하는 방식은 다른 VCS들과 차별화되어 있다.

Git은 유입되는 모든 것을 Object로 간주한다.
주요 Object 유형으로 blob, tree, commit, tag가 있다.

![Simple version of the Git data model](/images/shell/git/simple-git-data-model.png)

*[Simple version of the Git data model](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)*

### tree

Git은 유닉스 파일 시스템과 비슷한 방법으로 저장하지만 좀 더 단순하다.
모든 것을 tree와 blob 객체로 저장한다.
tree는 유닉스의 디렉토리에 대응되고 blob은 inode나 일반 파일에 대응된다.
tree 객체 하나는 항목을 여러 개 가질 수 있다.
그리고 그 항목에는 blob 객체나 하위 tree 객체를 가리키는 SHA-1 포인터, 파일 모드, 객체 타입, 파일 이름이 들어 있다. `write-tree` 명령으로 생성한다.

### blob (binary large object)

blob은 데이터 구조에 상관없이 모든 종류의 파일을 저장한다.
파일의 위치나 이름과 같은 파일의 메타 데이터가 아닌 파일 내용 자체를 저장한다.

```bash
$ git cat-file -p d8329fc1cc938780ffdd9f94e0d364e0ea74f579
100644 blob 83baae61804e65cc73a7201a7252750c76066a30      test.txt
```

여기서 blob의 파일 모드는 보통의 파일을 나타내는 `100644`,
실행파일을 나타내는 `100755`,
심볼릭 링크를 나타내는 `120000` 세 가지만 사용한다.

### commit

스냅샷에 관한 모든 메타 데이터를 보유하는 객체다.
메타 데이터는 스냅샷을 누가, 언제, 왜 저장했는지에 대한 정보를 포함한다.
`commit-tree` 명령으로 생성한다.

![All the reachable objects in your Git directory](/images/shell/git/reachable-objects.png)

*[All the reachable objects in your Git directory](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)*

### tag

커밋 객체를 쉽게 참조할 수 있도록 도와주는 labeling 객체다.

## index

Staging Area에 관한 정보가 저장되어 있다.
즉, 저장소에 커밋할 파일을 보관하는 장소다.

## Hash Function

체크섬을 계산한다.

## config

git 설정을 저장한다.
설정 데이터는 우선순위가 있는데 범위가 좁은 Local이 가장 우선 적용된다.
Local (`.git/config`) > Global (`$HOME/.gitconfig`) > System (`/etc/gitconfig`) 순서다.
config 파일은 INI file(`.ini`) 형식이다.

- macOS에서는 Local 설정보다 Keychain이 우선하나? TODO

```ini
# $HOME/.gitconfig
[user]
  email = imcxsu@gmail.com
  name = Changsu Im
[core]
  editor = vim
[diff]
  tool = vimdiff
[difftool]
  prompt = false
  # Be able to abort all diffs with `:cq` or `:qa!`
  # `:cq` to quit without saving and make Vim return non-zero error (i.e. exit with error)
  # `:qa` to quit all (short for :quitall)
  trustExitCode = true
[alias]
  fix = "!git commit --fixup $(git log -n 20 --pretty=format:'%Cred%h - %s' --graph --abbrev-commit | fzf --reverse | awk '{print $2}')"
  lg = log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD %C(bold green)(%ar)%C(bold yellow)    +++ %d%C(reset)%n'L'          %C(white)%s %C(dim white)- %an' --all

# .git/config
[core]
  repositoryformatversion = 0
  filemode = true
  bare = false
  logallrefupdates = true
[remote "origin"]
  url = git@github.com:okbut/corporate-library-api.git
  fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
  remote = origin
  merge = refs/heads/main
```

```bash
$ git config --global user.name Changsu Im
$ git config --global user.email imcxsu@gmail.com

# config 목록 출력
$ git config --list
$ git config --list --global
```

# SCM: Source Code Management

- [Source code management](https://www.atlassian.com/git/tutorials/source-code-management) - Atlassian
- What? 코드 변경 사항을 추적하고 관리하는 방법이다. 'Version Control System'으로도 불린다.
- Why? 팀의 커뮤니케이션 오버헤드를 줄이고 릴리스 속도를 높일 수 있다.
- How? Git Commands
  - 포셀린(Porcelain) 명령어는 사용자에게 이해하기 쉬운 명령어다.
  - 플러밍(Plumbing) 명령어는 저수준 명령어다.

# 포셀린(Porcelain) 명령어

['CS Visualized: 유용한 깃(Git) 명령어'](https://markruler.github.io/posts/shell/cs-visualized-useful-git-commands/)를 함께 읽는다.

## init

현재 디렉토리에 `.git` 디렉터리를 생성하고 Git 프로젝트로 초기화한다.

```bash
$ git init
Initialized empty Git repository in /home/markruler/toy/.git/
```

## clone

remote 리포지토리의 설정 정보를 제외한 모든 데이터를 로컬 머신에 복제한다. 그 과정은 다음과 같다.

1. 대상 디렉토리가 존재하지 않는다면 생성하고, 대상 디렉토리를 GIt 디렉토리로 초기화한다.
2. 대상 디렉토리 안에 소스 저장소의 브랜치와 동일한 추적 브랜치들을 설정한다. (git remote)
3. `.git` 디렉토리 내부에 objects와 references를 연결한다.
4. 최신 버전을 checkout한다.

```bash
$ git clone ${origin}
Cloning into 'my-origin-repo'...
remote: Enumerating objects: 22940, done.
remote: Counting objects: 100% (1929/1929), done.
remote: Compressing objects: 100% (780/780), done.
remote: Total 22940 (delta 1277), reused 1675 (delta 1131), pack-reused 21011
Receiving objects: 100% (22940/22940), 41.19 MiB | 9.49 MiB/s, done.
Resolving deltas: 100% (16109/16109), done.
```

## submodule

submodule을 사용하면 다른 리포지터리의 특정 스냅샷을 참조할 수 있다.
submodule을 추가하면 `.gitmodules` 파일이 생성된다.

```bash
# submodule을 새로 추가하는 경우
$ git submodule add https://github.com/markruler/repository

# 의존하는 submodule 리포지터리를 clone한다
$ git submodule update --init --recursive
```

## subtree

submodule은 하위 프로젝트의 체크섬만 참조하는 반면 subtree는 `.gitmodule`과 같은 메타 데이터없이 데이터를 그대로 복제한다.

- 왜 submodule 대신 subtree를 사용해야 할까?
  - [Git subtree: the alternative to Git submodule](https://www.atlassian.com/git/tutorials/git-subtree) - Atlassian
  - [Why your company shouldn’t use Git submodules](https://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/) - Amber

![tree-subtree-concept](/images/shell/git/tree-subtree-concept.png)

*[일반적인 Tree 개념](https://opensource.com/article/20/5/git-submodules-subtrees)*

## branch

브랜치(branch)는 나뭇가지나 지점, 분기를 뜻한다. Git의 브랜치는 커밋 사이를 가볍게 이동할 수 있는 포인터 같은 것이다. 흔히 말하는 master, main 브랜치는 트렁크(trunk, 줄기) 브랜치라고 불리는데 소스 코드 통합의 중심이 되는 브랜치이기 때문이다.

branch 명령을 실행하면 다음의 단계를 수행한다.

1. `.git/refs/heads/`에서 모든 브랜치명을 수집한다.
2. `.git/HEAD`에 위치한 HEAD를 참조해 현재 작업 중인 브랜치를 찾는다.
3. 모든 브랜치를 오름차순으로 정렬하고, 현재 작업 중인 브랜치에 별표(\*)를 표시한다.

```bash
$ git branch
* feature
  master
```

### xargs

eXtended ARGuments, Git 명령어는 아니지만 함께 사용하면 유용하다.

- [When to Use xargs](https://www.baeldung.com/linux/xargs) - Baeldung

```bash
$ echo {0..9} | xargs -n 2
0 1
2 3
4 5
6 7
8 9
```

branch 명령과 xargs 명령을 파이프(`|`)로 연결해서 사용하지 않는 작업 브랜치를 한꺼번에 정리할 수 있다.

```bash
# master, stable, main, 현재 브랜치 외 모든 브랜치 삭제
$ git branch | grep -v "master\|stable\|main\|\*" | xargs git branch -D

# 현재 브랜치 제외하고 삭제
$ git branch | grep -v "\*" | xargs git branch -D

# 모두 삭제
$ git branch | grep -v '^*' | xargs git branch -D

# 정규표현식으로 특정 브랜치 삭제
$ git branch | grep -Eo 'feature/.*' | xargs git branch -D
```

## tag

커밋을 참조하기 쉽도록 꼬리표(tag)를 붙인다. Lightweight 태그와 Annotated 태그 두 종류가 있다.

- Lightweight 태그는 단순히 특정 커밋에 대한 포인터일 뿐이다.
- Annotated 태그는 Git 데이터베이스에 태그를 만든 사람의 이름, 이메일과 태그를 만든 날짜, 그리고 태그 메시지도 저장한다.
  GPG(GNU Privacy Guard)로 서명할 수도 있다.
  일반적으로 Annotated 태그를 만들어 이 모든 정보를 사용할 수 있도록 하는 것이 좋다.
  하지만 임시로 생성하는 태그거나 이러한 정보를 유지할 필요가 없는 경우에는 Lightweight 태그를 사용할 수도 있다.

```bash
# Annotated tag
$ git tag -a 1.0.0 -m "test tag"

# tag 목록
$ git tag
1.0.0
```

```bash
# tag 내용 확인
$ git show 1.0.0
tag 1.0.0
Tagger: Changsu Im <imcxsu@gmail.com>
Date:   Sat Jan 15 20:38:46 2022 +0900

test tag

commit 49ef168385a2fe63f6e47055c1da79a0465039dc (HEAD -> master, tag: 1.0.0)
...

```

```bash
$ git show-ref --tags
02618f768d91cc1d21f5998c8d10ad62aacf278b refs/tags/1.0.0
```

tag 명령어를 실행하면 다음과 같은 단계를 수행한다.

1. 커밋이 참조하고 있는 체크섬을 가져온다.
2. 존재하는 태그명들 중 주어진 태그명을 검증한다.
3. 새로운 태그명이라면 naming convention을 검증한다.
4. 태그 객체가 생성된다. (`.git/refs/tags/`)

## switch

브랜치를 변경한다.

- [git@v2.23.0](https://github.com/git/git/blob/v2.23.0/Documentation/RelNotes/2.23.0.txt#L61) 부터 `checkout` 명령어는 `git-switch`와 `git-restore`로 분리되었다.
  이유는 checkout이 하는 기능이 많기 때문이다.
  - [Highlights from Git 2.23](https://github.blog/2019-08-16-highlights-from-git-2-23/) - GitHub Blog
  - [Git 2.23 Adds Switch and Restore Commands](https://www.infoq.com/news/2019/08/git-2-23-switch-restore/) - Sergio De Simone

```bash
# 1. 원격 리포지터리에서 해결하려는 Issue에 맞는 브랜치를 생성한다.
# 2. 로컬 환경에서 원격 리포지터리의 업데이트 사항을 가져온다.
$ git fetch --all

# 3. 해당 브랜치를 tracking하는 로컬 브랜치를 생성한다.
# git switch -c <branch> -t[--track] <remote>/<branch>
$ git switch -c feature/local-test -t origin/feature/remote-test
Branch 'feature/local-test' set up to track remote branch 'feature/remote-test' from 'origin'.
Switched to a new branch 'feature/local-test'
```

```bash
# 브랜치를 Local에서 먼저 생성하는 경우도 있다.
# 1. 브랜치를 생성한다.
$ git switch -c test-rebase

# 2. upstream을 지정한다.
$ git branch --set-upstream-to=origin/test-rebase test-rebase
Branch 'test-rebase' set up to track remote branch 'test-rebase' from 'origin'.

# 3. rebase
$ git rebase
First, rewinding head to replay your work on top of it...
Fast-forwarded add-github-action to refs/remotes/origin/test-rebase.
```

### upstream

![Triangular Workflow](/images/shell/git/triangular-workflow.png)

[Triangular Workflow](https://github.blog/2015-07-29-git-2-5-including-multiple-worktrees-and-triangular-workflows/)

upstream이라는 용어는 헷갈릴 수 있다.
협업 프로젝트에서 보통 위와 같은 원본 저장소를 `upstream`이라고 부르고
그것을 [fork](#fork)한 저장소를 `origin`,
upstream에서 fetch한 나의 로컬 환경을 `local`이라고 부른다.
아래 명령어는 지정한 `upstream` 브랜치로 push하도록 한다.

잠깐. fork한 `origin` 저장소가 아니라 `upstream`으로 push한다?

```bash
$ git push --set-upstream origin feature/test-upstream
# push 후
Branch 'feature/test-upstream' set up to track remote branch 'feature/test-upstream' from 'origin'.
```

사실 upstream이라는 용어는 Git에서만 쓰이는 건 아니다.
흔히 downstream과 대비해서 네트워크에서도 쓰이는 용어다.
예를 들어 로컬에서 원격으로, 클라이언트에서 서버로 데이터를 전송하는 것을 upstream이라고 말하고, downstream은 그 반대다.
즉, upload/download의 방향을 말하며 Git에서 upstream은 push하려는 방향을 말한다.

여기서 중요한 점은 Git에서 절대적인 upstream/downstream이 없다는 것이다.
Git은 DVCS(Distributed Version Control System)다.
다시 말해서 origin이 upstream일 수 있고, upstream은 또 다른 저장소의 downstream일 수 있다.
Triangular Workflow는 하나의 효과적인 방식일 뿐이다.

## status

index 파일과 HEAD 커밋, index 파일과 working tree를 비교해서 차이나는 부분을 표시한다.

```bash
$ git status -sb
## feature...master [ahead 2, behind 1]
D  README.md
D  a.c
D  c.c
?? README.md
?? a-1.c
?? test
```

## add

Working Directory의 변경 사항들을 Staging Area에 포함시킨다.
index를 갱신하고 다음 커밋에 대한 컨텐츠를 준비한다. 그 과정은 다음과 같다.

1. 컨텐츠에 대한 SHA-1 체크섬을 계산한다.
2. 기존의 blob 객체에 새로운 컨텐츠나 링크를 만들지 여부를 결정한다.
3. 실제로 생성하거나 blob에 연결한다.
4. 컨텐츠에 위치를 추적할 tree 객체를 생성한다.

```bash
# 모든 변경 사항을 staging area에 추가
$ git add -A

# 현재 디렉토리의 변경 사항을 staging area에 추가
$ git add .

# 특정 변경 사항만 추가
$ git add '*Detail.java'
$ git add src/
```

## fetch

커밋, 파일 및 참조를 원격 저장소에서 로컬 저장소로 다운로드한다.
다른 사람들이 작업한 것을 보고 싶을 때 사용할 수 있다.
다음과 같은 단계를 수행한다.

1. URL이나 원격 저장소 이름을 검증하고, 지정된 저장소에 대한 유효성을 확인한다.
2. 정의된 것이 없다면 설정 파일을 읽어서 기본 설정된 원격 저장소를 찾는다.
3. 찾았다면 원격 저장소로부터 이름이 지정된 참조(heads와 tags)와 관련된 객체들까지 가져온다.
4. 복구 가능한 참조들은 나중에 병합이 가능하도록 `.git/FETCH_HEAD`에 저장한다.

```bash
$ git fetch <branch>
$ git fetch --all # Fetch all remotes.
Fetching origin

$ git merge <origin/branch> <commit>
$ git merge FETCH_HEAD
```

## commit

관리 대상(Tracked)에 있는 변경 사항들을 HEAD에 반영한다.
즉, staging area(index)에 있는 변경 사항들을 local repository에 반영한다.
그렇다고 working tree나 staging area의 내용들을 지우지 않는다.

```bash
$ git commit
$ git commit -m "commit message"

# 마지막 커밋의 author를 변경할 수 있다.
$ git commit --amend --author="Changsu Im <imcxsu@gmail.com>"
# 특정 커밋의 author를 변경하고 싶다면 rebase를 사용한다.
```

## merge

소스 코드를 병합한다.
다음과 같은 단계를 수행한다.

1. 지정된 파라미터를 기반으로 `.git/refs/heads` 디렉토리로부터 병합 후보들을 식별한다.
2. 모든 heads의 공통된 조상을 찾아 메모리에 있는 모든 대상 객체들을 로드한다.
3. 공통 조상과 HEAD 사이의 차이를 판별한다.
4. 두 head를 비교한다.
5. head 사이의 공통된 영역에서 변경 사항이 있다면 마커를 통해 충돌을 표시하고 사용자에게 안내한다.
6. 충돌한 곳이 없다면, 콘텐츠를 병합하고, 병합을 기술한 메타데이터를 커밋한다.

```bash
# feature 브랜치에서 main 브랜치`를` 병합한다.
$ git switch feature
$ git merge main

# 위 명령어들은 한 줄로 실행할 수 있다.
$ git merge feature main

# merge 과정에서 충돌이 발생했다면 --abort 옵션으로 취소할 수 있다.
$ git merge --abort
```

![Merging main into the feature branch](/images/shell/git/merging-main-into-the-feature-branch.png)

*[Merging main into the feature branch](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)*

병합은 두 가지 방식이 있다.

```bash
# fast-forward
$ git merge --ff
```

먼저 Fast Forward 방식이다.
현재 브랜치의 커밋(2nd commit)이 병합하려는 커밋(1st commit)을 조상(ancestor)으로 두고 있다면
별도의 Merge 과정 없이 그저 최신 커밋(1st commit ← 2nd commit)으로 이동한다.

```bash
# no-fast-forward
$ git merge --no-ff
```

두 번째는 [3-way-merge](<https://en.wikipedia.org/wiki/Merge_(version_control)#Three-way_merge>) 방식을 사용한 No Fast Forward 방식이다.
현재 브랜치의 커밋(2nd commit)이 병합하려는 커밋(1st commit)을 조상으로 두지 않는다면 공통 조상 하나를 사용하여 병합한다.
단순히 브랜치 포인터를 최신 커밋으로 옮기는 게 아니라 3-way-merge의 결과를
별도의 **Merge 커밋**으로 만들고 나서 해당 브랜치의 HEAD가 그 커밋들을 가리키도록 이동시킨다.
이 Merge 커밋은 부모 커밋을 2개 가진다.

```bash
*   commit aec54781c060c26eeb5a6475ea3fede4a47dc178
|\  Merge: be1dacb bf50160 # 부모 커밋이 2개
| | Author: Changsu <imcxsu@gmail.com>
| | Date:   Wed Dec 15 05:46:44 2021 +0900
| |
| |     Merge pull request #16 from markruler/test-merge-branch
| |
| |     Testing merge commit
| |
| * commit bf50160af864cab37ba8eca54c97c6e448886b62 (test-merge-branch)
```

만약 병합하는 두 브랜치에서 같은 파일의 같은 부분을 동시에 수정하고 병합하면 GIt은 해당 부분을 병합하지 못한다.
3-way-merge가 실패하고 충돌(Conflict)이 발생한다.
`git mergetool`을 활용하면 간편하게 충돌을 해결할 수 있다.

```bash
$ git mergetool

This message is displayed because 'merge.tool' is not configured.
See 'git mergetool --tool-help' or 'git help config' for more details.
'git mergetool' will now attempt to use one of the following tools:
opendiff kdiff3 tkdiff xxdiff meld tortoisemerge gvimdiff diffuse diffmerge ecmerge p4merge araxis bc codecompare smerge emerge vimdiff nvimdiff
No files need merging

$ git mergetool --tool-help

'git mergetool --tool=<tool>' may be set to one of the following:
    vimdiff
    vimdiff2
    vimdiff3

The following tools are valid, but not currently available:
    araxis
    bc
    bc3
    codecompare
    deltawalker
    diffmerge
    diffuse
    ecmerge
    emerge
    examdiff
    guiffy
    gvimdiff
    gvimdiff2
    gvimdiff3
    kdiff3
    meld
    opendiff
    p4merge
    smerge
    tkdiff
    tortoisemerge
    winmerge
    xxdiff

Some of the tools listed above only work in a windowed
environment. If run in a terminal-only session, they will fail.
```

## pull

해당 명령은 내부적으로 다음의 과정을 수행한다.

1. 주어진 파라미터를 가지고 `git fetch`를 수행한다.
2. `git merge`를 호출해 현재 브랜치의 HEAD와 지정한 브랜치의 HEAD를 병합한다.

Git 서버의 Pull Request는 협업 과정에서 "제가 이런 작업들을 origin 저장소에 병합하니까 pull 부탁드려요~"라고 하는 것과 같다.

## rebase

> [rebase는 Git의 꽃이다.](https://www.facebook.com/photo?fbid=4291246567585200) - 이규원

merge는 병합하려는 commit 객체를 그대로 가져오는 non-destructive 명령이다.
반면 rebase는 내용은 같지만 새로운 commit 객체를 생성해서 HEAD에 배치한다.
그래서 만약 rebase를 이용해 소스를 병합한다면 이미 병합한 작업 브랜치는 더 이상 사용할 수 없다.

rebase를 하든지, merge를 하든지 최종 결과물은 같지만 커밋 히스토리가 다르다.
보통 원격 브랜치에 커밋 히스토리를 깔끔하게 적용하고 싶을 때 사용한다.

```bash
# oldBase 브랜치에서 newBase 브랜치로 rebase한다.
$ git rebase <newBase> <oldBase>

# feature 브랜치에서 main 브랜치`로` 재배치(rebase)한다.
$ git switch feature

       A---B---C feature
      /
 D---E---F---G main

$ git rebase main
$ git rebase main feature

               A'--B'--C' feature
              /
 D---E---F---G main
```

![Rebasing the feature branch onto main](/images/shell/git/rebasing-the-feature-branch-onto-main.png)

*[Rebasing the feature branch onto main](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)*

```bash
o---o---o---o---o  main
        \
         o---o---o---o---o  featureA
              \
               o---o---o  featureB

$ git rebase --onto main featureA featureB

                      o---o---o  featureB
                     /
    o---o---o---o---o  main
     \
      o---o---o---o---o  featureA
```

interactive 모드를 사용하면 커밋 목록을 나열한 후 todo 목록을 작성해서 rebase 작업을 진행할 수 있다.

```bash
$ git rebase -i <commit>^
$ git rebase --interactive <commit>^
```

아래와 같은 하위 명령어들이 있다.
나열된 커밋의 순서를 바꾸는 것만으로도 실제 커밋 순서가 변경된다.

```bash
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
```

### squash와 fixup

squash는 **커밋 메시지를 확인하고 편집한 후** squash and merge한다.
대상 커밋 뿐만 아니라 이후의 커밋들도 다시 저장해야 하기 때문에 체크섬이 변경된다.

```bash
$ git --no-pager log --oneline
399e2ef (HEAD -> squash) 3
ea37b52 2
7f1a625 (main) 1

# 지금 staged 파일들을 squash 커밋으로 만든다.
$ git commit --squash ea37b52

# squash 커밋은 대상 커밋 메시지 앞에 "squash!"이 붙는다.
$ git --no-pager log --oneline
d927a64 (HEAD -> squash) squash! 2
399e2ef 3
ea37b52 2
7f1a625 (main) 1

# squash 커밋들은 커밋 메시지를 확인 후 squash and merge한다.
$ git rebase -i --autosquash main
pick ea37b52 2
squash d927a64 squash! 2
pick 399e2ef 3

[detached HEAD 6f530b5] 2
 Date: Mon Jan 17 02:05:58 2022 +0900
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 b
 create mode 100644 d
Successfully rebased and updated refs/heads/squash.

$ git --no-pager log --oneline
ea3b05e (HEAD -> squash) 3 # 이후의 커밋들도 다시 저장한다.
6f530b5 2
7f1a625 (main) 1
```

fixup은 squash와 결과가 동일하지만,
original 커밋 메시지만 남기고 fixup 커밋의 메시지들은 **자동으로 버린다**.

```bash
$ git --no-pager log --oneline
ffdc929 (HEAD -> fixup) 3
ea53497 2
7f1a625 (main) 1

# 지금 staged 파일들을 fixup 커밋으로 만든다.
$ git commit --fixup ea53497

# fixup 커밋은 대상 커밋 메시지 앞에 "fixup!"이 붙는다.
$ git --no-pager log --oneline
202953c (HEAD -> fixup) fixup! 2
ffdc929 3
ea53497 2
7f1a625 (main) 1

# fixup 커밋들은 자동으로 squash and merge가 된다.
$ git rebase -i --autosquash main
pick ea53497 2
fixup 202953c fixup! 2
pick ffdc929 3

# fixup 커밋의 메시지들은 자동으로 버린다.
Successfully rebased and updated refs/heads/fixup.

$ git --no-pager log --oneline
449ed00 (HEAD -> fixup) 3
000a709 2
7f1a625 (main) 1
```

## cherry-pick

어느 브랜치든지 커밋의 체크섬을 알고 있다면 해당 커밋의 변경 사항들을 현재 HEAD에 반영한다.
**커밋 체크섬은 달라진다**는 것에 유의한다.

```bash
$ git cherry-pick <commit>

# --no-commit 옵션은 커밋의 변경 내용만 가져오고 커밋하지 않는다.
$ git cherry-pick <commit> --no-commit
```

## stash

stash는 숨겨둔다는 뜻으로 현재 로컬 브랜치에서 수정한 데이터를 Stack에 임시로 저장해둘 수 있다.
stash에 저장한 데이터는 브랜치 별로 관리되기 때문에 작업 중에 브랜치를 자유롭게 변경할 수 있도록 해준다.

```bash
# 변경 사항을 Stack에 저장한다. 아무런 하위 명령어를 입력하지 않으면 default.
$ git stash push

# Stack이기 때문에 stash@{0}부터 작업 데이터를 꺼낸 후 drop한다.
$ git stash pop

# pop처럼 작업 데이터를 Stack에서 꺼내지만 Stack에서 drop하지 않는다.
$ git stash apply
```

```bash
# stash@{0}을 제거한다.
$ git stash drop

# 모든 stash 데이터를 제거한다.
$ git stash clear
```

```bash
# stash 목록을 보여준다.
$ git stash list

# stash@{0}과 HEAD의 diff를 보여준다.
$ git stash show

# stash@{2}와 HEAD의 diff를 보여준다.
$ git stash show -p[--patch] 2
```

```bash
# 현재 상태를 저장한다.
$ git stash save <message>
$ git stash save "haha"
Saved working directory and index state On master: haha

$ git stash list
stash@{0}: On master: haha
```

기본적으로 untracked 파일이나 ignored 파일은 stash하지 않지만 옵션을 주면 stash 할 수 있다.

![git stash options](/images/shell/git/git-stash-options.png)

*[git stash options](https://www.atlassian.com/git/tutorials/saving-changes/git-stash)*

### How git stash works

stash된 상태는 실제로 로컬 저장소에 커밋 객체처럼 인코딩되어 저장됩니다.

```bash
$ git log --oneline --graph stash@{0}
*   3bd5af8 (refs/stash) On master: haha
|\
| * 09162cd index on master: 49ef168 test
|/
* 49ef168 (HEAD -> master) test

$ cat .git/refs/stash
3bd5af85bcbfaf7b031972dc41b016c4eb463028
```

## reset

HEAD를 특정 상태로 되돌린다.
다양한 mode 옵션이 있다.

- `--soft` – 스테이징된 스냅샷과 워킹 디렉토리는 건드리지 않고 커밋만 업데이트한다.
- `--mixed` – default 옵션이다. 스테이징된 스냅샷이 지정한 커밋과 일치하도록 업데이트(Tracked → Untracked)되지만, 워킹 디렉터리는 영향을 받지 않는다. (Undo `add`)

  ```bash
  $ git reset HEAD^
  $ git reset --mixed HEAD^
  Unstaged changes after reset:
  M package-lock.json
  M package.json
  ```

- `--hard` – 스테이징된 스냅샷과 워킹 디렉토리가 지정된 커밋과 일치하도록 업데이트한다.

  ```bash
  $ git reset --hard HEAD^
  HEAD is now at 955b01b7 chore: renew mac certificates (#12)
  ```

- `--merge` — 워킹 트리에서 merge를 undo 할 수 있다. (Undo `merge`/`pull`)

  ```bash
  $ git pull
   Auto-merging nitfol
   Merge made by recursive.
    nitfol                |   20 +++++----
    ...

  $ git reset --merge ORIG_HEAD
  ```

## restore

워킹 트리를 복구한다. `--staged` 옵션을 지정하면 스테이징된 스냅샷도 되돌릴 수 있다.

- [git@v2.23.0](https://github.com/git/git/blob/v2.23.0/Documentation/RelNotes/2.23.0.txt#L61) 부터 `checkout` 명령어에서 분리되었다.

```bash
# git checkout -- ${file_name}
# git restore --staged ${file_name}
$ git restore --staged * # git reset --mixed HEAD
```

## revert

`reset`처럼 커밋을 되돌리지만 이력을 지우지 않고 변경 사항을 되돌리는 커밋을 생성한다.

```bash
$ git revert <commit>

Revert "4ea42dbe의 커밋 메시지"

This reverts commit 4ea42dbe6580e4f064091cd50b3c7cb2ab8b0e9b.
```

## Git으로 버그 찾기

### blame

파일의 라인마다 마지막 수정 정보를 확인할 수 있다.

```bash
$ git blame README.md
0f6d7dc1 (Changsu Im 2021-12-01 23:47:58 +0900 32) ### Bash
dd2a98b2 (cxsu       2020-12-28 14:27:42 +0900 33) 
dd2a98b2 (cxsu       2020-12-28 14:27:42 +0900 34) ```bash

$ git blame -L 69,82 README.md
$ git blame -L 69 README.md
```

### bisect

- [A beginner's guide to GIT BISECT](https://www.metaltoad.com/blog/beginners-guide-git-bisect-process-elimination) - Tony Rost

이진 탐색을 이용해 버그가 발생한 커밋을 찾는다.
운영 서버에 버그가 발생했는데 어디서부터 잘못된 건지 찾기 힘들 때가 있다.
이 때 bisect는 스냅샷 더미를 헤집고 다닐 수 있게 도와준다.

```bash
# 테스트 프로젝트 생성
mkdir git-bisect-tests
cd git-bisect-tests
git init

echo row > test.txt
git add -A && git commit -m "Adding first row"
echo row >> test.txt
git add -A && git commit -m "Adding second row"
echo row >> test.txt
git add -A && git commit -m "Adding third row"
echo your >> test.txt
git add -A && git commit -m "Adding the word 'your'"
echo boat >> test.txt
git add -A && git commit -m "Adding the word 'boat'"
echo gently >> test.txt
git add -A && git commit -m "Adding the word 'gently'"
sed -i -e 's/boat/bug/g' test.txt 
git add -A && git commit -m "Changing the word 'boat' to 'bug'"
echo down >> test.txt
git add -A && git commit -m "Adding the word 'down'"
echo the >> test.txt
git add -A && git commit -m "Adding the word 'the'"
echo stream >> test.txt
git add -A && git commit -m "Adding the word 'stream'"
```

```bash
$ cat test.txt
row
row
row
your
bug # bug를 찾을 것이다.
gently
down
the
stream
```

bisect를 시작한다.

```bash
$ git bisect start
```

버그가 있는 현재 커밋을 기록한다.

```bash
$ git bisect bad
```

버그 없이 멀쩡했던 커밋을 기록한다.

```bash
$ git log --oneline
d4a701f (HEAD -> master, refs/bisect/bad) Adding the word 'stream'
eedf347 Adding the word 'the'
9a12012 Adding the word 'down'
f937601 Changing the word 'boat' to 'bug'
759ea63 Adding the word 'gently'
850323e Adding the word 'boat'
222f64a Adding the word 'your'
c608f80 Adding third row
60532d0 Adding second row
106eb10 Adding first row

$ git bisect good c608f80
Bisecting: 3 revisions left to test after this (roughly 2 steps)
[759ea6356258b687ad8b12178b2934ab5ad830bf] Adding the word 'gently'
...
```

![git-bisect](/images/shell/git/git-bisect.png)

*[Git bisect - debugging with git, Noaa Barki](https://www.datree.io/resources/git-bisect-debugging-with-git)*

이제부터 버그를 찾아나선다.
Git은 bad 커밋과 good 커밋의 중간 커밋(이진 탐색)을 자동으로 Checkout 해준다.
현재 커밋에서 테스트해보고 만약 버그가 계속 발생한다면 `bad`로 기록하고 `good` 커밋 방향으로 범위를 좁힌다.
버그가 없으면 `good`으로 기록하고 `bad` 커밋 방향으로 범위를 좁힌다.

```bash
# 히스토리 확인
$ git log --oneline
759ea63 (HEAD) Adding the word 'gently'
850323e Adding the word 'boat'
222f64a Adding the word 'your'
c608f80 (refs/bisect/good-c608f8011e4bfa3d1f1e9f537cc148769f158669) Adding third row
...

# 버그가 없다면 good 기록
$ cat test.txt
row
row
row
your
boat
gently

$ git bisect good
Bisecting: 1 revision left to test after this (roughly 1 step)
[9a120127fabd58d0f54786cf015528f77d9a9f17] Adding the word 'down'
```

`good`으로 기록하면 `bad` 커밋 방향으로 이진탐색한다.

```bash
$ git log --oneline
9a12012 (HEAD) Adding the word 'down'
f937601 Changing the word 'boat' to 'bug'
759ea63 (refs/bisect/good-759ea6356258b687ad8b12178b2934ab5ad830bf) Adding the word 'gently'
850323e Adding the word 'boat'
222f64a Adding the word 'your'
c608f80 (refs/bisect/good-c608f8011e4bfa3d1f1e9f537cc148769f158669) Adding third row
...
```

```bash
# 버그를 발견했다면 bad 기록
$ cat test.txt
row
row
row
your
bug # 버그다!!!
gently
down

$ git bisect bad
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[f9376015d4721390c942c0cd0064467b51495094] Changing the word 'boat' to 'bug'
```

`bad`로 기록하면 `good` 커밋 방향으로 이진탐색한다.

```bash
$ git log --oneline
f937601 (HEAD) Changing the word 'boat' to 'bug'
759ea63 (refs/bisect/good-759ea6356258b687ad8b12178b2934ab5ad830bf) Adding the word 'gently'
850323e Adding the word 'boat'
222f64a Adding the word 'your'
c608f80 (refs/bisect/good-c608f8011e4bfa3d1f1e9f537cc148769f158669) Adding third row
```

그 다음 커밋도 `bad`로 기록하고
`good` 커밋(refs/bisect/good-759ea63) 사이에 더 이상 커밋이 남아있지 않다면
해당 `bad` 커밋이 버그가 발생한 커밋이라고 판단하고 탐색을 종료한다.

```bash
$ git bisect bad
f9376015d4721390c942c0cd0064467b51495094 is the first bad commit
commit f9376015d4721390c942c0cd0064467b51495094
Author: Changsu Im <imcxsu@gmail.com>
Date:   Thu Feb 17 03:21:28 2022 +0900

    Changing the word 'boat' to 'bug'

 test.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

이진탐색하는 동안 `.git` 디렉토리에 bisect를 위한 파일들이 생성된다.

```bash
$ cat .git/BISECT_ANCESTORS_OK

$ cat .git/BISECT_EXPECTED_REV
f9376015d4721390c942c0cd0064467b51495094

$ cat .git/BISECT_LOG
git bisect start
# bad: [d4a701f370a2489c8976eb0ce9f7ccbc358e640d] Adding the word 'stream'
git bisect bad d4a701f370a2489c8976eb0ce9f7ccbc358e640d
# good: [c608f8011e4bfa3d1f1e9f537cc148769f158669] Adding third row
git bisect good c608f8011e4bfa3d1f1e9f537cc148769f158669
# good: [759ea6356258b687ad8b12178b2934ab5ad830bf] Adding the word 'gently'
git bisect good 759ea6356258b687ad8b12178b2934ab5ad830bf
# bad: [9a120127fabd58d0f54786cf015528f77d9a9f17] Adding the word 'down'
git bisect bad 9a120127fabd58d0f54786cf015528f77d9a9f17
# bad: [f9376015d4721390c942c0cd0064467b51495094] Changing the word 'boat' to 'bug'
git bisect bad f9376015d4721390c942c0cd0064467b51495094
# first bad commit: [f9376015d4721390c942c0cd0064467b51495094] Changing the word 'boat' to 'bug'

$ cat .git/BISECT_NAMES

$ cat .git/BISECT_START
master

$ cat .git/BISECT_TERMS
bad
good
```

bisect를 끝낼 때는 `.git/BISECT_START`로 다시 checkout 한다.

```bash
$ git bisect reset
Previous HEAD position was f937601 Changing the word 'boat' to 'bug'
Switched to branch 'master'
```

## show

Git Object를 확인한다. (blob, tree, tag, commit)

```bash
# git show ${object}

# tag
$ git show v1.0.0

# tree
$ git show v1.0.0^{tree}
$ git show v1.0.0^{tree}

# commit, blob, tree 등의 체크섬
$ git show 077b8fa429b57e299eb2db54ccf66ed6f1f993eb --oneline

# 어떤 커밋이 브랜치의 가장 최신 커밋이라면 간단히 브랜치 이름으로 커밋을 가리킬 수 있다.
$ git show master:README.md
```

## log

커밋 이력을 조회한다.

- [pretty formats](https://git-scm.com/docs/git-log#_pretty_formats)을 사용해서 출력 형식을 정할 수 있다.
- `--abbrev-commit` — 짧고 중복되지 않는 해시 값을 보여준다. 앞 7자를 보여주고 해시 값이 중복되는 경우 더 긴 해시 값을 보여준다.

```bash
$ git log --oneline --graph

# 날짜 출력
$ git log --graph --pretty=format:'%C(auto)%h%d (%cr) %cn <%ce> %s'

# 모든 브랜치 로그 출력
$ git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD %C(bold green)(%ar)%C(bold yellow)%d%C(reset)%n'L'          %C(white)%s %C(dim white)- %an' --all
```

```bash
# alias 지정
$ git config --global alias.lg "log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD %C(bold green)(%ar)%C(bold yellow)%d%C(reset)%n'L'          %C(white)%s %C(dim white)- %an' --all"
$ git lg
```

### Triple Dot(...)

Triple Dot은 양쪽에 있는 두 refs 사이에서 공통으로 가지는 것을 제외하고 서로 다른 커밋만 보여준다.

```bash
$ git log master...feature --oneline --left-right
> 2fe25f7 (HEAD -> feature) q
> a611f28 feature commit message
< 106047f (master) first
```

## reflog: Reference logs

Git은 자동으로 브랜치와 HEAD가 지난 몇 달 동안에 가리켰었던 커밋을 모두 기록하는데 이 로그를 `reflog`라고 부른다.

```bash
# git reflog show HEAD@{0}
# git reflog show HEAD
$ git reflog
734713b HEAD@{0}: commit: fixed refs handling, added gc auto, updated
d921970 HEAD@{1}: merge phedders/rdocs: Merge made by the 'recursive' strategy.
1c002dd HEAD@{2}: commit: added some blame and merge stuff
1c36188 HEAD@{3}: rebase -i (squash): updating HEAD
95df984 HEAD@{4}: commit: # This is a combination of two commits.
1c36188 HEAD@{5}: rebase -i (squash): updating HEAD
7e05da5 HEAD@{6}: rebase -i (pick): updating HEAD
```

특정 브랜치의 reflog만 확인할 수도 있다.

```bash
# git reflog show main@{0}
# git reflog show main
$ git reflog main
```

Git은 브랜치가 가리키는 것이 달라질 때마다 그 정보를 임시 영역에 저장한다.
그래서 예전에 가리키던 것이 무엇인지 확인해 볼 수 있다.
`@{n}` 규칙을 사용하면 아래와 같이 HEAD가 5번 전에 가리켰던 것을 알 수 있다.

```bash
$ git show HEAD@{5}

commit a66e752aa1fccaefe115460dc761c0411d578ed5
Author: Changsu Im <imcxsu@gmail.com>
Date:   Wed Dec 1 23:51:01 2021 +0900
...
```

순서뿐 아니라 시간도 사용할 수 있다. 어제 날짜의 `master` 브랜치를 보고 싶으면 아래와 같이 한다.

```bash
$ git show main@{1.minute.ago}
$ git show main@{1.hour.ago}
$ git show main@{1.day.ago}
$ git show main@{yesterday}
$ git show main@{1.week.ago}
$ git show main@{1.month.ago}
$ git show main@{1.year.ago}
$ git show main@{2021-12-02.23:00:00}

commit c23bcca5542f7eefa939dc47e3f843bb3b5b70f6 (HEAD -> main, origin/main, origin/HEAD)
Author: Changsu Im <imcxsu@gmail.com>
Date:   Thu Dec 2 21:27:17 2021 +0900
...
```

이 명령은 특정 시간에 `main` 브랜치가 가리키고 있던 것이 무엇인지 보여준다.
reflog에 남아있을 때만 조회할 수 있기 때문에 너무 오래된 커밋은 조회할 수 없다.

| tilde  | caret  | at-sign (reflog) |
| ------ | ------ | ---------------- |
| HEAD   | HEAD~0 | HEAD@{0}         |
| HEAD^  | HEAD~1 | HEAD@{1}         |
| HEAD^^ | HEAD~2 | HEAD@{4}         |

## diff

변경 사항을 비교한다.

```bash
$ git diff <before> <after>

# 마지막 커밋과 그 전 커밋을 비교한다.
$ git diff HEAD~1 HEAD~0

# 현재 수정된 파일 내용(local)을 마지막 커밋 내용과 비교한다.
$ git diff HEAD^

# 직전 커밋과 비교해서 변경 사항을 확인한다.
$ git diff <commit>~ <commit>
```

## push

local 저장소의 내용을 remote 저장소에 반영한다.
히스토리가 일치하지 않으면 push할 수 없다.
rebase 등의 동작으로 히스토리가 변경되었다면 강제 푸시(force push)를 시도해 볼 수 있다.
다만 동료와 같이 작업 중인 브랜치라면 강제 푸시는 주의해서 사용해야 한다.

```bash
# origin 저장소의 main 브랜치로 push
$ git push origin main

# 현재 HEAD와 같은 브랜치로 push
$ git push origin HEAD

# 현재 브랜치의 upstream 브랜치 지정 및 push
$ git push --set-upstream origin feature/test-upstream
```

push 명령을 실행하면 다음 과정을 수행한다.

1. 현재 브랜치를 확인한다.
2. 설정 파일에 기본 원격 저장소가 존재하는지 탐색한다.
3. 알고 있는 원격 저장소 URL과 추적 중인 heads(브랜치)를 가져온다.
4. 원격지의 변화가 생긴 마지막 시간 이후에 변경된 내용이 있는지 확인한다.
   1. 원격 저장소로부터 reference 목록을 가져온다(`git ls-remote`).
   2. 로컬 저장소와 원격 저장소의 커밋 이력(history)을 확인한다. 만약 다르다면 fetch 혹은 pull을 수행한다.

remote 저장소에 동명의 브랜치가 없다면 아래와 같은 문구를 볼 수 있는데 저장소 이름과 브랜치 이름을 명시적으로 입력하면 push할 수 있다.

```bash
$ git push
fatal: The upstream branch of your current branch does not match
the name of your current branch.  To push to the upstream branch
on the remote, use

    git push origin HEAD:main

To push to the branch of the same name on the remote, use

    git push origin HEAD

To choose either option permanently, see push.default in 'git help config'.

$ git push origin branch-name
```

# 플러밍(Plumbing) 명령어

## rev-parse

Git 데이터베이스에 있는 Object의 체크섬을 조회한다.

```bash
$ git log --oneline -n 1
2fe25f7 (HEAD -> feature) commit-msg

$ git rev-parse feature
2fe25f72fca431a3b1aabb863b3ca6e04ddccb77
```

## hash-object

데이터를 `.git` 디렉토리에 저장하고 체크섬을 계산한다.

```bash
$ git hash-object -w READM.me
76e579ae4c9106f3b62fb9203ec5b49d8014d87c
```

## ls-tree

tree 객체의 내용들을 보여준다.

```bash
# commit hash: ee85974962b9645d757bc71dd773effb67d3594f
$ git ls-tree ee85
100644 blob 396865b39e3f04c5ca6369999fd886dbae7441d0  .gitignore
040000 tree 03ad58223967ba0494385bf1a1f9dc45783b860d  WebContent
040000 tree 4aefa5dd5e1e60eb883c4ba84d2a68a577692eb0  __test__
100644 blob a823b374191cec985963bb821803a78a13ff89f2  jest.config.json
100644 blob f496d9afc494b5312dd6efd73f43b5b5e40e5e63  pom.xml
040000 tree 59885985da5d1acf846d516fd9722daa1b2a4dd6  src
```

## ls-files

index(스테이징된 파일)의 내용들을 체크섬과 함께 보여준다.

```bash
$ git ls-files -s                                                                                           ✭ ✱
100644 396865b39e3f04c5ca6369999fd886dbae7441d0 0 .gitignore
...
100644 dcdb07b5dfb81d995509aecad3bf202ee3a1d690 0 __test__/price.test.js
100644 a823b374191cec985963bb821803a78a13ff89f2 0 jest.config.json
100644 f496d9afc494b5312dd6efd73f43b5b5e40e5e63 0 pom.xml
100644 e148a4810619ea951091909d82ef0955fe3e0e8f 0 src/main/resources-dev/logback.xml
# 모든 파일 출력
```

## cat-file

저장소에 저장된 객체의 내용, 타입, 사이즈 정보를 확인할 수 있다.

```bash
# 해당 체크섬을 가진 객체의 타입을 알려준다.
$ git cat-file -t <checksum>
blob

# 해당 체크섬을 가진 객체의 사이즈를 알려준다.
$ git cat-file -s <checksum>
13 # bytes

# 객체의 타입을 알고 있다면 파일의 내용을 표시해준다.
$ git cat-file <type> <checksum>
이것은 내용입니다.
```

## write-tree

현재 index 내용으로 tree 객체를 생성하고 체크섬을 반환한다.

```bash
$ git write-tree
174592b10bb329e6f4664cbc03fd2c4869d12cdc

$ git ls-tree 17459
100644 blob d474e1b4d626dbf09a9776c778e9f8691bc8b406  a
```

## commit-tree

특정 tree 객체로 새로운 커밋을 만든다.

```bash
$ git commit-tree HEAD^{tree} -p main -m "test commit"
d5fc19ea68a8556383d46a79177395b563a8a483

$ git show d5fc
commit d5fc19ea68a8556383d46a79177395b563a8a483
Author: Changsu Im <imcxsu@gmail.com>
Date:   Sat Jan 15 22:59:25 2022 +0900

    test

$ git merge --ff-only d5fc
Updating 5fe0db6..d5fc19e
Fast-forward
```

## read-tree

특정 tree 객체를 index에 포함시킨다.

```bash
$ git read-tree HEAD^
$ git status
Changes to be committed:
...

$ git read-tree HEAD
$ git status
nothing to commit, working tree clean
```

## update-index

woirking tree에서 기존 BLOB 또는 파일을 가져와 index를 업데이트합니다.

- `update-ref`
  - master 브랜치를 지정한 커밋 객체로 업데이트한다.

  ```bash
  $ git update-ref refs/heads/master 992379
  ```

- `symbolic-ref`
  - 또 다른 reference를 가리키도록 reference(일반적으로 HEAD)를 업데이트한다.
- `ls-remote`
  - 원격 저장소의 references를 나열한다.

  ```bash
  $ git ls-remote
  From .
  2fe25f72fca431a3b1aabb863b3ca6e04ddccb77  HEAD
  2fe25f72fca431a3b1aabb863b3ca6e04ddccb77  refs/heads/feature
  106047f0f0c057c28417e790a4ac22aef2b8bcf2  refs/heads/master
  ```

# Advanced

## Git Hooks

Git 저장소에서 특정 이벤트가 발생할 때마다 자동으로 실행되는 스크립트다.
스크립트들은 기본적으로 `.git/hooks/*` 에 위치한다.

![Maintaining a hook using a symlink to version-controlled script](/images/shell/git/hook-symlink-script.png)

*[Maintaining a hook using a symlink to version-controlled script](https://www.atlassian.com/git/tutorials/git-hooks)*

예를 들어, 아래와 같은 `pre-push` hook은 `git push` 명령어를 실행시켰을 때 `push` 가 실행되기 전 `gradle test` 명령어가 먼저 실행된다.

```bash
#!/usr/bin/env bash

# 해당 스크립트의 실행 권한을 부여한다.
# chmod +x .githooks/pre-push

# hooks 경로를 .githooks로 변경한다.
# git config core.hookspath .githooks

# `pre-push` hook은 `git push` 전 항상 실행되는 스크립트다.
gradle test
```

## Garbage Collection

### Packfiles

Git이 처음 객체를 저장하는 형식은 loose objects라고 부른다.
여러 개의 loose objects를 Packfile(`./git/objects/pack/*`)이라 불리는 단일 바이너리 내에 압축(pack)한다.
`git gc` 명령을 실행하면 `git repack`을 실행하고 `git pack-objects` 명령을 실행한다.
[pack-objects 명령](https://git-scm.com/docs/git-pack-objects)은 default로
zlib을 사용해서 packfile(`.pack`)과 pack의 index 파일(`.idx`)을 생성한다.
packfile은 객체들을 효율적으로 주고받고, 빠르게 읽기 위해 사용한다.
packfile은 다른 객체들과 다르게 clone, fetch, push, pull만 지원한다.

| 구현 측면 | 프로세스 호출 | 설명                                                                                                                                                  |
| --------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Server    | Upload-pack   | git fetch-pack에 의해 호출되며, 다른 측면에 없는 객체를 확인해 압축한 후 전송한다.                                                                            |
| Client    | Fetch-pack    | 다른 저장소로부터 소실된 패키지를 능동적으로 받는다. 이 명령은 일반적으로 최종 사용자에 의해 호출되지 않고 이 명령을 상위 수준으로 감싼 git fetch가 실행된다.                  |
| Server    | Receive-pack  | git send-pack에 의해 호출되며, 저장소 안에 push된 것들을 받는다.                                                                                          |
| Client    | Send-pack     | 다른 저장소에 대해 git 프로토콜을 이용해 객체들을 push한다. 이 명령은 일반적으로 최종 사용자에 의해 직접 호출되지 않고, 이 명령을 상위 수준으로 감싼 git push가 대신 실행된다. |

Packfile을 열어 압축한 내용을 확인해볼 수 있다.

```bash
$ git verify-pack -v .git/objects/pack/pack-3c3fc80c28fbf38af5ca843ae8b714d22c06bdab.idx
...
.git/objects/pack/pack-3c3fc80c28fbf38af5ca843ae8b714d22c06bdab.pack: ok
```

### gc

Garbage Collection을 실행한다.
Git에서 말하는 garbage는 접근할 수 없는 객체(orphan)다.
예를 들어 orphan 브랜치, 어떤 커밋에도 추가되지 않은 dangling 객체, 어떤 커밋도 가리키지 않고 압축되지 않은 blob 객체 등이다.
`git prune`, `git repack`, `git pack`, `git rerere` 등 다른 내부 하위 명령어를 같이 실행한다.
`git gc` 명령으로도 실행할 수 있지만 push, pull, merge, rebase, commit 명령에서 자동으로 실행된다.

Garbage Collection을 실행하기 전에는 reset한 객체들을 복구할 수 있다.

```bash
# touch test and git add
$ git commit -m "test"
[master (root-commit) fd5e183] test

# touch test2 and git add
$ git commit -m "test2"
[master (root-commit) 291b5c6] test

$ git log --oneline
291b5c6 (HEAD -> master) test2
fd5e183 test

$ git reset --hard HEAD^
HEAD is now at fd5e183 test

$ git gc

$ git fsck --lost-found
Checking object directories: 100% (256/256), done.
dangling commit 291b5c685acc9647ecf4330ec261d945078ac4d4

$ git merge 291b5c6
Updating fd5e183..291b5c6
Fast-forward
 test2 | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 test2

$ git log --oneline
291b5c6 (HEAD -> master) test2
fd5e183 test
```

orphan 브랜치를 직접 만들어보자

```bash
$ touch test
$ git add .
$ git commit -m "test"
[master (root-commit) c2864f0] test

$ git switch --orphan empty
Switched to a new branch 'empty'

$ git log
fatal: your current branch 'empty' does not have any commits yet

$ git log --oneline --all
c2864f0 (master) test

# git rm --cached -r .
# git clean -f

$ git commit --allow-empty -m "empty commit"
[empty (root-commit) 02116ce] empty commit
```

## prune

연결할 수 없는 orphan 객체를 제거한다.
일반적으로 직접 실행되지 않고 `gc`의 하위 명령으로 gc의 기준에 따라 사용된다.

`fsck` 명령으로 dangling 객체를 확인할 수 있다.

```bash
$ git fsck
Checking object directories: 100% (256/256), done.
Checking objects: 100% (573/573), done.
dangling blob c319a9963957cb51e3cb692ac44a4831ea529992
dangling blob 4a8aaf3e4ce1c7e8da2764f8b6253a3029664d92
dangling blob 091349d97a6ecaeea819fac9fcb3f9d515c87a99
dangling blob 524b1128ed15bfb42eb1b71f93b3fd0fa77adab6
dangling blob 879b261622ca54bd28f8fa2be6330fe9ebfba814
dangling blob 7f3ced9d3dad92439949d98ad2d92125be07764c
dangling blob bcfc949b6572079aa54db963abc59b48232813ed
dangling blob f16c37ff355844ac388d101e5bba46e698a4deb8
dangling blob e69de29bb2d1d6434b8b29ae775ad8c2e48c5391
dangling blob f4d5466af82d891b81ad792b0e74e2341e46312f
dangling blob 0a56b32d98fea47ca5228e3b62ee1fc189408796
dangling blob 0e062ca2a9130d0bfb9ffcf29a0a43d6f1b65957
dangling blob 5ca654e778f2cceb0207dc9311c8961107caa17e
dangling blob 002f663c650d708e29d75524630bc5cf97403039
```

`--dry-run` 옵션을 사용하면 실제로 객체를 지우지 않고 어떤 것이 지워지는지 보여주기만 한다.
확인해보면 위의 dangling blob 객체들이라는 것을 알 수 있다.

```bash
$ git prune --dry-run --verbose

002f663c650d708e29d75524630bc5cf97403039 blob
091349d97a6ecaeea819fac9fcb3f9d515c87a99 blob
0a56b32d98fea47ca5228e3b62ee1fc189408796 blob
0e062ca2a9130d0bfb9ffcf29a0a43d6f1b65957 blob
4a8aaf3e4ce1c7e8da2764f8b6253a3029664d92 blob
524b1128ed15bfb42eb1b71f93b3fd0fa77adab6 blob
5ca654e778f2cceb0207dc9311c8961107caa17e blob
7f3ced9d3dad92439949d98ad2d92125be07764c blob
879b261622ca54bd28f8fa2be6330fe9ebfba814 blob
bcfc949b6572079aa54db963abc59b48232813ed blob
c319a9963957cb51e3cb692ac44a4831ea529992 blob
e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 blob
f16c37ff355844ac388d101e5bba46e698a4deb8 blob
f4d5466af82d891b81ad792b0e74e2341e46312f blob
```

`GIT_TRACE=true` 환경 변수와 함께 `gc`를 실행하면 `prune` 명령이 실행된다는 것을 알 수 있다.

```bash
$ GIT_TRACE=true git gc
21:48:42.368350 git.c:439               trace: built-in: git gc
21:48:42.368555 run-command.c:663       trace: run_command: git pack-refs --all --prune
21:48:42.369748 git.c:439               trace: built-in: git pack-refs --all --prune
21:48:42.376790 run-command.c:663       trace: run_command: git reflog expire --all
21:48:42.377979 git.c:439               trace: built-in: git reflog expire --all
21:48:42.383220 run-command.c:663       trace: run_command: git repack -d -l -A --unpack-unreachable=2.weeks.ago
21:48:42.384183 git.c:439               trace: built-in: git repack -d -l -A --unpack-unreachable=2.weeks.ago
21:48:42.384316 run-command.c:663       trace: run_command: GIT_REF_PARANOIA=1 git pack-objects --local --delta-base-offset .git/objects/pack/.tmp-57526-pack --keep-true-parents --honor-pack-keep --non-empty --all --reflog --indexed-objects --unpack-unreachable=2.weeks.ago
21:48:42.385307 git.c:439               trace: built-in: git pack-objects --local --delta-base-offset .git/objects/pack/.tmp-57526-pack --keep-true-parents --honor-pack-keep --non-empty --all --reflog --indexed-objects --unpack-unreachable=2.weeks.ago
Enumerating objects: 573, done.
Counting objects: 100% (573/573), done.
Delta compression using up to 12 threads
Compressing objects: 100% (256/256), done.
Writing objects: 100% (573/573), done.
Total 573 (delta 133), reused 573 (delta 133)
21:48:42.402885 run-command.c:663       trace: run_command: git prune --expire 2.weeks.ago
21:48:42.403766 git.c:439               trace: built-in: git prune --expire 2.weeks.ago
21:48:42.407108 run-command.c:663       trace: run_command: git worktree prune --expire 3.months.ago
21:48:42.408258 git.c:439               trace: built-in: git worktree prune --expire 3.months.ago
21:48:42.408495 run-command.c:663       trace: run_command: git rerere gc
21:48:42.409708 git.c:439               trace: built-in: git rerere gc
```

# Git Server

## Fork

Fork는 서버에 저장소의 복사본을 만든다.

![fork-repository](/images/shell/git/fork-repository.svg)

*[Distributed version control and forking workflow](https://coderefinery.github.io/git-collaborative/03-distributed/)*

- fork를 사용하면 upstream 리포지토리에 영향을 주지 않고 마음대로 변경할 수 있다.
  - fork 리포지토리에서 `push --force`를 하든 말든 상관없다.
  - remote-local 리포지토리를 좀 더 적극적으로 관리할 수 있다.
  - 공유지의 비극을 피할 수 있다.
- upstream 리포지토리의 메인테이너를 제한할 수 있다.
- upstream 리포지토리의 안 쓰는 브랜치들을 따로 정리할 필요가 없다.
- 진정한 의미의 DVCS

## Branch protection rules

Pull Request를 통해서만 소스를 통합할 수 있도록 제약 사항을 설정했을 경우 혹은 원격 브랜치에 force push 할 수 있는 권한이 없을 경우 아래와 같은 메시지를 마주할 수 있다.

```bash
git --no-optional-locks -c color.branch=false -c color.diff=false -c color.status=false -c diff.mnemonicprefix=false -c core.quotepath=false -c credential.helper=sourcetree push -v --tags origin refs/heads/develop:refs/heads/develop
Pushing to https://bitbucket.markruler.com/scm/mark/test-pr.git
POST git-receive-pack (990 bytes)
remote:                             *%%%%%.
remote:                         %%%         %%%
remote:                      ,%#               %%
remote:                     %%                   %%
remote:                    %#                     %%
remote:                   %%                       %
remote:                   %(                       %%
remote:                   %%%%%%%%%%%%%%%%%%%%%%%%%%%
remote:                 %#%*%#///////%# %%///////%%%%%%
remote:                ,% %*%%******%#   %%******%(%%,%
remote:                  %%/ %%/**%%/%%%%%%%(**#%( %%#
remote:                   %%          %%%          %(
remote:                    %                      .%
remote:                    *%        %%%%%       .%
remote:                      %#                 %%
remote:                       .%%            .%%
remote:                       .%%.%%,     %%%.%%/
remote:                 %%%%%%##%.  #%%%%%.  .%((%%%%%%
remote:             %%#(((((((((%%,         #%%(((((((((#%%.
remote:       %%%((((((((((((((((((%%%, .%%%((((((((((((((((((#%%*
remote:     %%(((((((((((((((((((((((((%(((((((((((((((((((((((((#%.
remote:   ,%(((((((((((((((((((((((((((((((((((((((((((((((((((((((%#
remote:   %#((((((((((((((((((((((((((((((((((((((((((((((((((((((((%
remote:   %%%%%%%%%%%%%(((((((((((((((((((((((((((((((((%%%%%%%%%%%%%
remote:  %%            %####((((((###%%%%%%%%#(((((((((%            ,%
remote: ,%             %%%%%%#.               %%%((((((%*            %%
remote: #%                                       %%%#                %%
remote: .%                             .%%%%%%%%%                    %#
remote:  %                         #%%%                              %
remote:  %                     %%%%                                  %*
remote: /%************/#%%%%%%######%%*                        ..,*/(%%
remote:               %%######(((((((##################%%
remote:               %%######(((((((((((((((((((((((((%%
remote: //////////////%%%%%%%%#########################%%/////////  ///
remote: ----------------------------------------------------
remote: Branch refs/heads/develop can only be modified through pull requests.
remote: Check your branch permissions configuration with the project administrator.
remote: ----------------------------------------------------
remote:
remote:
To https://bitbucket.markruler.com/scm/mark/test-pr.git ! [remote rejected] develop -> develop (pre-receive hook declined)
error: failed to push some refs to 'https://bitbucket.markruler.com/scm/mark/test-pr.git'
Completed with errors, see above
```

# 참고

- Books
  - [Pro Git](https://git-scm.com/book/en/v2) (2/e) - Scott Chacon, Ben Straub
  - [Git Tutorials](https://www.atlassian.com/git/tutorials) - Atlassian
  - [Git Guide](https://github.com/git-guides/) - GitHub
  - [Git을 이용한 버전 관리](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=9788960775473) - 라비산카 소마순다람
- Git Internal
  - [CS Visualized: 유용한 깃(Git) 명령어](https://markruler.github.io/posts/shell/cs-visualized-useful-git-commands/) - Lydia Hallie
  - [The Complete Git Guide: Understand and master Git and GitHub](https://www.udemy.com/course/git-and-github-complete-guide/) - Bogdan Stashchuk
  - [A Visualized Intro to Git Internals — Objects and Branches](https://medium.com/swimm/a-visualized-intro-to-git-internals-objects-and-branches-68df85864037) - Omer Rosenbaum
  - [Getting Hardcore — Creating a Repo From Scratch](https://medium.com/swimm/getting-hardcore-creating-a-repo-from-scratch-cc747edbb11c) - Omer Rosenbaum
  - [A Hands-On Intro to Git Internals: Creating a Repo From Scratch](https://swimm.io/blog/a-hands-on-intro-to-git-internals-creating-a-repo-from-scratch/) - swimm
  - [Hash Function](https://git-scm.com/docs/hash-function-transition/) - git-scm
  - [objects](https://git-scm.com/book/ko/v2/Git%EC%9D%98-%EB%82%B4%EB%B6%80-Git-%EA%B0%9C%EC%B2%B4) - git-scm
- refs
  - [gitrevisions](https://git-scm.com/docs/gitrevisions) - git-scm
  - [Refs and the Reflog](https://www.atlassian.com/git/tutorials/refs-and-the-reflog) - Atlassian
- index
  - [Make your monorepo feel small with Git’s sparse index](https://github.blog/2021-11-10-make-your-monorepo-feel-small-with-gits-sparse-index/) - Derrick Stolee
  - [Git: Understanding the Index File](https://mincong.io/2018/04/28/git-index/) - Mincong Huang
  - [The Git Index](https://shafiul.github.io//gitbook/7_the_git_index.html)
- config
  - [git-scm](https://git-scm.com/docs/git-config) - git-scm
- tag
  - [tag](https://git-scm.com/book/ko/v2/Git%EC%9D%98-%EA%B8%B0%EC%B4%88-%ED%83%9C%EA%B7%B8) - git-scm
- Commands
  - [struct cmd_struct commands[]](https://github.com/git/git/blob/90d242d36e248acfae0033274b524bfa55a947fd/git.c#L487)
- submodule & subtree
  - [submodule](https://www.atlassian.com/git/tutorials/git-submodule) - Atlassian
  - [subtree](https://www.atlassian.com/git/tutorials/git-subtree) - Atlassian
  - [git-submodule](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-%EC%84%9C%EB%B8%8C%EB%AA%A8%EB%93%88) - git-scm
  - [Git subtree: the alternative to Git submodule](https://www.atlassian.com/git/tutorials/git-subtree) - Atlassian
  - [Why your company shouldn’t use Git submodules](https://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/) - Amber
  - [Use subtrees and submodules to add a public repo to your project](https://openclassrooms.com/en/courses/5671626-manage-your-code-project-with-git-github/6152286-use-subtrees-and-submodules-to-add-a-public-repo-to-your-project) - OpenClassrooms
  - [The power of Git subtree](https://blog.developer.atlassian.com/the-power-of-git-subtree/) - Atlassian
  - [Git subtree를 활용한 코드 공유](https://blog.rhostem.com/posts/2020-01-03-code-sharing-with-git-subtree) - rhostem
  - [Subtree 사용법](https://www.three-snakes.com/git/git-subtree) - ThreeSnakes
  - [git subtree - 프로젝트 안의 또 다른 프로젝트](https://homoefficio.github.io/2015/07/18/git-subtree/) - HomoEfficio
- status
  - [int cmd_status(int argc, const char \**argv, const char *prefix)](https://github.com/git/git/blob/90d242d36e248acfae0033274b524bfa55a947fd/builtin/commit.c#L1475)
  - [wt_status_collect(struct wt_status \*s)](https://github.com/git/git/blob/master/wt-status.c#L807)
  - [git은 폴더경로가 변경된 것을 어떻게 알 수 있을까?](https://kwoncheol.me/posts/git-rename-inference) - kwoncheol
- fetch
  - [git-fetch](https://git-scm.com/docs/git-fetch) - git-scm
  - [git fetch](https://www.atlassian.com/git/tutorials/syncing/git-fetch) - Atlassian
- add
  - [int cmd_add(int argc, const char \**argv, const char *prefix)](https://github.com/git/git/blob/90d242d36e248acfae0033274b524bfa55a947fd/builtin/add.c#L491)
- merge
  - [Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) - git-scm
  - [3 way merge - 지옥에서 온 Git](https://youtu.be/J0W-WA0aYJI) - 생활코딩
  - [Three-way merging: A look under the hood](https://blog.plasticscm.com/2016/02/three-way-merging-look-under-hood.html) - Plastic SCM
  - [3-way merge 알고리즘에 대해](https://blog.npcode.com/2012/09/29/3-way-merge-%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98%EC%97%90-%EB%8C%80%ED%95%B4/) - 이응준
- rebase
  - [Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) - git-scm
  - [Merging vs. Rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing) - Atlassian
- stash
  - [git stash](https://www.atlassian.com/git/tutorials/saving-changes/git-stash#how-git-stash-works) - Atlassian
  - [int cmd_stash(int argc, const char \**argv, const char *prefix)](https://github.com/git/git/blob/90d242d36e248acfae0033274b524bfa55a947fd/builtin/stash.c#L1769)
  - [static int check_changes(const struct pathspec *ps, int include_untracked, struct strbuf *untracked_files)](https://github.com/git/git/blob/90d242d36e248acfae0033274b524bfa55a947fd/builtin/stash.c#L1082)
- reset
  - [Undoing Things](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things) - git-scm
  - [Resetting, Checking Out & Reverting](https://www.atlassian.com/git/tutorials/resetting-checking-out-and-reverting) - Atlassian
- [Git으로 버그 찾기](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-Git%EC%9C%BC%EB%A1%9C-%EB%B2%84%EA%B7%B8-%EC%B0%BE%EA%B8%B0)
- reflog
  - [git reflog](https://www.atlassian.com/git/tutorials/rewriting-history/git-reflog) - Atlassian
  - [Revision Selection](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-%EB%A6%AC%EB%B9%84%EC%A0%84-%EC%A1%B0%ED%9A%8C%ED%95%98%EA%B8%B0#_git_reflog)
- diff
  - [Git diff](https://www.atlassian.com/git/tutorials/saving-changes/git-diff) - Atlassian
  - [git-diff](https://git-scm.com/docs/git-diff) - git-scm
- cherry-pick
  - [Git Cherry Pick](https://www.atlassian.com/git/tutorials/cherry-pick) - Atlassian
  - [git-cherry-pick](https://git-scm.com/docs/git-cherry-pick) - git-scm
- push
  - [git-push](https://git-scm.com/docs/git-push) - git-scm
  - [git push](https://www.atlassian.com/git/tutorials/syncing/git-push) - Atlassian
- hooks
  - [Git Hooks](https://www.atlassian.com/git/tutorials/git-hooks) - Atlassian
  - [githooks](https://git-scm.com/docs/githooks) - git-scm
- packfile
  - [Packfiles](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) - Pro Git
  - [The Packfile](http://shafiul.github.io/gitbook/7_the_packfile.html) - Git Community Book
- gc
  - [git gc](https://www.atlassian.com/git/tutorials/git-gc) - Atlassian
  - [git prune](https://www.atlassian.com/git/tutorials/git-prune) - Atlassian
- orphan
  - [Git 저장소에서 빈 고아 브랜치를 만드는 방법](https://www.lainyzine.com/ko/article/how-to-create-git-orphan-branch/) - LainyZine
- fork
  - [Forking Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow)
  - [About forks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/about-forks)
  - [Github를 이용하는 전체 흐름 이해하기 #1](https://blog.outsider.ne.kr/865) - 아웃사이더
