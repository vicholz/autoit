#include <WinAPI.au3> ; UserDefinedFunction to parse WinAPI "stuff"
AutoItSetOption("ExpandEnvStrings", 1) ; use environment variables instead of literal strings

Global $sFile, $hFile, $sText, $nBytes, $tBuffer ; set variables

; Grab clientname variable, write to section of pcview.cfg file that contains tty id
$sFile = 'c:\tmp\pcview.cfg' ; location of pcview.cfg file
$sText = '%clientname%' ; text to write to pcview.cfg file
$tBuffer = DllStructCreate("byte[" & StringLen($sText) & "]") ; type of data to write, or "struct" - in this case "byte", create the "struct"
DllStructSetData($tBuffer, 1, $sText)
$hFile = _WinAPI_CreateFile($sFile, 2) ; put file in write mode
_WinAPI_SetFilePointer($hFile, 2000) ; current location of tty id - line 2000 if viewed in hex mode, WinVI
_WinAPI_WriteFile($hFile, DllStructGetPtr($tBuffer), StringLen($sText), $nBytes) ; write text from $sText var to line 2000 of pcview.cfg
_WinAPI_CloseHandle($hFile) ; close file