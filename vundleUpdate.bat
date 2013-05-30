@echo off

:: Vundle Bundle install
set vimexe="%ProgramFiles%\vim\vim73\gvim.exe" 
if exist %vimexe% (
	call %vimexe% -u .vimrc +BundleInstall! +BundleClean +qall
)

:: Non-vundle bundles
hg clone https://bitbucket.org/ludovicchabant/vim-lawrencium "%USERPROFILE%\.vim\bundle\vim-lawrencium"
