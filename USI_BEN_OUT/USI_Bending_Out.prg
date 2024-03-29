Global Integer i, j, product, x, y, SP_SDef, SP_NDef, Total_XY, ex_product, ex_j, Start_Product
Global String cmd$, Return_code$, cmd_plu$
Global Boolean IsBuzy, Grip_Pass, product_load, test_mode
Global Real Thick_Conveyor, Thick_Platform '輸送帶到工件的厚度,平台到工件的厚度
Function main
	'V1.4BO
	Reset
	OnErr GoTo handle
	Motor On
	Wait Motor = On
	Power High
	'----
	LoadPoints "robot3.pts"
	Weight 1 '治具+工件重量
	Call DefSpeed
	SetNet #203, "192.168.0.23", 2000, CRLF, NONE, 0, TCP
'	SetNet #209, "192.168.0.23", 2001, CRLF, NONE, 0, TCP
'	OpenNet #209 As Server
	TCLim 50, 50, 50, 50, 50, 50
	
	'----
'	Grip_Pass = True '夾爪相關PASS
'	test_mode = True
	Integer re0
	re0 = 0
	Call MovetoPallet_Teach_Out(ByRef re0)
	
'	Xqt Move_Test_Out
	'---
	IsBuzy = False
'	Xqt Pause_RESET, NoPause
	Xqt tcpipcmd_Out, NoPause
	Exit Function
handle:
	Print "Error occer"
	Print "ERR:", SysErr
		Return_code$ = "ERR:" + Str$(SysErr)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", SysErr
		EndIf
		If ChkNet(209) > 0 Then
			Print #209, "ERR;", SysErr
		EndIf
	Reset
Fend
Function DefSpeed
	SP_NDef = 40
	Speed SP_NDef
	Accel SP_NDef, SP_NDef
	SP_SDef = 600
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function Move_Test_Out
	Integer re0
	re0 = 0
	Call MovetoPallet_Teach_Out(ByRef re0)
	Call GoHome_Out
	Do
		Call MovetoPick_Out
		Call MoveToPut_Out
	Loop
Fend
Function Pause_RESET
	Do
        If (PauseOn = True Or SafetyOn = True) And ChkNet(203) <> -2 Then
     		Print "暫停", ChkNet(203), PauseOn, SafetyOn
			OpenNet #203 As Server
		 	WaitNet #203, 30
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do
			 		If ChkNet(203) > 0 Then '連線埠有資料 Or Pass_Tcpip = True	
				 		Line Input #203, cmd_plu$
				 		Print " #203 暫停-等待指令中,", ChkNet(203)
				 		Wait 1
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 			Select Left$(Trim$(cmd_plu$), 4)
						 		Case "RSET"
							 		Print #203, SysErr
							 		Print "ERROR CORD:", SysErr
							 		CloseNet #203
								 	Print "Disconnected"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #203, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
		 		Loop
		 	EndIf
		EndIf
	Loop
Fend
Function MovetoPallet_Teach_Out(ByRef product_local As Integer)
	'Robot 3
	IsBuzy = True
	product_load = False
	j = 0
	Thick_Conveyor = 0 '輸送帶到工件的高度
	Thick_Platform = 0 '平台到工件的高度
	Select product_local
		Case 0
			
			x = 4 'X標準值
			y = 3 'Y標準值
			Start_Product = 100 '產品起點(10點)
			
			
			product_load = True
		Case 1
	Send

	If product_load = True Then
		product = product_local
		j = 1
		
		If CU(P(Start_Product)) + CU(P(Start_Product + 8)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 8)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 8)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8)
		EndIf
		If CU(P(Start_Product + 3)) + CU(P(Start_Product + 9)) > 180 Then
			pick = P(Start_Product + 3) + P(Start_Product + 9) :U((CU(P(Start_Product)) + CU(P(Start_Product + 9))) - 360)
		Else
			pick = P(Start_Product + 3) + P(Start_Product + 9)
		EndIf
		
