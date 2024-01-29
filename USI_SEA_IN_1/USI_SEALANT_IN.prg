Global Integer i, j, product, x, y, SP_SDef, SP_Def50, int_TotalXY, Int_Test, ex_product, ex_j, Start_Product
'Global Preserve Integer test01
Global String cmd$, Return_code$, cmd_plu$, cmd_err$, str_seq$
Global Boolean IsBuzy, Ccd_Pass, Grip_Pass, product_load, test_mode
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform, Standard_ccd_X, Standard_ccd_Y
Global Preserve Integer X_LOWER, Y_LOWER, U_LOWER
Function main
	'V1.5.5SI
	Reset
	OnErr GoTo handle
	Motor On
	Wait Motor = On
	Power High
	'----基本設定 
	LoadPoints "pickrobot.pts"
	Tool 0
	Weight 0.5 '治具+工件重量
 	Call DefSpeed
	SetNet #204, "192.168.0.24", 2000, CRLF, NONE, 0, TCP
'	SetNet #210, "192.168.0.24", 2001, CRLF, NONE, 0, TCP
	TCLim 50, 50, 50, 50, 30, 50
	product_load = False
	X_LOWER = 3
    Y_LOWER = 3
    U_LOWER = 1
	IsBuzy = False
	'---------測試模塊
	'Ccd_Pass = True '相機檢測PASS
	'Grip_Pass = True夾爪相關PASS
	'test_mode = False
	Integer IIXX
	IIXX = 0
	Call PRODUCT_IN(ByRef IIXX)
	Return_code$ = ""
'	Xqt Test_Move
	'---------
'	Xqt ERROR_RESET, NoEmgAbort '錯誤重置功能
'	Xqt Pause_RESET, NoPause '暫停開始功能
	Xqt 2, tcpipcmd_In, NoPause

Exit Function
handle:
	Print "Error "
	Print "ERR;", SysErr, ";Main_in"
	Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function DefSpeed
	SP_SDef = 1500
    SP_Def50 = 50
	Speed SP_Def50
	Accel SP_Def50, SP_Def50
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function Pause_RESET
	Do
        If ChkNet(210) <= 0 Then
     			OpenNet #210 As Server
     		EndIf
        If (PauseOn = True Or SafetyOn = True) Then
     		Print "暫停", ChkNet(210), PauseOn, SafetyOn
     		If ChkNet(210) <= 0 Then
     			OpenNet #210 As Server
     		EndIf
		 	WaitNet #210, 5
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do
			 		If ChkNet(210) > 0 Then '連線埠有資料 Or Pass_Tcpip = True	
				 		Line Input #210, cmd_plu$
				 		'Print " #210 暫停-等待指令中,", ChkNet(210)
				 		Wait 1
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 			Select Left$(Trim$(cmd_plu$), 4)
						 		Case "RSET"
							 		Print #210, "Pause:", SysErr
							 		Print "ERROR CORD:", SysErr
							 		CloseNet #210
								 	Print "Disconnected"
									Cont
									cmd_plu$ = ""
									
									Exit Do
						 		Default
				 					Print #210, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
		 		Loop
		 	EndIf
		EndIf
	Loop
Fend
Function ERROR_RESET
	Boolean Pass_Tcpip
	Pass_Tcpip = True
	Do
		If (ErrorOn = True Or EStopOn = True) Then
	     	Print "錯誤", ChkNet(210), ErrorOn, EStopOn
			OpenNet #210 As Server
		 	WaitNet #210, 5
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do
			 		If ChkNet(210) > 0 Or Pass_Tcpip = True Then '連線埠有資料					 		
				 		Line Input #210, cmd_err$
				 		Print " #210 錯誤處理"
				 		Wait 1
				 		If Len(cmd_err$) > 0 And Trim$(cmd_err$) <> "" Then
				 			Select Left$(Trim$(cmd_err$), 4)
						 		Case "RSET"
							 		Print #210, SysErr
							 		Print "ERROR CORD:", SysErr
							 		CloseNet #210
								 	Print "Disconnected"
								 	'EResume
								 	Call main
									Exit Do
						 		Default
				 					Print #210, "ERR;Cmd_NotFound"
			 				Send
					 	EndIf
			 		EndIf
		 		Loop
		 	EndIf
		EndIf
	Loop
