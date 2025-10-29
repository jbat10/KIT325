#!/bin/bash

# Memory Analysis Tool for Linux
# Memory acquisition using AVML and basic analysis

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="$TOOLKIT_ROOT/tools"
OUTPUT_DIR="$TOOLKIT_ROOT/output"

echo "Memory Analysis Tool"
echo "==================="
echo

echo "Select memory analysis option:"
echo
echo "1. Memory Acquisition (AVML)"
echo "2. Live Memory Analysis"
echo "3. Process Memory Dump"
echo "4. Return to main menu"
echo
read -p "Select option (1-4): " mem_choice

case $mem_choice in
    1) memory_acquisition ;;
    2) live_analysis ;;
    3) process_dump ;;
    4) return 0 ;;
    *) echo "Invalid choice."; return 1 ;;
esac

memory_acquisition() {
    clear
    echo "Memory Acquisition (AVML)"
    echo "========================"
    echo
    
    # Check for AVML
    if [ ! -x "$TOOLS_DIR/avml" ] && ! command -v avml &> /dev/null; then
        echo "[ERROR] AVML not found."
        echo "Please place the AVML binary in $TOOLS_DIR/ or install it system-wide."
        echo "AVML can be downloaded from: https://github.com/microsoft/avml"
        read -p "Press Enter to continue..."
        return 1
    fi
    
    # Determine AVML command
    if [ -x "$TOOLS_DIR/avml" ]; then
        AVML_CMD="$TOOLS_DIR/avml"
    else
        AVML_CMD="avml"
    fi
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    MEMORY_FILE="$OUTPUT_DIR/memory_dump_$TIMESTAMP.lime"
    
    echo "Starting memory acquisition..."
    echo "Output file: $MEMORY_FILE"
    echo
    echo "This process may take several minutes depending on system memory size."
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    # Run AVML
    $AVML_CMD "$MEMORY_FILE"
    
    if [ $? -eq 0 ]; then
        echo
        echo "Memory acquisition completed successfully!"
        echo "Memory dump: $MEMORY_FILE"
        
        # Calculate hash
        echo "Calculating hash for verification..."
        sha256sum "$MEMORY_FILE" > "$MEMORY_FILE.sha256"
        
        # Get file size
        file_size=$(stat -c%s "$MEMORY_FILE")
        echo "File size: $(numfmt --to=iec $file_size)"
        echo "Hash file: $MEMORY_FILE.sha256"
    else
        echo "[ERROR] Memory acquisition failed!"
    fi
    
    read -p "Press Enter to continue..."
}

live_analysis() {
    clear
    echo "Live Memory Analysis"
    echo "==================="
    echo
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    ANALYSIS_DIR="$OUTPUT_DIR/memory_analysis_$TIMESTAMP"
    mkdir -p "$ANALYSIS_DIR"
    
    echo "Performing live memory analysis..."
    echo "Output directory: $ANALYSIS_DIR"
    echo
    
    # Memory information
    echo "Collecting memory information..."
    cat /proc/meminfo > "$ANALYSIS_DIR/meminfo.txt"
    
    # Virtual memory statistics
    vmstat > "$ANALYSIS_DIR/vmstat.txt"
    
    # Memory maps of all processes
    echo "Collecting process memory maps..."
    for pid in /proc/[0-9]*; do
        if [ -r "$pid/maps" ]; then
            pid_num=$(basename "$pid")
            cp "$pid/maps" "$ANALYSIS_DIR/maps_$pid_num.txt" 2>/dev/null
        fi
    done
    
    # Process status information
    echo "Collecting process status..."
    for pid in /proc/[0-9]*; do
        if [ -r "$pid/status" ]; then
            pid_num=$(basename "$pid")
            cp "$pid/status" "$ANALYSIS_DIR/status_$pid_num.txt" 2>/dev/null
        fi
    done
    
    # Kernel information
    echo "Collecting kernel information..."
    cat /proc/version > "$ANALYSIS_DIR/kernel_version.txt"
    cat /proc/modules > "$ANALYSIS_DIR/loaded_modules.txt"
    
    # System call information
    if [ -r /proc/kallsyms ]; then
        cp /proc/kallsyms "$ANALYSIS_DIR/kallsyms.txt"
    fi
    
    # Process tree
    pstree -p > "$ANALYSIS_DIR/process_tree.txt" 2>/dev/null
    
    echo "Live memory analysis completed: $ANALYSIS_DIR"
    read -p "Press Enter to continue..."
}

process_dump() {
    clear
    echo "Process Memory Dump"
    echo "=================="
    echo
    
    echo "Running processes:"
    ps aux | head -20
    echo
    
    read -p "Enter PID of process to dump: " target_pid
    if [ -z "$target_pid" ]; then
        echo "No PID specified."
        read -p "Press Enter to continue..."
        return 1
    fi
    
    if [ ! -d "/proc/$target_pid" ]; then
        echo "[ERROR] Process $target_pid not found."
        read -p "Press Enter to continue..."
        return 1
    fi
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    DUMP_DIR="$OUTPUT_DIR/process_dump_${target_pid}_$TIMESTAMP"
    mkdir -p "$DUMP_DIR"
    
    echo
    echo "Dumping process $target_pid memory..."
    echo "Output directory: $DUMP_DIR"
    echo
    
    # Process information
    cp "/proc/$target_pid/status" "$DUMP_DIR/process_status.txt" 2>/dev/null
    cp "/proc/$target_pid/maps" "$DUMP_DIR/process_maps.txt" 2>/dev/null
    cp "/proc/$target_pid/environ" "$DUMP_DIR/process_environ.txt" 2>/dev/null
    cp "/proc/$target_pid/cmdline" "$DUMP_DIR/process_cmdline.txt" 2>/dev/null
    
    # Memory dump using gcore if available
    if command -v gcore &> /dev/null; then
        echo "Using gcore to dump process memory..."
        cd "$DUMP_DIR"
        gcore "$target_pid"
        cd - > /dev/null
    else
        echo "[INFO] gcore not available. Collecting available process information..."
        
        # Copy memory maps and other proc files
        if [ -r "/proc/$target_pid/mem" ]; then
            echo "Process memory file is accessible but requires special tools to extract."
            echo "Consider using gdb or specialized tools for full memory dump."
        fi
    fi
    
    # Open files
    if command -v lsof &> /dev/null; then
        lsof -p "$target_pid" > "$DUMP_DIR/open_files.txt" 2>/dev/null
    fi
    
    echo "Process dump completed: $DUMP_DIR"
    read -p "Press Enter to continue..."
}