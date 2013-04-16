@echo off

echo Gitting latest
call git pull
call git submodule update --init

echo Copying Files
xcopy .vim "%HOME%\.vim" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .vimrc "%HOME%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .vimrc.bundles "%HOME%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore

:: Vundle Bundle install
set vimexe="%ProgramFiles%\vim\vim73\vim.exe" 
if exist %vimexe% (
	call %vimexe% -u .vimrc.bundles +BundleInstall! +BundleClean +qall
)

:: Non-vundle bundles
hg clone https://bitbucket.org/ludovicchabant/vim-lawrencium "%HOME%\.vim\bundle\vim-lawrencium"
