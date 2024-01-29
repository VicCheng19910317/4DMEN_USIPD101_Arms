Global Integer i, j, product, x, y, SP_SDef, SP_NDef, int_TotalXY, Start_move, Now_product, Start_Product
Global String cmd$, Return_code$, cmd_plu$, ex_product$, ex_j$, seq_DownToUp$, seq_UpToDown$
Global Boolean IsBuzy, Ccd_Pass, Grip_Pass, Pneumatic_Pass, Vacuum_Pass, product_load, Pass_Tcpip, test_mode
Global Real ccdX, ccdY, ccdU, DefUptoDown_X, DefUptoDown_Y, DefUptoDown_U, DefDowntoUp_X, DefDowntoUp_Y, DefDowntoUp_U, ASSEMBLE_Z, Thick_Conveyor, Thick_Platform '輸送帶到工件的厚度,平台到工件的厚度
Global Double CCD4_Xdef, CCD4_Ydef
Global Preserve Integer X_LOWER2, Y_LOWER2, U_LOWER2, X_LOWER, X_UPPER, Y_LOWER, Y_UPPER, U_LOWER, U_UPPER
Function main
	'V1.02.10190126.SO
	Reset
	Motor On
	Wait Motor = On
	Power High
	OnErr GoTo handle
	'------基本設置
	LoadPoints "robot3.pts"
	Weight 0.6 '治具+工件重量
	Tool 0
	Call DefSpeed
	SetNet #206, "192.168.0.26", 2000, CRLF, NONE, 0, TCP
	IsBuzy = False
	product_load = False
	TCLim 50, 50, 50, 50, 30, 50
'	If X_LOWER = 0 And X_UPPER = 0 Then
	X_LOWER = -3; X_UPPER = 3
    Y_LOWER = -3; Y_UPPER = 3
    U_LOWER = -1; U_UPPER = 1
    X_LOWER2 = 5; Y_LOWER2 = 5; U_LOWER2 = 2
'    EndIf
	'-----測試模塊
'	Vacuum_Pass = True '真空PASS
'	Ccd_Pass = True '相機檢測PASS
'	Grip_Pass = True '夾爪相關PASS
'	Pass_Tcpip = True
	'test_mode = True
	Integer re0, XXYY
	re0 = 0
	Call Product_Pick_Out(ByRef re0)
	Return_code$ = ""
    '-----
	Xqt 2, tcpipcmd_Out, NoPause
	Exit Function
	handle:
		Print "Error main"
		Print "ERR;", Err
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(206) > 0 Then
			Print 206, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function BOX_Test
	Box 1, -200, 300, 0, 500, -100, 0
	
Fend
Function WaitNoBox
	Do
		Wait GetRobotInsideBox(1) = 0
		Motor Off
	Loop
Fend
Function DefSpeed
	SP_NDef = 40
	Speed SP_NDef
	Accel SP_NDef, SP_NDef
	SP_SDef = 1200
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function SlowSpeed
	SP_NDef = 20
	Speed SP_NDef
	Accel SP_NDef, SP_NDef
	SP_SDef = 200
	SpeedS SP_SDef
	AccelS SP_SDef, SP_SDef
Fend
Function Product_Pick_Out(ByRef product_local As Integer)
	'Robot 3
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
			'上對下相機
			DefUptoDown_X = -280.174 'X標準值
			DefUptoDown_Y = 160.508 'Y標準值
			DefUptoDown_U = 359 'U標準值
			'下對上相機
			DefDowntoUp_X = -26.059 'X標準值
			DefDowntoUp_Y = -90.559 'Y標準值
			DefDowntoUp_U = 0.144 'U標準值
			
			ASSEMBLE_Z = 0.5 '組裝高度調整
			Start_Product = 100 '使用產品點位起點1-8
			seq_DownToUp$ = "SEaL_CCD2_ASSE" '下對上相機檢測序列
			seq_UpToDown$ = "CCDD4" '上對下相機檢測序列
	
			product_load = True '成功讀取產品
		Case 1

			x = 4
			y = 3


	Send

	If product_load = True Then
		j = 1
		product = product_local
		
		If CU(P(Start_Product)) + CU(P(Start_Product + 8)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 8)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 8)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8)
		EndIf
		If CU(P(Start_Product + 5)) + CU(P(Start_Product + 9)) > 180 Then
			put_assembledX3 = P(Start_Product + 5) + P(Start_Product + 9) :U((CU(P(Start_Product + 5)) + CU(P(Start_Product + 9))) - 360)
		Else
			put_assembledX3 = P(Start_Product + 5) + P(Start_Product + 9)
		EndIf
		
