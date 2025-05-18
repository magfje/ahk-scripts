; Portable script: works standalone or with Script Manager
#Requires AutoHotkey v2.0

; Auto-closing brackets/quotes like in code editors
#SingleInstance Force
SendMode "Input"

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

; Auto-closing pairs with VS Code and Cursor exclusion
$(:: {
    if (IsExcludedEditor())
        Send "("  ; Normal behavior in excluded editors
    else
        SendInput("(){Left}")
}

$":: {
    if (IsExcludedEditor())
        Send "`""  ; Normal behavior in excluded editors
    else
        SendInput("`"`"{Left}")
}

$':: {
    if (IsExcludedEditor())
        Send "'"  ; Normal behavior in excluded editors
    else
        SendInput("''{Left}")
}

$<:: {
    if (IsExcludedEditor())
        Send "<"  ; Normal behavior in excluded editors
    else
        SendInput("<>{Left}")
}

$[:: {
    if (IsExcludedEditor())
        Send "["  ; Normal behavior in excluded editors
    else {
        SendInput("[")
        SendInput("]")
        SendInput("{Left}")
    }
}

${:: {
    if (IsExcludedEditor())
        Send "{"  ; Normal behavior in excluded editors
    else {
        SendInput("{")
        SendInput("}")
        SendInput("{Left}")
    }
}
