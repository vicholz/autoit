
#Region
#AutoIt3Wrapper_icon=installr.ico
#AutoIt3Wrapper_outfile=installr.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Installr
#AutoIt3Wrapper_Res_Description=Easily install programs with a click of a button
#AutoIt3Wrapper_Res_Fileversion=1.1.2.0
#EndRegion
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_MINIMIZE = -4
Global Const $GUI_EVENT_RESTORE = -5
Global Const $GUI_EVENT_MAXIMIZE = -6
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
Global Const $GUI_EVENT_SECONDARYDOWN = -9
Global Const $GUI_EVENT_SECONDARYUP = -10
Global Const $GUI_EVENT_MOUSEMOVE = -11
Global Const $GUI_EVENT_RESIZED = -12
Global Const $GUI_EVENT_DROPPED = -13
Global Const $GUI_RUNDEFMSG = "GUI_RUNDEFMSG"
Global Const $GUI_AVISTOP = 0
Global Const $GUI_AVISTART = 1
Global Const $GUI_AVICLOSE = 2
Global Const $GUI_CHECKED = 1
Global Const $GUI_INDETERMINATE = 2
Global Const $GUI_UNCHECKED = 4
Global Const $GUI_DROPACCEPTED = 8
Global Const $GUI_NODROPACCEPTED = 4096
Global Const $GUI_ACCEPTFILES = $GUI_DROPACCEPTED
Global Const $GUI_SHOW = 16
Global Const $GUI_HIDE = 32
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128
Global Const $GUI_FOCUS = 256
Global Const $GUI_NOFOCUS = 8192
Global Const $GUI_DEFBUTTON = 512
Global Const $GUI_EXPAND = 1024
Global Const $GUI_ONTOP = 2048
Global Const $GUI_FONTITALIC = 2
Global Const $GUI_FONTUNDER = 4
Global Const $GUI_FONTSTRIKE = 8
Global Const $GUI_DOCKAUTO = 1
Global Const $GUI_DOCKLEFT = 2
Global Const $GUI_DOCKRIGHT = 4
Global Const $GUI_DOCKHCENTER = 8
Global Const $GUI_DOCKTOP = 32
Global Const $GUI_DOCKBOTTOM = 64
Global Const $GUI_DOCKVCENTER = 128
Global Const $GUI_DOCKWIDTH = 256
Global Const $GUI_DOCKHEIGHT = 512
Global Const $GUI_DOCKSIZE = 768
Global Const $GUI_DOCKMENUBAR = 544
Global Const $GUI_DOCKSTATEBAR = 576
Global Const $GUI_DOCKALL = 802
Global Const $GUI_DOCKBORDERS = 102
Global Const $GUI_GR_CLOSE = 1
Global Const $GUI_GR_LINE = 2
Global Const $GUI_GR_BEZIER = 4
Global Const $GUI_GR_MOVE = 6
Global Const $GUI_GR_COLOR = 8
Global Const $GUI_GR_RECT = 10
Global Const $GUI_GR_ELLIPSE = 12
Global Const $GUI_GR_PIE = 14
Global Const $GUI_GR_DOT = 16
Global Const $GUI_GR_PIXEL = 18
Global Const $GUI_GR_HINT = 20
Global Const $GUI_GR_REFRESH = 22
Global Const $GUI_GR_PENSIZE = 24
Global Const $GUI_GR_NOBKCOLOR = -2
Global Const $GUI_BKCOLOR_DEFAULT = -1
Global Const $GUI_BKCOLOR_TRANSPARENT = -2
Global Const $GUI_BKCOLOR_LV_ALTERNATE = -33554432
Global Const $GUI_WS_EX_PARENTDRAG = 1048576
Opt("MustDeclareVars", 0)
Opt("TrayIconHide", 1)
$SINGLEQUOTE = Chr(39)
$DOUBLEQUOTE = Chr(34)
$TEMPDIR = @TempDir & "\"
$TEMPDIRINSTALLR = @TempDir & "\installr\"
$TEMPDIRWGET = @TempDir & "\wget.exe"
If Not FileExists($TEMPDIRINSTALLR) Then
	Do
		DirCreate($TEMPDIRINSTALLR)
	Until FileExists($TEMPDIRINSTALLR)
