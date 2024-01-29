Global Integer i, j, x, y, SP_SDef, SP_Def, start_pt, end_pt, Speed_CR, Speed_LN, Start_move, Now_product
Global String cmd$, Return_code$, cmd_plu$, str_seq$
Global Boolean IsBuzy, Ccd_Pass, Glued_Pass, product_load, Pass_Tcpip, test_mode, Pass_Have
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform, Standard_ccd_U, Standard_ccd_X, Standard_ccd_Y
Global Double MiD_XX, MiD_YY, Out_side_X, Out_side_Y, Glued_mid_X, Glued_mid_Y
Global Preserve Real Glue_Time
Function main
	'V1.3SG
	Reset
	'-------	
	Motor On
'	ThreeT = 0; agv_result = False
	Wait Motor = On
	Power High
'	Speed 3; 	Accel 3, 3
'	SpeedS 50; 	AccelS 300, 300
	OnErr GoTo handle
'====Tool Setting===============================================================
	'�]�mTool�����q�M�D�ʰѼ�
	'Inertia [�t���D��]kgm^2, [���߲v]mm
	LoadPoints "robot1.pts"
	Tool 0
	Weight 2.5
	Inertia 0.05, 40
	SetNet #205, "192.168.0.25", 2000, CRLF, NONE, 0, TCP
	IsBuzy = False
	product_load = False
	'--------�򥻳]�w
	Call DefSpeed
	'----------���ե\��
'	Ccd_Pass = True '�۾��˴�PASS
'	Glued_Pass = True '�����PASS
	'Pass_Tcpip = True
	Pass_Have = True '�Ѿl�����˴�PASS
	If Glue_Time < 1 Then
		Glue_Time = 1
	EndIf
	Integer re0
	re0 = 0
	Call Product_Setting(re0)
	Return_code$ = ""
	'----------
	Off DO_Spit_OP
	On DO_Spit_CL
	Off Glued
'	Xqt Pause_RESET, NoPause
'	Xqt Altitude_Detection
	Xqt 2, tcpipcmd_Gld, NoPause
	Exit Function
	handle:
		Print "Error occer"
		Print "ERR:", SysErr
		Return_code$ = "ERR;" + Str$(SysErr)
			If ChkNet(205) > 0 Then
				Print 205, "ERR;", SysErr
			EndIf
		If ChkNet(211) > 0 Then
			Print #211, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function Altitude_Detection
	If Sw(Glued_have) = Off Then
		Print #205, "WARRING;Insufficient Glued"
	EndIf
Fend
Function Pause_RESET
	Do
        If (PauseOn = True Or SafetyOn = True) Then 'And ChkNet(201) <> -2 
     		Print "�Ȱ�", ChkNet(205), PauseOn, SafetyOn
		 	If TW = True Then
		 		Print "Time Out"
		 	Else
		 		Do

			 		If ChkNet(205) > 0 Then '�s�u�𦳸�� Or Pass_Tcpip = True	
				 		Line Input #205, cmd_plu$
				 		Wait 1
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks1$(0)
			 					ParseStr cmd_plu$, toks1$(), ";"
			 					Select toks1$(0)
						 		Case "Resume"
							 		Print #205, "Resume"
							 		Print "ERROR Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #205, "ERR,Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
		 		Loop While (PauseOn = True Or SafetyOn = True)
		 	EndIf
		EndIf
	Loop
Fend
Function Product_Setting(product_local As Integer)
	product_load = False
	IsBuzy = True
	Integer I_pd, pp
	Thick_Conveyor = 0 '��e�a��u�󪺰���
	Thick_Platform = 0 '���x��u�󪺰���
	I_pd = 0
	Select product_local 'Ū�����~�s��
		Case 0
			str_seq$ = "CCD_PL" '�۾��˴��ǦC
			Standard_ccd_X = -230.261 'X�зǭ�
			Standard_ccd_Y = 274.479 'Y�зǭ�
			Standard_ccd_U = 258.48 'U�зǭ�
			Out_side_Y = 1 'Y��V�~�X�Z��
			Out_side_X = 0.3 'X��V�~�X�Z��
			start_pt = 100; end_pt = 123;  Start_move = 200; Speed_CR = 2000; Speed_LN = 40
			'start_pt:���~�_�l�I��;end_pt:���~���|���I;Speed_CR:���s�t��;Speed_LN:���u�t��
			'���u�P���u�̤j�t��2000
			
			product_load = True
		Case 1
			str_seq$ = "CCD_PL" '�۾��˴��ǦC
			Standard_ccd_X = -230.261 'X�зǭ�
			Standard_ccd_Y = 274.479 'Y�зǭ�
			Standard_ccd_U = 258.48 'U�зǭ�
			Out_side_Y = 1 'Y��V�~�X�Z��
			Out_side_X = 0.3 'X��V�~�X�Z��
			start_pt = 100; end_pt = 123;  Start_move = 200; Speed_CR = 2000; Speed_LN = 40
			'start_pt:���~�_�l�I��;end_pt:���~���|���I(���]�A�T���u�ΤW�褤�I);Speed_CR:���s�t��;Speed_LN:���u�t��
			'���u�P���u�̤j�t��2000
			
			product_load = True
		Case 2
			str_seq$ = "CCD_PL"
			Standard_ccd_U = 155.5
			Standard_ccd_X = -231.8
			Standard_ccd_Y = 274.4
			Out_side_Y = 1
			Out_side_X = 0.3
			start_pt = 130; end_pt = 153;  Start_move = 200; Speed_CR = 2000; Speed_LN = 40

			product_load = True
	Send
	

	
	If product_load = True Then
		Now_product = product_local
			Glued_mid_X = (CX(P(start_pt)) + CX(P(start_pt + 10))) / 2
			Glued_mid_Y = (CY(P(start_pt)) + CY(P(start_pt + 10))) / 2
			For pp = start_pt To end_pt
				P(Start_move + I_pd) = XY(CX(P(pp)) - CX(P(start_pt)) - Glued_mid_X, CY(P(pp)) - CY(P(start_pt)) - Glued_mid_Y, CZ(P(300 + Now_product)), 0) /7
				I_pd = I_pd + 1
			Next

		Return_code$ = "RunFinish,PROD," + Str$(product_local)
	Else
		Return_code$ = "ERR,PROD"
		
	EndIf
	IsBuzy = False
	Print Return_code$
Fend
Function Set_XYZU(Offset_X As Real, Offset_Y As Real, Offset_Z As Real, Offset_U As Real)
	If Now_product >= 0 Then
		P(600 + Now_product) = XY(Offset_X, Offset_Y, Offset_Z, Offset_U) '�ɥ��x�s�b(600+���~�s��)�W
		SavePoints "robot1.pts"
		Return_code$ = "SETSHIFT;" + Str$(CX(P(600 + Now_product))) + ";" + Str$(CY(P(600 + Now_product))) + ";" + Str$(CZ(P(600 + Now_product))) + ";" + Str$(CU(P(600 + Now_product)))
	EndIf
