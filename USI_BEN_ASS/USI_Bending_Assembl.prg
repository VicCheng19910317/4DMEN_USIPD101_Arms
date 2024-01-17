Global Integer i, j, product, x, y, SP_SDef, SP_NDef, Total_XY, ex_product, ex_j, Start_Product
Global String cmd$, Return_code$, cmd_plu$, str_seq$
Global Boolean IsBuzy, Vacuum_Pass, Pneumatic_Pass, Ccd_Pass, product_load, test_mode
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform, Standard_ccd_X, Standard_ccd_Y, Standard_ccd_U
Function main
	'V1.5.10BA
	Reset
	OnErr GoTo handle
	Motor On
	Wait Motor = On
	Power High
	TCLim 30, 30, 50, 30, 30, 30
	'---
	LoadPoints "robot_bass.pts"
	Weight 0.8 '治具+工件重量
	Call DefSpeed
	SetNet #202, "192.168.0.22", 2000, CRLF, NONE, 0, TCP
'	SetNet #208, "192.168.0.22", 2001, CRLF, NONE, 0, TCP
	'---
'	Vacuum_Pass = True '真空PASS
'	Pneumatic_Pass = True '氣動缸PASS
'	Ccd_Pass = True
'	test_mode = True
	
	Integer re0
	re0 = 0
	Call AssemblPallet_Teach(ByRef re0)

	'---
	IsBuzy = False
'	Xqt Pause_RESET, NoPause
	Xqt 2, tcpipcmd_Ass, NoPause
	Exit Function
	handle:
	Print "Error main"
	Print "ERR:", SysErr
		Return_code$ = "ERR:" + Str$(SysErr)
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr
		EndIf
	Reset
Fend
Function DefSpeed
	SP_NDef = 40
	Speed SP_NDef
	Accel SP_NDef, SP_NDef
	SP_SDef = 700
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function Pause_RESET
	Do
        If (PauseOn = True Or SafetyOn = True) And ChkNet(202) <> -2 Then
     		Print "暫停", ChkNet(202), PauseOn, SafetyOn
			OpenNet #202 As Server
		 	WaitNet #202, 5
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do
			 		If ChkNet(202) > 0 Then '連線埠有資料 Or Pass_Tcpip = True	
				 		Line Input #202, cmd_plu$
				 		Print " #202 暫停-等待指令中,", ChkNet(202)
				 		Wait 1
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 			Select Left$(Trim$(cmd_plu$), 4)
						 		Case "RSET"
							 		Print #202, SysErr
							 		Print "ERROR CORD:", SysErr
								 	Print "Disconnected"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #202, "ERR,Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
		 		Loop
		 	EndIf
		EndIf
	Loop
Fend
Function AssemblPallet_Teach(ByRef product_local As Integer)
	'Robot 2
	IsBuzy = True
	product_load = False
	j = 0
	Thick_Conveyor = 0 '輸送帶到工件的厚度
	Thick_Platform = 0 '平台到工件的厚度
	'PalletClr product_local
	Select product_local
		Case 0
			'脆盤靠近傳輸帶一側為X
			x = 7
			y = 5
			
			Start_Product = 100 '產品起點(7點)
			Standard_ccd_X = 32.722 'X標準值
			Standard_ccd_Y = -21.29 'Y標準值
			Standard_ccd_U = -90.222 'U標準值
			
			'str_seq$ = "T_P0"
			str_seq$ = "BENDING_P0" '相機檢測序列

			product_load = True
		Case 1
			'脆盤靠近傳輸帶一側為X
			x = 7
			y = 5
			
			Start_Product = 100 '產品起點(7點)
			Standard_ccd_X = 48.5 'X標準值
			Standard_ccd_Y = 9.7 'Y標準值
			Standard_ccd_U = -90.8 'U標準值
			str_seq$ = "BenAssTest" '相機檢測序列

			
	Send

	If product_load = True Then
	
		product = product_local
		j = 1
		'-----
		If CU(P(Start_Product)) + CU(P(Start_Product + 5)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 5)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 5)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5)
		EndIf
		If CU(P(Start_Product + 4)) + CU(P(Start_Product + 6)) > 180 Then
			put = P(Start_Product + 4) + P(Start_Product + 6) :U((CU(P(Start_Product)) + CU(P(Start_Product + 6))) - 360)
		Else
			put = P(Start_Product + 4) + P(Start_Product + 6)
		EndIf
		'----
