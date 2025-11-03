# Tool Index

Installation guide for forensic tools. Download each tool and place in the specified directory within the toolkit.

### AVML - Acquire Volatile Memory Linux
**Download:** https://github.com/microsoft/avml/releases  
**Install Path:** `tools/linux/avml` (executable file)

### WinPmem
**Download:** https://github.com/Velocidex/WinPmem/releases  
**Install Path:** `tools/windows/winpmem.exe` (rename executable to winpmem.exe)

### PhotoRec 
**Documentation:** https://www.cgsecurity.org/wiki/PhotoRec  
**Download:** https://www.cgsecurity.org/wiki/TestDisk_Download  
**Install Paths:**
- Linux: Extract to `tools/linux/testdisk/` (keep folder structure)
- Windows: Extract to `tools/windows/testdisk_win/` (keep folder structure)

### ntfstool (Windows File Acquisition)
**Download:** https://github.com/thewhiteninja/ntfstool/releases  
**Install Paths:**
- `tools/windows/ntfstool.x64.exe` (64-bit version)
- `tools/windows/ntfstool.x86.exe` (32-bit version)

### RECmd (Registry Analysis)
**Download:** https://ericzimmerman.github.io/#!index.md  
**Documentation:** https://github.com/EricZimmerman/RECmd  
**Install Path:** Extract entire folder to `tools/windows/RECmd/` (must include BatchExamples and Plugins subdirectories)

### .NET Runtime (Required for RECmd on Windows)
**Download:** https://dotnet.microsoft.com/en-us/download/dotnet/9.0 (Download the Windows **Binaries**, not the installer.)
**Install Path:** `tools/windows/dotnet/` (extract runtime files here)  

### Guymager (Offline Full-Disk Imaging)
**Download:** https://packages.debian.org/stable/guymager
**Documentation:** https://guymager.sourceforge.io/
**Install Path:** /usr/bin/guymager (preinstalled, managed by package manager)

### Autopsy (Offline Analysis and Extraction)
**Download:** https://github.com/sleuthkit/autopsy/releases
**Documentation:** https://sleuthkit.org/autopsy/docs/user-docs/4.22.0//
**Install Path:** /home/investigator/Autopsy (preinstalled)