Fend
Function Get_XYZU
	Return_code$ = "GETSHIFT;" + Str$(CX(P(600 + Now_product))) + ";" + Str$(CY(P(600 + Now_product))) + ";" + Str$(CZ(P(600 + Now_product))) + ";" + Str$(CU(P(600 + Now_product)))
Fend
Function MovetoSpit_Gld '�R��
	OnErr GoTo handle
	Tool 1
	If Pass_Have <> True Then
		Call Altitude_Detection
	EndIf
	Jump Sptipoint
	Off DO_Spit_CL
	On DO_Spit_OP

	If Glued_Case = False Then
		Off DO_Spit_CL
		Off DO_Spit_OP
		Exit Function
	EndIf
	Wait 1
	If GluedClose_Case = False Then
		Off DO_Spit_OP
		On DO_Spit_CL
		Exit Function
	EndIf
	Wait Glue_Time
	On DO_Spit_CL
	Off DO_Spit_OP
	Tool 0
	Jump Here :Z(-1)
	Return_code$ = "RunFinish,SPIT,"
	Print Return_code$
	Exit Function
		handle:
			Off DO_Spit_OP
			On DO_Spit_CL
			Off Glued
			Print "Error occer"
			Print "ERR:", SysErr, ",GLUE"
			If ChkNet(211) > 0 Then
				Print #211, "ERR:", SysErr
			EndIf
		Reset
		Power High
		Call DefSpeed
Fend
Function Glued_Case As Boolean
		Glued_Case = True
		On Glued
		Wait Sw(DI_Glued_OP) = On, 3
		If TW = True And Glued_Pass = False Then
			Off Glued
			Glued_Case = False
			Move Here :Z(0)
			Return_code$ = "ERR,GLUED_Open" '�^�Ƕ����		
			Exit Function
		EndIf
		Wait 0.05
Fend
Function GluedClose_Case As Boolean
		GluedClose_Case = True
		Off Glued
		Wait Sw(DI_Glued_OP) = Off, 2
		If TW = True And Glued_Pass = False Then
			Off Glued
			GluedClose_Case = False
			Move Here :Z(0)
			Return_code$ = "ERR,GLUED_Close" '�^�Ƕ����		
			Exit Function
		EndIf
		'Wait 0.1
Fend
Function Move_OnTable
	Integer Table_GapX, Table_GapY '���C
	Integer Speed_Tb_LN, Speed_Tb_Move '���u��t�׸�D��t��
	Double Table_X, Table_Y '�C�Ӥu��X��Y�����j
	SpeedS 50 '�̰��t��
	AccelS 500, 500 '�[�t�� ��t��
	Speed_Tb_LN = 20 'Speed_Tb_LN =��t��
	Table_X = 95.3; Table_Y = 80.4; Speed_Tb_Move = 50
	For Table_GapY = 0 To 1 Step 1
		For Table_GapX = 0 To 2 Step 1
        Jump Table_first +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY)
        SpeedS Speed_Tb_LN
		Call Glued_Case
		Move Table_first_fin +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY) -Y(2) ! D90; Off Glued !
		Move Here +Z(10)
		SpeedS Speed_Tb_Move
		'Call GluedClose_Case
		Jump Table_second +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY)
		SpeedS Speed_Tb_LN
		Call Glued_Case
		Move Table_second_fin +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY) -Y(2) ! D90; Off Glued !
		Move Here +Z(10)
		SpeedS Speed_Tb_Move
		'Call GluedClose_Case
		Jump Table_thried +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY)
		SpeedS Speed_Tb_LN
		Call Glued_Case
		Move Table_thried_fin +X(Table_X * Table_GapX) +Y(Table_Y * Table_GapY) -Y(2) ! D90; Off Glued !
		Move Here +Z(10)
		SpeedS Speed_Tb_Move
		'Call GluedClose_Case
		Next
	Next
	Jump CCD_PL
	Call DefSpeed '80.4 95.3
	Exit Function
	handle:
		Off Glued
		Print "Error GLUE"
		Print "ERR;", Err, ";GLUE"
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(205) > 0 Then
			Print 205, "ERR;", Err
		EndIf

	Reset
	Power High
	Call DefSpeed
