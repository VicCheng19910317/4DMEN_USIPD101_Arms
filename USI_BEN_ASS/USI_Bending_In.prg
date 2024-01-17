Global Integer i, j, product, x, y, SP_SDef, SP_NDef, Total_XY
Global String cmd$, Return_code$
Global Boolean IsBuzy, Ccd_Pass, Grip_Pass, product_load, test_mode
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform
Function main
	'Robot 1
	Reset
	Motor On
	Wait Motor = On
	Power High
	'-----基礎設定
	Weight 3 '治具+工件重量
	Tool 0
	SP_NDef = 50
	Speed SP_NDef
	Accel 100, 100
	SP_SDef = 500
	SpeedS SP_SDef
	AccelS 50, 50
	'-----
	Ccd_Pass = True '相機檢測PASS
	Grip_Pass = True '夾爪相關PASS
	test_mode = True
	IsBuzy = False
	Xqt Move_Test
	'-----
	Xqt tcpipcmd_In
	
Fend
Function Move_Test
	Integer IIXX
	IIXX = 0
	Call PRODUCT_IN(ByRef IIXX)
	Call GoHome_In
	Do
		Call MovetoPick_In
		Call MoveToPut_In
	Loop
Fend
Function PRODUCT_IN(ByRef product_local As Integer)
	'Robot 1
	IsBuzy = True
	product_load = False
	j = 1
	Select product_local
		Case 0
			product = product_local
			x = 3
			y = 4
			Pallet 0, PL1, PL2, PL3, PL4, x, y
			Thick_Conveyor = 0 '輸送帶到工件的厚度
			Thick_Platform = 10 '平台到工件的厚度
			product_load = True
	Send
	If test_mode = True Then
		Thick_Conveyor = 50 '輸送帶到工件的厚度
		Thick_Platform = 50 '平台到工件的厚度
	EndIf
	If product_load = True Then
		Return_code$ = "RunFinish,PROD," + Str$(product)
		Total_XY = x * y
	Else
		Return_code$ = "ERR,PROD"
		Total_XY = 0
	EndIf
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
	Grip_Open_In = True
Fend
Function Grip_Close_In As Boolean
	Off GP_OPEN
	On GP_CLOSE
	Wait Sw(DI_GP_Close) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,GRIP_OP" '回傳閉爪失敗		
		Grip_Close_In = False
		Exit Function
	EndIf
	Grip_Close_In = True
Fend
Function MovetoPick_In '取料及相機
	'Robot 1
	String ex_product$, ex_j$
	IsBuzy = True
	Tool 0
	If (Grip_Open_In = False) Then
		Exit Function
	EndIf
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	Jump3 Here :Z(550), palletup, Pallet(product, j) +X(20) +Z(20 + Thick_Platform) '從當前位置到用紅外線SENSRO檢測塗交
	Wait Sw(DI_Senosr_Check) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,SENSOR" '回傳紅外線偵測失敗	
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Exit Function
	EndIf

	Go Pallet(product, j) +Z(10 + Thick_Platform) CP
	SpeedS 100
	Move Pallet(product, j) +Z(Thick_Platform)
	SpeedS SP_SDef
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,SENSOR" '回傳偵測失敗
		Exit Function
	Else
		If (Grip_Close_In = False) Then
			Exit Function
		EndIf
	EndIf
	Move Here +Z(30)
	Move palletup
 	Go ccd '到拍照位置
' 	Boolean found
' 	VRun Test01 '執行相機拍照
' 	VGet Test1.Geom01.RobotToolXYU, found, ccdX, ccdY, ccdU
'	If found = True Or Ccd_Pass = True Then  '有找到物件
'		TLSet 15, XY(ccdX, ccdY, 00, ccdU)
' 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
'	Else
'	 	Return_code$ = "ERR,Geom was not found!" '回傳拍照失敗 	
'		Print Return_code$
'	 	Exit Function
'	EndIf
	Return_code$ = "RunFinish,PICK," + ex_product$ + "," + ex_j$
Fend
Function MoveToSpecifyPick_In(ByRef Specify_num As Integer)
	'Robot 1
	String ex_product$, ex_j$
	IsBuzy = True
	j = Specify_num
	Tool 0
	If (Grip_Open_In = False) Then
		Exit Function
	EndIf
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	Jump3 Here :Z(550), palletup, Pallet(product, j) +X(20) +Z(20 + Thick_Platform) '從當前位置到用紅外線SENSRO檢測塗交
	Wait Sw(DI_Senosr_Check) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,SENSOR" '回傳紅外線偵測失敗	
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Exit Function
	EndIf

	Go Pallet(product, j) +Z(10 + Thick_Platform) CP
	SpeedS 100
	Move Pallet(product, j) +Z(Thick_Platform)
	SpeedS SP_SDef
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR,SENSOR" '回傳偵測失敗
		Exit Function
	Else
		If (Grip_Close_In = False) Then
			Exit Function
		EndIf
	EndIf
	Move Here +Z(30)
	Move palletup
 	Go ccd '到拍照位置
