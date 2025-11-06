#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    clear
    echo "========================================="
    echo "  KIT325 Forensics Toolkit - Linux"
    echo "  Quick Access Menu"
    echo "========================================="
    echo
    echo "[WARNING] Not running as root!"
    echo
    echo "Some operations may fail or have limited functionality:"
    echo "- Physical disk imaging may be restricted"
    echo "- Memory acquisition unavailable"
    echo "- System file access may be limited"
    echo
    echo "For full functionality, run as root with:"
    echo "sudo bash linux.sh"
    echo
    echo "Press Enter to continue with limited mode..."
    read -r
    LIMITED_MODE=true
else
    clear
    echo "========================================="
    echo "  KIT325 Forensics Toolkit - Linux"
    echo "  Quick Access Menu"
    echo "========================================="
    echo
    echo
    LIMITED_MODE=false
fi

show_main_menu() {
    if [ "$LIMITED_MODE" = true ]; then
        echo "Available Forensic Tools:"
        echo
        echo "1. File Carving (PhotoRec)"
        echo "2. File Acquisition (dd)"
        echo "3. Memory Analysis (AVML)"
        echo "4. System Information Collection"
        echo "5. Exit"
        echo
        echo "[NOTE] Some tools may have reduced functionality without root"
    else
        echo "Available Forensic Tools:"
        echo
        echo "1. File Carving (PhotoRec)"
        echo "2. File Acquisition (dd)"
        echo "3. Memory Analysis (AVML)"
        echo "4. System Information Collection"
        echo "5. Exit"
        echo
    fi
    
    read -p "Select tool (1-5): " choice
    
    case $choice in
        1) photorec_menu ;;
        2) file_acquisition_menu ;;
        3) memory_analysis_menu ;;
        4) system_info_menu ;;
        5) exit_toolkit ;;
        *) echo "Invalid choice. Please try again."; echo; show_main_menu ;;
    esac
}

photorec_menu() {
    clear
    echo "========================================="
    echo "  PhotoRec File Carving"
    echo "========================================="
    echo
    bash "scripts/linux/photorec.sh"
    show_main_menu
}

file_acquisition_menu() {
    clear
    echo "========================================="
    echo "  File Acquisition Tools"
    echo "========================================="
    echo
    bash "scripts/linux/file_acquisition.sh"
    show_main_menu
}

memory_analysis_menu() {
    clear
    echo "========================================="
    echo "  Memory Analysis"
    echo "========================================="
    echo
    bash "scripts/linux/memory_analysis.sh"
    show_main_menu
}

system_info_menu() {
    clear
    echo "========================================="
    echo "  System Information Collection"
    echo "========================================="
    echo
    bash "scripts/linux/system_info.sh"
    show_main_menu
}

exit_toolkit() {
    clear
    bash "scripts/linux/checksumgeneratorlin.sh"
    exit 0
}

while true; do
    show_main_menu
done