'		PL1 = P(Start_Product) + P(Start_Product + 8)
'		PL2 = P(Start_Product + 1) + P(Start_Product + 8)
'		PL3 = P(Start_Product + 2) + P(Start_Product + 8)
		check_one = P(Start_Product + 3)
		pick = P(Start_Product + 4)
'		put_assembledX3 = P(Start_Product + 5) + P(Start_Product + 9)
		CCD2Test = P(Start_Product + 6)
		pick_assembled = P(Start_Product + 7)
		
		Pallet 0, PL1, PL2, PL3, x, y
		int_TotalXY = x * y
		Return_code$ = "RunFinish;PROD;" + Str$(product)
		SavePoints "robot3.pts"
	Else
		Return_code$ = "ERR;PROD"
	EndIf
	IsBuzy = False
	Print Return_code$
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real, Offset_X2 As Real, Offset_Y2 As Real, Offset_Z2 As Real, Offset_U2 As Real)
	If Start_Product >= 0 Then
		P(Start_Product + 8) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U)
		P(Start_Product + 9) = XY(Offset_X2, Offset_Y2, Offset_Z2, Offset_U2)
		SavePoints "robot3.pts"
		If CU(P(Start_Product)) + CU(P(Start_Product + 8)) > 180 Then
			PL1 = (P(Start_Product) + P(Start_Product + 8)) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8) :U((CU(P(Start_Product)) + CU(P(Start_Product + 8))) - 360)
		Else
			PL1 = P(Start_Product) + P(Start_Product + 8)
			PL2 = P(Start_Product + 1) + P(Start_Product + 8)
			PL3 = P(Start_Product + 2) + P(Start_Product + 8)
		EndIf
		If CU(P(Start_Product + 5)) + CU(P(Start_Product + 9)) > 180 Then
			put_assembledX3 = P(Start_Product + 5) + P(Start_Product + 9) :U((CU(P(Start_Product + 5)) + CU(P(Start_Product + 9))) - 360)
		Else
			put_assembledX3 = P(Start_Product + 5) + P(Start_Product + 9)
		EndIf
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
	Wait 0.2
	Grip_Open_Out = True
Fend
Function Grip_Close_Out As Boolean
	Off GP_OPEN
	On GP_CLOSE
	Wait Sw(DI_GP_Close) = On, 2
	If TW = True And Grip_Pass = False Then
		Return_code$ = "ERR;GRIP_CL" '回傳閉爪失敗		
		Grip_Close_Out = False
		Exit Function
	EndIf
	Wait 0.2
	Grip_Close_Out = True
Fend
Function MovetoPick_Out '組裝&一次檢定
	OnErr GoTo handle
	TC Off
	Call DefSpeed
	IsBuzy = True
	Tool 0
	If (CY(Here)) < 10 Then
		Call SlowSpeed
		Move Here :Z(600)
		Move LJM(SafePointPut_AS :Z(600))
		Move LJM(palletup :Z(600))
		Print "ERR;Postion"
	EndIf
	If (Abs(CZ(Here) - CZ(palletup) > 10 Or Abs(CX(Here) - CX(palletup)) > 5 Or Abs(CY(Here) - CY(palletup)) > 5)) Then
		Call SlowSpeed
		Move Here :Z(600) CP
		Move LJM(palletup :Z(600))
		Print "ERR,Postion"
	EndIf
	If Sw(DI_Senosr_Pick) = On Then
		Move Here :Z(600) CP
	EndIf
	If Sw(DI_Senosr_Pick) = On Then
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	If (Grip_Open_Out = False) Then
		Exit Function
	EndIf
	
	Go (SafePointPut_AS :Z(600)) CP
	Go (pick_assembled :Z(600)) CP
	Go LJM(pick_assembled +Z(20)) CP
	SpeedS 30
	Move LJM(pick_assembled +Z(5))
	TC On
    Move LJM(pick_assembled)
    TC Off
	Call DefSpeed
	Wait Sw(DI_Senosr_Pick) = On, 2
	If TW = True And Grip_Pass = False Then
		Move Here :Z(600)
		Return_code$ = "ERR;SENSOR" '回傳偵測失敗
		Exit Function
	EndIf
	Off Vacuum_CL
	On Vacuum_OP '吸氣
	Wait Sw(DI_Vacuum) = On, 2
