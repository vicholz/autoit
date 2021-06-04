#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author: IGT

 Script Function:
	Replaces specified string in a file.
	
	Usage: replace <file> <search_string> <new_string>

#ce ----------------------------------------------------------------------------

$Usage = "Usage: " & @AutoItExe & " <file> <search_string> <new_string>"

If $CmdLine[0] <> 3 Then
	ConsoleWrite($Usage)
	Exit
EndIf

If Not FileExists($CmdLine[1]) Then
	ConsoleWrite($Usage)
	Exit
EndIf

$rFile = $CmdLine[1]
$rFileText = FileRead($rFile,FileGetSize($rFile))
$rFileText = StringReplace($rFileText, $CmdLine[2], $CmdLine[3])
FileDelete($rFile)
FileWrite($rFile,$rFileText)