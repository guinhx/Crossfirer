﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force
#IfWinActive ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
#Include Crossfirer_Functions.ahk  
#KeyHistory 0
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
;==================================================================================
CheckPermission()
CheckCompile()
;==================================================================================
Gun_Chosen := 0
XGui5 := 0, YGui5 := 0, XGui6 := 0, YGui6 := 0, XGui7 := 0, YGui7 := 0
Vertices := 40
Radius := 0
Diameter := 2 * Radius
Angle := 8 * ATan(1) / Vertices
Hole = 

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xrs, Yrs, Wrs, Hrs, Offset1Up, Offset1Down)
    Radius := Round((Hrs - Offset1Up - Offset1Down) / 18)
    Diameter := 2 * Radius
    Start:
    Gui, recoil_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, recoil_mode: Margin, 0, 0
    Gui, recoil_mode: Color, 333333 ;#333333
    Gui, recoil_mode: Font, s15, Microsoft YaHei
    Gui, recoil_mode: Add, Text, hwndGui_6 vModeClick c00FF00, 压枪准备 ;#00FF00
    GuiControlGet, P6, Pos, %Gui_6%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 8) - P6W // 2, Round((Hrs - Offset1Up - Offset1Down) / 9) - P6H // 2)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA, Listening

    Gui, gun_sel: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, gun_sel: Margin, 0, 0
    Gui, gun_sel: Color, 333333 ;#333333
    Gui, gun_sel: Font, s15, Microsoft YaHei
    Gui, gun_sel: Add, Text, hwndGui_7 vModeGun c00FF00, 暂未选枪械 ;#00FF00
    GuiControlGet, P7, Pos, %Gui_7%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 8) - P7W // 2, Round((Hrs - Offset1Up - Offset1Down) / 6) - P7H // 2)
    Gui, gun_sel: Show, x%XGui6% y%YGui6% NA, Listening

    Gui, circle: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcc -DPIScale
    Gui, circle: Color, FFFF00 ;#FFFF00
    SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
    Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA, Listening
    WinSet, Transparent, 31, ahk_id %cc%
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    Xcc := Radius, Ycc := Radius
    Loop, %Vertices%
        Hole .= Floor(Xcc + Radius * Cos(A_Index * Angle)) "-" Floor(Ycc + Radius * Sin(A_Index * Angle)) " "
    Hole .= Floor(Xcc + Radius * Cos(Angle)) "-" Floor(Ycc + Radius * Sin(Angle))
    WinSet, Region, %Hole%, ahk_id %cc% 
    Hole = ;free memory
    Gui, circle: Show, Hide, Listening
    OnMessage(0x1001, "ReceiveMessage")
    Return
}
Else If !WinExist("ahk_class CrossFire") && !A_IsCompiled
{
    MsgBox, , 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!, 3
    ExitApp
}
;==================================================================================
~*-::ExitApp

~*RAlt::
    SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 8) - P6W // 2, Round((Hrs - Offset1Up - Offset1Down) / 9) - P6H // 2)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA, Listening
    SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 8) - P7W // 2, Round((Hrs - Offset1Up - Offset1Down) / 6) - P7H // 2)
    Gui, gun_sel: Show, x%XGui6% y%YGui6% NA, Listening
Return

~*LButton:: ;压枪 正在开发
    SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
    Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA, Listening
    If (!Not_In_Game() && Gun_Chosen > 0)
    {
        GuiControl, recoil_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("recoil_mode", "ModeClick", "自动压枪", XGui5, YGui5)
        Recoilless(Gun_Chosen)
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    Gui, circle: Show, Hide, Listening
    If !Not_In_Game()
    {
        GuiControl, recoil_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("recoil_mode", "ModeClick", "压枪准备", XGui5, YGui5)
    }
Return

~*RButton:: ;压枪 正在开发
    SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
    Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA, Listening
Return

~*Rbutton Up:: ;保障新一轮压枪
    Gui, circle: Show, Hide, Listening
Return

~*Numpad0::
    If !Not_In_Game()
    {
        GuiControl, gun_sel: +c00FF00 +Redraw, ModeGun ;#00FF00
        UpdateText("gun_sel", "ModeGun", "暂未选枪械", XGui6, YGui6)
        Gun_Chosen := 0
    }
Return

~*Numpad1::
    If !Not_In_Game()
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "AK47-B 系", XGui6, YGui6)
        Gun_Chosen := 1
    }  
Return

~*Numpad2::
    If !Not_In_Game()
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "M4A1-S 系", XGui6, YGui6)
        Gun_Chosen := 2
    }
Return
