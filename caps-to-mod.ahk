; Portable script: works standalone or with Script Manager
; User configuration: Set your app paths below
#Requires AutoHotkey v2.0

; Get Local AppData path (since A_LocalAppData is not built-in)
LocalAppData := EnvGet("LOCALAPPDATA")

; === USER CONFIGURATION ===
; Edit the paths below to match your system if needed
apps := Map(
    "b", Map("exe", "zen.exe", "path", A_ProgramFiles "\ZenBrowser\zen.exe"),
    "v", Map("exe", "Code.exe", "path", LocalAppData "\Programs\Microsoft VS Code\Code.exe"),
    "c", Map("exe", "claude.exe", "path", LocalAppData "\AnthropicClaude\Claude.exe"),
    "t", Map("exe", "WindowsTerminal.exe", "path", LocalAppData "\Microsoft\WindowsApps\wt.exe"),
    "o", Map("exe", "Obsidian.exe", "path", LocalAppData "\Programs\Obsidian\Obsidian.exe"),
    "f", Map("exe", "FPilot.exe", "path", LocalAppData "\Voidstar\FilePilot\FPilot.exe"),
    "u", Map("exe", "Cursor.exe", "path", LocalAppData "\Programs\Cursor\Cursor.exe")
)

; ==========================

; Disable the normal CapsLock behavior
SetCapsLockState "AlwaysOff"

; Global variables to track window states for each app
global appWindowIndex := Map()
global editorWindowIndex := 0  ; Index for combined editor windows

; Regular hotkeys for app switching
for key, appInfo in apps {
    if (key = "v") {
        ; Skip VS Code as we'll handle it specially
        continue
    }
    CreateHotkey(key)
}

; Special hotkey for VS Code/Cursor toggling
Hotkey("CapsLock & v", (*) => CycleEditorWindows())

; Function to create a hotkey with the key value properly captured
CreateHotkey(k) {
    Hotkey("CapsLock & " k, (*) => SwitchToApp(k))
}

; Function to check if a window ID is still valid
IsValidWindow(winID) {
    try {
        return WinExist("ahk_id" winID)
    } catch {
        return false
    }
}

; Function to cycle through all VS Code and Cursor windows
CycleEditorWindows() {
    global editorWindowIndex  ; Ensure we're using the global variable

    vscodeExe := "Code.exe"
    cursorExe := "Cursor.exe"
    vscodeClass := "ahk_exe " vscodeExe
    cursorClass := "ahk_exe " cursorExe

    ; Check if Shift is held down - if so, launch VS Code
    if (GetKeyState("Shift", "P")) {
        Run(apps["v"]["path"])
        return
    }

    ; Get fresh window lists for both editors
    vscodeWindows := WinGetList(vscodeClass)
    cursorWindows := WinGetList(cursorClass)

    ; Create a combined list of editor windows
    combinedWindows := Array()

    ; Add VS Code windows to the combined list
    loop vscodeWindows.Length {
        combinedWindows.Push(vscodeWindows[A_Index])
    }

    ; Add Cursor windows to the combined list
    loop cursorWindows.Length {
        combinedWindows.Push(cursorWindows[A_Index])
    }

    ; If no windows found, launch VS Code
    if (combinedWindows.Length = 0) {
        Run(apps["v"]["path"])
        editorWindowIndex := 0  ; Reset index
        return
    }

    ; Get currently active window
    try {
        currentActiveWindow := WinGetID("A")
    } catch {
        currentActiveWindow := 0
    }

    ; Find current window in the list to determine next window
    currentIndex := 0
    for i, winID in combinedWindows {
        if (winID = currentActiveWindow) {
            currentIndex := i
            break
        }
    }

    ; Calculate next index
    nextIndex := currentIndex + 1
    if (nextIndex > combinedWindows.Length) {
        nextIndex := 1
    }

    ; Get the window to activate
    windowToActivate := combinedWindows[nextIndex]

    ; Validate and activate the window
    if (IsValidWindow(windowToActivate)) {
        WinActivate("ahk_id" windowToActivate)
    } else {
        ; If window is invalid, try the first valid window in the list
        for winID in combinedWindows {
            if (IsValidWindow(winID)) {
                WinActivate("ahk_id" winID)
                break
            }
        }
    }
}

; Function to switch to app or cycle between instances
SwitchToApp(key) {
    app := apps[key]
    exeName := app["exe"]

    ; Check if Shift is held down - if so, launch a new instance
    if (GetKeyState("Shift", "P")) {
        Run(app["path"])
        return
    }

    ; Get application class
    AppClass := "ahk_exe " exeName

    ; Get fresh window list
    windowList := WinGetList(AppClass)
    windowCount := windowList.Length

    ; If no windows found, launch app
    if (windowCount = 0) {
        Run(app["path"])
        appWindowIndex[exeName] := 0  ; Reset index
        return
    }

    ; Initialize index if not exists
    if (!appWindowIndex.Has(exeName)) {
        appWindowIndex[exeName] := 0
    }

    ; Make sure index is valid for current window count
    if (appWindowIndex[exeName] < 0 || appWindowIndex[exeName] >= windowCount) {
        appWindowIndex[exeName] := 0
    }

    ; Try to cycle through windows, handling invalid ones
    attempts := 0
    maxAttempts := windowCount

    while (attempts < maxAttempts) {
        ; Move to next index
        appWindowIndex[exeName] := appWindowIndex[exeName] + 1

        ; Wrap around if needed
        if (appWindowIndex[exeName] > windowCount) {
            appWindowIndex[exeName] := 1
        }

        ; Get the window to activate
        windowToActivate := windowList[appWindowIndex[exeName]]

        ; Try to activate if valid
        if (IsValidWindow(windowToActivate)) {
            WinActivate("ahk_id" windowToActivate)
            return
        }

        attempts++
    }

    ; If we get here, all windows were invalid - get fresh list and try first valid one
    windowList := WinGetList(AppClass)
    loop windowList.Length {
        if (IsValidWindow(windowList[A_Index])) {
            WinActivate("ahk_id" windowList[A_Index])
            appWindowIndex[exeName] := A_Index
            return
        }
    }
}

; Make CapsLock & key combinations work
#HotIf GetKeyState("CapsLock", "P")
b:: return
v:: return
c:: return
t:: return
o:: return
f:: return
u:: return
#HotIf