'	Move Here +Z(30 + Thick_Platform)
	If TW = True And Vacuum_Pass <> True Then
		Off Vacuum_OP
		Move Here :Z(600)
		Return_code$ = "ERR;VACCUM_OP" '回傳真空失敗
		Exit Function
	EndIf
	Wait 0.2
	Move Here :Z(600)
	Go (SafePointPut_AS :Z(600)) CP
	Go LJM(CCD2Test)
	Wait 0.5
 	Boolean found, found2
 	Real CCDU2
 	'VRun SEaL_CCD2_ASSE '執行相機拍照
 	VRun seq_DownToUp$ '執行相機拍照
 	VGet seq_DownToUp$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU
	If (found = True And Abs(Abs(ccdX) - Abs(DefDowntoUp_X)) < X_LOWER2 And Abs(Abs(ccdY) - Abs(DefDowntoUp_Y) < Y_LOWER2)) Then  '有找到物件
		VGet seq_DownToUp$.Geom01.Angle, CCDU2
	'	VGet SEaL_CCD2_ASSE.Geom01.Angle, ccdU
		If CCDU2 > 180 Then
			CCDU2 = CCDU2 - 360
		EndIf
		If Abs(Abs(CCDU2) - Abs(DefDowntoUp_U)) > U_LOWER2 Then
			Return_code$ = "ERR;U>" '回傳拍照失敗 	
			Print Return_code$
		 	Exit Function
		EndIf
		TLSet 3, XY(ccdX, ccdY, 0, CCDU2)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", CCDU2
	Else
	 	VRun seq_DownToUp$ '執行相機拍照
 		VGet seq_DownToUp$.Point01.RobotToolXYU, found, ccdX, ccdY, ccdU

		If found = True Or Ccd_Pass = True Then  '有找到物件
		
			VGet seq_DownToUp$.Geom01.RobotU, CCDU2
			If CCDU2 > 180 Then
				CCDU2 = CCDU2 - 360
			EndIf
			If Abs(Abs(CCDU2) - Abs(DefDowntoUp_U)) > 2 Then
				Return_code$ = "ERR;U>" '回傳拍照失敗 	
				Print Return_code$
			 	Exit Function
			EndIf
			
			TLSet 3, XY(ccdX, ccdY, 00, CCDU2)
	 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", CCDU2
		Else
		 	Return_code$ = "ERR;CCDERROR" '回傳拍照失敗 	
			Print Return_code$
		 	Exit Function
		EndIf
	EndIf
	Tool 0
	Go LJM(Safe_point_Put_under)
	Return_code$ = "RunFinish;PICK;" + Str$(j) + ";" + Str$(ccdX) + ";" + Str$(ccdY) + ";" + Str$(CCDU2)
	Print Return_code$
	Exit Function
	handle:
		Print "Error PICK"
		Print "ERR:", Err
		Move Here :Z(600)
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(206) > 0 Then
			Print 206, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
	
Fend
Function SafeSensor
	Do
		If Sw(DI_Senosr_Check) = On Then
			Quit 4
			Do
			Loop Until TaskDone(4)
			Wait 1
			TC On
			Move Here :Z(550)
			TC Off
			Return_code$ = "ERR;SENSOR;ASSEMBLE"
			MemOff 1
		EndIf
	Loop Until TaskDone(4)
