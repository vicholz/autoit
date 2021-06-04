;*****************************************************************************************************************************************************
;  Gui to populate 3 listview boxes based on txt files in the script directory.  In this example, the command run on the selected items is just a ping,
;  but I have commented out a scheduled task which is the real purpose this script written.  before function is called to actually run the command,
;  a window will pop up - "Are you sure?".  The user is required to click "YES", and then another window pops up requiring the user to type in a
;  random string (generated and displayed in the title bar.)   A progress bar is displayed, and the gui is updated to reflect the current item in the
;  array (actually an array that has been piped into a textfile with duplicates removed).  A log file is created to show success' and errors.
;******************************************************************************************************************************************************

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPI.au3>
#Include <GuiListView.au3>
#include <GuiListBox.au3>
#include <Misc.au3>
#include <ProgressConstants.au3>

AutoItSetOption("ExpandEnvStrings", 1)

Global $schedtask_xml ; declare variables

Dim $listofall, $listofall_array, $listofMD, $listofMD_array, $listofPODS, $listofPODS_array, $active_list_array, $stuff, $current_item, $sure, $GO_final, $final, $yes_input, $pcname, $progress_dlg, $Skip, $error_log, $log_info, $text ; declare variables

$text = ""
$pcname = ""
$listofall = @ScriptDir & "\all.txt"
$listofMD = @ScriptDir & "\md.txt"
$listofPODS = @ScriptDir & "\pods.txt"
$status = "SWC Shell"
$active_list = @ScriptDir & "\activelist.txt"
$error_log = @ScriptDir & "\error_log.txt"

Opt("GUIOnEventMode", 1)


;****************************************************
;  Create main gui with listviews populated by arrays
;****************************************************

$Form2 = GUICreate("BIG.RED.BUTTON - Ping Test", 687, 442)
GUISetBkColor(0x7A7A7A)
$ButtonOk = GUICtrlCreateButton("BIG.RED.BUTTON", 28, 290, 627, 137, $BS_DEFPUSHBUTTON)
GUICtrlSetFont(-1, 60, 400, 0, "Agency FB")
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetOnEvent(-1, "_CreateNewChild")
GuiCtrlSetState(-1,$GUI_ONTOP)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")

;---------------------------------------------------
; Radio buttons, position and function assigment
;---------------------------------------------------

$Radio1 = GUICtrlCreateRadio("Local Admin", 32, 256, 213, 17)
GUICtrlSetFont(-1, 16, 400, 0, "Vrinda")
GUICtrlSetOnEvent(-1, "RadioSelect_la")
$Radio2 = GUICtrlCreateRadio("SWC Shell", 530, 256, 123, 17, BitOR($GUI_SS_DEFAULT_RADIO,$BS_RIGHTBUTTON))
GUICtrlSetFont(-1, 16, 400, 0, "Vrinda")
GUICtrlSetOnEvent(-1, "RadioSelect_ss")
GuiCtrlSetState($radio2, 1)

;-----------------------------------------------------
;  /end Radio buttons, position and function assigment
;-----------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Listview creation, populated by text files piped
; arrays.  variables defined at top.
;---------------------------------------------------

$ALLPCs = GUICtrlCreateListView("ALL PC'S", 25, 41, 154, 160, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 133)

_FileReadToArray($listofall, $listofall_array)

$Port_Array_Limit = UBound($listofall_array) - 1
For $i = 1 To $Port_Array_Limit
    $populate_all_box = String($listofall_array[$i])
    GUICtrlCreateListViewItem($populate_all_box, $ALLPCs)
Next

$MDWorkstations = GUICtrlCreateListView("MD Workstations", 270, 41, 154, 160, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 133)

_FileReadToArray($listofMD, $listofMD_array)

$Port_Array_Limit = UBound($listofMD_array) - 1
For $i = 1 To $Port_Array_Limit
    $populate_MD_box = String($listofMD_array[$i])
    GUICtrlCreateListViewItem($populate_MD_box, $MDWorkstations)
Next

$PODS = GUICtrlCreateListView("PODS", 505, 41, 154, 160, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 133)

_FileReadToArray($listofPODS, $listofPODS_array)

$Port_Array_Limit = UBound($listofPODS_array) - 1
For $i = 1 To $Port_Array_Limit
    $populate_PODS_box = String($listofPODS_array[$i])
    GUICtrlCreateListViewItem($populate_PODS_box, $PODS)
Next

;---------------------------------------------------
; /end  Listview creation
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Checkbox creation and function assignment
;---------------------------------------------------

