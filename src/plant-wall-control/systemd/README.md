# Plant Wall Control Systemd Service

This directory contains systemd service configuration and deployment scripts for the Plant Wall Control backend service, optimized for Raspberry Pi Zero 2W deployment.

## Files Overview

### Core Service Files
- **`plant-wall-control.service`** - Main systemd service configuration
- **`health-check.service`** - Health monitoring service configuration
- **`health-check.sh`** - Health monitoring and recovery script

### Deployment Scripts
- **`install-service.sh`** - Service installation and setup script
- **`deploy.sh`** - Automated deployment script for remote Pi deployment

## Quick Start

### 1. Local Installation on Raspberry Pi

```bash
# Build the application
go build -o plant-wall-control

# Install the service
sudo ./systemd/install-service.sh

# Check service status
sudo systemctl status plant-wall-control
```

### 2. Remote Deployment

```bash
# Deploy to Pi (requires SSH key authentication)
./systemd/deploy.sh

# Deploy to specific Pi
PI_HOST=192.168.1.100 ./systemd/deploy.sh

# Check deployment status
./systemd/deploy.sh --status
```

## Service Configuration

### Main Service Features

- **User**: Runs as dedicated `plantwall` user (non-root)
- **GPIO Access**: Proper permissions for hardware control
- **Memory Limit**: 150MB (optimized for Pi Zero 2W)
- **Auto-restart**: Automatic restart on failure
- **Graceful Shutdown**: 30-second timeout for clean shutdown
- **Security**: Hardened with minimal filesystem access

### Health Monitoring

- **Automatic Recovery**: Restarts service on failures
- **API Monitoring**: Checks HTTP endpoint health
- **Resource Monitoring**: Memory, CPU, disk usage
- **Alert System**: Logs critical issues
- **Smart Restart**: Cooldown periods and attempt limits

## Installation Process

The `install-service.sh` script performs:

1. **User Creation**: Creates `plantwall` user with GPIO permissions
2. **Directory Setup**: Creates service directories with proper permissions
3. **Binary Installation**: Installs service binary to `/opt/plant-wall-control/`
4. **Configuration**: Copies config to `/etc/plant-wall-control/`
5. **GPIO Permissions**: Sets up udev rules for hardware access
6. **Log Rotation**: Configures log rotation for service logs
7. **Service Registration**: Installs and enables systemd service

## Directory Structure After Installation

```
/opt/plant-wall-control/
├── plant-wall-control          # Service binary
└── systemd/
    ├── health-check.sh         # Health monitoring script
    └── ...

/etc/plant-wall-control/
└── config.yaml                 # Service configuration

/var/log/plant-wall-control/
├── *.log                       # Service logs
└── alerts.log                  # Health check alerts

/var/lib/plant-wall-control/
└── health-check.state          # Health monitor state
```

## Service Management Commands

### Basic Control
```bash
# Start service
sudo systemctl start plant-wall-control

# Stop service
sudo systemctl stop plant-wall-control

# Restart service
sudo systemctl restart plant-wall-control

# Check status
sudo systemctl status plant-wall-control

# View logs
sudo journalctl -u plant-wall-control -f
```

### Health Monitoring
```bash
# Check health status
sudo /opt/plant-wall-control/systemd/health-check.sh --status

# Force restart
sudo /opt/plant-wall-control/systemd/health-check.sh --restart

# Reset health state
sudo /opt/plant-wall-control/systemd/health-check.sh --reset-state
```

### Deployment Management
```bash
# Check deployment prerequisites
./systemd/deploy.sh --check

# View remote logs
./systemd/deploy.sh --logs

# Run remote health check
./systemd/deploy.sh --health

# Rollback deployment
./systemd/deploy.sh --rollback
```

## Configuration

### Environment Variables

The service supports these environment variables:

- `PWC_CONFIG_PATH`: Path to configuration file (default: `/etc/plant-wall-control/config.yaml`)
- `PWC_LOG_LEVEL`: Log level (default: `info`)
- `GOMEMLIMIT`: Go memory limit (default: `200MiB`)

### Hardware Permissions

The service user (`plantwall`) is added to these groups:
- `gpio`: GPIO pin access
- `i2c`: I2C bus access
- `spi`: SPI bus access
- `dialout`: Serial port access

### Security Features

- **Non-root execution**: Service runs as dedicated user
- **Filesystem protection**: Read-only root filesystem
- **Resource limits**: Memory and process limits
- **Minimal permissions**: Only necessary system access

## Troubleshooting

### Service Won't Start

1. Check service status:
   ```bash
   sudo systemctl status plant-wall-control
   ```

2. Check logs:
   ```bash
   sudo journalctl -u plant-wall-control -f
   ```

3. Verify binary permissions:
   ```bash
   ls -la /opt/plant-wall-control/plant-wall-control
   ```

4. Test binary manually:
   ```bash
   sudo -u plantwall /opt/plant-wall-control/plant-wall-control
   ```

### GPIO Permission Issues

1. Check user groups:
   ```bash
   groups plantwall
   ```

2. Check GPIO permissions:
   ```bash
   ls -la /sys/class/gpio/
   ```

3. Reload udev rules:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

### Memory Issues

1. Check memory usage:
   ```bash
   sudo systemctl show plant-wall-control -p MemoryCurrent
   ```

2. Monitor with health check:
   ```bash
   sudo /opt/plant-wall-control/systemd/health-check.sh --status
   ```

### Network Issues

1. Test API endpoint:
   ```bash
   curl http://localhost:5000/api/status
   ```

2. Check firewall:
   ```bash
   sudo ufw status
   ```

## Deployment Environment Variables

For remote deployment, set these environment variables:

```bash
export PI_HOST="plantwall.local"    # Pi hostname or IP
export PI_USER="pi"                 # SSH username
export PI_SSH_PORT="22"             # SSH port
```

## Uninstallation

To completely remove the service:

```bash
sudo ./systemd/install-service.sh --uninstall
```

This removes:
- Service files
- Service user
- Installation directories
- Configuration files
- Log files

## Performance Optimization

The service is optimized for Raspberry Pi Zero 2W:

- **Memory limit**: 150MB maximum
- **CPU governor**: Performance mode during operation
- **I/O scheduler**: Deadline scheduler for SD cards
- **Log rotation**: Prevents disk space issues
- **Resource monitoring**: Automatic alerts on resource exhaustion

## Security Best Practices

1. **SSH Key Authentication**: Use key-based auth for deployment
2. **Firewall**: Configure UFW to limit access
3. **User Isolation**: Service runs as non-root user
4. **File Permissions**: Strict file system permissions
5. **Log Monitoring**: Regular log review for security events