Fend
Function MoveToAssemble
	OnErr GoTo handle
	TC Off
	IsBuzy = True
	Tool 0
	If (CY(Here)) < 10 Then
		Call SlowSpeed
		Move Here :Z(600)
		Move LJM(SafePointPut_AS :Z(600))
		Move LJM(palletup :Z(600))
		Print "ERR;Postion"
	EndIf
	If Abs(CZ(Here) - CZ(Safe_point_Put_under)) > 10 Or Abs(CX(Here) - CX(Safe_point_Put_under)) > 10 Or Abs(CY(Here) - CY(Safe_point_Put_under)) > 10 Then
		Tool 0
		If Sw(DI_Senosr_Pick) = Off Then
			Return_code$ = "ERR;SENSOR;READ" '回傳偵測失敗
			Exit Function
		EndIf
		SpeedS SP_SDef / 2
		AccelS SP_SDef / 2, SP_SDef / 2
		Move Here :Z(600)
		Call DefSpeed
		Go LJM(SafePointPut_AS :Z(600))
	
		Go LJM(CCD2Test)
		Go LJM(Safe_point_Put_under)
		Print "ERR;Postion"
	EndIf
	Boolean found
 	Real xx, yy, uu
	VRun seq_UpToDown$
	VGet seq_UpToDown$.Point01.RobotXYU, found, xx, yy, uu
	VGet seq_UpToDown$.Line01.Found, found

	If (found = True And ((xx) - (DefUptoDown_X)) <= X_UPPER And ((xx) - (DefUptoDown_X)) >= X_LOWER And ((yy) - (DefUptoDown_Y)) < Y_UPPER And ((yy) - (DefUptoDown_Y)) >= Y_LOWER) Then  '有找到物件
		VGet CCDD4.Line01.Angle, uu
		If uu < 180 Then
			uu = 360 + uu
		EndIf
		If (Abs(uu - DefUptoDown_U) > 1) Then
			uu = 360 - uu
		Else
			uu = 360 - uu
		EndIf
		If (uu >= U_UPPER And uu <= U_LOWER) Then
			Return_code$ = "ERR;CCDERROR:U" '回傳拍照失敗 	
			Print Return_code$
		 	Exit Function
		EndIf
		Local 2, XY(xx, yy, 0, 0)
 		Print " X:	", xx, "	Y:	", yy, "	U:	", uu
	Else
	 	Return_code$ = "ERR;CCDERROR" '回傳拍照失敗 	
		Print Return_code$
	 	Exit Function
	EndIf
	Tool 3
	TC On
	Go LJM(put_assembledX3 +Z(25)) '25
	SpeedS 20
	AccelS 20, 100
	If TaskInfo(6, 3) = 1 Then
		Quit SafeSensor
		Wait 0.5
	EndIf
	Xqt 6, SafeSensor
	
    Move LJM(put_assembledX3 +Z(ASSEMBLE_Z + Thick_Conveyor + 0.5))
    Quit SafeSensor
    Wait 0.1
    Move LJM(put_assembledX3 +Z(ASSEMBLE_Z + Thick_Conveyor))
	On Vacuum_CL
	Off Vacuum_OP '吸氣
	Wait Sw(DI_Vacuum) = Off, 2
	If TW = True And Vacuum_Pass = False Then
	 	Move Here :Z(550)
		Return_code$ = "ERR;Vacuum" '回傳真空失敗
		Exit Function
	EndIf
	Tool 0
	If Abs(CZ(Here) - CZ(pick)) > 10 Or Abs(CX(Here) - CX(pick)) > 2 Or Abs(CY(Here) - CY(pick)) > 2 Then
		Tool 0
		Move Here :Z(600)
		Return_code$ = "ERR;Postion"
		Exit Function
	EndIf

	Print "組裝完成"
	Tool 0
	Off Vacuum_CL
	Move LJM(pick :Z(CZ(Here)))
	Move LJM(pick +Z(Thick_Conveyor))
	If (Grip_Close_Out = False) Then
		Exit Function
	EndIf
	Call DefSpeed
	Move Here +Z(50)
	Move LJM(Safe_point_Put_under)
	TC Off
	Go LJM(check_one)
	Return_code$ = "RunFinish;READ"
	Wait 0.5
	Print Return_code$
	MemOff 1
	Exit Function
	handle:
		Quit SafeSensor
		Print "Error READ"
		Print "ERR:", Err
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(206) > 0 Then
			Print 206, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
	MemOff 1
Fend
Function MoveToTwocheck '二次檢測
	OnErr GoTo handle
	TC Off
	Tool 0
	If (CY(Here)) < 10 Then
		Tool 0
		Call SlowSpeed
		Move Here :Z(600)
		Move LJM(SafePointPut_AS :Z(600))
		Move LJM(palletup :Z(600))
		Print "ERR;Postion"
	EndIf
	If (Abs(CZ(Here) - CZ(check_one) > 10 Or Abs(CX(Here) - CX(check_one)) > 5 Or Abs(CY(Here) - CY(check_one)) > 5)) Then
		Tool 0
		Move Here :Z(600) CP
		Move LJM(check_one +Z(50)) CP
		Return_code$ = "ERR;Postion"
		Print Return_code$
	EndIf
	Move LJM(check_two)
	Return_code$ = "RunFinish;CTWO"
	Exit Function
	handle:
		Print "Error CTWO"
		Print "ERR:", Err
		If ChkNet(212) > 0 Then
			Print #212, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function MoveToPut_Out 'OK
	If PUT_Step = True Then
		Return_code$ = "RunFinish;PUTP;" + ex_product$ + ";" + ex_j$
		Print Return_code$
	EndIf