'		PL1 = P(Start_Product) + P(Start_Product + 8)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 8)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 8)
'		pick = P(Start_Product + 3) + P(Start_Product + 9)
		Barcode1 = P(Start_Product + 4)
		Barcode2 = P(Start_Product + 5)
		NG1 = P(Start_Product + 6)
		NG2 = P(Start_Product + 7)
		Pallet 0, PL1, PL2, PL3, x, y
		Return_code$ = "RunFinish;PROD;" + Str$(product)
		Total_XY = x * y
		
	Else
		Return_code$ = "ERR;PROD"
		Total_XY = 0
	EndIf
	Print Return_code$
	IsBuzy = False
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real, Offset_X2 As Real, Offset_Y2 As Real, Offset_Z2 As Real, Offset_U2 As Real)
	If Start_Product >= 0 Then
		P(Start_Product + 8) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U)
		P(Start_Product + 9) = XY(Offset_X2, Offset_Y2, Offset_Z2, Offset_U2)
		SavePoints "robot3.pts"
		If CU(P(Start_Product)) + Offset_U > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 8)) :U((CU(P(Start_Product)) + Offset_U) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8) :U((CU(P(Start_Product)) + Offset_U) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8) :U((CU(P(Start_Product)) + Offset_U) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 8)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8)
		EndIf
		If CU(P(Start_Product + 3)) + Offset_U2 > 180 Then
			pick = P(Start_Product + 3) + P(Start_Product + 9) :U((CU(P(Start_Product)) + Offset_U2) - 360)
		Else
			pick = P(Start_Product + 3) + P(Start_Product + 9)
		EndIf
'		PL1 = P(Start_Product) + P(Start_Product + 8)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 8)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 8)
'		pick = P(Start_Product + 3) + P(Start_Product + 9)
		Pallet 0, PL1, PL2, PL3, x, y
		Return_code$ = "SETSHIFT;" + Str$(Offset_X) + ";" + Str$(Offset_Y) + ";" + Str$(Offset_Z) + ";" + Str$(Offset_U) + ";" + Str$(Offset_X2) + ";" + Str$(Offset_Y2) + ";" + Str$(Offset_Z2) + ";" + Str$(Offset_U2)
	EndIf
Fend
Function Get_XYZU
	Return_code$ = "GETSHIFT;" + Str$(CX(P(Start_Product + 8))) + ";" + Str$(CY(P(Start_Product + 8))) + ";" + Str$(CZ(P(Start_Product + 8))) + ";" + Str$(CU(P(Start_Product + 8))) + ";" + Str$(CX(P(Start_Product + 9))) + ";" + Str$(CY(P(Start_Product + 9))) + ";" + Str$(CZ(P(Start_Product + 9))) + ";" + Str$(CU(P(Start_Product + 9)))
Fend
Function Grip_Open_Out As Boolean
	On GP_OPEN
	Off GP_CLOSE
	Wait Sw(DI_GP_Open) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;GRIP_OP" '回傳開爪失敗		
		Grip_Open_Out = False
		Exit Function
	EndIf
	Grip_Open_Out = True
	Wait 0.2
Fend
Function Grip_Close_Out As Boolean
	Off GP_OPEN
	On GP_CLOSE
	Wait Sw(DI_GP_Close) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;GRIP_OP" '回傳閉爪失敗		
		Grip_Close_Out = False
		Exit Function
	EndIf
	Grip_Close_Out = True
	Wait 0.2
Fend
Function MovetoFirstCheck
	'Robot 3
	TC Off
	OnErr GoTo handle
	Tool 0
    P(500) = PUT_Safepoint
	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		If CY(Here) > 590 Then
			Move Here :Z(500)
			Move NG2 :Z(500)
			Move pick :Z(550)
		EndIf
		If CX(Here) < -190 And CY(Here) > 550 Then
			Move pick :Z(550)
		EndIf
		Move Here :Z(550)
		Go LJM(P(500) :Z(550))
		Print "ERR,Postion"
	EndIf
	If DI_Senosr_Pick = On And Grip_Pass = False Then
		Move Here :Z(550)
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	If (Grip_Open_Out = False) Then
		Exit Function
	EndIf
	P(500) = palletup
	If CX(Here) - CX(P(500)) > 0 Then
		Tool 0
		Move Here :Z(550)
		Go LJM(PUT_Safepoint)
		Print "ERR,Postion"
	EndIf
	P(500) = PUT_Safepoint
	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		Move Here :Z(550)
		Go LJM(P(500))
		Print "ERR,Postion"
	EndIf
	Go LJM(PUT_Safepoint) CP
	Go LJM(Barcode1)
	Return_code$ = "RunFinish;CONE"
	Print Return_code$
	Exit Function
