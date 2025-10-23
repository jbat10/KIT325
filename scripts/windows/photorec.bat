@echo off
setlocal enabledelayedexpansion

:: PhotoRec File Carving Wrapper
:: Recovers deleted or obfuscated files

set TOOLKIT_ROOT=%~dp0..\..
set TOOLS_DIR=%TOOLKIT_ROOT%\tools
set OUTPUT_DIR=%TOOLKIT_ROOT%\output

:: Create output directory with timestamp
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set SESSION_DIR=%OUTPUT_DIR%\photorec_%TIMESTAMP%
mkdir "%SESSION_DIR%" 2>nul

:: Check for administrator privileges and request if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges to access hard disks.
    echo Please run as administrator or the script will attempt to elevate...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Launch PhotoRec with output directory and log file specified
"%TOOLS_DIR%\windows\testdisk_win\photorec_win.exe" /log /logname "%SESSION_DIR%\photorec.log" /d "%SESSION_DIR%"
echo.
echo PhotoRec has been closed.
echo Results saved to: %SESSION_DIR%
pause
exit /b 0

