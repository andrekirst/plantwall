#!/bin/bash
# setup-raspberry-pi.sh - Master setup script for Raspberry Pi Zero 2W
# Plant Wall Control System - Production Ready Installation
# 
# This script configures a fresh Raspbian OS Lite installation for the Plant Wall Control System
# Optimized for headless operation with remote management capabilities

set -e

# Script configuration
SCRIPT_VERSION="1.0.0"
PI_USER="pi"
PLANTWALL_USER="plantwall"
GO_VERSION="1.21.8"
PROJECT_NAME="plant-wall-control"

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

check_raspberry_pi() {
    if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
        log_warning "This doesn't appear to be a Raspberry Pi"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        local pi_model=$(cat /proc/device-tree/model | tr -d '\0')
        log_info "Detected: $pi_model"
    fi
}

backup_original_config() {
    log_step "Creating backup of original configuration files"
    
    local backup_dir="/opt/plantwall-setup-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup important config files
    [[ -f /boot/config.txt ]] && cp /boot/config.txt "$backup_dir/"
    [[ -f /boot/cmdline.txt ]] && cp /boot/cmdline.txt "$backup_dir/"
    [[ -f /etc/wpa_supplicant/wpa_supplicant.conf ]] && cp /etc/wpa_supplicant/wpa_supplicant.conf "$backup_dir/"
    [[ -f /etc/ssh/sshd_config ]] && cp /etc/ssh/sshd_config "$backup_dir/"
    
    log_success "Configuration backup created at: $backup_dir"
}

update_system() {
    log_step "Updating system packages (this may take a while...)"
    
    # Update package lists
    apt update
    
    # Upgrade system packages
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
    
    # Install essential packages
    log_info "Installing essential packages"
    apt install -y \
        curl \
        wget \
        git \
        vim \
        htop \
        tmux \
        tree \
        unzip \
        build-essential \
        i2c-tools \
        spi-tools \
        python3-pip \
        python3-venv \
        avahi-daemon \
        fail2ban \
        ufw \
        logrotate \
        rsync \
        bc \
        jq
    
    log_success "System packages updated and essential packages installed"
}

install_go() {
    log_step "Installing Go $GO_VERSION"
    
    # Remove any existing Go installation
    rm -rf /usr/local/go
    
    # Determine architecture
    local arch=""
    case $(uname -m) in
        aarch64|arm64) arch="arm64" ;;
        armv7l|armv6l) arch="armv6l" ;;
        x86_64) arch="amd64" ;;
        *) 
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    # Download and install Go
    local go_url="https://golang.org/dl/go${GO_VERSION}.linux-${arch}.tar.gz"
    log_info "Downloading Go from: $go_url"
    
    cd /tmp
    wget -q "$go_url" -O go.tar.gz
    tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
    
    # Add Go to PATH for all users
    cat > /etc/profile.d/go.sh << 'EOF'
# Go language environment
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
    
    # Source the profile for current session
    source /etc/profile.d/go.sh
    
    # Verify installation
    /usr/local/go/bin/go version
    log_success "Go $GO_VERSION installed successfully"
}

create_plantwall_user() {
    log_step "Creating plant wall service user"
    
    # Create user if it doesn't exist
    if ! id "$PLANTWALL_USER" &>/dev/null; then
        useradd -m -s /bin/bash -G sudo "$PLANTWALL_USER"
        log_info "Created user: $PLANTWALL_USER"
    else
        log_info "User $PLANTWALL_USER already exists"
    fi
    
    # Add to hardware groups
    usermod -a -G gpio,i2c,spi,dialout,video "$PLANTWALL_USER" || {
        log_warning "Some hardware groups may not exist yet"
    }
    
    # Set up basic environment for plantwall user
    sudo -u "$PLANTWALL_USER" mkdir -p "/home/$PLANTWALL_USER/.ssh"
    sudo -u "$PLANTWALL_USER" touch "/home/$PLANTWALL_USER/.ssh/authorized_keys"
    chmod 700 "/home/$PLANTWALL_USER/.ssh"
    chmod 600 "/home/$PLANTWALL_USER/.ssh/authorized_keys"
    
    log_success "Plant wall user configured"
}

configure_hardware_interfaces() {
    log_step "Configuring hardware interfaces (GPIO, I2C, SPI)"
    
    # Enable hardware interfaces using raspi-config
    raspi-config nonint do_i2c 0    # Enable I2C
    raspi-config nonint do_spi 0    # Enable SPI
    raspi-config nonint do_ssh 0    # Enable SSH
    
    # Disable unnecessary interfaces to save power and resources
    raspi-config nonint do_camera 1     # Disable camera
    raspi-config nonint do_audio 1      # Disable audio (frees GPIO pins)
    
    log_success "Hardware interfaces configured"
}

