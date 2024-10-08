#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Define gestures array
gestures := [ { gesture: "d", hotkey: "{Left}", humanName: "Previous Protocol" }
             ,{ gesture: "u", hotkey: "{Right}", humanName: "Next Protocol" }
             ,{ gesture: "l", hotkey: "{PgUp}", humanName: "Previous Series" }
             ,{ gesture: "r", hotkey: "{PgDn}", humanName: "Next Series" }
             ,{ gesture: "ul", hotkey: "y", humanName: "Measure" }
             ,{ gesture: "ur", hotkey: "^a", humanName: "Arrow" }
             ,{ gesture: "lu", hotkey: "y", humanName: "Measure" }
             ,{ gesture: "ru", hotkey: "^a", humanName: "Arrow" }
             ,{ gesture: "rd", hotkey: "[", humanName: "Next Prior" }
             ,{ gesture: "dr", hotkey: "[", humanName: "Next Prior" }
             ,{ gesture: "ld", hotkey: "]", humanName: "Previous Prior" }
             ,{ gesture: "dl", hotkey: "]", humanName: "Previous Prior" }
             ,{ gesture: "lr", hotkey: ["^y", "+q"], humanName: "Erase Measurements and Annotations" }
             ,{ gesture: "rl", hotkey: ["^y", "+q"], humanName: "Erase Measurements and Annotations" }
             ,{ gesture: "ud", hotkey: "s", humanName: "Scroll" }
             ,{ gesture: "du", hotkey: "s", humanName: "Scroll" }
             ,{ gesture: "rdld", hotkey: "j", humanName: "ROI" }
             ,{ gesture: "rld", hotkey: "^t", humanName: "Text" }
             ,{ gesture: "udr", hotkey: "{F5}", humanName: "Lung Window" }
			 ,{ gesture: "udu", hotkey: "{F6}", humanName: "Liver Window" }
             ,{ gesture: "uld", hotkey: "ZoomMeasureReset", humanName: "Zoom, Measure, Reset" }  ; New gesture
             ,{ gesture: "uru", hotkey: "{F7}", humanName: "Bone Window" }  ; New shorter gesture for Bone Window
             ,{ gesture: "drd", hotkey: "{F4}", humanName: "Soft Tissue Window" }  ; New shorter gesture for Soft Tissue Window
             ,{ gesture: "ldru", hotkey: "^{Backspace}", humanName: "Reset Viewer" }
             ,{ gesture: "rdlu", hotkey: "^{Backspace}", humanName: "Reset Viewer" }
             ,{ gesture: "rlr", hotkey: "z", humanName: "Zoom" }
             ,{ gesture: "rdr", hotkey: "z", humanName: "Zoom" } ]

; Initialize variables
rightClickCounter := 0
clickTimeframe := 250  ; Time in milliseconds to wait for a potential double-click
longClickThreshold := 500  ; Time in milliseconds to consider a click as a long click
fKeys := ["F4", "F5", "F6", "F7"]  ; Cycle through F4, F5, F6, F7
lastRightClickTime := 0
waitingForSecondRightClick := false
global resetPressed := false

; XButton variables
lastXButton1ClickTime := 0
lastXButton2ClickTime := 0
waitingForSecondXButton1 := false
waitingForSecondXButton2 := false

; Y key toggle variable
yKeyPressed := false

; Create GUI
Gui, -AlwaysOnTop +Resize
Gui, Font, s10, Arial  ; Set a larger, more readable font

; Add Tab control
Gui, Add, Tab3, vMainTab w800 h600, Gesture Reminders|Event Log

; Gesture Reminders Tab
Gui, Tab, 1
Gui, Add, ListView, r18 w580 vGestureList, Gesture|Hotkey|Action

; Populate the ListView with gesture information
for index, item in gestures {
    hotkey := IsObject(item.hotkey) ? item.hotkey[1] . " + " . item.hotkey[2] : item.hotkey
    LV_Add("", item.gesture, hotkey, item.humanName)
}