' 	Boolean found
' 	VRun Test01 '執行相機拍照
' 	VGet Test1.Geom01.RobotToolXYU, found, ccdX, ccdY, ccdU
'	If found = True Or Ccd_Pass = True Then  '有找到物件
'		TLSet 15, XY(ccdX, ccdY, 00, ccdU)
' 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
'	Else
'	 	Return_code$ = "ERR,Geom was not found!" '回傳拍照失敗 	
'		Print Return_code$
'	 	Exit Function
'	EndIf
	Return_code$ = "RunFinish,PICK," + ex_product$ + "," + ex_j$
Fend
Function MoveToPut_In '放料
	'Robot 1
	IsBuzy = True
	Jump3 PutUp, put +Z(10 + Thick_Conveyor), put +Z(Thick_Conveyor)
	If (Grip_Open_In = False) Then
		Move Here :Z(550)
		Tool 0
		Exit Function
	EndIf
	Print "放料完成"
	Return_code$ = "RunFinish,PUTP" + "," + Str$(ccdX) + "," + Str$(ccdY) + "," + Str$(ccdU)
	Move Here :Z(550)
	Tool 0
Fend
Function GoHome_In '復歸
	'Robot 1
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
	Home
	Return_code$ = "RunFinish,HOME"
	SpeedS SP_SDef
	Speed SP_NDef
	Print Return_code$
Fend
Function tcpipcmd_In
	String leftcmd$, midcmd$
	Boolean Pass_Tcpip
	Pass_Tcpip = True
	SetNet #201, "192.168.0.21", 2000, CRLF, NONE, 0, TCP
	Do
		 OpenNet #201 As Server
		 WaitNet #201, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #201 Connected"
		 	Do
			 	If (ChkNet(201) > 0 And IsBuzy = False) Or Pass_Tcpip = True Then '連線埠有資料
			 		If Pass_Tcpip = False Then
			 			Line Input #201, cmd$
			 		EndIf
				 	If cmd$ <> "" Then
			 			Print "received '", cmd$, "' from PC"
			 			leftcmd$ = Left$(cmd$, 4) '讀1-4
			 			Select leftcmd$
			 				Case "PROD" '讀產品
			 					Integer product_tcpip
			 					Print #201, "cmd,received"
			 					midcmd$ = Mid$(cmd$, 5) '第五個字往後讀
			 					product_tcpip = Val(midcmd$)
                                Call PRODUCT_IN(ByRef product_tcpip)
			 				Case "PICK" '取料及相機
			 					Print #201, "cmd,received"
			 					If product_load = True Then
			 						Call MovetoPick_In
			 					Else
			 						Return_code$ = "ERR,Product No Load"
			 					EndIf
			 				Case "SYPK" '指定取料
			 					Integer Specify_num
			 					Print #204, "cmd,received"
			 					Specify_num = Val(Mid$(cmd$, 5))
			 					If product_load = True And (Specify_num <= Total_XY) Then
			 						Call MoveToSpecifyPick_In(ByRef Specify_num)
			 					Else
			 						If product_load = False Then
			 							Return_code$ = "ERR,Product No Load"
			 						Else
			 							Return_code$ = "ERR,Specify_num is too more"
			 						EndIf
			 					EndIf
			 				Case "PUTP" '放料
			 					Print #201, "cmd,received"
			 					If product_load = True Then
			 						Call MoveToPut_In
			 					Else
			 						Return_code$ = "ERR,Product No Load"
			 					EndIf
			 				Case "HOME" '復歸
			 					Print #201, "cmd,received"
			 					Call GoHome_In
			 				Default
			 					Print #201, "ERR,Cmd_NotFound"
			 			Send
			 			IsBuzy = False
			 			If Return_code$ <> "" Then
			 				Print #201, Return_code$
			 				Return_code$ = ""
			 			EndIf
				 	cmd$ = ""
                    EndIf
			 	EndIf
			 	If ChkNet(201) = -3 Then
			 		CloseNet #201
			 		Print "Disconnected"
			 		Exit Do
			 	EndIf
			 Loop
		 EndIf
	Loop
Fend
'流程 
'開始讀參數 PROD0
'動作 PUTP PICK
'復歸 Home

