﻿#Include Crossfirer_Functions.ahk
Preset("点")
;==================================================================================
global CLK_Service_On := False
CheckPermission()
SysGet, Mouse_Buttons, 43 ;检测鼠标按键数量
If Mouse_Buttons < 5
{
    MsgBox, 262144, 鼠标按键数量不足/Not enough buttons on mouse, 请考虑更换鼠标,不然无法使用本连点辅助/Please consider getting a new mouse, or you will not able to use this auto clicker
    ;ExitApp
}
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Gui, click_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, click_mode: Margin, 0, 0
    Gui, click_mode: Color, 333333 ;#333333
    Gui, click_mode: Font, S10 Q5, Microsoft YaHei
    Gui, click_mode: Add, Text, hwndGui_5 vModeClick c00FF00, 连点准备 ;#00FF00
    GuiControlGet, P5, Pos, %Gui_5%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, Round(He / 3.6) - P5H // 2)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    OnMessage(0x1001, "ReceiveMessage")
    CLK_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#IfWinActive, ahk_class CrossFire ;以下的热键需要CF窗口活跃才能激活
~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If CLK_Service_On
    {
        If Is_Chatting()
            Suspend, On 
        Suspended()
    }
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    If CLK_Service_On
    {
        Suspended()
        SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, Round(He / 3.6) - P5H // 2)
        Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    }
Return

~*MButton:: ;爆裂者轰炸
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "右键速点", XGui3, YGui3)
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P")) && WinActive("ahk_class CrossFire") ;避免切换窗口时影响
        {
            press_key("RButton", 10.0, 50.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{RButton Up}
    }
Return

~*XButton2:: ;炼狱连刺
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "炼狱连刺", XGui3, YGui3)
        cnt := 0
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P") || cnt > 10) && WinActive("ahk_class CrossFire")
        {
            press_key("RButton", 10.0, 270.0) ;炼狱右键
            press_key("LButton", 10.0, 10.0) ;炼狱左键枪刺归位
            cnt += 1
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return

~*XButton1:: ;半自动速点,适合加特林速点,不适合USP
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键速点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P")) && WinActive("ahk_class CrossFire")
        {
            Random, RanClick, 88.0, 92.0
            press_key("LButton", RanClick, 120.0 - RanClick) ;貌似tx开始严查间隔小于100的按击
            ;press_key("LButton", 30.0, 30.0) ;炼狱加特林射速1000发/分
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*":: ;大宝剑二段连击
~*'::
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "二段连击", XGui3, YGui3)
        press_key("RButton", 1050, 150)
        press_key("RButton", 90, 10)
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P")) && WinActive("ahk_class CrossFire")
        {
            press_key("RButton", 490, 10)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return

~*|:: ;左键直射
~*\::
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键不放", XGui3, YGui3)
        Send, {Blind}{LButton Up}
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("RButton", "P")) && WinActive("ahk_class CrossFire") && !GetKeyState("vk87")
        {
            If !GetKeyState("LButton")
                Send, {LButton Down}
            HyperSleep(100)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*::: ;炼狱热管
~*;:: 
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "炼狱热管", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P") || GetKeyState("XButton1", "P")) && WinActive("ahk_class CrossFire") && !GetKeyState("vk87") ;炼狱速点时结束
        {
            press_key("LButton", 10.0, 110.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return
;==================================================================================