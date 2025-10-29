@echo off
setlocal enabledelayedexpansion

:: File Acquisition Tool - Windows ntfstool wrapper
:: Individual file extraction and NTFS analysis using ntfstool by thewhiteninja
:: https://github.com/thewhiteninja/ntfstool
:: NOTE: This Windows version uses ntfstool. For dd functionality, use the Linux version.

set TOOLKIT_ROOT=%~dp0..\..
set TOOLS_DIR=%TOOLKIT_ROOT%\tools\windows
set OUTPUT_DIR=%TOOLKIT_ROOT%\output

:: Auto-detect system architecture and select appropriate ntfstool version
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set NTFSTOOL_EXE=%TOOLS_DIR%\ntfstool.x64.exe
    set ARCH_TYPE=x64
) else if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set NTFSTOOL_EXE=%TOOLS_DIR%\ntfstool.x86.exe
    set ARCH_TYPE=x86
) else (
    :: Default to x64 if unknown
    set NTFSTOOL_EXE=%TOOLS_DIR%\ntfstool.x64.exe
    set ARCH_TYPE=x64
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
if "%acq_choice%"=="5" exit /b 0
echo Invalid choice. Please try again.
goto menu

:file_extraction
cls
echo File Extraction using ntfstool
echo ==============================
echo.

:: Check if ntfstool is available
if not exist "%NTFSTOOL_EXE%" (
    echo [ERROR] ntfstool.exe not found at: %NTFSTOOL_EXE%
    echo Please download ntfstool from: https://github.com/thewhiteninja/ntfstool
    echo and place it in the tools\windows directory.
    pause
    goto menu
)

echo Available disks and volumes:
echo ==========================================
"%NTFSTOOL_EXE%" info
echo.
echo NOTE: Look at the table above:
echo - "Id" column shows the disk number (0, 1, 2, etc.)
echo - For each disk, volumes are numbered starting from 1
echo - Choose an NTFS volume for best results
echo.

:select_disk_vol
set /p disk_num="Enter disk number (from Id column above): "
if "%disk_num%"=="" goto file_extraction

echo.
echo Showing detailed info for disk %disk_num%:
"%NTFSTOOL_EXE%" info disk=%disk_num%
echo.

set /p volume_num="Enter volume number (1, 2, 3, etc.): "
if "%volume_num%"=="" goto select_disk_vol

echo.
echo Selected: Disk %disk_num%, Volume %volume_num%
echo Showing volume details:
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num% > temp_volume_info.txt
type temp_volume_info.txt

:: Extract the mount point from the volume info
for /f "tokens=3" %%a in ('findstr /i "Mounted" temp_volume_info.txt') do set volume_mount=%%a
del temp_volume_info.txt

echo.
echo IMPORTANT: Make sure the file you want to extract is on THIS volume!
echo This volume is mounted as: %volume_mount%
echo.
set /p confirm="Is this the correct volume for your target file? (y/n): "
if /i not "%confirm%"=="y" goto select_disk_vol

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
echo IMPORTANT: Based on ntfstool documentation, enter the FULL Windows path.
echo Examples:
echo - For a file on C: drive: C:\Windows\System32\file.exe
echo - For a file on D: drive: D:\TFTV\horizontal.mp4
echo.
echo The selected volume is mounted as: %volume_mount%
echo.
set /p file_path="Enter full Windows path to file (e.g., D:\folder\file.txt): "
if "%file_path%"=="" goto file_extraction

:: Remove quotes if present
set file_path=%file_path:"=%

echo DEBUG: File path to extract: %file_path%

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set OUTPUT_FILE=%OUTPUT_DIR%\extracted_file_%TIMESTAMP%

echo.
echo Extracting file using ntfstool...
echo Disk: %disk_num%, Volume: %volume_num%
echo Source: %file_path%
echo Output: %OUTPUT_FILE%
echo.
echo DEBUG: Full command being executed:
echo "%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% from="%file_path%" output="%OUTPUT_FILE%"
echo.

"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% from="%file_path%" output="%OUTPUT_FILE%"

echo.
if exist "%OUTPUT_FILE%" (
    echo Extraction completed successfully: %OUTPUT_FILE%
) else (
    echo.
    echo [ERROR] Extraction failed!
    echo Common issues:
    echo 1. File path doesn't exist on the selected volume
    echo 2. Wrong disk/volume selected - make sure the "Mounted" field matches your drive
    echo 3. File path should start with \ and not include drive letter
    echo.
    echo Example: If you want D:\folder\file.txt:
    echo - First select the disk/volume where D: is mounted
    echo - Then enter path as: \folder\file.txt
)
pause
goto menu

:extract_by_inode
set /p inode_num="Enter MFT inode number (e.g., 0 for $MFT): "
if "%inode_num%"=="" goto file_extraction

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set OUTPUT_FILE=%OUTPUT_DIR%\extracted_inode_%inode_num%_%TIMESTAMP%

echo.
echo Extracting file by inode using ntfstool...
echo Disk: %disk_num%, Volume: %volume_num%
echo Inode: %inode_num%
echo Output: %OUTPUT_FILE%
echo.

"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% inode=%inode_num% output="%OUTPUT_FILE%"

echo.
echo Extraction completed: %OUTPUT_FILE%
pause
goto menu

:extract_system_files
echo.
echo Extracting common system files using ntfstool...
echo.

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set SYSTEM_DIR=%OUTPUT_DIR%\system_files_%TIMESTAMP%
mkdir "%SYSTEM_DIR%"

echo 1. Extracting $MFT (Master File Table)...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% inode=0 output="%SYSTEM_DIR%\$MFT"

echo 2. Extracting SAM (Security Account Manager)...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --sam output="%SYSTEM_DIR%\SAM"

echo 3. Extracting SYSTEM registry hive...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --system output="%SYSTEM_DIR%\SYSTEM"

echo 4. Extracting SECURITY registry hive...
"%NTFSTOOL_EXE%" extract disk=%disk_num% volume=%volume_num% --security output="%SYSTEM_DIR%\SECURITY"

echo.
echo System files extracted to: %SYSTEM_DIR%
pause
goto menu

:browse_volume
echo.
echo Opening ntfstool shell for Disk %disk_num%, Volume %volume_num%
echo.
echo Commands you can use in the shell:
echo - ls : list current directory
echo - cd foldername : change to folder
echo - pwd : show current path
echo - exit : exit shell
echo.
echo Look for your file and note the exact path, then exit and use option 1.
pause

"%NTFSTOOL_EXE%" shell disk=%disk_num% volume=%volume_num%
goto file_extraction



:mft_analysis
cls
echo MFT Analysis using ntfstool
echo ===========================
echo.

:: Check if ntfstool is available
if not exist "%NTFSTOOL_EXE%" (
    echo [ERROR] ntfstool.exe not found at: %NTFSTOOL_EXE%
    echo Please download ntfstool from: https://github.com/thewhiteninja/ntfstool
    echo and place it in the tools\windows directory.
    pause
    goto menu
)

echo Available disks and volumes:
echo ==========================================
"%NTFSTOOL_EXE%" info
echo.
echo NOTE: Look at the table above:
echo - "Id" column shows the disk number (0, 1, 2, etc.)
echo - For each disk, volumes are numbered starting from 1
echo - Choose an NTFS volume for best results
echo.

:select_disk_vol_mft
set /p disk_num="Enter disk number (from Id column above): "
if "%disk_num%"=="" goto mft_analysis

echo.
echo Showing detailed info for disk %disk_num%:
"%NTFSTOOL_EXE%" info disk=%disk_num%
echo.

set /p volume_num="Enter volume number (1, 2, 3, etc.): "
if "%volume_num%"=="" goto select_disk_vol_mft

echo.
echo Selected: Disk %disk_num%, Volume %volume_num%
echo Showing volume details:
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num%
echo.
set /p confirm="Is this the correct volume? (y/n): "
if /i not "%confirm%"=="y" goto select_disk_vol_mft

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set MFT_DIR=%OUTPUT_DIR%\mft_analysis_%TIMESTAMP%
mkdir "%MFT_DIR%"

echo.
echo Analyzing NTFS Master File Table using ntfstool...
echo Disk: %disk_num%, Volume: %volume_num%
echo Output directory: %MFT_DIR%
echo.

echo Select MFT dump format:
echo 1. CSV format (spreadsheet compatible)
echo 2. JSON format (structured data)
echo 3. Raw binary format
echo.
set /p format_choice="Select format (1-3): "

if "%format_choice%"=="1" (
    set format=csv
    set output_file=%MFT_DIR%\mft_dump.csv
) else if "%format_choice%"=="2" (
    set format=json
    set output_file=%MFT_DIR%\mft_dump.json
) else if "%format_choice%"=="3" (
    set format=raw
    set output_file=%MFT_DIR%\mft_dump.raw
) else (
    echo Invalid choice. Using CSV format.
    set format=csv
    set output_file=%MFT_DIR%\mft_dump.csv
)

echo.
echo Dumping MFT in %format% format...
"%NTFSTOOL_EXE%" mft.dump disk=%disk_num% volume=%volume_num% format=%format% output="%output_file%"

echo.
echo Analyzing specific MFT record (Root directory - inode 5)...
"%NTFSTOOL_EXE%" mft.record disk=%disk_num% volume=%volume_num% inode=5 > "%MFT_DIR%\root_directory_record.txt"

echo.
echo Getting volume information...
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num% > "%MFT_DIR%\volume_info.txt"

echo.
echo MFT analysis completed: %MFT_DIR%
echo Generated files:
echo - %output_file% (MFT dump in %format% format)
echo - root_directory_record.txt (detailed root directory MFT record)
echo - volume_info.txt (volume information)
pause
goto menu

:streams_analysis
cls
echo NTFS Streams Analysis using ntfstool
echo ====================================
echo.

:: Check if ntfstool is available
if not exist "%NTFSTOOL_EXE%" (
    echo [ERROR] ntfstool.exe not found at: %NTFSTOOL_EXE%
    echo Please download ntfstool from: https://github.com/thewhiteninja/ntfstool
    echo and place it in the tools\windows directory.
    pause
    goto menu
)

echo Available disks and volumes:
echo ==========================================
"%NTFSTOOL_EXE%" info
echo.
echo NOTE: Look at the table above:
echo - "Id" column shows the disk number (0, 1, 2, etc.)
echo - For each disk, volumes are numbered starting from 1
echo - Choose an NTFS volume for best results
echo.

:select_disk_vol_streams
set /p disk_num="Enter disk number (from Id column above): "
if "%disk_num%"=="" goto streams_analysis

echo.
echo Showing detailed info for disk %disk_num%:
"%NTFSTOOL_EXE%" info disk=%disk_num%
echo.

set /p volume_num="Enter volume number (1, 2, 3, etc.): "
if "%volume_num%"=="" goto select_disk_vol_streams

echo.
echo Selected: Disk %disk_num%, Volume %volume_num%
echo Showing volume details:
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num%
echo.
set /p confirm="Is this the correct volume? (y/n): "
if /i not "%confirm%"=="y" goto select_disk_vol_streams

set /p file_path="Enter full path to file to analyze for streams: "
if "%file_path%"=="" goto streams_analysis

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set STREAMS_DIR=%OUTPUT_DIR%\streams_analysis_%TIMESTAMP%
mkdir "%STREAMS_DIR%"

echo.
echo Analyzing NTFS Alternate Data Streams using ntfstool...
echo Disk: %disk_num%, Volume: %volume_num%
echo File: %file_path%
echo Output: %STREAMS_DIR%
echo.

"%NTFSTOOL_EXE%" streams disk=%disk_num% volume=%volume_num% from="%file_path%" > "%STREAMS_DIR%\streams_report.txt"

echo.
echo Streams analysis completed: %STREAMS_DIR%
echo Generated files:
echo - streams_report.txt (alternate data streams information)
pause
goto menu

:undelete_files
cls
echo File Recovery using ntfstool
echo ============================
echo.

:: Check if ntfstool is available
if not exist "%NTFSTOOL_EXE%" (
    echo [ERROR] ntfstool.exe not found at: %NTFSTOOL_EXE%
    echo Please download ntfstool from: https://github.com/thewhiteninja/ntfstool
    echo and place it in the tools\windows directory.
    pause
    goto menu
)

echo Available disks and volumes:
echo ==========================================
"%NTFSTOOL_EXE%" info
echo.
echo NOTE: Look at the table above:
echo - "Id" column shows the disk number (0, 1, 2, etc.)
echo - For each disk, volumes are numbered starting from 1
echo - Choose an NTFS volume for best results
echo.

:select_disk_vol_undelete
set /p disk_num="Enter disk number (from Id column above): "
if "%disk_num%"=="" goto undelete_files

echo.
echo Showing detailed info for disk %disk_num%:
"%NTFSTOOL_EXE%" info disk=%disk_num%
echo.

set /p volume_num="Enter volume number (1, 2, 3, etc.): "
if "%volume_num%"=="" goto select_disk_vol_undelete

echo.
echo Selected: Disk %disk_num%, Volume %volume_num%
echo Showing volume details:
"%NTFSTOOL_EXE%" info disk=%disk_num% volume=%volume_num%
echo.
set /p confirm="Is this the correct volume? (y/n): "
if /i not "%confirm%"=="y" goto select_disk_vol_undelete

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set UNDELETE_DIR=%OUTPUT_DIR%\undelete_%TIMESTAMP%
mkdir "%UNDELETE_DIR%"

echo.
echo Select operation:
echo 1. List deleted files only
echo 2. List and recover specific file by inode
echo.
set /p operation="Select operation (1-2): "

if "%operation%"=="1" (
    echo.
    echo Searching for deleted files...
    "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num% format=csv output="%UNDELETE_DIR%\deleted_files.csv"
    echo.
    echo Deleted files list saved to: %UNDELETE_DIR%\deleted_files.csv
) else if "%operation%"=="2" (
    echo.
    echo First, listing deleted files...
    "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num%
    echo.
    set /p inode_num="Enter inode number of file to recover: "
    if not "!inode_num!"=="" (
        set /p output_name="Enter output filename: "
        if not "!output_name!"=="" (
            echo Recovering file...
            "%NTFSTOOL_EXE%" undelete disk=%disk_num% volume=%volume_num% inode=!inode_num! output="%UNDELETE_DIR%\!output_name!"
            echo File recovered to: %UNDELETE_DIR%\!output_name!
        )
    )
) else (
    echo Invalid choice.
)

echo.
echo Undelete operation completed: %UNDELETE_DIR%
pause
goto menu