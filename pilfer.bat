@echo off
:: **************************************************************************************
:: ** PILFER
:: ** Source: https://github.com/digitalsleuth/forensics_tools
:: ** Batch File to quickly gather basic system info & volatile network info
:: ** then dump it out to a text file called Acquisition_Results.txt. 
:: ** This script must be run as administrator.
:: ** (right click and select "Run as administrator")
:: ** rawccopy source: https://github.com/dr-anoroc/rawccopy
:: **************************************************************************************
:: ** Initial build: Cst. Percival Hall - 2013-12-20 ************************************
:: ** Current build: Corey Forman - 2025-03-02 ******************************************
:: **************************************************************************************
:: ** Version 4.0 ***********************************************************************

setlocal
set version=4.0
TITLE Pilfer v%version% - github.com/digitalsleuth
set workingdir=%~dp0
for /f "usebackq tokens=*" %%i in (`powershell -c "(Get-Date -Format \"yyyy-MM-dd HH-mm-ss\")"`) do (
     set fulldatetime=%%i
)
for /f "tokens=*" %%a in ('tzutil /g') do set tzcheck=%%a
for /f "usebackq tokens=*" %%j in (`powershell -c "(Get-TimeZone).BaseUtcOffset.TotalMinutes /60"`) do (
    set tzoffsethrs=%%j
)
set fulldate=%fulldatetime:~0,10%
set fulltime=%fulldatetime:~11,8%
set starttime=%time%
set datetime=%fulldatetime% %tzcheck% UTC %tzoffsethrs%

goto admin
:admin
    net session >nul 2>&1
    if %errorLevel% == 0 (
	    set initiation_time=Acquisition initiated at SYSTEM-TIME: %datetime%
		goto cwd
    ) else (
        echo This script requires administrator privileges. Run as admin, and try again. Exiting.
		net helpmsg 5
		PAUSE
		EXIT /B 5
)

:cwd
echo %initiation_time%
echo.
echo Your current working directory is "%workingdir:~0,-1%"
echo.
goto entername

:entername
set /p "name=Enter your name and title: "
echo.
choice /c yn /M "You entered %name%, is this correct"
echo.
   if %ERRORLEVEL% EQU 1 goto enterfile
   if %ERRORLEVEL% EQU 2 goto entername

:enterfile
set /p "filenum=Enter your File #: "
echo.
choice /c yn /M "You entered %filenum%, is this correct"
echo.
   if %ERRORLEVEL% EQU 1 goto currentdt
   if %ERRORLEVEL% EQU 2 goto enterfile

:currentdt
choice /c yn /M "Date/Time on this system when script initiated was %datetime%, is this the correct time"
echo.
   if %ERRORLEVEL% EQU 1 set "currentdate=SYSTEM DATE IS CORRECT" && set "currenttime=SYSTEM TIME IS CORRECT" && goto enterexhibit
   if %ERRORLEVEL% EQU 2 set "datetime=NOT ACCURATE" && goto enterdate

:enterdate
set /p "currentdate=Enter current correct date (yyyy-mm-dd): "
echo.
choice /c yn /M "You entered %currentdate%, is this correct"
echo.
   if %ERRORLEVEL% EQU 1 set "fulldate=%currentdate%" && goto entertime
   if %ERRORLEVEL% EQU 2 goto enterdate

:entertime
set /p "currenttime=Enter current correct time (HH-MM-SS): "
echo.
choice /c yn /M "You entered %currenttime%, is this correct"
echo.
   if %ERRORLEVEL% EQU 1 set "fulltime=%currenttime%" && goto enterexhibit
   if %ERRORLEVEL% EQU 2 goto entertime

:enterexhibit
set /p "description=Enter descriptive info about this Exhibit: "
echo.
choice /c yn /M "You entered %description%, is this correct"
echo.
   if %ERRORLEVEL% EQU 1 goto userhivebool
   if %ERRORLEVEL% EQU 2 goto enterexhibit

:userhivebool
choice /c yn /M "Do you have rawccopy.exe in the current directory, AND want to grab ALL user NTUSER and UsrClass hives"
echo.
   if %ERRORLEVEL% EQU 1 set "grabhives=y"
   if %ERRORLEVEL% EQU 2 set "grabhives=n"
echo.
goto startoutput

