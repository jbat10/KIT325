#!/bin/bash

# System Information Collection Tool for Linux
# Gathers comprehensive system information for forensic context

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$TOOLKIT_ROOT/output"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SYSINFO_DIR="$OUTPUT_DIR/system_info_$TIMESTAMP"
mkdir -p "$SYSINFO_DIR"

echo "Collecting system information..."
echo "Output directory: $SYSINFO_DIR"
echo

# Basic system information
echo "=== BASIC SYSTEM INFO ===" > "$SYSINFO_DIR/system_overview.txt"
uname -a >> "$SYSINFO_DIR/system_overview.txt"
echo >> "$SYSINFO_DIR/system_overview.txt"

if [ -f /etc/os-release ]; then
    cat /etc/os-release >> "$SYSINFO_DIR/system_overview.txt"
fi

echo >> "$SYSINFO_DIR/system_overview.txt"
uptime >> "$SYSINFO_DIR/system_overview.txt"
echo >> "$SYSINFO_DIR/system_overview.txt"
date >> "$SYSINFO_DIR/system_overview.txt"

# Hardware information
echo "Collecting hardware information..."
if command -v lshw &> /dev/null; then
    lshw > "$SYSINFO_DIR/hardware_detailed.txt" 2>/dev/null
fi

lscpu > "$SYSINFO_DIR/cpu_info.txt" 2>/dev/null
cat /proc/meminfo > "$SYSINFO_DIR/memory_info.txt"
lsblk -a > "$SYSINFO_DIR/block_devices.txt"
lsusb > "$SYSINFO_DIR/usb_devices.txt" 2>/dev/null
lspci > "$SYSINFO_DIR/pci_devices.txt" 2>/dev/null

# Process information
echo "Collecting process information..."
ps aux > "$SYSINFO_DIR/processes.txt"
ps -eo pid,ppid,cmd,etime,user > "$SYSINFO_DIR/processes_detailed.txt"

# Network information
echo "Collecting network information..."
ip addr show > "$SYSINFO_DIR/network_interfaces.txt" 2>/dev/null
ip route show > "$SYSINFO_DIR/routing_table.txt" 2>/dev/null
netstat -tuln > "$SYSINFO_DIR/network_connections.txt" 2>/dev/null
ss -tuln > "$SYSINFO_DIR/socket_statistics.txt" 2>/dev/null
arp -a > "$SYSINFO_DIR/arp_table.txt" 2>/dev/null

# User information
echo "Collecting user information..."
cat /etc/passwd > "$SYSINFO_DIR/user_accounts.txt"
cat /etc/group > "$SYSINFO_DIR/user_groups.txt"
who > "$SYSINFO_DIR/logged_users.txt"
last > "$SYSINFO_DIR/login_history.txt"
w > "$SYSINFO_DIR/current_activity.txt"

# System services
echo "Collecting service information..."
if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service > "$SYSINFO_DIR/systemd_services.txt"
    systemctl list-unit-files --type=service > "$SYSINFO_DIR/systemd_service_files.txt"
fi

if command -v service &> /dev/null; then
    service --status-all > "$SYSINFO_DIR/services_status.txt" 2>&1
fi

# Filesystem information
echo "Collecting filesystem information..."
df -h > "$SYSINFO_DIR/disk_usage.txt"
mount > "$SYSINFO_DIR/mounted_filesystems.txt"
cat /proc/mounts > "$SYSINFO_DIR/proc_mounts.txt"
lsof > "$SYSINFO_DIR/open_files.txt" 2>/dev/null

# Environment and configuration
echo "Collecting environment information..."
env > "$SYSINFO_DIR/environment_variables.txt"
cat /proc/cmdline > "$SYSINFO_DIR/kernel_cmdline.txt"
cat /proc/version > "$SYSINFO_DIR/kernel_version.txt"

# Installed packages
echo "Collecting installed packages..."
if command -v dpkg &> /dev/null; then
    dpkg -l > "$SYSINFO_DIR/installed_packages_dpkg.txt"
fi

if command -v rpm &> /dev/null; then
    rpm -qa > "$SYSINFO_DIR/installed_packages_rpm.txt"
fi

if command -v pacman &> /dev/null; then
    pacman -Q > "$SYSINFO_DIR/installed_packages_pacman.txt"
fi

# Cron jobs
echo "Collecting scheduled tasks..."
if [ -f /etc/crontab ]; then
    cp /etc/crontab "$SYSINFO_DIR/system_crontab.txt"
fi

if [ -d /etc/cron.d ]; then
    cp -r /etc/cron.d "$SYSINFO_DIR/cron.d"
fi

crontab -l > "$SYSINFO_DIR/user_crontab.txt" 2>/dev/null

# System logs (recent entries)
echo "Collecting recent log entries..."
if [ -f /var/log/syslog ]; then
    tail -1000 /var/log/syslog > "$SYSINFO_DIR/syslog_recent.txt"
fi

if [ -f /var/log/messages ]; then
    tail -1000 /var/log/messages > "$SYSINFO_DIR/messages_recent.txt"
fi

if [ -f /var/log/auth.log ]; then
    tail -1000 /var/log/auth.log > "$SYSINFO_DIR/auth_log_recent.txt"
fi

if command -v journalctl &> /dev/null; then
    journalctl --no-pager -n 1000 > "$SYSINFO_DIR/journal_recent.txt" 2>/dev/null
fi

# Network configuration files
echo "Collecting network configuration..."
if [ -d /etc/network ]; then
    cp -r /etc/network "$SYSINFO_DIR/" 2>/dev/null
fi

if [ -f /etc/resolv.conf ]; then
    cp /etc/resolv.conf "$SYSINFO_DIR/"
fi

if [ -f /etc/hosts ]; then
    cp /etc/hosts "$SYSINFO_DIR/"
fi

# Kernel modules
echo "Collecting kernel module information..."
lsmod > "$SYSINFO_DIR/loaded_modules.txt"

# Security information
echo "Collecting security information..."
if command -v sestatus &> /dev/null; then
    sestatus > "$SYSINFO_DIR/selinux_status.txt"
fi

if command -v aa-status &> /dev/null; then
    aa-status > "$SYSINFO_DIR/apparmor_status.txt" 2>/dev/null
fi

# Create summary report
SUMMARY_FILE="$SYSINFO_DIR/collection_summary.txt"
echo "System Information Collection Summary" > "$SUMMARY_FILE"
echo "=====================================" >> "$SUMMARY_FILE"
echo "Collection Date: $(date)" >> "$SUMMARY_FILE"
echo "Output Directory: $SYSINFO_DIR" >> "$SUMMARY_FILE"
echo "System: $(uname -a)" >> "$SUMMARY_FILE"
echo >> "$SUMMARY_FILE"
echo "Files Created:" >> "$SUMMARY_FILE"
ls -la "$SYSINFO_DIR" >> "$SUMMARY_FILE"

echo
echo "System information collection completed!"
echo "Results saved to: $SYSINFO_DIR"
echo
read -p "Press Enter to continue..."
clear