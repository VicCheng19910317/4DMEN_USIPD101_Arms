Global Integer i, j, product, x, y, SP_SDef, SP_NDef, Total_XY
Global String cmd$, Return_code$
Global Boolean IsBuzy, Vacuum_Pass, Pneumatic_Pass, Ccd_Pass, product_load
Global Real ccdX, ccdY, ccdU, Thick_Conveyor, Thick_Platform
Function main_Ass
	'Robot 2
	Reset
	Motor On
	Wait Motor = On
	Power High
	'---
	Weight 3 '�v��+�u�󭫶q
	Speed 100
	Accel 100, 100
	SP_SDef = 500
	SpeedS 500
	SpeedS SP_SDef
	AccelS 50, 50
	'---
	Vacuum_Pass = True '�u��PASS
	Pneumatic_Pass = True '��ʬ�PASS
	Ccd_Pass = True
	test_mode = True
	Xqt Move_Test_Ass
	'---
	IsBuzy = False

	Xqt tcpipcmd_Ass
Fend
Function Move_Test_Ass
	Integer re0
	re0 = 0
	Call AssemblPallet_Teach(ByRef re0)
	Call GoHome_In
	Do
		Call MovetoPick_Ass
		Call MoveToPut_Ass
	Loop
Fend
Function Test_Move
	Integer re0
	re0 = 0
	Call AssemblPallet_Teach(ByRef re0)
	Call GoHome_Ass
	Do
		Call MovetoPick_Ass
		Call MoveToPut_Ass
	Loop
Fend
Function AssemblPallet_Teach(ByRef product_local As Integer)
	'Robot 2
	IsBuzy = True
	product_load = False
	j = 1
		Select product_local
		Case 0
			product = product_local
			x = 5
			y = 7
			Pallet 0, PL1, PL2, PL3, PL4, x, y
			Thick_Conveyor = 0 '��e�a��u�󪺫p��
			Thick_Platform = 10 '���x��u�󪺫p��
			product_load = True
	Send
	If product_load = True Then
		Return_code$ = "RunFinish,PROD," + Str$(product)
		Total_XY = x * y
	Else
		Return_code$ = "ERR,PROD"
		Total_XY = 0
	EndIf
	Print Return_code$
Fend
Function Pneumatic_Back_Ass As Boolean
	Off Pneumatic_OP
    On Pneumatic_CL
    Wait Sw(DI_Pneumatic_CL) = On, 2
	If TW = True And Pneumatic_Pass = False Then
		Return_code$ = "ERR,Pneumatic_CL" '�^�Ǯ�����^����		
		Pneumatic_Back_Ass = False
		Exit Function
	EndIf
	Pneumatic_Back_Ass = True
Fend
Function Pneumatic_Out_Ass As Boolean
	On Pneumatic_OP
    Off Pneumatic_CL
    Wait Sw(DI_Pneumatic_OP) = On, 2
	If TW = True And Pneumatic_Pass = False Then
		Return_code$ = "ERR,Pneumatic_CL" '�^�Ǯ�����^����		
		Pneumatic_Out_Ass = False
		Exit Function
	EndIf
	Pneumatic_Out_Ass = True
Fend
Function MovetoPick_Ass '���Ƥά۾�
	'Robot 2
	String ex_product$, ex_j$
	IsBuzy = True
	If (Pneumatic_Back_Ass = False) Then
		Exit Function
	EndIf

	Go palletup
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	Jump3 Here :Z(500), Pallet(product, j) +Z(30 + Thick_Platform), Pallet(product, j) +Z(20 + Thick_Platform)
	j = j + 1 '���W+1
	If j > y * x Then '���W�^��1
		j = 1
	EndIf
	Off Vacuum_CL
	On Vacuum_OP '�l��
	Wait Sw(DI_Vacuum) = On, 2
	Move Here +Z(30 + Thick_Platform)
	Move palletup
	If TW = True And Vacuum_Pass = False Then
		Return_code$ = "ERR,Vacuum" '�^�ǯu�ť���
		Exit Function
	EndIf
	'���
	Go ccd '���Ӧ�m
