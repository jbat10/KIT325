@echo off
:: needed to hook dotnet install to RECmd.dll
set DOTNET_PATH=%~dp0..\dotnet\dotnet.exe
set RECMD_PATH=%~dp0RECmd.dll

"%DOTNET_PATH%" "%RECMD_PATH%" %*