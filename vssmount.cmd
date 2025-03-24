@echo off
:: ***********************************************************************************************
:: ** The Purpose of this Batch Script is to allow for mass mounting of Volume Shadow Copies to a 
:: ** mount point on the local Windows filesystem. When mounting another disk or forensic image, 
:: ** Arsenal Image Mounter will allow the shadow copies to (most recent successful test 3.0.79)
:: ** be seen.
:: ** Feel free to modify this script as you see fit.
:: ** Source: https://github.com/digitalsleuth/forensics_tools
:: ** Last Update: 2020-09-06 Corey Forman
:: ***********************************************************************************************
MODE con:cols=130
setlocal
set version=2.0
@title vssmount v%version%
goto admin
:admin
    net session >nul 2>&1
    if %errorLevel% == 0 (
		cls
        goto start
    ) else (
        echo This script requires administrator privileges. Run as admin, and try again. Exiting...
		TIMEOUT 5
		EXIT /B %ERRORLEVEL%
    )
:start
ECHO Volume Shadow Copy Mount Tool - v%version%
ECHO https://github.com/digitalsleuth/forensics_tools
ECHO.
ECHO -----------------------------------------------------------------------------------------------------------
ECHO This tool will allow you to mount all Volume Shadow Copies for all drives which are mounted and contain 
ECHO Volume Shadow Copies. If you want to mount VSC's from another disk or forensic image, Arsenal Image 
ECHO Mounter will allow the shadow copies to be seen. 
ECHO NOTE: Disk/Image must be mounted in 'Write temporary' mode.
ECHO.
ECHO If you are looking to use this tool to capture locked files, you may want to create a VSC before using this
ECHO tool to capture the most recent files. 
ECHO.
ECHO To do this in Windows Servers 2008/12/16, run the following from an Administrator Command Prompt / 
ECHO PowerShell Terminal:
ECHO vssadmin create shadow /for=c: (or the volume of your choice)
ECHO.
ECHO To do this in Windows 7/8/8.1/10, run the following from an Administrator Command Prompt / 
ECHO PowerShell Terminal:
ECHO wmic shadowcopy call create Volume=C:\ (requires proper case and the SLASH at the end)
ECHO You can run vssadmin list volumes to get the correct volume identifier/path.
ECHO.
ECHO If you wish to mount a VSC manually, you can use the following commands:
ECHO mkdir C:\Windows\Temp\mount_vsc
ECHO.
ECHO for /f "tokens=4" %%f in ('vssadmin list shadows ^|findstr GLOBALROOT') do 
ECHO @for /f "tokens=4 delims=\" %%g in ("%%f") do @mklink /d C:\Windows\temp\mount_vsc\%%g %%f\
ECHO.
ECHO for /f %%f in ('dir /b C:\Windows\Temp\mount_vsc\Hard*') do rmdir C:\Windows\Temp\mount_vsc\%%f
ECHO -----------------------------------------------------------------------------------------------------------
ECHO.
ECHO [L] - List available shadow copies
ECHO.
ECHO [C] - Create a VSC
ECHO.
ECHO [M] - Mount all detected volumes
ECHO.
ECHO [I] - Mount individual volume
ECHO.
ECHO [D] - Display volumes mounted in chosen path
ECHO.
ECHO [S] - Unmount single volume
ECHO.
ECHO [U] - Unmount all mounted volumes
ECHO.
ECHO [Q] - Quit this script
ECHO.
goto choose
:choose
:: Present the user a choice
ECHO.
set /p choice="VSC Mount Options: [L]ist, [C]reate, [M]ount, [I]ndividual mount, [D]isplay mounted, [S]ingle unmount, [U]nmount all, [Q]uit: "
if /I "%choice%"=="Q" goto quit
if /I "%choice%"=="L" goto vsclist
if /I "%choice%"=="C" goto create
if /I "%choice%"=="D" goto mounted
if /I "%choice%"=="M" goto mount
if /I "%choice%"=="U" goto unmount
if /I "%choice%"=="I" goto i_mount
if /I "%choice%"=="S" goto s_unmount
if not "%choice%"=='' (
ECHO "%choice%" is not valid - please choose again
ECHO.
)
:: If one of the above choices aren't given, then give an error and re-prompt
goto choose

:vsclist
:: Used to display pertinent information from vssadmin to determine which volume user wants to mount.
vssadmin list shadows | findstr "Originating creation GLOBALROOT Volume"
goto choose

:create
:: Will create a volume shadow copy to potentially capture locked files
:: Get Version as variable, and if variable equals something, use this command
vssadmin list volumes | findstr /C:"Volume path"
set /p driveletter="Choose your drive letter. Make sure it is in the correct case and includes the \: "
for /f "tokens=2-3" %%i in ('wmic os get Caption ^|findstr Windows') do set version=%%i %%j
if "%version%" == "Windows 10" goto create_wmic
if "%version%" == "Windows 8.1" goto create_wmic
if "%version%" == "Windows 8" goto create_wmic
if "%version%" == "Windows 7" goto create_wmic
if "%version%" == "Windows Server" goto create_vssadmin

:create_wmic
wmic shadowcopy call create Volume=%driveletter%
if %errorlevel% == 0 (
  ECHO VSC Created
  goto choose
  ) else (
  ECHO Error creating VSC - Check your input for the correct case and \ and try again
  goto choose
  )

:create_vssadmin
vssadmin create shadow /for=%driveletter%
if %errorlevel% == 0 (
  ECHO VSC Created
  goto choose
  ) else (
  ECHO Error creating VSC - Check your input for the correct case and frive letter and try again
  goto choose
  )