'		PL1 = P(Start_Product) + P(Start_Product + 5)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 5)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 5)
		ccd = P(Start_Product + 3)
'		put = P(Start_Product + 4) + P(Start_Product + 6)
		Pallet 0, PL1, PL2, PL3, x, y
		Return_code$ = "RunFinish;PROD;" + Str$(product)
		Total_XY = x * y
		Print "料格數:", Total_XY
		SavePoints "robot_bass.pts"
	Else
		Return_code$ = "ERR;PROD"
		Total_XY = 0
	EndIf
	Print Return_code$
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real, Offset_X2 As Real, Offset_Y2 As Real, Offset_Z2 As Real, Offset_U2 As Real)
	If Start_Product >= 0 Then
		P(Start_Product + 5) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U)
		P(Start_Product + 6) = XY(Offset_X2, Offset_Y2, Offset_Z2, Offset_U2)
'		SavePoints "robot_bass.pts"
		If CU(P(Start_Product)) + CU(P(Start_Product + 5)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 5)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 5)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5)
		EndIf
		If CU(P(Start_Product + 4)) + CU(P(Start_Product + 6)) > 180 Then
			put = P(Start_Product + 4) + P(Start_Product + 6) :U((CU(P(Start_Product)) + CU(P(Start_Product + 6))) - 360)
		Else
			put = P(Start_Product + 4) + P(Start_Product + 6)
		EndIf
'		PL1 = P(Start_Product) + P(Start_Product + 5)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 5)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 5)
'		put = P(Start_Product + 4) + P(Start_Product + 6)
		SavePoints "robot_bass.pts"
		Pallet 0, PL1, PL2, PL3, x, y
		Return_code$ = "SETSHIFT;" + Str$(Offset_X) + ";" + Str$(Offset_Y) + ";" + Str$(Offset_Z) + ";" + Str$(Offset_U) + ";" + Str$(Offset_X2) + ";" + Str$(Offset_Y2) + ";" + Str$(Offset_Z2) + ";" + Str$(Offset_U2)
	EndIf
Fend
Function Get_XYZU
	Return_code$ = "GETSHIFT;" + Str$(CX(P(Start_Product + 5))) + ";" + Str$(CY(P(Start_Product + 5))) + ";" + Str$(CZ(P(Start_Product + 5))) + ";" + Str$(CU(P(Start_Product + 5))) + ";" + Str$(CX(P(Start_Product + 6))) + ";" + Str$(CY(P(Start_Product + 6))) + ";" + Str$(CZ(P(Start_Product + 6))) + ";" + Str$(CU(P(Start_Product + 6)))
Fend
Function Pneumatic_Back_Ass As Boolean
	Off Pneumatic_OP
    On Pneumatic_CL
    Wait Sw(DI_Pneumatic_CL) = On, 2
	If TW = True And Pneumatic_Pass = False Then
		Return_code$ = "ERR;Pneumatic_CL" '回傳氣缸收回失敗		
		Pneumatic_Back_Ass = False
		Exit Function
	EndIf
	Pneumatic_Back_Ass = True
	Wait 0.2
Fend
Function Pneumatic_Out_Ass As Boolean
	On Pneumatic_OP
    Off Pneumatic_CL
    Wait Sw(DI_Pneumatic_OP) = On, 2
	If TW = True And Pneumatic_Pass = False Then
		Return_code$ = "ERR;Pneumatic_CL" '回傳氣缸收回失敗		
		Pneumatic_Out_Ass = False
		Exit Function
	EndIf
	Pneumatic_Out_Ass = True
	Wait 0.2
