#!/bin/bash

# File Acquisition Tool for Linux - dd and filesystem tools wrapper
# Individual file extraction with metadata preservation

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="$TOOLKIT_ROOT/tools"
OUTPUT_DIR="$TOOLKIT_ROOT/output"

show_menu() {
    echo "Select acquisition method:"
    echo
    echo "1. Disk/Partition Image (dd)"
    echo "2. Individual File/Directory Copy"
    echo "3. Filesystem Analysis"
    echo "4. Return to main menu"
    echo
    read -p "Select option (1-4): " acq_choice
    
    case $acq_choice in
        1) disk_image; show_menu ;;
        2) file_extraction; show_menu ;;
        3) filesystem_analysis; show_menu ;;
        4) clear; exit 0 ;;
        *) echo "Invalid choice. Please try again."; echo; show_menu ;;
    esac
}

disk_image() {
    clear
    echo "Disk/Partition Imaging"
    echo "======================"
    echo
    
    # List available block devices
    echo "Available block devices:"
    lsblk -f
    echo
    fdisk -l 2>/dev/null | grep "Disk /"
    echo
    
    read -p "Enter source device (e.g., /dev/sda): " source_device
    if [ -z "$source_device" ]; then
        show_menu
        return
    fi
    
    if [ ! -b "$source_device" ]; then
        echo "[ERROR] Device $source_device not found or not a block device."
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    # Create timestamp for output
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    IMAGE_FILE="$OUTPUT_DIR/disk_image_$TIMESTAMP.dd"
    
    echo
    echo "Creating disk image..."
    echo "Source: $source_device"
    echo "Output: $IMAGE_FILE"
    echo
    
    # Get device size
    device_size=$(blockdev --getsize64 "$source_device" 2>/dev/null)
    if [ -n "$device_size" ]; then
        echo "Device size: $(numfmt --to=iec $device_size)"
    fi
    
    echo "This may take a significant amount of time depending on device size."
    echo
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    # Create imaging log
    LOG_FILE="$OUTPUT_DIR/imaging_log_$TIMESTAMP.txt"
    echo "Disk Imaging Log" > "$LOG_FILE"
    echo "================" >> "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Source: $source_device" >> "$LOG_FILE"
    echo "Output: $IMAGE_FILE" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    
    # Run dd with progress monitoring
    echo "Starting disk imaging (with progress monitoring)..."
    dd if="$source_device" of="$IMAGE_FILE" bs=4M status=progress 2>> "$LOG_FILE"
    
    # Calculate hash
    echo
    echo "Calculating MD5 hash for verification..."
    md5sum "$IMAGE_FILE" > "$IMAGE_FILE.md5"
    
    echo "Calculating SHA256 hash for verification..."
    sha256sum "$IMAGE_FILE" > "$IMAGE_FILE.sha256"
    
    echo
    echo "Disk imaging completed!"
    echo "Image file: $IMAGE_FILE"
    echo "Log file: $LOG_FILE"
    echo "Hashes: $IMAGE_FILE.md5, $IMAGE_FILE.sha256"
    
    read -p "Press Enter to continue..."
}