:startoutput
set outputfolder=%fulldate%_%fulltime%
set out=%workingdir%\%outputfolder%
set wlanreport=%out%\wlan-report
set results=%out%\Acquisition_Results.html
mkdir %out%
mkdir %out%\wlan-config
mkdir %out%\systeminfo

for %%l in (
"<!DOCTYPE html>"
"<html>"
"<head>"
"<title>FILE-%filenum% %datetime%</title>"
"<style>"
"body {"
"  background-color: white;"
"  font-family: verdana;"
"  font-size: 12px;"
"}"
".collapsible {"
"  background-color: #1971f4;"
"  color: white;"
"  cursor: pointer;"
"  padding: 18px;"
"  width: 100%;"
"  border: none;"
"  text-align: left;"
"  outline: none;"
"  font-size: 15px;"
"  border-radius: 10px;"
"}"
".active, .collapsible:hover {"
"  background-color: #1644b9;"
"}"
".content {"
"  padding: 0 18px;"
"  display: none;"
"  white-space: pre;"
"}"
".btn-header {"
"  text-align: center;"
"  font-size: 14px;"
"}"
"h1 {"
"  color: #1644b9;"
"  text-align: center;"
"  text-decoration: underline;"
"  font-size: 16px;"
"}"
"h2 {"
"  color: #1644b9;"
"  text-align: left;"
"  text-decoration: underline;"
"  font-size: 14px;"
"  font-weight: bold;"
"  display: block;"
"  white-space: pre;"
"}"
"p {"
"  font-family: verdana;"
"  font-size: 12px;"
"  white-space: pre;"
"}"
"a.button:link, a.button:visited {"
"  background-color: #1971f4;"
"  color: white;"
"  padding: 14px 25px;"
"  text-align: center;"
"  text-decoration: none;"
"  display: inline-block;"
"  border-radius: 10px;"
"}"
"a.button:hover, a.button:active {"
"  background-color: #1644b9;"
"}"
"a.plain:link, a.plain:visited {"
"  color: #1644b9;"
"  font-size: 12px;"
"  font-family: verdana;"
"  font-weight: normal;"
"  display: inline;"
"  text-decoration: none;"
"}"
"a.plain:hover {"
"  text-decoration: underline;"
"}"
".dark-mode {"
"  background-color: black;"
"  color: white;"
"}"
".dark-mode .cmd-content {"
"  background-color: black;"
"  color: white;"
"}"
".dark-mode section, .dark-mode a.plain {"
"  color: white;"
"}"
".light-mode {"
"  background-color: white;"
"  color: black;"
"}"
".light-mode .cmd-content {"
"  background-color: white;"
"  color: black;"
"}"
".dark-button {"
"  background-color: black;"
"  border: none;"
"  padding: 10px 10px;"
"  text-align: center;"
"  color: white;"
"  text-decoration: none;"
"  border-radius: 5px;"
"}"
".light-button {"
"  background-color: white;"
"  border: none;"
"  padding: 10px 10px;"
"  text-align: center;"
"  color: black;"
"  text-decoration: none;"
"  border-radius: 5px;"
"}"
"#cmd-box {"
"  margin: 0px 0px 10px 0px;"
"}"
".cmd-content {"
"  background-color: white;"
"  color: black;"
"  padding: 1px;"
"  outline: 1px solid #BBB;"
"  white-space: pre;"
"}"
"</style>"
"</head>"
"<body>"
) do echo.%%~l >> %results%
echo ^<section id="top"^>^</section^>>> %results%
echo ^<div style="text-align:right"^>^<button type="button" class="dark-button" onclick="darkMode()"^>^</button^>>> %results%
echo ^<button type="button" class="light-button" onclick="lightMode()"^>^</button^>^</div^>>> %results%
echo ^<h1^>>> %results%
echo ^<button type="button" class="collapsible"^>%initiation_time%^</button^>>> %results%
echo ^</h1^>>> %results%
echo ^<div style="text-align:center"^>^<p^>^<a class="button" href="#physical-system-details"^>Physical System Details^</a^> ^<a class="button" href="#soft-proc-task"^>Software, Processes and Tasks^</a^> ^<a class="button" href="#user-details"^>User Details^</a^> ^<a class="button" href="#network-details"^>Network Details^</a^> ^<a class="button" href="#registry"^>Registry^</a^> ^<a class="button" href="#end-of-collection"^>End of Collection Details^</a^>^</p^>^</div^>>> %results%
echo ^<button type="button" class="collapsible"^>Investigation Details^</button^>>> %results%
echo ^<div class="content"^>^<div class="cmd-box"^>^<p^> >> %results%
echo ^<textarea class="cmd-content" cols="80" rows="24" readonly="true" spellcheck="false"^> >> %results%
echo INVESTIGATOR	 : %name% >> %results%
echo FILE NUMBER	 : %filenum% >> %results%
echo SYSTEM TIME	 : %datetime% >> %results%
echo CORRECT DATE	 : %fulldate% >> %results%
echo CORRECT TIME	 : %fulltime% >> %results%
echo SYSTEM TZ	 : %tzcheck% >> %results%
echo CURR TZ OFFSET   : UTC %tzoffsethrs% >> %results%
echo EXHIBIT INFO	 : %description% >> %results%
echo ^</textarea^>^</p^>^</div^>^</div^> >> %results%
goto startprocess

