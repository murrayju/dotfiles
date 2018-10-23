@echo off
:: This installs Chocolatey NuGet, and a set of basic apps

:: Automatically check & get admin rights
:checkPrivileges 
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 

:getPrivileges 
if '%1'=='ELEV' (shift & goto gotPrivileges)  
ECHO. 
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation 
ECHO **************************************

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
cmd /k "%temp%\OEgetPrivileges.vbs" 
exit /B 

:gotPrivileges 
setlocal & pushd .
:: Main program starts here

:: Update Chocolatey if it is installed
echo Updating Chocolatey...
call choco upgrade -y chocolatey
if %errorlevel%==0 goto noInst
:: Install Chocolatey if it is missing
echo Chocolatey not yet installed, installing...
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
:noInst

:: basic apps
call choco install -y 7zip
call choco install -y 7zip.commandline
:: call choco install -y freecommander

:: browsers
call choco install -y googlechrome
call choco install -y chromium
call choco install -y Firefox

:: Console tools
:: call choco install -y cyg-get
call choco install -y cygwin
call choco install -y babun
call choco install -y conemu

:: Sysinternals package
call choco install -y sysinternals

:: Dev tools
call choco install -y git
call choco install -y hg
call choco install -y tortoisegit
call choco install -y tortoisehg
call choco install -y sourcetree
call choco install -y vim
call choco install -y editorconfig.core
:: call choco install -y atom
:: call choco install -y brackets
call choco install -y visualstudiocode
:: call choco install -y sublimetext3
call choco install -y notepadplusplus
call choco install -y notepad2
call choco install -y nodejs
call choco install -y python3
call choco install -y python2
call choco install -y easy.install
call choco install -y pip
call choco install -y dotPeek
call choco install -y DotNet3.5
:: call choco install -y DotNet4.7.1
call choco install -y netfx-4.7.1-devpack
call choco install -y dotnetcore-sdk
call choco install -y windows-sdk-10
call choco install -y jdk8 -params "both=true"
call choco install -y jdk11
call choco install -y ant
call choco install -y NAnt
call choco install -y wireshark
call choco install -y fiddler4
call choco install -y wget
call choco install -y curl
call choco install -y kdiff3
call choco install -y dependencywalker

:: misc apps
call choco install -y virtualbox
call choco install -y virtualbox.extensionpack
call choco install -y vmwareplayer
call choco install -y vmwarevsphereclient
call choco install -y docker
call choco install -y docker-machine
call choco install -y docker-compose
:: call choco install -y vagrant
call choco install -y filezilla
call choco install -y launchy
call choco install -y autohotkey
call choco install -y putty
:: call choco install -y VirtualCloneDrive
call choco install -y vlc
call choco install -y windirstat
call choco install -y winscp
call choco install -y hashcheck
call choco install -y foxitreader
call choco install -y keepassxc
call choco install -y gimp

pause
