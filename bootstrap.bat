@echo off

pushd %~dp0

echo Gitting latest
call git pull origin master

echo Copying Files
xcopy .vim "%USERPROFILE%\.vim" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .* "%USERPROFILE%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore

:: Install Vim plugins
set vimroot="%ProgramFiles%"\vim
if not exist %vimroot% (
	set vimroot="%ProgramFiles(x86)%"\vim
)
if not exist %vimroot% (
	echo "Vim is not installed"
	goto novim
)
set vimpath=%vimroot%\vim74
if not exist %vimpath% (
	set vimpath=%vimroot%\vim73
)
if not exist %vimpath% (
	echo "Vim is not installed"
	goto novim
)
set vimexe=%vimpath%\vim.exe
if not exist %vimexe% (
	echo "Vim is not installed"
	goto novim
)

call %vimexe% -c "PlugInstall" +qall

:novim

:: AutoHotkey
call win\ahkBootstrap.bat

:: FreeCommander
if not exist "%appdata%\FreeCommander\FreeCommander.ini" (
	echo F | xcopy win\freecommander\* "%appdata%\FreeCommander\" /F /E /I /H /R /Y
)

:: Run extra custom script
set extra=%USERPROFILE%\extra.bat
if exist "%extra%" (
	call %extra%
)

popd
