# SHELL := /usr/bin/env bash -ex
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# 운영체제에 따라 다른 변수나 동작을 설정
ifeq ($(OS), Windows_NT)
    # Windows
    OSFLAG := WINDOWS
    PRINTER := Write-Host
		CLEAN := powershell -ExecutionPolicy Bypass -File .\scripts\windows.clean.ps1
		BUILD := powershell -ExecutionPolicy Bypass -File .\scripts\windows.build.ps1
		DEPLOY := powershell -ExecutionPolicy Bypass -File .\scripts\windows.deploy.ps1
else
    # uname으로 운영체제 구분
		UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S), Linux)
        OSFLAG := LINUX
    endif
    ifeq ($(UNAME_S), Darwin)
        OSFLAG := MACOS
    endif
    PRINTER := printf
		CLEAN := ./scripts/clean.sh
		BUILD := ./scripts/build.sh
		DEPLOY := ./scripts/deploy.sh
endif

# ANSI Escape Code - Color
# https://en.wikipedia.org/wiki/ANSI_escape_code#colors

all:
	@echo "Usage: make [clean|build|deploy|run]"
.PHONY: all

clean:
	$(CLEAN)
.PHONY: clean

build: clean
	$(BUILD)
.PHONY: build

deploy: build
	$(DEPLOY)
.PHONY: deploy

run:
	@echo "Run the site..."
	hugo server --contentDir=_content --bind=0.0.0.0 --baseURL=http://127.0.0.1
.PHONY: run

# git submodule
submodule-add:
	git submodule add -b develop git@github.com:markruler/hugo-theme-diary.git themes/hugo-theme-diary
.PHONY: submodule-add

submodule-update:
	git submodule update --init --recursive
.PHONY: submodule-update

submodule-delete:
	git submodule deinit -f themes/hugo-theme-diary
	$(RM) .git/modules/themes/hugo-theme-diary
	git rm -f themes/hugo-theme-diary
.PHONY: submodule-delete
