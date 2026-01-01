#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Admin auto-elevate (optional) ---
if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; --- Remap Right Ctrl as right-hand Caps layer ---
RControl:: {
    SetCapsLockState("AlwaysOff")
    Send("{Blind}{RControl Down}")
    KeyWait("RControl")
    Send("{RControl Up}")
}

; --- Left CapsLock base layer ---
CapsLock:: {
    SetCapsLockState("AlwaysOff")
    Send("{Esc}")
}

; --- Left-hand Caps combos ---
CapsLock & n::Send("{Enter}")
CapsLock & `;:: {
    Send("{End}")
    Send("{Enter}")
}
CapsLock & i:: {
    Send("^a")
    Send("{Backspace}")
}
CapsLock & g:: {
    Send("^a")
    Send("^c")
    Send("{Right}")
}
CapsLock & h::Send("{Left}")
CapsLock & j::Send("{Down}")
CapsLock & k::Send("{Up}")
CapsLock & l::Send("{Right}")
CapsLock & y::Send("^z")
CapsLock & /::Send("!{F4}")
CapsLock & o::Send("^{Left}")
CapsLock & p::Send("^{Right}")
CapsLock & m::Send("{Backspace}")
CapsLock & u::Send("^{Backspace}")
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
CapsLock & .::Send("^v")
CapsLock & ,:: {
    Send("^a")
    Sleep(50)
    Send("^c")
}
CapsLock & [::Send("{PgUp}")
CapsLock & '::Send("{PgDn}")
CapsLock & d::Send("{Delete}")
CapsLock & f::Send("^f")

; --- Ctrl+Shift hotkeys ---
^+`;:: {
    progToRun := "C:\Program Files\ueli\ueli.exe"
    progName := "ueli.exe"
    if ProcessExist(progName)
        ProcessClose(progName)
    else
        Run(progToRun)
}
^+[::Run("wt.exe")
!Backspace::Send("!{Left}")
PgUp::Send("{Home}")

; --- Letters passthrough and Right Ctrl mirror ---
letters := ["a","b","c","d","e","q","s","t","v","w","x","z"]

for key in letters {
    thisKey := key
    ; Left-hand Caps passthrough
    Hotkey("CapsLock & " thisKey, Func("Passthrough").Bind(thisKey))
    ; Right-hand Ctrl passthrough
    Hotkey("RControl & " thisKey, Func("Passthrough").Bind(thisKey))
}

; --- Right-hand special combos mirror ---
RControl & h::Send("{Left}")
RControl & j::Send("{Down}")
RControl & k::Send("{Up}")
RControl & l::Send("{Right}")
RControl & n::Send("{Enter}")
RControl & i:: {
    Send("^a")
    Send("{Backspace}")
}
RControl & g:: {
    Send("^a")
    Send("^c")
    Send("{Right}")
}
RControl & y::Send("^z")
RControl & /::Send("!{F4}")
RControl & o::Send("^{Left}")
RControl & p::Send("^{Right}")
RControl & m::Send("{Backspace}")
RControl & u::Send("^{Backspace}")
RControl & 1::Send("{F1}")
RControl & 2::Send("{F2}")
RControl & 3::Send("{F3}")
RControl & 4::Send("{F4}")
RControl & 5::Send("{F5}")
RControl & 6::Send("{F6}")
RControl & 7::Send("{F7}")
RControl & 8::Send("{F8}")
RControl & 9::Send("{F9}")
RControl & 0::Send("{F10}")
RControl & -::Send("{F11}")
RControl & =::Send("{F12}")
RControl & .::Send("^v")
RControl & ,:: {
    Send("^a")
    Sleep(50)
    Send("^c")
}
RControl & [::Send("{PgUp}")
RControl & '::Send("{PgDn}")
RControl & d::Send("{Delete}")
RControl & f::Send("^f")

; --- Email hotstrings ---
::this;::thisismytestmail123@gmail.com
::mathew;::mathewmanisk699@gmail.com
::maniac;::maniacphotos7@gmail.com
::manisk;::maniskgaurav@gmail.com
::galaxy;::galaxytitan1234@gmail.com
::kmanisk;::kumarmanisk991@gmail.com

; --- Passthrough function ---
Passthrough(k) {
    Send(k)
}