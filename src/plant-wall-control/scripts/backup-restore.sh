#!/bin/bash
# backup-restore.sh - Plant Wall Control System Backup Restoration Script
# Restores system configuration, application data, and provides recovery procedures
# Optimized for Raspberry Pi Zero 2W deployment

set -e

# Script configuration
SCRIPT_VERSION="1.0.0"
BACKUP_ROOT="/opt/plant-wall-backups"
RESTORE_LOG="/var/log/plant-wall-restore-$(date +%Y%m%d-%H%M%S).log"

# Plant Wall Control directories
INSTALL_DIR="/opt/plant-wall-control"
CONFIG_DIR="/etc/plant-wall-control"
DATA_DIR="/var/lib/plant-wall-control"
LOG_DIR="/var/log/plant-wall-control"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Restore options
RESTORE_SYSTEM=false
RESTORE_APPLICATION=false
RESTORE_DATA=false
RESTORE_LOGS=false
BACKUP_DIR=""
FORCE_RESTORE=false
DRY_RUN=false

# Log functions
log_header() {
    local msg="=== $1 ==="
    echo -e "\n${PURPLE}$msg${NC}"
    echo "$msg" >> "$RESTORE_LOG"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$RESTORE_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[SUCCESS] $1" >> "$RESTORE_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[WARNING] $1" >> "$RESTORE_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$RESTORE_LOG"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
    echo "[STEP] $1" >> "$RESTORE_LOG"
}

# Helper functions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_backup_directory() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_error "Backup directory not found: $BACKUP_DIR"
        exit 1
    fi
    
    if [[ ! -f "$BACKUP_DIR/backup-manifest.txt" ]]; then
        log_error "Invalid backup directory: backup-manifest.txt not found"
        exit 1
    fi
    
    log_info "Using backup directory: $BACKUP_DIR"
    
    # Display backup information
    log_info "Backup manifest:"
    head -20 "$BACKUP_DIR/backup-manifest.txt" | while read line; do
        echo "  $line"
    done
}

stop_plant_wall_service() {
    log_step "Stopping Plant Wall Control service"
    
    if systemctl is-active --quiet plant-wall-control; then
        log_info "Stopping plant-wall-control service"
        systemctl stop plant-wall-control
        log_success "Service stopped"
    else
        log_info "Plant Wall Control service is not running"
    fi
}

start_plant_wall_service() {
    log_step "Starting Plant Wall Control service"
    
    if systemctl is-enabled --quiet plant-wall-control; then
        log_info "Starting plant-wall-control service"
        systemctl start plant-wall-control
        
        # Wait for service to start
        sleep 5
        
        if systemctl is-active --quiet plant-wall-control; then
            log_success "Service started successfully"
        else
            log_error "Service failed to start"
            log_info "Check status: systemctl status plant-wall-control"
        fi
    else
        log_warning "Plant Wall Control service is not enabled"
        log_info "Enable with: systemctl enable plant-wall-control"
    fi
}

backup_current_system() {
    log_step "Creating backup of current system before restore"
    
    local pre_restore_backup="/tmp/plant-wall-pre-restore-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$pre_restore_backup"
    
    # Backup current application if it exists
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "Backing up current application"
        cp -r "$INSTALL_DIR" "$pre_restore_backup/"
    fi
    
    # Backup current configuration if it exists
    if [[ -d "$CONFIG_DIR" ]]; then
        log_info "Backing up current configuration"
        cp -r "$CONFIG_DIR" "$pre_restore_backup/"
    fi
    
    # Backup current data if it exists
    if [[ -d "$DATA_DIR" ]]; then
        log_info "Backing up current data"
        cp -r "$DATA_DIR" "$pre_restore_backup/"
    fi
    
    log_success "Current system backed up to: $pre_restore_backup"
    echo "Pre-restore backup: $pre_restore_backup" >> "$RESTORE_LOG"
}

