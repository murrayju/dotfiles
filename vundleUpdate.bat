@echo off

set vimpath="%ProgramFiles%"\vim
if not exist %vimpath% (
	set vimpath="%ProgramFiles(x86)%"\vim
)
if not exist %vimpath% (
	echo "Vim is not installed"
	exit
)

:: Vundle Bundle install
set vimexe=%vimpath%\vim74\gvim.exe
if not exist %vimexe% (
	set vimexe=%vimpath%\vim73\gvim.exe
)
if exist %vimexe% (
	call %vimexe% -u .vimrc +BundleInstall! +BundleClean +qall
)

:: Non-vundle bundles
rem hg clone https://bitbucket.org/ludovicchabant/vim-lawrencium "%USERPROFILE%\.vim\bundle\vim-lawrencium"
