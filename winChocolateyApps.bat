@echo off

rem This installs Chocolatey NuGet, and a set of basic apps

rem Update Chocolatey if it is installed
call cup
if %errorlevel%==0 goto noInst
rem Install Chocolatey if it is missing
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
:noInst

rem basic apps
call cinst 7zip
call cinst 7zip.commandline
call cinst freecommander

rem browsers
call cinst GoogleChrome
call cinst Firefox

rem Install GnuWin32 apps
call cinst GnuWin

rem Sysinternals package
call cinst sysinternals

rem Dev tools
call cinst git
call cinst tortoisegit
call cinst vim
call cinst notepadplusplus
call cinst notepad2
call cinst python
call cinst dotPeek
call cinst DotNet4.5
call cinst wireshark

rem misc apps
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
