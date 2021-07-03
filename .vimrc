if &compatible
  set nocompatible " Be iMproved
endif

" Some environment based settings
if has("win32") || has("win64")
	set guifont=Consolas:h10
	set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME
	" Set the behavior for line endings
	set fileformats=dos,unix,mac
elseif has("mac")
	set guifont=Consolas:h12,Envy\ Code\ R:h12
else
	set guifont=Droid\ Sans\ Mono\ 11,Ubuntu\ Mono\ 11
endif

" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install plugins
call plug#begin('~/.vim/plugged')

  " color schemes
  Plug 'tomasr/molokai'
  Plug 'morhetz/gruvbox'

  " Syntax Coloring
  Plug 'tpope/vim-markdown', { 'for': 'markdown' }
  Plug 'groenewege/vim-less', { 'for': 'less' }
  Plug 'ekalinin/Dockerfile.vim'
  Plug 'HerringtonDarkholme/yats.vim' " Typescript
  Plug 'yuezk/vim-js'
  Plug 'MaxMEllon/vim-jsx-pretty'
  Plug 'jparise/vim-graphql'

  " Code completion
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Syntax Checking
  Plug 'vim-syntastic/syntastic'

  " Project tree
  Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

  " Git extensions
  Plug 'tpope/vim-git'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'rbong/vim-flog'
  " Plug 'airblade/vim-gitgutter'
  " Plug 'akiomik/git-gutter-vim'

  " Better motion
  Plug 'Lokaltog/vim-easymotion'
  Plug 'bkad/CamelCaseMotion'

  " TComment
  Plug 'tomtom/tcomment_vim'

  " Unimpaired
  Plug 'tpope/vim-unimpaired'

  " Surrounds (mostly for html)
  Plug 'tpope/vim-surround'

  " Select entire file
  Plug 'kana/vim-textobj-user'
  Plug 'kana/vim-textobj-entire'

  " toggle relative/absolute line numbers
  Plug 'myusuf3/numbers.vim'

  " Quick find files
  Plug 'ctrlpvim/ctrlp.vim'

  " autocomplete
  Plug 'Shougo/neocomplcache.vim'

  " Status bar
  Plug 'vim-airline/vim-airline'

  " external status bars
  Plug 'edkolev/promptline.vim'
  Plug 'edkolev/tmuxline.vim'

  " Searching
  Plug 'dkprice/vim-easygrep'
  Plug 'mileszs/ack.vim'

  " EditorConfig.org whitespace
  Plug 'editorconfig/editorconfig-vim'


" Initialize plugin system
call plug#end()


" Use the built in matchit plugin
source $VIMRUNTIME/macros/matchit.vim

" Syntax highlighting
if ((has("win32") || has("win64")) && !has("gui_running"))
	silent! color cmd
	set background=light
else
	color desert
	silent! color gruvbox
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

" Use grep
set grepprg=grep\ -nrHE
let g:EasyGrepCommand = 1
let g:EasyGrepRoot = "repository"
let g:EasyGrepRecursive = 1
let g:EasyGrepFilesToExclude = ".git,node_moules,dist,ts-dist"
let g:EasyGrepInvertWholeWord = 1

" prefer ag over ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Use UTF-8
set encoding=utf-8
set fileencoding=utf8

" Change mapleader (instead of backslash)
let mapleader=","
let g:mapleader=","

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
	set undofile
endif

" Don’t create backups when editing files in certain directories
" set backupskip=/tmp/*,/private/tmp/*
set nobackup
set nowritebackup

" Respect modeline in files
set modeline
set modelines=4

" Do not consider numbers as octal
set nrformats=hex

" Enable line numbers
set number

" Show the cursor position
set ruler

" Highlight current line
set cursorline

" Make tabs as wide as two spaces
set tabstop=2
set shiftwidth=2
set smarttab
set noexpandtab
set autoindent

" Highlight searches
set hlsearch

" Ignore case of searches
set ignorecase
set smartcase
let g:EasyMotion_smartcase = 1

" Highlight dynamically as pattern is typed
set incsearch

" EasyMotion style searching
map  ? <Plug>(easymotion-sn)
omap ? <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" Enable syntax folding
set foldmethod=syntax
set foldlevelstart=99
let javaScript_fold=1         " JavaScript
let php_folding=1             " PHP
let sh_fold_enabled=1         " sh
let xml_syntax_folding=1      " XML

" Always show status line
set laststatus=2

" The status line
" molokai bg=#222222
" solarized bg=#073642
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
set statusline +=%1*%{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}%*
set statusline +=%1*%=%5l%*             "current line
set statusline +=%2*/%L%*               "total lines
set statusline +=%1*%4c%V\ %*           "virtual column number


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

" Clear search highlighting
nnoremap \\ :noh<CR><ESC>
" Reduce the timeout so there isn't an annoying delay when using j
set tm=500

" Y should behave more like C and D
map Y y$

" Auto reload files (when not modified locally)
set autoread

" Set to auto change directory to the file that I am editing
set autochdir

" backspace in Visual mode deletes selection
vnoremap <BS> d

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
nmap <leader>l :set list!<CR>

" Pressing F5 lists all buffers, just type number
map <F5> :ls<CR>:e #
:nnoremap <Leader>b :buffers<CR>:buffer<Space>
:nnoremap <Leader>q :bdelete<CR>

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,n~/.viminfo
function! ResCur()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction

" autocomplete
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" :
	\ <SID>check_back_space() ? "\<TAB>" :
	\ neocomplete#start_manual_complete()
function! s:check_back_space() "{{{
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" ctrlp
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|\.git\|dist'
let g:ctrlp_working_path_mode = 'ra'

" CoC
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json'
  \ ]

if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif


" TextEdit might fail if hidden is not set.
set hidden

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" Automatic commands
if has("autocmd")

	" Enable file type detection
	filetype on

	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	autocmd BufNewFile,BufRead *.hta setfiletype html syntax=html
	autocmd BufNewFile,BufRead *.cshtml setfiletype html syntax=html

	" Javascript should use spaces, not tabs
	autocmd FileType javascript setlocal ts=2 sts=2 sw=2 et

	" Add support for source code formatting
	autocmd FileType {cpp,c,h} set formatprg=astyle\ -t4pbSYM60m0HjOok3U
	autocmd FileType xml set formatprg=xmllint\ --format\ -
  autocmd FileType json setlocal formatprg=prettier
  autocmd FileType javascript setlocal formatprg=prettier
  autocmd FileType typescript setlocal formatprg=prettier

	augroup resCur
		autocmd!
		autocmd BufWinEnter * call ResCur()
	augroup END

	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif
