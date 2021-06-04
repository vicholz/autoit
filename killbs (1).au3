RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\AutoConfigURL")

if Not ProcessExists("java.exe") & Not ProcessExists("bk.exe") Then
	ProcessClose("cmd.exe")
	ProcessClose("conhost.exe")
	ProcessClose("reg.exe")
	ProcessClose("rundll32.exe")
EndIf