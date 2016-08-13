@echo off

pushd %~dp0

echo Gitting latest
call git pull origin master

echo Copying Files
xcopy .vim "%USERPROFILE%\.vim" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore
xcopy .* "%USERPROFILE%" /F /E /I /H /R /Y /EXCLUDE:.xcopyignore

:: Vundle Vim Bundles
call vundleUpdate.bat

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