; Auto-size columns based on content
LV_ModifyCol(1, "AutoHdr")  ; Gesture column
LV_ModifyCol(2, "AutoHdr")  ; Hotkey column
LV_ModifyCol(3, "AutoHdr")  ; Action column

; Event Log Tab
Gui, Tab, 2
Gui, Add, Edit, vEventText w780 h570 ReadOnly

; Calculate the required width and height
Gui, +LastFound
GuiControlGet, TabControl, Pos, MainTab
GuiControlGet, ListView, Pos, GestureList
totalWidth := ListViewW + 40  ; Add some padding
totalHeight := TabControlH + 40  ; Add some padding for the tab control

; Show GUI with calculated dimensions
Gui, Show, w%totalWidth% h%totalHeight%, Corsair M55 Mouse Action Tracker

; Function to update GUI
UpdateGui(action) {
    global EventText
    currentText := ""  ; Initialize to empty string
    GuiControlGet, currentText,, EventText
    newText := action . "`n" . currentText
    GuiControl,, EventText, %newText%
}


; XButton1 handling
XButton1::
    currentTime := A_TickCount
    timeSinceLastClick := currentTime - lastXButton1ClickTime
    lastXButton1ClickTime := currentTime
    
    if (waitingForSecondXButton1 and timeSinceLastClick <= clickTimeframe)
    {
        ; Double-click detected
        waitingForSecondXButton1 := false
        Send, {F6}  ; Liver Window
        UpdateGui("Action: Liver Window (XButton1 double-click)")
    }
    else
    {
        ; Potential single click
        waitingForSecondXButton1 := true
        SetTimer, XButton1SingleClickAction, -%clickTimeframe%
    }
return

XButton1SingleClickAction:
    if (waitingForSecondXButton1)
    {
        waitingForSecondXButton1 := false
        Send, {F4}  ; Soft Tissue Window
        UpdateGui("Action: Soft Tissue Window (XButton1 single click)")
    }
return

; XButton2 handling
XButton2::
    currentTime := A_TickCount
    timeSinceLastClick := currentTime - lastXButton2ClickTime
    lastXButton2ClickTime := currentTime
    
    if (waitingForSecondXButton2 and timeSinceLastClick <= clickTimeframe)
    {
        ; Double-click detected
        waitingForSecondXButton2 := false
        Send, {F7}  ; Bone Window
        UpdateGui("Action: Bone Window (XButton2 double-click)")
    }
    else
    {
        ; Potential single click
        waitingForSecondXButton2 := true
        SetTimer, XButton2SingleClickAction, -%clickTimeframe%
    }
return

XButton2SingleClickAction:
    if (waitingForSecondXButton2)
    {
        waitingForSecondXButton2 := false
        Send, {F5}  ; Lung Window
        UpdateGui("Action: Lung Window (XButton2 single click)")
    }
return

; Right-click handling
RButton::
    if (GetKeyState("LButton", "P"))  ; Check if left button is also pressed
    {
        ToggleYKey()
        return
    }

    currentTime := A_TickCount
    timeSinceLastClick := currentTime - lastRightClickTime
    lastRightClickTime := currentTime
    
    if (waitingForSecondRightClick and timeSinceLastClick <= clickTimeframe)
    {
        ; Double-click detected
        waitingForSecondRightClick := false
        rightClickCounter := Mod(rightClickCounter + 1, 4)
        fKey := fKeys[rightClickCounter + 1]
        Send, {%fKey%}
        UpdateGui("Action: " . fKey . " sent (double-click)")
    }
    else
    {
        ; Potential single click or long click
        waitingForSecondRightClick := true
        SetTimer, RightClickAction, -%clickTimeframe%
    }
return

RightClickAction:
    if (waitingForSecondRightClick)
    {
        waitingForSecondRightClick := false
        if (GetKeyState("RButton", "P"))
        {
            ; Long click detected
            UpdateGui("Action: Long right-click detected (Intellerad window/level adjustment)")
            Send, {w down}  ; Press W key at the start of long click
            Send, {LButton Down}  ; Hold down left mouse button
            UpdateGui("Action: W key pressed, Left mouse button held down")
            
            KeyWait, RButton  ; Wait for button release
            
            Send, {w up}  ; Release W key
            Send, {LButton Up}  ; Release left mouse button
            Send, {s down}{s up}  ; Press and release S key
            UpdateGui("Action: W key released, left mouse button released, S key pressed and released")
        }
        else
        {
            ; Single click
            Send {RButton}
            UpdateGui("Action: Context menu shown (single click)")
        }
    }
