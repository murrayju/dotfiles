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

:: Install GnuWin32 apps
call cinst GnuWin

:: Sysinternals package
call cinst sysinternals

:: Dev tools
call cinst git
call cinst tortoisegit
call cinst vim
call cinst notepadplusplus
call cinst notepad2
call cinst python
call cinst dotPeek
call cinst DotNet4.5
call cinst wireshark

:: misc apps
call cinst filezilla
call cinst launchy
call cinst fiddler
call cinst autohotkey_l
call cinst putty
call cinst VirtualCloneDrive
call cinst vlc
call cinst windirstat
call cinst winscp
call cinst javaruntime

pause
