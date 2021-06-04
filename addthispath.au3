; ----------------------------------------------------------------------------
;
; AutoIt Version:	3.1.1
; Script Version:	1.2_mod - Modded for adding current path.
; Author:			Jared Breland <jbreland@legroom.net>
; Homepage:			http://www.legroom.net/mysoft
;
; Script Function:
;	Modify system path
;		Full add/remove support for Windows NT-based systems
;		Full add, limited remove support for Win 9x systems
;
; ----------------------------------------------------------------------------

; declare variables
dim $oldpath, $newpath

; check for valid input
if $cmdline[0] < 1 then
	msgbox(0, "Modify Path", "Usage:" & @CRLF & "modpath.exe {/add | /del}")
	exit
endif

if $cmdline[0] > 1 then
	msgbox(0, "Modify Path", "Usage:" & @CRLF & "modpath.exe {/add | /del}")
	exit
endif

; process for Win 9x
if @OSType == "WIN32_WINDOWS" then
	; exit if delete - processing all possible options is too complicated

	; convert to short name
	$dir = filegetshortname(@ScriptDir)

	; if file exists, search for duplicate entry
	if fileexists("c:\autoexec.bat") then
		
		; get file into array
		dim $i = 0
		dim $aExecArr[$i+1]
		$autoexec = fileopen("c:\autoexec.bat", 0)
		$line = filereadline($autoexec)
		do
			$aExecArr[$i] = $line
			$i = $i + 1
			redim $aExecArr[$i+1]
			$line = filereadline($autoexec)
		until @ERROR
		redim $aExecArr[$i]
		fileclose($autoexec)
		
		; search through array for existing entry
		for $i = 0 to ubound($aExecArr)-1
			if $cmdline[1] = "/add" then
				; if duplicate found, exit
				if stringinstr($aExecArr[$i], $dir, 0) then
					exit
				endif
			else
				; if the duplicate entry matches what we set at install, delete
				if stringinstr($aExecArr[$i], "SET PATH=%PATH%;" & $dir) then
					$aExecArr[$i] = ''
				endif
			endif
		next
	endif

	; if duplicate not found, or file didn't exist, (create and) append path
	if $cmdline[1] = "/add" then
		$autoexec = fileopen("c:\autoexec.bat", 1)
		filewriteline($autoexec, @CRLF & "SET PATH=" & $dir & ";%PATH%" )
		fileclose($autoexec)

	; If removing, write out the full autoexec from array
	else
		$autoexec = fileopen("C:\AUTOEXEC.BAT", 2)
		for $i = 0 to ubound($aExecArr)-1
			filewriteline($autoexec, $aExecArr[$i])
		next
		fileclose($autoexec)
	endif

; process for NT
elseif @OSType == "WIN32_NT" then
	$oldpath = stringsplit(regread("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path"), ";")

	; tokenize path, look for existing entry
	for $i = 1 to ubound($oldpath)-1
		if @ScriptDir = $oldpath[$i] then
			; when adding, skip if directory is already in path
			if $cmdline[1] = "/add" then
				exit
			; when deleting, drop directory
			elseif $cmdline[1] = "/del" then
				continueloop
			endif
		endif
		if $i = 1 then
			$newpath = $oldpath[$i]
		else
			$newpath = $newpath & ";" & $oldpath[$i]
		endif
	next

	; when adding, add to path
	if $cmdline[1] = "/add" then $newpath = @ScriptDir & ";" & $newpath

	; write new path
	regwrite("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path", "REG_EXPAND_SZ", $newpath)
endif

; update system environment
envupdate()
