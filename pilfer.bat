@echo off
:: **************************************************************************************
:: ** Batch File to quickly gather basic system info & volatile network info
:: ** then dump it out to a text file called Acquisition_Results.txt. Although not critical,
:: ** I Recommend that it be run with elevated privs.
:: ** (right click and select "Run as administrator") especially for netstat details.
:: ** Feel free to modify as you see fit.
:: **************************************************************************************
:: ** By Cst. Percival Hall - 2013-12-20 ************************************************
:: ** Modified by Sgt. Corey Forman - 2019-10-26 ****************************************
:: **************************************************************************************
:: ** Version 1.4 ***********************************************************************
setlocal
set fulltime=%time: =0%
set workingdir=%~dp0
set year=%date:~-4%
set month=%date:~4,2%
set day=%date:~7,2%
set hour=%fulltime:~0,2%
set min=%fulltime:~3,2%
set sec=%fulltime:~6,2%
set outputfolder=%year%%month%%day%-%hour%%min%%sec%
set wlanreport=%workingdir%\%outputfolder%\wlan-report
for /f "tokens=*" %a in ('tzutil /g') do set tzcheck=%a
set results=%results%
goto admin
:admin
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto cwd
    ) else (
        echo This script requires administrator privileges. Run as admin, and try again. Exiting
		timeout 5
		EXIT /B %ERRORLEVEL%
)
:cwd
echo.
echo Your current working directory is "%workingdir:~0,-1%"
echo.
goto entername

:entername
set /p "input1=Enter your name and title: "
echo.
set /p "answer1=You entered %input1%, is this correct (Y/n)? "
echo.
   if /i "%answer1:~,1%" EQU "y" goto enterfile
   if /i "%answer1%" EQU "" goto enterfile
   if /i "%answer1:~,1%" EQU "n" goto entername

:: :next1
:: echo INVESTIGATOR : %input1% >> %results%

:enterfile
set /p "input2=Enter your File #: "
echo.
set /p "answer2=You entered %input2%, is this correct (Y/n)? "
echo.
   if /i "%answer2:~,1%" EQU "y" goto currentdt
   if /i "%answer2%" EQU "" goto currentdt
   if /i "%answer2:~,1%" EQU "n" goto enterfile

:: :next2
:: echo FILE NUMBER #: %input2% >> %results%

:currentdt
set datetime=%date:~4,10%-%time: =0%
set /p "answerdt=Current System Date/Time is %datetime%. Is this correct (Y/n)? "
echo.
   if /i "%answerdt:~,1%" EQU "y" set "input3=SYSTEM DATE IS CORRECT" && set "input4=SYSTEM TIME IS CORRECT" && goto enterexhibit
   if /i "%answerdt%" EQU "" set "input3=SYSTEM DATE IS CORRECT" && set "input4=SYSTEM TIME IS CORRECT" && goto enterexhibit
   if /i "%answerdt:~,1%" EQU "n" set datetime=NOT ACCURATE && goto enterdate

:enterdate
set /p "input3=Enter current correct date (yyyy-mm-dd): "
echo.
set /p "answer3=You entered %input3%, is this correct (Y/n)? "
echo.
   if /i "%answer3:~,1%" EQU "y" goto entertime
   if /i "%answer3%" EQU "" goto entertime
   if /i "%answer3:~,1%" EQU "n" goto enterdate

:: :next3
:: echo CORRECT DATE: %input3% >> %results%

:entertime
set /p "input4=Enter current correct time (HH:MM): "
echo.
set /p "answer4=You entered %input4%, is this correct (Y/n)? "
echo.
   if /i "%answer4:~,1%" EQU "y" goto enterexhibit
   if /i "%answer4%" EQU "" goto enterexhibit
   if /i "%answer4:~,1%" EQU "n" goto entertime

:: :next4
:: echo CORRECT TIME: %input4% >> %results%

:enterexhibit
set /p "input5=Enter descriptive info about this Exhibit: "
echo.
set /p "answer5=You entered %input5%, is this correct (Y/n)? "
echo.
   if /i "%answer5:~,1%" EQU "y" goto startoutput
   if /i "%answer5%" EQU "" goto startoutput
   if /i "%answer5:~,1%" EQU "n" goto enterexhibit

   
:startoutput
mkdir %workingdir%\%outputfolder%
echo INVESTIGATOR: %input1% >> %results%
echo FILE NUMBER : %input2% >> %results%
echo CURRENT TIME: %datetime% >> %results%
echo CORRECT DATE: %input3% >> %results%
echo CORRECT TIME: %input4% >> %results%
echo EXHIBIT INFO: %input5% >> %results%
echo TIMEZONE: %tzcheck% >> %results%
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
		echo Looking for XML files in "C:\ProgramData\Microsoft\Wlansvc" and copying info >> %results%
		findstr /I /C:"<name>" /S C:\ProgramData\Microsoft\Wlansvc\*.xml >> %results%
		for /F %%G in ('dir /B /S C:\ProgramData\Microsoft\Wlansvc\*.xml') do copy %%G %workingdir%\%outputfolder%\ 1>> %results% 2>>&1
		netsh wlan show wirelesscapabilities >> %results%
		netsh wlan show interfaces >> %results%
		mkdir %wlanreport%
		netsh wlan show wlanreport 2>>&1 && copy C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.* %wlanreport% 2>>&1
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
	echo. >> %results%

:: echo 	cached drive mappings to a remote computer
:: echo %BORDER% >> %results%
:: echo ======DRIVE MAPPINGS TO REMOTE COMPUTER - CACHED============== >> %results%
:: echo %BORDER% >> %results%
:: net view /cache >> %results%
:: wmic netuse list full >> %results%
:: echo. >> %results%

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
			type %systemroot%\system32\LogFiles\Firewall\pfirewall.log >> %workingdir%\%outputfolder%\pfirewall.log 
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

echo -	SAM and SYSTEM hives for hash extraction
	echo %BORDER% >> %results%
	echo ======SAM and SYSTEM HIVES EXTRACTED========================== >> %results%
	echo %BORDER% >> %results%
		reg save hklm\sam %workingdir%\%outputfolder%\sam_%outputfolder% >> %results%
		reg save hklm\system %workingdir%\%outputfolder%\system_%outputfolder% >> %results%
	echo. >> %results%

echo %BORDER% >> %results%
echo ======END OF EVIDENCE COLLECTION============================== >> %results%
echo %BORDER% >> %results%
echo COMPLETED AT: %date% %time: =0% SYSTEMTIME >> %results%
echo ===DONE===
endlocal
timeout 5