Fend
Function PRODUCT_IN(ByRef product_local As Integer)
	'Robot 1
	product_load = False
	IsBuzy = True
	j = 0
	Thick_Conveyor = 0 '輸送帶到工件的高度
	Thick_Platform = 0 '平台到工件的高度
	Select product_local
		Case 0
			'脆盤靠近傳輸帶一側為X
			x = 4
			y = 3
			Start_Product = 100 '產品起點(9點)
			Standard_ccd_X = 15.1 'X標準值
			Standard_ccd_Y = 15.2 'Y標準值
			str_seq$ = "SEAL_CCDPUT2" '相機檢測序列
			

			product_load = True
		Case 1
		
			x = 4
			y = 3
			
			product_load = True
	Send
'	If test_mode = True Then
'		Thick_Conveyor = 30 '輸送帶到工件的高度
'		Thick_Platform = 30 '平台到工件的高度
'	EndIf
	If product_load = True Then
		j = 1
		product = product_local
		
		If CU(P(Start_Product)) + CU(P(Start_Product + 7)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 7)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 7) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 7) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 7)
			PL2 = P(Start_Product + 1) + P(Start_Product + 7)
			PL3 = P(Start_Product + 2) + P(Start_Product + 7)
		EndIf
		If CU(P(Start_Product + 5)) + CU(P(Start_Product + 8)) > 180 Then
			put = P(Start_Product + 5) + P(Start_Product + 8) :U((CU(P(Start_Product + 5)) + CU(P(Start_Product + 8))) - 360)
		Else
			put = P(Start_Product + 5) + P(Start_Product + 8)
		EndIf
		
		
'		PL1 = P(Start_Product) + P(Start_Product + 7)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 7)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 7)
		se_weight = P(Start_Product + 3)
		ccd = P(Start_Product + 4)