handle:
	TC Off
	Print "Error Check"
	Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", SysErr
		EndIf
		If ChkNet(209) > 0 Then
			Print #209, "ERR;", SysErr
		EndIf
	Reset
Fend
Function MovetoSecondCheck
	'Robot 3
	OnErr GoTo handle
	Tool 0
	P(500) = Barcode1
    If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		If CY(Here) > 590 Then
			Move Here :Z(500)
			Move NG2 :Z(500)
			Move pick :Z(550)
		EndIf
		If CX(Here) < -190 And CY(Here) > 550 Then
			Move pick :Z(550)
		EndIf
		Move Here :Z(550)
		Go LJM(P(500) :Z(550))
		Print "ERR,Postion"
	EndIf
	Move LJM(Barcode2)
	Return_code$ = "RunFinish;CTWO"
	Print Return_code$
	Exit Function
handle:
	Print "Error occer"
	Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", SysErr
		EndIf
		If ChkNet(209) > 0 Then
			Print #209, "ERR;", SysErr
		EndIf
	Reset
Fend
Function MovetoPick_Out '取料
	'Robot 3
	OnErr GoTo handle
	TC Off
	Tool 0
	IsBuzy = True
	P(500) = Barcode2
	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		If CY(Here) > 590 Then
			Move Here :Z(500)
			Move NG2 :Z(500)
			Move pick :Z(550)
		EndIf
		If CX(Here) < -190 And CY(Here) > 550 Then
			Move pick :Z(550)
		EndIf
		Move Here :Z(550)
		Go P(500) :Z(550)
		Print "ERR;Postion"
	EndIf
	
	If (Grip_Open_Out = False) Then
		Exit Function
	EndIf

	Go LJM(pick +Z(50)) CP
	Go LJM(pick +Z(20))
	SpeedS 40
	TC On
    Move LJM(pick +Z(Thick_Conveyor))
	
	TC Off
	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass = False Then
		Move Here :Z(550)
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	If (Grip_Close_Out = True) Then
		Print "取料完成"
		Return_code$ = "RunFinish;PICK"
	EndIf
	Call DefSpeed
	
	Move Here +Z(50)
	Print Return_code$
	Exit Function
handle:
	TC Off
	Print "Error occer"
	Print "ERR:", Err
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", Err
		EndIf

	Reset
Fend
Function MoveToSpecifyPUT_Out(ByRef Specify_num As Integer) '放料
	j = Specify_num
	If put_case_Bool = True Then
		Return_code$ = "RunFinish;SYPU;" + Str$(ex_product) + ";" + Str$(ex_j)
	EndIf
	
Fend
Function MoveToPut_Out '放料
	If put_case_Bool = True Then
		Return_code$ = "RunFinish;PUTP;" + Str$(ex_product) + ";" + Str$(ex_j)
	EndIf
	
Fend
Function put_case_Bool As Boolean
	OnErr GoTo handle
	Tool 0
	put_case_Bool = False
	IsBuzy = True
	P(500) = pick
	If Abs(CZ(Here) - CZ(P(500)) - 50) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		If CY(Here) > 590 Then
			Move Here :Z(550)
			Move pick :Z(550)
		EndIf
		If CX(Here) < -190 And CY(Here) > 550 Then
			Move pick :Z(550)
		EndIf
		Move Here :Z(550)
		Go LJM(P(500) :Z(550))
		Print "ERR;Postion"
	EndIf
		If DI_Senosr_Pick = On And Grip_Pass = False Then
		Move Here :Z(500)
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	Go LJM(PUT_Safepoint) CP
	Go LJM(palletup) CP
	Go LJM(Pallet(product, j) +Z(30))
	SpeedS 100
	TC On
	Move Pallet(product, j) +Z(2 + Thick_Platform)
	ex_product = product
	ex_j = j
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	If (Grip_Open_Out = True) Then
		Print "放料完成"
		put_case_Bool = True
	EndIf
	TC Off
	Move Here +Z(30) CP
	SpeedS SP_SDef
	Go LJM(palletup) CP
	Go LJM(PUT_Safepoint)
	Print Return_code$
	Exit Function
handle:
	Print "Error occer"
	Print "ERR:", Err
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", Err
		EndIf
	Reset
