; ==========================================
; MOVE CURSOR ONLY WHEN SWITCHING MONITORS
; ==========================================
; #Requires AutoHotkey v2.0 AutoHotkey v2.0

CoordMode "Mouse", "Screen"

lastWindow := WinExist("A")

SetTimer WatchActiveWindow, 100

WatchActiveWindow() {
    global lastWindow

    currentWindow := WinExist("A")

    if (!currentWindow || currentWindow = lastWindow)
        return

    ; Ignore taskbar and desktop windows
    try {
        windowClass := WinGetClass("ahk_id " currentWindow)

        if (windowClass = "Shell_TrayWnd"
            || windowClass = "Shell_SecondaryTrayWnd"
            || windowClass = "Progman"
            || windowClass = "WorkerW")
            return

        lastWindow := currentWindow

        ; Get active window center
        WinGetPos &x, &y, &w, &h, "ahk_id " currentWindow

        windowX := x + w // 2
        windowY := y + h // 2

        ; Get current mouse position
        MouseGetPos &mouseX, &mouseY

        mouseMonitor := GetMonitorAt(mouseX, mouseY)
        windowMonitor := GetMonitorAt(windowX, windowY)

        ; Move only when switching monitors
        if (mouseMonitor != windowMonitor && windowMonitor != 0) {
            ; Get monitor dimensions
            MonitorGet windowMonitor, &left, &top, &right, &bottom

            ; Center of the monitor
            centerX := (left + right) // 2
            centerY := (top + bottom) // 2

            MouseMove centerX, centerY, 0
        }
    }
}

GetMonitorAt(x, y) {
    loop MonitorGetCount() {
        MonitorGet A_Index, &left, &top, &right, &bottom

        if (x >= left && x < right
            && y >= top && y < bottom)
            return A_Index
    }

    return 0
}