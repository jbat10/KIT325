@echo off
setlocal enabledelayedexpansion

set TOOLKIT_ROOT=%~dp0..\..
set OUTPUT_DIR=%TOOLKIT_ROOT%\output

echo Comprehensive System Information Collection
echo ==========================================
echo.

set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set SYSINFO_DIR=%OUTPUT_DIR%\system_info_%TIMESTAMP%
mkdir "%SYSINFO_DIR%"

echo Collecting system information...
echo Output directory: %SYSINFO_DIR%
echo.

:: Basic system information
echo === BASIC SYSTEM INFO === > "%SYSINFO_DIR%\system_overview.txt"
systeminfo >> "%SYSINFO_DIR%\system_overview.txt"

:: Process list
echo Collecting process information...
tasklist /V > "%SYSINFO_DIR%\processes.txt"
echo Collecting detailed process information...
wmic process list full /format:csv > "%SYSINFO_DIR%\processes_detailed.csv" 2>nul
if %errorlevel% neq 0 (
    tasklist /SVC > "%SYSINFO_DIR%\processes_services.txt"
)

:: Network information
echo Collecting network information...
ipconfig /all > "%SYSINFO_DIR%\network_config.txt"
netstat -ano > "%SYSINFO_DIR%\network_connections.txt"
arp -a > "%SYSINFO_DIR%\arp_table.txt"

:: User accounts
echo Collecting user account information...
net user > "%SYSINFO_DIR%\user_accounts.txt"
echo Collecting detailed user account information...
wmic useraccount list full /format:csv > "%SYSINFO_DIR%\user_accounts_detailed.csv" 2>nul
if %errorlevel% neq 0 (
    net localgroup > "%SYSINFO_DIR%\local_groups.txt"
)

:: Services
echo Collecting service information...
sc query > "%SYSINFO_DIR%\services.txt"
net start > "%SYSINFO_DIR%\services_running.txt"
sc query type= service state= all > "%SYSINFO_DIR%\services_all.txt"

echo Collecting detailed service information...
wmic service get name,displayname,state,startmode,pathname /format:csv > "%SYSINFO_DIR%\services_detailed.csv" 2>nul
if %errorlevel% neq 0 (
    powershell -Command "Get-Service | Select-Object Name,DisplayName,Status,StartType | Export-Csv -Path '%SYSINFO_DIR%\services_powershell.csv' -NoTypeInformation" 2>nul
)

:: Installed software
echo Collecting installed software...
wmic product get name,version,vendor /format:csv > "%SYSINFO_DIR%\installed_software_wmi.csv" 2>nul

echo Collecting software from registry...
echo === INSTALLED SOFTWARE (from Registry) === > "%SYSINFO_DIR%\installed_software_registry.txt"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s >> "%SYSINFO_DIR%\installed_software_registry.txt" 2>nul

:: Hardware information
echo Collecting hardware information...
echo === HARDWARE OVERVIEW === > "%SYSINFO_DIR%\hardware_overview.txt"
echo Collection Date: %date% %time% >> "%SYSINFO_DIR%\hardware_overview.txt"
echo. >> "%SYSINFO_DIR%\hardware_overview.txt"

echo Computer System Information: >> "%SYSINFO_DIR%\hardware_overview.txt"
wmic computersystem get name,manufacturer,model,totalphysicalmemory >> "%SYSINFO_DIR%\hardware_overview.txt" 2>nul
echo. >> "%SYSINFO_DIR%\hardware_overview.txt"

echo Logical Disk Information: >> "%SYSINFO_DIR%\hardware_overview.txt"
wmic logicaldisk get caption,size,freespace,filesystem >> "%SYSINFO_DIR%\hardware_overview.txt" 2>nul
echo. >> "%SYSINFO_DIR%\hardware_overview.txt"

echo Collecting detailed disk information...
wmic diskdrive list full /format:csv > "%SYSINFO_DIR%\disk_drives.csv" 2>nul
if %errorlevel% neq 0 (
    echo list disk > "%TEMP%\diskpart_script.txt"
    diskpart /s "%TEMP%\diskpart_script.txt" > "%SYSINFO_DIR%\disk_info_diskpart.txt" 2>nul
    del "%TEMP%\diskpart_script.txt" 2>nul
)

