# Plant Wall Control System - Deployment Guide

**Production Deployment for Raspberry Pi Zero 2W IoT System**

This guide covers the complete deployment process for the Plant Wall Control System from development to production operation.

## 🚀 Deployment Overview

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│ Development     │    │ Production Pi    │    │ Plant Wall Hardware │
│ Environment     │────│ Zero 2W          │────│ Sensors & Actuators │
│ (Cross-compile) │    │ plant-wall-      │    │ 4 Plant Modules     │
└─────────────────┘    │ control service  │    └─────────────────────┘
                       └──────────────────┘
                              │
                       ┌──────────────────┐
                       │ Remote Monitoring│
                       │ & Management     │
                       │ (Web Interface)  │
                       └──────────────────┘
```

### Deployment Targets

- **Development**: Mock hardware, hot reload, debug logging
- **Staging**: Hardware simulation, integration testing
- **Production**: Full hardware control, optimized performance, monitoring

## 🛠️ Prerequisites

### Development Environment

```bash
# Required tools installation
# Go 1.21+ for cross-compilation
wget https://go.dev/dl/go1.21.8.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# SSH access to target Pi
ssh-copy-id pi@plantwall-001.local

# GitHub CLI (optional, for automated releases)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh
```

### Target Pi Preparation

```bash
# Ensure Pi is set up according to raspberry-pi-setup.md
# Verify hardware interfaces are enabled
sudo /opt/plant-wall-control/scripts/hardware-test.sh --quick

# Check system resources
free -h
df -h
```

## 📦 Build and Compilation

### Local Development Build

```bash
cd src/plant-wall-control

# Development build (current architecture)
make build

# Run with development config
./plant-wall-control --config=config/hardware-development.yaml
```

### Cross-Compilation for Pi Zero 2W

```bash
# ARM64 build (Pi Zero 2W)
make build-arm64

# ARM32 build (fallback for older Pi)
make build-arm32

# Build all architectures
make build-all

# Verify binary
file plant-wall-control-arm64
# Should show: ELF 64-bit LSB executable, ARM aarch64
```

### Docker-Based Compilation (Alternative)

```bash
# Build using Docker for consistent environment
make docker-build

# Multi-architecture build
docker buildx create --name plant-wall-builder
docker buildx use plant-wall-builder
docker buildx build --platform linux/arm64,linux/arm/v7 -t plant-wall-control:latest .
```

## 🎯 Deployment Strategies

### 1. Manual Deployment

```bash
# Build and copy manually
make build-arm64
scp plant-wall-control-arm64 pi@plantwall-001.local:/tmp/

# SSH to Pi and install
ssh pi@plantwall-001.local
sudo systemctl stop plant-wall-control
sudo cp /tmp/plant-wall-control-arm64 /opt/plant-wall-control/plant-wall-control
sudo chmod +x /opt/plant-wall-control/plant-wall-control
sudo systemctl start plant-wall-control
sudo systemctl status plant-wall-control
```

### 2. Automated Deployment Script

```bash
# Single command deployment
make deploy-pi

# Deploy to specific host
PI_HOST=192.168.1.100 make deploy-pi

# Deploy with configuration update
make deploy-full

# Deploy and run tests
make deploy-test
```

### 3. Blue-Green Deployment

```bash
# Deploy new version alongside current
make deploy-blue-green

# Automatically switches after health check
# Rollback available if issues detected
```

### 4. CI/CD Pipeline Deployment

```bash
# GitHub Actions deployment
# Triggered on tag push or main branch merge
git tag v1.0.0-rc1
git push origin v1.0.0-rc1

# Automatically builds, tests, and deploys
# Includes rollback on failure
```

## ⚙️ Configuration Management

### Environment-Specific Configs

```yaml
# config/hardware-production.yaml
server:
  host: "0.0.0.0"
  port: 5000
  read_timeout: 30s
  write_timeout: 30s
  
hardware:
  mock_mode: false
  gpio_pins:
    water_pump: 20
    led_pwm: 18
    status_leds: [5, 6, 13]
    
