#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Admin auto-elevate (optional) ---
if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; --- Disable Caps Lock and map it to Escape ---
CapsLock::
{
    SetCapsLockState("AlwaysOff")
    Send("{Esc}")
}

; --- Remap CapsLock + N to Enter ---
CapsLock & n::Send("{Enter}")

; --- Map CapsLock + ; to send End and Enter ---
CapsLock & `;::
{
    Send("{End}")
    Send("{Enter}")
}

; --- CapsLock + i: Select all and delete ---
CapsLock & i::
{
    Send("^a")
    Send("{Backspace}")
}

; --- Ctrl + Shift + ;  toggle Ueli ---
^+`;::
{
    progToRun := "C:\Program Files\ueli\ueli.exe"
    progName := "ueli.exe"

    if ProcessExist(progName)
        ProcessClose(progName)
    else
        Run(progToRun)
}

; --- Ctrl + Shift + [  opens Windows Terminal ---
^+[::
{
    Run("wt.exe")
}

; --- CapsLock + g: Copy all and move right ---
CapsLock & g::
{
    Send("^a")
    Send("^c")
    Send("{Right}")
}

; --- Vim-like navigation ---
CapsLock & h::Send("{Left}")
CapsLock & j::Send("{Down}")
CapsLock & k::Send("{Up}")
CapsLock & l::Send("{Right}")

; --- Undo ---
CapsLock & y::Send("^z")

; --- Close window ---
CapsLock & /::Send("!{F4}")

; --- Word navigation ---
CapsLock & o::Send("^{Left}")
CapsLock & p::Send("^{Right}")

; --- Delete character ---
CapsLock & m::Send("{Backspace}")

; --- Delete previous word ---
CapsLock & u::Send("^{Backspace}")

; --- Function key mappings ---
CapsLock & 1::Send("{F1}")
CapsLock & 2::Send("{F2}")
CapsLock & 3::Send("{F3}")
CapsLock & 4::Send("{F4}")
CapsLock & 5::Send("{F5}")
CapsLock & 6::Send("{F6}")
CapsLock & 7::Send("{F7}")
CapsLock & 8::Send("{F8}")
CapsLock & 9::Send("{F9}")
CapsLock & 0::Send("{F10}")
CapsLock & -::Send("{F11}")
CapsLock & =::Send("{F12}")

; --- Letter passthrough ---
for key in ["a","b","c","d","e","q","s","t","v","w","x","z"]
    Hotkey("CapsLock & " key, (*) => Send(key))

; --- Copy/Paste shortcuts ---
; CapsLock & ,::Send("^c")
CapsLock & .::Send("^v")

; --- Copy all (Ctrl+A then Ctrl+C) ---
CapsLock & ,::
{
    Send("^a")
    Sleep(50)
    Send("^c")
}
; --- Page Up / Down ---
CapsLock & [::Send("{PgUp}")
CapsLock & '::Send("{PgDn}")

; --- Deletes a file or a single char ---
CapsLock & d::Send "{Delete}"
; --- CapsLock + f = Ctrl + f ---
CapsLock & f::Send("^f")
!Backspace::Send("!{Left}")   ; Alt + Backspace → Alt + Left Arrow

PgUp::Send("{Home}")
;Send("{Right}")
