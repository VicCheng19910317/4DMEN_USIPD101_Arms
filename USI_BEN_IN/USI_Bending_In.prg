Global Integer i, j, product, x, y, SP_SDef, SP_NDef, Total_XY, ex_product, ex_j, Start_Product
Global String cmd$, Return_code$, cmd_plu$, str_seq$
Global Boolean IsBuzy, Ccd_Pass, Grip_Pass, product_load, test_mode
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform, Standard_ccd_X, Standard_ccd_Y, Standard_ccd_U
Function main
	'V1.5BI
	Reset
	OnErr GoTo handle
	Motor On
	Wait Motor = On
	Power High
	TCLim 50, 50, 50, 50, 30, 50
	
	'-----基礎設定
	LoadPoints "pickrobot.pts"
	Weight 0.5 '治具+工件重量
	Tool 0
	Call DefSpeed
	SetNet #201, "192.168.0.21", 2000, CRLF, NONE, 0, TCP
'	SetNet #207, "192.168.0.21", 2001, CRLF, NONE, 0, TCP
'	OpenNet #207 As Server
	'-----
'	Ccd_Pass = True '相機檢測PASS
'	Grip_Pass = True '夾爪相關PASS
'	test_mode = True
	IsBuzy = False
	Integer IIXX
	IIXX = 0
	Call PRODUCT_IN(ByRef IIXX)
	'-----
	
'	Xqt Pause_RESET, NoPause
	Xqt 2, tcpipcmd_In, NoPause
	'Pause
Exit Function
	handle:
	Print "Error main"
	Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(201) > 0 Then
			Print #201, "ERR;", SysErr
		EndIf
'		If ChkNet(207) > 0 Then
'			Print #207, "ERR;", SysErr
'		EndIf
	Reset
Fend
Function DefSpeed
	SP_NDef = 40
	Speed SP_NDef
	Accel SP_NDef, SP_NDef
	SP_SDef = 1000
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function Pause_RESET
	Do
        If (PauseOn = True Or SafetyOn = True) Then 'And ChkNet(201) <> -2 
     		Print "暫停", ChkNet(201), PauseOn, SafetyOn
'     		If ChkNet(201) < 0 Then
'     			CloseNet #201
'     			
'				OpenNet #201 As Server
'		 		WaitNet #201, 30
'		 	EndIf
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do
			 		'Wait PauseOn = False And SafetyOn = False
'			 		If (PauseOn = False And SafetyOn = False) Then
'			 			Cont
'			 			Exit Do
'			 		EndIf
			 		If ChkNet(201) > 0 Then '連線埠有資料 Or Pass_Tcpip = True	
				 		Line Input #201, cmd_plu$
				 		'Print " #201 暫停-等待指令中,", ChkNet(201)
				 		Wait 1
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks1$(0)
			 					ParseStr cmd_plu$, toks1$(), ";"
			 					Select toks1$(0)
						 		Case "Resume"
						 			
							 		Print #201, "Resume"
							 		Print "ERROR Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #201, "ERR,Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
		 		Loop While (PauseOn = True Or SafetyOn = True)
		 	EndIf
		EndIf
	Loop
