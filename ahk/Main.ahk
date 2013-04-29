;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win7
; Author:         Justin Murray <murrayju@addpcs.com>
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force ; Automatically replace with newer version when run
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Include extra functionality
; #Include %A_ScriptDir%\WinServ.ahk
#Include %A_ScriptDir%\Functions.ahk

; Make CAPSLOCK just behave like SHIFT
CapsLock::Shift

; Open any selected text (or file in explorer) as a path in gVim
F4::Vim(GetSelectedText())
