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
echo 1. Live Registry Analysis
echo 2. Registry Hive File Analysis
echo 3. Quick Triage Analysis
echo 4. Export Registry Keys
echo 5. Return to main menu
echo.
set /p reg_choice="Select option (1-5): "

if "%reg_choice%"=="1" goto live_analysis
if "%reg_choice%"=="2" goto hive_analysis
if "%reg_choice%"=="3" goto triage_analysis
if "%reg_choice%"=="4" goto export_keys
if "%reg_choice%"=="5" (
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

echo Analysing live registry...
echo Output directory: %REG_DIR%
echo.

:: Export critical registry hives
echo Exporting SYSTEM hive...
reg export "HKLM\SYSTEM" "%REG_DIR%\SYSTEM.reg" /y

echo Exporting SOFTWARE hive...
reg export "HKLM\SOFTWARE" "%REG_DIR%\SOFTWARE.reg" /y

echo Exporting SECURITY hive...
reg export "HKLM\SECURITY" "%REG_DIR%\SECURITY.reg" /y 2>nul

echo Exporting SAM hive...
reg export "HKLM\SAM" "%REG_DIR%\SAM.reg" /y 2>nul

echo Exporting user hives...
reg export "HKCU" "%REG_DIR%\CURRENT_USER.reg" /y

:: Create analysis report
set REPORT_FILE=%REG_DIR%\analysis_report.txt
echo Registry Analysis Report > "%REPORT_FILE%"
echo ======================== >> "%REPORT_FILE%"
echo Date: %date% %time% >> "%REPORT_FILE%"
echo Analysis Type: Live Registry >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo Analysing common artifacts...

echo --- Installed Software --- >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr "DisplayName" >> "%REPORT_FILE%"

echo. >> "%REPORT_FILE%"
echo --- Recent Documents --- >> "%REPORT_FILE%"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" >> "%REPORT_FILE%" 2>nul

echo. >> "%REPORT_FILE%"
echo --- USB Devices --- >> "%REPORT_FILE%"
reg query "HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR" >> "%REPORT_FILE%" 2>nul

echo. >> "%REPORT_FILE%"
echo --- Network Shares --- >> "%REPORT_FILE%"
reg query "HKCU\Network" >> "%REPORT_FILE%" 2>nul

echo. >> "%REPORT_FILE%"
echo --- Run Keys --- >> "%REPORT_FILE%"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> "%REPORT_FILE%" 2>nul
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> "%REPORT_FILE%" 2>nul

echo Live registry analysis completed: %REG_DIR%
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

:: Use RECmd for detailed hive analysis
echo [INFO] Running RECmd basic analysis...
call "%RECMD_PATH%" --f "%hive_path%" --csv "%HIVE_DIR%" --csvf "hive_basic_analysis.csv" --details

:: Use RECmd with batch file for comprehensive analysis
echo [INFO] Running RECmd comprehensive analysis...
call "%RECMD_PATH%" --f "%hive_path%" --bn "%TOOLS_DIR%\windows\RECmd\BatchExamples\Kroll_Batch.reb" --csv "%HIVE_DIR%" --csvf "hive_comprehensive.csv"

:: Search for common forensic artifacts
echo [INFO] Searching for common artifacts...
call "%RECMD_PATH%" --f "%hive_path%" --sk "Run" --csv "%HIVE_DIR%" --csvf "run_keys.csv"
call "%RECMD_PATH%" --f "%hive_path%" --sk "MRU" --csv "%HIVE_DIR%" --csvf "mru_keys.csv"
call "%RECMD_PATH%" --f "%hive_path%" --sk "USB" --csv "%HIVE_DIR%" --csvf "usb_artifacts.csv"

:: Generate summary report
set REPORT_FILE=%HIVE_DIR%\analysis_summary.txt
echo RECmd Registry Hive Analysis Report > "%REPORT_FILE%"
echo ================================== >> "%REPORT_FILE%"
echo Date: %date% %time% >> "%REPORT_FILE%"
echo Hive File: %hive_path% >> "%REPORT_FILE%"
echo Analysis Tool: RECmd v2.1.0.0 >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo Output Files: >> "%REPORT_FILE%"
echo - hive_basic_analysis.csv: Basic registry structure >> "%REPORT_FILE%"
echo - hive_comprehensive.csv: Comprehensive analysis using batch file >> "%REPORT_FILE%"
echo - run_keys.csv: Autostart/Run keys >> "%REPORT_FILE%"
echo - mru_keys.csv: Most Recently Used artifacts >> "%REPORT_FILE%"
echo - usb_artifacts.csv: USB device artifacts >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo RECmd hive analysis completed: %HIVE_DIR%
echo Check the generated CSV files for detailed results.
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

:export_keys
cls
echo Export Registry Keys
echo ===================
echo.

echo Common registry keys of forensic interest:
echo 1. SYSTEM (Current Control Set)
echo 2. SOFTWARE (Installed Programs)
echo 3. USER (User Profile Data)
echo 4. SECURITY (Security Settings)
echo 5. Custom key path
echo.
set /p export_choice="Select key to export (1-5): "

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set EXPORT_DIR=%OUTPUT_DIR%\registry_export_%TIMESTAMP%
mkdir "%EXPORT_DIR%"

if "%export_choice%"=="1" (
    set REG_KEY=HKLM\SYSTEM
    set FILE_NAME=SYSTEM_export.reg
)
if "%export_choice%"=="2" (
    set REG_KEY=HKLM\SOFTWARE
    set FILE_NAME=SOFTWARE_export.reg
)
if "%export_choice%"=="3" (
    set REG_KEY=HKCU
    set FILE_NAME=USER_export.reg
)
if "%export_choice%"=="4" (
    set REG_KEY=HKLM\SECURITY
    set FILE_NAME=SECURITY_export.reg
)
if "%export_choice%"=="5" (
    set /p REG_KEY="Enter registry key path (e.g., HKLM\SOFTWARE\Microsoft): "
    set FILE_NAME=custom_export.reg
)

if defined REG_KEY (
    echo Exporting %REG_KEY% to %EXPORT_DIR%\%FILE_NAME%...
    reg export "%REG_KEY%" "%EXPORT_DIR%\%FILE_NAME%" /y
    
    if %errorlevel% equ 0 (
        echo Export completed successfully!
    ) else (
        echo [ERROR] Export failed. Check permissions and key path.
    )
) else (
    echo Invalid selection.
)

pause
goto menu