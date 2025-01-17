﻿#Include Crossfirer_Functions.ahk
Preset("断")
DetectHiddenWindows, On
SetTitleMatchMode, Regex
;==================================================================================
global NBK_Service_On := False
global Net_On := True
Net_Start := 0
nb_block := False
nb_allow := False
CheckPermission("一键限网")
hwndcf := WinExist("ahk_class CrossFire")
If ProcessExist("NLClientApp.exe")
{
    WinActivate, ahk_exe NLClientApp.exe
    Nclickx := 416, Nclicky := 130
    ToolTip, NetLimiter版一键限速已就绪!`nNetLimiter version of onekey-bandwidth-limiter is ready!
    HyperSleep(3000)
    ToolTip ;隐藏提示
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
}
Else If WinExist("ahk_class Q360NetFosClass")
{
    WinActivate, ahk_class Q360NetFosClass
    CheckPosition(X360, Y360, W360, H360, "Q360NetFosClass")
    clickx := Round(W360 / 5), clicky := Round(H360 / 2.8) ;右键位置
    ToolTip, 360版一键限速已就绪!`n360 version of onekey-bandwidth-limiter is ready!
    HyperSleep(3000)
    ToolTip ;隐藏提示
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
}
Else
{
    MsgBox, 262160, 错误/Error, 未找到指定流量限速程序!辅助将退出!!`nUnable to find bandwidth limiter!The program will exit!!, 3
    Exitapp
}
;==================================================================================
If (WinExist("ahk_class CrossFire"))
{
    H_pressed := A_TickCount
    WinGetTitle, CF_Title, ahk_class CrossFire
    If CF_Title = CROSSFIRE
        Net_Time := 6
    Else If CF_Title = 穿越火线
        Net_Time := 8
    Net_Allowed := Net_Time
    Net_Text := "一键断天涯|"Net_Time
    CheckPosition(X3e, Y3e, W3e, H3e, "CrossFire")
    Gui, net_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, net_status: Margin, 0, 0
    Gui, net_status: Color, 333333 ;#333333
    Gui, net_status: Font, S20 Q5, Microsoft YaHei
    Gui, net_status: Add, Text, hwndGui_9 vNetBlock c00FFFF, %Net_Text% ;#00FFFF
    GuiControlGet, P9, Pos, %Gui_9%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
    Gui, net_status: Show, Hide ;x%XGui9% y%YGui9% NA
    OnMessage(0x1001, "ReceiveMessage")
    NBK_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#If WinActive("ahk_class CrossFire") && NBK_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On 
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    Suspended()
    SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
    If !Net_On
        Gui, net_status: Show, x%XGui9% y%YGui9% NA
    Else
        Gui, net_status: Show, Hide
Return

~*H Up::
    ;保证短时间内无法连续点击破坏断网效果
    If (1000 <= A_TickCount - H_pressed)
        H_pressed := A_TickCount
    Else If (1000 > A_TickCount - H_pressed)
        Return

    If WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]") && !GetKeyState("vk87")
    {
        Net_On := !Net_On
        WinMove, ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+], , -400, 50, 700, 500 ;移动到不影响战斗同时能看清规则是否激活的地点
        Gui, net_status: Show, x%XGui9% y%YGui9% NA
        Release_All_Keys() ;释放所有按键防止误触
        If !Net_On
            SetTimer, UpdateNet, 100
        Else
        {
            SetTimer, UpdateNet, Off
            Net_Start := 0, Net_Time := Net_Allowed
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
        FlashClick(Nclickx, Nclicky, "ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]") ;开关都一样
    }
    Else If NBK_Service_On && (hwnd360 := WinExist("ahk_class Q360NetFosClass"))
    {
        Net_On := !Net_On
        
        Gui, net_status: Show, x%XGui9% y%YGui9% NA
        FlashPress(clickx, clicky, "ahk_class Q360NetFosClass", "ahk_class #32768")
        If !Net_On
            SetTimer, UpdateNet, 100
        Else
        {
            SetTimer, UpdateNet, Off
            Net_Start := 0, Net_Time := Net_Allowed
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
Return
;==================================================================================
UpdateNet() ;精度0.1s
{
    global XGui9, YGui9, Net_Start, Net_Time, clickx, clicky, Nclickx, Nclicky, hwndcf, hwnd360, H360, Net_Text
    Net_Timer(XGui9, YGui9, Net_On, Net_Start, Net_Time, Net_Text, "net_status", "NetBlock")
    If Net_On
    {
        Gui, net_status: Show, Hide
        SetTimer, UpdateNet, Off
        If WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        {
            Release_All_Keys()
            FlashClick(Nclickx, Nclicky, "ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        }
        Else If WinExist("ahk_class Q360NetFosClass")
        {
            Release_All_Keys()
            FlashPress(clickx, clicky, "ahk_class Q360NetFosClass", "ahk_class #32768")
        }
    }
}
;==================================================================================
;断网计时器
Net_Timer(XGui9, YGui9, ByRef Net_On, ByRef Net_Start, ByRef Net_Time, ByRef Net_Text, Gui_Number, ControlID)
{
    global Net_Allowed
    If !Net_On
    {
        If Net_Start = 0
            Net_Start := SystemTime()
        Else
        {
            Net_Time := Round(Net_Allowed + 0.5 - (SystemTime() - Net_Start) / 1000)
            If Net_Time >= 6
                GuiControl, %Gui_Number%: +c00FFFF +Redraw, %ControlID% ;#00FFFF
            Else If (Net_Time <= 5 && Net_Time > 2)
                GuiControl, %Gui_Number%: +cFFFF00 +Redraw, %ControlID% ;#FFFF00
            Else If (Net_Time <= 2 && Net_Time > 0)
                GuiControl, %Gui_Number%: +cFF0000 +Redraw, %ControlID% ;#FF0000
            Else If Net_Time <= 0
            {
                Net_Start := 0
                Net_Time := Net_Allowed
                Net_On := !Net_On
            }
            Net_Text := "一键断天涯|"Net_Time
            UpdateText(Gui_Number, ControlID, Net_Text, XGui9, YGui9)
        }
    }
}
;==================================================================================
;模拟点击界面指定位置,代替controlclick
FlashClick(clickx1, clicky1, winID)
{
    global hwndcf, Xnb, Ynb, Wnb, Hnb, X3e, Y3e, W3e, H3e
    CheckPosition(Xnb, Ynb, Wnb, Hnb, winID)
    CheckPosition(X3e, Y3e, W3e, H3e, "CrossFire")
    BlockInput, On
    lParam := clickx1 & 0xFFFF | (clicky1 & 0xFFFF) << 16
    WinActivate, %winID%
    If hwndnt4 := WinExist(winID) ;确保窗口置顶...
        DllCall("SwitchToThisWindow", "UInt", hwndnt4, "UInt", 1)
    CoordMode, Mouse, Client
    MouseClick, Left, clickx1, clicky1
    MouseMove, clickx1, clicky1
    PostMessage, 0x204, 2, %lParam%, , ahk_id %hwndnt4% ;WM_RBUTTONDOWN
    PostMessage, 0x205, 2, %lParam%, , ahk_id %hwndnt4% ;WM_RBUTTONUP
    HyperSleep(10)
    Loop, 4
    {
        ControlSend, , {Down}, %winID%
        HyperSleep(10)
    }
	ControlSend, , {Enter}, %winID%
    HyperSleep(10)
    WinActivate, ahk_class CrossFire
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
    CoordMode, Mouse, Screen
    MouseMove, X3e + W3e // 2, Y3e + H3e // 2
    BlockInput, Off
}
;==================================================================================
;模拟指定界面按键
FlashPress(clickx1, clicky1, winID, menuID)
{
    global Net_On, hwndcf
    ControlClick, x%clickx1% y%clicky1%, %winID%, , Right, , NA ;PostMessage, 0x204, 2, 0x3201A9, , %winID% ;PostMessage, 0x205, 2, 0x3201A9, , %winID%
    Loop
    {
        HyperSleep(1)
    } Until WinExist(menuID)
    ControlSend, , {Down}, %menuID% ;PostMessage, 0x100, 0x28, 0, %menuID%
    If Net_On
    {
        ControlSend, , {Down}, %menuID% ;PostMessage, 0x100, 0x28, 0, %menuID%
    }
    ControlSend, , {Enter}, %menuID% ;PostMessage, 0x100, 0xD, 0, %menuID%
}
;==================================================================================