Fend
Function PRODUCT_IN(ByRef product_local As Integer)
	IsBuzy = True
	product_load = False
	Thick_Conveyor = 0 '輸送帶到工件的高度
	Thick_Platform = 0 '平台到工件的高度
	Select product_local
		Case 0
			'脆盤靠近傳輸帶一側為X
			x = 4
			y = 3
			str_seq$ = "CCD2_ASSEMBLE" '使用的相機檢測序列
			Standard_ccd_X = 24.1 '25 '相機X標準值 Point01 
			Standard_ccd_Y = 9.2 '9.7 '相機Y標準值 Point01
			Standard_ccd_U = 0.8 '0.2 '相機U標準值 Geom01
			Start_Product = 100 '產品起點(7點)
			product_load = True '成功讀取產品
		Case 1
			'脆盤靠近傳輸帶一側為X
			x = 4
			y = 3
			str_seq$ = "CCD2_ASSEMBLE" '使用的相機檢測序列
			Standard_ccd_X = 25 '相機X標準值
			Standard_ccd_Y = 9.7 '相機Y標準值SS
			Standard_ccd_U = 0.2 '相機U標準值
			Start_Product = 100 '產品起點(7點)
			product_load = True '成功讀取產品
	Send

	If product_load = True Then
		product = product_local
		j = 1
		If CU(P(Start_Product)) + CU(P(Start_Product + 5)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 5)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5) :U((CU(P(Start_Product)) + CU(P(Start_Product + 5))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 5)
			PL2 = P(Start_Product + 1) + P(Start_Product + 5)
			PL3 = P(Start_Product + 2) + P(Start_Product + 5)
		EndIf
		
		CCD2 = P(Start_Product + 3)
		
		If CU(P(Start_Product + 4)) + CU(P(Start_Product + 6)) > 180 Then
			put = P(Start_Product + 4) + P(Start_Product + 6) :U((CU(P(Start_Product)) + CU(P(Start_Product + 6))) - 360)
		Else
			put = P(Start_Product + 4) + P(Start_Product + 6)
		EndIf
		Pallet 0, PL1, PL2, PL3, x, y
		Return_code$ = "RunFinish;PROD;" + Str$(product)
		Total_XY = x * y
	Else
		Return_code$ = "ERR;PROD"
		Total_XY = 0
	EndIf
	IsBuzy = False
	Print Return_code$
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real, Offset_X2 As Real, Offset_Y2 As Real, Offset_Z2 As Real, Offset_U2 As Real)
	If Start_Product >= 0 Then
		P(Start_Product + 5) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U)
		P(Start_Product + 6) = XY(Offset_X2, Offset_Y2, Offset_Z2, Offset_U2)
		SavePoints "pickrobot.pts"
		
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
		Pallet 0, PL1, PL2, PL3, x, y
'		PL1 = P(Start_Product) + P(Start_Product + 5)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 5)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 5)
'		put = P(Start_Product + 4) + P(Start_Product + 6)
'		
		Return_code$ = "SETSHIFT;" + Str$(Offset_X) + ";" + Str$(Offset_Y) + ";" + Str$(Offset_Z) + ";" + Str$(Offset_U) + ";" + Str$(Offset_X2) + ";" + Str$(Offset_Y2) + ";" + Str$(Offset_Z2) + ";" + Str$(Offset_U2)
	EndIf
Fend
Function Get_XYZU
	Return_code$ = "GETSHIFT;" + Str$(CX(P(Start_Product + 5))) + ";" + Str$(CY(P(Start_Product + 5))) + ";" + Str$(CZ(P(Start_Product + 5))) + ";" + Str$(CU(P(Start_Product + 5))) + ";" + Str$(CX(P(Start_Product + 6))) + ";" + Str$(CY(P(Start_Product + 6))) + ";" + Str$(CZ(P(Start_Product + 6))) + ";" + Str$(CU(P(Start_Product + 6)))
Fend
Function Grip_Open_In As Boolean
	On GP_OPEN
	Off GP_CLOSE
	Wait Sw(DI_GP_Open) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;GRIP_OP" '回傳開爪失敗		
		Grip_Open_In = False
		Exit Function
	EndIf
	Grip_Open_In = True
	Wait 0.2
Fend
Function Grip_Close_In As Boolean
	Off GP_OPEN
	On GP_CLOSE
	Wait Sw(DI_GP_Close) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;GRIP_CL" '回傳閉爪失敗		
		Grip_Close_In = False
		Exit Function
	EndIf
	Grip_Close_In = True
	Wait 0.2
Fend
Function MovetoPickBack_In '放回料格
  	Tool 0
  	TC Off
  	If (Abs(CZ(Here) - CZ(PalletUp_Put) > 10 Or Abs(CX(Here) - CX(PalletUp_Put)) > 20 Or Abs(CY(Here) - CY(PalletUp_Put)) > 20)) Then
		Tool 0
		Move Here :Z(500)
		Go PalletUp_Put
		Print "ERR;Postion"
	EndIf
	If (Grip_Close_In = False) Then
		Speed 10
		SpeedS 100
		Move Here :Z(500) CP
		Move LJM(palletup)
		Call DefSpeed
		Tool 0
		Exit Function
	EndIf
    SpeedS SP_SDef
	Move Here :Z(550) CP
	Go LJM(palletup) CP
	Move LJM(Pallet(ex_product, j) +Z(20 + Thick_Platform)) CP
	SpeedS 50
	Move LJM(Pallet(ex_product, j) +Z(Thick_Platform + 10))
	TC On
	Move LJM(Pallet(ex_product, j) +Z(Thick_Platform + 5))
	If (Grip_Open_In = False) Then
				
	EndIf
	TC Off
	Move Here +Z(100) CP
	Call DefSpeed
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
		If ChkNet(201) > 0 Then
			Print #201, "ERR;", SysErr
		EndIf
		If ChkNet(210) > 0 Then
			Print #210, "ERR;", SysErr
		EndIf
	Reset
