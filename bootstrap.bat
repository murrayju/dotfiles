@echo off

echo Gitting latest
call git pull
call git submodule update --init

echo Copying Files
xcopy .vim "%HOME%\.vim" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .vimrc "%HOME%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .vimrc.bundles "%HOME%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore

:: Vundle Vim Bundles
call vundleUpdate.bat

:: AutoHotkey
call ahkBootstrap.bat