Fend
Function Move_OnTable2
	Integer Table_GapX, Table_GapY, T_x, T_y, T_z '���C
	Integer Speed_Tb_LN, Speed_Tb_Move '���u��t�׸�D��t��
    Integer T_Strip '�X���u
	Double Table_X, Table_Y '�C�Ӥu��X��Y�����j
	Double T_Spacing, T_Offset '�C���u���Z,�����h�ֶ}�l
	SpeedS 50 '�̰��t��
	AccelS 500, 500 '�[�t�� ��t��
	Call DefSpeed
	Speed_Tb_LN = 20; Speed_Tb_Move = 50
    Table_X = 95.3; Table_Y = 80.4; T_Offset = 0.5; T_Spacing = 0.2
    Table_GapY = 2; Table_GapX = 3; T_Strip = 1
    If T_Strip <= 0 Then
    	Print "ERR;", Err, ";GLUE"
    	Exit Function
    EndIf
  	Tool 1
	For T_x = 0 To (Table_GapX - 1) Step 1
		For T_y = 0 To (Table_GapY - 1) Step 1
        	For T_z = 0 To (T_Strip - 1)
	            Jump Table_first +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y)
		        SpeedS Speed_Tb_LN
				Call Glued_Case
	            Move Table_first_fin +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y) ! D90; Off Glued !
				Move Here +Z(10)
				SpeedS Speed_Tb_Move
				'Call GluedClose_Case
			Next
			For T_z = 0 To (T_Strip - 1)
	            Jump Table_second +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y)
				SpeedS Speed_Tb_LN
				Call Glued_Case
	            Move Table_second_fin +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y) ! D90; Off Glued !
				Move Here +Z(10)
				SpeedS Speed_Tb_Move
				'Call GluedClose_Case
			Next
			For T_z = 0 To (T_Strip - 1)
	            Jump Table_thried +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y)
				SpeedS Speed_Tb_LN
				Call Glued_Case
	            Move Table_thried_fin +X(Table_X * T_x - T_Offset + T_z * T_Spacing) +Y(Table_Y * T_y) ! D90; Off Glued !
				Move Here +Z(10)
				SpeedS Speed_Tb_Move
				'Call GluedClose_Case       
			Next
		Next
	Next
	Tool 0
	Jump CCD_PL
	Call DefSpeed '80.4 95.3
	Exit Function
	handle:
		Off Glued
		Print "Error GLUE"
		Print "ERR;", Err, ";GLUE"
		Return_code$ = "ERR;" + Str$(Err)
		If ChkNet(205) > 0 Then
			Print 205, "ERR;", Err
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function Move_OnTable3(PD_TB As Int32) 'X���� Y����'�C�Ӥu��X��Y�����j
	Integer Table_GapX, Table_GapY, T_x, T_y '���C
	Integer Speed_Tb_LN, Speed_Tb_Move '���u��t�׸�D��t��
	Double X_Length, Y_Length	'1.2 X��Y��Z��
	Double Table_X, Table_Y '3.4 �C�Ӥu��X��Y�����j
	SpeedS 50 '�̰��t��
	AccelS 500, 500 '�[�t�� ��t��
	Call DefSpeed
	Speed_Tb_LN = 30; Speed_Tb_Move = 100
	X_Length = 37; Y_Length = 29.9 'X��Y��Z��
	Table_X = 90; Table_Y = 51.8; '�C�Ӥu��X��Y�����j
    Table_GapY = 2; Table_GapX = 3; '���C
    Table_free = P(280 + PD_TB)
    Tool 1
	For T_x = 0 To (Table_GapX - 1) Step 1
		For T_y = 0 To (Table_GapY - 1) Step 1
	            Jump Table_free +X(Table_X * T_x) +Y(Table_Y * T_y) +Z(1) '���U�}�l
		        SpeedS Speed_Tb_LN
		        Move Table_free +X(Table_X * T_x) +Y(Table_Y * T_y)
		        CP On
				Call Glued_Case
				Wait 0.1
	            Move Here +Y(Y_Length)
				'Call Glued_Case
	            Move Here +X(X_Length)
	            'Call Glued_Case
	            Move Here -Y(Y_Length)
	            'Call Glued_Case
	            Move Here -X(X_Length)
				SpeedS Speed_Tb_Move
				Call GluedClose_Case
				CP Off
				Move Here :Z(-1)
		Next
	Next
	Tool 0
	Jump CCD_PL
	Call DefSpeed
	Return_code$ = "RunFinish;MANUALGLUE"
	Exit Function
	handle:
		Off Glued
		Tool 0
		Jump Here(-1)
		Print "Error GLUE"
		Print "ERR;", SysErr, ";GLUE"
		Return_code$ = "ERR;" + Str$(SysErr)
		If ChkNet(205) > 0 Then
			Print 205, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function Move_Test_Glued '�
	Tool 1
	OnErr GoTo handle
	Off Glued
	If Pass_Have <> True Then '�L�˴�����PASS�h�T�{����
		Call Altitude_Detection
	EndIf
	'�}�l� 		
	Boolean found, found2, found3
	Real xx, yy, uu
	Call DefSpeed
	Real Line_high; '�e�T���u�U������
	'�]�w����
	Tool 0
	Jump LJM(CCD_PL)
	Wait 0.5
	VRun str_seq$
	VGet str_seq$.Point01.RobotXYU, found, xx, yy, uu
	'wei
	xx = xx + 1.543
	yy = yy + 0.122
	If found = True Then
	
		VGet str_seq$.LineFind02.Angle, uu
		Print "U:", uu
		uu = Standard_ccd_U - uu
		If Abs(uu) > 1 And Abs(Abs(xx) - Abs(Standard_ccd_X)) > 5 And Abs(Abs(yy) - Abs(Standard_ccd_Y)) > 5 Then
			Print "ERR;XYU>;", uu
			VRun str_seq$
			VGet str_seq$.Point01.RobotXYU, found, xx, yy, uu
			'wei
			xx = xx + 1.543
			yy = yy + 0.122
			If found = True Then
				VGet str_seq$.LineFind02.Angle, uu
				uu = uu - Standard_ccd_U
				If Abs(uu) > 1 And Abs(Abs(xx) - Abs(Standard_ccd_X)) > 5 And Abs(Abs(yy) - Abs(Standard_ccd_Y)) > 5 Then
					Print "ERR;XYU>;", uu
					Return_code$ = "ERR;CCDERROR;U_is_More"
					Exit Function
				EndIf
			Else
				Print "Vision fail"
				Off Glued
				Return_code$ = "ERR;CCDERROR"
				Exit Function
			EndIf
	EndIf

	Print "X:", xx, ";Y:", yy, ";U:", uu '�۾��ɥ�+���I(���~���I300+�{�b���~�s��(EX:�{�b�O���~1,�N�O300+1=301))
       Local 7, XY(xx + CX(P(300 + Now_product)) + Glued_mid_X, yy + CY(P(300 + Now_product)) + Glued_mid_Y, 0, 0)
		Tool 1
		Select Now_product
			Case 0
				Line_high = 0.9
				Jump LJM(P(Start_move + 20) +Y(1) +Z(0) :U(0)) CP '��_�l��m�A���_�l�I�O���I����I������
				Move LJM(P(Start_move + 20) +Y(1) +Z(Thick_Conveyor))
		    	AccelS Speed_CR, Speed_CR '�[��t���ɨ�ֱ̧o�����u
				CP On '�}�ҳs��ʧ@
				If Glued_Case = False Then '�}�l�
					Exit Function
				EndIf
				SpeedS Speed_LN '���u�t��
		        Move LJM(P(Start_move) +X(Out_side_Y / 2) +Y(Out_side_Y) +Z(Thick_Conveyor)) '�q�_�l��m�����I�}�l�
				SpeedS Speed_CR '���s�t��
                Arc LJM(P(Start_move + 1) +Y(0.3) +Z(Thick_Conveyor)), LJM(P(Start_move + 2) +X(Out_side_X) +Y(0.3) +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		        Arc LJM(P(Start_move + 3) -X(0.2) +Z(Thick_Conveyor)), LJM(P(Start_move + 4) -X(Out_side_X / 2) +Z(Thick_Conveyor))
				SpeedS Speed_LN
		        Move LJM(P(Start_move + 5) -X(Out_side_X / 2) +Z(Thick_Conveyor))
				SpeedS Speed_CR
		        Arc LJM(P(Start_move + 6) -X(Out_side_X / 2) +Z(Thick_Conveyor)), LJM(P(Start_move + 7) -X(Out_side_X) -Y(0.3) +Z(Thick_Conveyor)) '+0.5
		        Arc LJM(P(Start_move + 8) -Y(0.3) +Z(Thick_Conveyor)), LJM(P(Start_move + 9) -Y(Out_side_Y) +Z(Thick_Conveyor)) '+0.5
				SpeedS Speed_LN
				Move LJM(P(Start_move + 10) -X(Out_side_Y / 2) -Y(Out_side_Y) +Z(Thick_Conveyor))
				SpeedS Speed_CR
		        Arc LJM(P(Start_move + 11) -Y(0.3) +Z(Thick_Conveyor)), LJM(P(Start_move + 12) -X(0.1) -Y(0.3) +Z(Thick_Conveyor))
		        Arc LJM(P(Start_move + 13) +X(0.1) +Z(Thick_Conveyor)), LJM(P(Start_move + 14) +X(Out_side_X / 2) +Z(Thick_Conveyor))
				SpeedS Speed_LN
				Move LJM(P(Start_move + 15) +X(Out_side_X / 2) +Z(Thick_Conveyor))
				SpeedS Speed_CR
		        Arc LJM(P(Start_move + 16) +X(Out_side_X / 2) +Z(Thick_Conveyor)), LJM(P(Start_move + 17) +X(Out_side_X) +Y(0.3) +Z(Thick_Conveyor))
		        Arc LJM(P(Start_move + 18) +Y(0.3) +Z(Thick_Conveyor)), LJM(P(Start_move + 19) +Y(Out_side_Y) +Z(Thick_Conveyor)) CP
				SpeedS Speed_LN
				Move LJM(P(Start_move + 20) -X(Out_side_Y / 2) +Y(Out_side_Y) +Z(Thick_Conveyor))
		         If GluedClose_Case = False Then
					Exit Function
				EndIf
				SpeedS Speed_LN / 2
				Move LJM(P(Start_move + 20) -X(2) +Y(Out_side_Y) +Z(Thick_Conveyor))
				CP Off
				Move Here +Z(1)
				SpeedS Speed_LN
		        Move LJM(P(Start_move + 21) :Y(CY(P(Start_move))) +Y(Out_side_Y) :Z(CZ(Here)))
		        Int32 ZX1
				If CZ(Here) < 2 Then '����W�ɶW�L����
					ZX1 = 0
				Else
					ZX1 = 1
				EndIf
				Move LJM(P(Start_move + 21) :Y(CY(P(Start_move))) +Z(Thick_Conveyor + ZX1 + 1))
		        Move LJM(P(Start_move + 21) :Y(CY(P(Start_move))) -Y(2.5) +Z(Thick_Conveyor + ZX1 + 1))
				'�T�����u
				
				Move LJM(P(Start_move + 21) :Y(CY(P(Start_move))) -Y(2.5) +Z(Thick_Conveyor + ZX1))
				Move LJM(P(Start_move + 21) :Y(CY(P(Start_move))) -Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If Glued_Case = False Then
					Exit Function
				EndIf
		        Move LJM(P(Start_move + 21) +Y(3) +Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If GluedClose_Case = False Then
					Exit Function
				EndIf
				Move LJM(P(Start_move + 21) +Y(2.5) +Z(Thick_Conveyor - Line_high - 0.2))
				Wait 0.1
				
				Move LJM(P(Start_move + 22) +Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If Glued_Case = False Then
					Exit Function
				EndIf
				Move LJM(P(Start_move + 22) :Y(CY(P(Start_move))) -Y(3) -Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If GluedClose_Case = False Then
					Exit Function
				EndIf
				Move LJM(P(Start_move + 22) :Y(CY(P(Start_move))) -Y(2.5) +Z(Thick_Conveyor - Line_high - 0.2))
				Wait 0.1
				
				Move LJM(P(Start_move + 23) :Y(CY(P(Start_move))) -Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If Glued_Case = False Then
					Exit Function
				EndIf
				Move LJM(P(Start_move + 23) +Y(3) +Y(2.5) +Z(Thick_Conveyor - Line_high)) CP
				If GluedClose_Case = False Then
					Exit Function
				EndIf
				Move LJM(P(Start_move + 23) +Y(2.5) +Z(Thick_Conveyor - Line_high - 0.2))
			Case 1
				
		Send
		
		Wait 0.1
		Tool 0
		Call DefSpeed
	Else
		Print "Vision fail"
		Off Glued
		Return_code$ = "ERR;CCDERROR"
		Exit Function
	EndIf
	'�����		

	Move Here :Z(0)
	Jump LJM(CCD_PL)
	Tool 0
	Print "�����"
	Return_code$ = "RunFinish;GLUE;" + Str$(xx) + ";" + Str$(yy) + ";" + Str$(uu)
	Exit Function
		handle:
			Off Glued
			Print "Error GLUE"
			Print "ERR;", SysErr, ";GLUE"
			Return_code$ = "ERR;" + Str$(SysErr)
			If ChkNet(205) > 0 Then
				Print 205, "ERR;", SysErr
			EndIf
			If ChkNet(211) > 0 Then
				Print #211, "ERR;", SysErr
			EndIf
		Reset
		Power High
		Call DefSpeed
Fend
Function GoHome_Gld '�_�k
	'Robot 2
	IsBuzy = True
	Speed 10
	SpeedS 50
	Home
	Power High
	Call DefSpeed
	Return_code$ = "RunFinish;HOME"
	Print Return_code$
Fend
Function tcpipcmd_Gld
	Integer product_num
	OnErr GoTo handle
	If False Then
		handle:
			Print "Error occer"
			Print "ERR:", SysErr
			If ChkNet(205) > 0 Then
				Print #205, "ERR;", SysErr
			EndIf
		Reset
		Power High
		Call DefSpeed
	EndIf
	Do
		 OpenNet #205 As Server
		 WaitNet #205, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #205 Connected"
		 	Do
            	If (PauseOn = True Or SafetyOn = True) Then
            		If ChkNet(205) > 0 Then
				 		Line Input #205, cmd_plu$
				 		If Len(cmd_plu$) > 0 And Trim$(cmd_plu$) <> "" Then
				 				String toks12$(0)
			 					ParseStr cmd_plu$, toks12$(), ";"
			 					Select toks12$(0)
						 		Case "Resume"
							 		Print #205, "Resume"
							 		Print "Continue"
									Cont
									cmd_plu$ = ""
									Exit Do
						 		Default
				 					Print #205, "ERR,Cmd_NotFound"
				 					cmd_plu$ = ""
				 			Send
				 		EndIf
			 		EndIf
            	Else
				 	If (ChkNet(205) > 0 And IsBuzy = False) Then '�s�u�𦳸��
				 		If Pass_Tcpip = False Then
					 			Line Input #205, cmd$
					 		EndIf
				 		Wait 0.5
					 	If Len(cmd$) > 0 And cmd$ <> "" Then
				 			Print "received '", cmd$, "' from PC"
				 			String toks1$(0)
				 			ParseStr cmd$, toks1$(), ";"
	                        Select toks1$(0)
				 			'Select Left$(cmd$, 4)
				 				Case "PROD" 'Ū���~
				 					'Print #205, "cmd;received;", toks1$(0)
				 					'product_num = Val(Mid$(cmd$, 5))
				 					product_num = Val(toks1$(1))
				 					Call Product_Setting(product_num)
				 				Case "SPIT" '�R��
				 					'Print #205, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call MovetoSpit_Gld
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "NEED" '�w��
				 					'Print #205, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call MovetoNeedle_Gld
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "GLUE" '�
				 					'Print #205, "cmd;received;", toks1$(0)
				 					If product_load = True Then
				 						Call Move_Test_Glued
				 					Else
				 						Return_code$ = "ERR;Product No Load"
				 					EndIf
				 				Case "MANUALGLUE"
								Select Val(toks1$(1))
				 						Case 0
											Call Move_OnTable2
										Case 1
											Call Move_OnTable3(Val(toks1$(1)))
										Default
				 							Print #205, "ERR;Cmd_NotFound"
									Send
				 				Case "TKIF"
				 					If (TaskInfo(4, 3)) < 1 Then Print #205, "Task;NotRun"
				 					If (TaskInfo(4, 3)) = 1 Then Print #205, "Task;Run"
									If (TaskInfo(4, 3)) = 2 Then Print #205, "Task;Wait"
									If (TaskInfo(4, 3)) = 3 Then Print #205, "Task;Pause"
									If (TaskInfo(4, 3)) = 4 Then Print #205, "Task;Stop"
									If (TaskInfo(4, 3)) = 5 Then Print #205, "Task;Error"
					 			Case "SET_PURGE_GLUE_TIME"
				 					Glue_Time = Val(toks1$(1))
				 				Case "SetShift"
	                                'Print #205, "cmd;received;", toks1$(0)
				 					Call Set_XYZU(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)))
				 				Case "GetShift"
				 					'Print #205, "cmd;received;", toks1$(0)
				 					Call Get_XYZU
'				 				Case "SetModle"
'				 					 'Print #205, "cmd;received;", toks1$(0)
'				 					 'L W R L1 L2 L3
'				 					Call WLsetting(Val(toks1$(1)), Val(toks1$(2)), Val(toks1$(3)), Val(toks1$(4)), Val(toks1$(5)), Val(toks1$(6)))
				 				Case "HOME" '�_�k
				 					'Print #205, "cmd;received;", toks1$(0)
				 					Call GoHome_Gld
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
				 					Print #205, "ERR;Cmd_NotFound"
				 			Send
				 		'	IsBuzy = False
				 			
					 	cmd$ = ""
	                    EndIf
				 	EndIf
				 	If TaskInfo(4, 3) < 1 Or TaskInfo(4, 3) > 3 Then
				 		IsBuzy = False
				 	EndIf
				 	If Return_code$ <> "" Then
			 			Print #205, Return_code$
			 			Return_code$ = ""
			 		EndIf
			 		
				 	If ChkNet(205) = -3 Then
				 		CloseNet #205
				 		Print "Disconnected"
				 		Exit Do
				 	EndIf
			 	EndIf
			 Loop
		 EndIf
	Loop
Fend
Function MovetoNeedle_Gld
	Real mid_1X, mid_1Y, val_1X, val_1Y, fin_1X, fin_1Y, fin_1Z
	Tool 0
	OnErr GoTo handle
	'Call Speed_SuperLow
	SpeedS 300
	MemOff (RUN1_TCPX_1); MemOff (RUN1_TCPX_2);	MemOff (RUN1_TCPY_1); MemOff (RUN1_TCPY_2);
	MemOff (RUN1_TCPZ_1); MemOff (RUN1_TCPZ_2)

	Jump Circle_P5 :Z(0)
	Call Speed_SuperLow2

	Print "�ѦҶ�ߦ�m�G", Circle_P5
	Move Circle_P5 :Z(-10)						'����P5��m���W��
	Move Circle_P5 +Z(-2)								'�]���
	Circle1_Nega_P6 = Circle_P5 -Y(10) +Z(-2)			'�����]�w
	Circle1_Posi_P7 = Circle_P5 +Y(10) +Z(-2)
	
	Move Circle1_Nega_P6 +X(0.01)				'�G�N�]�����䰾�@�I�A�i�յۧ�Z?

	Call Speed_SuperLow
	Xqt RUN1_X; Xqt RUN1_Y						'�I����TCP�I��
	Arc Circle1_Posi_P7, Circle1_Nega_P6		'�����]�I
	SavePoints "robot1.pts"
	Wait MemSw(RUN1_TCPX_1) = On And MemSw(RUN1_TCPY_1) = On, 20
	If TW = On Or (TaskState(RUN1_X) = 1 Or TaskState(RUN1_Y)) = 1 Then
 		Quit RUN1_X; Quit RUN1_Y
 		Return_code$ = "ERR;Sensor XY No Find"
 		Exit Function
	EndIf

	'�C�L�Ĥ@�ꪺ4���IX,Y�A����n���X�H��
	Print CR
	Print "P1-X(first)=	", CX(RUN1_TCPY2_P14), "	P1-Y(first)=	", CY(RUN1_TCPX1_P11)
	Print "P2-X(second)=	", CX(RUN1_TCPY1_P12), "	P2-Y(second)=	", CY(RUN1_TCPX2_P13)
	
	'���Ĥ@�ꪺ���	
	'�I��TCPX�O��Y�ȡA�I��TCPY�O��X��
	mid_1X = (CX(RUN1_TCPY2_P14) + CX(RUN1_TCPY1_P12)) / 2
	mid_1Y = (CY(RUN1_TCPX1_P11) + CY(RUN1_TCPX2_P13)) / 2
'	If GetLinePara = False Then
'		Print "�i�i�i�iRUN ERROR�j�j�j�j"
'		Print #211, "EER,RUN ERROR"
'		Exit Function
'	EndIf
'	mid_1X = MiD_XX
'	mid_1Y = MiD_YY
	fin_1Z = CZ(Circle_P5)
	Print "mid_1X=		", mid_1X, "	mid_1Y=		", mid_1Y, "	fin_1Z= ", fin_1Z
	
	If Abs(CX(RUN1_mid) - CX(Circle_P5)) > 5 Then '3
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Print #205, "ERR,X>"
		Return_code$ = "ERR,X>"
		Exit Function
	EndIf
	If Abs(CY(RUN1_mid) - CY(Circle_P5)) > 5 Then '3
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Print #205, "ERR;Y>"
			Return_code$ = "ERR;Y>"
		Exit Function
	EndIf
	Call Speed_SuperLow2
	Move Here :X(mid_1X) :Y(mid_1Y)
	RUN1_mid = Here
	'Move Here +Z(-2)
	Call Speed_SuperLow
	Xqt RUN1_Z
	Move Here :Z(-20)
	Move Here :Z(CZ(RUN1_mid))
	Wait MemSw(RUN1_TCPZ_1) = On, 20
	If TW = On Or TaskState(RUN1_Z) = 1 Then
 		Quit RUN1_Z
 		Return_code$ = "ERR;Sensor Z No Find"
 		Exit Function
	EndIf
	Wait 0.5
	Print "mid_1X=		", mid_1X, "	mid_1Y=		", mid_1Y, "	fin_1Z= ", CZ(RUN1_TCPZ1_P15)
	If Abs(CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5)) < 5 Then 'Abs(CX(RUN1_mid) - CX(Circle_P5)) < 1 And Abs(CY(RUN1_mid) - CY(Circle_P5)) < 1 
		'TLSet 1, XY(CX(RUN1_mid) - CX(Circle_P5), CY(RUN1_mid) - CY(Circle_P5), CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5), 0)
		NEW_Circle_P8 = Here :X(CX(RUN1_mid)) :Y(CY(RUN1_mid)) :Z(CZ(RUN1_TCPZ1_P15) - 0.1)
	Else
		Print "X", Str$(CX(RUN1_mid) - CX(Circle_P5)), ",Y,", Str$(CY(RUN1_mid) - CY(Circle_P5)), ",Z,", Str$((CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5)))
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Print #205, "ERR;XYZ>"
		Exit Function
	EndIf
	SpeedS 200
	Move NEW_Circle_P8
	'STEP2
	If Need_twoStep = False Then
		Exit Function
	EndIf
	SpeedS 200
	Move NEW_Circle_P8
	Call DefSpeed
	'Pause
	Print "�i�i�i�iRUN1 ok�j�j�j�j"
	SavePoints "robot1.pts"
	'Return_code$ = "RunFinish;NEED"
	Exit Function
	handle:
		Print "Error NEED1"
		Print "ERR;", SysErr
		If ChkNet(211) > 0 Then
			Print #211, "ERR;", SysErr
		EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function Need_twoStep As Boolean
	Real mid_1X, mid_1Y, val_1X, val_1Y, fin_1X, fin_1Y, fin_1Z
	OnErr GoTo handle
	Need_twoStep = True
	Circle1_Nega_P6 = NEW_Circle_P8 -Y(10) 			'�����]�w
	Circle1_Posi_P7 = NEW_Circle_P8 +Y(10)
	Call Speed_SuperLow2
	Move Circle1_Nega_P6 +X(0.01)				'�G�N�]�����䰾�@�I�A�i�յۧ�Z?
	Call Speed_SuperLow
	Xqt RUN1_X; Xqt RUN1_Y						'�I����TCP�I��
	Arc Circle1_Posi_P7, Circle1_Nega_P6		'�����]�I
	SavePoints "robot1.pts"
	Wait MemSw(RUN1_TCPX_1) = On And MemSw(RUN1_TCPY_1) = On, 20
	If TW = On Or (TaskState(RUN1_X) = 1 Or TaskState(RUN1_Y)) = 1 Then
 		Quit RUN1_X; Quit RUN1_Y
 		Return_code$ = "ERR;Sensor XY No Find"
 		Need_twoStep = False
 		Exit Function
	EndIf

	'�C�L�Ĥ@�ꪺ4���IX,Y�A����n���X�H��
	Print CR
	Print "P1-X(first)=	", CX(RUN1_TCPY2_P14), "	P1-Y(first)=	", CY(RUN1_TCPX1_P11)
	Print "P2-X(second)=	", CX(RUN1_TCPY1_P12), "	P2-Y(second)=	", CY(RUN1_TCPX2_P13)
	
	'���Ĥ@�ꪺ���	
	'�I��TCPX�O��Y�ȡA�I��TCPY�O��X��
	mid_1X = (CX(RUN1_TCPY2_P14) + CX(RUN1_TCPY1_P12)) / 2
	mid_1Y = (CY(RUN1_TCPX1_P11) + CY(RUN1_TCPX2_P13)) / 2
'	If GetLinePara = False Then
'		Print "�i�i�i�iRUN ERROR�j�j�j�j"
'		Print #211, "EER,RUN ERROR"
'		Exit Function
'	EndIf
'	mid_1X = MiD_XX
'	mid_1Y = MiD_YY
	fin_1Z = CZ(NEW_Circle_P8)
	Print "mid_1X=		", mid_1X, "	mid_1Y=		", mid_1Y, "	fin_1Z= ", fin_1Z
	
	If Abs(CX(RUN1_mid) - CX(NEW_Circle_P8)) > 1 Then
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Need_twoStep = False
		Print #205, "ERR;X>1"
		Exit Function
	EndIf
	If Abs(CY(RUN1_mid) - CY(NEW_Circle_P8)) > 1 Then
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Need_twoStep = False
		Print #205, "ERR;Y>1"
		Exit Function
	EndIf
	Move Here :X(mid_1X) :Y(mid_1Y)
	RUN1_mid = Here
	Move Here +Z(-2)
	Call Speed_SuperLow
	Xqt RUN1_Z
	Move Here :Z(-20)
	Move Here :Z(CZ(RUN1_mid) - 2)
	Wait MemSw(RUN1_TCPZ_1) = On, 20
	If TW = On Or TaskState(RUN1_Z) = 1 Then
 		Quit RUN1_Z
 		Return_code$ = "ERR;Sensor Z No Find"
 		Need_twoStep = False
 		Exit Function
	EndIf
	Wait 0.5
	
	Print "mid_1X=		", mid_1X, "	mid_1Y=		", mid_1Y, "	fin_1Z= ", CZ(RUN1_TCPZ1_P15)
	If Abs(CZ(RUN1_TCPZ1_P15) - CZ(NEW_Circle_P8)) < 3 Then ' Abs(CX(RUN1_mid) - CX(NEW_Circle_P8)) < 1 And Abs(CY(RUN1_mid) - CY(NEW_Circle_P8)) < 1 And
		TLSet 1, XY(-(CX(RUN1_mid) - CX(Circle_P5)), -(CY(RUN1_mid) - CY(Circle_P5)), -(CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5)), 0)
		'NEW_Circle_P8 = Here :X(CX(RUN1_mid)) :Y(CY(RUN1_mid)) :Z(CZ(RUN1_TCPZ1_P15) - 0.1)
		Print "TOOL X", Str$(-(CX(RUN1_mid) - CX(Circle_P5))), ",Y,", Str$(-(CY(RUN1_mid) - CY(Circle_P5))), ",Z,", Str$(-((CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5))))
		Return_code$ = "RunFinish;NEED;" + Str$(-(CX(RUN1_mid) - CX(Circle_P5))) + ";" + Str$(-(CY(RUN1_mid) - CY(Circle_P5))) + ";" + Str$(-((CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5))))
	Else
		Print "TOOL X", Str$(CX(RUN1_mid) - CX(Circle_P5)), ",Y,", Str$(CY(RUN1_mid) - CY(Circle_P5)), ",Z,", Str$((CZ(RUN1_TCPZ1_P15) - CZ(Circle_P5)))
		
		Print "�i�i�i�iRUN ERROR�j�j�j�j"
		Print #205, "ERR;XYZ>1"
		Need_twoStep = False
		Exit Function
	EndIf
	Exit Function
	handle:
		Need_twoStep = False
		Print "Error NEED2"
		Print "ERR;", SysErr, ";NEED2"
				Return_code$ = "ERR;" + Str$(SysErr)
			If ChkNet(205) > 0 Then
				Print 205, "ERR;", SysErr
			EndIf
	Reset
	Power High
	Call DefSpeed
