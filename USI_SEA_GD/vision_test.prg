Function vision_test_04
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX(P(94)), CY(P(pp)) - CY(P(130)) + CY(P(94)), CZ(P(94)) + 0.5, 0) /12 '+ CX(P(94)) CU(P(94)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_4)
	VRun Test04
	VGet Test04.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 12, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj4) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj4) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_4)
		Else
			Print "Vision fail"
	EndIf
Fend
Function vision_test_02
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX(P(92)), CY(P(pp)) - CY(P(130)) + CY(P(92)), CZ(P(92)) + 0.5, 0) /14 '+ CX(P(92)) CU(P(92)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_2)
	VRun Test02
	VGet Test02.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 14, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj2) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj2) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_2)
		Else
			Print "Vision fail"
	EndIf
Fend
Function vision_test_03
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX(P(93)), CY(P(pp)) - CY(P(130)) + CY(P(93)), CZ(P(93)) + 0.5, 0) /13 '+ CX(P(93)) CU(P(93)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_3)
	VRun Test03
	VGet Test03.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 13, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj3) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj3) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_3)
		Else
			Print "Vision fail"
	EndIf
Fend
Function vision_test_01
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX(P(91)), CY(P(pp)) - CY(P(130)) + CY(P(91)), CZ(P(91)) + 0.5, 0) /15 '+ CX(P(91)) CU(P(91)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_1)
	VRun Test01
	VGet Test01.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 15, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj1) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj1) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_1)
		Else
			Print "Vision fail"
	EndIf
Fend
Function vision_test_05
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX(obj5), CY(P(pp)) - CY(P(130)) + CY((obj5)), CZ((obj5)) + 0.5, 0) /11 '+ CX(P(obj5)) CU(P(obj5)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_5)
	VRun Test05
	VGet Test05.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 11, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj5) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj5) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_5)
		Else
			Print "Vision fail"
	EndIf
Fend
Function vision_test_06
	Boolean found
	Real xx, yy, uu
	Thick_Conveyor = 0
	Integer pp
	For pp = 130 To 149
		Print pp - 39
		P(pp + 30) = XY(CX(P(pp)) - CX(P(130)) + CX((obj6)), CY(P(pp)) - CY(P(130)) + CY((obj6)), CZ((obj6)) + 0.5, 0) /10 '+ CX(P(91)) CU(P(91)))
		Print P(pp + 30)
	Next
	SavePoints "robot1.pts"
	Tool 0
	Jump LJM(CCD_6)
	VRun Test06
	VGet Test06.Point01.RobotXYU, found, xx, yy, uu
	If found = True Then
		Print xx, yy, uu
		Local 10, XY(xx, yy, 0, 0)
		Tool 1
		Jump LJM(obj6) +Z(0.5) :U(0)
		On Glued
		CP On
		Arc LJM(P161 +Z(Thick_Conveyor)), LJM(P162 +Z(Thick_Conveyor))   '�꩷P102�ꤤ�~�I
		Arc LJM(P163 +Z(Thick_Conveyor)), LJM(P164 +Z(Thick_Conveyor))
		Move LJM(P165 +Z(Thick_Conveyor))
		Arc LJM(P166 +Z(Thick_Conveyor)), LJM(P167 +Z(Thick_Conveyor))
		Arc LJM(P168 +Z(Thick_Conveyor)), LJM(P169 +Z(Thick_Conveyor))
		Move LJM(P170 +Z(Thick_Conveyor))
		Arc LJM(P171 +Z(Thick_Conveyor)), LJM(P172 +Z(Thick_Conveyor))
		Arc LJM(P173 +Z(Thick_Conveyor)), LJM(P174 +Z(Thick_Conveyor))
		Move LJM(P175 +Z(Thick_Conveyor))
		Arc LJM(P176 +Z(Thick_Conveyor)), LJM(P177 +Z(Thick_Conveyor))
		Arc LJM(P178 +Z(Thick_Conveyor)), LJM(P179 +Z(Thick_Conveyor))
		Move LJM(P160 +Z(Thick_Conveyor))
		Move LJM(obj6) +Z(0.5) :U(0)
		Wait 0.5
		Off Glued
		CP Off
		Move Here :Z(0)
		Tool 0
		Jump LJM(CCD_6)
		Else
			Print "Vision fail"
	EndIf
Fend
