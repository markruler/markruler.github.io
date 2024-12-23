---
date: 2020-12-07T00:44:00+09:00
lastmod: 2024-12-24T07:40:00+09:00
title: "VIM 에디터 명령어 정리"
description: "VI/VIM"
featured_image: "/images/shell/vim.png"
images: ["/images/shell/vim.jpeg"]
tags:
  - editor
  - vi
  - vim
  - shell
categories:
  - wiki
---

> 서버에서 파일을 편집하기 위해 VIM 에디터를 사용할 일이 많은데,
> 제가 사용하는 설정 파일과 자주 쓰는 명령어를 정리합니다.

# 설정 (.vimrc)

제가 사용하는 설정 파일(`~/.vimrc`)입니다.

```vim
"이것은 주석
syntax on                                                                       
set showcmd
set statusline+=%F::%l,%c
set showmatch
set ignorecase
set smartcase
set incsearch
set autowrite
set ruler
set autoindent
set cindent
set shiftwidth=2
set tabstop=2
set expandtab
set laststatus=2
set backspace=indent,eol,start
set showmode
set hls
set colorcolumn=80
set ff=unix
set fileencodings=utf8
set viminfo='50,<1000
"set history=1000
au FileType make setlocal noexpandtab

highlight TailingWhitespace ctermbg=red guibg=red

set cul
set background=dark
set nowrapscan
set visualbell
set tenc=utf-8
```

- `syntax on` 구문강조 사용
- `set showcmd` 명령어 입력시 상태표시줄에 보여줌
- `set statusline+=%F::%l,%c` 상태표시줄에 파일명, 줄, 컬럼 표시
- `set showmatch` 괄호 매칭 보여줌
- `set ignorecase` 검색시 대소문자 무시
- `set smartcase` 검색어에 대문자가 포함되어 있으면 대소문자 구분
- `set incsearch` 검색어 입력시 점진적 검색
- `set autowrite` 저장하지 않은 파일을 끝내기 전에 자동으로 저장
- `set ruler` 화면 우측 하단에 현재 커서의 위치(줄,칸) 표시
- `set autoindent` 자동 들여쓰기
- `set cindent` C언어 자동 들여쓰기
- `set shiftwidth=2` 들여쓰기 2칸
- `set tabstop=2` 탭을 2칸으로
- `set expandtab` 탭을 스페이스로 대체
- `set laststatus=2` 상태표시줄 항상 표시
- `set backspace=indent,eol,start` 백스페이스로 들여쓰기, 줄 끝, 줄 시작 삭제
- `set showmode` 현재 모드 표시
- `set hls` 검색어 하이라이팅
- `set colorcolumn=80` 80칸에 세로줄 표시
- `set ff=unix` 파일 포맷을 유닉스로
- `set fileencodings=utf8` 파일 인코딩
- `set viminfo='50,<1000` 최근 50개의 명령어 기억
- `set history=1000` vi 편집기록 기억갯수 `.viminfo`에 기록
- `au FileType make setlocal noexpandtab` makefile에서 탭을 스페이스로 대체하지 않음
- `highlight TailingWhitespace ctermbg=red guibg=red` 끝에 공백이 있는 경우 빨간색으로 표시
- `set cul` 현재 커서가 있는 줄 강조
- `set nowrapscan` 검색시 문서 끝에서 처음으로 이동하지 않음
- `set visualbell` 경고음 대신 화면 깜빡임
- `set tenc=utf-8` 터미널 인코딩을 UTF-8로

![vim](/images/shell/vim.png)

# 입력 모드 (Insert Mode)

- `i` 현재 커서에서 편집
  - `Shift + i` 현재 줄의 처음으로 커서를 옮긴 후 편집
- `s` 현재 커서 한 글자 삭제 후 바로 입력 모드
  - `Shift + s` 현재 줄 삭제 후 바로 입력 모드
- `a` 다음 칸으로 커서를 옮긴 후 편집
  - `Shift + a` 현재 줄의 끝으로 커서를 옮긴 후 편집
- `o` 다음 줄로 커서를 옮긴 후 편집
  - `Shift + o` 이전 줄로 커서를 옮긴 후 편집

