#Requires AutoHotkey v2.0

; -------------------------------
; Disable Caps Lock and map it to Escape
CapsLock:: {
    SetCapsLockState("AlwaysOff")  ; Ensure Caps Lock is always off
    Send("{Esc}")
}

; Remap Caps Lock + N to Enter
CapsLock & n::Send("{Enter}")

; CapsLock + ; -> End + Enter
CapsLock & `;:: {
    Send("{End}")
    Send("{Enter}")
}

; CapsLock + i -> Ctrl+A + Backspace
CapsLock & i:: {
    Send("^a")
    Send("{Backspace}")
}

; Ctrl+Shift+; -> Toggle Ueli
^+`;:: {
    progToRun := "C:\Program Files\ueli\ueli.exe"
    progName := "ueli.exe"

    pid := ProcessExist(progName)
    if pid
        ProcessClose(pid)
    else
        Run(progToRun)
}

; Ctrl+Shift+[ -> Windows Terminal
^+[::Run("wt.exe")

; CapsLock + g -> Ctrl+A, Ctrl+C, Right Arrow
CapsLock & g:: {
    Send("^a")
    Send("^c")
    Send("{Right}")
}

; Vim-like navigation
CapsLock & h::Send("{Left}")
CapsLock & j::Send("{Down}")
CapsLock & k::Send("{Up}")
CapsLock & l::Send("{Right}")

; Undo
CapsLock & y::Send("^z")

; Alt+F4
CapsLock & /::Send("!{F4}")

; Word movement
CapsLock & o::Send("^({Left})")
CapsLock & p::Send("^({Right})")

; Backspace
CapsLock & m::Send("{Backspace}")
CapsLock & u::Send("^({Backspace})")

; Function keys (F1-F12)
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

; Letters not bound to other functions -> send lowercase
for key in ["a","b","c","d","e","f","q","s","t","v","w","x","z"] {
    Hotkey("CapsLock & " key, Func("SendLetter").Bind(key))
}

; Copy / Paste
CapsLock & ,::Send("^c")
CapsLock & .::Send("^v")

; Page Up / Down
CapsLock & [::Send("{PgUp}")
CapsLock & '::Send("{PgDn}")

; -------------------------------
; Functions

SendLetter(key) {
    Send(key)
}
