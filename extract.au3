#include <extprop.au3>
FileInstall(".\7za.exe", @TempDir & "\7za.exe")
$7Zip = @TempDir & "\7za.exe"
Opt("TrayIconHide", 0)

If $CmdLine[0] = 1 Then ; dunno why this is here... I think so we can specify what folder to work in...
	$WorkDir = $CmdLine[1] & "\" 
Else
	$WorkDir = @ScriptDir & "\"
EndIf

$search = FileFindFirstFile($WorkDir & "*.zip") ; Find all zip files
While 1
    $ZipFile = FileFindNextFile($search) ; Define current zipfile
    If @error Then ExitLoop ; exit loop if there is an error
	$Mp3Folder = CleanString(StringTrimRight($ZipFile, 4)) ; cleanup original zip file name and use it as mp3folder
	$ArrayAA = StringSplit($Mp3Folder, "-")
	RunWait($7Zip & ' e -y "' & $WorkDir & $ZipFile & '" -o"' & $WorkDir & $Mp3Folder &  '\"', $WorkDir, @SW_HIDE); unzip
	FileClose($ZipFile); close zip
	FileDelete($WorkDir & $ZipFile); delete zip
    $MP3FF = FileFindFirstFile($WorkDir & $Mp3Folder & "\*.mp3");Get first MP3 File in the $MP3Folder
	$MP3NF = FileFindNextFile($MP3FF); get next mp3 also
	If @OSVersion = "WIN_7" Then
		;Get ID3 tags of 2nd MP3 file if Win7
		$Artist = CleanString(_GetExtProperty($WorkDir & $Mp3Folder & "\" & $MP3NF, 20))
		$Album = CleanString(_GetExtProperty($WorkDir & $Mp3Folder & "\" & $MP3NF, 14))
		;MsgBox(0,"Win7 get prop",$Artist & " - " & $Album)
	Else
		;Get ID3 tags of 2nd MP3 file if XP
		$Artist = CleanString(_GetExtProperty($WorkDir & $Mp3Folder & "\" & $MP3NF, 16))
		$Album = CleanString(_GetExtProperty($WorkDir & $Mp3Folder & "\" & $MP3NF, 17))
		;MsgBox(0,"XP get prop",$Artist & " - " & $Album)
	EndIf
	
	;Check what got returned by GetExtProperty and use file/folder name as $Artist/$Album if GetExtProp returned crap
	If $Artist = "Authors" Then
		$Artist = $ArrayAA[1]
		;MsgBox(0,"Using Delims because GetExt for Artist didn't work or ID3 is missing",$Artist & " - " & $Album)
	EndIf
	If $Album = "Album" Then
		$Album = $ArrayAA[2]
		;MsgBox(0,"Using Delims because GetExt for Album didn't work or ID3 is missing",$Artist & " - " & $Album)
	EndIf
	;MsgBox(0,"Before renaming getting Artist/Album",$Artist & " - " & $Album)
	FileMove($WorkDir & $Mp3Folder & "\*.*", $WorkDir & $Artist & "\" & $Album & "\", 8); Move all mp3 files to Artist/Album folder (creating them if they don't exist)
	FileClose($MP3FF) ; close first mp3 file
	FileClose($MP3NF) ; close second mp3 file
	DirRemove($WorkDir & $Mp3Folder, 1) ; remove extract to dir
WEnd

Func CleanString($sString)
	$sString = StringReplace($sString, "__", " ")
    $sString = StringReplace($sString, "_", " ")
	$sString = StringStripWS($sString, 7) ; remove extra spaces left over
	$sString = StringRegExpReplace($sString, "(?i)[^a-z0-9.-'&]", "") ; remove invalid chars
	Return $sString ; return clean string
EndFunc

MsgBox(0,"Extract","Done.")