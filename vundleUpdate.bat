@echo off

:: Vundle Bundle install
set vimexe="%ProgramFiles%\vim\vim73\vim.exe" 
if exist %vimexe% (
	call %vimexe% -u .vimrc.bundles +BundleInstall! +BundleClean +qall
)

:: Non-vundle bundles
hg clone https://bitbucket.org/ludovicchabant/vim-lawrencium "%HOME%\.vim\bundle\vim-lawrencium"
