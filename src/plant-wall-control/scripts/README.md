# Plant Wall Control - Installation & Management Scripts

This directory contains comprehensive installation and management scripts for the Plant Wall Control System, optimized for Raspberry Pi Zero 2W deployment.

## Scripts Overview

### 🚀 Setup & Installation

#### `setup-raspberry-pi.sh`
**Master setup script for fresh Raspberry Pi Zero 2W installation**

- **Purpose**: Complete system setup from fresh Raspbian OS Lite
- **Features**:
  - System optimization for Pi Zero 2W (512MB RAM)
  - Go 1.21.8 installation with proper PATH configuration
  - Hardware interface enablement (GPIO, I2C, SPI)
  - WiFi power saving disabled for IoT reliability
  - SSH security hardening with fail2ban
  - UFW firewall configuration
  - Log2ram installation to reduce SD card wear
  - System monitoring and health checks
  - Project directory structure creation

```bash
# Run on fresh Raspberry Pi OS Lite installation
sudo ./setup-raspberry-pi.sh

# View help
sudo ./setup-raspberry-pi.sh --help
```

**Requirements**: Fresh Raspberry Pi OS Lite, Internet connection, root access

---

#### `hardware-test.sh`
**Hardware validation and testing script**

- **Purpose**: Comprehensive hardware functionality testing
- **Features**:
  - GPIO pin testing (all Plant Wall Control pins)
  - I2C device detection and communication
  - SPI interface validation (MCP3008 ADC)
  - PWM functionality testing for LED control
  - Sensor pin configuration testing
  - System resource monitoring
  - Network connectivity validation
  - Detailed hardware report generation

```bash
# Run comprehensive hardware test
sudo ./hardware-test.sh

# View test reports
cat /var/log/plant-wall-control/hardware-test-summary.txt
```

**Outputs**: 
- Summary report: `/var/log/plant-wall-control/hardware-test-summary.txt`
- Detailed log: `/var/log/plant-wall-control/hardware-test-[timestamp].log`

---

### 💾 Backup & Recovery

#### `backup-create.sh`
**Comprehensive system backup creation**

- **Purpose**: Create complete system backups for disaster recovery
- **Features**:
  - System configuration backup (boot, network, SSH, services)
  - Application files and configuration backup
  - Data and logs backup with retention management
  - SD card image creation (full system recovery)
  - Backup compression and cleanup
  - Backup manifest generation

```bash
# Create full system backup
sudo ./backup-create.sh

# Create backup without compression prompt
sudo ./backup-create.sh --no-compress

# View backup information
cat /opt/plant-wall-backups/[timestamp]/backup-manifest.txt
```

**Backup Contents**:
- `/opt/plant-wall-backups/[timestamp]/system/` - System configuration
- `/opt/plant-wall-backups/[timestamp]/application/` - Plant Wall Control app
- `/opt/plant-wall-backups/[timestamp]/data/` - Application data
- `/opt/plant-wall-backups/[timestamp]/logs/` - System and application logs
- `/opt/plant-wall-backups/[timestamp]/sd-image/` - SD card image

---

#### `backup-restore.sh`
**System restoration from backups**

- **Purpose**: Restore system components from backup archives
- **Features**:
  - Selective restoration (system, application, data, logs)
  - Automatic pre-restore backup creation
  - Dry-run mode for safe testing
  - Service management during restoration
  - Restoration verification

```bash
# List available backups
sudo ./backup-restore.sh --list

# Restore everything from latest backup
sudo ./backup-restore.sh --all --latest

# Restore specific backup
sudo ./backup-restore.sh --all --restore-from /opt/plant-wall-backups/20231215-143022

# Restore only application (safest option)
sudo ./backup-restore.sh --application --restore-from /path/to/backup

# Dry run to see what would be restored
sudo ./backup-restore.sh --all --latest --dry-run
```

**Restoration Types**:
- `--system`: Systemd services, udev rules, system configuration
- `--application`: Plant Wall Control binary and configuration
- `--data`: Application data and databases
- `--logs`: Application and system logs
- `--all`: Complete restoration

---

## Configuration Files

### Production Configuration
**`../config/hardware-production.yaml`**

Complete hardware configuration for production deployment:
- Real GPIO pin mappings for Pi Zero 2W
- I2C/SPI device addresses and settings
- Sensor calibration values and safety limits
- Watering system configuration and schedules
- Lighting control with automatic scheduling
- Safety monitoring and emergency procedures
- Network and logging configuration

### Development Configuration
**`../config/hardware-development.yaml`**

Mock hardware configuration for development:
- Simulated hardware for development without physical components
- Accelerated timing for faster testing
- Enhanced debugging and logging
- Test scenarios and mock data generation
- Development-friendly API settings

---

## Usage Workflows

### 🆕 Fresh Raspberry Pi Setup

