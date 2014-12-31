@echo off

set vimpath="%ProgramFiles%"\vim
if not exist %vimpath% (
	set vimpath="%ProgramFiles(x86)%"\vim
)
if not exist %vimpath% (
	echo "Vim is not installed"
	exit
)

:: Vundle Plugin install
set vimexe=%vimpath%\vim74\gvim.exe
if not exist %vimexe% (
	set vimexe=%vimpath%\vim73\gvim.exe
)
if exist %vimexe% (
	call %vimexe% -u .vimrc +PluginInstall! +PluginClean +qall
)

:: Non-vundle bundles
rem hg clone https://bitbucket.org/ludovicchabant/vim-lawrencium "%USERPROFILE%\.vim\bundle\vim-lawrencium"