Fend
Function GetLinePara As Boolean
	Double MX12, MX34, LPK1, LPK2, LPB1, LPB2
	MX12 = CX(RUN1_TCPY2_P14) - CX(RUN1_TCPY1_P12)

	If MX12 = 0 Then
		LPK1 = 10000
		LPB1 = CY(RUN1_TCPY1_P12) - LPK1 * CX(RUN1_TCPY1_P12)
	Else
		LPK1 = (CY(RUN1_TCPY2_P14) - CY(RUN1_TCPY1_P12)) / (CX(RUN1_TCPY2_P14) - CX(RUN1_TCPY1_P12))
		LPB1 = CY(RUN1_TCPY1_P12) - LPK1 * CX(RUN1_TCPY1_P12)
	EndIf
	
	MX34 = CX(RUN1_TCPX2_P13) - CX(RUN1_TCPX1_P11)

	If MX34 = 0 Then
		LPK2 = 10000
		LPB2 = CY(RUN1_TCPX1_P11) - LPK2 * CX(RUN1_TCPX1_P11)
	Else
		LPK2 = (CY(RUN1_TCPX2_P13) - CY(RUN1_TCPX1_P11)) / (CX(RUN1_TCPX2_P13) - CX(RUN1_TCPX1_P11))
		LPB2 = CY(RUN1_TCPX1_P11) - LPK2 * CX(RUN1_TCPX1_P11)
	EndIf
	MiD_XX = 0; MiD_YY = 0
	If (Abs(LPK1 - LPK2) > 0.5) Then
		MiD_XX = (LPB2 - LPB1) /(LPK1 - LPK2)
		MiD_YY = LPK1 * MiD_XX + LPB1
		GetLinePara = True
	Else
		GetLinePara = False
	EndIf