:startprocess

echo ^<h2^>>> %results%
echo ^<section id="physical-system-details"^>PHYSICAL SYSTEM DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%
TITLE Pilfering: Physical System Details
echo Pilfering:

echo -	current system date and time
	echo ^<button type="button" class="collapsible"^>^<section id="csdt"^>CURRENT SYSTEM DATE/TIME AND TIMEZONE^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		echo %fulldatetime% >> %results%
		echo. >> %results%
		reg query "hklm\system\currentcontrolset\control\timezoneinformation" | findstr /r /v "^$" >> %results%
		echo. >> %results%
		powershell -c "(Get-TimeZone)" >> %results%
    call :closediv

echo -	full system details
	echo ^<button type="button" class="collapsible"^>^<section id="full-system-details"^>FULL SYSTEM INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		msinfo32 /report %out%\systeminfo\full-system-info.txt
		type %out%\systeminfo\full-system-info.txt>> %results%
    call :closediv

echo -	basic system information
    echo ^<button type="button" class="collapsible"^>^<section id="basic-system-info"^>BASIC SYSTEM INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		systeminfo >> %results%
    call :closediv

echo -	OS information
    echo ^<button type="button" class="collapsible"^>^<section id="os-info"^>OPERATING SYSTEM INFORMATION^</section^>^</button^>>> %results%
    call :opendiv
    call :textarea
		powershell -c "(Get-CimInstance -ClassName Win32_OperatingSystem | select *)" >> %results%
    call :closediv

echo -	BIOS information
    echo ^<button type="button" class="collapsible"^>^<section id="bios-info"^>BIOS INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "(Get-CimInstance -ClassName Win32_BIOS) | select *" >> %results%
    call :closediv

echo -	last system boot time
    echo ^<button type="button" class="collapsible"^>^<section id="last-system-boot"^>LAST TIME SYSTEM WAS BOOTED^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootupTime" >> %results%
    call :closediv
	
echo -	startup info
    echo ^<button type="button" class="collapsible"^>^<section id="startup-info"^>STARTUP INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-CimInstance -ClassName Win32_StartupCommand | select Caption,Command,Location,User | Format-List" >> %results%
    call :closediv

echo -	local physical disk configuration details
    echo ^<button type="button" class="collapsible"^>^<section id="physical-disk-info"^>PHYSICAL DISK INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-CimInstance -ClassName Win32_DiskDrive |select DeviceId,Partitions,BytesPerSector,Size,Caption,FirmwareRevision,InterfaceType,PNPDeviceID,Manufacturer,Model,SerialNumber |Format-List" >> %results%
	call :closediv
	
echo -	local logical disk configuration details
    echo ^<button type="button" class="collapsible"^>^<section id="logical-disk-info"^>LOGICAL DISK INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |select Caption,Compressed,Description,DeviceID,DriveType,FileSystem,FreeSpace,Name,Size,VolumeName,VolumeSerialNumber | Format-List" >> %results%
	call :closediv
	
echo -	partition details
    echo ^<button type="button" class="collapsible"^>^<section id="partition-info"^>PARTITION INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-Partition | Select PartitionNumber,Size,Offset,IsSystem,IsHidden,IsBoot,MbrType,GptType,Guid,DriveLetter,DiskNumber,DiskId,UniqueId,DiskPath,ObjectId |Format-List" >> %results%
    call :closediv
	
