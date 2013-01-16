" Make Vim more useful
set nocompatible

" Some environment based settings
if has("win32") || has("win64")
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set guifont=Ubuntu\ Mono:h12
	set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME
	" Set the behavior for line endings
	set fileformats=dos,unix
elseif has("mac")
	set guifont=Envy\ Code\ R:h14
else
	set guifont=Envy\ Code\ R\ 14
endif

" Syntax highlighting
let g:molokai_original = 0
set t_Co=256
:colorscheme molokai
:syntax on

" Appearance options
if has("gui_running")
   " set default size
   set columns=140
   set lines=45
   " No menus and no toolbar
   set guioptions-=m
   set guioptions-=T
endif

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
" set clipboard=unnamed
" Enhance command-line completion
set wildmenu

" Allow cursor keys in insert mode
set esckeys

" Allow backspace in insert mode
set backspace=indent,eol,start

" Optimize for fast terminal connections
set ttyfast

" Add the g flag to search/replace by default
set gdefault

" Use UTF-8 without BOM
set encoding=utf-8 nobomb
set fileencoding=utf8 nobomb

" Change mapleader
let mapleader=","

" Don’t add empty newlines at the end of files
set binary
set noeol

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Respect modeline in files
set modeline
set modelines=4

" Enable per-directory .vimrc files and disable unsafe commands in them
" set exrc
" set secure

" Enable line numbers
set number

" Show the cursor position
set ruler

" Highlight current line
set cursorline

" Make tabs as wide as two spaces
set tabstop=4
set shiftwidth=4
set smarttab
set noexpandtab
set autoindent

" Show “invisible” characters
" set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
" set list

" Highlight searches
set hlsearch

" Ignore case of searches
set smartcase

" Highlight dynamically as pattern is typed
set incsearch

" Always show status line
" set laststatus=2

" Enable mouse in all modes
if has('mouse')
	set mouse=a
endif

" Disable error bells
set noerrorbells

" Don’t reset cursor to start of line when moving around.
set nostartofline

" Don’t show the intro message when starting Vim
set shortmess=atI

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it’s being typed
set showcmd

" Use relative line numbers
" if exists("&relativenumber")
" 	set relativenumber
" 	au BufReadPost * set relativenumber
" endif

" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>

" line wrapping
set wrap
set linebreak

" Map Ctrl-E Ctrl-W to toggle linewrap option like in VS
noremap <C-E><C-W> :set wrap!<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")

	" Enable file type detection
	filetype on

	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript

	" Add support for custom highlighting
	autocmd BufNewFile,BufRead *.pgm set syn=pgm
	autocmd BufNewFile,BufRead *.g set syn=antlr3

	" Add support for source code formatting
	autocmd BufNewFile,BufRead *.cpp set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.c set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.h set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.xml set formatprg=xmllint\ --format\ -
endif

