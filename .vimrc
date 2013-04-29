set nocompatible               " be iMproved

" Some environment based settings
if has("win32") || has("win64")
	set guifont=Consolas:h11
	set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME
	" Set the behavior for line endings
	set fileformats=dos,unix,mac
elseif has("mac")
	set guifont=Envy\ Code\ R:h12
else
	set guifont=Envy\ Code\ R\ 12
endif

" Vundle Bundles
if filereadable(expand("~/.vimrc.bundles"))
	source ~/.vimrc.bundles
endif


" Syntax highlighting
if ((has("win32") || has("win64")) && !has("gui_running"))
	color cmd
	set background=light
else
	let g:molokai_original = 0
	let g:rehash256 = 1
	set t_Co=256
	color molokai
	set background=dark
endif
syntax on

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
set clipboard=unnamed

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
set ignorecase
set smartcase

" Highlight dynamically as pattern is typed
set incsearch

" Always show status line
set laststatus=2

" The status line
hi User1 guifg=#eea040 guibg=#222222
hi User2 guifg=#dd3333 guibg=#222222
hi User3 guifg=#ff66ff guibg=#222222
hi User4 guifg=#a0ee40 guibg=#222222
hi User5 guifg=#eeee40 guibg=#222222
set statusline=
set statusline +=%1*\ %n\ %*            "buffer number
set statusline +=%5*%{&ff}%*            "file format
set statusline +=%3*%y%*                "file type
set statusline +=%1*\ %{fugitive#statusline()}%*    "git branch
set statusline +=%4*\ %<%F%*            "full path
set statusline +=%2*%m%*                "modified flag
set statusline +=%1*%=%5l%*             "current line
set statusline +=%2*/%L%*               "total lines
set statusline +=%1*%4c%V\ %*             "virtual column number
set statusline +=%2*0x%04B\ %*          "character under cursor


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

" Easier way to esc insert mode
inoremap jk <ESC>

" Auto reload files (when not modified locally)
set autoread

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo
function! ResCur()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction

" Automatic commands
if has("autocmd")

	" Enable file type detection
	filetype on

	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	autocmd BufNewFile,BufRead *.hta setfiletype html syntax=html

	" Add support for custom highlighting
	autocmd BufNewFile,BufRead *.pgm set syn=pgm
	autocmd BufNewFile,BufRead *.g set syn=antlr3

	" Add support for source code formatting
	autocmd BufNewFile,BufRead *.cpp set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.c set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.h set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd BufNewFile,BufRead *.xml set formatprg=xmllint\ --format\ -

	augroup resCur
		autocmd!
		autocmd BufWinEnter * call ResCur()
	augroup END

	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on
endif