Fend
Function RUN1_X
Do
	If Sw(TCPX) = On Then
		buf_x1 = RealPos; MemOn RUN1_TCPX_1 '�Ǧ^�ثe�y��
		Wait Sw(TCPX) = Off
		buf_x2 = RealPos
		
		'RUN1_TCPX1_P11 = RealPos :X((CX(buf_x1) + CX(buf_x2)) / 2) :Y((CY(buf_x1) + CY(buf_x2)) / 2) :Z((CZ(buf_x1) + CZ(buf_x2)) / 2)
		RUN1_TCPX1_P11 = RealPos :X(CX(buf_x2)) :Y(CY(buf_x2)) :Z(CZ(buf_x2))
		'Print "[XXX]BUF1=", buf_x1	'�p���
		'Print "[XXX]BUF2=", buf_x2	'�p���
		Print "RUN1_X1(P11)=", RUN1_TCPX1_P11
		'Pause
		Do
			If Sw(TCPX) = On Then
				buf_x1 = RealPos; MemOn RUN1_TCPX_2
				Wait Sw(TCPX) = Off
				buf_x2 = RealPos
				'RUN1_TCPX2_P13 = RealPos :X((CX(buf_x1) + CX(buf_x2)) / 2) :Y((CY(buf_x1) + CY(buf_x2)) / 2) :Z((CZ(buf_x1) + CZ(buf_x2)) / 2)
				RUN1_TCPX2_P13 = RealPos :X(CX(buf_x2)) :Y(CY(buf_x2)) :Z(CZ(buf_x2))
				'Print "[XXX]BUF1=", buf_x1	'�p���
				'Print "[XXX]BUF2=", buf_x2	'�p���
				Print "RUN1_X2(P13)=", RUN1_TCPX2_P13
				'Pause
					
					Quit RUN1_X
			EndIf
		Loop
	EndIf