return

; Left click handling
~LButton::
    if (GetKeyState("RButton", "P"))  ; Check if right button is also pressed
    {
        ToggleYKey()
        return
    }
    UpdateGui("Left Click detected")
return

; Middle click handling (for gestures)
MButton::
    PerformOrientationClick()
    UpdateGui("Middle Click detected, starting gesture recognition")
    result := GetMouseGesture(True)
    While GetKeyState("MButton", "P") {
        result := GetMouseGesture()
        ToolTip % result.gesture . (result.humanName ? " - " . result.humanName : "") . " (" . Round(result.similarity * 100) . "% match)"
        Sleep 150
    }
    ToolTip  ; Clear the tooltip
    
    if (result.hotkey) {
        if (result.hotkey == "ZoomMeasureReset") {
            PerformZoomMeasureReset()
        } else if (IsObject(result.hotkey)) {
            for index, key in result.hotkey {
                Send % key
            }
        } else {
            Send % result.hotkey
        }
        UpdateGui("Action: Gesture " . result.gesture . " recognized and executed (" . result.humanName . ") with " . Round(result.similarity * 100) . "% similarity")
    }
    else
    {
        UpdateGui("No gesture recognized (Best match: " . Round(result.similarity * 100) . "% similarity)")
    }
return

; Improved function for Zoom, Measure, Reset routine with multi-screen support
PerformZoomMeasureReset() {
    Send, z  ; Activate zoom
    UpdateGui("Action: Zoom activated")
    KeyWait, LButton, D  ; Wait for left mouse button to be pressed
    KeyWait, LButton  ; Wait for left mouse button to be released
    Send, y  ; Activate measure
    UpdateGui("Action: Measure activated")
    KeyWait, LButton, D  ; Wait for left mouse button to be pressed
    KeyWait, LButton  ; Wait for left mouse button to be released

    ; Create a new GUI for the reset prompt
    Gui, ResetPrompt:New, +AlwaysOnTop +ToolWindow

    ; Get current mouse position and monitor info
    MouseGetPos, mouseX, mouseY, windowUnderMouse, controlUnderMouse, 2
    SysGet, monitorCount, MonitorCount
    SysGet, primaryMonitor, MonitorPrimary

    ; Find which monitor the mouse is on
    Loop, %monitorCount%
    {
        SysGet, monArea, Monitor, %A_Index%
        if (mouseX >= monAreaLeft && mouseX < monAreaRight && mouseY >= monAreaTop && mouseY < monAreaBottom)
        {
            currentMonitor := A_Index
            break
        }
    }

    ; Calculate GUI position
    guiW := 220  ; Estimated width of the GUI
    guiH := 100  ; Estimated height of the GUI
    guiX := (mouseX + guiW > monAreaRight) ? monAreaRight - guiW : mouseX
    guiY := (mouseY + guiH > monAreaBottom) ? monAreaBottom - guiH : mouseY

    ; Add controls to the GUI
    Gui, ResetPrompt:Add, Text,, Press Reset when ready:
    Gui, ResetPrompt:Add, Button, gResetViewerAction w100, Reset Viewer
    Gui, ResetPrompt:Add, Button, gCancelReset w100, Cancel

    ; Show the GUI near the mouse cursor
    Gui, ResetPrompt:Show, x%guiX% y%guiY% NoActivate, Reset Viewer
    UpdateGui("Action: Reset prompt displayed")

    ; Make the GUI movable
    WinSet, Style, +0x80000, Reset Viewer

    ; Wait for user action while allowing other functions to run
    SetTimer, CheckResetPrompt, 100
    return

ResetViewerAction:
    Gui, ResetPrompt:Destroy
    SetTimer, CheckResetPrompt, Off
    Send, ^{Backspace}  ; Reset viewer
    UpdateGui("Action: Viewer reset (Reset button pressed)")
    return

CancelReset:
    Gui, ResetPrompt:Destroy
    SetTimer, CheckResetPrompt, Off
    UpdateGui("Action: Reset cancelled (Cancel button pressed)")
    return

CheckResetPrompt:
    if (!WinExist("Reset Viewer"))
    {
        SetTimer, CheckResetPrompt, Off
        if (!A_GuiEvent)  ; If GUI was closed without pressing a button
            UpdateGui("Action: Reset prompt closed (Window closed)")
    }
    return
}

