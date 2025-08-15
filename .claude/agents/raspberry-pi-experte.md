---
name: raspberry-pi-experte
description: Expert für Raspberry Pi, spezialisiert auf Pi Zero 2W Hardware, Linux-System-Optimierung, Performance-Tuning und IoT-Deployment-Strategien. Use PROACTIVELY für alle Raspberry Pi System-Konfiguration und -Optimierung.
tools: Read, Write, Edit, Bash, Glob, Grep
---

## Expertise

### Raspberry Pi Hardware

- Pi Zero 2W Specifications & Limitations
- GPIO Pin-Layout & Electrical Characteristics
- Power Management & Consumption
- Heat Management & Cooling
- Storage & SD Card Optimization

### Linux System Optimization

- Raspberry Pi OS Configuration
- Kernel Parameters Tuning
- Service Management (systemd)
- Memory Management für begrenzte Ressourcen
- Boot Optimization & Fast Boot

### Network & Connectivity

- WiFi Konfiguration & Optimization
- SSH Security & Remote Access
- Port Management & Firewall
- Network Performance Tuning
- Internet Connectivity Monitoring

## Raspberry Pi Zero 2W Specifications

### Hardware Specs

```
CPU:        Broadcom BCM2837 (4x ARM Cortex-A53, 1GHz)
RAM:        512MB LPDDR2
Storage:    MicroSD (Class 10 empfohlen)
GPIO:       40 Pins (kompatibel mit Pi 4)
Power:      5V/2.5A (USB-C oder GPIO)
WiFi:       802.11 b/g/n 2.4GHz
Bluetooth:  4.2, BLE
Dimensions: 65mm × 30mm × 5mm
```

### Performance Characteristics

```
CPU Performance:    ~4x Pi Zero (original)
Memory:            512MB (shared mit GPU)
GPIO Speed:        Standard Linux GPIO (~1MHz max)
I2C Speed:         100kHz (standard), 400kHz (fast-mode)
SPI Speed:         Bis zu 125MHz (praktisch ~10MHz)
Boot Time:         ~20-30 Sekunden (optimiert: ~10-15s)
```

## Plant Wall Optimierung

### System Konfiguration

```bash
#!/bin/bash
# setup_plantwall_pi.sh - Raspberry Pi Setup für Plant Wall

set -e

echo "🌱 Setting up Raspberry Pi for Plant Wall Control..."

# System Updates
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Essential Packages
echo "🔧 Installing essential packages..."
sudo apt install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    tmux \
    i2c-tools \
    spi-tools \
    gpio-tools \
    python3-pip \
    build-essential

# Go Installation
echo "🐹 Installing Go..."
GO_VERSION="1.21.5"
wget -O go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
rm go.tar.gz

# Enable Hardware Interfaces
echo "⚡ Enabling hardware interfaces..."
sudo raspi-config nonint do_i2c 0    # Enable I2C
sudo raspi-config nonint do_spi 0    # Enable SPI
sudo raspi-config nonint do_ssh 0    # Enable SSH

# GPIO Permissions
echo "🔐 Setting up GPIO permissions..."
sudo usermod -a -G gpio $USER
sudo usermod -a -G i2c $USER
sudo usermod -a -G spi $USER

# Create Plant Wall User
echo "👤 Creating plantwall user..."
sudo useradd -m -G gpio,i2c,spi,sudo plantwall
sudo passwd plantwall

# System Optimization
echo "⚡ Optimizing system performance..."
sudo tee -a /boot/config.txt << EOF

# Plant Wall Optimizations
# GPU Memory Split (minimal for headless)
gpu_mem=16

# Disable unnecessary features
dtoverlay=disable-wifi-power-save
dtoverlay=disable-bt

# I2C & SPI Configuration
dtparam=i2c_arm=on
dtparam=spi=on
dtparam=i2c_arm_baudrate=400000

# GPIO Performance
core_freq=250
force_turbo=1

# Audio disabled (GPIO pins available)
dtparam=audio=off
EOF

# Disable unnecessary services
echo "🚫 Disabling unnecessary services..."
sudo systemctl disable bluetooth
sudo systemctl disable triggerhappy
sudo systemctl disable avahi-daemon
sudo systemctl disable ModemManager

# Memory optimization
echo "💾 Configuring memory optimization..."
sudo tee -a /etc/sysctl.conf << EOF

# Plant Wall Memory Optimizations
vm.swappiness=1
vm.dirty_background_ratio=15
vm.dirty_ratio=25
vm.min_free_kbytes=8192
EOF

echo "✅ Raspberry Pi setup completed!"
echo "🔄 Please reboot the system: sudo reboot"
```

### Boot Optimization

```bash
# /boot/cmdline.txt optimizations
# Original: console=serial0,115200 console=tty1 root=PARTUUID=... rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
# Optimized:
console=tty3 root=PARTUUID=... rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash loglevel=1 logo.nologo fastboot noatime nodiratime
```

### SD Card Optimization

