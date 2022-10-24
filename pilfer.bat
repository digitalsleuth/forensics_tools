@echo off
:: **************************************************************************************
:: ** PILFER
:: ** Source: https://github.com/digitalsleuth/forensics_tools
:: ** Batch File to quickly gather basic system info & volatile network info
:: ** then dump it out to a text file called Acquisition_Results.txt. 
:: ** This script must be run as administrator.
:: ** (right click and select "Run as administrator")
:: **************************************************************************************
:: ** Initial build: Cst. Percival Hall - 2013-12-20 ************************************
:: ** Ongoing maintenance: Corey Forman - 2022-10-24 ************************************
:: **************************************************************************************
:: ** Version 2.4 ***********************************************************************

setlocal
set version=2.4
TITLE Pilfer v%version% - github.com/digitalsleuth
set workingdir=%~dp0
for /f "usebackq tokens=1,2 delims=,= " %%i in (`wmic os get LocalDateTime /value`) do @if %%i==LocalDateTime (
     set fulldatetime=%%j
)
for /f "tokens=*" %%a in ('tzutil /g') do set tzcheck=%%a
set year=%fulldatetime:~0,4%
set month=%fulldatetime:~4,2%
set day=%fulldatetime:~6,2%
set fulldate=%year%-%month%-%day%
set hour=%fulldatetime:~8,2%
set min=%fulldatetime:~10,2%
set sec=%fulldatetime:~12,2%
set fulltime=%hour%-%min%-%sec%
set tzoffset=%fulldatetime:~-5%
set /A tzoffsethrs=%tzoffset% / 60

