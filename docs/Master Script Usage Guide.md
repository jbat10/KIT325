# Master Script Usage Guide

The KIT325 Forensics Toolkit includes master scripts that provide a unified menu interface for accessing all forensic tools. These scripts simplify the workflow by eliminating the need to navigate directories or remember command syntax.

## Overview

**Files:**
- `windows.bat` - Windows master script
- `linux.sh` - Linux master script  

**Location:** Root directory of the toolkit

**Output:** All tool outputs are saved to the `output/` directory with timestamped folders

## Windows Guide

### Prerequisites
- Administrator privileges recommended (some tools require it)
- Windows 7 or later

### Running the Script

1. Open Command Prompt as Administrator
2. Navigate to the toolkit directory
3. Run: `windows.bat`

### Features

The Windows master script provides access to five forensic tool categories:

**1. File Carving (PhotoRec)**
- Recovers deleted files from storage media
- Supports multiple file types
- Interactive interface guides through device selection

**2. File Acquisition (ntfstools)**
- Extract specific files by path or inode
- Dump Master File Table (MFT) for analysis
- Analyse NTFS alternate data streams
- Recover deleted files (undelete)
- Browse volumes using interactive shell

**3. Registry Analysis (RECmd)**
- Extract and analyse Windows Registry hives
- Batch processing for common forensic queries
- Export to CSV/JSON formats

**4. Memory Analysis (WinPmem)**
- Capture live system memory
- Creates memory dumps for forensic analysis
- Requires Administrator privileges

**5. System Information Collection**
- Comprehensive system snapshot including:
  - Process lists and detailed information
  - Network configuration and connections
  - User accounts and groups
  - Running services
  - Installed software
  - Hardware configuration
  - Event logs (recent entries)
  - Scheduled tasks
  - Startup programs
  - Driver information

### Usage Tips

**Administrator Mode:**
The script detects privilege level and displays warnings if not running as Administrator. Some operations (memory capture, physical disk access) will fail without elevated privileges.

**Navigation:**
After each tool completes, you'll return to the main menu. Use Ctrl+C to exit at any time.

**Output Organisation:**
All outputs are saved to timestamped directories in `output/` for easy organisation and evidence tracking.

## Linux Guide

### Prerequisites
- Root/sudo access recommended (some tools require it)
- Bash shell
- Linux kernel 2.6+ (for most features)

### Running the Script


`sudo bash linux.sh`

`sudo ./linux.bat`

### Features

The Linux master script provides access to four forensic tool categories:

**1. File Carving (PhotoRec)**
- Recovers deleted files from storage media
- Deep scan for file signatures
- Supports ext2/3/4, NTFS, FAT filesystems

**2. File Acquisition (dd)**
- Create bit-for-bit disk/partition images
- Individual file/directory extraction with metadata
- Filesystem analysis and enumeration
- Automatic hash generation (MD5/SHA256)
- Progress monitoring during imaging

**3. Memory Analysis (AVML)**
- Capture live system memory
- Creates memory dumps in standard formats
- Requires root privileges

**4. System Information Collection**
- Comprehensive system snapshot including:
  - Hardware information (CPU, memory, devices)
  - Process lists with full details
  - Network configuration and connections
  - User accounts and login history
  - Systemd services and status
  - Filesystem and disk usage
  - Installed packages (dpkg/rpm/pacman)
  - Cron jobs and scheduled tasks
  - Recent system logs
  - Kernel modules and version
  - Security status (SELinux/AppArmor)

### Usage Tips

**Root vs Limited Mode:**
The script detects if running as root and displays appropriate warnings. Running without root will limit functionality, particularly for memory capture and physical disk access.

**File Preservation:**
File extraction uses rsync to preserve timestamps, permissions, and metadata for forensic integrity.

**Hash Verification:**
Disk images automatically generate MD5 and SHA256 hashes for integrity verification.

**Navigation:**
After each tool completes, press Enter to return to the main menu.

## Best Practices

1. **Always run as Administrator/root** when possible for full functionality
2. **Verify available disk space** before imaging large drives
3. **Document your actions** - note what tools you ran and why
4. **Check output directory** after each operation to verify success
5. **Keep original evidence intact** - work on copies when possible