echo -	volume details
    echo ^<button type="button" class="collapsible"^>^<section id="volume-info"^>VOLUME INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-Volume | Select DriveLetter,DriveType,FileSystem,FileSystemLabel,AllocationUnitSize,Size,SizeRemaining,Path,ObjectId,UniqueId | Format-List" >> %results%
		mountvol | findstr "\ *" >> %results%
    call :closediv

echo -	volume file layout
    echo ^<button type="button" class="collapsible"^>^<section id="volume-file-layout"^>VOLUME FILE LAYOUT^</section^>^</button^>>> %results%
    call :opendiv
    call :textarea
        fsutil volume allocationReport %SYSTEMDRIVE% >> %results%
    call :closediv

echo -	file system information
	echo ^<button type="button" class="collapsible"^>^<section id="file-system-info"^>FILE SYSTEM INFO^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
    setlocal enabledelayedexpansion
    for /f "tokens=*" %%a in ('fsutil fsinfo drives') do (
		for %%b in (%%a) do (
			set "token=%%b"
			if "!token:~1,1!"==":" (
				echo !token:~0,2! Drive >> %results%
				echo ---------- >> %results%
				fsutil fsinfo ntfsinfo !token:~0,2! >> %results%
				echo ---------- >> %results%
			)
		)
	)
	endlocal
	call :closediv

echo -	plug and play devices
    echo ^<button type="button" class="collapsible"^>^<section id="pnp-info"^>PLUG AND PLAY DEVICES^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
        pnputil /enum-devices >> %results%
    call :closediv

echo -	BitLocker configuration
    echo ^<button type="button" class="collapsible"^>^<section id="bitlocker-info"^>BITLOCKER CONFIGURATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		manage-bde -status %SystemDrive% >> %results%
		manage-bde -protectors -get %SystemDrive% >> %results%
    call :closediv

echo -	Encrypting File System settings
	echo ^<button type="button" class="collapsible"^>^<section id="encrypting-file-system-info"^>ENCRYPTING FILE SYSTEM STATUS^</section^>^</button^>>> %results%
    call :opendiv
    call :textarea
        fsutil behavior query disableEncryption >> %results%
        fsutil behavior query encryptPagingFile >> %results%
        cipher /u /n /h >> %results%
    call :closediv

echo -	shadow copy details
    echo ^<button type="button" class="collapsible"^>^<section id="shadow-copy-info"^>SHADOW COPY DETAILS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
        echo vssadmin list providers >> %results%
		vssadmin list providers >> %results%
		echo vssadmin list shadows >> %results%
		vssadmin list shadows >> %results%
		echo vssadmin list shadowstorage >> %results%
		vssadmin list shadowstorage >> %results%
		echo vssadmin list volumes >> %results%
		vssadmin list volumes >> %results%
		echo vssadmin list writers >> %results%
		vssadmin list writers >> %results%
    call :closediv

echo -	Windows Defender Status
	echo ^<button type="button" class="collapsible"^>^<section id="defender-info"^>WINDOWS DEFENDER STATUS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		echo Get-MpComputerStatus >> %results%
		powershell -c Get-MpComputerStatus >> %results%
		echo Get-MpPreference >> %results%
		powershell -c Get-MpPreference >> %results%
		echo ExclusionPaths >> %results%
		powershell -c "Get-MpPreference | Select -expandproperty ExclusionPath" >> %results%
	call :closediv

TITLE Pilfering: Software, Processes, and Tasks
echo ^<h2^>>> %results%
echo ^<section id="soft-proc-task"^>SOFTWARE, PROCESSES, and TASKS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	installed software
	echo ^<button type="button" class="collapsible"^>^<section id="full-system-details"^>INSTALLED SOFTWARE^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "$MyProgs = Get-ItemProperty 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'; $MyProgs += Get-ItemProperty 'HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'; $MyProgs.DisplayName | Sort-Object -Unique" >> %results%
    call :closediv

