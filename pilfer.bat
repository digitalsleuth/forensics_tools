@echo off
:: **************************************************************************************
:: ** PILFER
:: ** Source: https://github.com/digitalsleuth/forensics_tools
:: ** Batch File to quickly gather basic system info & volatile network info
:: ** then dump it out to a text file called Acquisition_Results.txt. 
:: ** Although not critical, it is recommended that it be run with elevated priveleges,
:: ** (right click and select "Run as administrator") especially for netstat details.
:: **************************************************************************************
:: ** Initial build: Cst. Percival Hall - 2013-12-20 ************************************
:: ** Ongoing maintenance: Corey Forman - 2020-09-07 ************************************
:: **************************************************************************************
:: ** Version 1.7 ***********************************************************************

setlocal
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
		echo Error %ERRORLEVEL%
		PAUSE
		EXIT /B %ERRORLEVEL%
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
set acquisition_path="%workingdir%\%outputfolder%"
set wlanreport=%acquisition_path%\wlan-report
set results=%acquisition_path%\Acquisition_Results.txt
mkdir %acquisition_path%
echo %initiation_time% >> %results%
echo INVESTIGATOR  : %input1% >> %results%
echo FILE NUMBER   : %input2% >> %results%
echo SYSTEM TIME   : %datetime% >> %results%
echo CORRECT DATE  : %fulldate% >> %results%
echo CORRECT TIME  : %fulltime% >> %results%
echo SYSTEM TZ     : %tzcheck% >> %results%
echo CURR TZ OFFSET: UTC %tzoffsethrs% >> %results%
echo EXHIBIT INFO  : %input5% >> %results%
goto startprocess

:startprocess

set BORDER===============================================================

echo Getting:
echo -	current system date and time
	echo %BORDER% >> %results%
	echo ======CURRENT SYSTEM DATE/TIME AND TIMEZONE=================== >> %results%
	echo %BORDER% >> %results%
	echo. >> %results%
		echo %date% %time: =0% >> %results%
		echo. >> %results%
		reg query "hklm\system\currentcontrolset\control\timezoneinformation" | findstr /r /v "^$" >> %results%
		echo. >> %results%
		wmic timezone get bias,caption,daylightbias,daylightname /format:list| findstr /r /v "^$" >> %results%
		wmic os get currenttimezone /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	current user
	echo %BORDER% >> %results%
	echo ======CURRENT USER============================================ >> %results%
	echo %BORDER% >> %results%
		whoami >> %results%
	echo. >> %results%

	echo %BORDER% >> %results%
	echo ======ALL USER ACCOUNTS======================================= >> %results%
	echo %BORDER% >> %results%
		wmic useraccount get caption,domain,fullname,name,SID /format:table | findstr /r /v "^$" >> %results%
		net user | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	account policies
	echo %BORDER% >> %results%
	echo ======CURRENT USER ACCOUNT POLICIES=========================== >> %results%
	echo %BORDER% >> %results%
		net accounts | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	list of groups on the computer
	echo %BORDER% >> %results%
	echo ======LIST OF GROUPS ON COMPUTER============================== >> %results%
	echo %BORDER% >> %results%
		net localgroup | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	basic system information
	echo %BORDER% >> %results%
	echo ======BASIC SYSTEM INFORMATION================================ >> %results%
	echo %BORDER% >> %results%
		systeminfo >> %results%
	echo. >> %results%

