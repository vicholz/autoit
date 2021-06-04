#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         myName

 Script Function:
	Template AutoIt script.
	
#ce ----------------------------------------------------------------------------

#AutoIt3Wrapper_Icon=60.ico
AutoItSetOption("TrayAutoPause", 0)


; Script Start - Add your code below here
$H = @HOUR
$OH = @HOUR
While 1
	if @HOUR <> $OH and @HOUR < 18 and @HOUR > 7 then
		$OH = @HOUR
		MsgBox(0,"60-60", "!", 3300)
	EndIf
	Sleep(1000)
WEnd