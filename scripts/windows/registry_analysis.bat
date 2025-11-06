@echo off
setlocal enabledelayedexpansion

:: Registry Analysis Tool - RECmd wrapper
:: Comprehensive analysis of registry hives using Eric Zimmerman's RECmd

set TOOLKIT_ROOT=%~dp0..\..
set TOOLS_DIR=%TOOLKIT_ROOT%\tools
set OUTPUT_DIR=%TOOLKIT_ROOT%\output
set RECMD_PATH=%TOOLS_DIR%\windows\RECmd\recmd_portable.bat

:menu
echo Select registry analysis option:
echo.
echo 1. Live Registry Analysis (Export keys and analyse)
echo 2. Registry Hive File Analysis
echo 3. Quick Triage Analysis
echo 4. Return to main menu
echo.
set /p reg_choice="Select option (1-4): "

if "%reg_choice%"=="1" goto live_analysis
if "%reg_choice%"=="2" goto hive_analysis
if "%reg_choice%"=="3" goto triage_analysis
if "%reg_choice%"=="4" (
    cls
    exit /b 0
)
echo Invalid choice. Please try again.
goto menu

:live_analysis
cls
echo Live Registry Analysis
echo ======================
echo.

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set REG_DIR=%OUTPUT_DIR%\registry_live_%TIMESTAMP%
mkdir "%REG_DIR%"
mkdir "%REG_DIR%\hives" >nul 2>&1
mkdir "%REG_DIR%\text_exports" >nul 2>&1

echo Analysing live registry...
echo Output directory: %REG_DIR%
echo.

echo [1/5] Saving system hives...
reg save HKLM\SYSTEM "%REG_DIR%\hives\SYSTEM" >nul 2>&1
reg save HKLM\SOFTWARE "%REG_DIR%\hives\SOFTWARE" >nul 2>&1
reg save HKLM\SECURITY "%REG_DIR%\hives\SECURITY" >nul 2>&1
reg save HKLM\SAM "%REG_DIR%\hives\SAM" >nul 2>&1
reg save HKU\.DEFAULT "%REG_DIR%\hives\DEFAULT" >nul 2>&1
copy "%SystemRoot%\System32\config\*.LOG*" "%REG_DIR%\hives\" >nul 2>&1
echo Complete

echo [2/5] Copying user hives...
if exist "%USERPROFILE%\NTUSER.DAT" (
    powershell -Command "[System.IO.File]::Copy('%USERPROFILE%\NTUSER.DAT', '%REG_DIR%\hives\NTUSER.DAT', $true)" >nul 2>&1
    if not exist "%REG_DIR%\hives\NTUSER.DAT" reg save HKCU "%REG_DIR%\hives\NTUSER.DAT" >nul 2>&1
    copy "%USERPROFILE%\NTUSER.DAT.LOG*" "%REG_DIR%\hives\" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Microsoft\Windows\UsrClass.dat" (
    powershell -Command "[System.IO.File]::Copy('%LOCALAPPDATA%\Microsoft\Windows\UsrClass.dat', '%REG_DIR%\hives\UsrClass.dat', $true)" >nul 2>&1
    if not exist "%REG_DIR%\hives\UsrClass.dat" reg save HKCU\Software\Classes "%REG_DIR%\hives\UsrClass.dat" >nul 2>&1
    copy "%LOCALAPPDATA%\Microsoft\Windows\UsrClass.dat.LOG*" "%REG_DIR%\hives\" >nul 2>&1
)
for /d %%u in (C:\Users\*) do (
    if exist "%%u\NTUSER.DAT" (
        powershell -Command "$basename=[System.IO.Path]::GetFileName('%%u'); [System.IO.File]::Copy('%%u\NTUSER.DAT', '%REG_DIR%\hives\NTUSER_'+$basename, $true)" >nul 2>&1
        copy "%%u\NTUSER.DAT.LOG*" "%REG_DIR%\hives\" >nul 2>&1
    )
    if exist "%%u\AppData\Local\Microsoft\Windows\UsrClass.dat" (
        powershell -Command "$basename=[System.IO.Path]::GetFileName('%%u'); [System.IO.File]::Copy('%%u\AppData\Local\Microsoft\Windows\UsrClass.dat', '%REG_DIR%\hives\UsrClass_'+$basename, $true)" >nul 2>&1
        copy "%%u\AppData\Local\Microsoft\Windows\UsrClass.dat.LOG*" "%REG_DIR%\hives\" >nul 2>&1
    )
)
echo Complete

echo [3/5] Exporting text backups...
reg export "HKLM\SYSTEM" "%REG_DIR%\text_exports\SYSTEM.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE" "%REG_DIR%\text_exports\SOFTWARE.reg" /y >nul 2>&1
reg export "HKCU" "%REG_DIR%\text_exports\CURRENT_USER.reg" /y >nul 2>&1
reg export "HKU" "%REG_DIR%\text_exports\ALL_USERS.reg" /y >nul 2>&1
echo Complete

echo [4/5] Extracting forensic artifacts...
mkdir "%REG_DIR%\artifacts" >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" "%REG_DIR%\artifacts\RecentDocs.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedURLs" "%REG_DIR%\artifacts\TypedURLs.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" "%REG_DIR%\artifacts\RunMRU.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" "%REG_DIR%\artifacts\UserAssist.reg" /y >nul 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" "%REG_DIR%\artifacts\USB_Devices.reg" /y >nul 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList" "%REG_DIR%\artifacts\NetworkList.reg" /y >nul 2>&1
reg export "HKCU\SOFTWARE\Microsoft\Terminal Server Client" "%REG_DIR%\artifacts\RDP_Connections.reg" /y >nul 2>&1
echo Complete

echo [5/5] Saving loaded user hives...
for /f "tokens=1 delims=\" %%a in ('reg query HKU ^| findstr /R "S-1-5-21-"') do (
    for /f "tokens=2 delims=\" %%b in ("%%a") do (
        reg save "%%a" "%REG_DIR%\hives\HKU_%%b" >nul 2>&1
    )
)
echo Complete