'		put = P(Start_Product + 5) + P(Start_Product + 8)
		se_weight_PICK = P(Start_Product + 6)
		Pallet product_local, PL1, PL2, PL3, x, y
		int_TotalXY = x * y
		Print "料格數:", int_TotalXY
		
		Return_code$ = "RunFinish;PROD;" + Str$(product)
	Else
		Return_code$ = "ERR;PROD"
	EndIf
	IsBuzy = False
	Print Return_code$
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real, Offset_X2 As Real, Offset_Y2 As Real, Offset_Z2 As Real, Offset_U2 As Real)
	If Start_Product >= 0 Then
		P(Start_Product + 7) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U)
		P(Start_Product + 8) = XY(Offset_X2, Offset_Y2, Offset_Z2, Offset_U2)
		'SavePoints "pickrobot.pts"
		
				
		If CU(P(Start_Product)) + CU(P(Start_Product + 7)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 7)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 7) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 7) :U((CU(P(Start_Product)) + CU(P(Start_Product + 7))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 7)
			PL2 = P(Start_Product + 1) + P(Start_Product + 7)
			PL3 = P(Start_Product + 2) + P(Start_Product + 7)
		EndIf
		If CU(P(Start_Product + 5)) + CU(P(Start_Product + 8)) > 180 Then
			put = P(Start_Product + 5) + P(Start_Product + 8) :U((CU(P(Start_Product + 5)) + CU(P(Start_Product + 8))) - 360)
		Else
			put = P(Start_Product + 5) + P(Start_Product + 8)
		EndIf
		SavePoints "pickrobot.pts"
'		PL1 = P(Start_Product) + P(Start_Product + 7)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 7)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 7)
'		put = P(Start_Product + 5) + P(Start_Product + 8)
'		
		Return_code$ = "SETSHIFT;" + Str$(Offset_X) + ";" + Str$(Offset_Y) + ";" + Str$(Offset_Z) + ";" + Str$(Offset_U) + ";" + Str$(Offset_X2) + ";" + Str$(Offset_Y2) + ";" + Str$(Offset_Z2) + ";" + Str$(Offset_U2)
	EndIf
Fend
Function Get_XYZU
	Return_code$ = "GETSHIFT;" + Str$(CX(P(Start_Product + 7))) + ";" + Str$(CY(P(Start_Product + 7))) + ";" + Str$(CZ(P(Start_Product + 7))) + ";" + Str$(CU(P(Start_Product + 7))) + ";" + Str$(CX(P(Start_Product + 8))) + ";" + Str$(CY(P(Start_Product + 8))) + ";" + Str$(CZ(P(Start_Product + 8))) + ";" + Str$(CU(P(Start_Product + 8)))
Fend
Function Grip_Open_In As Boolean
	On GP_OPEN
	Off GP_CLOSE
	Wait Sw(DI_GP_Open) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,GRIP_OP" '回傳開爪失敗		
		Grip_Open_In = False
		Exit Function
	EndIf
	Wait 0.3
	Grip_Open_In = True
Fend
Function Grip_Close_In As Boolean
	Off GP_OPEN
	On GP_CLOSE
	Wait Sw(DI_GP_Close) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,GRIP_CL" '回傳閉爪失敗		
		Grip_Close_In = False
		Exit Function
	EndIf
	Wait 0.3
	Grip_Close_In = True
Fend
Function MovetoPickBack_In '放回料格
  	Tool 0
  	TC Off
  	OnErr GoTo handle
	Move Here :Z(550) CP
	Tool 2
	Move LJM(se_weight_PICK +Z(100)) CP
	Move LJM(se_weight_PICK +Z(20 + Thick_Conveyor)) CP
	TC On
	SpeedS 50
    Move LJM(se_weight_PICK +Z(2 + Thick_Conveyor))
	If (Grip_Close_In = False) Then
		Move Here +Z(100) CP
		Move LJM(palletup)
		Tool 0
		TC Off
		Exit Function
	EndIf
	TC Off
    Move Here +Z(20) CP
    SpeedS SP_SDef
	Move Here +Z(100) CP
	Go LJM(palletup) CP
	Move LJM(Pallet(ex_product, j) +Z(20 + Thick_Platform)) CP
	Move LJM(Pallet(ex_product, j) +Z(Thick_Platform + 5))
	Move Here +Z(100) CP
	Go LJM(palletup) CP
	Tool 0
	If (Grip_Open_In = True) Then
		Return_code$ = "RunFinish;PIBK;"
	EndIf

	Exit Function
    handle:
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function MovetoPick_In '取料及相機
	'Robot 1
	OnErr GoTo handle
	IsBuzy = True
	TC Off
	If (Grip_Open_In = False) Then
		Exit Function
	EndIf
	ex_product = product
	ex_j = j
	Tool 2
	If (Abs((CZ(Here) - CZ(palletup)) > 5 Or Abs(CX(Here) - CX(palletup)) > 5 Or Abs(CY(Here) - CY(palletup)) > 5)) Then
		'不在秤重區等待時 到高處再過來	
		Tool 0
		Move Here :Z(550)
	EndIf
	Tool 2
	Go LJM(palletup) CP
	Go LJM(Pallet(ex_product, ex_j) +Z(20 + Thick_Platform)) CP ' +X(20)從當前位置到用紅外線SENSRO檢測塗交
	Move LJM(Pallet(ex_product, ex_j) +Z(10 + Thick_Platform))
'	Wait Sw(DI_Senosr_Check) = On, 2
'	If TW = True And Grip_Pass = False Then
'		Return_code$ = "ERR,SENSOR" '回傳紅外線偵測失敗		
'		Exit Function
'	EndIf
'	Go LJM(Pallet(product, j) +Z(20 + Thick_Platform)) CP

	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass <> True Then
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Move Here +Z(50) CP
		Move LJM(palletup)
		Tool 0
		Exit Function
	EndIf
'	Move LJM(Pallet(ex_product, ex_j) +Z(10 + Thick_Platform))
	SpeedS 50
	TC On
	Move LJM((Pallet(ex_product, ex_j)) +Z(Thick_Platform))
		'當夾爪上方SENSOR檢測有料時才會夾取
	If (Grip_Close_In = False) Then
		Move Here +Z(50 + Thick_Platform) CP
		Move LJM(palletup)
		Tool 0
		TC Off
		Exit Function
	EndIf
	Move Here +Z(20) CP
	TC Off
	SpeedS SP_SDef
'	Move Here +Z(100) CP
	Go LJM(palletup) CP
	Wait Sw(DI_Senosr_Pick) = On, 1
	If TW = True And Grip_Pass <> True Then
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Tool 0
		Exit Function
	EndIf
	Go LJM(se_weight) +Z(30) CP
	SpeedS 50
	Move LJM(se_weight +Z(6 + Thick_Conveyor))
	TC On
	Move LJM(se_weight +Z(3 + Thick_Conveyor))
	If (Grip_Open_In = False) Then
		Move Here +Z(20) CP
		Tool 0
		Go Here :Z(550)
		Exit Function
	EndIf
	TC Off
'	Move Here +Z(20)
	SpeedS SP_SDef
	Tool 0
	Return_code$ = "RunFinish;PICK;"
'    Print Return_code$
    Exit Function
    handle:
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function MoveToPut_In '放料
	'Robot 1
	Tool 2
	TC Off
	OnErr GoTo handle
	IsBuzy = True
	If (Abs((CZ(Here) - CZ(se_weight)) > 40 Or Abs(CX(Here) - CX(se_weight)) > 5 Or Abs(CY(Here) - CY(se_weight)) > 5)) Then
		'不在秤重區等待時 到高處再過來	
		Tool 0
		TC On
		Move Here :Z(550)
		Tool 2
		Move LJM(se_weight +Z(50))
		TC Off
		Print "ERR;Postion"
	EndIf
	If Sw(DI_Senosr_Have) = True Then
		Return_code$ = "ERR;Have_Sensor_on;"
		Exit Function
	EndIf
	Move LJM(se_weight) +Z(Thick_Conveyor)
	If (Grip_Close_In = False) Then
		Move Here +Z(30)
		Tool 0
		Move Here :Z(550)
		Exit Function
	EndIf
	Move Here +Z(50)
	Wait Sw(DI_Senosr_Pick) = On, 1
	If TW = True And Grip_Pass <> True Then
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Move Here +Z(50) CP
		Move LJM(palletup)
		Tool 0
		Exit Function
	EndIf
	Go LJM(ccd)
	Wait 0.5
 	Boolean found

' 	VRun SEAL_CCDPUT2 '執行相機拍照
 	VRun str_seq$ '執行相機拍照
 	VGet str_seq$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
	If (found = True And Abs(Abs(Standard_ccd_X) - Abs(ccdX)) < X_LOWER And Abs(Abs(Standard_ccd_Y) - Abs(ccdY)) < Y_LOWER) Then  '有找到物件
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
		TLSet 1, XY(ccdX, ccdY, 00, ccdU)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	Else
		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
		Return_code$ = "ERR;CCDERROR" '回傳拍照失敗 	
		Move Here +Z(100) CP
		Go LJM(palletup) CP
		Move LJM(Pallet(ex_product, ex_j) +Z(20 + Thick_Platform)) CP
		Move LJM(Pallet(ex_product, ex_j) +Z(5 + Thick_Platform))
		If (Grip_Open_In = False) Then
			
		EndIf
		Move Here +Z(100) CP
		Go LJM(palletup)
		Print Return_code$
	 	Exit Function
	EndIf

	Tool 1
	Go LJM(put :Z(420)) CP
	SpeedS 50
	Move LJM(put +Z(10 + Thick_Conveyor))
	TC On
	Move LJM(put +Z(0 + Thick_Conveyor)) '移動到放料位置
	If (Grip_Open_In = False) Then
		Move Here :Z(450)
		TC Off
		Exit Function
	EndIf
	SpeedS SP_SDef
	Move Here +Z(50)
	TC Off
'	Move Here :Z(550)
	Tool 0
	Return_code$ = "RunFinish;PUTP;" + Str$(ex_product) + ";" + Str$(ex_j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(ccdU)
'	Print Return_code$
	Exit Function
	handle:
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function GoHome_In '復歸
	'Robot 1
	TC On
	OnErr GoTo handle
	Speed 10
	SpeedS 40
	IsBuzy = True
	Print "當前高度:", CZ(Here)
	If CZ(Here) < 500 Then
		Move Here +Z(50)
		Go Here :Z(550)
	ElseIf CZ(Here) < 550 Then
		Move Here :Z(550)
	EndIf
	Home
	Return_code$ = "RunFinish;HOME"
	SpeedS SP_SDef
	Speed SP_Def50
	Print Return_code$
	TC Off
	Power High
	Exit Function
	handle:
		TC Off
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
		Reset
		Power High
		Call DefSpeed
Fend
Function GoToStandby
	Tool 2
	TC Off
	OnErr GoTo handle
	If (Abs((CZ(Here) - CZ(palletup)) < 3 And Abs(CX(Here) - CX(palletup)) < 3 And Abs(CY(Here) - CY(palletup)) < 3)) Then
		Return_code$ = "RunFinish;GOSD"
        Exit Function
	EndIf
	Tool 1
    If (Abs((CZ(Here) - CZ(put) - 50) > 5 Or Abs(CX(Here) - CX(put)) > 5 Or Abs(CY(Here) - CY(put)) > 5)) Then
		'不在秤重區等待時 到高處再過來	
		Tool 0
		Move Here :Z(550)
	EndIf
	Tool 2
	Go LJM(palletup)
	Return_code$ = "RunFinish;GOSD"
	Exit Function
		handle:
		TC Off
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(204) > 0 Then
			Print 204, "ERR;", SysErr
		EndIf
		Reset
		Power High
		Call DefSpeed
Fend
Function GoToCcd
	Move Here :Z(550)
	Go LJM(ccd)
	Return_code$ = "RunFinish;GOCD"
Fend
Function tcpipcmd_In
	Boolean Pass_Tcpip
	Pass_Tcpip = False
	OnErr GoTo handle
	If False Then
	handle:
		Print "Error occer"
		Print "ERR:", SysErr
		If ChkNet(210) > 0 Then
			Print #210, "ERR;", SysErr
		EndIf
		Reset
		Power High
		Call DefSpeed
		Reset
	EndIf
	Do
		 If ChkNet(204) <> -2 Then
		 	If ChkNet(204) = -3 Then
				OpenNet #204 As Server
			EndIf
			'OpenNet #204 As Server
			WaitNet #204, 60
			If TW = True Then
			 	Print "Time Out"
			Else
			 	Print " #204 Connected"
			 	Do
			 		If (PauseOn = True Or SafetyOn = True) Then
	            		If ChkNet(204) > 0 Then
					 		Line Input #204, cmd_plu$
					 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
					 				String toks12$(0)
				 					ParseStr cmd_plu$, toks12$(), ";"
				 					Select toks12$(0)
							 		Case "Resume"
							 			
								 		Print #204, "Resume"
								 		Print "Continue"
										Cont
										cmd_plu$ = ""
										Exit Do
							 		Default
					 					Print #204, "ERR;Cmd_NotFound"
					 					cmd_plu$ = ""
					 			Send
						 	EndIf
				 		EndIf
				 	Else
					 	If (ChkNet(204) > 0 And IsBuzy = False) Then ' And IsBuzy = False) Then '連線埠有資料
					 		If Pass_Tcpip = False Then
					 			Line Input #204, cmd$
					 		EndIf
						 	If cmd$ <> "" Then
					 			Print "received '", cmd$, "' from PC"
					 			String toks1$(0)
				 				ParseStr cmd$, toks1$(), ";"
	                        	Select toks1$(0)
					 			'Select Left$(cmd$, 4) '讀1-4
					 				Case "PROD" '讀產品
					 					Integer product_tcpip
					 					'Print #204, "cmd;received;", toks1$(0)
					 					product_tcpip = Val(toks1$(1))
		                                Call PRODUCT_IN(ByRef product_tcpip)
					 				Case "PICK" '取料及相機
					 					'Print #204, "cmd;received;", toks1$(0)
					 					If product_load = True Then
					 						'Call MovetoPick_In
					 						Xqt 4, MovetoPick_In
					 					Else
					 						Return_code$ = "ERR;Product No Load"
					 					EndIf
					 				Case "PIBK" '放回料盤
	                                    'Print #204, "cmd;received;", toks1$(0)
					 					If product_load = True Then
					 						'Call MovetoPickBack_In
					 						Xqt 4, MovetoPickBack_In
					 			
					 					Else
					 						Return_code$ = "ERR;Product No Load"
					 					EndIf
					 				Case "GOSD" 'STNDBY
					 					'Print #204, "cmd;received;", toks1$(0)
					 					If product_load = True Then
					 					'	Call GoToStandby
					 				        Xqt 4, GoToStandby
					 					Else
					 						Return_code$ = "ERR;Product No Load"
					 					EndIf
					 				Case "SYPU" '指定取料
					 					Integer Specify_num
					 					'Print #204, "cmd;received;", toks1$(0)
					 					Specify_num = Val(toks1$(1))
					 					If product_load = True And (0 < Specify_num <= int_TotalXY) Then
					 						j = Specify_num
					 						Return_code$ = "RunFinish;SYPU;" + Str$(product) + ";" + Str$(j)
					 					Else
					 						If product_load = False Then
					 							Return_code$ = "ERR;Product No Load"
					 						Else
					 							Return_code$ = "ERR;Specify_num is not true"
					 						EndIf
					 					EndIf
					 				Case "SYPK" '指定取料
					 					Integer Specify_num1
					 					'Print #204, "cmd;received;", toks1$(0)
					 					Specify_num1 = Val(toks1$(1))
					 					If product_load = True And (0 < Specify_num1 <= int_TotalXY) Then
					 						j = Specify_num1
					 						Return_code$ = "RunFinish;SYPK;" + Str$(product) + ";" + Str$(j)
					 					Else
					 						If product_load = False Then
					 							Return_code$ = "ERR;Product No Load"
					 						Else
					 							Return_code$ = "ERR;Specify_num is not true"
					 						EndIf
					 					EndIf
					 				Case "PUTP" '放料
					 					'Print #204, "cmd;received;", toks1$(0)
					 					If product_load = True Then
					 					'	Call MoveToPut_In
					 						Xqt 4, MoveToPut_In
					 					Else
					 						Return_code$ = "ERR;Product No Load"
					 					EndIf
					 				Case "GOSD"
					 					'Print #204, "cmd;received;", toks1$(0)
					 					'Call GoToStandby
					 					Xqt 4, GoToStandby
						 			Case "SetShift"
		                                'Print #204, "cmd;received;", toks1$(0)
					 					Return_code$ = "SETSHIFT"
					 					Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)), Val(toks1$(7)), Val(toks1$(8)))
					 				Case "GetShift"
					 					'Print #204, "cmd;received;", toks1$(0)
					 					Call Get_XYZU
					 				Case "GOCD"
					 					'Print #204, "cmd;received;", toks1$(0)
					 				'	Call GoToCcd
					 					Xqt 4, GoToCcd
					 				Case "HOME" '復歸
					 					'Print #204, "cmd;received;", toks1$(0)
					 					'Call GoHome_In
					 					Xqt 4, GoHome_In
					 				Case "CCD_OFFSET"
					 					'Print #206, "cmd;received;", toks1$(0)
					 					X_LOWER = Val(toks1$(1));
	                                    Y_LOWER = Val(toks1$(2));
	                                    U_LOWER = Val(toks1$(3));
	                                    Return_code$ = "RunFinish;CCD_OFFSET"
					 				Case "Paus"
					 				   Print #204, "cmd,Pause," + Str$(TaskInfo(4, 3))
					 				   Halt 4
					 				Case "Resu"
					 				   Print #204, "cmd,Resu" + Str$(TaskInfo(4, 3))
					 				   Resume 4
					 				Case "TKIF"
					 					If (TaskInfo(4, 3)) < 1 Then Print #204, "Task;NotRun"
					 					If (TaskInfo(4, 3)) = 1 Then Print #204, "Task;Run"
										If (TaskInfo(4, 3)) = 2 Then Print #204, "Task;Wait"
										If (TaskInfo(4, 3)) = 3 Then Print #204, "Task;Pause"
										If (TaskInfo(4, 3)) = 4 Then Print #204, "Task;Stop"
										If (TaskInfo(4, 3)) = 5 Then Print #204, "Task;Error"
					 				Default
					 					Print #204, "ERR;Cmd_NotFound"
					 			Send
					 			
					 			
						 	cmd$ = ""
		                    EndIf
					 	EndIf
