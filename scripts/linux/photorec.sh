#!/bin/bash

# PhotoRec File Carving Wrapper
# Recovers deleted or obfuscated files

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="$TOOLKIT_ROOT/tools"
OUTPUT_DIR="$TOOLKIT_ROOT/output"

# Create output directory with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_DIR="$OUTPUT_DIR/photorec_$TIMESTAMP"
mkdir -p "$SESSION_DIR" 2>/dev/null

# Check for root privileges and request if needed
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges to access hard disks."
    echo "Please run as administrator or the script will attempt to elevate..."
    echo
    sudo "$0" "$@"
    exit $?
fi

# Launch PhotoRec with output directory and log file specified
"$TOOLS_DIR/linux/testdisk/photorec_static" /log /logname "$SESSION_DIR/photorec.log" /d "$SESSION_DIR"
clear
echo "PhotoRec has been closed."
echo "Results saved to: $SESSION_DIR"
read -p "Press any key to continue..."
exit 0