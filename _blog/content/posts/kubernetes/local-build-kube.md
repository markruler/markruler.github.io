---
date: 2020-10-11T14:48:00+09:00
title: "쿠버네티스 컴포넌트를 로컬에서 직접 빌드 및 디버깅하기"
description: "Github/kubernetes"
featured_image: "/images/kubernetes/vscode-debugging-golang.png"
tags:
  - kubernetes
categories:
  - cloud
---

> 직접 빌드해서 사용한다면 쿠버네티스 기능을 확장해서 사용할 수 있다.

## Reference

- [kubernetes/build/README.md](https://github.com/kubernetes/kubernetes/blob/release-1.19/build/README.md)

## 사용할 명령어

```bash
# master 브랜치
git clone --depth 1 https://github.com/kubernetes/kubernetes.git
# 특정 브랜치
git clone --depth 1 --single-branch --branch release-1.19 https://github.com/kubernetes/kubernetes.git

# cmd 디렉터리에 있는 다른 컴포넌트도 같은 방식으로 빌드할 수 있다.
# cmd/kubeadm, kubectl, kubelet, kube-apiserver, kube-proxy, kube-controller-manager, kube-scheduler, ...
make all WHAT=cmd/kubectl GOFLAGS=-v

# 그냥 간단히 go build 명령도 가능하다.
go build -o k cmd/kubectl
```

## 빌드 실행 따라가기

### Makefile

- make 명령을 내릴 루트 디렉터리 Makefile을 보면 아래와 같이 다른 Makefile을 가리킨다.

```bash
build/root/Makefile
```

### 실제로 빌드되는 Makefile

> [build/root/Makefile](https://github.com/kubernetes/kubernetes/blob/release-1.19/build/root/Makefile)

- all 타겟은 WHAT 전달인자와 함께 build.sh 쉘 스크립트 파일을 실행시킨다.

```makefile
# Build code.
#
# Args:
#   WHAT: Directory names to build.  If any of these directories has a 'main'
#     package, the build will produce executable files under $(OUT_DIR)/bin.
#     If not specified, "everything" will be built.
#   GOFLAGS: Extra flags to pass to 'go' when building.
#   GOLDFLAGS: Extra linking flags passed to 'go' when building.
#   GOGCFLAGS: Additional go compile flags passed to 'go' when building.
#
# Example:
#   make
#   make all
#   make all WHAT=cmd/kubelet GOFLAGS=-v
#   make all GOLDFLAGS=""
#     Note: Specify GOLDFLAGS as an empty string for building unstripped binaries, which allows
#           you to use code debugging tools like delve. When GOLDFLAGS is unspecified, it defaults
#           to "-s -w" which strips debug information. Other flags that can be used for GOLDFLAGS 
#           are documented at https://golang.org/cmd/link/
endef
.PHONY: all
ifeq ($(PRINT_HELP),y)
all:
	@echo "$$ALL_HELP_INFO"
else
all: generated_files
	hack/make-rules/build.sh $(WHAT)
endif
```

### all: generated_files

> [hack/make-rules/build.sh](https://github.com/kubernetes/kubernetes/blob/release-1.19/hack/make-rules/build.sh)

```bash
#!/usr/bin/env bash

# This script sets up a go workspace locally and builds all go components.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..
KUBE_VERBOSE="${KUBE_VERBOSE:-1}"
source "${KUBE_ROOT}/hack/lib/init.sh"

# 👉 hack/lib/golang.sh
kube::golang::build_binaries "$@"
kube::golang::place_bins
```

### kube::golang::

> [hack/lib/golang.sh](https://github.com/kubernetes/kubernetes/blob/release-1.19/hack/lib/golang.sh)

- 참고로 쉘 스크립트의 function 키워드는 생략할 수 있으며, double colon(::)은 쿠버네티스의 Naming Convection으로 보인다.

```bash
# Build binaries targets specified
#
# Input:
#   $@ - targets and go flags.  If no targets are set then all binaries targets
#     are built.
#   KUBE_BUILD_PLATFORMS - Incoming variable of targets to build for.  If unset
#     then just the host architecture is built.
kube::golang::build_binaries() {
  ...
}

# This will take binaries from $GOPATH/bin and copy them to the appropriate
# place in ${KUBE_OUTPUT_BINDIR}
#
# Ideally this wouldn't be necessary and we could just set GOBIN to
# KUBE_OUTPUT_BINDIR but that won't work in the face of cross compilation.  'go
# install' will place binaries that match the host platform directly in $GOBIN
# while placing cross compiled binaries into `platform_arch` subdirs.  This
# complicates pretty much everything else we do around packaging and such.
kube::golang::place_bins() {
  ...
  # V=2 kube::log::status ${KUBE_OUTPUT_BINPATH}
  # 위 로그 함수를 추가해서 빌드하면 어디에 빌드되었는지 확인할 수 있다.
  # > [%m%d %H:%M:%S] /home/kubernetes/kubernetes/_output/local/bin
}
```

### 로그 레벨

> [hack/lib/logging.sh](https://github.com/kubernetes/kubernetes/blob/master/hack/lib/logging.sh)

```makefile
# This controls the verbosity of the build. Higher numbers mean more output.
KUBE_VERBOSE ?= 4
# 찾아보면 V=4까지 있는 것 같아서 4로 지정했다.

# 👉 hack/lib/logging.sh
kube::log::status() {
  local V="${V:-0}"
  if [[ ${KUBE_VERBOSE} < ${V} ]]; then
    return
  fi

  timestamp=$(date +"[%m%d %H:%M:%S]")
  echo "+++ ${timestamp} ${1}"
  shift
  for message; do
    echo "    ${message}"
  done
}
```

### cmd/kubectl

> [kubectl.go](https://github.com/kubernetes/kubernetes/blob/release-1.19/cmd/kubectl/kubectl.go)

```go
package main

import (
	goflag "flag"
	"math/rand"
	"os"
	"time"

	"github.com/spf13/pflag"

	cliflag "k8s.io/component-base/cli/flag"
	"k8s.io/kubectl/pkg/util/logs"
	"k8s.io/kubernetes/pkg/kubectl/cmd"

	// Import to initialize client auth plugins.
	_ "k8s.io/client-go/plugin/pkg/client/auth"
)

func main() {
	rand.Seed(time.Now().UnixNano())

	command := cmd.NewDefaultKubectlCommand()

	// TODO: once we switch everything over to Cobra commands, we can go back to calling
	// cliflag.InitFlags() (by removing its pflag.Parse() call). For now, we have to set the
	// normalize func and add the go flag set by hand.
	pflag.CommandLine.SetNormalizeFunc(cliflag.WordSepNormalizeFunc)
	pflag.CommandLine.AddGoFlagSet(goflag.CommandLine)
	// cliflag.InitFlags()
	logs.InitLogs()
	defer logs.FlushLogs()

	if err := command.Execute(); err != nil {
		os.Exit(1)
	}
}
```

### [pkg/kubectl/cmd](https://github.com/kubernetes/kubernetes/blob/release-1.19/pkg/kubectl/cmd/cmd.go)

## 디버깅

> 환경은 VS Code에 github.com/go-delve/delve/cmd/dlv 를 설치한다.

- [launch.json](https://code.visualstudio.com/docs/editor/debugging)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "go",
      "request": "launch",
      "name": "kubectl",
      "program": "${workspaceFolder}/cmd/kubectl/kubectl.go",
      "args": [
        "config",
        "view"
      ]
    }
  ]
}
```

![vscode-debugging-golang](/images/kubernetes/vscode-debugging-golang.png)