1. **Flash Raspberry Pi OS Lite** to SD card
2. **Enable SSH** (create empty `ssh` file in boot partition)
3. **Configure WiFi** (optional: create `wpa_supplicant.conf`)
4. **Boot Pi and connect via SSH**
5. **Run setup script**:
   ```bash
   # Copy script to Pi
   scp setup-raspberry-pi.sh pi@raspberrypi.local:~/
   
   # Run setup
   ssh pi@raspberrypi.local
   sudo ./setup-raspberry-pi.sh
   
   # Reboot for optimization to take effect
   sudo reboot
   ```

### 🔧 Hardware Validation

After setup completion:
```bash
# Test all hardware components
sudo ./hardware-test.sh

# Review test results
cat /var/log/plant-wall-control/hardware-test-summary.txt
```

### 📦 Application Deployment

After hardware validation:
```bash
# Build application for ARM64
cd /path/to/source
GOOS=linux GOARCH=arm64 go build -o plant-wall-control

# Copy to Pi and install
scp plant-wall-control config.yaml pi@raspberrypi.local:~/
ssh pi@raspberrypi.local
sudo ./systemd/install-service.sh
```

### 💾 Regular Backups

Set up automated backups:
```bash
# Create initial backup
sudo ./backup-create.sh

# Schedule weekly backups
sudo crontab -e
# Add: 0 2 * * 0 /opt/plant-wall-control/scripts/backup-create.sh --no-compress
```

### 🔄 Disaster Recovery

Complete system recovery:
```bash
# Option 1: Restore from backup
sudo ./backup-restore.sh --all --latest

# Option 2: Flash SD image (complete hardware failure)
sudo dd if=/opt/plant-wall-backups/[timestamp]/sd-image/backup.img of=/dev/sdX bs=1M status=progress
```

---

## Security Considerations

### 🔒 SSH Security
- Default SSH port can be changed in setup script
- Public key authentication recommended
- Fail2ban configured for brute force protection
- UFW firewall with minimal open ports

### 🛡️ System Hardening
- Unnecessary services disabled
- GPIO permissions properly configured
- User isolation (plantwall service user)
- Log rotation and monitoring

### 🔐 Network Security
- WiFi power saving disabled for reliability
- CORS properly configured for web interface
- Rate limiting on API endpoints
- VPN recommended for remote access

---

## Troubleshooting

### Common Issues

**🚨 Permission Denied Errors**
```bash
# Fix GPIO permissions
sudo udevadm control --reload-rules
sudo udevadm trigger

# Check user groups
groups plantwall
```

**🚨 Service Won't Start**
```bash
# Check service status
systemctl status plant-wall-control

# View logs
journalctl -u plant-wall-control -f

# Test binary directly
sudo -u plantwall /opt/plant-wall-control/plant-wall-control
```

**🚨 Hardware Not Detected**
```bash
# Re-run hardware test
sudo ./hardware-test.sh

# Check interface enablement
sudo raspi-config nonint get_i2c  # Should return 0
sudo raspi-config nonint get_spi  # Should return 0
```

**🚨 High Memory Usage**
```bash
# Check for memory leaks
sudo ps aux --sort=-%mem | head -10

# Restart service
sudo systemctl restart plant-wall-control

# Check system optimization
free -h
cat /proc/sys/vm/swappiness  # Should be 1
```

### Log Locations

- **Application Logs**: `/var/log/plant-wall-control/`
- **System Logs**: `journalctl -u plant-wall-control`
- **Hardware Test Reports**: `/var/log/plant-wall-control/hardware-test-*.log`
- **Backup Logs**: `/var/log/plant-wall-restore-*.log`

### Support Commands

```bash
# System information
sudo ./scripts/hardware-test.sh --help
cat /proc/device-tree/model
vcgencmd measure_temp

# Network diagnostics
ip addr show
iwconfig
ping -c 1 8.8.8.8

# Service diagnostics
systemctl list-units --type=service --state=failed
systemctl status plant-wall-control
```

---

## Script Maintenance

### Updating Scripts
Scripts are version-controlled and include version numbers. Update procedures:

1. **Backup current scripts**
2. **Test new versions in development**
3. **Deploy during maintenance window**
4. **Verify functionality with hardware tests**

### Adding New Features
When adding new hardware or features:

1. **Update hardware configuration files**
2. **Modify hardware-test.sh for new components**
3. **Update backup scripts for new data locations**
4. **Test complete workflow**

---

## File Permissions

All scripts require specific permissions:
```bash
# Script permissions (executable)
chmod +x scripts/*.sh

# Configuration permissions (readable)
chmod 644 config/*.yaml

# Service user permissions
chown -R plantwall:plantwall /opt/plant-wall-control/
```

---

## Integration with Plant Wall System

These scripts integrate with the main Plant Wall Control system:

- **Hardware abstraction layer** uses configuration from `config/` files
- **Systemd service** manages application lifecycle
- **Monitoring scripts** provide health checks and alerting
- **Backup system** ensures data persistence and recovery
- **Development workflow** supports both mock and real hardware modes

For complete system documentation, see the main project README and documentation in `/docs/`.