Fend
Function MoveToRemake 'NG
	OnErr GoTo handle
	Tool 0
	IsBuzy = True
	P(500) = pick
	If Abs(CZ(Here) - CZ(P(500)) - 50) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		If CY(Here) > 590 Then
			Move Here :Z(500)
			Move NG2 :Z(500)
			Move pick :Z(550)
		EndIf
		If CX(Here) < -190 And CY(Here) > 550 Then
			Move pick :Z(550)
		EndIf
		Move Here :Z(550)
		Go P(500) :Z(550)
		Print "ERR,Postion"
	EndIf
	
	If Sw(NG1_Sensor_Have) = On And Sw(NG2_Sensor_Have) = On Then
		Return_code$ = "RunFinish;NG_FULL"
		Exit Function
	EndIf
	If Sw(DI_Senosr_Pick) = Off Then
		Move Here :Z(500)
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	Move Here :Z(550) CP
	If Sw(NG1_Sensor_Have) = Off Then
		Go NG1 :Z(500) CP
		Go NG1 +Z(20)
		SpeedS 50
		TC On
		Move NG1
		TC On
		If (Grip_Open_Out = False) Then
			Go LJM(pick :Z(500))
			Go LJM(PUT_Safepoint)
			TC Off
			Exit Function
		EndIf
		Call DefSpeed
		Move NG1 +Z(20)
		Go LJM(NG1 :Z(500)) CP
		Go LJM(pick :Z(550))
		Go LJM(PUT_Safepoint)
		Return_code$ = "RunFinish;GONG;1"
	
	ElseIf Sw(NG2_Sensor_Have) = Off Then
		Go NG2 :Z(500) CP
		Go NG2 +Z(20)
		SpeedS 50
		TC On
		Move NG2
		TC Off
		If (Grip_Open_Out = False) Then
			Go LJM(pick :Z(500))
			Go LJM(PUT_Safepoint)
			TC Off
			Exit Function
		EndIf
		Call DefSpeed
		Move NG2 +Z(20)
		Go LJM(NG2 :Z(500)) CP
		Go LJM(pick :Z(550))
		Go LJM(PUT_Safepoint)
		Return_code$ = "RunFinish;GONG;2"
	EndIf
	TC Off
'	If Sw(NG1_Sensor_Have) = On And Sw(NG2_Sensor_Have) = On Then
'		Print #203, "RunFinish;FULL"
'	EndIf
	Exit Function
handle:
	Print "Error occer"
	Print "ERR:", Err
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(203) > 0 Then
			Print #203, "ERR;", Err
		EndIf

	Reset
Fend
Function GoHome_Out '復歸
	'Robot 3
	TC On
	OnErr GoTo handle
	Tool 0
	Speed 10
	SpeedS 40
	IsBuzy = True
	Print CZ(Here)
	If CZ(Here) < 500 Then
		Move Here +Z(50)
		Go Here :Z(550)
	ElseIf CZ(Here) < 550 Then
		Move Here :Z(550)
	EndIf
	If CY(Here) > 590 Then
		Move Here :Z(550)
		Move pick :Z(550)
	EndIf
	If CX(Here) < -190 And CY(Here) > 550 Then
		Move pick :Z(550)
	EndIf
	Home
	Return_code$ = "RunFinish;HOME"
	Call DefSpeed
	Print Return_code$
	TC Off
	Power High
	Exit Function
handle:
	TC Off
	Print "Error occer"
	Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(203) > 0 Then
			Print #203, "ERR:", SysErr
		EndIf
	Reset
Fend
Function tcpipcmd_Out
	String leftcmd$
	Boolean Pass_Tcpip