restore_system_configuration() {
    if [[ ! $RESTORE_SYSTEM == true ]]; then
        return 0
    fi
    
    log_header "Restoring System Configuration"
    
    local system_backup_dir="$BACKUP_DIR/system"
    
    if [[ ! -d "$system_backup_dir" ]]; then
        log_warning "System configuration backup not found"
        return 1
    fi
    
    # Ask for confirmation for critical system files
    if [[ ! $FORCE_RESTORE == true ]]; then
        echo -e "${YELLOW}WARNING:${NC} Restoring system configuration will overwrite:"
        echo "  • Boot configuration (/boot/config.txt, /boot/cmdline.txt)"
        echo "  • Network configuration (/etc/wpa_supplicant/)"
        echo "  • SSH configuration (/etc/ssh/)"
        echo "  • Systemd services"
        echo
        read -p "Continue with system configuration restore? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "System configuration restore skipped"
            return 0
        fi
    fi
    
    # Restore system configuration files
    log_step "Restoring system configuration files"
    
    # Important: Restore files carefully to avoid breaking the system
    local restore_files=(
        "etc/systemd/system/plant-wall-control.service"
        "etc/systemd/system/health-check.timer"
        "etc/systemd/system/health-check-oneshot.service"
        "etc/udev/rules.d"
        "etc/logrotate.d/plant-wall-control"
        "etc/cron.d/plant-wall-monitoring"
    )
    
    for file_path in "${restore_files[@]}"; do
        local source_file="$system_backup_dir/$file_path"
        local target_file="/$file_path"
        
        if [[ -e "$source_file" ]]; then
            log_info "Restoring: $target_file"
            
            if [[ $DRY_RUN == true ]]; then
                log_info "DRY RUN: Would restore $source_file to $target_file"
            else
                # Create target directory if needed
                mkdir -p "$(dirname "$target_file")"
                
                # Copy file or directory
                if [[ -d "$source_file" ]]; then
                    cp -r "$source_file"/* "$(dirname "$target_file")/"
                else
                    cp "$source_file" "$target_file"
                fi
            fi
        else
            log_warning "Backup file not found: $source_file"
        fi
    done
    
    # Reload systemd after restoring service files
    if [[ $DRY_RUN == false ]]; then
        log_info "Reloading systemd daemon"
        systemctl daemon-reload
        
        # Reload udev rules
        log_info "Reloading udev rules"
        udevadm control --reload-rules
        udevadm trigger
    fi
    
    log_success "System configuration restore completed"
}

restore_application() {
    if [[ ! $RESTORE_APPLICATION == true ]]; then
        return 0
    fi
    
    log_header "Restoring Plant Wall Control Application"
    
    local app_backup_dir="$BACKUP_DIR/application"
    
    if [[ ! -d "$app_backup_dir" ]]; then
        log_warning "Application backup not found"
        return 1
    fi
    
    # Restore application directory
    if [[ -d "$app_backup_dir/plant-wall-control" ]]; then
        log_step "Restoring application files"
        
        if [[ $DRY_RUN == true ]]; then
            log_info "DRY RUN: Would restore application to $INSTALL_DIR"
        else
            # Create target directory
            mkdir -p "$INSTALL_DIR"
            
            # Remove existing application (if any)
            if [[ -d "$INSTALL_DIR" ]]; then
                log_info "Removing existing application files"
                rm -rf "$INSTALL_DIR"/*
            fi
            
            # Restore application files
            log_info "Copying application files"
            cp -r "$app_backup_dir/plant-wall-control"/* "$INSTALL_DIR/"
            
            # Set proper permissions
            chown -R plantwall:plantwall "$INSTALL_DIR"
            chmod 755 "$INSTALL_DIR/plant-wall-control" 2>/dev/null || true
            
            log_success "Application files restored"
        fi
    fi
    
    # Restore configuration directory
    if [[ -d "$app_backup_dir/plant-wall-control" ]]; then
        log_step "Restoring configuration files"
        
        if [[ $DRY_RUN == true ]]; then
            log_info "DRY RUN: Would restore configuration to $CONFIG_DIR"
        else
            # Create target directory
            mkdir -p "$CONFIG_DIR"
            
            # Restore configuration files
            if [[ -d "$app_backup_dir/plant-wall-control" ]]; then
                log_info "Copying configuration files"
                cp -r "$app_backup_dir/plant-wall-control"/* "$CONFIG_DIR/" 2>/dev/null || true
                
                # Set proper permissions
                chown -R root:root "$CONFIG_DIR"
                chmod 644 "$CONFIG_DIR"/*.yaml 2>/dev/null || true
            fi
            
            log_success "Configuration files restored"
        fi
    fi
    
    log_success "Application restore completed"
}

restore_data() {
    if [[ ! $RESTORE_DATA == true ]]; then
        return 0
    fi
    
    log_header "Restoring Plant Wall Control Data"
    
    local data_backup_dir="$BACKUP_DIR/data"
    
    if [[ ! -d "$data_backup_dir" ]]; then
        log_warning "Data backup not found"
        return 1
    fi
    
    # Ask for confirmation for data restore
    if [[ ! $FORCE_RESTORE == true ]]; then
        echo -e "${YELLOW}WARNING:${NC} Restoring data will overwrite current:"
        echo "  • Sensor data and historical records"
        echo "  • Application databases"
        echo "  • User settings and preferences"
        echo
        read -p "Continue with data restore? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Data restore skipped"
            return 0
        fi
    fi
    
    log_step "Restoring data files"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "DRY RUN: Would restore data to $DATA_DIR"
        find "$data_backup_dir" -type f | head -10 | while read file; do
            log_info "DRY RUN: Would restore $(basename "$file")"
        done
    else
        # Create target directory
        mkdir -p "$DATA_DIR"
        
        # Restore data files
        if [[ -d "$data_backup_dir/plant-wall-control" ]]; then
            log_info "Copying data files"
            cp -r "$data_backup_dir/plant-wall-control"/* "$DATA_DIR/"
            
            # Set proper permissions
            chown -R plantwall:plantwall "$DATA_DIR"
            chmod 750 "$DATA_DIR"
            
            # Display restored data info
            local data_size=$(du -sh "$DATA_DIR" 2>/dev/null | cut -f1 || echo "Unknown")
            local file_count=$(find "$DATA_DIR" -type f | wc -l)
            
            log_info "Restored data size: $data_size"
            log_info "Restored file count: $file_count"
        fi
        
        log_success "Data files restored"
    fi
    
    log_success "Data restore completed"
}

restore_logs() {
    if [[ ! $RESTORE_LOGS == true ]]; then
        return 0
    fi
    
    log_header "Restoring Plant Wall Control Logs"
    
    local logs_backup_dir="$BACKUP_DIR/logs"
    
    if [[ ! -d "$logs_backup_dir" ]]; then
        log_warning "Logs backup not found"
        return 1
    fi
    
    log_step "Restoring log files"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "DRY RUN: Would restore logs to $LOG_DIR"
    else
        # Create target directory
        mkdir -p "$LOG_DIR"
        
        # Restore log files
        if [[ -d "$logs_backup_dir/plant-wall-control" ]]; then
            log_info "Copying log files"
            cp -r "$logs_backup_dir/plant-wall-control"/* "$LOG_DIR/"
            
            # Set proper permissions
            chown -R plantwall:plantwall "$LOG_DIR"
            chmod 750 "$LOG_DIR"
        fi
        
        log_success "Log files restored"
    fi
    
    log_success "Logs restore completed"
}

verify_restoration() {
    log_header "Verifying Restoration"
    
    local verification_passed=true
    
    # Check application binary
    if [[ $RESTORE_APPLICATION == true ]]; then
        if [[ -f "$INSTALL_DIR/plant-wall-control" ]]; then
            log_success "Application binary found"
            
            # Check if binary is executable
            if [[ -x "$INSTALL_DIR/plant-wall-control" ]]; then
                log_success "Application binary is executable"
            else
                log_error "Application binary is not executable"
                verification_passed=false
            fi
        else
            log_error "Application binary not found"
            verification_passed=false
        fi
    fi
    
    # Check configuration files
    if [[ $RESTORE_APPLICATION == true ]]; then
        if [[ -f "$CONFIG_DIR/config.yaml" ]] || [[ -f "$CONFIG_DIR/hardware-production.yaml" ]]; then
            log_success "Configuration files found"
        else
            log_warning "No configuration files found"
        fi
    fi
    
    # Check data directory
    if [[ $RESTORE_DATA == true ]]; then
        if [[ -d "$DATA_DIR" ]]; then
            local file_count=$(find "$DATA_DIR" -type f | wc -l)
            log_success "Data directory restored with $file_count files"
        else
            log_warning "Data directory not found"
        fi
    fi
    
    # Check service status
    if [[ $RESTORE_SYSTEM == true ]]; then
        if systemctl list-unit-files | grep -q plant-wall-control; then
            log_success "Plant Wall Control service is installed"
            
            if systemctl is-enabled --quiet plant-wall-control; then
                log_success "Service is enabled"
            else
                log_warning "Service is not enabled"
            fi
        else
            log_error "Plant Wall Control service not found"
            verification_passed=false
        fi
    fi
    
    if [[ $verification_passed == true ]]; then
        log_success "Restoration verification passed"
        return 0
    else
        log_error "Restoration verification failed"
        return 1
    fi
}

list_available_backups() {
    log_header "Available Backups"
    
    if [[ ! -d "$BACKUP_ROOT" ]]; then
        log_error "Backup root directory not found: $BACKUP_ROOT"
        return 1
    fi
    
    local backup_dirs=($(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "????????-??????" | sort -r))
    
    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        log_info "No backups found in $BACKUP_ROOT"
        return 1
    fi
    
    echo "Available backups:"
    echo
    
    for backup_dir in "${backup_dirs[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_date=$(echo "$backup_name" | sed 's/\(........\)-\(......\)/\1 \2/' | sed 's/\(....\)\(..\)\(..\) \(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/')
        local backup_size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1 || echo "Unknown")
        
        echo "  $backup_name"
        echo "    Date: $backup_date"
        echo "    Size: $backup_size"
        echo "    Path: $backup_dir"
        
        # Show manifest summary if available
        if [[ -f "$backup_dir/backup-manifest.txt" ]]; then
            local manifest_summary=$(grep "Total Backup Size:" "$backup_dir/backup-manifest.txt" 2>/dev/null || echo "")
            if [[ -n "$manifest_summary" ]]; then
                echo "    $manifest_summary"
            fi
        fi
        echo
    done
}

show_restore_instructions() {
    cat << 'EOF'
Plant Wall Control System Backup Restoration
============================================

This script can restore various components of the Plant Wall Control system:

RESTORATION TYPES:
  --system      Restore systemd services, udev rules, and system configuration
  --application Restore Plant Wall Control binary and configuration files  
  --data        Restore application data and databases
  --logs        Restore application and system logs
  --all         Restore all components (equivalent to --system --application --data --logs)

USAGE EXAMPLES:
  # List available backups
  sudo ./backup-restore.sh --list

  # Restore everything from latest backup
  sudo ./backup-restore.sh --all --latest

  # Restore specific backup
  sudo ./backup-restore.sh --all --restore-from /opt/plant-wall-backups/20231215-143022

  # Restore only application (safe)
  sudo ./backup-restore.sh --application --restore-from /path/to/backup

  # Dry run (show what would be restored)
  sudo ./backup-restore.sh --all --restore-from /path/to/backup --dry-run

OPTIONS:
  --restore-from PATH   Restore from specific backup directory
  --latest             Use the most recent backup
  --force              Skip confirmation prompts
  --dry-run            Show what would be restored without making changes
  --help, -h           Show detailed help

SAFETY NOTES:
  • System configuration restore affects boot settings and services
  • Application restore is generally safe and won't break the system
  • Data restore overwrites current sensor data and settings
  • A pre-restore backup is automatically created in /tmp/

RECOVERY FROM SD CARD IMAGE:
  If the system is completely broken, use the SD card image:
  
  1. Find the SD image in the backup:
     ls /opt/plant-wall-backups/*/sd-image/
  
  2. Flash to new SD card:
     sudo dd if=backup-image.img of=/dev/sdX bs=1M status=progress
     
  3. Boot from new SD card and update network settings if needed

For more information, see the backup manifest file in each backup directory.
EOF
}

