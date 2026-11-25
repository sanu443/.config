; #Requires AutoHotkey v2.0
; #SingleInstance Force

;Private 
#Include "..\..\private\autohotkey\main-private.ahk"
; Additional modules
#Include "modules\mouse-follow-focus.ahk"

; Window management
#w::Send "!{F4}"

; Ctrl+Escape -> Do nothing
^Esc::Return

; Win+C -> Open Copilot normally, then start dictation
~#c::
{
    Sleep 200
    Send "#h"
}


; Open the most recently downloaded file in VS Code


; Win + Ctrl + P: Open or extract latest download
#^p::
{
    downloads := EnvGet("USERPROFILE") "\Downloads"
    latest := ""
    latestTime := ""

    ; Find the newest downloaded file
    Loop Files, downloads "\*", "F"
    {
        ; Ignore incomplete downloads
        if (A_LoopFileExt ~= "i)^(crdownload|part|partial|tmp|download|opdownload)$")
            continue

        ; Ignore temporary Office files and empty downloads
        if (SubStr(A_LoopFileName, 1, 2) = "~$" || A_LoopFileSize = 0)
            continue

        if (latest = "" || A_LoopFileTimeCreated > latestTime)
        {
            latest := A_LoopFileFullPath
            latestTime := A_LoopFileTimeCreated
        }
    }

    ; No downloads found
    if (latest = "")
    {
        MsgBox("No downloaded files found.", "Latest Download")
        return
    }

    ; Identify file extension
    SplitPath(latest, , , &extension, &archiveName)
    extension := StrLower(extension)

    ; Handle ZIP and RAR archives
    if (extension = "zip" || extension = "rar")

        {
        ; Locate 7-Zip
        sevenZip := EnvGet("ProgramFiles") "\7-Zip\7z.exe"

        if !FileExist(sevenZip)
            sevenZip := EnvGet("ProgramFiles(x86)") "\7-Zip\7z.exe"

        if !FileExist(sevenZip)
        {
            MsgBox("Cannot locate 7-Zip executable.", "Latest Download")
            return
        }

        ; Create archive-specific extraction directory
        archiveRoot := EnvGet("USERPROFILE") "\Desktop\home-repo\archive"
        destination := archiveRoot "\" archiveName

        DirCreate(destination)

        ; Extract quietly
        exitCode := RunWait(
            '"' sevenZip '" x "' latest '" -o"' destination '" -y -bb0 -bso0 -bsp0 -bse0',
            ,
            "Hide"
        )

        ; Open extracted directory in maximized Explorer
        if (exitCode = 0)
        {
            Run('explorer.exe /n,"' destination '"', , "Max")
        }
        else
        {
            MsgBox(
                "Extraction failed.`nExit code: " exitCode,
                "Latest Download"
            )
        }

        return
    }

    ; Open other files in VS Code
    codeExe := EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe"

    if !FileExist(codeExe)
        codeExe := EnvGet("ProgramFiles") "\Microsoft VS Code\Code.exe"

    if !FileExist(codeExe)
    {
        MsgBox("Cannot locate VS Code executable.", "Latest Download")
        return
    }

    Run('"' codeExe '" --reuse-window "' latest '"')
}

; Win+Shift+Ctrl+Q -> Put Windows to sleep
#^+q::
{
    DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
}


; Win+Shift+P -> Show mouse coordinates
#+p::
{
    CoordMode "Mouse", "Screen"
    MouseGetPos &x, &y
    MsgBox "Mouse position: X=" x " Y=" y
}

; Win+Shift+V -> Open ChatGPT and start Voice Mode
#+v::
{
    CoordMode "Mouse", "Screen"

    ; Save original cursor position
    MouseGetPos &originalX, &originalY

    ; Open ChatGPT in a new Edge window
    Run 'msedge.exe --new-window "https://chatgpt.com/"'

    ; Wait for Edge to become active
    if !WinWaitActive("ahk_exe msedge.exe", , 10)
        return

    ; Wait for ChatGPT to load
    Sleep 3000

    ; Click Voice Mode button
    Click 1472, 580

    ; Restore original cursor position
    MouseMove originalX, originalY, 0
}