EndIf
If FileExists($TEMPDIR & "install.bat") Then
	FileDelete($TEMPDIR & "install.bat")
Else
EndIf
$BATCHFILE = $TEMPDIR & "install.bat"
$FILE = FileOpen($BATCHFILE, 2)
If $FILE = -1 Then
	MsgBox(0, "Error", "Unable to open file.")
	Exit
EndIf
FileWrite($FILE, "@ECHO OFF" & @CRLF)

Func _INETGETSOURCE($S_URL, $S_HEADER = "")
	If StringLeft($S_URL, 7) <> "http://"  And StringLeft($S_URL, 8) <> "https://"  Then $S_URL = "http://" & $S_URL
	Local $H_DLL = DllOpen("wininet.dll")
	Local $AI_IRF, $S_BUF = ""
	Local $AI_IO = DllCall($H_DLL, "int", "InternetOpen", "str", "AutoIt v3", "int", 0, "int", 0, "int", 0, "int", 0)
	If @error Or $AI_IO[0] = 0 Then
		DllClose($H_DLL)
		SetError(1)
		Return ""
	EndIf
	Local $AI_IOU = DllCall($H_DLL, "int", "InternetOpenUrl", "int", $AI_IO[0], "str", $S_URL, "str", $S_HEADER, "int", StringLen($S_HEADER), "int", -2147483648, "int", 0)
	If @error Or $AI_IOU[0] = 0 Then
		DllCall($H_DLL, "int", "InternetCloseHandle", "int", $AI_IO[0])
		DllClose($H_DLL)
		SetError(1)
		Return ""
	EndIf
	Local $V_STRUCT = DllStructCreate("udword")
	DllStructSetData($V_STRUCT, 1, 1)
	While DllStructGetData($V_STRUCT, 1) <> 0
		$AI_IRF = DllCall($H_DLL, "int", "InternetReadFile", "int", $AI_IOU[0], "str", "", "int", 256, "ptr", DllStructGetPtr($V_STRUCT))
		$S_BUF &= StringLeft($AI_IRF[2], DllStructGetData($V_STRUCT, 1))
	WEnd
	DllCall($H_DLL, "int", "InternetCloseHandle", "int", $AI_IOU[0])
	DllCall($H_DLL, "int", "InternetCloseHandle", "int", $AI_IO[0])
	DllClose($H_DLL)
	Return $S_BUF
EndFunc


Func WGETWRITE($WGETURL, $WGETNAME)
	FileWrite($FILE, "echo ***** Start downloading " & $WGETNAME & " *****" & @CRLF)
	FileWrite($FILE, $TEMPDIRWGET & " --no-check-certificate --directory-prefix=" & $DOUBLEQUOTE & $TEMPDIRINSTALLR & $WGETNAME & $DOUBLEQUOTE & " " & $DOUBLEQUOTE & $WGETURL & $DOUBLEQUOTE & @CRLF)
EndFunc


Func EXECPROGRAM($PROGRAMNAME)
	FileWrite($FILE, "cd " & $DOUBLEQUOTE & $TEMPDIRINSTALLR & $PROGRAMNAME & $DOUBLEQUOTE & @CRLF)
	FileWrite($FILE, "FOR %%s IN (*.exe) DO " & Chr(34) & "%%s" & Chr(34) & @CRLF)
EndFunc