Loop
	
Fend
Function RUN1_Y
Do
	If Sw(TCPY) = On Then
		buf_y1 = RealPos; MemOn RUN1_TCPY_1
		Wait Sw(TCPY) = Off
		buf_y2 = RealPos;
		
		'RUN1_TCPY1_P12 = RealPos :X((CX(buf_y1) + CX(buf_y2)) / 2) :Y((CY(buf_y1) + CY(buf_y2)) / 2) :Z((CZ(buf_y1) + CZ(buf_y2)) / 2)
		RUN1_TCPY1_P12 = RealPos :X(CX(buf_y2)) :Y(CY(buf_y2)) :Z(CZ(buf_y2))
		'Print "[XXX]BUF1=", buf_y1	'�p���
		'Print "[XXX]BUF2=", buf_y2	'�p���
		Print "RUN1_Y1(P12)=", RUN1_TCPY1_P12
		'Pause
		Do
			If Sw(TCPY) = On Then
				buf_y1 = RealPos; MemOn RUN1_TCPY_2
				Wait Sw(TCPY) = Off
				buf_y2 = RealPos
				'RUN1_TCPY2_P14 = RealPos :X((CX(buf_y1) + CX(buf_y2)) / 2) :Y((CY(buf_y1) + CY(buf_y2)) / 2) :Z((CZ(buf_y1) + CZ(buf_y2)) / 2)
				RUN1_TCPY2_P14 = RealPos :X(CX(buf_y2)) :Y(CY(buf_y2)) :Z(CZ(buf_y2))
				'Print "[XXX]BUF1=", buf_y1	'�p���
				'Print "[XXX]BUF2=", buf_y2	'�p���
				Print "RUN1_Y2(P14)=", RUN1_TCPY2_P14
				'Pause

