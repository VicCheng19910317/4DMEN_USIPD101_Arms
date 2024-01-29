Function main_PG
Integer icnt
Real rtrq(6)
Reset
Motor On
Power High
' Power Low
Weight 1
Speed 20
Accel 20, 20
icnt = 1
PTCLR
LimitTorque 100 'init HighPower limit torque
LimitTorqueLP 100 'init LowPower limit torque
CollisionDetect On
Do
	Call all_ax_move
	Print "第", icnt, "次扭矩測試:", PTRQ(1), PTRQ(2), PTRQ(3), PTRQ(4), PTRQ(5), PTRQ(6)
	icnt = icnt + 1
	If icnt = 5 Then
		If Power = 1 Then 'High power case
			Print "LimitTorque set"
			rtrq(1) = PTRQ(1) * 1.2 * LimitTorque(1) + 1.0
			rtrq(2) = PTRQ(2) * 1.2 * LimitTorque(2) + 1.0
			rtrq(3) = PTRQ(3) * 1.2 * LimitTorque(3) + 1.0
			rtrq(4) = PTRQ(4) * 1.2 * LimitTorque(4) + 1.0
			rtrq(5) = PTRQ(5) * 1.2 * LimitTorque(5) + 1.0
			rtrq(6) = PTRQ(6) * 1.2 * LimitTorque(6) + 1.0
			Print "顯示目前高功率扭矩:", LimitTorque(1), LimitTorque(2), LimitTorque(3), LimitTorque(4), LimitTorque(5), LimitTorque(6)
			LimitTorque rtrq(1), rtrq(2), rtrq(3), rtrq(4), rtrq(5), rtrq(6)
			Print "設定高功率扭矩:", LimitTorque(1), LimitTorque(2), LimitTorque(3), LimitTorque(4), LimitTorque(5), LimitTorque(6)
			LimitTorqueStop On
		Else 'Low poser case
			Print "LimitTorqueLP set"
			rtrq(1) = PTRQ(1) * 1.4 * LimitTorqueLP(1) + 1.0
			rtrq(2) = PTRQ(2) * 1.4 * LimitTorqueLP(2) + 1.0
			rtrq(3) = PTRQ(3) * 1.4 * LimitTorqueLP(3) + 1.0
			rtrq(4) = PTRQ(4) * 1.4 * LimitTorqueLP(4) + 1.0
			rtrq(5) = PTRQ(5) * 1.4 * LimitTorqueLP(5) + 1.0
			rtrq(6) = PTRQ(6) * 1.4 * LimitTorqueLP(6) + 1.0
			Print "顯示低功率扭矩:", LimitTorqueLP(1), LimitTorqueLP(2), LimitTorqueLP(3), LimitTorqueLP(4), LimitTorqueLP(5),
			LimitTorqueLP (6)
			LimitTorqueLP rtrq(1), rtrq(2), rtrq(3), rtrq(4), rtrq(5), rtrq(6)
			Print "設定低功率扭矩:", LimitTorqueLP(1), LimitTorqueLP(2), LimitTorqueLP(3), LimitTorqueLP(4), LimitTorqueLP(5), LimitTorqueLP(6)
			LimitTorqueStopLP On
		EndIf
	EndIf
'	If icnt > 5 Then
'		icnt = 6
'	EndIf
Loop While icnt < 5
Home
Print "動作結束"
Fend
Function all_ax_move
Integer icount

Go JA(37.315 + 10, 1.169 + 10, -14.23 + 10, 0 + 10, -76.959 + 10, 142.662 + 10)
Go JA(37.315 - 10, 1.169 - 10, -14.23 - 10, 0 - 10, -76.959 - 10, 142.662 - 10)

Fend