logging:
  level: "info"
  file: "/var/log/plant-wall-control/app.log"
  max_size: 50  # MB
  max_files: 5
  
monitoring:
  health_check_interval: "5m"
  metrics_enabled: true
  alert_webhook: "https://hooks.slack.com/..."
```

```yaml
# config/hardware-development.yaml
server:
  host: "127.0.0.1"
  port: 5000
  
hardware:
  mock_mode: true
  simulate_sensors: true
  
logging:
  level: "debug"
  file: "/tmp/plant-wall-control.log"
  
monitoring:
  health_check_interval: "30s"
  metrics_enabled: false
```

### Runtime Configuration

```bash
# Configuration validation
sudo /opt/plant-wall-control/plant-wall-control --validate-config

# Test with specific config
sudo /opt/plant-wall-control/plant-wall-control --config=/etc/plant-wall-control/config-test.yaml --dry-run

# Reload configuration (SIGHUP)
sudo systemctl reload plant-wall-control
```

## 🔒 Security Deployment

### SSL/TLS Configuration

```bash
# Generate self-signed certificate for local network
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/plant-wall-control/ssl/server.key \
  -out /etc/plant-wall-control/ssl/server.crt \
  -subj "/CN=plantwall-001.local"

# Update configuration
ssl:
  enabled: true
  cert_file: "/etc/plant-wall-control/ssl/server.crt"
  key_file: "/etc/plant-wall-control/ssl/server.key"
```

### Access Control

```yaml
# API authentication configuration
security:
  api_keys:
    - name: "admin"
      key: "pwc-admin-${RANDOM_TOKEN}"
      permissions: ["read", "write", "admin"]
    - name: "readonly"
      key: "pwc-readonly-${RANDOM_TOKEN}"
      permissions: ["read"]
      
  cors:
    allowed_origins: 
      - "https://plantwall-001.local:3000"
      - "https://192.168.1.0/24"
    allowed_methods: ["GET", "POST", "PUT", "DELETE"]
    allowed_headers: ["Content-Type", "Authorization"]
```

### Firewall Configuration

```bash
# Production firewall rules
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH access (change port if needed)
sudo ufw allow 22/tcp

# Plant Wall API (HTTPS only in production)
sudo ufw allow 5000/tcp

# NTP for time sync
sudo ufw allow 123/udp

# Enable firewall
sudo ufw --force enable
sudo ufw status verbose
```

## 📊 Monitoring and Logging

### System Monitoring Setup

```bash
# Install monitoring tools
sudo apt install -y prometheus-node-exporter htop iotop

# Configure log rotation
sudo tee /etc/logrotate.d/plant-wall-control <<EOF
/var/log/plant-wall-control/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    sharedscripts
    postrotate
        systemctl reload plant-wall-control
    endscript
}
EOF
```

### Health Monitoring

```yaml
# Health check configuration
monitoring:
  health_checks:
    - name: "api_response"
      url: "http://localhost:5000/api/health"
      timeout: "5s"
      interval: "30s"
      
    - name: "gpio_access"
      type: "gpio"
      pins: [18, 20, 21]
      interval: "5m"
      
    - name: "i2c_devices"
      type: "i2c"
      addresses: [0x29]  # TSL2591 light sensor
      interval: "5m"
      
    - name: "system_resources"
      type: "system"
      cpu_threshold: 80
      memory_threshold: 85
      disk_threshold: 90
      interval: "1m"
      
  alerts:
    webhook: "https://hooks.slack.com/services/..."
    email: "admin@plantwall.local"
    retry_count: 3
    cooldown: "10m"
```

### Log Analysis

```bash
# Real-time log monitoring
sudo journalctl -u plant-wall-control -f

# Service status and recent logs
sudo systemctl status plant-wall-control

# Hardware-specific logs
sudo journalctl -u plant-wall-control | grep -i gpio
sudo journalctl -u plant-wall-control | grep -i sensor