echo.
echo Generating report...
set REPORT_FILE=%REG_DIR%\analysis_report.txt
echo Registry Analysis Report > "%REPORT_FILE%"
echo ======================== >> "%REPORT_FILE%"
echo Date: %date% %time% >> "%REPORT_FILE%"
echo Analysis Type: Live Registry >> "%REPORT_FILE%"
echo Hostname: %COMPUTERNAME% >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo Raw Binary Hives (hives\ folder - use these with RECmd): >> "%REPORT_FILE%"
dir /B "%REG_DIR%\hives" >> "%REPORT_FILE%" 2>nul
echo. >> "%REPORT_FILE%"
echo Text Exports (text_exports\ folder - for manual review): >> "%REPORT_FILE%"
echo - SYSTEM.reg, SOFTWARE.reg, SECURITY.reg, SAM.reg >> "%REPORT_FILE%"
echo - CURRENT_USER.reg, ALL_USERS.reg >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo Forensic Artifacts (artifacts\ folder): >> "%REPORT_FILE%"
echo - Recent Documents, Typed URLs, Run MRU >> "%REPORT_FILE%"
echo - UserAssist, OpenSave MRU >> "%REPORT_FILE%"
echo - USB Devices, Network History >> "%REPORT_FILE%"
echo - RDP Connections, Mount Points >> "%REPORT_FILE%"
echo - Office MRU >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo USAGE: >> "%REPORT_FILE%"
echo To analyze with RECmd, use files from the hives\ folder: >> "%REPORT_FILE%"
echo   Example: RECmd.exe -f "%REG_DIR%\hives\SYSTEM" --bn batch.reb --csv output >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo === SYSTEM INFORMATION === >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2>nul | findstr "ProductName" >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallDate 2>nul | findstr "InstallDate" >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner 2>nul | findstr "RegisteredOwner" >> "%REPORT_FILE%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /v ComputerName 2>nul | findstr "ComputerName" >> "%REPORT_FILE%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v TimeZoneKeyName 2>nul | findstr "TimeZoneKeyName" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === INSTALLED SOFTWARE (Top 50) === >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s 2>nul | findstr "DisplayName DisplayVersion Publisher InstallDate" | findstr /v "ParentDisplayName" > "%REG_DIR%\artifacts\installed_software.txt"
powershell -Command "Get-Content '%REG_DIR%\artifacts\installed_software.txt' | Select-Object -First 200" >> "%REPORT_FILE%" 2>nul

echo. >> "%REPORT_FILE%"
echo === USER ACCOUNTS === >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" 2>nul | findstr "ProfileImagePath" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === STARTUP PROGRAMS === >> "%REPORT_FILE%"
echo [HKLM Run Keys] >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul >> "%REPORT_FILE%"
echo [HKCU Run Keys] >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul >> "%REPORT_FILE%"
echo [RunOnce Keys] >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" 2>nul >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" 2>nul >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === RECENT ACTIVITY === >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" 2>nul >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === USB DEVICES (Summary) === >> "%REPORT_FILE%"
reg query "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" 2>nul | findstr "FriendlyName" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === NETWORK HISTORY === >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /s 2>nul | findstr "ProfileName DateCreated" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === TYPED URLS (Browser History) === >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Internet Explorer\TypedURLs" 2>nul >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === NETWORK SHARES === >> "%REPORT_FILE%"
reg query "HKCU\Network" 2>nul >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" 2>nul | findstr "MountPoints2" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo === SHELLBAGS (Folder Access) === >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\Shell\BagMRU" 2>nul >> "%REPORT_FILE%"

