#KeyHistory 0  ; Disables key history to save performance.

; Disable Caps Lock and map it to Escape
CapsLock::
    SetCapsLockState, AlwaysOff  ; Ensure Caps Lock is always off
    Send, {Esc}
return

; windows and d to do the minimize all
; CapsLock & Space::Send #d

; Remap Caps Lock + N to Enter
CapsLock & n::Send, {Enter}

; Map CapsLock + ; to send End and Enter
CapsLock & `;::
Send, {End}  ; Send the End key
Send, {Enter}  ; Send the Enter key
Return

CapsLock & i::
Send, ^a  ; Send Ctrl + A
Send, {Backspace}  ; Send Backspace to delete all characters
Return

^+`;::  ; Ctrl + Shift + ;
    ; Set the full path to the program
    progToRun := "C:\Program Files\ueli\ueli.exe"
    progName := "ueli.exe"  ; Use just the executable name to identify the process

    ; Check if the program is already running by process name
    Process, Exist, %progName%
    if (ErrorLevel)
    {
        ; If the process is running, close it
        Process, Close, %ErrorLevel%
    }
    else
    {
        ; If the process is not running, start it
        Run, %progToRun%
    }
return

; This triggers on Ctrl+Shift+[
^+[::
    Run, "wt.exe"
return

CapsLock & g::
{
    Send, ^a  ; Send Ctrl + A (Select All)
    Send, ^c  ; Send Ctrl + C (Copy)
    Send, {Right}  ; Send Right Arrow key
    Return
}


; Vim-Like Navigation with CapsLock + H, J, K, L
CapsLock & h::Send {Left}    ; Move cursor left
CapsLock & j::Send {Down}    ; Move cursor down
CapsLock & k::Send {Up}      ; Move cursor up
CapsLock & l::Send {Right}   ; Move cursor right
return

; Map CapsLock + Y to Ctrl + Z (Undo)
CapsLock & y::Send, ^z  ; Send Ctrl + Z for Undo
return


; Map CapsLock + / to Alt + F4
CapsLock & /::Send !{F4}

; Map CapsLock + O/P for word movement (Ctrl + Arrow)
CapsLock & o::
    Send ^{Left}  ; Move left by word
return

CapsLock & p::
    Send ^{Right} ; Move right by word
return

; Map CapsLock + M to delete the character to the left (normal Backspace)
CapsLock & m::
    Send {Backspace}  ; Delete character to the left
return

; Map CapsLock + u to delete the previous word (like Ctrl + Backspace)
CapsLock & u::
    Send ^{Backspace}  ; Delete previous word
return

; Map CapsLock + Number Row to Function Keys (F1 - F10)
CapsLock & 1::Send {F1}
CapsLock & 2::Send {F2}
CapsLock & 3::Send {F3}
CapsLock & 4::Send {F4}
CapsLock & 5::Send {F5}
CapsLock & 6::Send {F6}
CapsLock & 7::Send {F7}
CapsLock & 8::Send {F8}
CapsLock & 9::Send {F9}
CapsLock & 0::Send {F10}
CapsLock & -::Send {F11}
CapsLock & =::Send {F12}

; For non-bound letter keys, send the lowercase character
CapsLock & a::Send a
CapsLock & b::Send b
CapsLock & c::Send c
CapsLock & d::Send d
CapsLock & e::Send e
CapsLock & f::Send f
;CapsLock & g::Send g
CapsLock & q::Send q
CapsLock & s::Send s
CapsLock & t::Send t
CapsLock & v::Send v
CapsLock & w::Send w
CapsLock & x::Send x
CapsLock & z::Send z

; Map CapsLock + , (Comma) to Ctrl + C (Copy)
CapsLock & ,::Send, ^c  ; Send Ctrl + C for Copy

; Map CapsLock + . (Period) to Ctrl + V (Paste)
CapsLock & .::Send, ^v  ; Send Ctrl + V for Paste
return


; Map Alt + Caps Lock to Alt + F4
;!CapsLock:: 
;{
;    Send, !{F4}
;    return
;}

; Use Caps Lock + [ to Page Up
CapsLock & [::
    Send, {PgUp}
    return

; Use Caps Lock + ' to Page Down
CapsLock & '::
    Send, {PgDn}
    return

::this;::thisismytestmail123@gmail.com
::niko;::nikobellicmanisk@gmail.com
::mgau;::maniskgaurav@gmail.com
::kumar;::kumarmanisk991@gmail.com
::mathew;::mathewmanisk699@gmail.com
::rlk;::rlkumar452@gmail.com
::fname;::Kumar Manisk Gaurav


ScrollLock::CapsLock


; Map Caps Lock + Right Alt to Enter
;CapsLock & RAlt::Send {Enter}

; Map CapsLock + IJKL to Arrow Keys
;CapsLock & i::
;    Send {Up}
;return
;
;CapsLock & k::
;    Send {Down}
;return
;
;CapsLock & j::
;    Send {Left}
;return
;
;CapsLock & h::
;    Send {Left}
;return
;
;CapsLock & l::
;    Send {Right}
;return

