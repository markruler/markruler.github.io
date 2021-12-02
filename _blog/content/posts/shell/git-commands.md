---
date: 2021-12-01T23:28:00+09:00
title: "Git똥찬 소스 코드 버전 관리"
description: "CLI 환경에서 Git 활용하기"
featured_image: "/images/shell/git-logo-2color.png"
images: ["/images/shell/git-logo-2color.png"]
socialshare: true
tags:
  - git
Categories:
  - shell
---

- [참고](#참고)
- [명령어](#명령어)
  - [config](#config)
  - [clone 하고 submodule 가져오기](#clone-하고-submodule-가져오기)
  - [add](#add)
    - [refs (.git/)](#refs-git)
  - [switch](#switch)
    - [upstream](#upstream)
  - [branch](#branch)
    - [xargs](#xargs)
  - [fetch](#fetch)
  - [commit](#commit)
  - [rebase](#rebase)
  - [merge](#merge)
  - [reset](#reset)
  - [revert](#revert)
  - [Git으로 버그 찾기 - git-scm](#git으로-버그-찾기---git-scm)
    - [blame](#blame)
    - [bisect](#bisect)
  - [log 그래프](#log-그래프)
    - [Git Alias](#git-alias)
  - [diff](#diff)
  - [cherry-pick](#cherry-pick)
  - [stash](#stash)
  - [push](#push)
- [Advanced](#advanced)
  - [Git Hooks](#git-hooks)
- [Git 서버](#git-서버)
  - [Branch protection rules](#branch-protection-rules)

# 참고

- [Pro Git](https://git-scm.com/book/en/v2) - git-scm
- [Git Tutorials](https://www.atlassian.com/git/tutorials) - Atlassian

# 명령어

명령어들을 확인하기 전 [[번역] CS Visualized: 유용한 깃(Git) 명령어](https://markruler.github.io/posts/shell/cs-visualized-useful-git-commands/)를 먼저 읽는다.

## config

git 설정을 편집하거나 확인한다.
설정 데이터는 우선순위가 있는데 범위가 좁은 Local이 가장 우선 적용된다.

- Local (`.git/config`)
- Global (`$HOME/.gitconfig`)
- System (`/etc/gitconfig`)

```toml
# $HOME/.gitconfig
[user]
  email = imcxsu@gmail.com
  name = Changsu Im
[core]
  editor = vim

# .git/config
[core]
  repositoryformatversion = 0
  filemode = true
  bare = false
  logallrefupdates = true
[remote "origin"]
  url = git@github.com:markruler/markruler.github.io.git
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

## clone 하고 submodule 가져오기

```bash
$ git clone ${origin}
$ git submodule update --init --recursive
```

## add

working directory의 변경 사항들을 staging area에 포함시킨다. `stage`라는 용어는 두루 쓰이기 때문에 한번 생각해 볼 만하다. stage는 "과정이나 발전, 성장 등의 단계"라는 뜻을 가지고 있다. 그래서 "목표로 하는 것의 직전 단계"라고 생각하면 쉽다. Git에서의 staging area는 저장소에 커밋되기 직전 단계이고, 배포 환경에서의 staging 서버는 production 서버에 배포하기 직전 단계에 있는 서버다.

![git-sections](/images/shell/git-sections.png)

*[the three main sections of a Git project](https://git-scm.com/book/en/v2/Getting-Started-What-is-Git%3F#_the_three_states)*

![git-states](/images/shell/git-states.png)

*[The lifecycle of the status of your files](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)*

```bash
# 모든 변경 사항을 staging area에 추가
$ git add -A

# 특정 변경 사항만 추가
$ git add '*Detail.java'
$ git add src/
```

### refs (.git/)

- [gitrevisions](https://git-scm.com/docs/gitrevisions#_specifying_revisions) - git-scm
- [Refs and the Reflog](https://www.atlassian.com/git/tutorials/refs-and-the-reflog) - Atlassian

| 이름       | 설명                                          | 예시 파일 내용                                                                                                   |
| ---------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| HEAD       | 현재 브랜치의 마지막 커밋 참조                | ref: refs/heads/main                                                                                             |
| ORIG_HEAD  | HEAD의 직전 커밋을 백업 참조                       | ec2a7f1e03bca5485627b8af6b76129aa3f49b8a                                                                         |
| FETCH_HEAD | 가장 최근에 fetch한 브랜치와 그 브랜치의 HEAD | 2a6464fe3e243a15ceeef19c32e930374481e87f not-for-merge branch 'main' of github.com:markruler/markruler.github.io |
| MERGE_HEAD, CHERRY_PICK_HEAD, REVERT_HEAD, BISECT_HEAD, ...| - | - |

## switch

- [git@v2.23.0](https://github.com/git/git/blob/v2.23.0/Documentation/RelNotes/2.23.0.txt#L61) 부터 `git-checkout` 명령어는 `git-switch`와 `git-restore`로 분리되었다. 이유는 checkout이 하는 기능이 많았기 때문이다.
  - [Highlights from Git 2.23](https://github.blog/2019-08-16-highlights-from-git-2-23/) - GitHub Blog
  - [Git 2.23 Adds Switch and Restore Commands](https://www.infoq.com/news/2019/08/git-2-23-switch-restore/) - InfoQ

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
Fast-forwarded test-rebase to refs/remotes/origin/test-rebase.
```

### upstream

![Triangular Workflow](/images/shell/triangular-workflow.png)

*[Triangular Workflow](https://github.blog/2015-07-29-git-2-5-including-multiple-worktrees-and-triangular-workflows/)*

upstream이라는 용어는 헷갈릴 수 있다.
오픈 소스 프로젝트에서 보통 위와 같이 원본 저장소를 `upstream`이라고 부르고
그것을 fork한 저장소를 `origin`,
upstream에서 fetch한 로컬 환경을 `local`이라고 부른다.
아래 명령어는 지정한 `upstream` 브랜치로 push하도록 한다.

```bash
$ git push --set-upstream origin feature/test-upstream
# push 후
Branch 'feature/test-upstream' set up to track remote branch 'feature/test-upstream' from 'origin'.
```

잠깐. fork한 `origin` 저장소가 아니라 `upstream`으로 push한다?

사실 upstream이라는 용어는 Git에서만 쓰이는 건 아니다.
흔히 downstream과 대비해서 네트워크에서도 쓰이는 용어다.
예를 들어 로컬에서 원격으로, 클라이언트에서 서버로 데이터를 전송하는 것을 upstream이라고 말하고,
downstream은 그 반대이다.
즉, upload/download의 방향을 말하며 Git에서 upstream은 push하려는 방향을 말한다.

여기서 중요한 점은 Git에서 절대적인 upstream/downstream이 없다는 것이다.
Git은 DVCS(Distributed Version Control System)다.
다시 말해서 origin이 upstream일 수 있고, upstream은 또 다른 저장소의 downstream일 수 있다.
Triangular Workflow는 하나의 효과적인 방식이며, 해당 워크플로에서 `upstream`이라는 브랜치명을 사용하는 것뿐이다.

## branch

브랜치(branch)는 나뭇가지나 지점을 뜻한다.
흔히 말하는 master, main 브랜치는 줄기(trunk) 브랜치라고 불리는데
소스 코드 통합의 중심이 되는 브랜치이기 때문이다.

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

### xargs

eXtended ARGuments

- [When to Use xargs](https://www.baeldung.com/linux/xargs) - Baeldung

```bash
$ echo {0..9} | xargs -n 2
0 1
2 3
4 5
6 7
8 9
```

## fetch

커밋, 파일 및 참조를 원격 저장소에서 로컬 저장소로 다운로드한다.
fetch는 다른 사람들이 작업한 것을 보고 싶을 때 실행한다.

- [git-fetch](https://git-scm.com/docs/git-fetch) - git-scm
- [git fetch](https://www.atlassian.com/git/tutorials/syncing/git-fetch) - Atlassian

```bash
$ git fetch --all # Fetch all remotes.
$ git fetch <branch>

$ git merge <origin/branch> <commit>
$ git merge FETCH_HEAD
```

## commit

tracking 되고 있는 변경 사항들을 HEAD에 반영한다.
즉, staging area에 있는 변경 사항들을 local repository에 반영한다.

```bash
$ git commit
$ git commit -m "commit message"

# 커밋 author 변경
$ git commit --amend --author="Changsu Im <imcxsu@gmail.com>"
```

## rebase

> TODO: 정리

- [rebase는 Git의 꽃이다.](https://www.facebook.com/photo?fbid=4291246567585200) - 이규원
- [Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) - git-scm

## merge

소스 코드를 [3-way-merge](<https://en.wikipedia.org/wiki/Merge_(version_control)#Three-way_merge>) 방식을 통해 병합한다.

- [Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) - git-scm
- [Merging vs. Rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing) - Atlassian
- [3 way merge - 지옥에서 온 Git](https://youtu.be/J0W-WA0aYJI) - 생활코딩
- [Three-way merging: A look under the hood](https://blog.plasticscm.com/2016/02/three-way-merging-look-under-hood.html) - Plastic SCM

```bash
# hotfix 브랜치를 main으로 병합
$ git switch main
$ git merge hotfix

# fast-forward
# 새로운 커밋을 생성하지 않고 병합하려는 브랜치의 커밋을 그대로 병합한다.
$ git merge --ff

# no-fast-forward
# 현재 브랜치에 새로운 병합 커밋을 생성하고,
# 현재 브랜치와 병합하려는 브랜치 모두를 참조한다.
$ git merge --no-ff
```

## reset

- [Undoing Things](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things) - git-scm

```bash
# 현재 커밋에서 변경된 파일을 유지한 채 이전 커밋 지점으로만 이동한다.
# 변경된 파일은 unstaged 상태가 된다.
$ git reset HEAD^

# 현재 커밋을 삭제하고 이전 커밋으로 HEAD를 옮긴다.
# staged된 변경 사항은 제거되고, 아니면 유지된다.
$ git reset --hard HEAD^
```

```bash
# stage 파일을 unstage 상태로 변경하면서 변경 내용을 지운다.
$ git reset [--mixed] HEAD
# checkout에서 나뉜 restore가 같은 명령을 수행한다.
$ git restore --staged *

# 특정 파일을 변경된 부분까지 초기화하고 되돌린다.
# git checkout -- ${file_name}
$ git restore --staged ${file_name}
```

## revert

`reset`처럼 변경 사항을 되돌리지만 이력을 지우지 않고 변경 사항을 되돌리는 커밋을 생성한다.

```bash
$ git revert <commit>

Revert "이것은 4ea42dbe 커밋 메시지입니다."

This reverts commit 4ea42dbe6580e4f064091cd50b3c7cb2ab8b0e9b.
```

## [Git으로 버그 찾기](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-Git%EC%9C%BC%EB%A1%9C-%EB%B2%84%EA%B7%B8-%EC%B0%BE%EA%B8%B0) - git-scm

### blame

```bash
$ git blame -L 69,82 README.md
$ git blame -L 69 README.md
```

### bisect

```bash
$ git bisect start
$ git bisect bad
$ git bisect good v1.0
```

## log 그래프

```bash
$ git log --oneline --graph

$ git config --global alias.lg "log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
$ git lg
```

### [Git Alias](https://git-scm.com/book/ko/v2/Git%EC%9D%98-%EA%B8%B0%EC%B4%88-Git-Alias)

## diff

변경 사항을 비교한다.

- [Git diff](https://www.atlassian.com/git/tutorials/saving-changes/git-diff) - Atlassian
- [git-diff](https://git-scm.com/docs/git-diff) - git-scm

```bash
# 마지막 커밋과 그 전 커밋 비교
$ git diff HEAD~1 HEAD~0

# 현재 수정된 파일 내용(local)을 마지막 커밋 내용과 비교
$ git diff HEAD^

# 전전 커밋과 local 비교
$ git diff HEAD~2

# 특정 커밋 수정 확인하기
$ git diff <commit>~ <commit>
```

## cherry-pick

- [Git Cherry Pick](https://www.atlassian.com/git/tutorials/cherry-pick) - Atlassian
- [git-cherry-pick](https://git-scm.com/docs/git-cherry-pick) - git-scm

브랜치 상관없이 특정 커밋의 변경 사항들을 현재 HEAD에 반영한다.

```bash
$ git cherry-pick <commit>
```

## stash

stash는 숨겨둔다는 뜻으로 local에서 수정한 부분들을 잠시 저장해둘 수 있다.

```bash
$ git stash list # List the stash entries that you currently have.
$ git stash show # Show the changes recorded in the stash entry as a diff between the stashed contents and the commit back when the stash entry was first created.
$ git stash drop # Remove a single stash entry from the list of stash entries.
$ git stash push # Save your local modifications
$ git stash pop # Remove a single stashed state from the stash list and apply it on top of the current working tree state.
$ git stash apply # Like pop, but do not remove the state from the stash list.
$ git stash clear # Remove all stash entries
$ git stash create <message>
$ git stash store
```

## push

local 저장소의 내용을 remote 저장소에 반영한다.

- [git-push](https://git-scm.com/docs/git-push) - git-scm
- [git push](https://www.atlassian.com/git/tutorials/syncing/git-push) - Atlassian

```bash
$ git push origin main

$ git push --set-upstream origin feature/test-upstream
$ git push
```

# Advanced

## Git Hooks

Git 저장소에서 특정 이벤트가 발생할 때마다 자동으로 실행되는 스크립트다.
스크립트들은 기본적으로 `.git/hooks/*` 에 위치한다.

- [Git Hooks](https://www.atlassian.com/git/tutorials/git-hooks) - Atlassian
- [githooks](https://git-scm.com/docs/githooks) - git-scm

예를 들어, 아래와 같은 `pre-push` hook은 `git push` 명령어를 실행시켰을 때
`push` 가 실행되기 전 `gradle test` 명령어가 먼저 실행된다.

```bash
#!/usr/bin/env bash

# 해당 스크립트의 실행 권한을 부여한다.
# chmod +x .githooks/pre-push

# hooks 경로를 .githooks로 변경한다.
# git config core.hookspath .githooks

# `pre-push` hook은 `git push` 전 항상 실행되는 스크립트다.
gradle test
```

# Git 서버

## Branch protection rules

Pull Request를 통해서만 소스를 통합할 수 있도록 제약 사항을 설정했을 경우 아래와 같은 메시지를 확인할 수 있다.

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
