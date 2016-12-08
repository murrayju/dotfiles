EnvGet, ProgFiles32, ProgramFiles(x86)
if ProgFiles32 = ; Probably not on a 64-bit system.
    EnvGet, ProgFiles32, ProgramFiles
EnvGet, ProgFiles64, ProgramW6432

RunApplication(exePath)
{
	Run %exePath%
}

ShowApplication(exePath, windowClass, windowText = "", hideWindow = true, minimizeWindow = false)
{
	DetectHiddenWindows on

	IfWinExist %windowText% ahk_class %windowClass%
	{
		IfWinActive %windowText% ahk_class %windowClass%
		{
			If (hideWindow = true)
			{
				Send !{Tab}
				WinHide %windowText% ahk_class %windowClass%
				DetectHiddenWindows off
			}
			Else if (minimizeWindow = true)
			{
				WinMinimize %windowText% ahk_class %windowClass%
			}
		}
		Else If (hideWindow = false)
		{
			WinActivate %windowText% ahk_Class %windowClass%
		}
		Else
		{
			WinShow %windowText% ahk_class %windowClass%
			WinActivate %windowText% ahk_Class %windowClass%
		}
	}
	Else
	{
		RunApplication(exePath)
	}
}

Console2Exe(command)
{
	Run C:\Program Files\Console2\Console.exe -r "/k %command%"
}

RunIfExists(exe, args := false)
{
	if FileExist(exe)
	{
		if args {
			Run "%exe%" "%args%"
		} else { 
			Run "%exe%"
		}
		Return true
	}
	Return false
}

Vim(args := false) {
	global ProgFiles32
	vim8 := RunIfExists(ProgFiles32 . "\vim\vim80\gvim.exe", args)
	if !vim8 {
		vim74 := RunIfExists(ProgFiles32 . "\vim\vim74\gvim.exe", args)
		if !vim74 {
			vim73 := RunIfExists(ProgFiles32 . "\vim\vim73\gvim.exe", args)
		}
	}
}

VimFile(file) {
	found := RegExMatch(file, "\s*([ \w\\/:\+\$\.%\(\)\[\]\{\}\-=#\^~!@&;,``']+)", matchedStr)
	if (found != 0) {
		Vim(matchedStr1)
	}
}

; GetSelectedText or FilePath in Windows Explorer
GetSelectedText()
{
	IsClipEmpty := (Clipboard = "") ? 1 : 0

	if !IsClipEmpty {

		ClipboardBackup := ClipboardAll
		While !(Clipboard = "") {
			Clipboard =
			Sleep, 10
		}
	}

	Send, ^c
	ClipWait, 0.1

	ToReturn := Clipboard, Clipboard := ClipboardBackup
	if !IsClipEmpty
	ClipWait, 0.5, 1

	Return ToReturn
}
