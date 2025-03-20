---
date: 2021-02-14T15:22:00+09:00
lastmod: 2021-02-14T15:22:00+09:00
title: "최소한의 안전한 Bash 스크립트 템플릿"
description: "Maciej Radzikowski"
# featured_image: "/images/shell/minimal-safe-bash-script-template.png"
images: ["/images/shell/minimal-safe-bash-script-template.png"]
socialshare: true
tags:
  - bash
  - shell
  - translate
Categories:
  - wiki
---

> - [Maciej Radzikowski](https://twitter.com/radzikowski_m)가 작성한 [Minimal safe Bash script template (2020-12-14)](https://betterdev.blog/minimal-safe-bash-script-template/)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

Bash 스크립트.
거의 모든 사람들이 언젠가 작성해야 하는 것입니다.
하지만 그 중 누구도 "맞아요, 저는 Bash 스크립트 작성하는 것을 사랑합니다"라고 말하지 않습니다.
거의 모든 사람들이 Bash 스크립트를 작성할 때 주의를 기울이지 않는 이유죠.

저는 여러분을 Bash 전문가로 만들려는 것이 아닙니다 (저도 전문가는 아닙니다).
다만 스크립트를 더 안전하게 만들어 줄 최소한의 템플릿을 보여 드리겠습니다.
저에게 감사해하실 필요는 없어요. 여러분의 미래가 여러분에게 감사해할 것입니다.

# Bash에서 스크립팅 하는 이유

Bash 스크립팅에 대한 가장 좋은 설명이 최근 저의 트위터 피드에 나타났습니다.

> "자전거 타는 거랑 비슷해"의 반대말은 "bash 프로그래밍이랑 비슷해"이다.\
> 몇 번을 했던지 상관없이 매번 다시 배워야 한다는 말.\
> \
> \- [Jake Wharton](https://twitter.com/JakeWharton/status/1334177665356587008)

하지만 Bash는 널리 사랑받는 언어인 JavaScript처럼 쉽게 사라지지 않을 것입니다.
주요 언어가 되지 않길 바라더라도 Bash는 항상 우리와 가까운 곳에 있습니다.

Bash는 [셸(shell) 왕좌를 물려받았고](https://www.quora.com/Is-Bash-considered-the-lingua-franca-of-shells/answer/Paul-Reiber)
Docker 이미지를 포함한 거의 모든 Linux에서 찾을 수 있습니다.
이는 대부분의 백엔드가 실행되는 환경입니다.
따라서 서버 애플리케이션 시작, CI/CD 또는 통합 테스트 실행을
스크립팅해야 하는 경우 Bash를 사용하면 됩니다.

몇 가지 명령을 이어 붙이고, 출력을 다른 명령으로 전달하고,
실행 파일을 시작하기 위해 Bash는 가장 쉽고 가장 기본적인 솔루션입니다.
더 크고 복잡한 스크립트를 다른 언어로 작성하는 것은 매우 타당한 일이지만
Python, Ruby, fish 또는 다른 인터프리터가 어디에서나 사용할 수 있을 것이라고 기대할 수는 없습니다.
또한 일부 프로덕션 서버, Docker 이미지 또는 CI 환경에 이 언어들을 추가하려면
두 번 생각해보고 또 다시 한 번 생각해 보아야 합니다.

하지만 Bash는 완벽하지 않습니다.
문법은 최악이고 에러 핸들링도 어렵습니다.
우리가 해결해야 하는 지뢰가 널려 있죠.

# Bash 스크립트 템플릿

거두절미하고 템플릿은 다음과 같습니다.

```bash
#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"
```

너무 길지 않게 만들려는 생각이었습니다.
저는 스크립트 로직때문에 500줄이나 스크롤하고 싶지 않습니다.
동시에 어떤 스크립트에서든 좋은 기반 스크립트가 되었으면 했습니다.
하지만 Bash는 의존성 관리라는 것이 없어서 쉽게 만들 수는 없었습니다.

한 가지 해결책은 처음부터 모든 보일러 플레이트 및 유틸리티
함수(function)가 있는 별도의 스크립트를 같이 실행시키는 것입니다.
이 방식의 단점은 "간단한 Bash 스크립트"라는 의도를 잃어버리고 항상
별도의 파일을 달고 다녀야 한다는 것입니다. 그래서 저는 템플릿을
가능한 한 짧게 만들기 위해 필수적인 것만을 템플릿에 넣자고 결정했습니다.

이제 좀 더 자세히 살펴보겠습니다.

## Bash 선택하기

```bash
#!/usr/bin/env bash
```

스크립트는 기본적으로 셔뱅(shebang)[^1]으로 시작합니다.
[최적의 호환성](https://stackoverflow.com/questions/21612980/why-is-usr-bin-env-bash-superior-to-bin-bash)을 위해
`/bin/bash`가 아닌 `/usr/bin/env`를 참조합니다.
링크된 StackOverflow 질문의 답변을 읽어 보시면
이 경우에도 오류가 발생할 수는 있습니다.

[^1]: [셔뱅](https://ko.wikipedia.org/wiki/%EC%85%94%EB%B1%85)이란 해시 기호와 느낌표(`#!`)로 이루어진 문자 시퀀스로 인터프리터 지시자(interpreter directive)를 지정합니다. 지정하려는 인터프리터 프로그램은 절대경로로 표시합니다.

## 빠르게 실패하기

```bash
set -Eeuo pipefail
```

`set` 명령어는 스크립트 실행 옵션을 변경합니다.
예를 들면 **기본적으로 Bash는 일부 명령이 실패하는 것과 상관없이**
0 외의 종료 상태 코드를 반환합니다. 다음 단계로 잘 넘어갑니다.
이제 다음과 같이 짧은 스크립트를 살펴보겠습니다.

```bash
#!/usr/bin/env bash
cp important_file ./backups/
rm important_file
```

여기서 `backups` 디렉토리가 존재하지 않을 경우 어떻게 될까요?
정확히 말하면 콘솔에 오류 메시지가 표시되지만
응답하기 전에 두 번째 명령에 의해 파일이 이미 제거됩니다.

`set -Eeuo pipefail` 옵션들이 정확하게 무엇을 바꾸는지,
어떻게 사용자를 보호할 것인지에 대한 자세한 내용은
[몇 년 동안 제 북마크에 있는 글](https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/)을 참조해주세요.

하지만 [이러한 옵션 설정에 대해 몇 가지 반론](https://www.reddit.com/r/commandline/comments/g1vsxk/the_first_two_statements_of_your_bash_script/fniifmk/)이 있다는 것을 알고 있어야 합니다.

## 위치 가져오기

```bash
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
```

이 줄은 스크립트가 위치한 디렉토리를 지정하는 데 가장 효과적이며, ~~여기에 `cd`를 붙입니다.~~

스크립트가 작업 디렉토리에 있다면 스크립트가 상대 경로로 동작하며
파일을 복사하고 명령어를 실행합니다.
동일한 디렉토리에서 스크립트를 실행하는 한 그렇습니다.

하지만 CI 구성에서 다음과 같은 스크립트를 실행한다면

```bash
/opt/ci/project/script.sh
```

이 스크립트는 프로젝트 디렉토리가 아니라 CI 도구의 다른 작업 디렉토리에서 동작합니다.
스크립트를 실행하기 전에 해당 디렉토리로 이동함으로써 고칠 수 있습니다.

```bash
cd /opt/ci/project && ./script.sh
```

그래도 스크립트 쪽에서 해결하는 게 훨씬 좋습니다.
스크립트가 일부 파일을 읽거나 동일한 디렉터리에서
다른 프로그램을 실행하려는 경우 아래처럼 호출합니다.

```bash
cat "$script_dir/my_file"
```

동시에 스크립트는 작업 디렉토리 위치를 변경하지 않습니다.
스크립트가 다른 디렉토리에서 실행되어 사용자가 일부 파일에 대한
상대 경로를 제공하더라도 해당 스크립트를 읽을 수 있습니다.

## 정리하기

```bash
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}
```

스크립트의 `trap`을 `finally` 블록으로 생각해 보세요.
보통 오류나 외부 신호에 의해 스크립트가 끝나면 `cleanup()` 함수가 실행됩니다.
예를 들어 스크립트가 생성한 모든 임시 파일들을 제거할 수 있습니다.

`cleanup()`은 끝날 때뿐만 아니라 스크립트가 특정 부분만 제거할 수도 있다는 것을 기억하세요.
제거하려는 자원이 반드시 있어야 하는 것은 아닙니다.

## 도움되는 도움말 표시하기

```bash
usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

...
EOF
  exit
}
```

`usage()` 함수가 상대적으로 스크립트 상단에 있을 경우 다음 두 가지 방식으로 동작합니다.

- 모든 옵션을 아는 것도 아니면서 스크립트 전체를 보고 싶지 않은 사용자를 위해 `도움말을 표시합니다`.
- 스크립트 수정 시 `최소한의 문서`입니다. (예: 2주 후, 무엇을 작성했는지 떠올릴 필요가 없습니다)

여기에 모든 함수를 기록해야 한다고 말하는 것은 아닙니다.
그러나 짧고 적절한 스크립트 사용법(usage) 메시지는 필수 항목입니다.

## 적절한 메시지 출력하기

```bash
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}
```

먼저 텍스트에서 색상을 사용하지 않으려면 `setup_colors()` 함수를 지우세요.
하지만 저는 매번 코드를 구글에다 검색하지 않는다면
색상을 더 자주 사용할 수 있다는 것을 알기 때문에 지우지 않습니다.

둘째로, 이러한 **색상은 `msg()` 함수에만 사용하도록 되어 있고** `echo` 명령에는 사용되지 않습니다.

`msg()` 함수는 스크립트 출력을 제외한 모든 것을 출력하는 데 사용됩니다.
여기에는 오류뿐만 아니라 모든 로그와 메시지가 포함됩니다.
[12 팩터 CLI 앱](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)이라는 좋은 글을 인용합니다.

> **_요컨대 stdout은 출력용이고 stderr는 메시지용입니다._**
>
> [Jeff Dickey](https://jdxcode.com/), who [knows a little](https://github.com/oclif/oclif/graphs/contributors) about [building CLI apps](https://github.com/heroku/cli/graphs/contributors)

그래서 대부분의 경우 `stdout`에 색상을 사용하지 않는 것이 좋습니다.

`msg()`로 출력된 메시지는 `stderr` 스트림으로 전송되며 색상과 같은 특수 시퀀스를 지원합니다.
또한 `stderr` 출력이 대화형 터미널이 아니거나 [표준 파라미터 중 하나](https://no-color.org/)가 전달되면 색상이 비활성화됩니다.

사용법:

```bash
msg "This is a ${RED}very important${NOFORMAT} message, but not a script output value!"
```

`stderr`가 대화형 터미널이 아닐 때 어떻게 작동하는지 확인하려면 스크립트에 위와 같은 줄을 추가하세요.
그런 다음 `stderr`를 `stdout`으로 리다이렉션하고 cat에 보내줍니다(pipe).
파이프가 동작하면 출력이 더 이상 터미널로 직접 전송되지 않고 다음 명령으로
전송되므로 이제 색상을 사용하지 않도록 설정해야 합니다.

```bash
$ ./test.sh 2>&1 | cat
This is a very important message, but not a script output value!
```

## 모든 파라미터 파싱

```bash
parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}
```

스크립트에서 파라미터로 만들어야 하는 것이 있다면, 저는 보통 그렇게 합니다.
스크립트가 한 곳에서만 사용되더라도 마찬가지입니다.
이렇게 하면 복사 및 재사용이 쉬워지며, 이 작업은 종종 더 빠릅니다.
또한 하드 코딩이 필요한 부분이 있더라도 일반적으로 Bash 스크립트보다 더 높은 수준입니다.

플래그(flags), 지정된 파라미터(named parameters, keyword arguments) 및 위치 인자(positional arguments)라는
[세 가지 주요 CLI 파라미터 유형](https://betterdev.blog/command-line-arguments-anatomy-explained/)이 있습니다[^2].
`parse_params()` 함수는 모두 지원합니다.

[^2]: 간단히 말하면,
'플래그'는 `true`, `false`를 인자로 받으며 `true`일 경우 생략할 수 있습니다.
'지정된 파라미터'는 파라미터와 함께 특정 값을 인자로 지정해야 합니다.
'위치 인자'는 인자를 적합한 위치에 지정해야 합니다.

여기서 처리되지 않는 유일한 공통 파라미터 패턴은
[여러 개의 단일 문자 플래그를 연결하는](https://betterdev.blog/command-line-arguments-anatomy-explained/#flags_and_named_arguments) 것입니다.
`-a -b`처럼 두 개의 플래그가 아닌 `-ab`로 전달하려면 추가 코드가 필요합니다.

`while` 루프는 파라미터들을 수동으로 파싱하는 방법입니다.
다른 모든 언어에서는 [내장 파서](https://docs.python.org/3/library/argparse.html)
또는 [사용 가능한 라이브러리](https://yargs.js.org/)를 사용해야 합니다.
하지만 우리가 사용하려는 것은 Bash입니다.

템플릿에 플래그(`-f`)와 지정된 파라미터(`-p`)가 예시로 있습니다.
다른 파라미터를 추가하기 위해서는 변경하거나 복사하기만 하면 됩니다.
그후 잊지 말고 `usage()` 함수를 업데이트하세요.

여기서 중요한 것은 **알 수 없는 옵션에 오류를 던지는 것**입니다.
Bash 인자 파싱에 대한 Google 검색 결과를 보면 일반적으로 놓치는 것입니다.
스크립트가 알 수 없는 옵션을 받았다는 것은 스크립트가 수행할 수
없는 작업을 사용자는 수행하기를 원했음을 의미합니다.
따라서 사용자의 기대와 스크립트 동작은 상당히 다를 수 있습니다.
좋지 않은 일이 일어나기 전에 실행을 아예 막는 것이 좋습니다.

Bash에는 파라미터를 파싱하는 두 가지 대안이 있습니다. `getopt`와 `getopts`입니다.
이 명령어들을 사용하는 것에 대한 [찬성과 반대 의견](https://unix.stackexchange.com/questions/62950/getopt-getopts-or-manual-parsing-what-to-use-when-i-want-to-support-both-shor)이 있습니다.
기본적으로 macOS의 `getopt`가 [완전히 다르게 동작](https://stackoverflow.com/questions/11777695/why-the-getopt-doesnt-work-well-in-my-mac-os)하고,
`getopts`가 긴 파라미터(예: `--help`)를 지원하지 않기 때문에 이러한 도구가 최선은 아니라는 것을 알게 되었습니다.

# 템플릿 사용하기

인터넷에서 찾을 수 있는 대부분의 코드처럼 복사-붙여넣기만 하면 됩니다.

음, 사실은 말하자면요.
Bash를 사용하면 `npm install`과 같은 범용 기능이 없습니다.

복사한 후에는 4가지 항목만 변경하면 됩니다.

- 스크립트에 대한 설명이 있는 `usage()` 텍스트
- 관련 내용 `cleanup()`
- `parse_params()`의 파라미터 - `--help`와 `--no-color`는 그대로 두고 예시(`-f`, `-p`)는 변경하세요.
- 실제 스크립트 로직

# 이식성 (Portability)

MacOS (기본적으로 구식 Bash 3.2)와 몇몇의 Docker 이미지에서 템플릿을 테스트했습니다.
Debian, Ubuntu, CentOS, Amazon Linux, Fedora입니다. 제대로 동작합니다.

분명히 Alpine Linux와 같은 Bash가 빠진 환경에서는 작동하지 않을 것입니다.
Alpine은 미니멀리즘 시스템으로서 매우 가벼운 ash (Almquist shell)를 사용합니다.

거의 모든 곳에서 작동하는
[본 셸](https://en.wikipedia.org/wiki/Bourne_shell)(Bourne shell, `/bin/sh`)
호환 스크립트를 사용하는 것이 좋지 않냐고 질문할 수 있습니다.
적어도 저에게는 그렇지 않습니다.
Bash는 (아직도 사용하기 쉽지 않지만) 더 안전하고 강력하기 때문에
거의 다룰 일 없는 몇 가지 리눅스 배포판을 지원하지 않는 것 정도는 받아들일 수 있습니다.

# 더 읽을 거리

Bash 또는 기타 ~~더 나은~~ 언어로 CLI 스크립트를 만들 때 몇 가지 범용 규칙이 있습니다.
다음 자료들은 작은 스크립트와 대형 CLI 애플리케이션을 안정적으로 만드는 방법으로 안내합니다.

- [명령행 인터페이스 가이드라인](https://clig.dev/)
- [12 팩터 CLI 앱](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)
- [예시를 들어 설명하는 명령행 인자 구조](https://betterdev.blog/command-line-arguments-anatomy-explained/)

# 끝맺음

제가 Bash 스크립트 템플릿을 만든 첫 번째이자 마지막이 아닙니다.
좋은 대안 중 하나는 [이 프로젝트](https://github.com/ralish/bash-script-template)입니다.
비록 제가 매일 필요로 하는 것에 비해 조금 크긴 하지만요.
결국 저는 Bash 스크립트를 가능한 한 작게 (그리고 희한하게) 유지하려고 노력합니다.

Bash 스크립트를 작성할 때 JetBrains IDE와 같이
[ShellCheck](https://github.com/koalaman/shellcheck) 린터를 지원하는 IDE를 사용하십시오.
이것은 당신에게 역효과를 줄 수 있는 [많은 것](https://github.com/koalaman/shellcheck/blob/master/README.md#user-content-gallery-of-bad-code)들을 하지 못하게 할 것입니다.

저의 Bash 스크립트 템플릿은 GitHub Gist(MIT 라이센스)처럼 사용할 수 있습니다.

[script-template.sh](https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038)

템플릿에 문제가 있거나 중요한 항목이 빠졌다고 생각되면 [코멘트](https://betterdev.blog/minimal-safe-bash-script-template/)로 알려 주세요.

## 업데이트 2020-12-15

[Reddit](https://www.reddit.com/r/programming/duplicates/kcxnag/minimal_safe_bash_script_template/)과
[HackerNews](https://news.ycombinator.com/item?id=25428621)에서 많은 코멘트를 받은 후
템플릿을 개선했습니다.
개정 이력을 [gist](https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038)에서 확인하세요.

## 업데이트 2020-12-16

이 게시물에 대한 링크는 [Hacker News의 첫 페이지(#7)](https://news.ycombinator.com/front?day=2020-12-15)에 도달했습니다.
상상도 못한 일이었습니다.
