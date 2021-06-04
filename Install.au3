#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.10.0
 Author:         Victor Holz

 Script Function:
	Installer for RGS QA Histo Apps.

#ce ----------------------------------------------------------------------------
$Answer = MsgBox(36, "QA Histo Applications Installer", "This will install ant 1.6.5, and JDK 1.5.0_14, and configure bitkeeper and other files/folders for QA Histo's. Continue?")
If $Answer = 7 Then
	Exit
EndIf

;### Create Directory Structure ###
DirCreate("C:\BKroot\gs_rgs\tmp_build\gameenv\histo_results")

;### Copying files ###
Filecopy(".\buildconf\*", "C:\BKroot\gs_rgs\buildconf\", 9)
Filecopy(".\tools\clone.bat", "C:\BKroot\gs_rgs\", 1)
Filecopy(".\readme.txt", "C:\BKroot\gs_rgs\", 1)
Filecopy(".\tools\modscripts.bat", "C:\BKroot\gs_rgs\", 1)

;### Creating Shortcuts ###
FileCreateShortcut("C:\BKroot\gs_rgs\", "%USERPROFILE%\Desktop\BK-gs_rgs.lnk", "C:\BKroot\gs_rgs\")
FileCreateShortcut("C:\BKroot\gs_rgs\tmp_build\gameenv\histo_results\", "C:\BKroot\gs_rgs\Histo_Results.lnk", "C:\BKroot\gs_rgs\tmp_build\gameenv\histo_results\")
FileCreateShortcut("C:\BKroot\gs_rgs\repo_rgs_tools\EAR\game\math_models\", "C:\BKroot\gs_rgs\Games.lnk", "C:\BKroot\gs_rgs\repo_rgs_tools\EAR\game\math_models\")

;### Install ant 1.6.5 ###
RunWait(".\ant\apache-ant-1.6.5.exe")

;### Add ant to PATH ###
RunWait(".\tools\modpath.exe /add C:\apache-ant-1.6.5\bin")

;### Install JDK 1.5.0_14 ###
MsgBox(0, "Launching JDK 1.5.0_14 Installer...", "Setup will now launch the JDK installer. Please complete the installation.")
RunWait(".\jdk\jdk-1_5_0_14-windows-i586-p.exe")

;### Add Java to PATH ###
RunWait('.\tools\modpath.exe /add "C:\Program Files\Java\jdk1.5.0_14\bin"')

;### Set JAVA_HOME ###
ShellExecuteWait(".\tools\javahome.vbs", '"C:\Program Files\Java\jdk1.5.0_14"')

;### BK Clone? ###
$Answer = MsgBox(36, "BK Clone?", "Do you want to do a 'bk clone' of the repos's required for histo's?")
If $Answer = 6 Then
	RunWait("C:\BKroot\gs_rgs\clone.bat", "C:\BKroot\gs_rgs\")
	RunWait("C:\BKroot\gs_rgs\modscripts.bat", "C:\BKroot\gs_rgs\")
EndIf

Msgbox(64, "Install is Complete!", "Installation is complete. Please see the README.TXT to for build script configuration and histo information.")