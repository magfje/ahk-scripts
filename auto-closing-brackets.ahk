; Portable script: works standalone or with Script Manager
#Requires AutoHotkey v2.0

; Auto-closing brackets/quotes with double-press functionality
#SingleInstance Force
SendMode "Input"

; Global variables to track key presses and timing
global lastKeyPress := ""
global lastKeyTime := 0
global doublePressDelay := 300  ; milliseconds

; Function to check if current window is an editor to exclude
IsExcludedEditor() {
    ; Get active window info
    activeProcess := WinGetProcessName("A")
    activeTitle := WinGetTitle("A")

    ; Check for VS Code or Cursor
    if (InStr(activeProcess, "Code.exe") || InStr(activeTitle, "Visual Studio Code"))
        return true
    if (InStr(activeProcess, "Cursor.exe") || InStr(activeTitle, "Cursor"))
        return true

    return false
}

; Function to handle double-press detection
HandleDoublePress(key, openingChar, closingChar) {
    global lastKeyPress, lastKeyTime, doublePressDelay
    currentTime := A_TickCount

    if (lastKeyPress = key && (currentTime - lastKeyTime) < doublePressDelay) {
        ; Double press detected - send opening and closing with cursor in middle
        SendInput(openingChar)
        SendInput(closingChar)
        SendInput("{Left}")
        SendInput("{Backspace}")
        lastKeyPress := ""  ; Reset to prevent triple-press issues
        lastKeyTime := 0
    } else {
        ; Single press - just send the opening character
        SendInput(openingChar)
        lastKeyPress := key
        lastKeyTime := currentTime
    }
}

; Auto-closing pairs with double-press functionality
$(:: {
    if (IsExcludedEditor())
        Send "("  ; Normal behavior in excluded editors
    else
        HandleDoublePress("(", "(", ")")
}

$":: {
    if (IsExcludedEditor())
        Send "`""  ; Normal behavior in excluded editors
    else
        HandleDoublePress("`"", "`"", "`"")
}

$':: {
    if (IsExcludedEditor())
        Send "'"  ; Normal behavior in excluded editors
    else
        HandleDoublePress("'", "'", "'")
}

$<:: {
    if (IsExcludedEditor())
        Send "<"  ; Normal behavior in excluded editors
    else
        HandleDoublePress("<", "<", ">")
}

; $[:: {
;     if (IsExcludedEditor())
;         Send "["  ; Normal behavior in excluded editors
;     else
;         HandleDoublePress("[", "[", "]")
; }

; ${:: {
;     if (IsExcludedEditor())
;         Send "{"  ; Normal behavior in excluded editors
;     else
;         HandleDoublePress("{", "{", "}")
; }
