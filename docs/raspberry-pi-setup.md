# Raspberry Pi Zero 2W Hardware Setup Guide

**Plant Wall Control System - Foundation Setup**

This guide covers the complete setup process for the Raspberry Pi Zero 2W hardware platform that will control the automated plant wall system.

## 📋 Hardware Requirements

### Essential Components

| Component | Specification | Purpose |
|-----------|---------------|---------|
| **Raspberry Pi Zero 2W** | ARM Cortex-A53 64-bit, 512MB RAM | Main control unit |
| **MicroSD Card** | 32GB Industrial Grade, Class 10+ | OS and data storage |
| **Power Supply** | 5V/2.5A USB-C with GPIO capability | System power |
| **Case** | IP65-rated enclosure | Weather protection |
| **Heat Sink** | Aluminum with thermal pad | Temperature management |

### MVP Prototype Hardware (4 Plant Modules)

| Hardware Module | Component | GPIO Connection |
|-----------------|-----------|-----------------|
| **Sensors** | 4x Capacitive Soil Moisture | MCP3008 ADC (SPI) |
| | TSL2591 Light Sensor | I2C (GPIO 2/3) |
| | DHT22 Temp/Humidity | GPIO 4 |
| | pH/EC Sensor | MCP3008 ADC (SPI) |
| **Actuators** | 12V Water Pump | GPIO 20 (Relay) |
| | 4x 5V Water Valves | GPIO 21-24 (Transistor) |
| | 24V LED Strip (PWM) | GPIO 18 (Hardware PWM) |
| **Display** | Status RGB LEDs | GPIO 5, 6, 13 |
| | Optional OLED Display | I2C (GPIO 2/3) |

## 🚀 Quick Start Installation

### Option 1: Automated Setup (Recommended)

```bash
# 1. Flash Raspbian OS Lite to SD card
# 2. Boot Pi and enable SSH
# 3. Copy repository to Pi
git clone https://github.com/andrekirst/plantwall.git
cd plantwall/src/plant-wall-control

# 4. Run master setup script
sudo ./scripts/setup-raspberry-pi.sh

# 5. Deploy application
sudo ./systemd/install-service.sh

# 6. Validate hardware
sudo ./scripts/hardware-test.sh
```

### Option 2: Manual Setup

Follow the detailed steps in the sections below.

## 🔧 Detailed Setup Process

### Step 1: OS Installation and Initial Setup

#### 1.1 Flash Raspbian OS Lite

```bash
# Download Raspbian OS Lite (latest)
# Flash to 32GB Industrial MicroSD card using Raspberry Pi Imager

# Enable SSH and WiFi during imaging:
# - Enable SSH with public key authentication
# - Configure WiFi credentials
# - Set hostname: plantwall-001
```

#### 1.2 First Boot Configuration

```bash
# SSH into the Pi
ssh pi@plantwall-001.local

# Update system
sudo apt update && sudo apt full-upgrade -y

# Configure timezone and locale
sudo raspi-config nonint do_change_timezone Europe/Berlin
sudo raspi-config nonint do_change_locale de_DE.UTF-8

# Expand filesystem
sudo raspi-config nonint do_expand_rootfs
```

### Step 2: Hardware Interface Setup

#### 2.1 Enable Hardware Interfaces

```bash
# Enable GPIO, I2C, SPI interfaces
sudo raspi-config nonint do_i2c 0        # Enable I2C
sudo raspi-config nonint do_spi 0        # Enable SPI
sudo raspi-config nonint do_ssh 0        # Enable SSH
sudo raspi-config nonint do_camera 1     # Disable camera (save resources)

# Configure GPU memory split for headless operation
echo "gpu_mem=16" | sudo tee -a /boot/config.txt

# Enable hardware PWM on GPIO 18
echo "dtoverlay=pwm,pin=18,func=2" | sudo tee -a /boot/config.txt
```

#### 2.2 Install Required Packages

```bash
# System packages
sudo apt install -y \
    git curl wget \
    i2c-tools spi-tools \
    build-essential \
    htop iotop \
    fail2ban ufw \
    logrotate \
    python3-pip

# Install log2ram for SD card longevity
wget -O log2ram.deb https://github.com/azlux/log2ram/releases/latest/download/log2ram_1.6.1_all.deb
sudo dpkg -i log2ram.deb
sudo systemctl enable log2ram
```

