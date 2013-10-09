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
call cup
if %errorlevel%==0 goto noInst
:: Install Chocolatey if it is missing
echo Chocolatey not yet installed, installing...
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
:noInst

:: basic apps
call cinst 7zip
call cinst 7zip.commandline
call cinst freecommander

:: browsers
call cinst GoogleChrome
call cinst Firefox

:: Console tools
:: call cinst GnuWin
:: call cinst cyg-get
call cinst cygwin

:: Sysinternals package
call cinst sysinternals

:: Dev tools
call cinst git.commandline
call cinst tortoisegit
call cinst hg
call cinst tortoisehg
call cinst sourcetree
call cinst vim
call cinst notepadplusplus
call cinst notepad2
call cinst python.x86
call cinst easy.install
call cinst pip
call cinst dotPeek
call cinst DotNet4.5
call cinst java.jdk
call cinst apache.ant
call cinst NAnt
call cinst wireshark
call cinst fiddler4

:: misc apps
call cinst virtualbox
call cinst vagrant
call cinst filezilla
call cinst launchy
call cinst autohotkey_l
call cinst putty
call cinst VirtualCloneDrive
call cinst vlc
call cinst windirstat
call cinst winscp
call cinst javaruntime
call cinst hashcheck

pause
