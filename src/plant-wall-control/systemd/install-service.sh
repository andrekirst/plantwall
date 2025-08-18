#!/bin/bash
# install-service.sh - Plant Wall Control Service Installation Script
# Optimized for Raspberry Pi Zero 2W deployment

set -e

# Configuration
SERVICE_NAME="plant-wall-control"
SERVICE_USER="plantwall"
SERVICE_GROUP="plantwall"
INSTALL_DIR="/opt/plant-wall-control"
CONFIG_DIR="/etc/plant-wall-control"
LOG_DIR="/var/log/plant-wall-control"
DATA_DIR="/var/lib/plant-wall-control"
BINARY_NAME="plant-wall-control"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_raspberry_pi() {
    if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
        log_warning "This doesn't appear to be a Raspberry Pi. Continuing anyway..."
    else
        log_info "Detected Raspberry Pi: $(cat /proc/device-tree/model)"
    fi
}

create_user() {
    log_info "Creating service user: $SERVICE_USER"
    
    if id "$SERVICE_USER" &>/dev/null; then
        log_warning "User $SERVICE_USER already exists"
    else
        useradd -r -s /bin/false -d "$INSTALL_DIR" -c "Plant Wall Control Service" "$SERVICE_USER"
        log_success "Created user: $SERVICE_USER"
    fi

    # Add user to hardware access groups
    log_info "Adding user to hardware access groups"
    usermod -a -G gpio,i2c,spi,dialout "$SERVICE_USER" || {
        log_warning "Some hardware groups may not exist. This is normal on non-Pi systems."
    }
}

create_directories() {
    log_info "Creating service directories"
    
    # Create directories with proper ownership
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/systemd"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$DATA_DIR"
    
    # Set ownership
    chown "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR"
    chown "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR/systemd"
    chown "$SERVICE_USER:$SERVICE_GROUP" "$LOG_DIR"
    chown "$SERVICE_USER:$SERVICE_GROUP" "$DATA_DIR"
    chown root:root "$CONFIG_DIR"
    
    # Set permissions
    chmod 755 "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR/systemd"
    chmod 750 "$LOG_DIR"
    chmod 750 "$DATA_DIR"
    chmod 755 "$CONFIG_DIR"
    
    log_success "Created directories"
}

install_binary() {
    log_info "Installing plant-wall-control binary"
    
    if [[ ! -f "$BINARY_NAME" ]]; then
        log_error "Binary '$BINARY_NAME' not found in current directory"
        log_info "Please build the binary first: go build -o $BINARY_NAME"
        exit 1
    fi
    
    # Copy binary
    cp "$BINARY_NAME" "$INSTALL_DIR/"
    chown "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR/$BINARY_NAME"
    chmod 755 "$INSTALL_DIR/$BINARY_NAME"
    
    log_success "Installed binary to $INSTALL_DIR/$BINARY_NAME"
}

install_config() {
    log_info "Installing configuration file"
    
    if [[ ! -f "config.yaml" ]]; then
        log_error "Configuration file 'config.yaml' not found in current directory"
        exit 1
    fi
    
    # Copy config with proper permissions
    cp "config.yaml" "$CONFIG_DIR/"
    chown root:root "$CONFIG_DIR/config.yaml"
    chmod 644 "$CONFIG_DIR/config.yaml"
    
    log_success "Installed configuration to $CONFIG_DIR/config.yaml"
}

install_systemd_service() {
    log_info "Installing systemd service and health monitoring"
    
    if [[ ! -f "systemd/$SERVICE_NAME.service" ]]; then
        log_error "Service file 'systemd/$SERVICE_NAME.service' not found"
        exit 1
    fi
    
    # Copy main service file
    cp "systemd/$SERVICE_NAME.service" "/etc/systemd/system/"
    chmod 644 "/etc/systemd/system/$SERVICE_NAME.service"
    
    # Copy health check services and timer (if they exist)
    if [[ -f "systemd/health-check-oneshot.service" ]]; then
        cp "systemd/health-check-oneshot.service" "/etc/systemd/system/"
        chmod 644 "/etc/systemd/system/health-check-oneshot.service"
        log_info "Installed health check one-shot service"
    fi
    
    if [[ -f "systemd/health-check.timer" ]]; then
        cp "systemd/health-check.timer" "/etc/systemd/system/"
        chmod 644 "/etc/systemd/system/health-check.timer"
        log_info "Installed health check timer"
    fi
    
    # Copy health check script to install directory
    if [[ -f "systemd/health-check.sh" ]]; then
        cp "systemd/health-check.sh" "$INSTALL_DIR/systemd/"
        chmod 755 "$INSTALL_DIR/systemd/health-check.sh"
        chown "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR/systemd/health-check.sh"
        log_info "Installed health check script"
    fi
    
    # Reload systemd
    systemctl daemon-reload
    
    log_success "Installed systemd service and monitoring components"
}