echo.
echo ========================================
echo Registry analysis complete!
echo.
echo Output: %REG_DIR%
echo Report: analysis_report.txt
echo Binary hives for RECmd: hives\ folder
echo ========================================
echo.
pause
goto menu

:hive_analysis
cls
echo Registry Hive File Analysis (RECmd)
echo ===================================
echo.

set /p hive_path="Enter path to registry hive file: "
if "%hive_path%"=="" goto menu

if not exist "%hive_path%" (
    echo [ERROR] Hive file not found: %hive_path%
    pause
    goto menu
)

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set HIVE_DIR=%OUTPUT_DIR%\registry_hive_%TIMESTAMP%
mkdir "%HIVE_DIR%"

echo Analysing registry hive: %hive_path%
echo Output directory: %HIVE_DIR%
echo Using RECmd for comprehensive analysis...
echo.

:: Use RECmd with batch file for comprehensive analysis
echo [INFO] Running RECmd comprehensive analysis...
call "%RECMD_PATH%" -f "%hive_path%" --bn "%TOOLS_DIR%\windows\RECmd\BatchExamples\Kroll_Batch.reb" --csv "%HIVE_DIR%" --csvf "hive_comprehensive.csv"

:: Search for common forensic artifacts
echo [INFO] Searching for Run keys...
call "%RECMD_PATH%" -f "%hive_path%" --sk "Run" --csv "%HIVE_DIR%" --csvf "run_keys.csv"

echo [INFO] Searching for MRU artifacts...
call "%RECMD_PATH%" -f "%hive_path%" --sk "MRU" --csv "%HIVE_DIR%" --csvf "mru_keys.csv"

echo [INFO] Searching for USB artifacts...
call "%RECMD_PATH%" -f "%hive_path%" --sk "USB" --csv "%HIVE_DIR%" --csvf "usb_artifacts.csv"

echo [INFO] Searching for User Assist...
call "%RECMD_PATH%" -f "%hive_path%" --sk "UserAssist" --csv "%HIVE_DIR%" --csvf "userassist.csv"

:: Generate summary report
set REPORT_FILE=%HIVE_DIR%\analysis_summary.txt
echo RECmd Registry Hive Analysis Report > "%REPORT_FILE%"
echo ================================== >> "%REPORT_FILE%"
echo Date: %date% %time% >> "%REPORT_FILE%"
echo Hive File: %hive_path% >> "%REPORT_FILE%"
echo Analysis Tool: RECmd v2.1.0.0 >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo Output Files: >> "%REPORT_FILE%"
echo - hive_comprehensive.csv: Comprehensive analysis using Kroll batch file >> "%REPORT_FILE%"
echo - run_keys.csv: Autostart/Run keys >> "%REPORT_FILE%"
echo - mru_keys.csv: Most Recently Used artifacts >> "%REPORT_FILE%"
echo - usb_artifacts.csv: USB device artifacts >> "%REPORT_FILE%"
echo - userassist.csv: UserAssist artifacts >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo.
echo RECmd hive analysis completed: %HIVE_DIR%
echo Check the generated CSV files for detailed results.
echo.
pause
goto menu

:triage_analysis
cls
echo Quick Triage Analysis
echo ====================
echo.

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set TRIAGE_DIR=%OUTPUT_DIR%\registry_triage_%TIMESTAMP%
mkdir "%TRIAGE_DIR%"

echo Performing quick triage analysis...
echo Output directory: %TRIAGE_DIR%
echo.

set TRIAGE_FILE=%TRIAGE_DIR%\triage_report.txt
echo Registry Triage Report > "%TRIAGE_FILE%"
echo ====================== >> "%TRIAGE_FILE%"
echo Date: %date% %time% >> "%TRIAGE_FILE%"
echo. >> "%TRIAGE_FILE%"

:: Quick checks for common indicators
echo === SYSTEM INFORMATION === >> "%TRIAGE_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> "%TRIAGE_FILE%" 2>nul
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallDate >> "%TRIAGE_FILE%" 2>nul
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner >> "%TRIAGE_FILE%" 2>nul

echo. >> "%TRIAGE_FILE%"
echo === RECENT ACTIVITY === >> "%TRIAGE_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" >> "%TRIAGE_FILE%" 2>nul

echo. >> "%TRIAGE_FILE%"
echo === STARTUP PROGRAMS === >> "%TRIAGE_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> "%TRIAGE_FILE%" 2>nul

echo. >> "%TRIAGE_FILE%"
echo === RECENTLY ACCESSED === >> "%TRIAGE_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" >> "%TRIAGE_FILE%" 2>nul

echo Quick triage completed: %TRIAGE_DIR%
pause
goto menu