:mount
@echo Choose folder to use as MountPoint. If the folder does not exist, it will be created.
:: Create a variable to test the existence of a path
set /p fullpath="Folder: "
:: Check for the path - If it exists, then mount to that path, if it doesn't, create the directory then mount.
IF EXIST %fullpath% (goto :domount) ELSE goto :mkfolder
goto choose

:domount
ECHO.
:: This is how the mount points are created - uses %fullpath% as a mounting point 
for /f "tokens=4" %%f in ('vssadmin list shadows ^|findstr GLOBALROOT') do @for /f "tokens=4 delims=\" %%g in ("%%f") do @mklink /d %fullpath%\%%g %%f\
@echo VSC's Mounted at %fullpath%
goto choose

:mkfolder
:: If the folder given at start does not exist, then create it and continue with the mount process.
@echo Directory does not exist - creating...
mkdir %fullpath%
if %errorlevel% == 0 (
  goto domount
  ) else (
  echo Error creating folder - error level %errorlevel%
  goto choose
  )

:i_mount
:: In the event there is only one VSC of interest, choose the one you want.
@echo Choose folder to use as MountPoint. If the folder does not exist, it will be created.
set /p fullpath="Folder: "
vssadmin list shadows | findstr "Originating creation GLOBALROOT Volume"
goto choose_mount

:choose_mount
@echo Identify only the # of the volume you wish to mount.
set /p i_vscnum="VSC #: "
set /a isnum=i_vscnum
if %isnum% EQU %i_vscnum% (
    if %i_vscnum% GTR 0 (
	goto verify_mount
	) 
	if %i_vscnum% EQU 0 (
	@echo That was not a valid option, please try again.
	goto choose_mount
	)
	if %i_vscnum% LSS 0 (
	@echo That was not a valid option, please try again.
	goto choose_mount 
	)
) else (
@echo That was not a valid option, please try again.
goto choose_mount
)

:verify_mount
set vscfolder=HarddiskVolumeShadowCopy%i_vscnum%
for /f "tokens=5 delims=\" %%f in ('vssadmin list shadows ^| findstr /C:"HarddiskVolumeShadowCopy"') do (
  if %vscfolder%==%%f (
  goto continue_mount
  )
)
ECHO VSC does not exist - try again
goto choose_mount

:continue_mount
ECHO.
:: The following will determine if the folder and mountpoint already exist, and decide what happens from there.
set mountpoint=%fullpath%\%vscfolder%
	IF EXIST %fullpath% (
		IF NOT EXIST %mountpoint% (
		for /f "tokens=4" %%f in ('vssadmin list shadows ^|findstr GLOBALROOT ^|findstr %i_vscnum%') do @for /f "tokens=4 delims=\" %%g in ("%%f") do @mklink /d %fullpath%\%%g %%f\
		ECHO.
		) ELSE (
			@echo VSC Mount point already exists at %mountpoint%. Please either change your path, use the single unmount option 
			@echo to unmount the existing mount point, or the unmount all option and try again.
			ECHO.
			goto choose
			)
		)
	IF NOT EXIST %fullpath% (
		@echo Directory does not exist - creating...
		mkdir %fullpath%
		IF EXIST %fullpath% (
			@echo Created, mounting VSC) ELSE (
				@echo Error creating directory - stopping
				ECHO.
				goto choose
				)
		for /f "tokens=4" %%f in ('vssadmin list shadows ^|findstr GLOBALROOT ^|findstr %i_vscnum%') do @for /f "tokens=4 delims=\" %%g in ("%%f") do @mklink /d %fullpath%\%%g %%f\
		@echo VSC mounted.
		ECHO.
)
goto choose

:mounted
:: Used to assist the user in determining what points have already been mounted
@echo Enter the folder where you'd like to check for mount points.
set /p fullpath="Folder: "
dir /AL "%fullpath%" 2>nul | >nul findstr "SYMLINKD" && (@echo Found the following symlink/mountpoints && ECHO.) && (dir /AL /b "%fullpath%") || (echo No symlink/mount points found in %fullpath%)
goto choose

:s_unmount
:: This can be used to unmount a single mount point, even if multiple are mounted.
@echo Identify the path for the volume you wish to unmount.
set /p fullpath="Folder: "
@echo Identify only the # of the volume you wish to unmount.
set /p s_vscnum="VSC #: "
set vscfolder=HarddiskVolumeShadowCopy%s_vscnum%
ECHO.
:: Do the mountpoints exists, determine way ahead based on outcome.
set mountpoint=%fullpath%\%vscfolder%
IF NOT EXIST %fullpath% (
	@echo Path does not exist - please re-enter.
	goto s_unmount
) ELSE (
	echo Removing Symlink for %vscfolder% from %fullpath%
	rmdir %mountpoint%
	IF %ERRORLEVEL% NEQ 0 (
		echo ERROR %ERRORLEVEL% - exiting...
		EXIT /B %ERRORLEVEL%
	)
	echo Symlink removed.
	ECHO.
	goto choose
)

:unmount
:: Properly remove the symlinks for the Volume Shadow Copies, ensuring that the VSC's themselves aren't deleted.
set /p remchoice="Path where the VSC's are mounted: "
IF NOT EXIST %remchoice% ( @echo Path does not exist.
	ECHO.
	goto choose 
) ELSE (
	@echo Removing Symlinks from %remchoice%
	for /f %%f in ('dir /b %remchoice%\Hard*') do rmdir %remchoice%\%%f
	IF %ERRORLEVEL% NEQ 0 ( echo %ERRORLEVEL%
		EXIT /B %ERRORLEVEL% 
	)
	echo Symlinks removed
	goto choose
)
:quit
set "fullpath="
endlocal
title Command Prompt
exit /b


