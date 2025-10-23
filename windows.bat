@echo off

title KIT325 Forensics Toolkit - Windows

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    cls
    echo =========================================
    echo   KIT325 Forensics Toolkit - Windows
    echo   Quick Access Menu
    echo =========================================
    echo.
    echo [WARNING] Not running as Administrator!
    echo.
    echo Some operations may fail or have limited functionality:
    echo - Physical disk imaging may be restricted
    echo - Registry access may be limited
    echo - Memory analysis unavailable
    echo.
    echo.
    echo.
    goto main_menu_limited
) else (
    cls
    echo =========================================
    echo   KIT325 Forensics Toolkit - Windows
    echo   Quick Access Menu
    echo =========================================
    echo.
    echo.
)

:main_menu
echo Available Forensic Tools:
echo.
echo 1. File Carving (PhotoRec)
echo 2. File Acquisition (ntfstools)
echo 3. Registry Analysis (RECmd)
echo 4. System Information Collection
echo 5. Exit
echo.
set /p choice="Select tool (1-5): "
goto process_choice

:main_menu_limited
echo Available Forensic Tools:
echo.
echo 1. File Carving (PhotoRec)
echo 2. File Acquisition (ntfstools) 
echo 3. Registry Analysis (RECmd)
echo 4. System Information Collection
echo 5. Exit
echo.
set /p choice="Select tool (1-5): "

:process_choice

if "%choice%"=="1" goto photorec
if "%choice%"=="2" goto file_acquisition
if "%choice%"=="3" goto registry
if "%choice%"=="4" goto system_info
if "%choice%"=="5" goto exit
echo Invalid choice. Please try again.
echo.

:: If admin, go to main menu, else limited menu
net session >nul 2>&1
if %errorLevel% neq 0 (
    goto main_menu_limited
) else (
    goto main_menu
)

:photorec
cls
echo =========================================
echo   PhotoRec File Carving
echo =========================================
echo.
call "scripts\windows\photorec.bat"
goto return_to_menu

:file_acquisition
cls
echo =========================================
echo   File Acquisition Tools
echo =========================================
echo.
call "scripts\windows\file_acquisition.bat"
goto return_to_menu

:registry
cls
echo =========================================
echo   Registry Analysis
echo =========================================
echo.
call "scripts\windows\registry_analysis.bat"
goto return_to_menu

:system_info
cls
echo =========================================
echo   System Information Collection
echo =========================================
echo.
call "scripts\windows\system_info.bat"
goto return_to_menu

:return_to_menu

:: If admin, go to main menu, else limited menu
net session >nul 2>&1
if %errorLevel% neq 0 (
    goto main_menu_limited
) else (
    goto main_menu
)

:exit
cls
exit /b 0