Fend
Function MovetoPick_In '取料及相機
	If Pick_case = True Then
		'Return_code$ = "RunFinish,PICK," + Str$(ex_product) + "," + Str$(ex_j)
	EndIf
Fend
Function MoveToSpecifyPick_In(ByRef Specify_num As Integer)
	j = Specify_num
    If Pick_case = True Then
        Return_code$ = "RunFinish;SYPK;" + Str$(ex_product) + ";" + Str$(ex_j)
    EndIf
Fend
Function Pick_case As Boolean
	OnErr GoTo handle
	MemOff (GaugeResult_OK); MemOff (GaugeResult_NG); MemOff (GaugeResult_Send)
	TC Off
	Pick_case = False
	IsBuzy = True
	Tool 0
	
	ex_product = product
	ex_j = j
	If (Abs((CZ(Here) - CZ(palletup)) > 10 Or Abs(CX(Here) - CX(palletup)) > 10 Or Abs(CY(Here) - CY(palletup)) > 10)) Then
		'不在秤重區等待時 到高處再過來	
		Tool 0
		Move Here :Z(500)
		Go LJM(palletup)
	EndIf
'	If Sw(DI_Table_Have) = True Then
'		Return_code$ = "ERR;Have_Sensor_On"
'		Exit Function
'	EndIf
	If Sw(DI_GP_Close) = On And Sw(DI_Senosr_Pick) = On Then '檢測夾爪有料異常
		Return_code$ = "ERR;SENSOR;On" '回傳偵測失敗
		Move Here :Z(500)
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Go LJM(palletup)
		Exit Function
	EndIf
	If (Grip_Open_In = False) Then
		Move Here :Z(500)
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Go LJM(palletup)
		Exit Function
	EndIf
    Go LJM(Pallet(product, j) +X(23) +Y(2) +Z(27))
    Wait 0.5
    MemOn (GaugeResult_Send)
'    Print #201, "cmd;received"
'	Print #201, "OnPosGauge" '膠量檢測 測試暫時註解
    Wait MemSw(GaugeResult_OK) = On Or MemSw(GaugeResult_NG) = On, 30
    If TW = True Or MemSw(GaugeResult_NG) = On Then
		Return_code$ = "ERR;GaugeResult"
		Exit Function
	EndIf
	'從當前位置到用紅外線SENSRO檢測塗交
'	Wait Sw(DI_Senosr_Check) = On, 2
'	If TW = True And Grip_Pass = False Then
'		Return_code$ = "ERR,SENSOR" '回傳紅外線偵測失敗	
'		Tool 0
'		Move Here :Z(500)
'		j = j + 1 '瑪垛+1
'		If j > y * x Then '瑪垛回到1
'			j = 1
'		EndIf
'		Exit Function
'	EndIf


	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Move Here :Z(500)
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Exit Function
	EndIf
	Wait 1
	Go Pallet(product, j) +Z(25 + Thick_Platform)
	SpeedS 50
	Go Pallet(product, j) +Z(10 + Thick_Platform)
	TC On
	Move Pallet(product, j) +Z(Thick_Platform)
	TC Off
	Call DefSpeed
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	If (Grip_Close_In = False) Then
		If Grip_Open_In = False Then
		EndIf
		SpeedS 100
		Move Here +Z(30)
		Call DefSpeed
		Exit Function
	EndIf
	Move Here +Z(30) CP
	Go palletup CP
 	Go CCD2 '到拍照位置
	Boolean found, found2
	Wait 0.5
	Real uu22