optimize_boot_config() {
    log_step "Optimizing boot configuration for Plant Wall Control"
    
    # Backup original config
    cp /boot/config.txt /boot/config.txt.backup
    
    # Add Plant Wall optimizations to config.txt
    cat >> /boot/config.txt << 'EOF'

# ===== Plant Wall Control System Optimizations =====
# Optimized for Raspberry Pi Zero 2W headless operation

# GPU Memory Split - Minimal for headless operation
gpu_mem=16

# Disable unnecessary features for power/resource optimization
dtoverlay=disable-wifi-power-save
dtoverlay=disable-bt

# Hardware interfaces
dtparam=i2c_arm=on
dtparam=spi=on
dtparam=i2c_arm_baudrate=400000

# GPIO Performance optimizations
core_freq=250
force_turbo=0
over_voltage=0

# Audio disabled (GPIO pins available for sensors/control)
dtparam=audio=off

# LED status indicators (optional - can be disabled to save power)
# dtparam=act_led_trigger=none
# dtparam=act_led_activelow=off

# USB power management
dtparam=usbhid.mousepoll=8

# Enable hardware watchdog
dtparam=watchdog=on
EOF
    
    log_success "Boot configuration optimized"
}

optimize_cmdline() {
    log_step "Optimizing boot command line for faster boot"
    
    # Backup original cmdline.txt
    cp /boot/cmdline.txt /boot/cmdline.txt.backup
    
    # Get the current command line and optimize it
    local current_cmdline=$(cat /boot/cmdline.txt)
    
    # Remove console output for faster boot (keep tty3 for emergency access)
    local optimized_cmdline=$(echo "$current_cmdline" | sed 's/console=serial0,115200 console=tty1/console=tty3/g')
    
    # Add optimization flags
    optimized_cmdline="$optimized_cmdline quiet splash loglevel=1 logo.nologo fastboot noatime nodiratime"
    
    echo "$optimized_cmdline" > /boot/cmdline.txt
    
    log_success "Boot command line optimized"
}

configure_network() {
    log_step "Configuring network settings"
    
    # Configure WiFi power saving
    log_info "Disabling WiFi power saving for IoT reliability"
    
    # Create NetworkManager configuration to disable WiFi power saving
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/wifi-power-save.conf << 'EOF'
[connection]
wifi.powersave = 2
EOF
    
    # Configure WiFi country (adjust as needed)
    raspi-config nonint do_wifi_country DE
    
    log_success "Network configuration completed"
}

setup_ssh_security() {
    log_step "Configuring SSH security"
    
    # Backup original sshd_config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Create secure SSH configuration
    cat > /etc/ssh/sshd_config.d/plant-wall-security.conf << 'EOF'
# Plant Wall Control SSH Security Configuration

# Change default port (uncomment and change as needed)
# Port 2222

# Security settings
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Connection limits
MaxAuthTries 3
MaxStartups 2:30:10
LoginGraceTime 30

# Disable unused features
X11Forwarding no
AllowTcpForwarding no
GatewayPorts no
PermitTunnel no

# Allow specific users
AllowUsers pi plantwall

# Client connection timeout
ClientAliveInterval 300
ClientAliveCountMax 2
EOF
    
    log_success "SSH security configured"
}

setup_firewall() {
    log_step "Configuring UFW firewall"
    
    # Reset firewall to defaults
    ufw --force reset
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH (adjust port if changed above)
    ufw allow 22/tcp comment 'SSH'
    
    # Allow Plant Wall Control API
    ufw allow 5000/tcp comment 'Plant Wall Control API'
    
    # Allow from local network (adjust network range as needed)
    # ufw allow from 192.168.1.0/24 to any port 22
    # ufw allow from 192.168.1.0/24 to any port 5000
    
    # Enable firewall
    ufw --force enable
    
    log_success "Firewall configured and enabled"
}

setup_fail2ban() {
    log_step "Configuring fail2ban for SSH protection"
    
    # Create local jail configuration
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = iptables-multiport

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
    
    # Enable and start fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban
    
    log_success "Fail2ban configured and started"
}

optimize_system_performance() {
    log_step "Optimizing system performance for Pi Zero 2W"
    
    # Memory management optimizations
    cat >> /etc/sysctl.conf << 'EOF'

# Plant Wall Control System Memory Optimizations
# Optimized for 512MB RAM on Pi Zero 2W
vm.swappiness=1
vm.dirty_background_ratio=15
vm.dirty_ratio=25
vm.min_free_kbytes=8192
vm.vfs_cache_pressure=50

# Network optimizations
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 65536 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
net.ipv4.tcp_congestion_control=bbr
EOF
    
    # Disable unnecessary services
    log_info "Disabling unnecessary services"
    systemctl disable bluetooth 2>/dev/null || true
    systemctl disable triggerhappy 2>/dev/null || true
    systemctl disable ModemManager 2>/dev/null || true
    
    # Configure log2ram to reduce SD card writes
    install_log2ram
    
    log_success "System performance optimized"
}