; Ensure this is added to handle GUI closure
ResetPromptGuiClose:
ResetPromptGuiEscape:
    Gui, ResetPrompt:Destroy
    SetTimer, CheckResetPrompt, Off
    UpdateGui("Action: Reset prompt closed (Window closed or Esc pressed)")
return

; Additional mouse button logging for troubleshooting
~WheelUp::UpdateGui("Wheel Up detected")
~WheelDown::UpdateGui("Wheel Down detected")

; Hotkey to clear the log
^+c::  ; Ctrl+Shift+C to clear
GuiControl,, EventText, Log Cleared
return

; Hotkey to exit script
^Esc::ExitApp

GuiClose:
ExitApp

; GetMouseGesture function
GetMouseGesture(reset := false) {
    Static xpos1, ypos1, xpos2, ypos2, currentGesture
    global gestures
    MouseGetPos, xpos2, ypos2
    if (reset) {
        xpos1 := xpos2, ypos1 := ypos2
        currentGesture := ""
        Return {gesture: currentGesture, hotkey: "", humanName: ""}
    }
    dx := xpos2 - xpos1, dy := ypos1 - ypos2
    if (abs(dy) >= abs(dx))
        track := dy > 0 ? "u" : "d"
    else
        track := dx > 0 ? "r" : "l"
    if (abs(dy) < 6 and abs(dx) < 6)
        track := ""
    xpos1 := xpos2, ypos1 := ypos2
    if (track != SubStr(currentGesture, 0, 1))
        currentGesture .= track
    
    return EvaluateGesture(currentGesture)
}

; Function to evaluate gestures
EvaluateGesture(currentGesture) {
    global gestures
    bestMatch := ""
    bestMatchScore := 0
    gestureLength := StrLen(currentGesture)

    for gestureIndex, gestureItem in gestures {
        similarity := CalculateSimilarity(currentGesture, gestureItem.gesture)
        if (similarity > bestMatchScore) {
            bestMatch := gestureItem
            bestMatchScore := similarity
        }
    }

    ; Define a threshold for gesture recognition (e.g., 0.7 or 70% similarity)
    if (bestMatchScore >= 0.7) {
        return {gesture: bestMatch.gesture, hotkey: bestMatch.hotkey, humanName: bestMatch.humanName, similarity: bestMatchScore}
    } else {
        return {gesture: currentGesture, hotkey: "", humanName: "", similarity: bestMatchScore}
    }
}

; Function to calculate similarity between two gestures
CalculateSimilarity(gesture1, gesture2) {
    len1 := StrLen(gesture1)
    len2 := StrLen(gesture2)
    maxLen := Max(len1, len2)
    
    if (maxLen == 0)
        return 1.0  ; Both strings are empty
    
    commonPrefix := 0
    while (commonPrefix < len1 && commonPrefix < len2 && SubStr(gesture1, commonPrefix+1, 1) == SubStr(gesture2, commonPrefix+1, 1))
        commonPrefix++
    
    return commonPrefix / maxLen
}

; Function to toggle Y key press
ToggleYKey() {
    global yKeyPressed
    if (yKeyPressed) {
        Send, {y up}
        UpdateGui("Action: Y key released (simultaneous left and right click)")
        yKeyPressed := false
    } else {
        Send, {y down}
        UpdateGui("Action: Y key pressed (simultaneous left and right click)")
        yKeyPressed := true
    }
}

; Perform orientation click
PerformOrientationClick() {
    Click
    Sleep, 50  ; Short delay to ensure the click is registered
}
