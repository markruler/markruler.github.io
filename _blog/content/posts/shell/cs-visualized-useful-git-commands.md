---
date: 2021-01-09T08:35:00+09:00
title: "CS Visualized: 유용한 깃(Git) 명령어"
description: "Lydia Hallie"
featured_image: "/images/shell/lydia/git-commands-visualized.png"
images: ["/images/shell/lydia/git-commands-visualized.png"]
socialshare: true
tags:
  - git
  - Lydia-Hallie
  - translate
Categories:
  - shell
---

> - 리디아 할리(Lydia Hallie, [@lydiahallie](https://twitter.com/lydiahallie))가 쓴 [CS Visualized: Useful Git Commands](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

Git이 정말 강력한 도구이긴 하지만, 대다수의 사람들은 끔찍한 악몽 😐
같다는 말도 공감할 거에요. 저는 항상 Git으로 작업할 때 어떤 일이 일어날지
머릿속으로 그려보는 것이 꽤 유용하다는 것을 알았습니다. 특정 명령을 실행할
때 브랜치는 어떻게 상호작용하고, 그것이 히스토리에 어떤 영향을 미칠까요?
`master`에서 하드 리셋하고 `origin` 리포지터리로 `force push`한 후,
`.git` 폴더를 `rimraf`하면 왜 동료가 아우성칠까요?

저는 가장 많이 쓰이면서 유용한 명령을 시각화하는 것이 완벽한 유즈 케이스라고 생각했습니다! 🥳
제가 다룰 명령어들은 동작을 바꾸기 위해 사용할 수 있는 전달 인자가 있습니다.
여기 예시에서는 (수많은) 설정 옵션 없이 명령어의 기본 동작에 대해 설명하겠습니다. 😄

---

# 병합 (Merge)

브랜치가 여러 개 있으면 분리된 수정 사항을 관리하기가 매우 편리합니다.
그리고 승인되지 않았거나 잘못된 수정 사항을 실수로 운영 환경에 푸시하지
않도록 하는 데에도 편리합니다. 수정 사항이 승인됐다면 운영 환경
브랜치에 적용해야 하죠!

한 브랜치에서 다른 브랜치로 수정 사항을 옮기는 한 가지 방법은
`git merge`를 실행하는 것입니다! Git이 수행할 수 있는 병합에는
**fast-forward**, **no-fast-forward**라는 두 가지 유형이 있습니다. 🐢

지금 당장은 무슨 말인지 이해되지 않으실테니 차이점을 살펴보도록 하겠습니다!

## Fast-forward (`--ff`)

**fast-forward 병합**은 현재 브랜치에 병합하려는 브랜치에 비해 추가
커밋이 없을 때 발생할 수 있습니다. Git은... *게을러서* 가장 쉬운
옵션인 fast-forward부터 시도하려 할 것입니다! 이 방식은 새로운
커밋을 생성하지 않고 병합하려는 브랜치의 커밋을 그대로 병합합니다. 🥳

![merge-ff](/images/shell/lydia/merge-ff.gif)

Perfect! 우리는 이제 `dev` 브랜치에서 만든 모든 수정 사항을
`master` 브랜치에서도 접근할 수 있게 되었습니다. 그럼
**no-fast-forward**는 뭘까요?

## No-fast-foward (`--no-ff`)

병합하려는 브랜치와 비교해 현재 브랜치에 추가 커밋이 없는 경우가 좋겠지만
안타깝게도 그런 경우는 거의 없습니다! 병합할 브랜치에 없는 수정 사항을 현재 브랜치에 커밋한 경우
Git은 *no-fast-forward* 병합을 수행합니다.

Git은 no-fast-forward을 사용해 현재 브랜치에 새로운 *병합 커밋*을 생성합니다.
상위 커밋은 현재 브랜치와 병합하려는 브랜치 모두를 가리킵니다!

![merge-no-ff](/images/shell/lydia/merge-no-ff.gif)

별 거 아니지만 완벽해요! 🎉
이제 `master` 브랜치는 `dev` 브랜치에서 수정한 내용을 모두 포함합니다.

## 병합 충돌 (Merge conflicts)

어떻게 브랜치를 병합하고 파일에 수정 사항을 추가할지 Git이 잘 결정할테지만,
Git이 항상 혼자 결정할 수는 없습니다. 🙂 병합하려는 두 개의 브랜치가 똑같은
파일, 똑같은 줄에 수정 사항이 있거나 한 브랜치가 다른 브랜치에서 수정한 파일을
삭제하는 경우 등 문제가 발생할 수 있습니다.

이런 경우 Git이 두 가지 중 어떤 내용을 유지하고 싶은지 물어볼 것입니다!
두 브랜치 모두에서 `README.md`의 첫번째 줄을 편집했다고 가정해 보겠습니다.

![readme](/images/shell/lydia/readme.png)

`dev`를 `master`로 병합하려는 경우 병합 충돌이 발생합니다.
그럼 제목을 `Hello!` 또는 `Hey!` 중 어떤 걸로 지정하실래요?

브랜치를 병합하려고 하면 Git은 충돌이 발생한 위치를 보여줄 겁니다.
버리고 싶은 수정 사항을 수동으로 제거하고 저장한 후,
수정된 파일을 다시 추가하면 커밋할 수 있게 됩니다. 🥳

![merge-conflict](/images/shell/lydia/merge-conflict.gif)

Yay! 병합 충돌은 정말 번거롭지만 꼭 필요한 과정입니다.
Git은 단순히 우리가 유지하고자 하는 수정 사항을 *가정*해서는 안 됩니다.

---

# 리베이스 (Rebase)

방금 `git merge`를 수행하여 한 브랜치에서 다른 브랜치로 수정 사항을 적용하는 방법을
보았습니다. 여기에 또 한 가지 방법이 있는데 바로 `git rebase`입니다.

`git rebase`는 현재 브랜치에서 커밋을 복사하고
복사된 커밋을 지정한 브랜치 맨 위에 놓습니다.

![rebase](/images/shell/lydia/rebase.gif)

Perfect! 이제 `master` 브랜치의 모든 수정 사항을
`dev` 브랜치에서도 사용할 수 있게 되었습니다! 🎊

`git merge`와 비교할 때 큰 차이점은 Git이 유지할 파일과 유지하지 않을 파일을 물어보지
않았는다는 거에요. 리베이스 하는 브랜치에는 항상 최근 수정 사항이 적용됩니다!
이러한 방식으로 병합 충돌은 발생하지 않고 Git 히스토리를 선형으로 유지하죠.

이 예에서는 `master` 브랜치에 대한 리베이스를 보여 줍니다.
그러나 더 큰 프로젝트에서는 대개 이렇게 하고 싶지 않을 거에요.
`git rebase`는 복사된 커밋의 해시가 새로 생성될 때
**프로젝트 히스토리를 변형시킵니다**!

리베이스는 `feature` 브랜치에서 작업할 때나 `master` 브랜치가 업데이트될 때 유용합니다.
브랜치에서 모든 업데이트를 받을 수 있으므로 이후 병합 충돌을 방지할 수 있거든요! 😄

## 대화형 리베이스 (`-i` interactive rebase)

*대화형 리베이스*를 사용하면 커밋을 리베이스 하기 전에 변형시킬 수도 있어요! 😃
대화형 리베이스는 현재 작업 중인 브랜치에서 일부 커밋을 수정하고 싶은 경우 유용할 수 있습니다.

리베이스 작업중인 커밋에 대해 수행할 수 있는 명령어는 6가지가 있습니다.

- `reword`: 커밋 메시지 수정
- `edit`: 커밋 수정
- `squash`: 이전 커밋과 혼합
- `fixup`: 커밋 로그 메시지를 유지하지 않고 이전 커밋과 혼합
- `exec`: 리베이스하려는 커밋마다 명령어 실행
- `drop`: 커밋 삭제

Awesome! 이 명령어들을 사용해 커밋을 완전히 제어할 수 있습니다.
만약 커밋을 지우고 싶다면 그냥 `drop`하세요.

![rebase-drop](/images/shell/lydia/rebase-drop.gif)

만약 깨끗한 히스토리를 유지하고 싶다면 여러 커밋들을 `squash`하시면 됩니다. 문제 없어요!

![rebase-squash](/images/shell/lydia/rebase-squash.gif)

대화형 리베이스는 커밋을 제어하는 다양한 방법을 제공합니다.
현재 작업 중인 브랜치라도 말이죠!

---

# 리셋 (Reset)

나중에 원치 않는 수정 사항을 커밋할 수도 있어요.
`WIP`[^1] 커밋이거나 버그가 발견된 커밋일 수도 있죠! 🐛
그런 경우에 `git reset` 명령어를 사용할 수 있습니다.

[^1]: WIP (Work in Progress): 진행 중인 작업

`git reset`은 스테이징[^2]된 파일을 제거하거나
`HEAD`가 가리키는 곳을 제어할 수 있습니다.

[^2]: 현재 작업 중인 "working directory"를 `git add` 하면 "staging area"로 옮겨진다. 그 후 `git commit`을 하면 "local repository"로 옮겨진다. 여기서 `git push`를 명령할 경우 마침내 "remote repository"로 간다.

## 소프트 리셋 (`--soft`)

*소프트 리셋*은 `HEAD`를 지정된 커밋으로 옮기거나 해당 커밋의 인덱스를 `HEAD`와 비교합니다.
나중에 커밋된 수정 사항들을 제거하지 않고서 말이죠!

`style.css` 파일을 추가한 `9e78i` 커밋과
`index.js` 파일을 추가한 `035cc` 커밋을 유지하고 싶지 않다고 가정해 보겠습니다.
하지만 새로 추가된 `style.css`와 `index.js` 파일은 유지하고 싶어요!
그럼 소프트 리셋을 위한 완벽한 유즈 케이스입니다.

![reset-soft](/images/shell/lydia/reset-soft.gif)

`git status`를 입력하면 아직 이전 커밋에서 수정한 모든 내용에 접근할 수 있다는 것을 알 수 있습니다.
이렇게 파일의 내용을 수정하고 또 다시 커밋할 수 있으니 좋은 방법입니다!

## 하드 리셋 (`--hard`)

때로는 특정 커밋에 의해 반영된 수정 사항을 유지하고 싶지 않을 겁니다.
그럼 소프트 리셋과 달리 더 이상 수정 사항에 접근할 필요가 없겠죠.
Git은 지정된 커밋의 상태로 간단하게 리셋합니다.
여기에는 워킹 디렉토리와 스테이징된 파일의 수정 사항도 포함됩니다! 💣

![reset-hard](/images/shell/lydia/reset-hard.gif)

Git은 `9e78i`와 `035cc` 커밋에 반영된 수정 사항을 버리고
`ec5be`커밋으로 다시 상태를 리셋했습니다.

---

# 리버트 (Revert)

수정 사항을 되돌리는 또 다른 방법은 `git revert` 하는 것입니다.
특정 커밋을 리버트하면 *새로운 커밋*이 생성되고 여기에는 리버트된 수정 사항이 포함됩니다!

`ec5be` 커밋으로 `index.js` 파일이 추가됐다고 가정해 보겠습니다.
그리고 나중에서야 이 수정 사항이 더 이상 필요없다는 것을 느끼죠!
이제 `ec5be` 커밋을 되돌려보겠습니다.

![revert](/images/shell/lydia/revert.gif)

Perfect! `9e78i` 커밋은 `ec5be` 커밋에 반영된 수정 사항을 제거했습니다.
`git revert`를 실행하면 브랜치의 히스토리를 수정하지 않고 특정 커밋을 되돌릴 수 있습니다.

---

# 체리 피킹 (Cherry-pick)

특정 브랜치에 우리에게 필요한 수정 사항을 가진 커밋이 있다면,
`cherry-pick` 명령어를 사용할 수 있습니다! 커밋을 `cherry-pick`하면
`cherry-pick` 커밋에 담긴 수정 사항을 포함해 현재 브랜치에 새로운 커밋을 만듭니다.

`dev` 브랜치의 `76d12` 커밋이 `master` 브랜치에서 원하는 수정 사항을
`index.js` 파일에 추가했다고 가정해 보세요. 그럼 *다른 커밋*들은 필요없고
단 한 가지 커밋만 있으면 됩니다!

![cherry-pick](/images/shell/lydia/cherry-pick.gif)

---

# 페치 (Fetch)

현재 브랜치에 없는 커밋이 원격 브랜치에 생길 수 있습니다!
예를 들어 다른 브랜치가 병합된다거나 동료가 빠르게 수정 사항을 푸시하는 경우 등이 있죠.

`git fetch`를 실행해서 원격 브랜치의 수정 사항을 로컬로 가져올 수 있습니다!
`fetch`는 단순히 새로운 데이터를 다운로드 하는 것일 뿐이지, 로컬 브랜치에 영향을 끼치지는
않습니다.

![git-fetch](/images/shell/lydia/git-fetch.gif)

---

# 풀 (Pull)

브랜치의 원격 데이터를 가져오기 위해서는 `git fetch`도 유용하지만 `git pull`도 좋습니다.
`git pull`은 `git fetch`와 `git merge` 두 가지 명령을 합친 것입니다.
`origin` 저장소에서 수정 사항을 풀(pull)할 때 먼저 `git fetch` 명령처럼
모든 데이터를 가져온 후 최신 수정 사항을 자동으로 로컬 브랜치에 병합합니다.

![git-pull](/images/shell/lydia/git-pull.gif)

Awesome! 이제 원격 브랜치와 완전히 동기화되었고 최신 수정 사항이 모두 반영되었습니다! 🤩

---

# 레프-로그 (Reflog)

모든 사람은 실수를 합니다. 지극히 정상이에요!
때로는 Git 저장소를 망쳐버려서 완전히 삭제하고 싶은 충동을 느낄 수도 있습니다.

`git reflog`는 실행된 작업 로그를 모두 표시하는 데 정말 유용한 명령입니다!
여기에는 병합, 리셋, 리버트 등 기본적으로 브랜치에 대한 모든 수정 사항이 포함됩니다.

![git-reflog](/images/shell/lydia/git-reflog.gif)

실수를 했다면 `reflog`가 주는 정보를 바탕으로 `HEAD`를 리셋해서 쉽게 되돌릴 수 있습니다!

`origin` 저장소의 브랜치를 병합하지 않고 싶다고 가정해보세요.
`git reflog` 명령어를 실행하면 병합 전의 저장소 상태가 `HEAD@{1}`로 표시됩니다.
`git reset`을 수행하여 헤드가 `head@{1}`으로 돌아가도록 합니다!

![reset-reflog](/images/shell/lydia/reset-reflog.gif)

리셋 명령으로 `reflog`가 밀린 것을 볼 수 있습니다!

---

Git에는 유용한 포셀린(porcelain) 명령어와 플러밍(plumbing) 명령어[^3]가 너무
많아서 모두 다룰 수 있었으면 좋겠어요! 😄 다른 명령어나 대안들이 많아서 미처
다룰 시간이 없었다는 것을 이해해주세요. 좋아하는 명령어나 가장 유용한 명령어가
무엇인지 알려주시면 제가 다른 글에서 다룰 수도 있습니다!

[^3]: [저수준의 명령어는 "Plumbing" 명령어라고 부르고 좀 더 사용자에게 친숙한 사용자용 명령어는 "Porcelain" 명령어라고 부른다.](https://git-scm.com/book/ko/v2/Git%EC%9D%98-%EB%82%B4%EB%B6%80-Plumbing-%EB%AA%85%EB%A0%B9%EA%B3%BC-Porcelain-%EB%AA%85%EB%A0%B9)

그리고 언제나 그랬듯이 저(Lydia Hallie)와 소통해요! 😊

|✨|👩🏽‍💻|💻|💡|📷|💌|
|---|---|---|---|---|---|---|
|[Twitter](https://www.twitter.com/lydiahallie)|[Instagram](https://www.instagram.com/theavocoder)|[GitHub](https://www.github.com/lydiahallie)|[LinkedIn](https://www.linkedin.com/in/lydia-hallie)|[YouTube](https://www.youtube.com/channel/UC4EWKIKdKiDtAscQ9BIXwUw)|[Email](mailto:lydiahallie.dev@gmail.com)|
