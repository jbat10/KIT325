# Tool Index

In the case where the documentation and download of the tool are in the same location, only one link is provided.

### AVML - Acquire Volatile Memory Linux
Version Used: v0.14.0
Link to github directory: https://github.com/microsoft/avml
> #### Install instructions
> Place avml executable in tools/linux

### WinPmem
Version Used: Release 4.0 RC2
Link to github directory: https://github.com/Velocidex/WinPmem
> #### Install instructions
> Rename the winpmem executable to winpmem.exe and place it in tools/windows

### Photorec 
Version Used: v7.2
Link to documentation: https://www.cgsecurity.org/wiki/PhotoRec 
Link to download: https://www.cgsecurity.org/wiki/TestDisk_Download 
> #### Install instructions
> Linux: Place testdisk folder in tools/linux/testdisk
> Windows: Place testdisk_win folder in tools/windows/testdisk_win

### RECmd
Version Used: 2.1.0
Link to documentation: https://github.com/EricZimmerman/RECmd
Link to download: https://ericzimmerman.github.io/#!index.md
> #### Install instructions
> Place RECmd folder in tools/windows/RECmd

### .NET Core SDK (Required for RECmd)
Version Used: 9.0.10
Link to documentation and download: https://dotnet.microsoft.com/en-us/download/dotnet/9.0
> #### Install instructions
> Powershell command to install: `iex "& { $(irm https://dot.net/v1/dotnet-install.ps1) }"`
> Bash command to install: `bash <(curl -sSL https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh)`