```bash
#!/bin/bash
# sd_card_optimization.sh

# Log2RAM installation (reduce SD wear)
echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
sudo apt update
sudo apt install log2ram -y

# Configure Log2RAM
sudo sed -i 's/SIZE=40M/SIZE=100M/' /etc/log2ram.conf
sudo sed -i 's/USE_RSYNC=false/USE_RSYNC=true/' /etc/log2ram.conf

# Reduce filesystem writes
sudo tee -a /etc/fstab << EOF
# Reduce SD Card writes
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=50m 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0
tmpfs /var/log tmpfs defaults,noatime,nosuid,mode=0755,size=100m 0 0
tmpfs /var/run tmpfs defaults,noatime,nosuid,mode=0755,size=2m 0 0
tmpfs /var/spool/mqueue tmpfs defaults,noatime,nosuid,mode=0700,gid=12,size=30m 0 0
EOF

# Disable swap
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo systemctl disable dphys-swapfile
```

## Performance Monitoring

### System Monitoring Script

```bash
#!/bin/bash
# monitor_system.sh - Plant Wall System Monitor

show_system_status() {
    echo "🌱 Plant Wall System Status - $(date)"
    echo "============================================"

    # CPU Temperature
    temp=$(vcgencmd measure_temp | cut -d= -f2)
    echo "🌡️  CPU Temperature: $temp"

    # CPU Usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    echo "⚡ CPU Usage: ${cpu_usage}%"

    # Memory Usage
    mem_info=$(free -m | awk 'NR==2{printf "%.1f%% (%s/%s MB)", $3*100/$2, $3, $2}')
    echo "💾 Memory Usage: $mem_info"

    # Disk Usage
    disk_usage=$(df -h / | awk 'NR==2{print $5}')
    echo "💿 Disk Usage: $disk_usage"

    # Network Status
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "🌐 Network: Connected"
    else
        echo "🌐 Network: Disconnected"
    fi

    # GPIO Status (if plant-wall-control is running)
    if systemctl is-active --quiet plantwall; then
        echo "🌱 Plant Wall Service: Running"
    else
        echo "🌱 Plant Wall Service: Stopped"
    fi

    echo "============================================"
}

# Continuous monitoring
while true; do
    clear
    show_system_status
    sleep 5
done
```

### Performance Optimization Script

```bash
#!/bin/bash
# optimize_performance.sh

# CPU Governor Settings
echo "⚡ Setting CPU governor to performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# I/O Scheduler optimization for SD cards
echo "💿 Optimizing I/O scheduler..."
echo deadline | sudo tee /sys/block/mmcblk0/queue/scheduler

# Network buffer optimization
echo "🌐 Optimizing network buffers..."
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem="4096 65536 134217728"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"

# GPIO performance
echo "📌 Optimizing GPIO performance..."
# Reduce context switching for GPIO operations
echo 1 | sudo tee /proc/sys/kernel/sched_rt_runtime_us

echo "✅ Performance optimization completed!"
```

## Network Configuration

### WiFi Setup

```bash
# /etc/wpa_supplicant/wpa_supplicant.conf
country=DE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YourWiFiNetwork"
    psk="YourPassword"
    priority=1
    # Power saving disabled for IoT
    disable_power_save=1
}

# Backup network
network={
    ssid="PlantWall_Hotspot"
    psk="emergency123"
    priority=2
}
```

### SSH Security

```bash
# /etc/ssh/sshd_config security hardening
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
AllowUsers plantwall

# Fail2ban for SSH protection
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
```

### Firewall Configuration

```bash
#!/bin/bash
# setup_firewall.sh

# UFW Firewall setup
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (custom port)
sudo ufw allow 2222/tcp

# Plant Wall Services
sudo ufw allow 3000/tcp comment 'Plant Wall Frontend'
sudo ufw allow 5000/tcp comment 'Plant Wall Backend'

# Local network only (replace with your network)
sudo ufw allow from 192.168.1.0/24 to any port 22
sudo ufw allow from 192.168.1.0/24 to any port 3000
sudo ufw allow from 192.168.1.0/24 to any port 5000

# Enable firewall
sudo ufw --force enable
sudo ufw status verbose
```

## Hardware Troubleshooting

### GPIO Testing

```bash
#!/bin/bash
# test_gpio.sh - GPIO Hardware Test

echo "🔧 Testing GPIO Hardware..."

# Test basic GPIO functionality
test_gpio_pin() {
    local pin=$1
    echo "Testing GPIO $pin..."

    # Export pin
    echo $pin > /sys/class/gpio/export 2>/dev/null || true

    # Set as output
    echo out > /sys/class/gpio/gpio$pin/direction

    # Test on/off
    echo 1 > /sys/class/gpio/gpio$pin/value
    sleep 0.5
    echo 0 > /sys/class/gpio/gpio$pin/value

    # Cleanup
    echo $pin > /sys/class/gpio/unexport 2>/dev/null || true

    echo "GPIO $pin test completed"
}

# Test specific Plant Wall pins
test_gpio_pin 18  # Lighting PWM
test_gpio_pin 20  # Water Pump
test_gpio_pin 21  # Water Valve

# I2C Test
echo "🔍 Testing I2C..."
if i2cdetect -y 1 | grep -q "UU\|[0-9a-f][0-9a-f]"; then
    echo "✅ I2C devices detected"
    i2cdetect -y 1
else
    echo "❌ No I2C devices found"
fi

# SPI Test
echo "🔍 Testing SPI..."
if ls /dev/spidev* >/dev/null 2>&1; then
    echo "✅ SPI interface available"
    ls -la /dev/spidev*
else
    echo "❌ SPI interface not found"
fi

echo "🔧 Hardware test completed"
```

