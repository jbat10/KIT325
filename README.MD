# KIT325 Portable Forensics Toolkit

A lightweight, portable forensics toolkit designed for USB storage devices, focused on evidence acquisition and triage capabilities for both Windows and Linux systems.

## Quick Start

Run the master script for your platform:
- **Windows:** `windows.bat` (run as Administrator)
- **Linux:** `sudo bash linux.sh`

[📖 Master Script Usage Guide](docs/Master%20Script%20Usage%20Guide.md)

## Documentation

- [Master Script Usage Guide](docs/Master%20Script%20Usage%20Guide.md) - Complete guide for using the menu interface
- [Tool Index](docs/tool_index.md) - Download links and installation instructions for all tools
- [AVML Usage Guide](docs/AVML%20Usage%20Guide.md) - Linux memory acquisition
- [WinPmem Usage Guide](docs/WinPmem%20Usage%20Guide.md) - Windows memory acquisition
- [Photorec Usage Guide](docs/Photorec%20Usage%20Guide.md) - File carving and recovery
- [Final Toolkit Report](docs/Final%20Toolkit%20Report.md) - Complete project documentation

## Tools Included

- **File Carving:** PhotoRec (Windows & Linux)
- **File Acquisition:** ntfstool (Windows), dd (Linux)
- **Memory Analysis:** WinPmem (Windows), AVML (Linux)
- **Registry Analysis:** RECmd (Windows)
- **System Information:** Comprehensive collection scripts (Windows & Linux)