---
date: 2020-12-07T00:44:00+09:00
title: "VIM 에디터 명령어 정리"
description: "VI/VIM"
featured_image: "/images/shell/vim.png"
images: ["/images/shell/vim.jpeg"]
tags:
  - editor
  - vi
  - vim
categories:
  - shell
---

> 업무 중에 구성 파일을 편집하기 위해 VIM 에디터를 사용할 일이 많은데, VIM 명령어 중에서도 가장 자주 쓰는 명령어를 정리합니다.

# $HOME/.vimrc

- " - comment

```vim
syntax on "구문강조 사용
colorscheme desert "color 폴더에 colorscheme 설치 필요
set background=dark "하이라이팅 lihgt / dark
set autoindent
set shiftwidth=2 "autoindent width
set ts=2 "tabstop, width
set softtabstop=2
set cindent "C Language indent
set nu "number
set cul "Highlight current line
set hls "hlsearch, 검색어 강조
set incsearch "키워드 입력시 점진적 검색
set ic "ignorecase, 검색시 대소문자 무시
set expandtab "탭 대신 스페이스
set laststatus=2 "status line
set nowrapscan "검색할 때 문서의 끝에서 처음으로 안돌아감
set visualbell "키를 잘못눌렀을 때 화면 프레시
set ruler "화면 우측 하단에 현재 커서의 위치(줄,칸) 표시
set fileencoding=utf-8 "파일저장인코딩
set tenc=utf-8 "터미널 인코딩
set history=1000 "vi 편집기록 기억갯수 .viminfo에 기록
set showbreak=+++\
```

![vim](/images/common/vim.png)

# 명령어

> - LLM: Last Line Mode
> - CM: Command Mode

- `u` - undo
- `control + r` - redo
- `.` - 이전 명령 다시 실행

- 비주얼 모드(visual mode)
  - `v` - 비주얼 모드

- 입력 모드로 전환
  - `i` - 현재 커서에서 편집
  - `a` - 다음 칸으로 커서를 옮긴 후 편집
  - `o` - 다음 줄로 커서를 옮긴 후 편집

- 간단한 편집
  - `x` - 현재 커서 한 글자 삭제 (delete)
  - `X` - 현재 커서 앞에 한 글자 삭제 (backspace)
  - `s` - 현재 커서 한 글자 삭제 후 바로 입력 모드
  - `r` - 현재 커서 한 글자 교체(replace)
  - `y` - 복사 (yank)
  - `p` - 붙여넣기
  - `>` - 들여쓰기
  - `<` - 내어쓰기


- 삭제
  - `:1,.d` - 첫 번째 줄부터 현재 커서까지 삭제 (LLM)
  - `:5,10d` - 5번 줄부터 10번 줄까지 삭제 (LLM)
  - `dd` - 현재 줄 삭제 (이후 p를 통해 삭제한 줄을 붙여넣을 수 있다)
    - `5dd` - 현재 줄 포함 아래로 5줄 삭제
  - `dgg` - 현재 커서에서 첫 줄까지 삭제
  - `dG` - 현재 커서에서 마지막 줄까지 삭제
  - `d`$ - 현재 커서에서 현재 줄 마지막 단어까지 삭제
  - `d^` - 현재 커서에서 현재 줄 첫 단어까지 삭제
  - 워드(w, b)나 방향키(g,h,j,k) 등과 조합해 삭제할 수도 있다(dw, db, dg, dh, dj, dk, ...).

- 이동
  - `control + b` - 이전 페이지로 이동
  - `control + f` - 다음 페이지로 이동
  - `control + u` - 이전 half page로 이동
  - `control + d` - 다음 half page로 이동
  - `gg` - 문서 맨 앞으로 이동
  - `G` - 문서 맨 뒤로 이동
  - `^` - 문장 맨 앞으로 이동
  - `$` - 문장 맨 뒤로 이동 
  - `0` - 현재 줄 끝으로 이동

- 화면 분할
  - `control + w` + `s` - horizontal split
    - `new` - horizontal split한 후 새로운 창 생성
  - `control + w` + `v` - vertical split
    - `vs` - vertical split한 후 현재 창 복제
  - `control + w` + `방향키` - 분할된 창 간 이동
  - `control + w` + `>` - 창 폭 늘리기
  - `control + w` + `<` - 창 폭 줄이기
  - `control + w` + `+` - 창 높이 늘리기
  - `control + w` + `-` - 창 높이 줄이기
  - `control + w` + `=` - 창 폭, 높이 원래 상태로
  - `control + w` + `o` - only one window

- 탭
  - `:tabnew` - 새로운 탭 열기 (LLM)
  - `gt` - 다음 탭으로 이동하기
  - `gT` - 이전 탭으로 이동하기

# Search mode (/, ?)

- `/regex-pattern`
- `:%s/old/new/g` - 교체
- `n` - 다음 단어 (?는 반대)
- `N` - 이전 단어 (?는 반대)
