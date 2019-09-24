@echo off
:: **************************************************************************************
:: ** Batch File to quickly gather basic system info & volatile network info
:: ** then dump it out to a text file called Acquisition_Results.txt. Although not critical,
:: ** I Recommend that it be run with elevated privs.
:: ** (right click and select "Run as administrator") especially for netstat details.
:: ** Feel free to modify as you see fit.
:: **************************************************************************************
:: ** By Cst. Percival Hall - 2013-12-20 ************************************************
:: ** Modified by Sgt. Corey Forman - 2019-09-23 ****************************************
:: **************************************************************************************
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
:: echo INVESTIGATOR : %input1% >> %workingdir%\%outputfolder%\Acquisition_Results.txt

:enterfile
set /p "input2=Enter your File #: "
echo.
set /p "answer2=You entered %input2%, is this correct (Y/n)? "
echo.
   if /i "%answer2:~,1%" EQU "y" goto currentdt
   if /i "%answer2%" EQU "" goto currentdt
   if /i "%answer2:~,1%" EQU "n" goto enterfile

:: :next2
:: echo FILE NUMBER #: %input2% >> %workingdir%\%outputfolder%\Acquisition_Results.txt

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
:: echo CORRECT DATE: %input3% >> %workingdir%\%outputfolder%\Acquisition_Results.txt

:entertime
set /p "input4=Enter current correct time (HH:MM): "
echo.
set /p "answer4=You entered %input4%, is this correct (Y/n)? "
echo.
   if /i "%answer4:~,1%" EQU "y" goto enterexhibit
   if /i "%answer4%" EQU "" goto enterexhibit
   if /i "%answer4:~,1%" EQU "n" goto entertime

:: :next4
:: echo CORRECT TIME: %input4% >> %workingdir%\%outputfolder%\Acquisition_Results.txt

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
echo INVESTIGATOR: %input1% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo FILE NUMBER : %input2% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo CURRENT TIME: %datetime% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo CORRECT DATE: %input3% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo CORRECT TIME: %input4% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo EXHIBIT INFO: %input5% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
goto startprocess

:startprocess
set BORDER===============================================================

echo Getting:
echo -	current system date and time
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======CURRENT SYSTEM DATE/TIME AND TIMEZONE=================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		echo %date% %time: =0% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		reg query "hklm\system\currentcontrolset\control\timezoneinformation" | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic timezone get bias,caption,daylightbias,daylightname /format:list| findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic os get currenttimezone /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	current user
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======CURRENT USER============================================ >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		whoami >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======ALL USER ACCOUNTS======================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic useraccount get caption,domain,fullname,name,SID /format:table | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net user | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	account policies
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======CURRENT USER ACCOUNT POLICIES=========================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net accounts | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	list of groups on the computer
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======LIST OF GROUPS ON COMPUTER============================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net localgroup | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	basic system information
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======BASIC SYSTEM INFORMATION================================ >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		systeminfo >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	BIOS information
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======BIOS INFORMATION======================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic bios get BIOSVersion,Caption,Description,Manufacturer,ReleaseDate,SerialNumber,Version /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	local physical disk configuration details
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======PHYSICAL DISK INFORMATION=============================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic diskdrive get BytesPerSector,CapabilityDescriptions,Caption,DeviceID,FirmwareRevision,Index,InstallDate,InterfaceType,Manufacturer,MediaType,Model,Name,Partitions,PNPDeviceID,SerialNumber,Size /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	local logical disk configuration details
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======LOGICAL DISK INFORMATION================================ >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic logicaldisk get Caption,Compressed,Description,DeviceID,DriveType,FileSystem,FreeSpace,Name,Size,VolumeName,VolumeSerialNumber /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	partition details
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======PARTITION INFORMATION=================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic partition get BlockSize,Caption,Description,DeviceID,DiskIndex,Name,Size,StartingOffset,SystemName,Type /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	volume details
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======VOLUME INFORMATION====================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic volume get BlockSize,Capacity,Caption,DeviceID,DriveLetter,FileSystem,FreeSpace,Label,Name,SerialNumber,SystemVolume /format:table | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		mountvol | findstr "\ *" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	shadow copy details
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======SHADOW COPY DETAILS===================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic shadowcopy get Caption,Description,DeviceObject,ID,InstallDate,OriginatingMachine,ProviderID,SetID,VolumeName /format:list | findstr /r /v "^$"  >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	last system boot time
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======LAST TIME SYSTEM WAS BOOTED============================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic os get lastbootuptime | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	startup info
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======STARTUP INFORMATION===================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic startup get * /format:list | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	network information including wireless
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======NETWORK INFORMATION===================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		ipconfig /all >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic nicconfig get description,IPAddress,MACaddress | findstr /I /C:":" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======WIRELESS NETWORK INFO=================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		netsh wlan show profiles >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		netsh wlan show profiles * key=clear >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		echo Looking for XML files in "C:\ProgramData\Microsoft\Wlansvc" and copying info >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		findstr /I /C:"<name>" /S C:\ProgramData\Microsoft\Wlansvc\*.xml >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		for /F %%G in ('dir /B /S C:\ProgramData\Microsoft\Wlansvc\*.xml') do copy %%G %workingdir%\%outputfolder%\ 1>> %workingdir%\%outputfolder%\Acquisition_Results.txt 2>>&1
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	DNS information
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======DNS INFORMATION========================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		ipconfig /displaydns >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	routing information
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======NETWORK ROUTING INFORMATION============================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		route print >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	ARP information
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======ARP INFORMATION========================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		arp -a >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	current users logged on remotely
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======CURRENT USERS LOGGED ON REMOTELY======================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net sessions >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	shares on the system
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======SHARES ON THE SYSTEM==================================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net share | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	current drive mappings to a remote computer
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======DRIVE MAPPINGS TO REMOTE COMPUTER - CURRENT============= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net use | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

