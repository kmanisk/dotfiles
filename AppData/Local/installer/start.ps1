
$ErrorActionPreference = "Stop"
$dir = $PSScriptRoot

Start-Process AutoHotkey.exe "`"$dir\ArrowKeysMapping.ahk`"" -WindowStyle Hidden
Start-Process AutoHotkey.exe "`"$dir\AutoCorrect_v2.ahk`"" -WindowStyle Hidden
