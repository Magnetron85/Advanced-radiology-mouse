#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Initialize variables
rightClickCounter := 0
fKeys := ["F4", "F5", "F6", "F7"]  ; Cycle through F4, F5, F6, F7
clickTimeframe := 250  ; Time in milliseconds to wait for a potential double-click
longClickThreshold := 500  ; Time in milliseconds to consider a click as a long click
lastRightClickTime := 0
waitingForSecondRightClick := false

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

; Add Gesture Reminders
Gui, Add, Text, vGestureReminder,
(
Gesture Reminders:
Text: 			UL (Up-Left)
Arrow: 			UR (Up-Right)   
Measure:		L  (Left)    
ROI:			R  (Right)     
Scroll:			UD (Up-Down) or DU (Down-Up)
Prior Nav:		DL (Down-Left) and DR (Down-Right)
Delete meas/ann:	LR (Left-Right) or RL (Right-Left)
)

; Add Event Log
Gui, Add, Text, y+20, Event Log:
Gui, Add, Edit, vEventText w400 h250 ReadOnly

; Show GUI
Gui, Show, w420 h400, Corsair M55 Mouse Action Tracker

; Function to update GUI
UpdateGui(action) {
    global EventText
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
        Send, {PgUp}
        UpdateGui("Action: Page Up sent (XButton1 double-click)")
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
        Send, {Left}
        UpdateGui("Action: Left Arrow sent (XButton1 single click)")
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
        Send, {PgDn}
        UpdateGui("Action: Page Down sent (XButton2 double-click)")
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
        Send, {Right}
        UpdateGui("Action: Right Arrow sent (XButton2 single click)")
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
    UpdateGui("Middle Click detected, starting gesture recognition")
    GetMouseGesture(True)
    While GetKeyState("MButton", "P") {
        ToolTip % MG := GetMouseGesture()
        Sleep 150
    }
    ToolTip  ; Clear the tooltip
    
    if (IsFunc(MG)) {
        %MG%()
        UpdateGui("Action: Gesture " . MG . " recognized and executed")
    }
    else
    {
        UpdateGui("No gesture recognized")
        ; Send {MButton}
    }
return

; Additional mouse button logging for troubleshooting
~WheelUp::UpdateGui("Wheel Up detected")
~WheelDown::UpdateGui("Wheel Down detected")

; Hotkey to clear the log
^c::  ; Ctrl+C to clear
GuiControl,, EventText, Log Cleared
return

; Hotkey to exit script
Esc::ExitApp

GuiClose:
ExitApp

; Mouse gesture functions
R() {
    Send, {j}
    UpdateGui("Action: J key sent (Right gesture)")
}

L() {
    Send, {y}
    UpdateGui("Action: Y key sent (Left gesture)")
}

UD() {
    Send, {s}
    UpdateGui("Action: S key sent (Up-Down gesture)")
}

DU() {
    Send, {s}
    UpdateGui("Action: S key sent (Down-Up gesture)")
}

DL() {
    Send, {]}
    UpdateGui("Action: } key sent (Down-Left gesture)")
}

UR() {
    Send, ^a  ; This sends Ctrl+A
    UpdateGui("Action: Ctrl+A sent (Up-Right gesture)")
}


UL() {
    Send, ^t  ; This sends Ctrl+T
    UpdateGui("Action: Ctrl+T sent (Up-Right gesture)")
}

LR() {
    Send, ^y  ; This sends Ctrl+A
	Send, +q  ; This sends Ctrl+Q
    UpdateGui("Action: Ctrl+Y and Shift+Q sent (Left-Right gesture)")
}

RL() {
    Send, ^y  ; This sends Ctrl+A
	Send, +q  ; This sends Ctrl+Q
    UpdateGui("Action: Ctrl+Y and Shift+Q sent (Left-Right gesture)")
}

DR() {
    Send, {[}  
    UpdateGui("Action: { sent (Left-Right gesture)")
}

; GetMouseGesture function
GetMouseGesture(reset := false) {
    Static xpos1, ypos1, xpos2, ypos2, gesture
    MouseGetPos, xpos2, ypos2
    if (reset) {
        xpos1 := xpos2, ypos1 := ypos2
        gesture := ""
        Return gesture
    }
    dx := xpos2 - xpos1, dy := ypos1 - ypos2
    if (abs(dy) >= abs(dx))
        track := dy > 0 ? "u" : "d"
    else
        track := dx > 0 ? "r" : "l"
    if (abs(dy) < 10 and abs(dx) < 10)
        track := ""
    xpos1 := xpos2, ypos1 := ypos2
    if (track != SubStr(gesture, 0, 1))
        gesture .= track
    Return gesture
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