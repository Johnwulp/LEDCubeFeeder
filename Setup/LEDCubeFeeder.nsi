#Unicode True
!define APPNAME "LEDCubeFeeder"
!define COMPANYNAME "John van der Wulp"
!define DESCRIPTION "Feeds CPU Load and Temp data to UDP"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0
!define MUI_ICON "src\led.ico"

!define VERSION "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.4"

!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "TextReplace.nsh"
!include "Sections.nsh"
!include "WordFunc.nsh"

Name "${APPNAME}"
OutFile "Setup ${APPNAME} v${VERSION}.exe"
Icon "src\led.ico"
InstallDir "C:\Program Files\${APPNAME}"
VIProductVersion "${VERSION}"
VIFileVersion "${VERSION}"
VIAddVersionKey ProductName "${APPNAME}"
VIAddVersionKey FileDescription "${DESCRIPTION}"
VIAddVersionKey ProductVersion ${VERSION}
VIAddVersionKey FileVersion ${VERSION}
VIAddVersionKey LegalCopyright "${COMPANYNAME}"

RequestExecutionLevel admin
ShowInstDetails show

#Connector
Var ConIP
Var ConPort
Var ConUpdateInterval
Var ConTempSensor
Var ConCPUSensorExclusion
Var emptyResponse

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!include "LEDCubeFeeder.nsdinc"
Page custom fnc_con_Show PgPageLeaveConnector
!insertmacro MUI_PAGE_INSTFILES
#!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Function PgPageLeaveConnector
    ${NSD_GetText} $hCtl_con_ip $ConIP
    ${NSD_GetText} $hCtl_con_port $ConPort
    ${NSD_GetText} $hCtl_con_updateinterval $ConUpdateInterval
    ${NSD_GetText} $hCtl_con_tempsensor $ConTempSensor
    ${NSD_GetText} $hCtl_con_cpuexclusion $ConCPUSensorExclusion

    ${If} $ConIP == ""
        MessageBox MB_ICONEXCLAMATION "Please configure a IP"
        Abort
    ${EndIf}
    ${If} $ConPort == ""
        MessageBox MB_ICONEXCLAMATION "Please enter a port"
        Abort
    ${EndIf}
    ${If} $ConUpdateInterval == ""
        MessageBox MB_ICONEXCLAMATION "Please enter a interval"
        Abort
    ${EndIf}
	${If} $ConTempSensor == ""
        MessageBox MB_ICONEXCLAMATION "Please enter a sensorname"
        Abort
    ${EndIf}
	${If} $ConCPUSensorExclusion == ""
        MessageBox MB_ICONEXCLAMATION "Please enter a sensorname"
        Abort
    ${EndIf}
FunctionEnd

Section "install"
    SetOutPath "$INSTDIR"
    File /r src\*

    DetailPrint "Install service"
    nsExec::ExecToLog 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe "$INSTDIR\LEDCubeFeeder.exe"'

    DetailPrint "Set settings"
    #Con
    ${textreplace::ReplaceInFile} "$INSTDIR\LEDCubeFeeder.exe.config" "$INSTDIR\LEDCubeFeeder.exe.config" "ledcubeserver_value" "$ConIP" "/S=1 /C=1 /AO=1" $emptyResponse
    ${textreplace::ReplaceInFile} "$INSTDIR\LEDCubeFeeder.exe.config" "$INSTDIR\LEDCubeFeeder.exe.config" "ledcubeport_value" "$ConPort" "/S=1 /C=1 /AO=1" $emptyResponse
    ${textreplace::ReplaceInFile} "$INSTDIR\LEDCubeFeeder.exe.config" "$INSTDIR\LEDCubeFeeder.exe.config" "updateinterval_value" "$ConUpdateInterval" "/S=1 /C=1 /AO=1" $emptyResponse
    ${textreplace::ReplaceInFile} "$INSTDIR\LEDCubeFeeder.exe.config" "$INSTDIR\LEDCubeFeeder.exe.config" "sensor_temp_value" "$ConTempSensor" "/S=1 /C=1 /AO=1" $emptyResponse
    ${textreplace::ReplaceInFile} "$INSTDIR\LEDCubeFeeder.exe.config" "$INSTDIR\LEDCubeFeeder.exe.config" "sensor_cpu_exclude_value" "$ConCPUSensorExclusion" "/S=1 /C=1 /AO=1" $emptyResponse

    # Uninstall section
    writeUninstaller "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${COMPANYNAME} - ${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\led.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "HelpLink" "www.google.nl"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "EstimatedSize" 4000

    DetailPrint "Install service"
    nsExec::ExecToLog 'net start LEDCubeFeeder'
SectionEnd

section "uninstall"
    nsExec::ExecToLog 'net stop LEDCubeFeeder'
    nsExec::ExecToLog 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe -u "$INSTDIR\LEDCubeFeeder.exe"'
	delete $INSTDIR\uninstall.exe
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
	RMDir /r /REBOOTOK $INSTDIR
sectionEnd