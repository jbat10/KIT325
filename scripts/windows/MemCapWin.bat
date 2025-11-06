@echo off
set TOOLKIT_ROOT=%~dp0..\..
set OUTPUT_DIR=%TOOLKIT_ROOT%\output\WinPmem
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
set TIMESTAMP=%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
"%TOOLKIT_ROOT%\tools\windows\winpmem.exe" "%OUTPUT_DIR%\memory_dump_%TIMESTAMP%.raw"
cls