install_log2ram() {
    log_info "Installing log2ram to reduce SD card wear"
    
    # Add log2ram repository
    echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" > /etc/apt/sources.list.d/azlux.list
    
    # Add repository key
    wget -qO - https://azlux.fr/repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/azlux-archive-keyring.gpg > /dev/null
    
    # Update and install
    apt update
    apt install -y log2ram
    
    # Configure log2ram
    sed -i 's/SIZE=40M/SIZE=100M/' /etc/log2ram.conf
    sed -i 's/USE_RSYNC=false/USE_RSYNC=true/' /etc/log2ram.conf
    
    # Add tmpfs mounts to reduce SD card writes
    cat >> /etc/fstab << 'EOF'

# Plant Wall Control - Reduce SD Card writes
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=50m 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0
tmpfs /var/run tmpfs defaults,noatime,nosuid,mode=0755,size=10m 0 0
tmpfs /var/spool/mqueue tmpfs defaults,noatime,nosuid,mode=0700,gid=12,size=10m 0 0
EOF
    
    # Disable swap to reduce SD card wear
    dphys-swapfile swapoff || true
    dphys-swapfile uninstall || true
    update-rc.d dphys-swapfile remove || true
    systemctl disable dphys-swapfile || true
    
    log_success "Log2ram installed and configured"
}

setup_gpio_permissions() {
    log_step "Setting up GPIO permissions for plant wall control"
    
    # Create udev rules for hardware access
    cat > /etc/udev/rules.d/99-plant-wall-hardware.rules << 'EOF'
# Plant Wall Control Hardware Permissions

# GPIO permissions
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys$devpath/direction /sys$devpath/value; chmod 660 /sys$devpath/direction /sys$devpath/value'"

# I2C permissions
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0664"

# SPI permissions  
KERNEL=="spidev[0-9].[0-9]", GROUP="spi", MODE="0664"

# General GPIO access
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0664"

# Hardware PWM access
KERNEL=="pwm*", GROUP="gpio", MODE="0664"
EOF
    
    # Reload udev rules
    udevadm control --reload-rules
    udevadm trigger
    
    log_success "GPIO permissions configured"
}

setup_monitoring() {
    log_step "Setting up system monitoring"
    
    # Create monitoring script directory
    mkdir -p /opt/plant-wall-monitoring
    
    # Create system monitor script
    cat > /opt/plant-wall-monitoring/system-monitor.sh << 'EOF'
#!/bin/bash
# System Monitor for Plant Wall Control
# Monitors CPU temperature, memory usage, and disk space

TEMP_THRESHOLD=70  # Celsius
MEMORY_THRESHOLD=90  # Percent
DISK_THRESHOLD=85   # Percent
LOG_FILE="/var/log/plant-wall-system.log"

check_temperature() {
    local temp_raw=$(vcgencmd measure_temp 2>/dev/null || echo "temp=0.0'C")
    local temp_celsius=$(echo $temp_raw | grep -o '[0-9.]*')
    
    if (( $(echo "$temp_celsius > $TEMP_THRESHOLD" | bc -l) )); then
        echo "$(date): WARNING - CPU temperature high: ${temp_celsius}°C" >> $LOG_FILE
        return 1
    fi
    return 0
}

check_memory() {
    local memory_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    
    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        echo "$(date): WARNING - Memory usage high: ${memory_usage}%" >> $LOG_FILE
        return 1
    fi
    return 0
}

check_disk() {
    local disk_usage=$(df / | awk 'NR==2 {print $(NF-1)}' | sed 's/%//')
    
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        echo "$(date): WARNING - Disk usage high: ${disk_usage}%" >> $LOG_FILE
        return 1
    fi
    return 0
}

# Run checks
check_temperature
check_memory  
check_disk

# Log system status
echo "$(date): System check completed - Temp: $(vcgencmd measure_temp 2>/dev/null | cut -d= -f2), Memory: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}'), Disk: $(df -h / | awk 'NR==2{print $5}')" >> $LOG_FILE
EOF
    
    chmod +x /opt/plant-wall-monitoring/system-monitor.sh
    
    # Add cron job for monitoring
    cat > /etc/cron.d/plant-wall-monitoring << 'EOF'
# Plant Wall System Monitoring
# Check system health every 5 minutes
*/5 * * * * root /opt/plant-wall-monitoring/system-monitor.sh
EOF
    
    log_success "System monitoring configured"
}