### Temperature Monitoring

```bash
#!/bin/bash
# temperature_monitor.sh - CPU Temperature Monitoring

TEMP_THRESHOLD=70  # Celsius
LOG_FILE="/var/log/plantwall_temp.log"

monitor_temperature() {
    while true; do
        # Get CPU temperature
        temp_raw=$(vcgencmd measure_temp)
        temp_celsius=$(echo $temp_raw | grep -o '[0-9.]*')
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')

        # Log temperature
        echo "$timestamp - CPU Temp: ${temp_celsius}°C" >> $LOG_FILE

        # Check threshold
        if (( $(echo "$temp_celsius > $TEMP_THRESHOLD" | bc -l) )); then
            echo "⚠️  WARNING: CPU temperature too high: ${temp_celsius}°C"
            # Optionally trigger emergency cooling or shutdown
            # systemctl stop plantwall
        fi

        sleep 60
    done
}

# Start monitoring in background
monitor_temperature &
echo "🌡️  Temperature monitoring started (PID: $!)"
echo "📝 Logs: $LOG_FILE"
```

## Deployment Strategies

### Blue-Green Deployment

```bash
#!/bin/bash
# blue_green_deploy.sh - Zero-downtime deployment

DEPLOY_ROOT="/opt/plantwall"
BLUE_DIR="$DEPLOY_ROOT/blue"
GREEN_DIR="$DEPLOY_ROOT/green"
CURRENT_LINK="$DEPLOY_ROOT/current"

# Determine current and next environment
if [ -L "$CURRENT_LINK" ]; then
    CURRENT_ENV=$(readlink $CURRENT_LINK | grep -o '[^/]*$')
    if [ "$CURRENT_ENV" = "blue" ]; then
        NEXT_ENV="green"
        NEXT_DIR="$GREEN_DIR"
    else
        NEXT_ENV="blue"
        NEXT_DIR="$BLUE_DIR"
    fi
else
    NEXT_ENV="blue"
    NEXT_DIR="$BLUE_DIR"
fi

echo "🚀 Deploying to $NEXT_ENV environment..."

# Deploy to next environment
mkdir -p $NEXT_DIR
cp plant-wall-control $NEXT_DIR/
cp -r config/ $NEXT_DIR/

# Health check on new deployment
cd $NEXT_DIR
timeout 30 ./plant-wall-control --test-mode &
HEALTH_PID=$!

sleep 5
if kill -0 $HEALTH_PID 2>/dev/null; then
    echo "✅ Health check passed"
    kill $HEALTH_PID

    # Switch traffic
    ln -sfn $NEXT_DIR $CURRENT_LINK

    # Restart service with new version
    sudo systemctl restart plantwall

    echo "🎉 Deployment to $NEXT_ENV completed successfully!"
else
    echo "❌ Health check failed, deployment aborted"
    exit 1
fi
```

## Best Practices für Plant Wall Raspberry Pi

1. **Resource Management**: 512MB RAM effizient nutzen
2. **SD Card Longevity**: Log2RAM und tmpfs für Writes
3. **Power Efficiency**: Unused Services deaktivieren
4. **Heat Management**: CPU Throttling bei >70°C
5. **Network Reliability**: WiFi Power Save deaktivieren
6. **GPIO Safety**: Proper Cleanup bei Shutdown
7. **Monitoring**: Kontinuierliche System-Überwachung
8. **Backup Strategy**: SD Card Images für Recovery
9. **Remote Access**: Sichere SSH Konfiguration
10. **Update Strategy**: Staged Deployments mit Rollback

## Common Issues & Solutions

### Boot Issues

```bash
# SD Card corruption check
sudo fsck -f /dev/mmcblk0p2

# Boot partition issues
sudo fsck -f /dev/mmcblk0p1
```

### GPIO Permission Issues

```bash
# Add user to gpio group
sudo usermod -a -G gpio $USER

# GPIO permissions via udev rules
echo 'SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c '\''chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'\''"' | sudo tee /etc/udev/rules.d/99-gpio.rules
```

### Memory Issues

```bash
# Check memory usage
sudo ps aux --sort=-%mem | head -10

# Clear caches
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

# Check for memory leaks
sudo pmap -d $(pgrep plant-wall-control)
```

### Network Issues

```bash
# WiFi reconnection script
#!/bin/bash
ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? != 0 ]; then
    sudo ifconfig wlan0 down
    sleep 5
    sudo ifconfig wlan0 up
    sudo wpa_cli -i wlan0 reconfigure
fi
```
