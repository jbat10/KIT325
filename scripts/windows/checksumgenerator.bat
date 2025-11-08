@echo off
setlocal enabledelayedexpansion

pushd "%~dp0..\..\output"
if errorlevel 1 (
    echo Failed to change to output directory
    exit /b 1
)

for /R "%CD%" %%F in (*) do (
    set "filepath=%%F"
    set "outputdir=%CD%"
    if "!filepath:%outputdir%=!" neq "!filepath!" (
        if /i not "%%~xF"==".sha256" (
            certutil -hashfile "%%F" SHA256 | findstr /v "certutil:" | findstr /v "sha256 hash of" > "%%F.sha256"
            (for /f "usebackq delims=" %%A in ("%%F.sha256") do (
                echo %%A %%~nxF
            )) > "%%F.temp"
            move /y "%%F.temp" "%%F.sha256" > nul
        )
    )
)

popd