create_project_structure() {
    log_step "Creating project directory structure"
    
    # Create project directories
    mkdir -p /opt/plant-wall-control/{bin,config,logs,data,scripts}
    mkdir -p /etc/plant-wall-control
    mkdir -p /var/log/plant-wall-control
    mkdir -p /var/lib/plant-wall-control
    
    # Set ownership
    chown -R "$PLANTWALL_USER:$PLANTWALL_USER" /opt/plant-wall-control
    chown -R "$PLANTWALL_USER:$PLANTWALL_USER" /var/log/plant-wall-control
    chown -R "$PLANTWALL_USER:$PLANTWALL_USER" /var/lib/plant-wall-control
    
    # Create README for project structure
    cat > /opt/plant-wall-control/README.txt << 'EOF'
Plant Wall Control System Directory Structure
============================================

/opt/plant-wall-control/
├── bin/           - Application binaries
├── config/        - Configuration files
├── logs/          - Application logs (symlinked to /var/log/plant-wall-control)
├── data/          - Runtime data files
├── scripts/       - Utility scripts
└── README.txt     - This file

/etc/plant-wall-control/    - System configuration files
/var/log/plant-wall-control/    - System logs  
/var/lib/plant-wall-control/    - Variable data files

Service is run as user: plantwall
Hardware access via groups: gpio, i2c, spi
EOF
    
    # Create symlink for logs
    ln -sf /var/log/plant-wall-control /opt/plant-wall-control/logs
    
    log_success "Project directory structure created"
}

display_summary() {
    log_header "Installation Summary"
    
    echo -e "${GREEN}Raspberry Pi setup completed successfully!${NC}"
    echo
    echo "System Configuration:"
    echo "  • System updated and optimized for Pi Zero 2W"
    echo "  • Go $GO_VERSION installed"
    echo "  • Hardware interfaces enabled (GPIO, I2C, SPI)"
    echo "  • WiFi power saving disabled for IoT reliability"
    echo "  • SSH security hardened"
    echo "  • UFW firewall enabled (ports 22, 5000)"
    echo "  • Fail2ban configured for SSH protection"
    echo "  • Log2ram installed to reduce SD card wear"
    echo "  • System monitoring configured"
    echo
    echo "Users:"
    echo "  • $PLANTWALL_USER - Service user with hardware access"
    echo "  • $PI_USER - Default user maintained"
    echo
    echo "Project Structure:"
    echo "  • /opt/plant-wall-control/ - Main application directory"
    echo "  • /etc/plant-wall-control/ - Configuration files"
    echo "  • /var/log/plant-wall-control/ - Log files"
    echo
    echo "Next Steps:"
    echo "  1. Reboot the system: sudo reboot"
    echo "  2. Test hardware: ./hardware-test.sh"
    echo "  3. Deploy Plant Wall Control application"
    echo "  4. Configure WiFi if not already done"
    echo
    echo -e "${YELLOW}Important:${NC} System will require reboot for all optimizations to take effect"
}

# Main installation function
main() {
    log_header "Plant Wall Control - Raspberry Pi Setup v$SCRIPT_VERSION"
    echo -e "${BLUE}Optimized for Raspberry Pi Zero 2W headless operation${NC}"
    echo
    
    # Preflight checks
    check_root
    check_raspberry_pi
    
    # Create backup
    backup_original_config
    
    # System setup steps
    update_system
    install_go
    create_plantwall_user
    configure_hardware_interfaces
    optimize_boot_config
    optimize_cmdline
    configure_network
    setup_ssh_security
    setup_firewall
    setup_fail2ban
    optimize_system_performance
    setup_gpio_permissions
    setup_monitoring
    create_project_structure
    
    # Show summary
    display_summary
    
    log_success "Raspberry Pi setup completed!"
    echo -e "${YELLOW}Reboot recommended: sudo reboot${NC}"
}

# Script entry point
case "${1:-}" in
    --help|-h)
        echo "Plant Wall Control - Raspberry Pi Setup Script"
        echo
        echo "Usage: sudo $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)      Run full setup"
        echo "  --help, -h  Show this help message"
        echo
        echo "This script will:"
        echo "  • Update system packages"
        echo "  • Install Go $GO_VERSION"
        echo "  • Configure hardware interfaces"
        echo "  • Optimize for Pi Zero 2W"
        echo "  • Set up security and monitoring"
        echo "  • Create project structure"
        echo
        echo "Requirements:"
        echo "  • Fresh Raspberry Pi OS Lite installation"
        echo "  • Internet connection"
        echo "  • Must be run as root"
        ;;
    *)
        main "$@"
        ;;
esac