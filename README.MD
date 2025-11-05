# KIT325 Portable Forensics Toolkit

A lightweight, portable forensics toolkit designed for USB storage devices, focused on evidence acquisition and triage capabilities for both Windows and Linux systems.

## Installation
To perform a full install, flash the toolkit disk image to a USB drive, boot into the newly flashed USB drive, open a terminal and run `./installer.sh` . This will install the rest of the toolkit into the remaining space on the USB drive. A USB 3.0 drive with 32GB of storage or better is required for full functionality.

To perform a partial install, format a USB flash drive to ExFAT and clone this repository into it. Add a ' .' to the end of the clone command to ensure the toolkit is loaded into the topmost directory. Under Linux, run `./downloader.sh` to automatically download tools; Under Windows or MacOS, read downloader.sh and recreate its commands with your platform's tools to the best of your ability. Attempting to install the toolkit on a FAT32 drive instead of an ExFAT drive will cause problems. A USB 2.0 Drive with 8GB of storage is required, more is recommended.

## Quick Start

Run the master script for your platform:
- **Windows:** `windows.bat` (run as Administrator)
- **Linux:** `sudo bash linux.sh`

[📖 Master Script Usage Guide](docs/Master%20Script%20Usage%20Guide.md)

## Documentation

- [Master Script Usage Guide](docs/Master%20Script%20Usage%20Guide.md) - Complete guide for using the menu interface
- [Tool Index](docs/tool_index.md) - Download links and installation instructions for all tools
- [AVML Usage Guide](docs/AVML%20Usage%20Guide.md) - Linux Memory Acquisition
- [WinPmem Usage Guide](docs/WinPmem%20Usage%20Guide.md) - Windows Memory Acquisition
- [Photorec Usage Guide](docs/Photorec%20Usage%20Guide.md) - File Carving and Recovery
- [Autopsy Usage Guide](docs/Autopsy%20Usage%20Guide.md) - Offline Analysis and File Acquisition
- [Guymager Usage Guide](docs/Guymager%20Usage%20Guide.md) - Offline Disk Imaging
- [Final Toolkit Report](docs/Final%20Toolkit%20Report.md) - Complete Project Documentation

## Tools Included

- **File Carving:** PhotoRec (Windows & Linux)
- **File Acquisition:** ntfstool (Windows), dd (Linux)
- **Memory Analysis:** WinPmem (Windows), AVML (Linux)
- **Registry Analysis:** RECmd (Windows)
- **System Information:** Comprehensive collection scripts (Windows & Linux)
- **Offline Disk Imaging:** Guymager (Bootable)
- **Offline General Forensics:** Autopsy (Bootable)