$Checkbox1 = GUICtrlCreateCheckbox("Select ALL", 32, 216, 97, 17)
GUICtrlSetOnEvent($Checkbox1, "ALL_Select")
$Checkbox2 = GUICtrlCreateCheckbox("Select ALL", 276, 210, 97, 17)
GUICtrlSetOnEvent($Checkbox2, "MD_Select")
$Checkbox3 = GUICtrlCreateCheckbox("Select ALL", 511, 211, 97, 17)
GUICtrlSetOnEvent($Checkbox3, "PODS_Select")
GUISetState(@SW_SHOW)

;---------------------------------------------------
; /end  Checkbox creation and function assignment
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


GUISwitch($form2) ; Allow switching between GUI's


While 1              ;--------------------------------
    Sleep(100)       ; Keep GUI alive
WEnd                 ;--------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Function called on 'Press Enter' button
;
; 	** removes working "templist.txt" file to ensure the
; 	   integrity of the final "activelist.txt"
;	** sets "status" variable based on radio button
;	   selection
;	** grabs selected items from all listviews, writes
;	   each item to $complete_list variable (templist.txt)
;	** writes all unique entries to $active_list
;	   (activelist.txt) - any duplicates are removed
;---------------------------------------------------

Func ButtonEnterClick()
	FileDelete(@ScriptDir & "\templist.txt")
	GUISetState(@SW_HIDE,$sure)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
	If $status = "Local Admin" Then
		$schedtask_xml = @ScriptDir & "\localreboot.xml"
		$log_info = "pingity...ping...ping..ping"
	ElseIf $status = "SWC Shell" Then
		$schedtask_xml = @ScriptDir & "\swcshellreboot.xml"
		$log_info = "pingity...ping...ping..ping"
	EndIf
	$complete_list = @ScriptDir & "\templist.txt"

    Local $aSelcted, $aDdata
    $aSelcted = _GUICtrlListView_GetSelectedIndices($ALLPCs, True)
    If $aSelcted[0] > 0 Then
        Dim $aDdata[$aSelcted[0] + 1]
        $aDdata[0] = $aSelcted[0]
        For $i = 1 To $aSelcted[0]
            $aDdata[$i] = _GUICtrlListView_GetItemTextString($ALLPCs, $aSelcted[$i])
			FileWrite($complete_list, $aDdata[$i] & @CRLF)
        Next
    EndIf

	    Local $mdSelcted, $mdDdata
    $mdSelcted = _GUICtrlListView_GetSelectedIndices($MDWorkstations, True)
    If $mdSelcted[0] > 0 Then
        Dim $mdDdata[$mdSelcted[0] + 1]
        $mdDdata[0] = $mdSelcted[0]
        For $i = 1 To $mdSelcted[0]
            $mdDdata[$i] = _GUICtrlListView_GetItemTextString($MDWorkstations, $mdSelcted[$i])
			FileWrite($complete_list, $mdDdata[$i] & @CRLF)
        Next
    EndIf

	    Local $podsSelcted, $podsDdata
    $podsSelcted = _GUICtrlListView_GetSelectedIndices($PODS, True)
    If $podsSelcted[0] > 0 Then
        Dim $podsDdata[$podsSelcted[0] + 1]
        $podsDdata[0] = $podsSelcted[0]
        For $i = 1 To $podsSelcted[0]
            $podsDdata[$i] = _GUICtrlListView_GetItemTextString($PODS, $podsSelcted[$i])
			FileWrite($complete_list, $podsDdata[$i] & @CRLF)
        Next
    EndIf

    ;If IsArray($aDdata) Then _ArrayDisplay($aDdata)
	Dim $oFile,$nFile
	_FileReadToArray($complete_list,$oFile)
	$nFile = _ArrayUnique($oFile,1, 1)
	_FileWriteFromArray($active_list,$nFile, 1)

	_dialogue()


EndFunc

;---------------------------------------------------
; /end  'Press Enter' function
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Function called on clicking the "X" in the GUI
;---------------------------------------------------

Func Form2Close()
	If @GUI_WINHANDLE = $form2 Then
		Exit
	Elseif @GUI_WinHandle = $sure Then
		GUISetState(@SW_HIDE,$sure)
	Elseif @GUI_WinHandle = $Final Then
		GUISetState(@SW_HIDE, $Final)
	ElseIf @GUI_WinHandle = $progress_dlg Then
		GUISetState(@SW_HIDE, $progress_dlg)
	EndIf
EndFunc