Fend
Function MoveToSpecifyPut_Out(ByRef Specify_num As Integer) 'OK
	j = Specify_num
	If PUT_Step = True Then
		Return_code$ = "RunFinish;SYPU;" + ex_product$ + ";" + ex_j$
		Print Return_code$
	EndIf
Fend
Function PUT_Step As Boolean
	OnErr GoTo handle
	TC Off
	PUT_Step = False
	IsBuzy = True
	Tool 0
	If (CY(Here)) < 10 Then
		Tool 0
		Call SlowSpeed
		Move Here :Z(600)
		Move LJM(SafePointPut_AS :Z(600))
		Move LJM(palletup :Z(600))
		Print "ERR;Postion"
	EndIf
	If Abs(CZ(Here) - CZ(check_one)) > 10 Or Abs(CX(Here) - CX(check_one)) > 10 Or Abs(CY(Here) - CY(check_one)) > 10 Then
		Tool 0
'		If Sw(DI_Senosr_Pick) = Off Then
'			Return_code$ = "ERR,SENSOR" '回傳偵測失敗
'			Exit Function
'		EndIf
		Move Here :Z(600)
		Go LJM(check_one :Z(600))
		Print Return_code$
	EndIf
	If CZ(Here) < 480 Then
		Move Here :Z(500) CP
	EndIf
	Go LJM(palletup) CP
	Go LJM(Pallet(product, j) +Z(30)) CP
	SpeedS 50
	Move LJM(Pallet(product, j) +Z(5 + Thick_Platform))
	TC On
	Move LJM(Pallet(product, j) +Z(2 + Thick_Platform))
	Print "品種:", Str$(product), ",第", Str$(j), "個"
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	On Vacuum_CL
	If (Grip_Open_Out = False) Then
		SpeedS SP_SDef
		Move Here +Z(50)
		TC Off
		Off Vacuum_CL
		j = j + 1 '瑪垛+1
		If j > y * x Then '瑪垛回到1
			j = 1
		EndIf
		Go LJM(palletup)
		PUT_Step = False
		Exit Function
	EndIf
	SpeedS SP_SDef
	Move Here +Z(50)
	TC Off
	Off Vacuum_CL
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Go LJM(palletup)
	PUT_Step = True
	Exit Function
	handle:
		Print "ERR:", Err
		Print "ERR:", Err(1)
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(206) > 0 Then
			Print 206, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function MoveToPick_only
	Tool 0
	TC Off
	IsBuzy = True
	Tool 0
	If (CY(Here)) < 10 Then
		Tool 0
		Call SlowSpeed
		Move Here :Z(600)
		Move LJM(SafePointPut_AS :Z(600))
		Print "ERR;Postion"
	EndIf
	If Abs(CZ(Here) - CZ(Safe_point_Put_under)) > 10 Or Abs(CX(Here) - CX(Safe_point_Put_under)) > 10 Or Abs(CY(Here) - CY(Safe_point_Put_under)) > 10 Then
		Tool 0
		Move Here :Z(600)
        Go LJM(SafePointPut_AS :Z(600))
		Go LJM(CCD2Test)
		Go LJM(Safe_point_Put_under)
		Print "ERR;Postion"
	EndIf
	Move LJM(pick +Z(30))
	Move LJM(pick +Z(Thick_Conveyor))
	If (Grip_Close_Out = False) Then
		Exit Function
	EndIf
	Call DefSpeed
	Move Here +Z(50)
	Move LJM(Safe_point_Put_under)
	Go LJM(check_one)
	If Abs(CZ(Here) - CZ(check_one)) > 10 Or Abs(CX(Here) - CX(check_one)) > 10 Or Abs(CY(Here) - CY(check_one)) > 10 Then
		Move Here :Z(600)
		Move LJM(check_one :Z(600))
		Print Return_code$
	EndIf
	Go LJM(palletup) CP
	Go LJM(Pallet(product, j) +Z(30)) CP
	SpeedS 50
	Move LJM(Pallet(product, j) +Z(5 + Thick_Platform))
	TC On
	Move LJM(Pallet(product, j) +Z(2 + Thick_Platform))
	Print "品種:", Str$(product), ",第", Str$(j), "個"
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	On Vacuum_CL
	If (Grip_Open_Out = True) Then
		Print "放料完成"
	EndIf
	SpeedS SP_SDef
	Move LJM(Pallet(product, j) +Z(30))
	TC Off
	Off Vacuum_CL
	j = j + 1 '瑪垛+1
	If j > y * x Then '瑪垛回到1
		j = 1
	EndIf
	Go LJM(palletup)
	Return_code$ = "RunFinish;PUTO;" + ex_product$ + ";" + ex_j$
	Exit Function
	handle:
		Print "Error occer"
		Print "ERR:", Err
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(206) > 0 Then
			Print 206, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function GoHome_Out '復歸
	'Robot 3
	TC On
	Speed 20
	SpeedS 40
	IsBuzy = True
	Print "當前高度:", CZ(Here)
	If CZ(Here) < 550 Then
		Move Here +Z(50)
		Go Here :Z(600)
	ElseIf CZ(Here) < 600 Then
		Move Here :Z(600)
	EndIf
	Home
	Power High
	Call DefSpeed
	Return_code$ = "RunFinish;HOME"
	TC Off
	Print Return_code$