Func VERSIONTRACKERGET($URL, $NAME)
	$SOURCE = _INETGETSOURCE($URL)
	$XPIREGEXP = "<a href=" & $DOUBLEQUOTE & "(.*\.exe.*)" & $DOUBLEQUOTE & " title=" & $DOUBLEQUOTE & ".*?" & $DOUBLEQUOTE & "><"
	$RET = StringRegExp($SOURCE, $XPIREGEXP, 1)
	$SOURCEDL = _INETGETSOURCE($RET[0])
	$XPIREGEXPDL = "window.location.href = " & $SINGLEQUOTE & "(.*\.exe)" & $SINGLEQUOTE & ""
	$RETDL = StringRegExp($SOURCEDL, $XPIREGEXPDL, 1)
	$URLVALUE = $RETDL[0]
	WGETWRITE($URLVALUE, $NAME)
	Return $URLVALUE
EndFunc

_MAIN()

Func _MAIN()
	$LABELNUMBER = 17
	$WINDOWHEIGHT = $LABELNUMBER * 20 + 100
	$BUTTONHEIGHT = $WINDOWHEIGHT - 60
	GUICreate("installr", 160, $WINDOWHEIGHT)
	GUICtrlCreateLabel("What to install?", 10, 10)
	$HEIGHT = 30
	$BOX_FIREFOX = GUICtrlCreateCheckbox("Mozilla Firefox", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_FFEX = GUICtrlCreateCheckbox("Firefox Extensions", 15, $HEIGHT, 106, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_WINRAR = GUICtrlCreateCheckbox("7-Zip", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_WLM = GUICtrlCreateCheckbox("Live Messenger", 15, $HEIGHT, 130, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_CCCP = GUICtrlCreateCheckbox("Media Coder", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_UTORRENT = GUICtrlCreateCheckbox("uTorrent", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_NPP = GUICtrlCreateCheckbox("Notepad++", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_IMGB = GUICtrlCreateCheckbox("IMGBurn", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_FLASH = GUICtrlCreateCheckbox("Adobe Flash Player", 15, $HEIGHT, 120, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_AVIRA = GUICtrlCreateCheckbox("AutoRuns", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_WINAMP = GUICtrlCreateCheckbox("Winamp", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_PUTTY = GUICtrlCreateCheckbox("PuTTY", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_FOXIT = GUICtrlCreateCheckbox("Foxit Reader", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_KEEPASS = GUICtrlCreateCheckbox("Google Video", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_DAEMON = GUICtrlCreateCheckbox("Daemon Tools Lite", 15, $HEIGHT, 120, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_NET = GUICtrlCreateCheckbox(".NET Framework", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$BOX_DEBUG = GUICtrlCreateCheckbox("Debug", 15, $HEIGHT, 97, 17)
	$HEIGHT = $HEIGHT + 20
	$INSTALLBUTTON = GUICtrlCreateButton("Install", 10, $BUTTONHEIGHT, 65, 20)
	$EXITID = GUICtrlCreateButton("Exit", 85, $BUTTONHEIGHT, 65, 20)
	GUICtrlSetColor(-1, 255)
	GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
	GUISetState()
	Do
		$MSG = GUIGetMsg()
		Select
			Case $MSG = $INSTALLBUTTON
				If GUICtrlRead($BOX_FIREFOX) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10208565", "Mozilla Firefox")
				If GUICtrlRead($BOX_FFEX) = 1 Then
					$HEIGHT = 30
					$LABELNUMBER = 8
					$WINDOWHEIGHT = $LABELNUMBER * 20 + 65
					$BUTTONHEIGHT = $WINDOWHEIGHT - 30
					$FFBOX = GUICreate("installr", 150, $WINDOWHEIGHT)
					GUICtrlCreateLabel("Select extensions:", 10, 10)
					$BOX_FIREFOX1 = GUICtrlCreateCheckbox("ColorZilla", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX2 = GUICtrlCreateCheckbox("Fetch Text URL", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX3 = GUICtrlCreateCheckbox("Adblock Plus", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX4 = GUICtrlCreateCheckbox("Xmarks", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX5 = GUICtrlCreateCheckbox("Speed Dial", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX6 = GUICtrlCreateCheckbox("Gmail Manager", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX7 = GUICtrlCreateCheckbox("Gmail Redesigned", 15, $HEIGHT, 130, 17)
					$HEIGHT = $HEIGHT + 20
					$BOX_FIREFOX8 = GUICtrlCreateCheckbox("Colorful Tabs", 15, $HEIGHT, 130, 17)
					$OKBUTTON = GUICtrlCreateButton("Install", 15, $BUTTONHEIGHT, 120, 20)
					GUISetState()
					Do
						$FFMSG = GUIGetMsg()
						Select
							Case $FFMSG = $OKBUTTON
								$CHECKBOXCHECK = GUICtrlRead($BOX_FIREFOX1)
								If GUICtrlRead($BOX_FIREFOX1) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/271/addon-271-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX2) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/518/addon-518-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX3) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/1865/addon-1865-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX4) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/2410/addon-2410-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX5) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/4810/addon-4810-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX6) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/1320/addon-1320-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX7) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/8434/addon-8434-latest.xpi", "FFEX")
								If GUICtrlRead($BOX_FIREFOX8) = 1 Then WGETWRITE("https://addons.mozilla.org/en-US/firefox/downloads/latest/1368/addon-1368-latest.xpi", "FFEX")
								GUIDelete($FFBOX)
						EndSelect
					Until $FFMSG = $GUI_EVENT_CLOSE Or $FFMSG = $OKBUTTON
				EndIf
				MsgBox(64, "Installr", "Locating latest versions and going to download." & @CRLF & "Please wait!")
				FileInstall("C:\Documents and Settings\Dk12057\Desktop\installr\wget.exe", $TEMPDIR, 0)
				If GUICtrlRead($BOX_WINRAR) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10007677", "WinRAR")
				If GUICtrlRead($BOX_WLM) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10450926", "Windows Live Messenger")
				If GUICtrlRead($BOX_CCCP) = 1 Then WGETWRITE("http://www.free-codecs.com/download_soft.php?d=4233&s=572", "CCCP")
				If GUICtrlRead($BOX_UTORRENT) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10528327", "uTorrent")
				If GUICtrlRead($BOX_NPP) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10327521", "Notepad-plus-plus")
				If GUICtrlRead($BOX_IMGB) = 1 Then
					$IMGSOURCE = _INETGETSOURCE("http://imgburn.com/index.php?act=download")
					$IMGXPIREGEXP = "<a href=" & $SINGLEQUOTE & "(.*\.exe)" & $SINGLEQUOTE & " target=" & $SINGLEQUOTE & "_blank.*?" & $SINGLEQUOTE & ""
					$IMGRET = StringRegExp($IMGSOURCE, $IMGXPIREGEXP, 3)
					FileWrite($FILE, "echo ***** Start downloading IMGBurn *****" & @CRLF)
					FileWrite($FILE, $TEMPDIRWGET & " --directory-prefix=IMGBurn " & $IMGRET[0] & @CRLF)
				EndIf
				If GUICtrlRead($BOX_FLASH) = 1 Then WGETWRITE("http://fpdownload.macromedia.com/get/flashplayer/current/install_flash_player.exe", "Adobe Flash")
				If GUICtrlRead($BOX_AVIRA) = 1 Then WGETWRITE("http://dl1.avgate.net/down/windows/antivir_workstation_winu_en_h.exe", "Avira")
				If GUICtrlRead($BOX_WINAMP) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10251792", "Winamp")
				If GUICtrlRead($BOX_PUTTY) = 1 Then
					FileWrite($FILE, "echo ***** Start downloading PuTTY *****" & @CRLF)
					FileWrite($FILE, $TEMPDIRWGET & " --directory-prefix=C:\ http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe" & @CRLF)
				EndIf
				If GUICtrlRead($BOX_FOXIT) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10313206", "Foxit Reader")
				If GUICtrlRead($BOX_KEEPASS) = 1 Then
					$KEESOURCE = _INETGETSOURCE("http://keepass.info/download.html")
					$KEEXPIREGEXP = '<a href="(.*\.exe)"'
					$KEERET = StringRegExp($KEESOURCE, $KEEXPIREGEXP, 3)
					FileWrite($FILE, "echo ***** Start downloading KeePass *****" & @CRLF)
					FileWrite($FILE, $TEMPDIRWGET & " --directory-prefix=KeePass " & $KEERET[0] & @CRLF)
				EndIf
				If GUICtrlRead($BOX_DAEMON) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/10778842", "Daemon Tools")
				If GUICtrlRead($BOX_NET) = 1 Then VERSIONTRACKERGET("http://www.versiontracker.com/dyn/moreinfo/win/47206", "NET Framework")
				If GUICtrlRead($BOX_FIREFOX) = 1 Then EXECPROGRAM("Mozilla Firefox")
				If GUICtrlRead($BOX_WINRAR) = 1 Then
					EXECPROGRAM("WinRAR")
				EndIf
				If GUICtrlRead($BOX_WLM) = 1 Then EXECPROGRAM("Windows Live Messenger")
				If GUICtrlRead($BOX_CCCP) = 1 Then EXECPROGRAM("CCCP")
				If GUICtrlRead($BOX_UTORRENT) = 1 Then EXECPROGRAM("uTorrent")
				If GUICtrlRead($BOX_NPP) = 1 Then EXECPROGRAM("Notepad-plus-plus")
				If GUICtrlRead($BOX_IMGB) = 1 Then EXECPROGRAM("IMGBurn")
				If GUICtrlRead($BOX_FLASH) = 1 Then EXECPROGRAM("Adobe Flash")
				If GUICtrlRead($BOX_AVIRA) = 1 Then EXECPROGRAM("Avira")
				If GUICtrlRead($BOX_WINAMP) = 1 Then EXECPROGRAM("Winamp")
				If GUICtrlRead($BOX_FOXIT) = 1 Then EXECPROGRAM("Foxit Reader")
				If GUICtrlRead($BOX_KEEPASS) = 1 Then EXECPROGRAM("KeePass")
				If GUICtrlRead($BOX_DAEMON) = 1 Then EXECPROGRAM("Daemon Tools")
				If GUICtrlRead($BOX_NET) = 1 Then EXECPROGRAM("NET Framework")
				If GUICtrlRead($BOX_FFEX) = 1 Then
					If ProcessExists("firefox.exe") Then
						MsgBox(64, "installr", "Firefox is running and must be closed to install extensions." & @CRLF & "Attempting to close firefox.")
						ProcessClose("firefox.exe")
					EndIf
					FileWrite($FILE, "cd " & $DOUBLEQUOTE & $TEMPDIRINSTALLR & "FFEX" & $DOUBLEQUOTE & @CRLF)
					FileWrite($FILE, "FOR %%s IN (*.xpi) DO " & Chr(34) & @ProgramFilesDir & "\Mozilla Firefox\firefox.exe" & Chr(34) & " -install-global-extension " & Chr(34) & "%%s" & @CRLF)
				EndIf
				If GUICtrlRead($BOX_FFEX) = 1 Then
					FileWrite($FILE, $DOUBLEQUOTE & @ProgramFilesDir & "\Mozilla Firefox\firefox.exe" & $DOUBLEQUOTE & @CRLF)
				EndIf
				If GUICtrlRead($BOX_DEBUG) = 1 Then
					FileWrite($FILE, "echo Done!" & @CRLF)
					FileWrite($FILE, "pause" & @CRLF)
				Else
					FileWrite($FILE, "rmdir " & $TEMPDIRINSTALLR & " /S /Q" & @CRLF)
				EndIf
				FileWrite($FILE, "exit" & @CRLF)
				FileClose($FILE)
				ShellExecute($BATCHFILE)
			Case $MSG = $EXITID
				DirRemove($TEMPDIRINSTALLR, 1)
		EndSelect
	Until $MSG = $GUI_EVENT_CLOSE Or $MSG = $EXITID
EndFunc