echo -	installed hot-fixes
    echo ^<button type="button" class="collapsible"^>^<section id="installed-hot-fixes"^>INSTALLED HOT-FIXES^</section^>^</button^>>> %results%
    call :opendiv
    call :textarea
        powershell -c "Get-HotFix | Select Description,HotFixId,InstalledBy,InstalledOn | Format-List" >> %results%
    call :closediv

echo -	open or locked files
    echo ^<button type="button" class="collapsible"^>^<section id="open-locked-files"^>OPEN/LOCKED FILES^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net file  >> %results%
    call :closediv
	
echo -	currently running services
    echo ^<button type="button" class="collapsible"^>^<section id="running-services"^>SERVICES CURRENTLY RUNNING ON THE PC^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net start >> %results%
		powershell -c "Get-Service | Select Name,DisplayName,ServiceName,Status,StartType,ServiceType" >> %results%
    call :closediv
	
echo -	running processes
    echo ^<button type="button" class="collapsible"^>^<section id="running-processes"^>RUNNING PROCESSES (DETAILED)^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		tasklist /v >> %results%
    call :closediv
	
echo -	scheduled tasks
    echo ^<button type="button" class="collapsible"^>^<section id="scheduled-tasks"^>SCHEDULED TASKS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		schtasks /query /FO LIST /V >> %results%
    call :closediv

echo -	contents of Prefetch
    echo ^<button type="button" class="collapsible"^>^<section id="prefetch-contents"^>PREFETCH CONTENTS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		dir %SYSTEMDRIVE%\Windows\Prefetch\*.pf >> %results%
    call :closediv

TITLE Pilfering: User Details
echo ^<h2^>>> %results%
echo ^<section id="user-details"^>USER DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	current user
    echo ^<button type="button" class="collapsible"^>^<section id="current-user"^>CURRENT USER^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		whoami /user /FO LIST >> %results%
    call :closediv

    echo ^<button type="button" class="collapsible"^>^<section id="all-users"^>ALL USER ACCOUNTS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-LocalUser |Select Name,FullName,Description,Enabled,LastLogon,AccountExpires,PasswordExpires,UserMayChangePassword,PasswordRequired,PasswordLastSet,SID | Format-List" >> %results%
		net user | findstr /r /v "^$" >> %results%
    call :closediv

echo -	current users logged on remotely
    echo ^<button type="button" class="collapsible"^>^<section id="remote-logged-in-users"^>CURRENT USERS LOGGED ON REMOTELY^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net sessions >> %results%
    call :closediv
	
echo -	account policies
    echo ^<button type="button" class="collapsible"^>^<section id="current-user-policies"^>CURRENT USER ACCOUNT POLICIES^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net accounts | findstr /r /v "^$" >> %results%
    call :closediv
	
echo -	list of groups on the computer
    echo ^<button type="button" class="collapsible"^>^<section id="groups-on-computer"^>LIST OF GROUPS ON COMPUTER^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net localgroup | findstr /r /v "^$" >> %results%
    call :closediv

echo -	all user, group, and privilege info
	echo ^<button type="button" class="collapsible"^>^<section id="all-user-priv-info"^>ALL USER / GROUP / PRIVILEGE INFO^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		whoami /ALL /FO LIST >> %results%
    call :closediv
	
TITLE Pilfering: Network Details
echo ^<h2^>>> %results%
echo ^<section id="network-details"^>NETWORK DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	network information including wireless
    echo ^<button type="button" class="collapsible"^>^<section id="network-info"^>NETWORK INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
	echo. >> %results%
		ipconfig /all >> %results%
		powershell -c "Get-NetAdapter |Select Name,InterfaceDescription,InterfaceName,MacAddress,LinkSpeed" >> %results%
        powershell -c "Get-NetIPAddress" >> %results%
        echo Host ISP and external IP info >> %results%
        powershell -nop irm ipinfo.io >> %results%
        nslookup myip.opendns.com resolver1.opendns.com >> %results%
    call :closediv
    echo ^<button type="button" class="collapsible"^>^<section id="wireless-network-info"^>WIRELESS NETWORK INFO^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		netsh wlan show profiles >> %results%
		netsh wlan show profiles * key=clear >> %results%
		set wlansvc=C:\ProgramData\Microsoft\Wlansvc
		echo Looking for XML files in %wlansvc% and copying info >> %results%
		dir /b /s %wlansvc% 2>nul | >nul findstr ".xml" && (@echo Found the following XML profiles >> %results%) && (findstr /I /C:"<name>" /S C:\ProgramData\Microsoft\Wlansvc\*.xml >> %results% 2>nul) && (@echo Copying to output folder >> %results%  && (for /F %%G in ('dir /B /S C:\ProgramData\Microsoft\Wlansvc\*.xml') do copy %%G %out%\wlan-config\) 1>nul 2>>%results%) || (@echo No XML profiles found. >> %results%)
		netsh wlan show wirelesscapabilities >> %results% 1>nul
		netsh wlan show interfaces >> %results% 1>nul
		mkdir %wlanreport%
		netsh wlan show wlanreport 1>nul && copy C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.* %wlanreport% 1>nul
    call :closediv
	
