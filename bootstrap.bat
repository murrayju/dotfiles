@echo off

echo Gitting latest
call git pull
call git submodule update --init

echo Copying Files
xcopy .vim "%USERPROFILE%\.vim" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .vimrc "%USERPROFILE%" /F /E /I /H /R /Y
xcopy .vimrc.bundles "%USERPROFILE%" /F /E /I /H /R /Y
xcopy .gitconfig "%USERPROFILE%" /F /E /I /H /R /Y
xcopy .gitignore "%USERPROFILE%" /F /E /I /H /R /Y
xcopy .gitattributes "%USERPROFILE%" /F /E /I /H /R /Y

:: Vundle Vim Bundles
call vundleUpdate.bat

:: AutoHotkey
call ahkBootstrap.bat
