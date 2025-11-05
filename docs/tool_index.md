# Tool Index

Record of included tools and dependencies.


## Live Partition

### AVML - Acquire Volatile Memory Linux
**Version:** v0.14.0  
**Download:** https://github.com/microsoft/avml/releases  
**Install Path:** `tools/linux/avml` (executable file)

### WinPmem
**Version:** Release 4.0 RC2  
**Download:** https://github.com/Velocidex/WinPmem/releases  
**Install Path:** `tools/windows/winpmem.exe` (rename executable to winpmem.exe)

### PhotoRec 
**Version:** v7.2  
**Documentation:** https://www.cgsecurity.org/wiki/PhotoRec  
**Download:** https://www.cgsecurity.org/wiki/TestDisk_Download  
**Install Paths:**
- Linux: Extract to `tools/linux/testdisk/` (keep folder structure)
- Windows: Extract to `tools/windows/testdisk_win/` (keep folder structure)

### ntfstool (Windows File Acquisition)
**Version:** Latest  
**Download:** https://github.com/thewhiteninja/ntfstool/releases  
**Install Paths:**
- `tools/windows/ntfstool.x64.exe` (64-bit version)
- `tools/windows/ntfstool.x86.exe` (32-bit version)

### RECmd (Registry Analysis)
**Version:** 2.1.0  
**Download:** https://ericzimmerman.github.io/#!index.md  
**Documentation:** https://github.com/EricZimmerman/RECmd  
**Install Path:** Extract entire folder to `tools/windows/RECmd/` (must include BatchExamples and Plugins subdirectories)

### .NET Runtime (Required for RECmd on Windows)
**Version:** 9.0.10 
**Download:** https://dotnet.microsoft.com/en-us/download/dotnet/9.0 (Download the Windows **Binaries**, not the installer.)
**Install Path:** `tools/windows/dotnet/` (extract runtime files here)  

## Bootable Partition

### Guymager (Offline Full-Disk Imaging)
**Version:** 0.8.13
**Download:** https://packages.debian.org/stable/guymager
**Documentation:** https://guymager.sourceforge.io/
**Install Path:** /usr/bin/guymager (preinstalled, managed by package manager)

### Autopsy (Offline Analysis and Extraction)
**Version:** 4.22.1
**Download:** https://github.com/sleuthkit/autopsy/releases
**Documentation:** https://sleuthkit.org/autopsy/docs/user-docs/4.22.0//
**Install Path:** /home/investigator/Autopsy (preinstalled)

### Sleuth Kit (Required by Autopsy)
**Version:** 4.14.0
**Download:** https://github.com/sleuthkit/sleuthkit/releases
**Documentation:** https://sleuthkit.org/sleuthkit/docs/
**Install Path:**  (preinstalled)

### Temurin JDK (Required by Autopsy)
**Version:** 17.0.17
**Download:** https://adoptium.net/temurin/releases/
**Documentation:** https://adoptium.net/installation
**Install Path:** /opt/java17 (preinstalled)

### Other Packages Installed from Debian Repositories
- testdisk
- git
- unzip
- exfatprogs