;---------------------------------------------------
; /end  Function called on clicking the "X" in the GUI
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Function called when the BIG.RED.BUTTON is clicked
; simple "YES" :: "NO"  dialogue box
;---------------------------------------------------

Func _CreateNewChild()
	$sure = GUICreate("Are you sure?", 323, 95, -1, -1)
	;Random(
	$Yes1 = GUICtrlCreateButton("YES", 16, 16, 75, 57)
	GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, 0x00FF00)
	$No2 = GUICtrlCreateButton("NO", 232, 16, 75, 57)
	GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, 0xFF0000)
	GUISetState(@SW_SHOW)
	GUICtrlSetOnEvent($Yes1, "_CreateFinalWindow")
	GUICtrlSetOnEvent($no2, "Form2Close")
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")

EndFunc

;---------------------------------------------------
; /end  Function called when the BIG.RED.BUTTON...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Function called when the 'YES' is clicked from the
; "Are you sure?" dialogue box
;
; 	** Random 6 character word created, saved to
;	   $text variable.
;	** $text variable used in the window title
;	** Input box created, user needs to type the
;	   string that shows in the title bar
;	** when the "Press Enter" button is called, the
;	   _readinput Function is called
;---------------------------------------------------

Func _CreateFinalWindow()
	For $i = 65 to 70
		$text = $text & Chr(Random(Asc("a"), Asc("z"), 1))
	Next
	$Final = GUICreate("Type " & "' " & $text & " '" & " to confirm...", 600, 366, -1, -1)
	$yes_input = GUICtrlCreateInput("", 152, 88, 257, 73)
	GUICtrlSetFont(-1, 40, 800, 0, "Verdana")
	$GO_final = GUICtrlCreateButton("Press 'Enter'", 184, 208, 181, 81)
	GUICtrlSetFont(-1, 30, 400, 0, "Agency FB")
	GUICtrlSetBkColor(-1, 0x00FF00)
	GUISetState(@SW_SHOW)
	GUICtrlSetOnEvent($GO_final, "_readinput")
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
	$dll = DllOpen("user32.dll")

	While 1
		Sleep (100)
			If _IsPressed("0D", $dll) Then
			_readinput()
			ExitLoop
		EndIf
	WEnd
	DllClose($dll)

EndFunc

;---------------------------------------------------
; /end  Function called when the "Yes" button...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
; Function called when the "Press Enter" button is
; clicked
;
;	** Verifies that the input button matches the
;	   random string created in the _CreateFinalWindow
;	   function.  If it doesn't match, you will get
;	   reprimanded.  And the random string will change.
;	   The previous function will be re-called.
;---------------------------------------------------

Func _readinput()
	Form2Close()
	$informat = GUICtrlRead($yes_input)
	If $informat = $text Then
		GUISetState(@SW_HIDE, $final)
		ButtonEnterClick()
	ElseIf $informat <> $text Then
		GUISetState(@SW_HIDE, $final)
		MsgBox(4096, "!", "FAILURE to follow instructions." & @crlf & @crlf & "You apparently cannot read." & @crlf & @crlf & "Please try again.  Now the string is different." & @crlf & @crlf & "...Good luck")
		$text = ""
		_CreateFinalWindow()
	EndIf
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
EndFunc

;---------------------------------------------------
; /end  Function called when the "Press 'Enter'"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "Local Admin" radio
;  button is selected.
;
;	** Sets $status variable
;	** Removes activelist.txt to ensure that you
;	   only run the command against the current
;	   selection.
;---------------------------------------------------

Func RadioSelect_la()
    Global $status = GUICtrlRead($Radio1, 1)
	FileDelete(@ScriptDir & "\activelist.txt")
EndFunc

;---------------------------------------------------
; /end  Function called when the "Local Admin"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "SWC Shell" radio
;  button is selected.
;
;	** Sets $status variable
;---------------------------------------------------

Func RadioSelect_ss()
    Global $status = GUICtrlRead($Radio2, 1)
EndFunc

;---------------------------------------------------
; /end  Function called when the "SWC Shell"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "Select ALL" checkbox
;  underneath the "ALL" list is checked.
;
;	**  Checks the status of the checkbox and either
;	    selects all, or unselects all
;---------------------------------------------------

Func ALL_Select()
	If GUICtrlRead($Checkbox1) = 1 Then
		$selected = True
	ElseIf GUICtrlRead($Checkbox1) = 4 Then
		$selected = False
	EndIf
	For $i = 0 To _GUICtrlListView_GetItemCount($ALLPCs)
    _GUICtrlListView_SetItemSelected($ALLPCs, $i, $selected)
	Next

