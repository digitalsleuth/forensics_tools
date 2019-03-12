:: The Purpose of this Batch Script is to allow for mass mounting of Volume Shadow Copies to a 
:: mount point on the local Windows filesystem.
:: v1.1 2019-03-11 Corey Forman
cls
@echo off

:start
ECHO Volume Shadow Copy Mount Tool - v1.1
ECHO.
ECHO.
ECHO This tool will allow you to mount all Volume Shadow Copies
ECHO for all drives which are mounted and have Volume Shadow Copies.
ECHO ---------------------------------------------------------------
ECHO If you have any questions - visit https://github.com/fetchered/
ECHO ---------------------------------------------------------------
ECHO.
ECHO M - Mount all detected Volume Shadow Copies
ECHO.
ECHO U - Unmount all mounted Volume Shadow Copies
ECHO.
ECHO Q - Quit this script
ECHO.  
:: Present the user a choice
set /p choice="VSC Mount Options: [M]ount,[U]nmount,[Q]uit: "
if /I "%choice%"=="Q" goto quit
if /I "%choice%"=="M" goto mount
if /I "%choice%"=="U" goto unmount
if not "%choice%"=='' (cls
ECHO "%choice%" is not valid - please choose again
ECHO.
)
:: If one of the above choices aren't given, then give an error and re-prompt
goto start

:mount
@echo Choose folder to use as MountPoint. If the folder does not exist, it will be created.
:: Create a variable to test the existence of a path
set /p fullpath="Full Path: "
:: Check for the path - If it exists, then mount to that path, if it doesn't, create the directory then mount.
IF EXIST %fullpath% (goto :domount) ELSE goto :mkfolder
goto start

:domount
ECHO.
:: This is how the mount points are created - takes %fullpath% as a variable from start
for /f "tokens=4" %%f in ('vssadmin list shadows ^|findstr GLOBALROOT') do @for /f "tokens=4 delims=\" %%g in ("%%f") do @mklink /d %fullpath%\%%g %%f\
@echo VSC's Mounted at %fullpath%
PAUSE
cls
goto start

:mkfolder
:: If the folder given at start does not exist, then create it and continue with the mount process.
@echo Directory does not exist - creating...
mkdir %fullpath%
goto domount

:unmount
:: Properly remove the symlinks for the Volume Shadow Copies, ensuring that the VSC's themselves aren't deleted.
set /p remchoice="Path where the VSC's are mounted: "
@echo Removing Symlinks from %remchoice%
for /f %%f in ('dir /b %remchoice%\Hard*') do rmdir %remchoice%\%%f
IF %ERRORLEVEL% NEQ 0 ( echo %ERRORLEVEL%
EXIT /B %ERRORLEVEL% 
)
@echo Symlinks removed
PAUSE
cls
goto start

:quit
set "fullpath="
cls