'				Wait Sw(TCPY) = Off
				Quit RUN1_Y
			EndIf
		Loop
	EndIf
Loop
	
Fend
Function RUN1_Z
Do
	If Sw(TCPY) = On And Sw(TCPX) = On Then
   		Wait Sw(TCPY) = Off And Sw(TCPX) = Off
		buf_z1 = RealPos; MemOn RUN1_TCPZ_1
		Print "Z1=", buf_z1
		Wait Sw(TCPY) = On And Sw(TCPX) = On
		buf_z2 = RealPos;
		Print "Z2=", buf_z2
		RUN1_TCPZ1_P15 = RealPos :Z((CZ(buf_z1) + CZ(buf_z2)) / 2)
		'Print "[XXX]BUF1=", buf_y1	'�p���
		'Print "[XXX]BUF2=", buf_y2	'�p���
		Print "RUN1_Z1(P15)=", RUN1_TCPZ1_P15
		'Pause
		Quit RUN1_Z
	EndIf
Loop
	
Fend
'F_Setting
'F_Initial.prg    '�w�q��l���A
'#include "Msg_Table.inc"
'#include "D_Global.inc"
Function Initial
	
'====Robot Reset=============================================================	
	Motor On
'	ThreeT = 0; agv_result = False
	Tool 0

	Wait Motor = On
	Power High
	Speed 3; 	Accel 3, 3
	SpeedS 50; 	AccelS 300, 300
'====Tool Setting===============================================================
	'�]�mTool�����q�M�D�ʰѼ�
	'Inertia [�t���D��]kgm^2, [���߲v]mm
	Weight 2.5
	Inertia 0.05, 40
Fend
'====Robot Speed================================================================	
Function DefSpeed
	SP_SDef = 500
	SP_Def = 30
	Speed SP_Def
	Accel SP_Def, SP_Def
	SpeedS SP_SDef
	AccelS 500, 500
Fend