# Performance metrics
sudo journalctl -u plant-wall-control | grep -i "memory\|cpu\|temperature"
```

## 🔄 Update and Rollback Procedures

### Version Management

```bash
# Tag current version before deployment
git tag -a v1.2.1 -m "Production release v1.2.1 - Improved sensor calibration"
git push origin v1.2.1

# Track deployed versions
echo "v1.2.1" | sudo tee /opt/plant-wall-control/VERSION
echo "$(date -Iseconds)" | sudo tee /opt/plant-wall-control/DEPLOYED_AT
```

### Rolling Updates

```bash
# Automated rolling update with health checks
sudo /opt/plant-wall-control/systemd/deploy.sh --version=v1.2.1 --health-check

# Manual rolling update
sudo systemctl stop plant-wall-control
sudo cp /tmp/plant-wall-control-new /opt/plant-wall-control/plant-wall-control.new
sudo mv /opt/plant-wall-control/plant-wall-control /opt/plant-wall-control/plant-wall-control.backup
sudo mv /opt/plant-wall-control/plant-wall-control.new /opt/plant-wall-control/plant-wall-control
sudo systemctl start plant-wall-control

# Verify deployment
sudo systemctl is-active plant-wall-control
curl -f http://localhost:5000/api/health
```

### Emergency Rollback

```bash
# Quick rollback to previous version
sudo systemctl stop plant-wall-control
sudo mv /opt/plant-wall-control/plant-wall-control.backup /opt/plant-wall-control/plant-wall-control
sudo systemctl start plant-wall-control

# Full rollback with configuration
sudo /opt/plant-wall-control/scripts/backup-restore.sh --type=system --latest

# Verify rollback
sudo systemctl status plant-wall-control
curl http://localhost:5000/api/health
```

## 🏗️ Infrastructure as Code

### Ansible Playbook (Optional)

```yaml
# deploy-plant-wall.yml
---
- hosts: plant-wall-systems
  become: yes
  vars:
    app_version: "{{ version | default('latest') }}"
    config_env: "{{ env | default('production') }}"
    
  tasks:
    - name: Download application binary
      get_url:
        url: "https://github.com/andrekirst/plantwall/releases/download/{{ app_version }}/plant-wall-control-arm64"
        dest: "/tmp/plant-wall-control"
        mode: '0755'
        
    - name: Stop service
      systemd:
        name: plant-wall-control
        state: stopped
        
    - name: Backup current version
      copy:
        src: "/opt/plant-wall-control/plant-wall-control"
        dest: "/opt/plant-wall-control/plant-wall-control.backup"
        remote_src: yes
        
    - name: Install new version
      copy:
        src: "/tmp/plant-wall-control"
        dest: "/opt/plant-wall-control/plant-wall-control"
        remote_src: yes
        owner: root
        group: root
        mode: '0755'
        
    - name: Update configuration
      template:
        src: "config-{{ config_env }}.yaml.j2"
        dest: "/etc/plant-wall-control/config.yaml"
        owner: plantwall
        group: plantwall
        mode: '0644'
        
    - name: Start service
      systemd:
        name: plant-wall-control
        state: started
        enabled: yes
        
    - name: Wait for service to be ready
      uri:
        url: "http://localhost:5000/api/health"
        method: GET
        timeout: 30
      retries: 5
      delay: 10
```

### Docker Deployment (Alternative)

```dockerfile
# Dockerfile.production
FROM scratch
COPY plant-wall-control-arm64 /plant-wall-control
COPY config/hardware-production.yaml /config/config.yaml
EXPOSE 5000
ENTRYPOINT ["/plant-wall-control", "--config=/config/config.yaml"]
```

```yaml
# docker-compose.yml for Pi
version: '3.8'
services:
  plant-wall-control:
    image: plant-wall-control:latest
    container_name: plant-wall-control
    restart: unless-stopped
    privileged: true  # Required for GPIO access
    network_mode: host
    volumes:
      - /dev/gpiomem:/dev/gpiomem
      - /dev/i2c-1:/dev/i2c-1
      - /dev/spidev0.0:/dev/spidev0.0
      - ./config:/etc/plant-wall-control:ro
      - ./logs:/var/log/plant-wall-control
    environment:
      - CONFIG_FILE=/etc/plant-wall-control/config.yaml
