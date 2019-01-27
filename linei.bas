$regfile = "m32def.dat"
$crystal = 8000000

$hwstack = 64
$swstack = 64
$framesize = 64

$lib "glcdKS108.LBX"
$include "font8x8.font"

Declare Sub Main
Declare Sub Scan
Declare Sub Read_X
Declare Sub Read_Y
Declare Sub Calibration_x1_y1
Declare Sub Calibration_x2
Declare Sub Calibration_y2
Declare Sub Calibration
Declare Sub Paint
Declare Sub Calib_Point (byval a as Integer,byval b as Integer )
Declare Sub Sideber(byval _X as Byte,Byval _Y as Byte)

Config Graphlcd = 128 * 64sed , Dataport = Portd , Controlport = Portb , Ce = 1 , Ce2 = 2 , Cd = 5 , Rd = 4 , Reset = 0 , Enable = 3
Setfont Font8x8

GoSub Main


Dim X As Word
Dim Y As Word
Dim x_old as Word
Dim y_old as Word
x_old = 0
y_old = 0
Dim X_e As Single
Dim X1 As Word
Dim X2 As Word
Dim Y_e As Single
Dim Y1 As Word
Dim Y2 As Word
Dim Var As Word
Dim Var1 As Single
Dim Pcolor As Byte
Dim Darkmode As Boolean

Sub Main:
    GoSub Calibration
    GoSub Paint
END Sub

Sub Scan:
    GoSub Read_X
    Waitms 10
    GoSub Read_Y
    Waitms 10
END Sub

Sub Read_X:
    Config Porta.0 = Output
    Config Pina.1 = Input
    Config Porta.2 = Output
    Config Pina.3 = Input
    Set Porta.0
    Reset Porta.1
    Reset Porta.2
    Reset Porta.3
    Config Adc = Single , Prescaler = Auto
    Start Adc
    X = Getadc(1)
END Sub

Sub Read_Y:
    Config Pina.0 = Input
    Config Porta.1 = Output
    Config Pina.2 = Input
    Config Porta.3 = Output
    Reset Porta.0
    Set Porta.1
    Reset Porta.2
    Reset Porta.3
    Config Adc = Single , Prescaler = Auto
    Start Adc
    Y = Getadc(2)
END Sub

Sub Calib_Point (byval a as Integer,byval b as Integer)
    Cls
    Pset a   , b   , 255
    Pset a+1 , b   , 255
    Pset a   , b+1 , 255
    Pset a+1 , b+1 , 255
END Sub

Sub Calibration_x1_y1:
    Call Calib_Point(0,0)
    Do
        GoSub Scan
    Loop Until X>50
    Waitms 50
    GoSub Scan
    X1 = X
    Y1 = Y
    Cls
    Lcdat 5 , 1 , "     +Saved     " , 0
    Do
        GoSub Scan
    Loop Until X<50
END Sub

Sub Calibration_x2:
    Call Calib_Point(126,0)
    Do
        GoSub Scan
    Loop Until X>50
    Waitms 50
    GoSub Scan
    X2 = X
    Cls
    Lcdat 5 , 1 , "     +Saved     " , 0
    Do
        GoSub Scan
    Loop Until X<50
END Sub

Sub Calibration_y2:
    Call Calib_Point(0,62)
    Do
        GoSub Scan
    Loop Until Y>50
    Waitms 50
    GoSub Scan
    Y2 = Y
    Cls
    Lcdat 5 , 1 , "     +Saved     " , 0
    Do
        GoSub Scan
    Loop Until Y<50
END Sub

Sub Calibration:
    GoSub Calibration_x1_y1
    GoSub Calibration_x2
    GoSub Calibration_y2
    If X1 > X2 Then
        Var = X1 - X2
        X_e = Var / 128
    Else
        Var = X2 - X1
        X_e = Var / 128
    End If
    If Y1 > Y2 Then
        Var = Y1 - Y2
        Y_e = Var / 64
    Else
        Var = Y2 - Y1
        Y_e = Var / 64
    End If
END Sub

Sub Sideber(byval _X as Byte,Byval _Y as Byte)
    If _X<22 Then
        If _Y<22 Then'save

        Elseif _Y<42 Then'open

        Else'invert
            Darkmode = Not Darkmode
            if Darkmode = 1 Then
                SHOWPIC 0,0,inv
            Else
                SHOWPIC 0,0,org
            End If
        End If
    Else
        If _Y<22 Then'pen

        Elseif _Y<42 Then'erase

        Else'erase all

        End If
    End If
End Sub

Sub Paint:
    Cls
    Pcolor = 255
    Darkmode = 0
    Do
        GoSub Scan
        If X1 < X2 Then
            Var = X - X1
            Var1 = Var / X_e
            X = Var1
        End If
        If X2 < X1 Then
            Var = X - X2
            Var1 = Var / X_e
            X = Var1
            X = 128 - x
        End If

        If Y1 < Y2 Then
            Var = Y - Y1
            Var1 = Var / Y_e
            Y = Var1
        End If
        If Y2 < Y1 Then
            Var = Y - Y2
            Var1 = Var / Y_e
            Y = Var1
            Y = 64 - y
        End If

        If X < 128 And Y < 64 Then
            If X<45 Then
                Call Sideber(X,Y)
            End If
            'Pset X , Y , Pcolor
            line(x_old,y_old)-(X,Y), Pcolor
            x_old = X
            y_old = Y
        End If
    Loop
END Sub

END

org:
   $bgf "org.bgf"
inv:
   $bgf "inv.bgf"