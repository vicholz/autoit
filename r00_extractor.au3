#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.4.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <Array.au3>
#include <File.au3>
 Global $filePathArray[1]=[0]

 $WorkDir = @ScriptDir

 getFileList($WorkDir)

Func getFileList($folderName)
 Local $fileArray, $i, $fullFilePath, $fileAttributes, $DIRTODEL
 $fileArray = _FileListToArray($folderName)

For $i=1 To $fileArray[0]
	 $fullFilePath = $folderName & "\" & $fileArray[$i] ;retrieve the full path
	 $fileAttributes = FileGetAttrib($fullFilePath)
	If StringInStr($fileAttributes,"D") Then ;folder, have to explore
		Dim $tempArray = getFileList($fullFilePath) ;recursive call
		_ArrayConcatenate($filePathArray,$tempArray,1) ;add returned results to already found files
	Else ;file
		If StringLower(StringRight($fileArray[$i], 3)) = "rar" Then
			;_ArrayAdd($filePathArray, $fullFilePath) ;add result to already found files or replace this with an extract command
			Msgbox(0,"OUT","Extracting: " & $fullFilePath) ; Extract command
			$DIR = StringSplit($fullFilePath, "\")
			For $c=1 To $DIR[0]-1
				$DIRTODEL &= $DIR[$c] & "\"
			Next
			Msgbox(0,"OUT","Deleting: " & $DIRTODEL)
			;DirRemove($DIRTODEL,1) ;FileDelete(StringLeft($fullFilePath, StringLen($fullFilePath)-3) & "*"))
		EndIf
	EndIf
Next
 $filePathArray[0] = UBound($filePathArray) - 1 ;adjust the size of the array
EndFunc

; _ArrayDisplay($filePathArray, "$fullfilepath")