'	VRun CCD2_ASSEMBLE '執行相機拍照
'	VGet CCD2_ASSEMBLE.Geom01.Found, found2
' 	VGet CCD2_ASSEMBLE.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
 	VRun str_seq$ '執行相機拍照
	VGet str_seq$.Geom01.Found, found2
 	VGet str_seq$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
 	If found2 = False Or found = False Then
 		VRun str_seq$ '執行相機拍照
		VGet str_seq$.Geom01.Found, found2
 		VGet str_seq$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
 	EndIf
	If (found = True And Abs(Abs(ccdX) - Abs(Standard_ccd_X)) < 6 And Abs(Abs(ccdY) - Abs(Standard_ccd_Y)) < 6) Or Ccd_Pass = True Then  '有找到物件And CXX <> 0 And CYY <> 0 And CUU <> 0
		VGet str_seq$.Geom01.Angle, uu22
		Print "原始U", Str$(uu22)
		If ccdU > 180 Then
			ccdU = uu22 - 360
		EndIf
		If (Abs(Abs(uu22) - Abs(Standard_ccd_U)) > 1) Then
			Tool 0
			Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", uu22
			Return_code$ = "ERR;FOUND;" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(uu22) '回傳拍照失敗 	
			Move Here +Z(100) CP
			Go LJM(palletup) CP
			Move LJM(Pallet(ex_product, ex_j) +Z(20 + Thick_Platform)) CP '放回
			Move LJM(Pallet(ex_product, ex_j) +Z(10 + Thick_Platform))
			TC On
			Move LJM(Pallet(ex_product, ex_j) +Z(5 + Thick_Platform))
			TC Off
			If (Grip_Open_In = False) Then
				
			EndIf
			Move Here +Z(100) CP
			Go LJM(palletup)
			Print Return_code$
		 	Exit Function
		EndIf

		TLSet 2, XY(ccdX, ccdY, 00, uu22)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", uu22
	Else
		Tool 0
		Return_code$ = "ERR;FOUND" + Str$(ccdX) + "Y is:" + Str$(ccdY) + "U is:" + Str$(uu22) '回傳拍照失敗 	
		Move Here +Z(100) CP
		Go LJM(palletup) CP
		Move LJM(Pallet(ex_product, ex_j) +Z(20 + Thick_Platform)) CP '放回
		Move LJM(Pallet(ex_product, ex_j) +Z(5 + Thick_Platform))
		If (Grip_Open_In = False) Then
			
		EndIf
		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", uu22
		Move Here +Z(100) CP
		Go LJM(palletup)
		Print Return_code$
	 	Exit Function
	EndIf
	Tool 0
	Go PalletUp_Put
	Return_code$ = "RunFinish;PICK;" + Str$(ex_product) + ";" + Str$(ex_j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(uu22)
	Print Return_code$
	Pick_case = True
	Exit Function
	handle:
	Print "Error Pick"
	Print "ERR:", SysErr
	'Return_code$ = "ERR,FOUND"
		Return_code$ = "ERR:" + Str$(SysErr)
		If ChkNet(201) > 0 Then
			Print #201, "ERR;", SysErr
		EndIf
		If ChkNet(207) > 0 Then
			Print #207, "ERR;", SysErr
		EndIf
	Reset
Fend
Function MoveToPut_In '放料
	'Robot 1
	TC Off
	OnErr GoTo handle
	IsBuzy = True
	If (Abs(CZ(Here) - CZ(PalletUp_Put) > 20 Or Abs(CX(Here) - CX(PalletUp_Put)) > 20 Or Abs(CY(Here) - CY(PalletUp_Put)) > 20)) Then
		Tool 0
		Move Here :Z(500)
		Go PalletUp_Put
		Print "ERR;Postion"
	EndIf
	If Sw(DI_Table_Have) = True Then
		Return_code$ = "ERR;Have_Sensor_On"
		Exit Function
	EndIf
	Tool 2
'	Double shtX, shtY, shtU, shtV, shtW
'	shtX = -0.677 '0.411 - 1.088
'	shtY = 0.59 '-1.089 + 1.679
'	shtU = 0
'	
	
'	Go put +X(shtX) +Y(shtY) +U(shtU) :Z(400) CP
'	Go put +X(shtX) +Y(shtY) +U(shtU) +Z(20 + Thick_Conveyor)
	Go put :Z(400) CP
	Go put +Z(20 + Thick_Conveyor)
	SpeedS 50
	TC On
'	Move put +X(shtX) +Y(shtY) +Z(0 + Thick_Conveyor)
	Move put +Z(0.5 + Thick_Conveyor)
	TC Off
	Call DefSpeed
	If (Grip_Open_In = False) Then
		Tool 0
		Move Here :Z(500)
		Exit Function
	EndIf
	Print "放料完成"
	
	Tool 0
	Move Here :Z(500) CP
	Go PalletUp_Put CP
	Go LJM(palletup) CP
	Return_code$ = "RunFinish;PUTP"
	If Sw(DI_Table_Have) = False Then
		Return_code$ = "ERR;Have_Sensor_Off"
	EndIf
	Print Return_code$
	Exit Function
	handle:
	Print "Error PUTP"
	Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(201) > 0 Then
			Print #201, "ERR;", SysErr
		EndIf
		If ChkNet(207) > 0 Then
			Print #207, "ERR;", SysErr
		EndIf
	Reset
Fend
Function GoHome_In '復歸
	'Robot 1
	TC On
	OnErr GoTo handle
	Speed 10
	SpeedS 40
	IsBuzy = True
	Print CZ(Here)
	If CZ(Here) < 450 Then
		Move Here +Z(50)
		Go Here :Z(500)
	ElseIf CZ(Here) < 500 Then
		Move Here :Z(500)
	EndIf
	If (Abs((CZ(Here) - CZ(palletup)) > 30 Or Abs(CX(Here) - CX(palletup)) > 30 Or Abs(CY(Here) - CY(palletup)) > 30)) Then
		Tool 0
		Move LJM(palletup)
	EndIf
	Home
	Return_code$ = "RunFinish;HOME"
	Call DefSpeed
	Print Return_code$
	TC Off
	Power High
	Exit Function
	handle:
	Print "Error Home"
	Print "ERR:", SysErr
		TC Off
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(201) > 0 Then
			Print #201, "ERR;", SysErr
		EndIf
		If ChkNet(207) > 0 Then
			Print #207, "ERR;", SysErr
		EndIf
	Reset
Fend
Function tcpipcmd_In
	String leftcmd$, midcmd$
	Boolean Pass_Tcpip
	'Pass_Tcpip = True
	Do
		 OpenNet #201 As Server
		 WaitNet #201, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #201 Connected"
		 	
		 	Do
		 		If MemSw(GaugeResult_Send) = On Then
		 				Print #201, "OnPosGauge" '膠量檢測 測試暫時註解
		 				MemOff (GaugeResult_Send)
		 		EndIf
		 			
				
            	If (PauseOn = True Or SafetyOn = True) Then
            		If ChkNet(201) > 0 Then
				 		Line Input #201, cmd_plu$
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks12$(0)
			 					ParseStr cmd_plu$, toks12$(), ";"
			 					Select toks12$(0)
						 		Case "Resume"
							 		Print #201, "Resume"
							 		Print "Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #201, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
            	Else
                 	If (ChkNet(201) > 0) Or Pass_Tcpip = True Then '連線埠有ndIf
				 		If Pass_Tcpip = False Then
				 			Line Input #201, cmd$
				 		EndIf
					 	If cmd$ <> "" Then
				 			Print "received '", cmd$, "' from PC"
				 			String toks1$(0)
				 			ParseStr cmd$, toks1$(), ";"
	                        Select toks1$(0)
				 				Case "PROD" '讀產品
				 					Integer product_tcpip
				 					Print #201, "cmd;received"
				 				
				 					product_tcpip = Val(toks1$(1))
	                                Call PRODUCT_IN(ByRef product_tcpip)
				 				Case "PICK" '取料及相機
				 					Print #201, "cmd;received"
				 					If product_load = True Then
				 						Xqt 4, MovetoPick_In
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "SYPK" '指定取料
				 					Integer Specify_num
				 					Print #201, "cmd;received"
				 					Specify_num = Val(toks1$(1))
				 					If product_load = True And (0 < Specify_num <= Total_XY) Then
				 						'Call MoveToSpecifyPick_In(ByRef Specify_num)
				 						j = Specify_num
				 						Return_code$ = "RunFinish;SYPK;" + Str$(product) + ";" + Str$(j)
				 					Else
				 						If product_load = False Then
				 							Return_code$ = "ERR;Product No Load"
				 						Else
				 							Return_code$ = "ERR;Specify_num is not true"
				 						EndIf
				 					EndIf
				 				Case "PUTP" '放料
				 					Print #201, "cmd;received"
				 					If product_load = True Then
				 						Xqt 4, MoveToPut_In
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
	'			 				Case "GOSD" '待機
	'			 					Print #201, "cmd;received"
	'			 					If product_load = True Then
	'			 						Xqt 4, MoveToStandby
	'			 					Else
	'			 						Return_code$ = "ERR;Product No Load"
	'			 					EndIf
				 				Case "HOME" '復歸
				 					Print #201, "cmd;received"
				 					Xqt 4, GoHome_In
				 				Case "PIBK"
				 					Print #201, "cmd;received"
				 					If product_load = True Then
				 						Xqt 4, MovetoPickBack_In
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
			 					Case "Paus"
				 				   Print #201, "cmd,Pause," + Str$(TaskInfo(4, 3))
				 				   Halt 4
				 				Case "Resu"
				 				   Print #201, "cmd,Resu" + Str$(TaskInfo(4, 3))
				 				   Resume 4
				 				Case "TKIF"
				 					If (TaskInfo(4, 3)) < 1 Then Print #201, "Task;NotRun"
				 					If (TaskInfo(4, 3)) = 1 Then Print #201, "Task;Run"
									If (TaskInfo(4, 3)) = 2 Then Print #201, "Task;Wait"
									If (TaskInfo(4, 3)) = 3 Then Print #201, "Task;Pause"
									If (TaskInfo(4, 3)) = 4 Then Print #201, "Task;Stop"
									If (TaskInfo(4, 3)) = 5 Then Print #201, "Task;Error"
					 			Case "SetShift"
		                            Print #201, "cmd;received;", toks1$(0)
					 				Return_code$ = "SETSHIFT"
					 				Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)), Val(toks1$(7)), Val(toks1$(8)))
					 			Case "GetShift"
					 				Print #201, "cmd;received;", toks1$(0)
					 				Call Get_XYZU
				 				Case "Info"
				 					Return_code$ = "Robot Name: " + RobotModel$ + "," + "Robot Sequence: " + RobotInfo$(4)
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
				 				Case "Resume"
				 				Case "GaugeResult"
				 					Print #201, "cmd;received"
				 					If(toks1$(1)) = "OK" Then
				 						MemOn (GaugeResult_OK)
				 					ElseIf(toks1$(1)) = "NG" Then
				 						MemOn (GaugeResult_NG)
				 					EndIf
				 					
				 				Default
				 					Print #201, "ERR,Cmd_NotFound"
				 			Send
				 			EndIf
					 	cmd$ = ""
	                    
				 	EndIf
					If TaskInfo(4, 3) < 1 Or TaskInfo(4, 3) > 3 Then
				 		IsBuzy = False
				 	EndIf
				 	If Return_code$ <> "" And IsBuzy = False Then
			 			Print #201, Return_code$
			 			Return_code$ = ""
			 		EndIf
				 	If ChkNet(201) = -3 Then
				 		CloseNet #201
				 		Print "Disconnected"
				 		Exit Do
					EndIf
				EndIf
			Loop
		EndIf
	Loop