### Step 3: Go Runtime Installation

#### 3.1 Install Go 1.21+

```bash
# Download and install Go for ARM64
wget https://go.dev/dl/go1.21.8.linux-arm64.tar.gz
sudo tar -C /usr/local -xzf go1.21.8.linux-arm64.tar.gz
rm go1.21.8.linux-arm64.tar.gz

# Configure Go environment
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
echo 'export GOPATH=$HOME/go' | sudo tee -a /etc/profile
source /etc/profile

# Verify installation
go version
```

### Step 4: Security Configuration

#### 4.1 SSH Hardening

```bash
# Configure SSH security
sudo tee -a /etc/ssh/sshd_config <<EOF
# Plant Wall Control Security Config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port 22
Protocol 2
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

# Restart SSH service
sudo systemctl restart ssh
```

#### 4.2 Firewall Setup

```bash
# Configure UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 5000/tcp comment "Plant Wall API"
sudo ufw --force enable

# Configure fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Step 5: Performance Optimization

#### 5.1 Memory and CPU Optimization

```bash
# Configure swapfile for Pi Zero 2W (512MB RAM)
sudo dphys-swapfile swapoff
echo "CONF_SWAPSIZE=512" | sudo tee /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable avahi-daemon
sudo systemctl disable triggerhappy

# Configure tmpfs for temporary files
echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,size=50m 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=10m 0 0" | sudo tee -a /etc/fstab
```

#### 5.2 SD Card Longevity

```bash
# Configure log2ram
sudo tee /etc/log2ram.conf <<EOF
SIZE=50M
USE_RSYNC=true
MAIL=false
PATH_DISK=/var/log
ZL2R=true
COMP_ALG=lz4
LOG_DISK_SIZE=100M
EOF

# Reduce write operations
echo "vm.dirty_background_ratio = 20" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_expire_centisecs = 0" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_ratio = 80" | sudo tee -a /etc/sysctl.conf
echo "vm.dirty_writeback_centisecs = 0" | sudo tee -a /etc/sysctl.conf
```

### Step 6: Application Deployment

#### 6.1 Deploy Plant Wall Control Service

```bash
# Clone repository
git clone https://github.com/andrekirst/plantwall.git
cd plantwall/src/plant-wall-control

# Build application
go mod tidy
go build -o plant-wall-control

# Install service
sudo ./systemd/install-service.sh

# Verify service status
sudo systemctl status plant-wall-control
```

#### 6.2 Hardware Validation

```bash
# Run hardware test suite
sudo ./scripts/hardware-test.sh

# Expected output:
# ✅ GPIO interfaces available
# ✅ I2C bus functional (bus 1)
# ✅ SPI interface ready
# ✅ Hardware PWM on GPIO 18
# ✅ System resources within limits
```

## 🔌 Hardware Connection Guide

### GPIO Pin Mapping (Raspberry Pi Zero 2W)

```
┌─────────────────────────────────────┐
│  Raspberry Pi Zero 2W GPIO Layout  │
│  ┌─────────────────────────────────┐│
│  │3V3  5V │ GPIO02 5V │ GPIO03 GND ││ <- I2C (Light sensor, Display)
│  │GPIO04 GND│ GPIO14 GPIO15│GPIO18 ││ <- DHT22, Hardware PWM (LEDs)
│  │GND GPIO24│ GPIO10 GPIO09│GPIO25 ││ <- SPI (MCP3008), Valves
│  │GPIO08 GPIO07│ ID_SD ID_SC│GND   ││ <- SPI CS pins
│  │GPIO12 GND│ GPIO16 GPIO20│GPIO21 ││ <- Pump relay, Valves
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘

Pin Assignment for Plant Wall MVP:
- GPIO 18: PWM LED Strip Control (Hardware PWM)
- GPIO 20: Water Pump Relay (12V)
- GPIO 21-24: Water Valves (5V, 4 modules)
- GPIO 2/3: I2C Bus (TSL2591 light sensor, OLED display)
- GPIO 4: DHT22 Temperature/Humidity
- GPIO 8-11: SPI (MCP3008 ADC for soil moisture, pH/EC)
- GPIO 5,6,13: Status LEDs (RGB indicators)
```

### Hardware Module Connections

#### Power Distribution
```
5V USB-C Input
├── 3.3V LDO (AMS1117) -> Sensors & Pi
├── 5V Rail -> Valves & Logic
├── 12V Step-Up (MT3608) -> Water Pump
└── 24V Step-Up (XL6009) -> LED Strips
```

#### Sensor Connections
```
MCP3008 ADC (SPI):
- VCC/VDD: 3.3V
- VSS/AGND: GND
- CLK: GPIO 11 (SPI0_SCLK)
- DOUT: GPIO 9 (SPI0_MISO)
- DIN: GPIO 10 (SPI0_MOSI)
- CS/SHDN: GPIO 8 (SPI0_CE0)

Channel Assignment:
- CH0: Soil Moisture Module 1
- CH1: Soil Moisture Module 2
- CH2: Soil Moisture Module 3
- CH3: Soil Moisture Module 4
- CH4: pH Sensor
- CH5: EC Sensor
- CH6-7: Reserved for expansion
```

## 🔍 Troubleshooting

### Common Issues

#### GPIO Permission Denied
```bash
# Add user to gpio group
sudo usermod -a -G gpio,i2c,spi $USER
# Logout and login again

# Check group membership
groups $USER
```

#### I2C/SPI Not Working
```bash
# Check interface status
sudo raspi-config nonint get_i2c  # Should return 0
sudo raspi-config nonint get_spi  # Should return 0

# Scan I2C devices
i2cdetect -y 1

# Test SPI
ls /dev/spi*  # Should show /dev/spidev0.0 and /dev/spidev0.1
```

#### Service Won't Start
```bash
# Check service logs
sudo journalctl -u plant-wall-control -f

# Check configuration file
sudo /opt/plant-wall-control/plant-wall-control --test-config

# Verify hardware access
sudo /opt/plant-wall-control/scripts/hardware-test.sh --verbose
```

#### High Memory Usage
```bash
# Monitor memory usage
free -h
htop

# Check for memory leaks
sudo journalctl -u plant-wall-control | grep "memory"

# Restart service if needed
sudo systemctl restart plant-wall-control
```

### Recovery Procedures

#### SD Card Corruption
```bash
# Boot from backup SD card
# Run file system check
sudo fsck /dev/mmcblk0p2

# Restore from backup
sudo ./scripts/backup-restore.sh --type=system
```

#### Factory Reset
```bash
# Flash fresh Raspbian OS
# Run complete setup again
sudo ./scripts/setup-raspberry-pi.sh --factory-reset
```

## 📊 Performance Monitoring

### System Health Checks

```bash
# CPU and memory usage
htop

# Temperature monitoring
vcgencmd measure_temp

# Network connectivity
ping -c 4 google.com

# Service health
sudo systemctl status plant-wall-control

# Hardware functionality
sudo /opt/plant-wall-control/scripts/hardware-test.sh --quick
```

### Automated Monitoring

The system includes automated health monitoring that runs every 5 minutes:
- API endpoint availability
- System resource usage
- Hardware interface functionality
- Log file size management
- Automatic service restart on failure

## 📚 Additional Resources

- [Raspberry Pi GPIO Pinout](https://pinout.xyz/)
- [periph.io Documentation](https://periph.io/)
- [Go Cross Compilation](https://golang.org/doc/install/source#environment)
- [systemd Service Configuration](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

## 🔒 Security Considerations

- **SSH Key-Only Access**: Password authentication disabled
- **Firewall Rules**: Only necessary ports exposed
- **Service Isolation**: Dedicated user account with minimal privileges
- **GPIO Access**: Proper group membership without sudo requirements
- **Log Management**: Automated log rotation and size limits
- **Update Policy**: Regular security updates with controlled reboots

## 📋 Maintenance Schedule

### Daily (Automated)
- Health checks and service monitoring
- Log rotation and cleanup
- Temperature monitoring

### Weekly (Automated)
- System backup creation
- Security update checks
- Hardware validation tests

### Monthly (Manual)
- Full system update and reboot
- Physical inspection of connections
- SD card health check
- Performance optimization review

---

**Created for Plant Wall Control System MVP - Raspberry Pi Zero 2W Platform**

*For additional support and updates, see the main project repository.*