' 	Boolean found
' 	VRun Test01 '����۾����
' 	VGet Test1.Geom01.RobotToolXYU, found, ccdX, ccdY, ccdU
'	If found = True Or Ccd_Pass = True Then  '����쪫��
'		TLSet 15, XY(ccdX, ccdY, 00, ccdU)
' 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
'	Else
'	 	Return_code$ = "ERR,Geom was not found!" '�^�ǩ�ӥ��� 	
'		Print Return_code$
'	 	Exit Function
'	EndIf
	Return_code$ = "RunFinish,PICK," + ex_product$ + "," + ex_j$
	Print Return_code$
Fend
Function MoveToSpecifyPick_Ass(ByRef Specify_num As Integer)
	'Robot 2
	String ex_product$, ex_j$
	IsBuzy = True
	If (Pneumatic_Back_Ass = False) Then
		Exit Function
	EndIf

	Go palletup
	ex_product$ = Str$(product)
	ex_j$ = Str$(j)
	Jump3 Here :Z(500), Pallet(product, j) +Z(30 + Thick_Platform), Pallet(product, j) +Z(20 + Thick_Platform)
	j = j + 1 '���W+1
	If j > y * x Then '���W�^��1
		j = 1
	EndIf
	Off Vacuum_CL
	On Vacuum_OP '�l��
	Wait Sw(DI_Vacuum) = On, 2
	Move Here +Z(30 + Thick_Platform)
	Move palletup
	If TW = True And Vacuum_Pass = False Then
		Return_code$ = "ERR,Vacuum" '�^�ǯu�ť���
		Exit Function
	EndIf
	'���
	Go ccd '���Ӧ�m
' 	Boolean found
' 	VRun Test01 '����۾����
' 	VGet Test1.Geom01.RobotToolXYU, found, ccdX, ccdY, ccdU
'	If found = True Or Ccd_Pass = True Then  '����쪫��
'		TLSet 15, XY(ccdX, ccdY, 00, ccdU)
' 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
'	Else
'	 	Return_code$ = "ERR,Geom was not found!" '�^�ǩ�ӥ��� 	
'		Print Return_code$
'	 	Exit Function
'	EndIf
	Return_code$ = "RunFinish,PICK," + ex_product$ + "," + ex_j$
	Print Return_code$
Fend
Function MoveToPut_Ass '���
	'Robot 2
	IsBuzy = True
	Jump3 Here :Z(500), put +X(ccdX) +Y(ccdY) +Z(10 + Thick_Conveyor) +U(ccdU), put +X(ccdX) +Y(ccdY) +Z(Thick_Conveyor) +U(ccdU)
'	Go put +X(ccdX) +Y(ccdY) +Z(10 + Thick_Conveyor) +U(ccdU) '���ʨ�ɥ���m�W��
'	Move put +X(ccdX) +Y(ccdY) +Z(Thick_Conveyor) +U(ccdU) '���ʨ�ɥ���m
	Off Vacuum_OP
	On Vacuum_CL
	Wait Sw(DI_Vacuum) = On, 2
	If TW = True And Vacuum_Pass = False Then
		Move Here :Z(500)
		Return_code$ = "ERR,Vacuum_OP" '�^�ǯu�ť���		
		Exit Function
    EndIf
    If (Pneumatic_Out_Ass = False) Then
    	Move Here :Z(500)
		Exit Function
	EndIf
'	Off Pneumatic_CL '����U���զX
'	On Pneumatic_OP
'    Wait Sw(DI_Pneumatic_OP) = On, 2
'	If TW = True And Pneumatic_Pass = False Then
'		Move put +X(ccdX) +Y(ccdY) +Z(20 + Thick_Conveyor) +U(ccdU)
'		Move Here :Z(500)
'		Return_code$ = "ERR,Pneumatic_CL" '�^�Ǯ�����^����		
'		Exit Function
'	EndIf

	If (Pneumatic_Back_Ass = False) Then
		Move Here :Z(500)
		Exit Function
	EndIf
	