echo -	DNS information
    echo ^<button type="button" class="collapsible"^>^<section id="dns-info"^>DNS INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		ipconfig /displaydns >> %results%
    call :closediv
	
echo -	routing information
    echo ^<button type="button" class="collapsible"^>^<section id="routing-info"^>NETWORK ROUTING INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		route print >> %results%
    call :closediv
	
echo -	ARP information
    echo ^<button type="button" class="collapsible"^>^<section id="arp-info"^>ARP INFORMATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		arp -a >> %results%
    call :closediv

echo -	remote desktop sessions
    echo ^<button type="button" class="collapsible"^>^<section id="remote-desktop-sessions"^>REMOTE DESKTOP SERVICES SESSIONS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		qwinsta /counter >> %results%
    call :closediv

echo -	shares on the system
    echo ^<button type="button" class="collapsible"^>^<section id="shares-on-system"^>SHARES ON THE SYSTEM^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net share | findstr /r /v "^$" >> %results%
    call :closediv

echo -	current drive mappings to a remote computer
    echo ^<button type="button" class="collapsible"^>^<section id="drive-mappings-to-remote-computer"^>DRIVE MAPPINGS TO REMOTE COMPUTER - CURRENT^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		net use | findstr /r /v "^$" | more >> %results%
		powershell -c "Get-SMBMapping |Select LocalPath,RemotePath" | more >> %results%
    call :closediv
	
echo -	current network connections (detailed)
    echo ^<button type="button" class="collapsible"^>^<section id="detailed-network-connections"^>CURRENT NETWORK CONNECTIONS (DETAILED)^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		netstat -anbo >> %results%
    call :closediv

echo -	netbios cache and sessions
    echo ^<button type="button" class="collapsible"^>^<section id="netbios-cache-sessions"^>NETBIOS CACHE AND SESSIONS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
	    nbtstat -c >> %results%
		nbtstat -s >> %results%
    call :closediv

echo -	historical IP addresses
    echo ^<button type="button" class="collapsible"^>^<section id="historical-ips"^>HISTORICAL IP'S FROM DELIVERY OPTIMIZATION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		powershell -c "Get-DeliveryOptimizationLog | ? Message -Like "*ExternalIpAddress*" | Format-Table -Property TimeCreated,ProcessId,ThreadId,Message -Wrap" | findstr /r /v "^$" >> %results%
    call :closediv

echo -	firewall status
    echo ^<button type="button" class="collapsible"^>^<section id="firewall-status"^>FIREWALL STATUS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
		netsh advfirewall show allprofiles >> %results%
		if exist %systemroot%\system32\LogFiles\Firewall\pfirewall.log ( 
			copy %systemroot%\system32\LogFiles\Firewall\pfirewall.log %out%\ 1>nul
		) else ( echo No Firewall Log Found in %systemroot%\system32\LogFiles\Firewall\ >> %results%
		)
    call :closediv

TITLE Pilfering: Registry Hives
echo ^<h2^>>> %results%
echo ^<section id="registry"^>REGISTRY^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%
mkdir %out%\registry
echo -	SAM, SYSTEM, SECURITY and SOFTWARE hives
    echo ^<button type="button" class="collapsible"^>^<section id="registry-hive-extractions"^>SAM, SYSTEM, SECURITY and SOFTWARE HIVE EXTRACTION^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
        echo 	-	Extracting SAM hive
		reg save hklm\sam %out%\registry\sam_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SAM hive successfully extracted >> %results%
        echo 	-	Extracting SYSTEM hive
		reg save hklm\system %out%\registry\system_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SYSTEM hive successfully extracted >> %results%
        echo 	-	Extracting SECURITY hive
		reg save hklm\security %out%\registry\security_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SECURITY hive successfully extracted >> %results%
        echo 	-	Extracting SOFTWARE hive
		reg save hklm\software %out%\registry\software_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SOFTWARE hive successfully extracted >> %results%
    call :closediv

