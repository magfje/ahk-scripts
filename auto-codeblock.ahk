; Portable script: works standalone or with Script Manager
#Requires AutoHotkey v2.0

; Triple Backtick Code Block Script - Safe Clipboard Method
; Press Shift+` three times quickly to insert code block

#SingleInstance Force
SendMode "Input"

; Initialize count tracking
global backtickCount := 0
global lastKeyTime := 0

; Shift+` hotkey
+`::
{
    global backtickCount, lastKeyTime

    ; Get current time
    currentTime := A_TickCount

    ; If it's been too long since last press, reset counter
    if (currentTime - lastKeyTime > 1000)
        backtickCount := 0

    ; Update last press time
    lastKeyTime := currentTime

    ; Increment counter
    backtickCount += 1

    ; Debug tooltip (can remove this later)
    ToolTip "Count: " . backtickCount
    SetTimer () => ToolTip(), -1000  ; Hide tooltip after 1 second

    ; On the FIRST and SECOND press, send the normal key
    if (backtickCount < 3) {
        ; Just send the character as normal
        SendInput "{Blind}{`` }"
    }
    ; Only on the THIRD press, insert the code block
    else if (backtickCount = 3) {
        ; Create a critical section so nothing interrupts our clipboard operations
        Critical "On"

        ; Save current clipboard with full content
        savedClip := ClipboardAll()

        ; Clear clipboard and prepare code block
        A_Clipboard := ""  ; Clear first for safety
        A_Clipboard := "``````" . "`n" . "`n" . "``````"

        ; Wait to ensure clipboard is ready (important for reliability)
        ClipWait 1

        ; Paste content
        SendInput "^v"

        ; Position cursor - small delay to ensure paste completes
        Sleep 30
        SendInput "{Up}"

        ; Restore original clipboard
        A_Clipboard := savedClip

        ; End critical section
        Critical "Off"

        ; Reset counter
        backtickCount := 0
    }
}