# Main restore function
main() {
    log_header "Plant Wall Control System Restore v$SCRIPT_VERSION"
    echo -e "${BLUE}Restoring Plant Wall Control system from backup${NC}"
    echo
    
    # Initialize restore log
    mkdir -p "$(dirname "$RESTORE_LOG")"
    echo "Plant Wall Control System Restore - $(date)" > "$RESTORE_LOG"
    echo "======================================================" >> "$RESTORE_LOG"
    
    # Preflight checks
    check_root
    check_backup_directory
    
    # Create pre-restore backup
    if [[ $DRY_RUN == false ]] && [[ $FORCE_RESTORE == false ]]; then
        backup_current_system
    fi
    
    # Stop service before restoration
    if [[ $DRY_RUN == false ]]; then
        stop_plant_wall_service
    fi
    
    # Perform restoration
    restore_system_configuration
    restore_application  
    restore_data
    restore_logs
    
    # Verify restoration
    if [[ $DRY_RUN == false ]]; then
        verify_restoration
        
        # Start service after restoration
        if [[ $RESTORE_APPLICATION == true ]] || [[ $RESTORE_SYSTEM == true ]]; then
            start_plant_wall_service
        fi
    fi
    
    log_success "Restoration completed!"
    log_info "Restore log: $RESTORE_LOG"
    
    if [[ $DRY_RUN == true ]]; then
        echo -e "${YELLOW}This was a dry run - no changes were made${NC}"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --system)
            RESTORE_SYSTEM=true
            shift
            ;;
        --application)
            RESTORE_APPLICATION=true
            shift
            ;;
        --data)
            RESTORE_DATA=true
            shift
            ;;
        --logs)
            RESTORE_LOGS=true
            shift
            ;;
        --all)
            RESTORE_SYSTEM=true
            RESTORE_APPLICATION=true
            RESTORE_DATA=true
            RESTORE_LOGS=true
            shift
            ;;
        --restore-from)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --latest)
            # Find latest backup
            if [[ -d "$BACKUP_ROOT" ]]; then
                BACKUP_DIR=$(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "????????-??????" | sort -r | head -1)
                if [[ -z "$BACKUP_DIR" ]]; then
                    log_error "No backups found in $BACKUP_ROOT"
                    exit 1
                fi
                log_info "Using latest backup: $(basename "$BACKUP_DIR")"
            else
                log_error "Backup root directory not found: $BACKUP_ROOT"
                exit 1
            fi
            shift
            ;;
        --force)
            FORCE_RESTORE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list)
            list_available_backups
            exit 0
            ;;
        --help|-h)
            show_restore_instructions
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate arguments
if [[ -z "$BACKUP_DIR" ]]; then
    log_error "No backup directory specified"
    echo "Use --restore-from /path/to/backup or --latest"
    echo "Use --list to see available backups"
    echo "Use --help for detailed usage information"
    exit 1
fi

if [[ ! $RESTORE_SYSTEM == true ]] && [[ ! $RESTORE_APPLICATION == true ]] && [[ ! $RESTORE_DATA == true ]] && [[ ! $RESTORE_LOGS == true ]]; then
    log_error "No restore type specified"
    echo "Use --system, --application, --data, --logs, or --all"
    echo "Use --help for detailed usage information"
    exit 1
fi

# Run main function
main