Fend
Function tcpipcmd_Out
	Integer product_tcpip
	OnErr GoTo handle
	If False Then
		handle:
			Print "Error occer"
			Print "ERR:", Err
			If ChkNet(206) > 0 Then
				Print 206, "ERR;", Err
			EndIf
		Reset
		Power High
		Call DefSpeed
	EndIf
	Do
		 OpenNet #206 As Server
		 WaitNet #206, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #206 Connected"
		 	Do
            	If (PauseOn = True Or SafetyOn = True) Then
            		If ChkNet(206) > 0 Then
				 		Line Input #206, cmd_plu$
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks12$(0)
			 					ParseStr cmd_plu$, toks12$(), ";"
			 					Select toks12$(0)
						 		Case "Resume"
							 		Print #206, "Resume"
							 		Print "Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #206, "ERR;Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
            	Else
				 	If (ChkNet(206) > 0 And IsBuzy = False) Then '連線埠有資料
				 		If Pass_Tcpip = False Then
				 			Line Input #206, cmd$
				 		EndIf
				 		If Power = 0 Then
							Power High
						EndIf
					 	If cmd$ <> "" And TaskInfo(4, 3) <> 1 And TaskInfo(6, 3) <> 1 Then
				 			Print "received '", cmd$, "' from PC"
				 			String toks1$(0)
				 			ParseStr cmd$, toks1$(), ";"
	                        Select toks1$(0)
				 			'Select Left$(cmd$, 4) '讀1-4
				 				Case "PROD" '讀產品
				 					'Print #206, "cmd;received;", toks1$(0)
				 					product_tcpip = Val(toks1$(1))
	                                Call Product_Pick_Out(ByRef product_tcpip)
				 				Case "PICK" '取料等待組裝
				 					'Print #206, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call MovetoPick_Out
				 						'Call MovetoPick_TEST_Out
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "SYPU" '指定放料
				 					'Print #206, "cmd;received;", toks1$(0)
				 					product_tcpip = Val(toks1$(1))
				 					If product_load = True And (0 < product_tcpip <= int_TotalXY) Then
				 						j = product_tcpip
				 						'Print #206, "RunFinish;SYPU;" + Str$(product) + ";" + Str$(j)
				 						Return_code$ = "RunFinish;SYPU;" + Str$(product) + ";" + Str$(j)
				 						'Call MoveToSpecifyPut_Out(ByRef product_tcpip)
				 					Else
				 						If product_load = False Then
				 							Return_code$ = "ERR;Product No Load"
				 						Else
				 							Return_code$ = "ERR;Specify_num is not true"
				 						EndIf
				 					EndIf
				 				Case "READ" '組裝到掃碼
				 					'Print #206, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Xqt 4, MoveToAssemble
				 						MemOn 1
				 						Wait MemSw(1) = Off
				 						'Call MoveToAssemble2TEST
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "PUTO" '取料放料
				 					'Print #206, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call MoveToPick_only
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "PUTP" '放料
				 					'Print #206, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call MoveToPut_Out
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "HOME" '復歸
				 					'Print #206, "cmd;received;", toks1$(0)
				 					Call GoHome_Out
	'			 				Case "CTWO" '2次定位
	'			 					'Print #206, "cmd;received;", toks1$(0)
	'			 					If product_load = True Then
	'			 						Call MoveToTwocheck
	'			 					Else
	'			 						Return_code$ = "ERR;Product No Load"
	'			 					EndIf
								Case "SetShift"
		                           '' 'Print #206, "cmd;received;", toks1$(0)
					 				Return_code$ = "SETSHIFT"
					 				Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)), Val(toks1$(7)), Val(toks1$(8)))
					 			Case "GetShift"
					 				'Print #206, "cmd;received;", toks1$(0)
					 				Call Get_XYZU
			 					Case "Paus"
				 				   Print #206, "cmd;Pause;" + Str$(TaskInfo(4, 3))
				 				   Halt 4
				 				Case "Resu"
				 				   Print #206, "cmd;Resu;" + Str$(TaskInfo(4, 3))
				 				   Resume 4
				 				Case "CCDOFFSET"
				 					'Print #206, "cmd;received;", toks1$(0)
				 					X_LOWER = Val(toks1$(1)); X_UPPER = Val(toks1$(2))
                                    Y_LOWER = Val(toks1$(3)); Y_UPPER = Val(toks1$(4))
                                    U_LOWER = Val(toks1$(5)); U_UPPER = Val(toks1$(6))
                                    Return_code$ = "RunFinish;CCDOFFSET"
                                Case "CCD_OFFSET2"
				 					'Print #206, "cmd;received;", toks1$(0)
				 					X_LOWER2 = Val(toks1$(1))
                                    Y_LOWER2 = Val(toks1$(2))
                                    U_LOWER2 = Val(toks1$(3))
                                    Return_code$ = "RunFinish;CCDOFFSET"
				 				Case "TKIF"
				 					If (TaskInfo(4, 3)) < 1 Then Print #204, "Task;NotRun"
				 					If (TaskInfo(4, 3)) = 1 Then Print #204, "Task;Run"
									If (TaskInfo(4, 3)) = 2 Then Print #204, "Task;Wait"
									If (TaskInfo(4, 3)) = 3 Then Print #204, "Task;Pause"
									If (TaskInfo(4, 3)) = 4 Then Print #204, "Task;Stop"
									If (TaskInfo(4, 3)) = 5 Then Print #204, "Task;Error"
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
				 					Print #206, "ERR;Cmd_NotFound"
				 			Send
				 			
					 	cmd$ = ""
	                    EndIf
				 	EndIf
			 		If TaskInfo(4, 3) <> 1 And TaskInfo(6, 3) <> 1 Then
				 		IsBuzy = False
				 	EndIf
				 	If Return_code$ <> "" And (IsBuzy = False Or CZ(Here) > 500) Then
			 			Wait 1
			 			Print #206, Return_code$
			 		'	Print Return_code$
			 			Return_code$ = ""
			 		EndIf
				 	If ChkNet(206) = -3 Then
				 		CloseNet #206
				 		Print "Disconnected"
				 		Exit Do
				 	EndIf
				 EndIf
			 Loop
		 EndIf
	Loop