# 마지막 행 모드 (Last Line Mode)

## Last Line Command (:)

- `:q` 종료
- `:q!` 강제 종료
- `:w` 저장
- `:%s/old/new/gi` 문자열 교체 (old -> new)
  - `g` 옵션을 빼면 해당 줄의 첫 번째 문자열만 교체
- `:!` 명령어 실행
  - `:!ls` 현재 디렉토리 파일 목록 출력
  - `:!pwd` 현재 디렉토리 경로 출력
  - `:!date` 현재 시간 출력
- `:tabnew [file]` 새로운 탭 열기 (file이 없으면 빈 탭)
  - 실제로는 에디터 밖에서도 사용할 수 있는 tmux나 terminal 자체 기능을 활용하는 편입니다.
  - `gt` 다음 탭으로 이동하기
  - `gT` 이전 탭으로 이동하기

## Search mode (/, ?)

- `/regex-pattern` (`?regex-pattern`) 검색
  - `n` 다음 단어 (?는 반대)
  - `N` 이전 단어 (?는 반대)

# 명령 모드 (Command Mode)

- `u` - undo
- `control + r` - redo
- `.` - 이전 명령 다시 실행

## 이동

- `hjkl` 좌하상우 이동
- `Control + b` 이전 페이지로 이동
- `Control + f` 다음 페이지로 이동
- `Control + u` 이전 half page로 이동
- `Control + d` 다음 half page로 이동
- `gg` 문서 맨 앞으로 이동
- `G` 문서 맨 뒤로 이동
- `^` 현재 줄 앞으로 이동
- `$` 현재 줄 끝으로 이동

## 간단한 편집

- `y` 복사 (yank)
- `p` 붙여넣기
- `>` 들여쓰기
- `<` 내어쓰기
- `Shift + j` 현재 줄의 끝과 다음 줄의 앞부분을 합칩니다.

## 삭제

- `r` 현재 커서 한 글자 교체(replace)
- `x` 현재 커서 한 글자 삭제 (delete)
- `Shift + x` 현재 커서 앞에 한 글자 삭제 (backspace)
- `:1,.d` 첫 번째 줄부터 현재 커서까지 삭제 (LLM)
- `:5,10d` 5번 줄부터 10번 줄까지 삭제 (LLM)
- `dd` 현재 줄 삭제 (이후 p를 통해 삭제한 줄을 붙여넣을 수 있습니다)
  - 이동키와 조합해 삭제할 수도 있다.
  - `5dd` 현재 줄 포함 아래로 5줄 삭제
  - `dgg` 현재 커서에서 첫 줄까지 삭제
  - `dG` 현재 커서에서 마지막 줄까지 삭제
  - `d$` 현재 커서에서 현재 줄 마지막 단어까지 삭제
  - `d^` 현재 커서에서 현재 줄 첫 단어까지 삭제
  - `dw` 현재 커서에서 현재 단어까지 삭제

## 비주얼 모드(visual mode)

- `v` 비주얼 모드
- `shift + v` 비주얼 라인
- `Ctrl + v` 비주얼 블록
  - 비주얼 블록 모드에서 `Shift + i`를 누르면 블록의 첫 줄에 커서가 위치하고, 입력 모드로 전환됩니다.
  - 입력을 마치고 `ESC`를 누르면 블록의 모든 줄에 입력한 내용이 삽입됩니다. (여러 줄을 주석 처리할 때 유용)

## 화면 분할

- 탭 기능과 동일하게 터미널 자체 기능을 선호하는 편입니다.
- `Control + w` + `s` horizontal split
  - `new` horizontal split한 후 새로운 창 생성
- `Control + w` + `v` vertical split
  - `vs` vertical split한 후 현재 창 복제
- `Control + w` + `방향키` 분할된 창 간 이동
- `Control + w` + `>` 창 폭 늘리기
- `Control + w` + `<` 창 폭 줄이기
- `Control + w` + `+` 창 높이 늘리기
- `Control + w` + `-` 창 높이 줄이기
- `Control + w` + `=` 창 폭, 높이 원래 상태로
- `Control + w` + `o` only one window