if /i %grabhives% EQU "y" ( 
    call :userhives
) else (
    echo null>nul
)

TITLE Finished pilfering...
echo ^<h2^>>> %results%
echo ^<section id="end-of-collection"^>>> %results%
echo END OF EVIDENCE COLLECTION >> %results%
echo ^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%
echo ^<p^>>> %results%
echo ^<button type="button" class="collapsible"^>^<section id="finished"^>COMPLETED AT: %date% %time: =0% SYSTEMTIME^</section^>^</button^>>> %results%
echo ^</p^>>> %results%
for %%l in (
"<script>"
"var coll = document.getElementsByClassName("collapsible");"
"var i;"
""
"for (i = 0; i < coll.length; i++) {"
"  coll[i].addEventListener("click", function() {"
"    this.classList.toggle("active");"
"    var content = this.nextElementSibling;"
"    if (content.style.display === "block") {"
"      content.style.display = "none";"
"    } else {"
"      content.style.display = "block";"
"    }"
"  });"
"}"
"function darkMode() {"
"  var element = document.body;"
"  element.className = "dark-mode";"
"}"
"function lightMode() {"
"  var element = document.body;"
"  element.className = "light-mode";"
"}"
"</script>"
) do echo.%%~l >> %results%
echo ^</body^>>> %results%
echo ^</html^>>> %results%
echo ===DONE===
msg %username% Pilfer acquisition done for file %filenum%.
timeout /t 5
endlocal
EXIT /B

:opendiv
echo ^<div class="content"^>^<div class="cmd-box"^>^<p^> >> %results%
goto :eof

:textarea
echo ^<textarea class="cmd-content" cols="80" rows="24" readonly="true" spellcheck="false"^> >> %results%
goto :eof

:closediv
echo ^</textarea^>^</div^>^</div^>^</p^> >> %results%
goto :eof

:userhives
echo -	NTUSER.DAT and UsrClass.dat hive extraction
	echo ^<button type="button" class="collapsible"^>^<section id="user-registry-hive-extractions"^>NTUSER.DAT and UsrClass.dat EXTRACTIONS^</section^>^</button^>>> %results%
	call :opendiv
	call :textarea
	FOR /f "usebackq" %%x in (
		`dir /B %SystemDrive%\Users\`
	) DO (
		mkdir %out%\registry\%%x
		echo 	-	Extracting NTUSER.DAT for %%x
		START /W /B "Pilfering NTUSER.DAT for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\NTUSER.DAT /OutputPath:%out%\registry\%%x >> %results%
		echo 	-	Extracting ntuser.dat.LOG1 for %%x
		START /W /B "Pilfering ntuser.dat.LOG1 for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\ntuser.dat.LOG1 /OutputPath:%out%\registry\%%x >> %results%
		echo 	-	Extracting ntuser.dat.LOG2 for %%x
		START /W /B "Pilfering ntuser.dat.LOG2 for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\ntuser.dat.LOG2 /OutputPath:%out%\registry\%%x >> %results%
		echo 	-	Extracting UsrClass.dat for %%x
		START /W /B "Pilfering UsrClass.dat for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\AppData\Local\Microsoft\Windows\UsrClass.dat /OutputPath:%out%\registry\%%x >> %results%
		echo 	-	Extracting UsrClass.dat.LOG1 for %%x
		START /W /B "Pilfering UsrClass.dat.LOG1 for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\AppData\Local\Microsoft\Windows\UsrClass.dat.LOG1 /OutputPath:%out%\registry\%%x >> %results%
		echo 	-	Extracting UsrClass.dat.LOG2 for %%x
		START /W /B "Pilfering UsrClass.dat.LOG2 for %%x" "%~dp0rawccopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\AppData\Local\Microsoft\Windows\UsrClass.dat.LOG2 /OutputPath:%out%\registry\%%x >> %results%
	) 
	call :closediv
goto :eof
