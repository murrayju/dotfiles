;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Include extra functionality
#Include %A_ScriptDir%\WinServ.ahk
#Include %A_ScriptDir%\Functions.ahk

; Get the install directories of the controller software
;RegRead, A3200InstallDir, HKEY_LOCAL_MACHINE, SOFTWARE\Aerotech\A3200, InstallDir

; Make CAPSLOCK just behave like SHIFT
CapsLock::Shift

; Win+N : Open Notepad++
#n::ShowApplication("C:\Program Files\Notepad++\Notepad++.exe", "Notepad++", "", false)

; Alt+G : Open GVIM
; >!g::ShowApplication("C:\Program Files\Vim\vim72\gvim.exe", "Vim", "", false)

; Open any selected text (or file in explorer) as a path in gVim
F4::Vim(GetSelectedText())