echo -	BIOS information
	echo %BORDER% >> %results%
	echo ======BIOS INFORMATION======================================== >> %results%
	echo %BORDER% >> %results%
		wmic bios get BIOSVersion,Caption,Description,Manufacturer,ReleaseDate,SerialNumber,Version /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	local physical disk configuration details
	echo %BORDER% >> %results%
	echo ======PHYSICAL DISK INFORMATION=============================== >> %results%
	echo %BORDER% >> %results%
		wmic diskdrive get BytesPerSector,CapabilityDescriptions,Caption,DeviceID,FirmwareRevision,Index,InstallDate,InterfaceType,Manufacturer,MediaType,Model,Name,Partitions,PNPDeviceID,SerialNumber,Size /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	local logical disk configuration details
	echo %BORDER% >> %results%
	echo ======LOGICAL DISK INFORMATION================================ >> %results%
	echo %BORDER% >> %results%
		wmic logicaldisk get Caption,Compressed,Description,DeviceID,DriveType,FileSystem,FreeSpace,Name,Size,VolumeName,VolumeSerialNumber /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	partition details
	echo %BORDER% >> %results%
	echo ======PARTITION INFORMATION=================================== >> %results%
	echo %BORDER% >> %results%
		wmic partition get BlockSize,Caption,Description,DeviceID,DiskIndex,Name,Size,StartingOffset,SystemName,Type /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	volume details
	echo %BORDER% >> %results%
	echo ======VOLUME INFORMATION====================================== >> %results%
	echo %BORDER% >> %results%
		wmic volume get BlockSize,Capacity,Caption,DeviceID,DriveLetter,FileSystem,FreeSpace,Label,Name,SerialNumber,SystemVolume /format:table | findstr /r /v "^$" >> %results%
		mountvol | findstr "\ *" >> %results%
	echo. >> %results%

echo -	shadow copy details
	echo %BORDER% >> %results%
	echo ======SHADOW COPY DETAILS===================================== >> %results%
	echo %BORDER% >> %results%
		wmic shadowcopy get Caption,Description,DeviceObject,ID,InstallDate,OriginatingMachine,ProviderID,SetID,VolumeName /format:list | findstr /r /v "^$"  >> %results%
	echo. >> %results%

echo -	last system boot time
	echo %BORDER% >> %results%
	echo ======LAST TIME SYSTEM WAS BOOTED============================= >> %results%
	echo %BORDER% >> %results%
		wmic os get lastbootuptime | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	startup info
	echo %BORDER% >> %results%
	echo ======STARTUP INFORMATION===================================== >> %results%
	echo %BORDER% >> %results%
		wmic startup get * /format:list | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	network information including wireless
	echo %BORDER% >> %results%
	echo ======NETWORK INFORMATION===================================== >> %results%
	echo %BORDER% >> %results%
	echo. >> %results%
		ipconfig /all >> %results%
		wmic nicconfig get description,IPAddress,MACaddress | findstr /I /C:":" >> %results%
	echo. >> %results%
	echo ======WIRELESS NETWORK INFO=================================== >> %results%
		netsh wlan show profiles >> %results%
		netsh wlan show profiles * key=clear >> %results%
		set wlansvc=C:\ProgramData\Microsoft\Wlansvc
		echo Looking for XML files in %wlansvc% and copying info >> %results%
		dir /b /s %wlansvc% 2>nul | >nul findstr ".xml" && (@echo Found the following XML profiles >> %results%) && (findstr /I /C:"<name>" /S C:\ProgramData\Microsoft\Wlansvc\*.xml >> %results% 2>nul) && (@echo Copying to output folder >> %results%  && (for /F %%G in ('dir /B /S C:\ProgramData\Microsoft\Wlansvc\*.xml') do copy %%G %acquisition_path%\) 1>nul 2>>%results%) || (@echo No XML profiles found. >> %results%)
		netsh wlan show wirelesscapabilities >> %results% 1>nul
		netsh wlan show interfaces >> %results% 1>nul
		mkdir %wlanreport%
		netsh wlan show wlanreport 1>nul && copy C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.* %wlanreport% 1>nul
	echo. >> %results%

echo -	DNS information
	echo %BORDER% >> %results%
	echo ======DNS INFORMATION========================================= >> %results%
	echo %BORDER% >> %results%
		ipconfig /displaydns >> %results%
	echo. >> %results%