file_extraction() {
    clear
    echo "Individual File/Directory Extraction"
    echo "==================================="
    echo
    
    read -p "Enter source path (file or directory): " source_path
    if [ -z "$source_path" ]; then
        show_menu
        return
    fi
    
    if [ ! -e "$source_path" ]; then
        echo "[ERROR] Path $source_path not found."
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    EXTRACT_DIR="$OUTPUT_DIR/extraction_$TIMESTAMP"
    mkdir -p "$EXTRACT_DIR"
    
    echo
    echo "Extracting file(s) with metadata preservation..."
    echo "Source: $source_path"
    echo "Destination: $EXTRACT_DIR"
    echo
    
    # Use rsync to preserve metadata and timestamps
    rsync -avH --numeric-ids "$source_path" "$EXTRACT_DIR/"
    
    # Create metadata report
    echo "Generating metadata report..."
    METADATA_FILE="$EXTRACT_DIR/metadata_report.txt"
    echo "File Extraction Report" > "$METADATA_FILE"
    echo "======================" >> "$METADATA_FILE"
    echo "Date: $(date)" >> "$METADATA_FILE"
    echo "Source: $source_path" >> "$METADATA_FILE"
    echo "Destination: $EXTRACT_DIR" >> "$METADATA_FILE"
    echo >> "$METADATA_FILE"
    
    # Detailed file listing with metadata
    echo "Detailed file listing:" >> "$METADATA_FILE"
    find "$EXTRACT_DIR" -ls >> "$METADATA_FILE"
    
    # File hashes
    echo >> "$METADATA_FILE"
    echo "File hashes (MD5):" >> "$METADATA_FILE"
    find "$EXTRACT_DIR" -type f -exec md5sum {} \; >> "$METADATA_FILE"
    
    echo "Extraction completed: $EXTRACT_DIR"
    read -p "Press Enter to continue..."
}

filesystem_analysis() {
    clear
    echo "Filesystem Analysis"
    echo "==================="
    echo
    
    echo "Available filesystems:"
    df -h
    echo
    mount | column -t
    echo
    
    read -p "Enter filesystem/device to analyse (e.g., /dev/sda1): " fs_device
    if [ -z "$fs_device" ]; then
        show_menu
        return
    fi
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FS_DIR="$OUTPUT_DIR/filesystem_analysis_$TIMESTAMP"
    mkdir -p "$FS_DIR"
    
    echo
    echo "Analysing filesystem: $fs_device"
    echo "Output directory: $FS_DIR"
    echo
    
    # Basic filesystem information
    echo "Collecting filesystem information..."
    
    # Filesystem type and features
    file -s "$fs_device" > "$FS_DIR/filesystem_type.txt" 2>/dev/null
    
    # Filesystem statistics
    if command -v tune2fs &> /dev/null; then
        tune2fs -l "$fs_device" > "$FS_DIR/ext_filesystem_info.txt" 2>/dev/null
    fi
    
    # Disk usage and structure
    if [ -d "$(findmnt -n -o TARGET "$fs_device" 2>/dev/null)" ]; then
        mount_point=$(findmnt -n -o TARGET "$fs_device")
        echo "Filesystem is mounted at: $mount_point"
        
        # Directory structure
        find "$mount_point" -maxdepth 3 -type d > "$FS_DIR/directory_structure.txt" 2>/dev/null
        
        # File count by type
        find "$mount_point" -type f | sed 's/.*\.//' | sort | uniq -c | sort -nr > "$FS_DIR/file_types.txt" 2>/dev/null
        
        # Large files
        find "$mount_point" -type f -size +100M -ls > "$FS_DIR/large_files.txt" 2>/dev/null
        
        # Recent files
        find "$mount_point" -type f -mtime -7 -ls > "$FS_DIR/recent_files.txt" 2>/dev/null
    else
        echo "Filesystem not mounted. Limited analysis available."
    fi
    
    # Block device information
    if command -v blockdev &> /dev/null; then
        blockdev --report "$fs_device" > "$FS_DIR/block_device_info.txt" 2>/dev/null
    fi
    
    # Create analysis summary
    SUMMARY_FILE="$FS_DIR/analysis_summary.txt"
    echo "Filesystem Analysis Summary" > "$SUMMARY_FILE"
    echo "===========================" >> "$SUMMARY_FILE"
    echo "Date: $(date)" >> "$SUMMARY_FILE"
    echo "Device: $fs_device" >> "$SUMMARY_FILE"
    echo "Output Directory: $FS_DIR" >> "$SUMMARY_FILE"
    echo >> "$SUMMARY_FILE"
    echo "Files created:" >> "$SUMMARY_FILE"
    ls -la "$FS_DIR" >> "$SUMMARY_FILE"
    
    echo "Filesystem analysis completed: $FS_DIR"
    read -p "Press Enter to continue..."
}

# Main entry point
show_menu