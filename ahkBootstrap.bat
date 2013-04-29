@echo off

:: AutoHotkey Launcher
set ahk=%programfiles%\AutoHotkey\AutoHotkey.exe
if not exist "%ahk%" (
	set ahk=%programW6432%\AutoHotkey\AutoHotkey.exe
)
if exist "%ahk%" (
	start "%ahk%" ahk\Main.ahk
	:: Autorun entry in registry
	reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v ahk_script /t REG_SZ /d "\"%ahk%\" \"%cd%\ahk\Main.ahk\"" /f
)
