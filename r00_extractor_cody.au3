#include <Array.au3>
#include <File.au3>
 Global $filePathArray[1]=[0]

If $CmdLine[0] = 1 Then ; dunno why this is here... I think so we can specify what folder to work in...
	$WorkDir = $CmdLine[1] & "\" 
Else
	$WorkDir = @ScriptDir & "\"
EndIf

 getFileList($WorkDir)

Func getFileList($folderName)
 Local $fileArray, $i, $fullFilePath, $fileAttributes, $DIRTODEL
 $fileArray = _FileListToArray($folderName)
 If Not IsArray($fileArray) Then Return 1 ;This can be replaced by line 18-21 that way the function is not even called if the dir is empty.

For $i=1 To $fileArray[0]
	 $fullFilePath = $folderName & "\" & $fileArray[$i] ;retrieve the full path
	 $fileAttributes = FileGetAttrib($fullFilePath)
	If StringInStr($fileAttributes,"D") Then ;folder, have to explore
		;If $fullFilePath Not EmptyDir Then
				getFileList($fullFilePath)
		;End If
		;Return 1
		
		;### Old stuff we don't need ###
		;Dim $tempArray = getFileList($fullFilePath) ;recursive call - runs the getFileList function again saves in a temp array so it can be added to filePatchArray
		;_ArrayConcatenate($filePathArray,$tempArray,1) ;add returned results to already found files - adds data to the filePathArray which we don't need - for _ArrayDisplay only
		;### END OLD ###
	Else ;file
		If StringLower(StringRight($fileArray[$i], 3)) = "rar" Then
			RunWait("uniextract.exe" & ' "' & $FullFilePath & '"' & " " & "..\", $WorkDir, @SW_HIDE); unzip
			$DIR = StringSplit($fullFilePath, "\")
			For $c=1 To $DIR[0]-1
				$DIRTODEL &= $DIR[$c] & "\"
			Next
			DirRemove($DIRTODEL,1)
		EndIf
	EndIf
Next
 ;$filePathArray[0] = UBound($filePathArray) - 1 ;adjust the size of the array - this was to fix the _ArrayDisplay so it displays the data correctly
EndFunc
