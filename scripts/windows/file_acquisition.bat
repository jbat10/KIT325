@echo off
setlocal enabledelayedexpansion

set TOOLKIT_ROOT=%~dp0..\..
set TOOLS_DIR=%TOOLKIT_ROOT%\tools\windows
set OUTPUT_DIR=%TOOLKIT_ROOT%\output

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set NTFSTOOL_EXE=%TOOLS_DIR%\ntfstool.x64.exe
) else (
    set NTFSTOOL_EXE=%TOOLS_DIR%\ntfstool.x86.exe
)

if not exist "%NTFSTOOL_EXE%" (
    echo [ERROR] ntfstool.exe not found at: %NTFSTOOL_EXE%
    echo Download from: https://github.com/thewhiteninja/ntfstool
    pause
    exit /b 1
)

:menu
echo Select acquisition method:
echo.
echo 1. File Extraction (ntfstool extract)
echo 2. MFT Analysis (ntfstool mft.dump)
echo 3. NTFS Streams Analysis (ntfstool streams)
echo 4. Undelete Files (ntfstool undelete)
echo 5. Return to main menu
echo.
set /p acq_choice="Select option (1-5): "

if "%acq_choice%"=="1" goto file_extraction
if "%acq_choice%"=="2" goto mft_analysis
if "%acq_choice%"=="3" goto streams_analysis
if "%acq_choice%"=="4" goto undelete_files
if "%acq_choice%"=="5" (
    cls
    exit /b 0
)
echo Invalid choice. Please try again.
goto menu

:file_extraction
cls
echo File Extraction using ntfstool
echo ==============================
echo.
call :select_volume
if errorlevel 1 goto menu

echo.
echo Select extraction method:
echo 1. Extract specific file by path
echo 2. Extract file by MFT inode
echo 3. Extract system files ($MFT, SAM, etc.)
echo 4. Browse volume with ntfstool shell (to find correct paths)
echo.
set /p extract_method="Select method (1-4): "

if "%extract_method%"=="1" goto extract_by_path
if "%extract_method%"=="2" goto extract_by_inode
if "%extract_method%"=="3" goto extract_system_files
if "%extract_method%"=="4" goto browse_volume
echo Invalid choice.
goto file_extraction

:extract_by_path
echo.
echo Volume: %volume_mount%
set /p file_path="Enter full path (e.g., D:\folder\file.txt): "
if "%file_path%"=="" goto file_extraction
set file_path=%file_path:"=%

call :get_timestamp
set EXTRACTION_DIR=%OUTPUT_DIR%\file_extraction_%TIMESTAMP%
mkdir "%EXTRACTION_DIR%"

for %%F in ("%file_path%") do set original_filename=%%~nxF
set OUTPUT_FILE=%EXTRACTION_DIR%\%original_filename%

echo.
echo Extracting: %file_path%
echo Output: %EXTRACTION_DIR%\%original_filename%
echo.

"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% from="%file_path%" output="%OUTPUT_FILE%"

echo.
if exist "%OUTPUT_FILE%" (
    echo [SUCCESS] File extracted to: %EXTRACTION_DIR%
    call :create_metadata "%EXTRACTION_DIR%" "%file_path%" "%original_filename%"
) else (
    echo [ERROR] Extraction failed - file may not exist on selected volume
    echo Try option 2 ^(MFT Analysis^) or option 4 ^(Undelete^)
)
pause
goto menu

:extract_by_inode
set /p inode_num="Enter MFT inode number: "
if "%inode_num%"=="" goto file_extraction

call :get_timestamp
set EXTRACTION_DIR=%OUTPUT_DIR%\inode_extraction_%TIMESTAMP%
mkdir "%EXTRACTION_DIR%"
set OUTPUT_FILE=%EXTRACTION_DIR%\inode_%inode_num%

echo.
echo Extracting inode %inode_num%...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% inode=%inode_num% output="%OUTPUT_FILE%"

if exist "%OUTPUT_FILE%" (
    echo [SUCCESS] Inode extracted to: %EXTRACTION_DIR%
    call :create_metadata "%EXTRACTION_DIR%" "inode:%inode_num%" "inode_%inode_num%"
) else (
    echo [ERROR] Extraction failed
)
pause
goto menu

:extract_system_files
call :get_timestamp
set SYSTEM_DIR=%OUTPUT_DIR%\system_files_%TIMESTAMP%
mkdir "%SYSTEM_DIR%"

echo.
echo Extracting system files...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% inode=0 output="%SYSTEM_DIR%\$MFT"
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --sam output="%SYSTEM_DIR%\SAM"
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --system output="%SYSTEM_DIR%\SYSTEM"
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --security output="%SYSTEM_DIR%\SECURITY"
echo Completed: %SYSTEM_DIR%
pause
goto menu

