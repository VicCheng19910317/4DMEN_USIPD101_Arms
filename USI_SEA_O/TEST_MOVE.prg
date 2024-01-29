Function Test_Move01Go
	Reset
	Motor On
	Wait Motor = On
	SpeedS 100
	Speed 10
	Go LJM(ccd)
 	Boolean found
 	VRun SEAL_OUT '執行相機拍照
 	VGet SEAL_OUT.Point01.RobotXYU, found, ccdX, ccdY, ccdU
	If found = True Or Ccd_Pass = True Then  '有找到物件
		TLSet 2, XY(ccdX, ccdY, 00, ccdU)
 		Print "The Geom X is: ", ccdX, "Y is:", ccdY, "U is:", ccdU
	EndIf
Fend