```

## 🧪 Testing in Production

### Smoke Tests

```bash
# Post-deployment verification
sudo /opt/plant-wall-control/systemd/test-installation.sh --production

# API endpoint tests
curl -f http://localhost:5000/api/health
curl -f http://localhost:5000/api/status
curl -f http://localhost:5000/api/sensors

# Hardware functionality tests
sudo /opt/plant-wall-control/scripts/hardware-test.sh --quick
```

### Load Testing

```bash
# API load test
apt install apache2-utils
ab -n 1000 -c 10 http://localhost:5000/api/status

# Memory usage under load
sudo systemctl status plant-wall-control
htop

# GPIO performance test
sudo /opt/plant-wall-control/scripts/hardware-test.sh --performance
```

### Integration Tests

```bash
# End-to-end hardware test
sudo /opt/plant-wall-control/scripts/hardware-test.sh --full

# Simulated operation cycle
curl -X POST http://localhost:5000/api/watering/test
curl -X POST http://localhost:5000/api/lighting/test

# Long-running stability test
sudo /opt/plant-wall-control/scripts/hardware-test.sh --stability --duration=1h
```

## 📋 Deployment Checklist

### Pre-Deployment

- [ ] Build tested and validated on development environment
- [ ] Configuration updated for production environment
- [ ] Hardware test suite passes completely
- [ ] Backup of current system created
- [ ] Monitoring and alerting configured
- [ ] SSL certificates valid and deployed
- [ ] Firewall rules updated and tested

### During Deployment

- [ ] Service stopped gracefully (no active watering cycles)
- [ ] New binary deployed and verified
- [ ] Configuration files updated
- [ ] Service started successfully
- [ ] Health checks pass
- [ ] API endpoints responding correctly
- [ ] Hardware functionality verified

### Post-Deployment

- [ ] System monitoring active and reporting
- [ ] Log files being written correctly
- [ ] Performance metrics within acceptable range
- [ ] User interface accessible and functional
- [ ] Automated tasks (scheduling) working
- [ ] Backup procedures tested
- [ ] Rollback procedure documented and tested

## 🚨 Troubleshooting Deployment Issues

### Common Problems

#### Service Won't Start

```bash
# Check service status and logs
sudo systemctl status plant-wall-control
sudo journalctl -u plant-wall-control -n 50

# Common causes:
# - Binary not executable: sudo chmod +x /opt/plant-wall-control/plant-wall-control
# - Config file missing: ls -la /etc/plant-wall-control/
# - GPIO permissions: groups plantwall | grep gpio
# - Port already in use: sudo netstat -tlnp | grep 5000
```

#### GPIO Access Denied

```bash
# Fix GPIO permissions
sudo usermod -a -G gpio plantwall
sudo chown root:gpio /dev/gpiomem
sudo chmod g+rw /dev/gpiomem

# Restart service
sudo systemctl restart plant-wall-control
```

#### High Memory Usage

```bash
# Monitor memory usage
free -h
sudo systemctl status plant-wall-control

# Reduce memory usage:
# - Enable hardware mock mode temporarily
# - Reduce log retention
# - Check for memory leaks in application logs
```

#### Network Connectivity Issues

```bash
# Check network configuration
ip addr show
ping -c 4 google.com

# Verify firewall rules
sudo ufw status verbose

# Test API accessibility
curl -v http://localhost:5000/api/health
curl -v http://$(hostname -I | cut -d' ' -f1):5000/api/health
```

---

**Plant Wall Control System Deployment Guide**

*This guide covers production deployment for IoT systems on Raspberry Pi platforms. For development and testing procedures, refer to the hardware integration guide.*