:browse_volume
echo.
echo Commands: ls, cd, pwd, exit
pause
"%NTFSTOOL_EXE%" shell disk=%disk_num% volume=%volume_num%
goto file_extraction

:mft_analysis
cls
echo MFT Analysis
echo ============
echo.
call :select_volume
if errorlevel 1 goto menu

call :get_timestamp
set MFT_DIR=%OUTPUT_DIR%\mft_analysis_%TIMESTAMP%
mkdir "%MFT_DIR%"


echo Format: 1=CSV 2=JSON 3=Raw
set /p format_choice="Select (1-3): "

if "%format_choice%"=="2" (
    set format=json
    set ext=json
) else if "%format_choice%"=="3" (
    set format=raw
    set ext=raw
) else (
    set format=csv
    set ext=csv
)

set output_file=%MFT_DIR%\mft_dump.%ext%
echo.
echo Dumping MFT...
"%NTFSTOOL_EXE%" mft.dump disk=%disk_num% volume=%volume_num% format=%format% output="%output_file%"
"%NTFSTOOL_EXE%" mft.record disk=%disk_num% volume=%volume_num% inode=5 > "%MFT_DIR%\root_record.txt"
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num% > "%MFT_DIR%\volume_info.txt"
echo Completed: %MFT_DIR%
pause
goto menu

:streams_analysis
cls
echo Streams Analysis
echo ===============
echo.
call :select_volume
if errorlevel 1 goto menu

set /p file_path="Enter full path: "
if "%file_path%"=="" goto streams_analysis

call :get_timestamp
set STREAMS_DIR=%OUTPUT_DIR%\streams_%TIMESTAMP%
mkdir "%STREAMS_DIR%"

echo.
echo Analyzing streams...
"%NTFSTOOL_EXE%" streams disk=%disk_num% volume=%volume_num% from="%file_path%" > "%STREAMS_DIR%\streams.txt"
echo Completed: %STREAMS_DIR%
pause
goto menu

:undelete_files
cls
echo File Recovery
echo =============
echo.
call :select_volume
if errorlevel 1 goto menu

call :get_timestamp
set UNDELETE_DIR=%OUTPUT_DIR%\undelete_%TIMESTAMP%
mkdir "%UNDELETE_DIR%"

echo.
echo 1. List deleted files
echo 2. Recover by inode
set /p operation="Select (1-2): "

if "%operation%"=="1" (
    echo Searching...
    "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num% format=csv output="%UNDELETE_DIR%\deleted.csv"
    echo Saved to: %UNDELETE_DIR%\deleted.csv
) else if "%operation%"=="2" (
    "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num%
    echo.
    set /p inode_num="Inode: "
    set /p output_name="Filename: "
    if not "!inode_num!"=="" if not "!output_name!"=="" (
        "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num% inode=!inode_num! output="%UNDELETE_DIR%\!output_name!"
        echo Recovered: %UNDELETE_DIR%\!output_name!
    )
)
pause
goto menu

:select_volume
"%NTFSTOOL_EXE%" info
echo.
set /p disk_num="Disk number: "
if "%disk_num%"=="" exit /b 1
"%NTFSTOOL_EXE%" info disk=%disk_num%
echo.
set /p volume_num="Volume number: "
if "%volume_num%"=="" exit /b 1
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num% > temp_volume.txt
type temp_volume.txt
for /f "tokens=3" %%a in ('findstr /i "Mounted" temp_volume.txt') do set volume_mount=%%a
del temp_volume.txt
echo.
set /p confirm="Confirm volume %volume_mount%? (y/n): "
if /i not "%confirm%"=="y" exit /b 1
exit /b 0

:get_timestamp
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
exit /b

:create_metadata
set meta_dir=%~1
set meta_path=%~2
set meta_file=%~3
echo Forensic File Extraction Report > "%meta_dir%\metadata.txt"
echo ================================ >> "%meta_dir%\metadata.txt"
echo. >> "%meta_dir%\metadata.txt"
echo Extraction: %date% %time% >> "%meta_dir%\metadata.txt"
echo Disk: %disk_num% Volume: %volume_num% >> "%meta_dir%\metadata.txt"
echo Mount: %volume_mount% >> "%meta_dir%\metadata.txt"
echo Source: %meta_path% >> "%meta_dir%\metadata.txt"
echo Filename: %meta_file% >> "%meta_dir%\metadata.txt"
echo Tool: ntfstool >> "%meta_dir%\metadata.txt"
exit /b