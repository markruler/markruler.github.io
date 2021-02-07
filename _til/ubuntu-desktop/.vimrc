"call plug#begin('~/.vim/plugged')
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
"call plug#end()

"https://vimawesome.com/
"vim-airline
"vim-fugitive
"NERDTree
"vim-gitgutter
"vim-go

filetype plugin indent on

"http://vimdoc.sourceforge.net/htmldoc/usr_05.html#vimrc-intro
":help vimrc

"http://vimdoc.sourceforge.net/htmldoc/options.html#options
"http://vimdoc.sourceforge.net/htmldoc/options.html#'compatible'
":help options

">>>SCHEME<<<
syntax on
colorscheme desert "color 폴더에 colorscheme 설치 필요

">>>VIEW<<<
set nu "number, Print the line number in front of each line.
set ru "ruler, Show the line and column number of the cursor position, separated by a comma.
set cul "cursorline, Highlight the screen line of the cursor with CursorLine |hl-CursorLine|.
set bg=dark "background, When set to "dark", Vim will try to use colors that look good on a dark background.
set sm "showmatch, When a bracket is inserted, briefly jump to the matching one.
set title "hen on, the title of the window will be set to the value of 'titlestring' (if it is not empty)
set wrap "This option changes how text is displayed.
set lbr "linebreak, If on Vim will wrap long lines at a character in 'breakat' rather than at the last character that fits on the screen.
set sbr=+++\ "showbreak, String to put at the start of lines that have been wrapped.

">>>EDIT<<<
"set vb "visualbell, Use visual bell instead of beeping.
set bs=indent,eol,start "backspace, Each item allows a way to backspace over something
set fenc=utf-8 "fileencoding, Sets the character encoding for the file of this buffer.
set tenc=utf-8 "termencoding, Encoding used for the terminal.
set et "expandtab, Use the appropriate number of spaces to insert a <Tab>.
set ls=2 "laststatus, The value of this option influences when the last window will have a status line
set mouse=a "Enable the use of the mouse.

">>>INDENT<<<
set sw=2 "shiftwidth, Number of spaces to use for each step of (auto)indent.
set ts=2 "tabstop, Number of spaces that a <Tab> in the file counts for.
set ai "autoindent, Copy indent from current line when starting a new line (typing <CR> in Insert mode or when using the "o" or "O" command).
set cin "cindent, Enables automatic C program indenting
set si "smartindent, Do smart autoindenting when starting a new line.

">>>SEARCH<<<
set hi=200 "history, A history of ":" commands, and a history of previous search patterns are remembered.
set hls "hlsearch, highlight matches with the last used search pattern.
set is "incsearch, While typing a search command, show where the pattern, as it was typed so far, matches.
set ic "ignorecase, Ignore case in search patterns.
set nows "nowrapscan, do not wrap around