:: echo 	cached drive mappings to a remote computer
:: echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
:: echo ======DRIVE MAPPINGS TO REMOTE COMPUTER - CACHED============== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
:: echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
:: net view /cache >> %workingdir%\%outputfolder%\Acquisition_Results.txt
:: wmic netuse list full >> %workingdir%\%outputfolder%\Acquisition_Results.txt
:: echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	current network connections (detailed)
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======CURRENT NETWORK CONNECTIONS (DETAILED)================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		netstat -anbo >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	firewall status
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======FIREWALL STATUS========================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		netsh advfirewall show allprofiles >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		if exist %systemroot%\system32\LogFiles\Firewall\pfirewall.log ( 
			type %systemroot%\system32\LogFiles\Firewall\pfirewall.log >> %workingdir%\%outputfolder%\pfirewall.log 
		) else ( echo No Firewall Log Found in %systemroot%\system32\LogFiles\Firewall\ >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		)
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	currently running services
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======SERVICES CURRENTLY RUNNING ON THE PC==================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		net start >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		wmic service get Name,PathName,ServiceType,StartMode /format:table | find /V "" | findstr /r /v "^$" >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	running processes
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======RUNNING PROCESSES (DETAILED)============================ >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		tasklist /v >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	scheduled tasks
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======SCHEDULED TASKS========================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		schtasks /query /FO LIST /V >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	contents of Prefetch
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======PREFETCH CONTENTS======================================= >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		dir /B %SYSTEMDRIVE%\Windows\Prefetch\*.pf >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo -	SAM and SYSTEM hives for hash extraction
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo ======SAM and SYSTEM HIVES EXTRACTED========================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		reg save hklm\sam %workingdir%\%outputfolder%\sam_%outputfolder% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
		reg save hklm\system %workingdir%\%outputfolder%\system_%outputfolder% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
	echo. >> %workingdir%\%outputfolder%\Acquisition_Results.txt

echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo ======END OF EVIDENCE COLLECTION============================== >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo %BORDER% >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo COMPLETED AT: %date% %time: =0% SYSTEMTIME >> %workingdir%\%outputfolder%\Acquisition_Results.txt
echo ===DONE===
endlocal
timeout 5