Function Speed_SuperLow
	'Speed 3; Accel 3, 3		'base low ok
	'SpeedS 5; AccelS 100, 100	'base low ok
	Speed 1; Accel 1, 1			'base power high
	SpeedS 5; AccelS 100, 100	'base power high
Fend
Function Speed_SuperLow2
	'Speed 3; Accel 3, 3		'base low ok
	'SpeedS 5; AccelS 100, 100	'base low ok
	Speed 1; Accel 1, 1			'base power high
	SpeedS 10; AccelS 100, 100	'base power high
Fend
Function Speed_Low		'base power high
	Speed 3; Accel 3, 3
	SpeedS 40; AccelS 300, 300
Fend
'Function CLR_PP
'    Integer pp, NewPP
'    start_pt = 130; end_pt = start_pt + 19;
'	For pp = start_pt To end_pt
'		NewPP = pp - 30
'		P(NewPP) = XY(CX(P(pp)) - CX(P(start_pt)), CY(P(pp)) - CY(P(start_pt)), CZ(Obj_PL), 0)
'	Next
'    P(NewPP + 1) = XY((CX(P(NewPP - 19)) + CX(P(NewPP))) / 2, (CY(P(NewPP - 19)) + CY(P(NewPP))) / 2, CZ(P(NewPP - 19)), 0)
''	P(NewPP + 2) = XY(CX(P(start_pt)), CY(P(start_pt)), CZ(P(start_pt)), 0)
''	P(NewPP + 3) = XY(CX(P(start_pt)), CY(P(start_pt)), CZ(P(start_pt)), 0)
''	P(NewPP + 4) = XY(CX(P(start_pt)), CY(P(start_pt)), CZ(P(start_pt)), 0)
'	P(NewPP + 2) = XY(CX(P(NewPP - 19)), CY(P(NewPP - 9)), CZ(P(NewPP - 19)), 0)
'	P(NewPP + 3) = XY(CX(P(NewPP - 19)), CY(P(NewPP - 9)), CZ(P(NewPP - 19)), 0)
'	P(NewPP + 4) = XY(CX(P(NewPP - 19)), CY(P(NewPP - 9)), CZ(P(NewPP - 19)), 0)
'		SavePoints "robot1.pts"
'	'�]�w����
'Fend
'		SpeedS 30
'		Move LJM(P160 +Z(Thick_Conveyor))
'		SpeedS 1000
'		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
'		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
'		SpeedS 30
'		Move LJM(P165 +Z(Thick_Conveyor))
'		SpeedS 1000
'		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Y(0.5) +Z(Thick_Conveyor)) '+0.5
'		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Y(0.5) +Z(Thick_Conveyor)) '+0.5
'		SpeedS 30
'		Move LJM(P170 +Y(0.05) +Z(Thick_Conveyor))
'		SpeedS 1000
'		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 -X(0.6) +Y(0.4) +Z(Thick_Conveyor))
'		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 -X(0.6) +Z(Thick_Conveyor))
'		SpeedS 30
'		Move LJM(P175 -X(0.2) +Z(Thick_Conveyor))
'		SpeedS 1000
'		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 -X(0.4) -Y(0.3) +Z(Thick_Conveyor))
'		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 -Y(0.3) +Z(Thick_Conveyor))
'		SpeedS 30
'		Move LJM(P190 +Z(Thick_Conveyor))
'		Off Glued
'		Move LJM(P160 +Y(-0.5) +Z(Thick_Conveyor))
'		CP Off
'Function WLsetting(S_W As Real, S_L As Real, S_R As Real, S_L1 As Real, S_L2 As Real, S_L3 As Real)
'	P130 = XY(-(S_W) / 2 + S_R, S_L / 2, 0, 0)
'	P131 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(90 + 22.5)), S_L / 2 - S_R + S_R * Sin(DegToRad(90 + 22.5)), 0, 0)
'	P132 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(90 + 45)), S_L / 2 - S_R + S_R * Sin(DegToRad(90 + 45)), 0, 0)
'	P133 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(90 + 67.5)), S_L / 2 - S_R + S_R * Sin(DegToRad(90 + 67.5)), 0, 0)
'    P134 = XY(-(S_W) / 2, S_L / 2 - S_R, 0, 0)
'	P135 = XY(-(S_W) / 2, -(S_L) / 2 + S_R, 0, 0)
'	P136 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(180 + 22.5)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(180 + 22.5)), 0, 0)
'	P137 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(180 + 45)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(180 + 45)), 0, 0)
'	P138 = XY(-(S_W) / 2 + S_R + S_R * Cos(DegToRad(180 + 67.5)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(180 + 67.5)), 0, 0)
'	P139 = XY(-(S_W) / 2 + S_R, -(S_L) / 2, 0, 0)
'	P140 = XY((S_W) / 2 - S_R, -(S_L) / 2, 0, 0)
'	P141 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(270 + 22.5)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(270 + 22.5)), 0, 0)
'	P142 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(270 + 45.5)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(270 + 45)), 0, 0)
'	P143 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(270 + 67.5)), -(S_L) / 2 + S_R + S_R * Sin(DegToRad(270 + 67.5)), 0, 0)
'	P144 = XY((S_W) / 2, -(S_L) / 2 + S_R, 0, 0)
'	P145 = XY((S_W) / 2, (S_L) / 2 - S_R, 0, 0)
'	P146 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(22.5)), (S_L) / 2 - S_R + S_R * Sin(DegToRad(22.5)), 0, 0)
'	P147 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(45)), (S_L) / 2 - S_R + S_R * Sin(DegToRad(45)), 0, 0)
'	P148 = XY((S_W) / 2 - S_R + S_R * Cos(DegToRad(67.5)), (S_L) / 2 - S_R + S_R * Sin(DegToRad(67.5)), 0, 0)
'	P149 = XY((S_W) / 2 - S_R, (S_L) / 2, 0, 0)
'	P150 = XY(0, (S_L) / 2, 0, 0)
'	P151 = XY(S_L1 - (S_W / 2), -(S_L) / 2 + S_R, 0, 0)
'	P152 = XY(S_L2 - (S_W / 2), -(S_L) / 2 + S_R, 0, 0)
'	P153 = XY(S_L3 - (S_W / 2), -(S_L) / 2 + S_R, 0, 0)
'	Integer I_pd, pp
'	I_pd = 0;
'
'	For pp = start_pt To end_pt
'		P(Start_move + I_pd) = XY(CX(P(pp)) - CX(P(start_pt)) - Glued_mid_X + CX(P(600 + Now_product)), CY(P(pp)) - CY(P(start_pt)) - Glued_mid_Y + CY(P(600 + Now_product)), CZ(Obj_PL) + CZ(P(600 + Now_product)), 0) /7
'		I_pd = I_pd + 1
'	Next
'	Glued_mid_X = (CX(P(start_pt)) + CX(P(start_pt + 10))) / 2
'	Glued_mid_Y = (CY(P(start_pt)) + CY(P(start_pt + 10))) / 2
'	Return_code$ = "SetModle"
'Fend