'					 	If TaskInfo(4, 3) < 1 Or TaskInfo(4, 3) > 3 Then
'				 			IsBuzy = False
'					 	EndIf
				 		If Return_code$ <> "" Then
			 				Print #204, Return_code$
			 				Print Return_code$
			 				Return_code$ = ""
			 				IsBuzy = False
			 			EndIf
					 	If ChkNet(204) = -3 Then
					 		CloseNet #204
					 		Print "Disconnected"
					 		Exit Do
					 	EndIf
			 		
					EndIf
				 Loop
			EndIf
		EndIf
	Loop
Fend
Function CCD_TEACH
	Boolean found
	VRun SEAL_CcdToPut '執行相機拍照
 	VGet SEAL_CcdToPut.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
	If (found = True) Or Ccd_Pass = True Then  '有找到物件And CXX <> 0 And CYY <> 0 And CUU <> 0
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
		TLSet 5, XY(ccdX, ccdY, 00, ccdU)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU

	EndIf
Fend
' Function MoveToSpecifyPick_In(ByRef Specify_num As Integer) '指定取料
'	'Robot 1
'	OnErr GoTo handle
'	IsBuzy = True
'	If (Grip_Open_In = False) Then
'		Exit Function
'	EndIf
'	ex_product = product
'	ex_j = j
'	Tool 0
'	Move Here :Z(550) CP
'	Tool 2
'	Go LJM(palletup) CP
'	Go LJM(Pallet(ex_product, ex_j) +Z(20 + Thick_Platform)) CP ' +X(20)從當前位置到用紅外線SENSRO檢測塗交
'	Move LJM(Pallet(ex_product, ex_j) +Z(10 + Thick_Platform)) CP
''	Wait Sw(DI_Senosr_Check) = On, 2
''	If TW = True And Grip_Pass = False Then
''		Return_code$ = "ERR,SENSOR" '回傳紅外線偵測失敗		
''		Exit Function
''	EndIf
''	Go LJM(Pallet(product, j) +Z(20 + Thick_Platform)) CP
'
'	j = j + 1 '瑪垛+1
'	If j > y * x Then '瑪垛回到1
'		j = 1
'	EndIf
'	Wait Sw(DI_Senosr_Pick) = On, 2
'	If TW = True And Grip_Pass = False Then
'		Return_code$ = "ERR,SENSOR" '回傳偵測失敗
'		Move Here +Z(50) CP
'		Move LJM(palletup)
'		Tool 0
'		Exit Function
'	EndIf
'	SpeedS 50
'	Move LJM((Pallet(ex_product, ex_j)) +Z(Thick_Platform))
'		'當夾爪上方SENSOR檢測有料時才會夾取
'	If (Grip_Close_In = False) Then
'		Move Here +Z(50 + Thick_Platform) CP
'		Move LJM(palletup)
'		Tool 0
'		Exit Function
'	EndIf
'	Move Here +Z(20) CP
'	SpeedS SP_SDef
'	Move Here +Z(100) CP
'	Go LJM(palletup) CP
'	
'	Go LJM(se_weight) +Z(40) CP
'	SpeedS 50
'	Move LJM(se_weight +Z(Thick_Conveyor))
'	If (Grip_Open_In = False) Then
'		Move Here +Z(20) CP
'		Tool 0
'		Go Here :Z(550)
'		Exit Function
'	EndIf
''	Move Here +Z(20)
'	SpeedS SP_SDef
'	Tool 0
'	Return_code$ = "RunFinish,PICK,"
''    Print Return_code$
'    Exit Function
'    handle:
'		Print "Error occer"
'		Print "ERR:", SysErr
'		If ChkNet(210) > 0 Then
'			Print #210, "ERR:", SysErr
'		EndIf
'	Reset
'Fend