'	Off Pneumatic_OP '������^
'	On Pneumatic_CL
'	Wait Sw(DI_Pneumatic_CL) = On, 2
'	If TW = True And Pneumatic_Pass = False Then
'		Move put +X(ccdX) +Y(ccdY) +Z(20 + Thick_Conveyor) +U(ccdU)
'		Move Here :Z(500)
'		Return_code$ = "ERR,Pneumatic_CL" '�^�Ǯ�����^����		
'		Exit Function
'	EndIf
	Move Here :Z(500)
	Print "��Ƨ���"
	Return_code$ = "RunFinish,PUTP"
	Print Return_code$
Fend
Function GoHome_Ass '�_�k
	'Robot 2
	Speed 20
	SpeedS 40
	IsBuzy = True
	Move Here :Z(600)
	Home
	Return_code$ = "RunFinish,HOME"
	SpeedS SP_SDef
	Speed 100
Fend
Function tcpipcmd_Ass
	String leftcmd$, midcmd$
	Boolean Pass_Tcpip
	Pass_Tcpip = True
	SetNet #202, "192.168.0.22", 2000, CRLF, NONE, 0, TCP
	Do
		 OpenNet #202 As Server
		 WaitNet #202, 60
		 If TW = True Then
		 	Print "Time Out"
		 Else
		 	Print " #202 Connected"
		 	Do
			 	If (ChkNet(202) > 0 And IsBuzy = False) Or Pass_Tcpip = True Then '�s�u�𦳸��
			 		If Pass_Tcpip = False Then
			 			Line Input #202, cmd$
			 		EndIf
				 	If cmd$ <> "" Then
			 			Print "received '", cmd$, "' from PC"
			 			leftcmd$ = Left$(cmd$, 4) 'Ū1-4
			 			Select leftcmd$
			 				Case "PROD" 'Ū���~
			 					Integer product_tcpip
			 					Print #202, "cmd,received"
			 					midcmd$ = Mid$(cmd$, 5) '�Ĥ��Ӧr����Ū
			 					product_tcpip = Val(midcmd$)
                                Call AssemblPallet_Teach(ByRef product_tcpip)
			 				Case "PICK" '���Ƥά۾�
			 					Print #202, "cmd,received"
			 					If product_load = True Then
			 						Call MovetoPick_Ass
			 					Else
			 						Return_code$ = "ERR,Product No Load"
			 					EndIf
							Case "SYPK" '���w����
			 					Integer Specify_num
			 					Print #204, "cmd,received"
			 					Specify_num = Val(Mid$(cmd$, 5))
			 					If product_load = True And (Specify_num <= Total_XY) Then
			 						Call MoveToSpecifyPick_Ass(ByRef Specify_num)
			 					Else
			 						If product_load = False Then
			 							Return_code$ = "ERR,Product No Load"
			 						Else
			 							Return_code$ = "ERR,Specify_num is too more"
			 						EndIf
			 					EndIf
			 				Case "PUTP" '���
			 					Print #202, "cmd,received"
			 					If product_load = True Then
			 						Call MoveToPut_Ass
			 					Else
			 						Return_code$ = "ERR,Product No Load"
			 					EndIf
			 				Case "HOME" '�_�k
			 					Print #202, "cmd,received"
			 					Call GoHome_Ass
			 				Default
			 					Print #202, "ERR,Cmd_NotFound"
			 			Send
			 			IsBuzy = False
			 			If Return_code$ <> "" Then
			 				Print #202, Return_code$
			 				Print Return_code$
			 				Return_code$ = ""
			 			EndIf
				 	cmd$ = ""
                    EndIf
			 	EndIf
	
'			 	If GS_send$ <> "" Then '���x���A�^�e
'			 		Return_code$ = GS_send$
'			 		Print "GS_send:", GS_send$
'			 		GS_send$ = ""
'			 	EndIf
			 	If ChkNet(202) = -3 Then
			 		CloseNet #202
			 		Print "Disconnected"
			 		Exit Do
			 	EndIf
			 Loop
		 EndIf
	Loop
Fend
'�y�{ 
'�}�lŪ�Ѽ� PROD0
'�ʧ@ PUTP PICK
'�_�k Home