goto admin
:admin
    net session >nul 2>&1
    if %errorLevel% == 0 (
	    set initiation_time=Acquisition initiated at SYSTEM-TIME: %fulldate% %fulltime% %tzcheck% - Current Offset UTC %tzoffsethrs%
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
set /p "input1=Enter your name and title: "
echo.
set /p "answer1=You entered %input1%, is this correct [Y]/n: "
echo.
   if /i "%answer1:~,1%" EQU "y" goto enterfile
   if /i "%answer1%" EQU "" goto enterfile
   if /i "%answer1:~,1%" EQU "n" goto entername

:enterfile
set /p "input2=Enter your File #: "
echo.
set /p "answer2=You entered %input2%, is this correct [Y]/n: "
echo.
   if /i "%answer2:~,1%" EQU "y" goto currentdt
   if /i "%answer2%" EQU "" goto currentdt
   if /i "%answer2:~,1%" EQU "n" goto enterfile

:currentdt
set datetime=%fulldate% %fulltime% %tzcheck%
set /p "answerdt=Date/Time on this system when script initiated was %datetime%, is this correct [Y]/n: "
echo.
   if /i "%answerdt:~,1%" EQU "y" set "input3=SYSTEM DATE IS CORRECT" && set "input4=SYSTEM TIME IS CORRECT" && goto enterexhibit
   if /i "%answerdt%" EQU "" set "input3=SYSTEM DATE IS CORRECT" && set "input4=SYSTEM TIME IS CORRECT" && goto enterexhibit
   if /i "%answerdt:~,1%" EQU "n" set "datetime=NOT ACCURATE" && goto enterdate

:enterdate
set /p "input3=Enter current correct date (yyyy-mm-dd): "
echo.
set /p "answer3=You entered %input3%, is this correct [Y]/n: "
echo.
   if /i "%answer3:~,1%" EQU "y" set "fulldate=%input3%" && goto entertime
   if /i "%answer3%" EQU "" set "fulldate=%input3%" && goto entertime
   if /i "%answer3:~,1%" EQU "n" goto enterdate

:entertime
set /p "input4=Enter current correct time (HH-MM-SS): "
echo.
set /p "answer4=You entered %input4%, is this correct [Y]/n: "
echo.
   if /i "%answer4:~,1%" EQU "y" set "fulltime=%input4%" && goto enterexhibit
   if /i "%answer4%" EQU "" set "fulltime=%input4%" && goto enterexhibit
   if /i "%answer4:~,1%" EQU "n" goto entertime

:enterexhibit
set /p "input5=Enter descriptive info about this Exhibit: "
echo.
set /p "answer5=You entered %input5%, is this correct [Y]/n: "
echo.
   if /i "%answer5:~,1%" EQU "y" goto startoutput
   if /i "%answer5%" EQU "" goto startoutput
   if /i "%answer5:~,1%" EQU "n" goto enterexhibit

   
:startoutput
set outputfolder=%fulldate%_%fulltime%
set out=%workingdir%\%outputfolder%
set wlanreport=%out%\wlan-report
set results=%out%\Acquisition_Results.html
mkdir %out%

for %%l in (
"<!DOCTYPE html>"
"<html>"
"<head>"
"<title>%datetime%</title>"
"<style>"
"body {"
"  background-color: white;"
"  font-family: verdana;"
"  font-size: 12px;"
"}"
".collapsible {"
"  background-color: #777;"
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
"  background-color: #777;"
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
".light-mode {"
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
"</style>"
"</head>"
"<body>"
) do echo.%%~l >> %results%
echo ^<div style="text-align:right"^>^<button type="button" class="dark-button" onclick="darkMode()"^>^</button^>>> %results%
echo ^<button type="button" class="light-button" onclick="lightMode()"^>^</button^>^</div^>>> %results%
echo ^<h1^>>> %results%
echo ^<button type="button" class="collapsible"^>^<section id="top"^>%initiation_time%^</section^>^</button^>>> %results%
echo ^</h1^>>> %results%
echo ^<div style="text-align:center"^>^<p^>^<a class="button" href="#physical-system-details"^>Physical System Details^</a^> ^<a class="button" href="#soft-proc-task"^>Software, Processes and Tasks^</a^> ^<a class="button" href="#user-details"^>User Details^</a^> ^<a class="button" href="#network-details"^>Network Details^</a^> ^<a class="button" href="#registry"^>Registry^</a^> ^<a class="button" href="#end-of-collection"^>End of Collection Details^</a^>^</p^>^</div^>>> %results%
echo ^<button type="button" class="collapsible"^>Investigation Details^</button^>>> %results%
echo ^<div class="content"^>^<p^>>> %results%
echo INVESTIGATOR	 : %input1% >> %results%
echo FILE NUMBER	 : %input2% >> %results%
echo SYSTEM TIME	 : %datetime% >> %results%
echo CORRECT DATE	 : %fulldate% >> %results%
echo CORRECT TIME	 : %fulltime% >> %results%
echo SYSTEM TZ	 : %tzcheck% >> %results%
echo CURR TZ OFFSET: UTC %tzoffsethrs% >> %results%
echo EXHIBIT INFO	 : %input5% >> %results%
echo ^</div^>^</p^>>> %results%
goto startprocess

:startprocess

echo ^<h2^>>> %results%
echo ^<section id="physical-system-details"^>PHYSICAL SYSTEM DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%
TITLE Pilfering: Physical System Details
echo Pilfering:

echo -	current system date and time
	echo ^<button type="button" class="collapsible"^>^<section id="csdt"^>CURRENT SYSTEM DATE/TIME AND TIMEZONE^</section^>^</button^>>> %results%
	echo ^<div class="content"^>^<p^>>> %results%
	echo. >> %results%
		echo %date% %time: =0% >> %results%
		echo. >> %results%
		reg query "hklm\system\currentcontrolset\control\timezoneinformation" | findstr /r /v "^$" >> %results%
		echo. >> %results%
		wmic timezone get bias,caption,daylightbias,daylightname /format:list| findstr /r /v "^$" >> %results%
		wmic os get currenttimezone /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	full system details
	echo ^<button type="button" class="collapsible"^>^<section id="full-system-details"^>FULL SYSTEM INFORMATION^</section^>^</button^>>> %results%
	echo ^<div class="content"^>^<p^>>> %results%
	echo. >> %results%
		msinfo32 /report %out%\full-system-info.txt
		type %out%\full-system-info.txt>> %results%
    echo ^</div^>^</p^>>> %results%

echo -	basic system information
    echo ^<button type="button" class="collapsible"^>^<section id="basic-system-info"^>BASIC SYSTEM INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		systeminfo >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	BIOS information
    echo ^<button type="button" class="collapsible"^>^<section id="bios-info"^>BIOS INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic bios get BIOSVersion,Caption,Description,Manufacturer,ReleaseDate,SerialNumber,Version /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	last system boot time
    echo ^<button type="button" class="collapsible"^>^<section id="last-system-boot"^>LAST TIME SYSTEM WAS BOOTED^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic os get lastbootuptime | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	startup info
    echo ^<button type="button" class="collapsible"^>^<section id="startup-info"^>STARTUP INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic startup get * /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	local physical disk configuration details
    echo ^<button type="button" class="collapsible"^>^<section id="physical-disk-info"^>PHYSICAL DISK INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic diskdrive get BytesPerSector,CapabilityDescriptions,Caption,DeviceID,FirmwareRevision,Index,InstallDate,InterfaceType,Manufacturer,MediaType,Model,Name,Partitions,PNPDeviceID,SerialNumber,Size /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	local logical disk configuration details
    echo ^<button type="button" class="collapsible"^>^<section id="logical-disk-info"^>LOGICAL DISK INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic logicaldisk get Caption,Compressed,Description,DeviceID,DriveType,FileSystem,FreeSpace,Name,Size,VolumeName,VolumeSerialNumber /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	partition details
    echo ^<button type="button" class="collapsible"^>^<section id="partition-info"^>PARTITION INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic partition get BlockSize,Caption,Description,DeviceID,DiskIndex,Name,Size,StartingOffset,SystemName,Type /format:list | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	volume details
    echo ^<button type="button" class="collapsible"^>^<section id="volume-info"^>VOLUME INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic volume get BlockSize,Capacity,Caption,DeviceID,DriveLetter,FileSystem,FreeSpace,Label,Name,SerialNumber,SystemVolume /format:table | findstr /r /v "^$" >> %results%
		mountvol | findstr "\ *" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	BitLocker configuration
    echo ^<button type="button" class="collapsible"^>^<section id="bitlocker-info"^>BITLOCKER CONFIGURATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		manage-bde -status %SystemDrive% >> %results%
		manage-bde -protectors -get %SystemDrive% >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	shadow copy details
    echo ^<button type="button" class="collapsible"^>^<section id="shadow-copy-info"^>SHADOW COPY DETAILS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic shadowcopy get Caption,Description,DeviceObject,ID,InstallDate,OriginatingMachine,ProviderID,SetID,VolumeName /format:list | findstr /r /v "^$"  >> %results%
    echo ^</div^>^</p^>>> %results%

TITLE Pilfering: Software, Processes, and Tasks
echo ^<h2^>>> %results%
echo ^<section id="soft-proc-task"^>SOFTWARE, PROCESSES, and TASKS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	installed software
	echo ^<button type="button" class="collapsible"^>^<section id="full-system-details"^>INSTALLED SOFTWARE^</section^>^</button^>>> %results%
	echo ^<div class="content"^>^<p^>>> %results%
	echo. >> %results%
		wmic product get Name,Version,InstallDate,InstallLocation,InstallSource,LocalPackage,IdentifyingNumber,PackageCode,PackageName>> %results%
    echo ^</div^>^</p^>>> %results%

echo -	open or locked files
    echo ^<button type="button" class="collapsible"^>^<section id="open-locked-files"^>OPEN/LOCKED FILES^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net file  >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	currently running services
    echo ^<button type="button" class="collapsible"^>^<section id="running-services"^>SERVICES CURRENTLY RUNNING ON THE PC^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net start >> %results%
		wmic service get Name,PathName,ServiceType,StartMode /format:table | find /V "" | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	running processes
    echo ^<button type="button" class="collapsible"^>^<section id="running-processes"^>RUNNING PROCESSES (DETAILED)^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		tasklist /v >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	scheduled tasks
    echo ^<button type="button" class="collapsible"^>^<section id="scheduled-tasks"^>SCHEDULED TASKS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		schtasks /query /FO LIST /V >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	contents of Prefetch
    echo ^<button type="button" class="collapsible"^>^<section id="prefetch-contents"^>PREFETCH CONTENTS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		dir /B %SYSTEMDRIVE%\Windows\Prefetch\*.pf >> %results%
    echo ^</div^>^</p^>>> %results%

TITLE Pilfering: User Details
echo ^<h2^>>> %results%
echo ^<section id="user-details"^>USER DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	current user
    echo ^<button type="button" class="collapsible"^>^<section id="current-user"^>CURRENT USER^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		whoami >> %results%
	echo. >> %results%
    echo ^</div^>^</p^>>> %results%
    echo ^<button type="button" class="collapsible"^>^<section id="all-users"^>ALL USER ACCOUNTS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		wmic useraccount get caption,domain,fullname,name,SID /format:table | findstr /r /v "^$" >> %results%
		net user | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	current users logged on remotely
    echo ^<button type="button" class="collapsible"^>^<section id="remote-logged-in-users"^>CURRENT USERS LOGGED ON REMOTELY^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net sessions >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	account policies
    echo ^<button type="button" class="collapsible"^>^<section id="current-user-policies"^>CURRENT USER ACCOUNT POLICIES^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net accounts | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	list of groups on the computer
    echo ^<button type="button" class="collapsible"^>^<section id="groups-on-computer"^>LIST OF GROUPS ON COMPUTER^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net localgroup | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

TITLE Pilfering: Network Details
echo ^<h2^>>> %results%
echo ^<section id="network-details"^>NETWORK DETAILS^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	network information including wireless
    echo ^<button type="button" class="collapsible"^>^<section id="network-info"^>NETWORK INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
	echo. >> %results%
		ipconfig /all >> %results%
		echo. >> %results%
		wmic nicconfig get description,IPAddress,MACaddress | findstr /I /C:":" >> %results%
    echo ^</div^>^</p^>>> %results%
    echo ^<button type="button" class="collapsible"^>^<section id="wireless-network-info"^>WIRELESS NETWORK INFO^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		netsh wlan show profiles >> %results%
		netsh wlan show profiles * key=clear >> %results%
		set wlansvc=C:\ProgramData\Microsoft\Wlansvc
		echo Looking for XML files in %wlansvc% and copying info >> %results%
		dir /b /s %wlansvc% 2>nul | >nul findstr ".xml" && (@echo Found the following XML profiles >> %results%) && (findstr /I /C:"<name>" /S C:\ProgramData\Microsoft\Wlansvc\*.xml >> %results% 2>nul) && (@echo Copying to output folder >> %results%  && (for /F %%G in ('dir /B /S C:\ProgramData\Microsoft\Wlansvc\*.xml') do copy %%G %workingdir%\%outputfolder%\) 1>nul 2>>%results%) || (@echo No XML profiles found. >> %results%)
		netsh wlan show wirelesscapabilities >> %results% 1>nul
		netsh wlan show interfaces >> %results% 1>nul
		mkdir %wlanreport%
		netsh wlan show wlanreport 1>nul && copy C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.* %wlanreport% 1>nul
    echo ^</div^>^</p^>>> %results%
	
echo -	DNS information
    echo ^<button type="button" class="collapsible"^>^<section id="dns-info"^>DNS INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		ipconfig /displaydns >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	routing information
    echo ^<button type="button" class="collapsible"^>^<section id="routing-info"^>NETWORK ROUTING INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		route print >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	ARP information
    echo ^<button type="button" class="collapsible"^>^<section id="arp-info"^>ARP INFORMATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		arp -a >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	remote desktop sessions
    echo ^<button type="button" class="collapsible"^>^<section id="remote-desktop-sessions"^>REMOTE DESKTOP SERVICES SESSIONS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		qwinsta /counter >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	shares on the system
    echo ^<button type="button" class="collapsible"^>^<section id="shares-on-system"^>SHARES ON THE SYSTEM^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net share | findstr /r /v "^$" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	current drive mappings to a remote computer
    echo ^<button type="button" class="collapsible"^>^<section id="drive-mappings-to-remote-computer"^>DRIVE MAPPINGS TO REMOTE COMPUTER - CURRENT^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		net use | findstr /r /v "^$" >> %results%
		wmic netuse list full >> %results%
    echo ^</div^>^</p^>>> %results%
	
echo -	current network connections (detailed)
    echo ^<button type="button" class="collapsible"^>^<section id="detailed-network-connections"^>CURRENT NETWORK CONNECTIONS (DETAILED)^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		netstat -anbo >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	netbios cache and sessions
    echo ^<button type="button" class="collapsible"^>^<section id="netbios-cache-sessions"^>NETBIOS CACHE AND SESSIONS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
	    nbtstat -c >> %results%
		nbtstat -s >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	historical IP addresses
    echo ^<button type="button" class="collapsible"^>^<section id="historical-ips"^>HISTORICAL IP'S FROM DELIVERY OPTIMIZATION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		%SystemDrive%\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Get-DeliveryOptimizationLog | Where-Object Message -Like "*ExternalIpAddress*"" >> %results%
    echo ^</div^>^</p^>>> %results%

echo -	firewall status
    echo ^<button type="button" class="collapsible"^>^<section id="firewall-status"^>FIREWALL STATUS^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		netsh advfirewall show allprofiles >> %results%
		if exist %systemroot%\system32\LogFiles\Firewall\pfirewall.log ( 
			copy %systemroot%\system32\LogFiles\Firewall\pfirewall.log %workingdir%\%outputfolder%\ 1>nul
		) else ( echo No Firewall Log Found in %systemroot%\system32\LogFiles\Firewall\ >> %results%
		)
    echo ^</div^>^</p^>>> %results%

TITLE Pilfering: Registry Hives
echo ^<h2^>>> %results%
echo ^<section id="registry"^>REGISTRY^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%

echo -	SAM, SYSTEM and SECURITY hives for NTLM hash extractions
    echo ^<button type="button" class="collapsible"^>^<section id="registry-hive-extractions"^>SAM, SYSTEM and SECURITY HIVE EXTRACTION^</section^>^</button^>>> %results%
    echo ^<div class="content"^>^<p^>>> %results%
		reg save hklm\sam %workingdir%\%outputfolder%\sam_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SAM hive successfully extracted >> %results%
			echo. >> %results%
		reg save hklm\system %workingdir%\%outputfolder%\system_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SYSTEM hive successfully extracted >> %results%
			echo. >> %results%
		reg save hklm\security %workingdir%\%outputfolder%\security_%outputfolder% >> %results%
		if %errorlevel% == 0 echo SECURITY hive successfully extracted >> %results%
			echo. >> %results%
    echo ^</div^>^</p^>>> %results%
	
::echo -	NTUSER.DAT hive extraction
::::	echo NTUSER.DAT HIVE EXTRACTION >> %results%
::::        FOR /f "usebackq" %%x in (
::	        `dir /B %SystemDrive%\Users\`
::        ) DO (
::	        mkdir %~dp0\%%x &
::	        START /W "RawCopy" "%~dp0RawCopy.exe" /FileNamePath:%SystemDrive%\Users\%%x\NTUSER.DAT /OutputPath:"%~dp0\%%x\"
::        )
::	echo. >> %results%
TITLE Finished pilfering...
echo ^<h2^>>> %results%
echo ^<section id="end-of-collection"^>>> %results%
echo END OF EVIDENCE COLLECTION >> %results%
echo ^</section^>^</h2^>^<p^>^<a class="plain" href="#top"^>top^</a^>^</p^>>> %results%
echo ^<p^>>> %results%
echo COMPLETED AT: %date% %time: =0% SYSTEMTIME >> %results%
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
echo.
timeout /t 5
endlocal
EXIT /B