Fend
Function PG_Set
	Real rtrqT(6)
	rtrqT(1) = 100; rtrqT(2) = 100; rtrqT(3) = 100; rtrqT(4) = 100; rtrqT(5) = 100; rtrqT(6) = 100
	LimitTorque rtrqT(1), rtrqT(2), rtrqT(3), rtrqT(4), rtrqT(5), rtrqT(6)
	Print "設定高功率扭矩:", LimitTorque(1), LimitTorque(2), LimitTorque(3), LimitTorque(4), LimitTorque(5), LimitTorque(6)
	LimitTorqueStop On
Fend
Function PG_Show
	Print "顯示目前高功率扭矩:", LimitTorque(1), LimitTorque(2), LimitTorque(3), LimitTorque(4), LimitTorque(5), LimitTorque(6)
Fend
'Function MovetoPick_TEST_Out '組裝T
'	OnErr GoTo handle
'	IsBuzy = True
'	Call DefSpeed
'	Tool 0
'	P(500) = palletup
'	If Abs(CZ(Here) - CZ(P(500))) > 10 Or Abs(CX(Here) - CX(P(500))) > 10 Or Abs(CY(Here) - CY(P(500))) > 10 Then
'		Tool 0
'		Move Here :Z(600)
'		Go P(500) :Z(600)
'		Print "ERR,Postion"
'	EndIf
'	
'	If Sw(DI_Senosr_Pick) = On Then
'		Return_code$ = "ERR,SENSOR" '回傳偵測失敗
'		Exit Function
'	EndIf
'	If (Grip_Open_Out = False) Then
'		Exit Function
'	EndIf
'	
'	Go (SafePointPut_AS :Z(600)) CP
'	Go (pick_assembled :Z(600)) CP
'	Go LJM(pick_assembled +Z(20)) CP
'	SpeedS 40
'    Move LJM(pick_assembled)
'	SpeedS SP_SDef
'	Wait Sw(DI_Senosr_Pick) = On, 2
'	If TW = True And Grip_Pass = False Then
'		Move Here :Z(600)
'		Return_code$ = "ERR,SENSOR" '回傳偵測失敗
'		Exit Function
'	EndIf
'	Off Vacuum_CL
'	On Vacuum_OP '吸氣
'	Wait Sw(DI_Vacuum) = On, 2
'	If TW = True And Vacuum_Pass = False Then
'		Move Here :Z(600)
'		Return_code$ = "ERR,VACCUM_OP" '回傳真空失敗
'		Exit Function
'	EndIf
'	Wait 0.2
'	Move Here :Z(600)
'	Go (SafePointPut_AS :Z(600)) CP
'
'	Go LJM(CCD2Test)
'	Wait 0.5
' 	Boolean found
' 	Real CCDU2
' 	VRun SEaL_CCD2_ASSE '執行相機拍照
'	VGet SEaL_CCD2_ASSE.Point01.RobotXYU, found, ccdX, ccdY, ccdU
' 	VGet SEaL_CCD2_ASSE.Geom01.Angle, CCDU2
'	If found = True Or Ccd_Pass = True Then  '有找到物件
'		If CCDU2 > 180 Then
'			CCDU2 = CCDU2 - 360
'		EndIf
'		Local 1, XY(ccdX, ccdY, 0, CCDU2)
' 		Print " X:	", ccdX, "	Y:	", ccdY, "	U:	", CCDU2
'	Else
'	 	Return_code$ = "ERR,FOUND" '回傳拍照失敗 	
'		Print Return_code$
'	 	Exit Function
'	EndIf
'	Tool 0
'	Go LJM(put_assembled2Test :Z(500))
'	Return_code$ = "RunFinish,PICK,X is:" + Str$(ccdX) + "Y is:" + Str$(ccdY) + "U is:" + Str$(CCDU2)
'	Print Return_code$
'	Exit Function
'	handle:
'		Print "Error MovetoPick_TEST_Out"
'		Print "ERR:", Err
'		If ChkNet(212) > 0 Then
'			Print #212, "ERR:", Err
'		EndIf
'	Reset
'Fend
'Function MoveToAssemble2TEST '組裝取料到掃碼T
'	OnErr GoTo handle
'	IsBuzy = True
'	Tool 0
'	'P40 = Here @1
'	If Abs(CZ(Here) - CZ(Safe_point_Put_under)) > 10 Or Abs(CX(Here) - CX(Safe_point_Put_under)) > 10 Or Abs(CY(Here) - CY(Safe_point_Put_under)) > 10 Then
'		Tool 0
'		If Sw(DI_Senosr_Pick) = Off Then
'			Return_code$ = "ERR,SENSOR,READ" '回傳偵測失敗
'			Exit Function
'		EndIf
'		Move Here :Z(600)
'		
'		Tool 0
'		Move (Safe_point_Put_under :Z(600))
'		Move Safe_point_Put_under
'		Print "ERR,Postion"
'	EndIf
'	Tool 0
'	Xqt SafeSensor
'	Move LJM(put_assembled2Test +Z(25))
'	SpeedS 20
'	AccelS 20, 100
'    Move LJM(put_assembled2Test +Z(2 + Thick_Conveyor))
'    Quit SafeSensor
'	On Vacuum_CL
'	Off Vacuum_OP '吸氣
'	Wait Sw(DI_Vacuum) = Off, 2
'	If TW = True And Vacuum_Pass = False Then
'		Return_code$ = "ERR,VACCUM_CL" '回傳真空失敗
'		Exit Function
'	EndIf
'	Call DefSpeed
'	Move Here +Z(30)
'	Print "組裝完成"
'	Tool 0
'	Move LJM(pick +Z(20)) CP
'	Off Vacuum_CL
'	Move LJM(pick +Z(Thick_Conveyor))
'	If (Grip_Close_Out = False) Then
'		Exit Function
'	EndIf
'	Move Here :Z(550)
''	Go LJM(check_one +Z(30)) CP
'	Go LJM(check_one)
'	Return_code$ = "RunFinish,READ"
'	Print Return_code$
'	Exit Function
'	handle:
'		Print "Error READ"
'		Print "ERR:", Err
'		If ChkNet(212) > 0 Then
'			Print #212, "ERR:", Err
'		EndIf
'	Reset
'Fend