Fend
Function MovetoPick_Ass '取料及相機
	If Pick_Item = True Then
		Return_code$ = "RunFinish;PICK;" + Str$(ex_product) + ";" + Str$(ex_j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(ccdU)
	EndIf
Fend
Function MoveToSpecifyPick_Ass(ByRef Specify_num As Integer)
	j = Specify_num
	If Pick_Item = True Then
		Return_code$ = "RunFinish;SYPK;" + Str$(ex_product) + ";" + Str$(ex_j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(ccdU)
	EndIf
Fend
Function Pick_Item As Boolean
	OnErr GoTo handle
	TC Off
	Tool 0
	IsBuzy = True
	P(500) = palletup
	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		Move Here :Z(550)
		Go LJM(P(500))
		Print "ERR,Postion"
	EndIf
    Call DefSpeed
	If (Pneumatic_Back_Ass = False) Then
		Exit Function
	EndIf
'	Move Here :Z(550)
'	Go LJM(palletup)
	ex_product = product
	ex_j = j
	Go LJM(Pallet(product, j) +Z(30 + Thick_Platform))
	SpeedS 300
	TC On
	Move LJM(Pallet(product, j) +Z(Thick_Platform)) '3
	TC Off
	Call DefSpeed
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Off Vacuum_CL
	On Vacuum_OP '吸氣
	Wait 0.5
	Wait Sw(DI_Vacuum) = On, 2
	If TW = True And Vacuum_Pass = False Then
		Off Vacuum_OP
		Off Vacuum_CL
		Move Here +Z(30)
		Go LJM(palletup)
		Return_code$ = "ERR;Vacuum" '回傳真空失敗
		Exit Function
	EndIf
	Move Here +Z(30)
	Go LJM(palletup)
	'拍照
	Go LJM(ccd) '到拍照位置
	Wait 0.5
	Boolean found
	Double fff
 	VRun str_seq$  'BenAssTest '執行相機拍照 	    
'    VGet str_seq$.Geom02.RobotToolXYU, found, ccdX, ccdY, ccdU
	VGet str_seq$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
'	VGet str_seq$.LineFind01.RobotU, ccdU
'   VGet str_seq$.Geom01.Found, found
'    VGet str_seq$.Geom01.RobotToolXYU, found, fff, ccdY, ccdU
'    VGet BenAssTest.Geom02.RobotToolXYU, found, ccdX, ccsdY, ccdU
'    VGet BenAssTest.Geom01.RobotToolXYU, found, fff, ccdY, ccdU
	If found = True Then
	VGet str_seq$.LineFind01.RobotU, ccdU
	ccdX = ccdX + 10.666
	ccdY = ccdY + 5.034
	ccdU = ccdU - 180.585
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
	EndIf
	If (found = True And Abs(Abs(ccdX) - Abs(Standard_ccd_X)) < 5 And Abs(Abs(ccdY) - Abs(Standard_ccd_Y)) < 5 And Abs(Abs(ccdU) - Abs(Standard_ccd_U)) < 10) Or Ccd_Pass = True Then  '有找到物件And ccdX <> 0 And ccdY <> 0 And ccdU <> 0
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
        TLSet 2, XY(ccdX, ccdY, 00, ccdU + 0) '0.3)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	Else
		Print "The Geom sX is: ", Abs(Abs(ccdX) - Abs(Standard_ccd_X)), "sY is:", Abs(Abs(ccdY) - Abs(Standard_ccd_Y)), "U is:", Abs(Abs(ccdU) - Abs(Standard_ccd_U))
		Return_code$ = "ERR;Geom was not found!" '回傳拍照失敗 	
		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
		Move Here :Z(500) CP
		Go LJM(palletup) CP
		Move LJM(Pallet(ex_product, ex_j) +Z(30 + Thick_Platform)) CP '放回
		Move LJM(Pallet(ex_product, ex_j) +Z(15 + Thick_Platform)) CP
		Off Vacuum_OP
		Off Vacuum_CL
		Move Here +Z(30) CP
		Go LJM(palletup)
		Print Return_code$
	 	Exit Function
	EndIf
	Go LJM(Put_palletup)
	Return_code$ = "RunFinish;PICK;" + Str$(ex_product) + ";" + Str$(ex_j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(ccdU)
	Print Return_code$
	Exit Function
	handle:
		TC Off
		Print "Error Pick"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
	Exit Function
	handle2:
		TC Off
		Move Here +Z(30)
		Print "Error Pick"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function MoveToPut_Ass '放料
	'Robot 2
	OnErr GoTo handle
	IsBuzy = True
	TC Off
	Tool 0
	P(500) = Put_palletup
	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
		Tool 0
		Move Here :Z(550)
		Go LJM(P(500))
		Print "ERR,Postion"
	EndIf
	Call DefSpeed
'	Move Here :Z(550)
	Tool 2
'    Double shX, shY, shU, shV, shW
'     shX = 7 '256.989
'     shY = -12.093 '  -9.1 - 0.459 + 0.1 335.944
'     shU = 0.923 ' - 1.4 ' + 0.86 'Azngle 
'     shV = 0.99
'     shW = 1.013
'     
	Go LJM(put +Z(30 + Thick_Conveyor)) CP
	Go LJM(put +Z(17 + Thick_Conveyor))
	Move LJM(put +Z(15 + Thick_Conveyor))
	SpeedS 20
	AccelS 20, 20
	TC On
	OnErr GoTo handle2
	Move LJM(put) +Y(0.1) -Z(1) ' +Z(+2 - 0.3 + Thick_Conveyor)) '-3.5
'	TC Off
'	Call DefSpeed
'	Tool 0
	OnErr GoTo handle
'    If (Pneumatic_Out_Ass = False) Then
'    	Move Here :Z(550)
'		Exit Function
'	EndIf
'	Wait 0.5
'	If (Pneumatic_Back_Ass = False) Then
'		Move Here :Z(550)
'		Exit Function
'	EndIf
	Wait 0.1
	Off Vacuum_OP
	On Vacuum_CL
	Wait Sw(DI_Vacuum) = Off, 2

	If TW = True And Vacuum_Pass = False Then
		Off Vacuum_CL
		Off Vacuum_OP
		Move Here :Z(550)
		Return_code$ = "ERR;Vacuum_OP" '回傳真空失敗		
		Exit Function
    EndIf
    Move Here +Z(10)
'    If (Pneumatic_Out_Ass = False) Then   0718
'    	Move Here :Z(550)
'		Exit Function
'	EndIf
	Move Here -Z(6)
'	If (Pneumatic_Back_Ass = False) Then   0718
'		Move Here :Z(550)
'		Exit Function
'	EndIf
	TC Off
	Call DefSpeed
	Tool 0
	Move Here +Z(30) CP
	Off Vacuum_CL
	Go Here +Z(100) CP
	Go LJM(palletup)
	Print "放料完成"
	Return_code$ = "RunFinish;PUTP"
	Print Return_code$
	Exit Function
	handle:
		Print "Error Put"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Exit Function
	handle2:
		TC Off
		Move Here :Z(450)
		Print "Error ASS"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr) + ";ASS"
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr, ";ASS"
		EndIf
	Reset
	Power High
Fend
Function GoHome_Ass '復歸
	'Robot 2
	OnErr GoTo handle
	Speed 10
	SpeedS 40
	IsBuzy = True
	Print CZ(Here)
	TC On
	If CZ(Here) < 500 Then
		Move Here +Z(50)
		Go Here :Z(550)
	ElseIf CZ(Here) < 550 Then
		Move Here :Z(550)
	EndIf
	Tool 0
	Go LJM(palletup)
	Home
	Return_code$ = "RunFinish;HOME"
	Call DefSpeed
	TC Off
	Power High
	Print Return_code$
		Exit Function
	handle:
		Print "Error Put"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(202) > 0 Then
			Print #202, "ERR;", SysErr
		EndIf
	Reset
	Power High
Fend
Function tcpipcmd_Ass
	String leftcmd$, midcmd$
	Boolean Pass_Tcpip
'	Pass_Tcpip = True
	Do
		 OpenNet #202 As Server
		 WaitNet #202, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #202 Connected"
		 	Do
            	If (PauseOn = True Or SafetyOn = True) Then
            		If ChkNet(202) > 0 Then
				 		Line Input #202, cmd_plu$
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks12$(0)
			 					ParseStr cmd_plu$, toks12$(), ";"
			 					Select toks12$(0)
						 		Case "Resume"
							 		Print #202, "Resume"
							 		Print "Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #202, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
            	Else
				 	If (ChkNet(202) > 0 And IsBuzy = False) Or Pass_Tcpip = True Then '連線埠有資料
				 		If Pass_Tcpip = False Then
				 			Line Input #202, cmd$
				 		EndIf
					 	If cmd$ <> "" Then
				 			Print "received '", cmd$, "' from PC"
				 			String toks1$(0)
				 			ParseStr cmd$, toks1$(), ";"
	                        Select toks1$(0)
				 				Case "PROD" '讀產品
				 					Integer product_tcpip
				 					Print #202, "cmd;received"
				 					product_tcpip = Val(toks1$(1))
	                                Call AssemblPallet_Teach(ByRef product_tcpip)
				 				Case "PICK" '取料及相機
				 					Print #202, "cmd;received"
				 					If product_load = True Then
				 						Xqt 4, MovetoPick_Ass
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
								Case "SYPK" '指定取料
				 					Integer Specify_num
				 					Print #202, "cmd;received"
				 					Specify_num = Val(toks1$(1))
				 					If product_load = True And (0 < Specify_num <= Total_XY) Then
				 						'Call MoveToSpecifyPick_Ass(ByRef Specify_num)
				 						j = Specify_num
				 							Return_code$ = "RunFinish;SYPK"
				 					Else
				 						If product_load = False Then
				 							Return_code$ = "ERR;Product No Load"
				 						Else
				 							Return_code$ = "ERR;Specify_num is too more"
				 						EndIf
				 					EndIf
				 				Case "PUTP" '放料
				 					Print #202, "cmd;received"
				 					If product_load = True Then
				 						Xqt 4, MoveToPut_Ass
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "HOME" '復歸
				 					Print #202, "cmd;received"
				 					Xqt 4, GoHome_Ass
				 				Case "Paus"
				 				   Print #202, "cmd,Pause," + Str$(TaskInfo(4, 3))
				 				   Halt 4
				 				Case "Resu"
				 				   Print #202, "cmd,Resu" + Str$(TaskInfo(4, 3))
				 				   Resume 4
				 				Case "TKIF"
				 					If (TaskInfo(4, 3)) < 1 Then Print #201, "Task;NotRun"
				 					If (TaskInfo(4, 3)) = 1 Then Print #201, "Task;Run"
									If (TaskInfo(4, 3)) = 2 Then Print #201, "Task;Wait"
									If (TaskInfo(4, 3)) = 3 Then Print #201, "Task;Pause"
									If (TaskInfo(4, 3)) = 4 Then Print #201, "Task;Stop"
									If (TaskInfo(4, 3)) = 5 Then Print #201, "Task;Error"
					 			Case "SetShift"
		                            Print #202, "cmd;received;", toks1$(0)
					 				Return_code$ = "SETSHIFT"
					 				Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)), Val(toks1$(7)), Val(toks1$(8)))
					 			Case "GetShift"
					 				Print #202, "cmd;received;", toks1$(0)
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
				 					Print #202, "ERR;Cmd_NotFound"
				 			Send
					 	cmd$ = ""
	                    EndIf
				 	EndIf
				 	If TaskInfo(4, 3) < 1 Or TaskInfo(4, 3) > 3 Then
				 		IsBuzy = False
				 	EndIf
				 	If Return_code$ <> "" And IsBuzy = False Then
			 			Print #202, Return_code$
			 			Return_code$ = ""
			 		EndIf
		
				 	If ChkNet(202) = -3 Then
				 		CloseNet #202
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
Function RobotCCD_TEACH
		Boolean found
		Real Rbt2U
 	VRun BEND_ASSEM '執行相機拍照
 	VGet BEND_ASSEM.Geom01.RobotToolXYU, found, ccdX, ccdY, ccdU
 	VGet BEND_ASSEM.Point01.RobotToolXYU, found, ccdX, ccdY, Rbt2U
	If (found = True) Or Ccd_Pass = True Then  '有找到物件And ccdX <> 0 And ccdY <> 0 And ccdU <> 0
		Print "原始U", Str$(ccdU), ",點位U", Str$(Rbt2U)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
		TLSet 2, XY(ccdX, ccdY, 00, Rbt2U)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	Else

	EndIf
Fend
Function RobotCCD_TEACH2
	Boolean found
	VRun BenAssTest  'BEND_ASSEM '執行相機拍照 	
    VGet BenAssTest.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
    VGet BenAssTest.Geom02.RobotU, ccdU
	If (found = True) Or Ccd_Pass = True Then  '有找到物件And ccdX <> 0 And ccdY <> 0 And ccdU <> 0
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
		TLSet 2, XY(ccdX, ccdY, 00, ccdU)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	Else

	EndIf
Fend

