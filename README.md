# AHK Scripts Collection

A collection of portable, ready-to-use [AutoHotkey v2.0](https://www.autohotkey.com/) scripts for productivity, automation, and workflow enhancement on Windows.

---

## About

- Each script is **standalone** and can be run directly with AutoHotkey v2.0.
- All scripts are also designed to work seamlessly with the [AutoHotkey Script Manager](https://github.com/magfje/ahk-script-manager) for easy enabling/disabling and editing.
- No hardcoded user paths—scripts are portable and easy to configure.

---

## Usage

### Standalone
1. Install [AutoHotkey v2.0](https://www.autohotkey.com/).
2. Download any script from this repo.
3. Double-click the `.ahk` file to run it, or right-click and choose "Run with AutoHotkey v2".
4. To stop a script, right-click its tray icon and choose Exit.

### With Script Manager
1. Download and set up the [AutoHotkey Script Manager](https://github.com/magfje/ahk-script-manager).
2. Copy or symlink these scripts into the manager's `Scripts/` folder.
3. Use the Script Manager GUI to enable, disable, or edit scripts.

---

## Scripts Included

### auto-closing-brackets.ahk
Auto-inserts closing brackets and quotes (like in code editors). Disables itself in VS Code and Cursor to avoid conflicts.

### auto-codeblock.ahk
Press Shift+` three times quickly to insert a Markdown code block (```) using the clipboard. Great for writing code in chat or notes.

### caps-to-mod.ahk
Turns CapsLock into a powerful modifier for fast app switching:
- `CapsLock + b` for ZenBrowser
- `CapsLock + v` for VS Code (cycles through VS Code and Cursor windows)
- `CapsLock + c` for Claude
- `CapsLock + t` for Windows Terminal
- `CapsLock + o` for Obsidian
- `CapsLock + f` for FilePilot
- `CapsLock + u` for Cursor

**Note:** Edit the configuration section at the top of the script to match your app install locations if needed.

---

## Looking for a Script Manager?
Check out the [AutoHotkey Script Manager](https://github.com/magfje/ahk-script-manager) for a GUI to manage, enable, and edit your scripts easily.