echo -	routing information
	echo %BORDER% >> %results%
	echo ======NETWORK ROUTING INFORMATION============================= >> %results%
	echo %BORDER% >> %results%
		route print >> %results%
	echo. >> %results%

echo -	ARP information
	echo %BORDER% >> %results%
	echo ======ARP INFORMATION========================================= >> %results%
	echo %BORDER% >> %results%
		arp -a >> %results%
	echo. >> %results%

echo -	current users logged on remotely
	echo %BORDER% >> %results%
	echo ======CURRENT USERS LOGGED ON REMOTELY======================== >> %results%
	echo %BORDER% >> %results%
		net sessions >> %results%
	echo. >> %results%

echo -	shares on the system
	echo %BORDER% >> %results%
	echo ======SHARES ON THE SYSTEM==================================== >> %results%
	echo %BORDER% >> %results%
		net share | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	current drive mappings to a remote computer
	echo %BORDER% >> %results%
	echo ======DRIVE MAPPINGS TO REMOTE COMPUTER - CURRENT============= >> %results%
	echo %BORDER% >> %results%
		net use | findstr /r /v "^$" >> %results%
		wmic netuse list full 1>nul >> %results%
	echo. >> %results%

echo -	current network connections (detailed)
	echo %BORDER% >> %results%
	echo ======CURRENT NETWORK CONNECTIONS (DETAILED)================== >> %results%
	echo %BORDER% >> %results%
		netstat -anbo >> %results%
	echo. >> %results%

echo -	firewall status
	echo %BORDER% >> %results%
	echo ======FIREWALL STATUS========================================= >> %results%
	echo %BORDER% >> %results%
		netsh advfirewall show allprofiles >> %results%
		if exist %systemroot%\system32\LogFiles\Firewall\pfirewall.log ( 
			copy %systemroot%\system32\LogFiles\Firewall\pfirewall.log %acquisition_path%\ 1>nul
		) else ( echo No Firewall Log Found in %systemroot%\system32\LogFiles\Firewall\ >> %results%
		)
	echo. >> %results%

echo -	currently running services
	echo %BORDER% >> %results%
	echo ======SERVICES CURRENTLY RUNNING ON THE PC==================== >> %results%
	echo %BORDER% >> %results%
		net start >> %results%
		wmic service get Name,PathName,ServiceType,StartMode /format:table | find /V "" | findstr /r /v "^$" >> %results%
	echo. >> %results%

echo -	running processes
	echo %BORDER% >> %results%
	echo ======RUNNING PROCESSES (DETAILED)============================ >> %results%
	echo %BORDER% >> %results%
		tasklist /v >> %results%
	echo. >> %results%

echo -	scheduled tasks
	echo %BORDER% >> %results%
	echo ======SCHEDULED TASKS========================================= >> %results%
	echo %BORDER% >> %results%
		schtasks /query /FO LIST /V >> %results%
	echo. >> %results%

echo -	contents of Prefetch
	echo %BORDER% >> %results%
	echo ======PREFETCH CONTENTS======================================= >> %results%
	echo %BORDER% >> %results%
		dir /B %SYSTEMDRIVE%\Windows\Prefetch\*.pf >> %results%
	echo. >> %results%

echo -	SAM, SYSTEM and SECURITY hives for NTLM hash extractions
	echo %BORDER% >> %results%
	echo ======SAM, SYSTEM and SECURITY HIVE EXTRACTION================ >> %results%
	echo %BORDER% >> %results%
		reg save hklm\sam %acquisition_path%\sam_%outputfolder% >> %results%
		reg save hklm\system %acquisition_path%\system_%outputfolder% >> %results%
		reg save hklm\security %acquisition_path%\security_%outputfolder% >> %results%
	echo. >> %results%

echo %BORDER% >> %results%
echo ======END OF EVIDENCE COLLECTION============================== >> %results%
echo %BORDER% >> %results%
echo COMPLETED AT: %date% %time: =0% SYSTEMTIME >> %results%
echo ===DONE===
echo.
endlocal
EXIT /B