:: Driver information with better formatting
echo Collecting driver information...
driverquery /fo table > "%SYSINFO_DIR%\drivers_table.txt" 2>nul
driverquery /v /fo csv > "%SYSINFO_DIR%\drivers_detailed.csv" 2>nul

:: Event log summary
echo Collecting event log summary...
echo === WINDOWS EVENT LOGS AVAILABLE === > "%SYSINFO_DIR%\event_logs_overview.txt"
echo This lists all available Windows Event Log channels on the system. >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo Key logs for forensic analysis: >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo - System: Hardware/driver issues, service start/stop >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo - Application: Application crashes, errors >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo - Security: Login attempts, privilege escalation >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo - Microsoft-Windows-PowerShell/Operational: PowerShell usage >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo. >> "%SYSINFO_DIR%\event_logs_overview.txt"
echo Complete list of available event logs: >> "%SYSINFO_DIR%\event_logs_overview.txt"
wevtutil el >> "%SYSINFO_DIR%\event_logs_overview.txt"

echo Collecting recent critical events...
wevtutil qe System /c:50 /rd:true /f:text > "%SYSINFO_DIR%\recent_system_events.txt" 2>nul
wevtutil qe Application /c:50 /rd:true /f:text > "%SYSINFO_DIR%\recent_application_events.txt" 2>nul

:: Environment variables
echo Collecting environment variables...
set > "%SYSINFO_DIR%\environment_variables.txt"

:: Scheduled tasks
echo Collecting scheduled tasks...
schtasks /query /fo csv /v > "%SYSINFO_DIR%\scheduled_tasks_detailed.csv" 2>nul
if %errorlevel% neq 0 (
    echo Warning: Scheduled tasks detailed query failed, using basic query...
) else (
    echo Detailed scheduled tasks query completed successfully
)

echo Collecting basic scheduled tasks list...
schtasks /query > "%SYSINFO_DIR%\scheduled_tasks_basic.txt" 2>nul

:: Startup programs
echo Collecting startup programs...
wmic startup list full /format:csv > "%SYSINFO_DIR%\startup_programs_wmi.csv" 2>nul

echo Collecting startup programs from registry...
echo === STARTUP PROGRAMS (from Registry) === > "%SYSINFO_DIR%\startup_programs_registry.txt"
echo HKLM Run Keys: >> "%SYSINFO_DIR%\startup_programs_registry.txt"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> "%SYSINFO_DIR%\startup_programs_registry.txt" 2>nul
echo. >> "%SYSINFO_DIR%\startup_programs_registry.txt"
echo HKCU Run Keys: >> "%SYSINFO_DIR%\startup_programs_registry.txt"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" >> "%SYSINFO_DIR%\startup_programs_registry.txt" 2>nul

:: Create comprehensive summary report
set SUMMARY_FILE=%SYSINFO_DIR%\collection_summary.txt
echo Comprehensive System Information Collection Summary > "%SUMMARY_FILE%"
echo ================================================== >> "%SUMMARY_FILE%"
echo Collection Date: %date% %time% >> "%SUMMARY_FILE%"
echo Output Directory: %SYSINFO_DIR% >> "%SUMMARY_FILE%"
echo Collection Mode: Comprehensive (WMIC + Registry + Native Commands) >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo Data Sources Used: >> "%SUMMARY_FILE%"
echo - Windows Management Instrumentation (WMIC) >> "%SUMMARY_FILE%"
echo - Registry queries >> "%SUMMARY_FILE%"
echo - Native Windows commands (systeminfo, tasklist, etc.) >> "%SUMMARY_FILE%"
echo - Service control commands (sc, net) >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo Files Created: >> "%SUMMARY_FILE%"
dir "%SYSINFO_DIR%" /B >> "%SUMMARY_FILE%"
echo. >> "%SUMMARY_FILE%"
echo Note: If WMIC commands failed, alternative data sources were used >> "%SUMMARY_FILE%"

echo.
echo Comprehensive system information collection completed!
echo Results saved to: %SYSINFO_DIR%
echo.
pause
cls