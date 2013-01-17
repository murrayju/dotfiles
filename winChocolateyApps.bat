@echo off

rem This installs Chocolatey NuGet, and a set of basic apps

rem Install Chocolatey first
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin

rem basic apps
cinst 7zip
cinst 7zip.commandline
cinst freecommander

rem browsers
cinst GoogleChrome
cinst Firefox

rem Install GnuWin32 apps
cinst GnuWin

rem Sysinternals package
cinst sysinternals

rem Dev tools
cinst git
cinst tortoisegit
cinst vim
cinst notepadplusplus
cinst notepad2
cinst python
cinst dotPeek
cinst DotNet4.5
cinst wireshark

rem misc apps
cinst filezilla
cinst launchy
cinst fiddler
cinst autohotkey_l
cisnt putty
cinst VirtualCloneDrive
cinst vlc
cinst windirstat
cinst winscp
cinst javaruntime
