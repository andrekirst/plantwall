#!/bin/bash
# backup-create.sh - Plant Wall Control System Backup Creation Script
# Creates comprehensive backups of system configuration, data, and SD card images
# Optimized for Raspberry Pi Zero 2W deployment

set -e

# Script configuration
SCRIPT_VERSION="1.0.0"
BACKUP_ROOT="/opt/plant-wall-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
MAX_BACKUPS=10

# Plant Wall Control directories
INSTALL_DIR="/opt/plant-wall-control"
CONFIG_DIR="/etc/plant-wall-control"
DATA_DIR="/var/lib/plant-wall-control"
LOG_DIR="/var/log/plant-wall-control"

# System configuration files
SYSTEM_CONFIGS=(
    "/boot/config.txt"
    "/boot/cmdline.txt"
    "/etc/wpa_supplicant/wpa_supplicant.conf"
    "/etc/ssh/sshd_config"
    "/etc/ssh/sshd_config.d/"
    "/etc/systemd/system/plant-wall-control.service"
    "/etc/systemd/system/health-check.timer"
    "/etc/systemd/system/health-check-oneshot.service"
    "/etc/udev/rules.d/99-plant-wall-*.rules"
    "/etc/logrotate.d/plant-wall-control"
    "/etc/cron.d/plant-wall-monitoring"
    "/etc/fstab"
    "/etc/sysctl.conf"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log functions
log_header() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Helper functions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_disk_space() {
    local required_space_mb=1000  # Minimum 1GB free space
    local available_space_kb=$(df /opt | tail -1 | awk '{print $4}')
    local available_space_mb=$((available_space_kb / 1024))
    
    if [[ $available_space_mb -lt $required_space_mb ]]; then
        log_error "Insufficient disk space. Required: ${required_space_mb}MB, Available: ${available_space_mb}MB"
        exit 1
    fi
    
    log_info "Available disk space: ${available_space_mb}MB"
}

create_backup_directory() {
    log_step "Creating backup directory structure"
    
    mkdir -p "$BACKUP_DIR"/{system,application,data,logs,sd-image}
    
    # Set proper permissions
    chmod 755 "$BACKUP_ROOT"
    chmod 750 "$BACKUP_DIR"
    
    log_success "Backup directory created: $BACKUP_DIR"
}

backup_system_configuration() {
    log_step "Backing up system configuration files"
    
    local system_backup_dir="$BACKUP_DIR/system"
    
    # Create system info
    cat > "$system_backup_dir/system-info.txt" << EOF
Plant Wall Control System Backup
===============================
Backup Date: $(date)
System: $(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' || echo "Unknown")
Kernel: $(uname -r)
Uptime: $(uptime)
Disk Usage: $(df -h)
Memory: $(free -h)

Backup Script Version: $SCRIPT_VERSION
EOF
    
    # Backup each system configuration file
    for config_file in "${SYSTEM_CONFIGS[@]}"; do
        if [[ -e "$config_file" ]]; then
            log_info "Backing up: $config_file"
            
            # Create directory structure in backup
            local backup_path="$system_backup_dir$(dirname "$config_file")"
            mkdir -p "$backup_path"
            
            # Copy file or directory
            if [[ -d "$config_file" ]]; then
                cp -r "$config_file" "$backup_path/"
            else
                cp "$config_file" "$backup_path/"
            fi
        else
            log_warning "Configuration file not found: $config_file"
        fi
    done
    
    # Backup additional system information
    log_info "Collecting additional system information"
    
    # Network configuration
    ip addr show > "$system_backup_dir/network-interfaces.txt" 2>/dev/null || true
    iwconfig > "$system_backup_dir/wifi-config.txt" 2>/dev/null || true
    
    # Installed packages
    dpkg -l > "$system_backup_dir/installed-packages.txt" 2>/dev/null || true
    
    # Running services
    systemctl list-units --type=service --state=running > "$system_backup_dir/running-services.txt" 2>/dev/null || true
    
    # Enabled services
    systemctl list-unit-files --type=service --state=enabled > "$system_backup_dir/enabled-services.txt" 2>/dev/null || true
    
    # GPIO configuration
    if [[ -d "/sys/class/gpio" ]]; then
        ls -la /sys/class/gpio/ > "$system_backup_dir/gpio-status.txt" 2>/dev/null || true
    fi
    
    # Hardware information
    lscpu > "$system_backup_dir/cpu-info.txt" 2>/dev/null || true
    lsusb > "$system_backup_dir/usb-devices.txt" 2>/dev/null || true
    
    # I2C and SPI devices
    if command -v i2cdetect >/dev/null 2>&1; then
        i2cdetect -y 1 > "$system_backup_dir/i2c-devices.txt" 2>/dev/null || true
    fi
    
    if [[ -c /dev/spidev0.0 ]]; then
        ls -la /dev/spidev* > "$system_backup_dir/spi-devices.txt" 2>/dev/null || true
    fi
    
    log_success "System configuration backup completed"
}

backup_application() {
    log_step "Backing up Plant Wall Control application"
    
    local app_backup_dir="$BACKUP_DIR/application"
    
    # Backup application directory
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "Backing up application directory: $INSTALL_DIR"
        cp -r "$INSTALL_DIR" "$app_backup_dir/"
        
        # Remove logs from application backup (they go to logs section)
        rm -rf "$app_backup_dir/plant-wall-control/logs" 2>/dev/null || true
    else
        log_warning "Application directory not found: $INSTALL_DIR"
    fi
    
    # Backup configuration directory
    if [[ -d "$CONFIG_DIR" ]]; then
        log_info "Backing up configuration directory: $CONFIG_DIR"
        cp -r "$CONFIG_DIR" "$app_backup_dir/"
    else
        log_warning "Configuration directory not found: $CONFIG_DIR"
    fi
    
    # Create application metadata
    cat > "$app_backup_dir/application-info.txt" << EOF
Plant Wall Control Application Backup
====================================
Backup Date: $(date)

Application Version: $(grep -o 'version.*' "$CONFIG_DIR"/*.yaml 2>/dev/null || echo "Unknown")
Binary Info: $(file "$INSTALL_DIR/plant-wall-control" 2>/dev/null || echo "Binary not found")
Binary Size: $(du -h "$INSTALL_DIR/plant-wall-control" 2>/dev/null || echo "Unknown")

Service Status: $(systemctl is-active plant-wall-control 2>/dev/null || echo "Not running")
Service Enabled: $(systemctl is-enabled plant-wall-control 2>/dev/null || echo "Not enabled")

Configuration Files:
$(find "$CONFIG_DIR" -type f 2>/dev/null || echo "No configuration files found")
EOF
    
    log_success "Application backup completed"
}

backup_data() {
    log_step "Backing up Plant Wall Control data"
    
    local data_backup_dir="$BACKUP_DIR/data"
    
    # Backup data directory
    if [[ -d "$DATA_DIR" ]]; then
        log_info "Backing up data directory: $DATA_DIR"
        cp -r "$DATA_DIR" "$data_backup_dir/"
        
        # Get data directory size
        local data_size=$(du -sh "$DATA_DIR" 2>/dev/null | cut -f1 || echo "Unknown")
        log_info "Data directory size: $data_size"
    else
        log_warning "Data directory not found: $DATA_DIR"
    fi
    
    # Backup database files if they exist
    local db_files=("$DATA_DIR"/*.db "$DATA_DIR"/*.sqlite "$DATA_DIR"/*.json)
    for db_file in "${db_files[@]}"; do
        if [[ -f "$db_file" ]]; then
            log_info "Found database file: $db_file"
        fi
    done
    
    # Create data metadata
    cat > "$data_backup_dir/data-info.txt" << EOF
Plant Wall Control Data Backup
=============================
Backup Date: $(date)

Data Directory: $DATA_DIR
Data Size: $(du -sh "$DATA_DIR" 2>/dev/null | cut -f1 || echo "Unknown")

Files in Data Directory:
$(find "$DATA_DIR" -type f -exec ls -lh {} \; 2>/dev/null || echo "No data files found")

Recent Data Files (last 7 days):
$(find "$DATA_DIR" -type f -mtime -7 -exec ls -lht {} \; 2>/dev/null || echo "No recent files")
EOF
    
    log_success "Data backup completed"
}

backup_logs() {
    log_step "Backing up system and application logs"
    
    local logs_backup_dir="$BACKUP_DIR/logs"
    
    # Backup Plant Wall Control logs
    if [[ -d "$LOG_DIR" ]]; then
        log_info "Backing up application logs: $LOG_DIR"
        cp -r "$LOG_DIR" "$logs_backup_dir/"
    else
        log_warning "Log directory not found: $LOG_DIR"
    fi
    
    # Backup recent system logs
    log_info "Backing up recent system logs"
    mkdir -p "$logs_backup_dir/system"
    
    # Last 1000 lines of important logs
    journalctl -u plant-wall-control --no-pager -n 1000 > "$logs_backup_dir/system/plant-wall-control-journal.log" 2>/dev/null || true
    journalctl --no-pager -n 1000 > "$logs_backup_dir/system/system-journal.log" 2>/dev/null || true
    
    # Copy recent log files
    local system_log_files=(
        "/var/log/syslog"
        "/var/log/auth.log"
        "/var/log/daemon.log"
        "/var/log/kern.log"
        "/var/log/plant-wall-system.log"
    )
    
    for log_file in "${system_log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            log_info "Backing up system log: $log_file"
            cp "$log_file" "$logs_backup_dir/system/" 2>/dev/null || true
        fi
    done
    
    # Create logs metadata
    cat > "$logs_backup_dir/logs-info.txt" << EOF
Plant Wall Control Logs Backup
=============================
Backup Date: $(date)

Application Logs: $LOG_DIR
Application Log Size: $(du -sh "$LOG_DIR" 2>/dev/null | cut -f1 || echo "Unknown")

System Log Files:
$(ls -lh "$logs_backup_dir/system/" 2>/dev/null || echo "No system logs backed up")

Recent Errors (last 100 lines):
$(journalctl --no-pager -p err -n 100 2>/dev/null || echo "No recent errors")
EOF
    
    log_success "Logs backup completed"
}

create_sd_card_image() {
    log_step "Creating SD card image backup"
    
    if [[ ! -b "/dev/mmcblk0" ]]; then
        log_warning "SD card device not found (/dev/mmcblk0) - skipping image backup"
        echo "SD card image backup skipped - not running on Raspberry Pi" > "$BACKUP_DIR/sd-image/skipped.txt"
        return 0
    fi
    
    local image_backup_dir="$BACKUP_DIR/sd-image"
    local image_file="$image_backup_dir/plant-wall-sd-backup-$TIMESTAMP.img"
    
    # Check available space for image
    local sd_size_mb=$(lsblk -b -d -o SIZE /dev/mmcblk0 2>/dev/null | tail -1)
    local sd_size_mb=$((sd_size_mb / 1024 / 1024))
    local available_space_kb=$(df "$BACKUP_ROOT" | tail -1 | awk '{print $4}')
    local available_space_mb=$((available_space_kb / 1024))
    
    if [[ $available_space_mb -lt $((sd_size_mb + 500)) ]]; then
        log_warning "Insufficient space for full SD card image (${sd_size_mb}MB). Creating compressed image."
        
        # Create compressed image using dd and gzip
        log_info "Creating compressed SD card image..."
        dd if=/dev/mmcblk0 bs=1M | gzip > "${image_file}.gz" &
        local dd_pid=$!
        
        # Show progress
        while kill -0 $dd_pid 2>/dev/null; do
            sleep 10
            local current_size=$(du -m "${image_file}.gz" 2>/dev/null | cut -f1 || echo "0")
            log_info "Image creation progress: ${current_size}MB compressed"
        done
        
        wait $dd_pid
        local dd_exit_code=$?
        
        if [[ $dd_exit_code -eq 0 ]]; then
            log_success "Compressed SD card image created: ${image_file}.gz"
        else
            log_error "SD card image creation failed"
            return 1
        fi
    else
        log_info "Creating full SD card image (${sd_size_mb}MB)..."
        
        # Create full image
        dd if=/dev/mmcblk0 of="$image_file" bs=1M status=progress
        
        log_success "SD card image created: $image_file"
        
        # Create checksum for verification
        log_info "Creating image checksum..."
        sha256sum "$image_file" > "${image_file}.sha256"
    fi
    
    # Create image information
    cat > "$image_backup_dir/image-info.txt" << EOF
SD Card Image Backup
===================
Backup Date: $(date)

SD Card Device: /dev/mmcblk0
SD Card Size: ${sd_size_mb}MB
Image File: $(basename "$image_file")
Image Size: $(du -h "$image_file"* 2>/dev/null | head -1 | cut -f1 || echo "Unknown")

Partition Information:
$(fdisk -l /dev/mmcblk0 2>/dev/null || echo "Unable to read partition table")

File System Information:
$(df -h / /boot 2>/dev/null || echo "Unable to read file system info")
EOF
    
    log_success "SD card image backup completed"
}

create_backup_manifest() {
    log_step "Creating backup manifest"
    
    cat > "$BACKUP_DIR/backup-manifest.txt" << EOF
Plant Wall Control System Backup Manifest
=========================================
Backup Date: $(date)
Backup Directory: $BACKUP_DIR
Backup Script Version: $SCRIPT_VERSION

System Information:
==================
Hostname: $(hostname)
System: $(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' || echo "Unknown")
Kernel: $(uname -r)
Architecture: $(uname -m)
Uptime: $(uptime)

Backup Contents:
===============
System Configuration: $(du -sh "$BACKUP_DIR/system" 2>/dev/null | cut -f1 || echo "N/A")
Application Files: $(du -sh "$BACKUP_DIR/application" 2>/dev/null | cut -f1 || echo "N/A")
Data Files: $(du -sh "$BACKUP_DIR/data" 2>/dev/null | cut -f1 || echo "N/A")
Log Files: $(du -sh "$BACKUP_DIR/logs" 2>/dev/null | cut -f1 || echo "N/A")
SD Card Image: $(du -sh "$BACKUP_DIR/sd-image" 2>/dev/null | cut -f1 || echo "N/A")

Total Backup Size: $(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "Unknown")

File Count by Directory:
$(find "$BACKUP_DIR" -type d -exec sh -c 'echo "{}: $(find "$1" -type f | wc -l) files"' _ {} \; 2>/dev/null || echo "Unable to count files")

Backup Verification:
===================
All directories created: $(test -d "$BACKUP_DIR/system" && test -d "$BACKUP_DIR/application" && test -d "$BACKUP_DIR/data" && test -d "$BACKUP_DIR/logs" && echo "Yes" || echo "No")
Manifest created: $(test -f "$BACKUP_DIR/backup-manifest.txt" && echo "Yes" || echo "No")

Recovery Instructions:
=====================
To restore this backup, use the backup-restore.sh script:
sudo ./backup-restore.sh --restore-from "$BACKUP_DIR"

For emergency recovery from SD image:
1. Flash the SD image to a new card: dd if=sd-image/*.img of=/dev/sdX bs=1M
2. Boot the Raspberry Pi from the new SD card
3. Update any network configuration as needed

Notes:
======
- This backup includes complete system configuration
- Application data and logs are included
- SD card image provides full system recovery capability
- Store this backup in multiple locations for redundancy
EOF
    
    log_success "Backup manifest created"
}

cleanup_old_backups() {
    log_step "Cleaning up old backups"
    
    # Find all backup directories (sorted by date)
    local backup_dirs=($(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "????????-??????" | sort -r))
    local backup_count=${#backup_dirs[@]}
    
    if [[ $backup_count -gt $MAX_BACKUPS ]]; then
        log_info "Found $backup_count backups, keeping $MAX_BACKUPS newest"
        
        # Remove old backups
        for ((i=$MAX_BACKUPS; i<$backup_count; i++)); do
            local old_backup="${backup_dirs[$i]}"
            log_info "Removing old backup: $(basename "$old_backup")"
            rm -rf "$old_backup"
        done
        
        log_success "Cleaned up $((backup_count - MAX_BACKUPS)) old backups"
    else
        log_info "Found $backup_count backups, no cleanup needed"
    fi
}

compress_backup() {
    log_step "Compressing backup (optional)"
    
    read -p "Compress backup to save space? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Compressing backup directory..."
        
        local compressed_file="$BACKUP_ROOT/plant-wall-backup-$TIMESTAMP.tar.gz"
        
        # Create compressed archive
        tar -czf "$compressed_file" -C "$BACKUP_ROOT" "$(basename "$BACKUP_DIR")"
        
        local original_size=$(du -sh "$BACKUP_DIR" | cut -f1)
        local compressed_size=$(du -sh "$compressed_file" | cut -f1)
        
        log_success "Backup compressed: $compressed_file"
        log_info "Original size: $original_size, Compressed size: $compressed_size"
        
        # Ask if user wants to remove uncompressed backup
        read -p "Remove uncompressed backup directory? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$BACKUP_DIR"
            log_info "Uncompressed backup directory removed"
        fi
    fi
}

display_summary() {
    log_header "Backup Summary"
    
    echo -e "${GREEN}Plant Wall Control System backup completed successfully!${NC}"
    echo
    echo "Backup Information:"
    echo "  Date: $(date)"
    echo "  Location: $BACKUP_DIR"
    echo "  Total Size: $(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "Unknown")"
    echo
    echo "Backup Contents:"
    echo "  • System configuration files"
    echo "  • Plant Wall Control application"
    echo "  • Application data and logs"
    echo "  • SD card image (if created)"
    echo
    echo "Recovery:"
    echo "  Use backup-restore.sh to restore from this backup"
    echo "  Manifest file: $BACKUP_DIR/backup-manifest.txt"
    echo
    echo -e "${YELLOW}Important:${NC} Store this backup in a safe location!"
    echo -e "${YELLOW}Recommendation:${NC} Copy to external storage or cloud backup"
}

# Main backup function
main() {
    log_header "Plant Wall Control System Backup v$SCRIPT_VERSION"
    echo -e "${BLUE}Creating comprehensive system backup${NC}"
    echo
    
    # Preflight checks
    check_root
    check_disk_space
    
    # Create backup
    create_backup_directory
    backup_system_configuration
    backup_application
    backup_data
    backup_logs
    create_sd_card_image
    create_backup_manifest
    cleanup_old_backups
    
    # Optional compression
    if [[ "${1:-}" != "--no-compress" ]]; then
        compress_backup
    fi
    
    # Show summary
    display_summary
    
    log_success "Backup creation completed successfully!"
}

# Script entry point
case "${1:-}" in
    --help|-h)
        echo "Plant Wall Control System Backup Creation Script"
        echo
        echo "Usage: sudo $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)         Create full system backup"
        echo "  --no-compress  Skip compression prompt"
        echo "  --help, -h     Show this help message"
        echo
        echo "This script creates:"
        echo "  • System configuration backup"
        echo "  • Application files backup"
        echo "  • Data and logs backup"
        echo "  • SD card image backup"
        echo "  • Recovery manifest"
        echo
        echo "Requirements:"
        echo "  • Must be run as root"
        echo "  • At least 1GB free disk space"
        echo "  • SD card image requires space equal to SD card size"
        echo
        echo "Backup location: $BACKUP_ROOT"
        echo "Maximum backups kept: $MAX_BACKUPS"
        ;;
    *)
        main "$@"
        ;;
esac