'	Pass_Tcpip = True
	Do
		 OpenNet #203 As Server
		 WaitNet #203, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #203 Connected"
		 	Do
            	If (PauseOn = True Or SafetyOn = True) Then
            		If ChkNet(203) > 0 Then
				 		Line Input #203, cmd_plu$
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks12$(0)
			 					ParseStr cmd_plu$, toks12$(), ";"
			 					Select toks12$(0)
						 		Case "Resume"
							 		Print #203, "Resume"
							 		Print "Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #203, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
            	Else
				 	If (ChkNet(203) > 0 And IsBuzy = False) Or Pass_Tcpip = True Then '連線埠有資料
				 		If Pass_Tcpip = False Then
				 			Line Input #203, cmd$
				 		EndIf
					 	If cmd$ <> "" Then
				 			Print "received '", cmd$, "' from PC"
				 			String toks1$(0)
				 			ParseStr cmd$, toks1$(), ";"
	                        Select toks1$(0)
				 				Case "PROD" '讀產品
				 					Integer product_tcpip
				 					Print #203, "cmd;received"
				 					product_tcpip = Val(toks1$(1))
	                                Call MovetoPallet_Teach_Out(ByRef product_tcpip)
				 				Case "PICK" '取料及相機
				 					Print #203, "cmd;received"
				 					If product_load = True Then
				 						Call MovetoPick_Out
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "PUTP" '放料
				 					Print #203, "cmd;received"
				 					If product_load = True Then
				 						Call MoveToPut_Out
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "SYPU" '指定放料
				 					Integer Specify_num
				 					Print #203, "cmd;received"
				 					Specify_num = Val(toks1$(1))
				 					If product_load = True And (0 < Specify_num <= Total_XY) Then
				 						'Call MoveToSpecifyPUT_Out(ByRef Specify_num)
				 						j = Specify_num
				 							Return_code$ = "RunFinish;SYPU;" + Str$(product) + ";" + Str$(j)
				 					Else
				 						If product_load = False Then
				 							Return_code$ = "ERR;Product No Load"
				 						Else
				 							Return_code$ = "ERR;Specify_num is too more"
				 						EndIf
				 					EndIf
				 				Case "HOME" '復歸
				 					Print #203, "cmd;received"
				 					Call GoHome_Out
				 				Case "CONE" '第一次檢查
				 					Print #203, "cmd;received"
				 					If product_load = True Then
				 						Call MovetoFirstCheck
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "CTWO" '第二次檢查
				 					Print #203, "cmd;received"
				 					If product_load = True Then
				 						Call MovetoSecondCheck
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "GONG" '廢料區
				 					Print #203, "cmd;received"
				 					If product_load = True Then
				 						Call MoveToRemake
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "Paus"
				 				   Print #203, "cmd,Pause," + Str$(TaskInfo(4, 3))
				 				   Halt 4
				 				Case "Resu"
				 				   Print #203, "cmd,Resu" + Str$(TaskInfo(4, 3))
				 				   Resume 4
				 				Case "TKIF"
				 					If (TaskInfo(4, 3)) < 1 Then Print #201, "Task;NotRun"
				 					If (TaskInfo(4, 3)) = 1 Then Print #201, "Task;Run"
									If (TaskInfo(4, 3)) = 2 Then Print #201, "Task;Wait"
									If (TaskInfo(4, 3)) = 3 Then Print #201, "Task;Pause"
									If (TaskInfo(4, 3)) = 4 Then Print #201, "Task;Stop"
									If (TaskInfo(4, 3)) = 5 Then Print #201, "Task;Error"
					 			Case "SetShift"
		                            Print #203, "cmd;received;", toks1$(0)
					 				Return_code$ = "SETSHIFT"
					 				Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)), Val(toks1$(7)), Val(toks1$(8)))
					 			Case "GetShift"
					 				Print #203, "cmd;received;", toks1$(0)
					 				Call Get_XYZU
					 			Case "PowerLow"
				 					Power Low
				 					Return_code$ = "RunFinish;POWERLOW"
				 				Case "PowerHigh"
				 					Power High
				 					Return_code$ = "RunFinish;POWERHIGH"
				 				Case "PowerType"
				 					If Power = 0 Then
										Return_code$ = "Low Power Mode"
									EndIf
									If Power = 1 Then
										Return_code$ = "High Power Mode"
									EndIf
				 				Default
				 					Print #203, "ERR;Cmd_NotFound"
				 			Send
					 	cmd$ = ""
	                    EndIf
				 	EndIf
				 	If TaskInfo(4, 3) < 1 Or TaskInfo(4, 3) > 3 Then
				 		IsBuzy = False
				 	EndIf
				 	If Return_code$ <> "" And IsBuzy = False Then
			 			Print #203, Return_code$
			 			Print Return_code$
			 			Return_code$ = ""
			 		EndIf
				 	If ChkNet(203) = -3 Then
				 		CloseNet #203
				 		Print "Disconnected"
				 		Exit Do
				 	EndIf
				 EndIf
			 Loop
		 EndIf
	Loop
Fend
'流程 
'開始讀參數 PROD0
'動作 PUTP PICK
'復歸 Home