setup_gpio_permissions() {
    log_info "Setting up GPIO permissions"
    
    # Create udev rules for GPIO access
    cat > /etc/udev/rules.d/99-plant-wall-gpio.rules << EOF
# Plant Wall Control GPIO permissions
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys\$devpath/direction /sys\$devpath/value; chmod 660 /sys\$devpath/direction /sys\$devpath/value'"

# I2C and SPI permissions
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0664"
KERNEL=="spidev[0-9].[0-9]", GROUP="spi", MODE="0664"
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0664"
EOF
    
    # Reload udev rules
    udevadm control --reload-rules
    udevadm trigger
    
    log_success "Set up GPIO permissions"
}

install_logrotate() {
    log_info "Installing log rotation configuration"
    
    cat > /etc/logrotate.d/$SERVICE_NAME << EOF
$LOG_DIR/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 $SERVICE_USER $SERVICE_GROUP
    postrotate
        /bin/systemctl reload-or-restart $SERVICE_NAME.service > /dev/null 2>&1 || true
    endscript
}
EOF
    
    log_success "Installed log rotation configuration"
}

enable_and_start_service() {
    log_info "Enabling and starting services"
    
    # Enable main service to start on boot
    systemctl enable "$SERVICE_NAME.service"
    
    # Enable health check timer if it exists
    if [[ -f "/etc/systemd/system/health-check.timer" ]]; then
        systemctl enable health-check.timer
        log_info "Enabled health check timer"
    fi
    
    # Start the main service
    systemctl start "$SERVICE_NAME.service"
    
    # Start health check timer if enabled
    if [[ -f "/etc/systemd/system/health-check.timer" ]]; then
        systemctl start health-check.timer
        log_info "Started health check timer"
    fi
    
    # Check status
    sleep 2
    if systemctl is-active --quiet "$SERVICE_NAME.service"; then
        log_success "Service started successfully"
        systemctl status "$SERVICE_NAME.service" --no-pager -l
        
        # Show timer status if enabled
        if systemctl is-enabled --quiet health-check.timer 2>/dev/null; then
            echo
            log_info "Health check timer status:"
            systemctl status health-check.timer --no-pager -l
        fi
    else
        log_error "Service failed to start"
        log_info "Check logs: journalctl -u $SERVICE_NAME.service -f"
        exit 1
    fi
}

show_status() {
    echo
    log_info "Installation completed!"
    echo
    echo "Service Information:"
    echo "  Name: $SERVICE_NAME"
    echo "  User: $SERVICE_USER"
    echo "  Binary: $INSTALL_DIR/$BINARY_NAME"
    echo "  Config: $CONFIG_DIR/config.yaml"
    echo "  Logs: $LOG_DIR/ and 'journalctl -u $SERVICE_NAME.service'"
    echo
    echo "Useful commands:"
    echo "  Start service:    sudo systemctl start $SERVICE_NAME"
    echo "  Stop service:     sudo systemctl stop $SERVICE_NAME"
    echo "  Restart service:  sudo systemctl restart $SERVICE_NAME"
    echo "  Check status:     sudo systemctl status $SERVICE_NAME"
    echo "  View logs:        sudo journalctl -u $SERVICE_NAME -f"
    echo "  Disable service:  sudo systemctl disable $SERVICE_NAME"
    echo
}

# Main installation process
main() {
    log_info "Starting Plant Wall Control Service Installation"
    echo
    
    check_root
    check_raspberry_pi
    
    create_user
    create_directories
    install_binary
    install_config
    install_systemd_service
    setup_gpio_permissions
    install_logrotate
    enable_and_start_service
    
    show_status
    
    log_success "Installation completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    --uninstall)
        log_info "Uninstalling Plant Wall Control Service"
        systemctl stop "$SERVICE_NAME" 2>/dev/null || true
        systemctl disable "$SERVICE_NAME" 2>/dev/null || true
        rm -f "/etc/systemd/system/$SERVICE_NAME.service"
        rm -f "/etc/udev/rules.d/99-plant-wall-gpio.rules"
        rm -f "/etc/logrotate.d/$SERVICE_NAME"
        rm -rf "$INSTALL_DIR"
        rm -rf "$LOG_DIR"
        rm -rf "$DATA_DIR"
        userdel "$SERVICE_USER" 2>/dev/null || true
        systemctl daemon-reload
        log_success "Service uninstalled"
        ;;
    --help|-h)
        echo "Plant Wall Control Service Installer"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)      Install the service"
        echo "  --uninstall Uninstall the service"
        echo "  --help, -h  Show this help message"
        echo
        echo "Requirements:"
        echo "  - Must be run as root (use sudo)"
        echo "  - Binary '$BINARY_NAME' must exist in current directory"
        echo "  - Config file 'config.yaml' must exist in current directory"
        echo "  - Service file 'systemd/$SERVICE_NAME.service' must exist"
        ;;
    *)
        main "$@"
        ;;
esac