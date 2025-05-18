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
global appWindowLists := Map()
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

    ; Get window lists for both editors
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

    ; Make sure editorWindowIndex is valid for the current list
    if (editorWindowIndex < 0 || editorWindowIndex >= combinedWindows.Length) {
        editorWindowIndex := 0  ; Reset if invalid
    }

    ; Increment the window index
    editorWindowIndex := editorWindowIndex + 1

    ; Wrap around if needed
    if (editorWindowIndex > combinedWindows.Length) {
        editorWindowIndex := 1
    }

    ; Get the window to activate
    windowToActivate := combinedWindows[editorWindowIndex]

    ; Activate the window
    WinActivate("ahk_id" windowToActivate)
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

    ; Get all windows for this app
    windowList := WinGetList(AppClass)
    windowCount := windowList.Length

    ; If no windows found, launch app
    if (windowCount = 0) {
        Run(app["path"])
        return
    }

    ; Check if we need to refresh our window list
    refreshList := true

    ; If we have a stored list for this app
    if (appWindowLists.Has(exeName)) {
        ; Get the stored list and check if it's still valid
        storedList := appWindowLists[exeName]

        ; If the count matches, assume it's still valid
        ; (This could be improved with more validation)
        if (storedList.Length = windowCount) {
            refreshList := false
        }
    }

    ; If we need to refresh or don't have a stored list
    if (refreshList) {
        ; Store the new window list
        appWindowLists[exeName] := windowList
        ; Reset index to 0
        appWindowIndex[exeName] := 0
    }

    ; Get the current list and increment index
    currentList := appWindowLists[exeName]

    ; Increment the index
    if (!appWindowIndex.Has(exeName)) {
        appWindowIndex[exeName] := 0
    }

    ; Move to next index
    appWindowIndex[exeName] := appWindowIndex[exeName] + 1

    ; Wrap around if needed
    if (appWindowIndex[exeName] > currentList.Length) {
        appWindowIndex[exeName] := 1
    }

    ; Get the window to activate
    windowToActivate := currentList[appWindowIndex[exeName]]

    ; Activate the window
    WinActivate("ahk_id" windowToActivate)
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