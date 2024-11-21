@echo off&setlocal enabledelayedexpansion
title HyperTN/MIUITN Rom Mod by Thang Nguyen (Based on China ROM)
set /p structure=<META-INF/Structure
echo.***********************************************
echo.
echo.  1. Make sure your computer's hard drive is more than 15 Gb
echo.  2. Please put the phone into Fastboot mode, and then open this script
echo.  3. If the flashing fails, please check driver of PC
echo.
echo.***********************************************
echo.
echo.  y = Keep data (Update HyperTN/MIUITN)           n = Format data (Fist install HyperTN/MIUITN)
echo.
set /p CHOICE="Your choice {y/n}: "
cd %~dp0
echo.
echo.  Please enter the your phone into fastboot
echo.
echo.
echo.***********************************************
META-INF\fastboot getvar product 2>&1 | findstr /r /c:"^product: *ares" || (
	echo. Device is not ares, please check rom file again. Stop!
	echo Your device is: 
	META-INF\fastboot getvar product
	pause		%ares%
	exit /B 1	%ares%
)	%ares%
META-INF\fastboot set_active a   >NUL 2>NUL
echo.
echo.
echo.  Please ignore the prompt 'Invalid sparse file format at magic header'
echo.  Please wait during the flashing process, don't exit
echo.
echo.

for /f %%i in ('dir /b *.new.dat.brx') do (
	set par=%%i
	set par=!par:.new.dat.brx=!
	del /s /q !par!.img >nul 2>nul 
	echo.  Extra !par! ...
	META-INF\brx -d !par!.new.dat.brx -o !par!.img

if !par! == super (
		META-INF\fastboot erase !par!  >NUL 2>NUL
		ping -n 5 127.0.0.1 >nul 2>nul
		echo.  The system is flashing, please don't quit.
	)
	META-INF\fastboot flash !par! !par!.img
)

for /f %%i in ('dir /b firmware-update') do (
	set par=%%~ni
	set url=firmware-update\%%i
	set mtkPar=""
	for %%i in (preloader_raw sspm tee scp mcupm gz lk dpm) do if "%%i" == "!par!" set mtkPar="true"
	if !par! == cust ( 
		META-INF\fastboot flash !par! !url!  >nul 2>nul 
	) else if !mtkPar! == "true" ( 
		META-INF\fastboot flash !par! !url! >nul 2>nul 
		META-INF\fastboot flash !par!1 !url! >nul 2>nul 
		META-INF\fastboot flash !par!2 !url! >nul 2>nul 
		META-INF\fastboot flash !par!_a !url! >nul 2>nul 
		META-INF\fastboot flash !par!_b !url! >nul 2>nul 
	) else if %structure% == VAB ( 
		META-INF\fastboot flash !par!_a !url!
		META-INF\fastboot flash !par!_b !url!
	) else ( 
		META-INF\fastboot flash !par! !url!
	)
)


if /I "%CHOICE%" == "n" (
	echo.  Formatting...
	META-INF\fastboot %* erase userdata  >NUL 2>NUL
	META-INF\fastboot %* erase metadata  >NUL 2>NUL
	META-INF\fastboot %* erase secdata  >NUL 2>NUL
	META-INF\fastboot %* erase exaid  >NUL 2>NUL
	echo.
)
echo.
echo.
echo.  Success, system is restarting. If there is no response, you can restart it manually.
echo.
META-INF\fastboot oem cdms  >NUL 2>NUL
META-INF\fastboot set_active a  >NUL 2>NUL
META-INF\fastboot reboot 
pause
exit