EndFunc

;---------------------------------------------------
; /end  Function called when the "Select ALL"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "Select ALL" checkbox
;  underneath the "MD Workstations" list is checked.
;
;	**  Checks the status of the checkbox and either
;	    selects all, or unselects all
;---------------------------------------------------

Func MD_Select()
	If GUICtrlRead($Checkbox2) = 1 Then
		$selected = True
	ElseIf GUICtrlRead($Checkbox2) = 4 Then
		$selected = False
	EndIf
	For $i = 0 To _GUICtrlListView_GetItemCount($MDWorkstations)
    _GUICtrlListView_SetItemSelected($MDWorkstations, $i, $selected)
	Next

EndFunc

;---------------------------------------------------
; /end  Function called when the "Select ALL"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "Select ALL" checkbox
;  underneath the "PODS" list is checked.
;
;	**  Checks the status of the checkbox and either
;	    selects all, or unselects all
;---------------------------------------------------

Func PODS_Select()
	If GUICtrlRead($Checkbox3) = 1 Then
		$selected = True
	ElseIf GUICtrlRead($Checkbox3) = 4 Then
		$selected = False
	EndIf
	For $i = 0 To _GUICtrlListView_GetItemCount($PODS)
    _GUICtrlListView_SetItemSelected($PODS, $i, $selected)
	Next

EndFunc

;---------------------------------------------------
; /end  Function called when the "Select ALL"...
;---------------------------------------------------

;///////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;---------------------------------------------------
;  Function called when the "Press 'Enter'" button
;  is pressed on the _CreateFinalWindow function and
;  after passing the input box verification.
;
;	** Creates progress bar with update field,
;	   $dynamic_name
;	** Reads activelist.txt to array, begins processing
;	   each line.
;	** Checks to verify that the computer is "alive"
;	   by pinging, if ping returns no error, then the
;	   command is run for that array item and a line
;	   item is written to the error_log.txt indicating
;	   "Success" and whether it was set to "Local Admin"
;	   or "SWC Shell".
;	   if the ping returns an error, then a line item
;	   is written to the error_log.txt indicating
;	   FAILURE
;---------------------------------------------------

Func _dialogue()
	local $Progress1
	$progress_dlg = GUICreate("Please wait...", 603, 227, -1, -1)
	$Progress1 = GUICtrlCreateProgress(56, 24, 494, 32, $PBS_SMOOTH)
	GUICtrlSetBkColor(-1, 0xA6CAF0)
	GUICtrlSetCursor (-1, 15)
	$static_info = GUICtrlCreateLabel("Please wait...processing list...currently on:  ", 72, 72, 364, 26)
	GUICtrlSetFont(-1, 14, 400, 0, "arial")
	$dynamic_name = GUICtrlCreateLabel($pcname, 464, 72, 72, 26)
	GUICtrlSetFont(-1, 14, 400, 0, "arial")
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")

	_FileReadToArray($active_list, $active_list_array)

	For $i=1 To $active_list_array[0] ; read array line by line
		$Temp = String($active_list_array[$i])
		$pcname = $Temp
		GUICtrlSetData($dynamic_name, $pcname)
		GUICtrlSetData($progress1, $i)
		$alive = Ping($pcname)
		If $alive Then
			;RunWait("schtasks" & " /create /s " & $pcname & " /u " & $pcname & "\administrator /p phome2 /tn localreboot /xml" & ' "' & $schedtask_xml & '"' & " /f /ru " & $pcname & "\administrator /rp phome2", "", @SW_HIDE)
			Run("ping" & " " & $pcname, "", @SW_HIDE)
			FileWrite($error_log, $pcname & " - SUCCESS - " & $log_info & @CRLF)
			While ProcessExists("ping.exe") <> 0
				Sleep(100)
			WEnd
		Else
			FileWrite($error_log, $pcname & " - ERROR! - " & "Possibly not online?" & " - Error:" & @error & " - " & $log_info & " FAILED" & @CRLF)
		EndIf
	Next

	$text = ""

	Guictrlsetdata($progress1, 100)
	GUICtrlSetData($static_info, "Finished.")
	GUICtrlSetData($dynamic_name, "")
	$Skip = GUICtrlCreateButton("Close", 456, 120, 91, 41)
	;GUICtrlSetData($Skip, "Close")
	GUICtrlSetOnEvent($Skip, "Form2Close")
	GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")
	Sleep(3000)

EndFunc

;---------------------------------------------------
; /end  Function called when the "Press Enter"...
;---------------------------------------------------