Fend
Function CCD_TEACH
	Boolean found
	VRun CCD2_ASSEMBLE '執行相機拍照
 	VGet CCD2_ASSEMBLE.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
	If (found = True) Or Ccd_Pass = True Then  '有找到物件And CXX <> 0 And CYY <> 0 And CUU <> 0
		Print "原始U", Str$(ccdU)
		If ccdU > 180 Then
			ccdU = ccdU - 360
		EndIf
		TLSet 2, XY(ccdX, ccdY, 00, ccdU)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	EndIf
Fend
'Function MoveToStandby
'		'Robot 1
'	OnErr GoTo handle
'	IsBuzy = True
'		Tool 2
'	If (Abs(CZ(Here) - 500 > 10 Or Abs(CX(Here) - CX(PalletUp_Put)) > 10 Or Abs(CY(Here) - CY(PalletUp_Put)) > 10)) Then
'		Tool 0
'		Move Here :Z(500)
'		Go LJM(PalletUp_Put)
'		Print "ERR;Postion"
'	EndIf
'	Tool 0
'	Go LJM(palletup)
'	
'	Return_code$ = "RunFinish;GOSD"
'	Tool 0
'	Move Here :Z(500)
'	Print Return_code$
'	Exit Function
'	handle:
'	Print "ERR:", SysErr
'		Return_code$ = "ERR:" + Str$(SysErr)
'		If ChkNet(201) > 0 Then
'			Print #201, "ERR;", SysErr
'		EndIf
'		If ChkNet(207) > 0 Then
'			Print #207, "ERR;", SysErr
'		EndIf
'	Reset
'Fend

