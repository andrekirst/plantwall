#!/bin/bash
# deploy.sh - Automated deployment script for Plant Wall Control
# Builds, transfers, and deploys to Raspberry Pi Zero 2W

set -e

# Configuration
PI_HOST="${PI_HOST:-plantwall.local}"
PI_USER="${PI_USER:-pi}"
PI_SSH_PORT="${PI_SSH_PORT:-22}"
SERVICE_NAME="plant-wall-control"
BUILD_ARCH="linux/arm64"
DEPLOY_DIR="/tmp/plant-wall-deployment"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites"
    
    # Check if Go is installed
    if ! command -v go >/dev/null 2>&1; then
        log_error "Go is not installed. Please install Go first."
        exit 1
    fi
    
    # Check if ssh/scp are available
    if ! command -v ssh >/dev/null 2>&1 || ! command -v scp >/dev/null 2>&1; then
        log_error "SSH tools are not installed. Please install openssh-client."
        exit 1
    fi
    
    # Check if we can reach the Pi
    log_info "Testing connection to $PI_HOST"
    if ! ssh -p "$PI_SSH_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$PI_USER@$PI_HOST" "echo 'Connection test successful'" >/dev/null 2>&1; then
        log_error "Cannot connect to $PI_HOST. Please check:"
        echo "  - Pi is powered on and connected to network"
        echo "  - SSH is enabled on the Pi"
        echo "  - Hostname/IP is correct: $PI_HOST"
        echo "  - Username is correct: $PI_USER"
        echo "  - SSH key authentication is set up"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Build the application
build_application() {
    log_info "Building application for ARM64"
    
    # Clean previous builds
    rm -f plant-wall-control plant-wall-control_arm64
    
    # Set Go build environment for ARM64
    export GOOS=linux
    export GOARCH=arm64
    export CGO_ENABLED=0
    
    # Build with optimizations for Raspberry Pi
    go build -ldflags="-w -s" -o plant-wall-control_arm64 .
    
    # Create a copy with the standard name for the Pi
    cp plant-wall-control_arm64 plant-wall-control
    
    log_success "Application built successfully"
}

# Create deployment package
create_deployment_package() {
    log_info "Creating deployment package"
    
    # Create temporary deployment directory
    mkdir -p "$DEPLOY_DIR"
    
    # Copy files to deployment directory
    cp plant-wall-control "$DEPLOY_DIR/"
    cp config.yaml "$DEPLOY_DIR/"
    cp -r systemd "$DEPLOY_DIR/"
    
    # Make scripts executable
    chmod +x "$DEPLOY_DIR/systemd/"*.sh
    
    log_success "Deployment package created"
}

# Transfer files to Pi
transfer_files() {
    log_info "Transferring files to $PI_HOST"
    
    # Create remote temporary directory
    ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "mkdir -p /tmp/plant-wall-deployment"
    
    # Transfer deployment package
    scp -P "$PI_SSH_PORT" -r "$DEPLOY_DIR"/* "$PI_USER@$PI_HOST:/tmp/plant-wall-deployment/"
    
    log_success "Files transferred successfully"
}

# Check if service is running and get current version info
check_current_deployment() {
    log_info "Checking current deployment status"
    
    local service_status
    service_status=$(ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "systemctl is-active $SERVICE_NAME 2>/dev/null || echo 'inactive'")
    
    if [[ "$service_status" == "active" ]]; then
        log_info "Service is currently running"
        
        # Get current binary info
        local current_info
        current_info=$(ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "ls -la /opt/plant-wall-control/plant-wall-control 2>/dev/null || echo 'not found'")
        log_info "Current binary: $current_info"
        
        return 0
    else
        log_info "Service is not currently running"
        return 1
    fi
}

# Deploy to Pi
deploy_to_pi() {
    log_info "Deploying to Raspberry Pi"
    
    # Run installation script on Pi
    ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "
        cd /tmp/plant-wall-deployment
        sudo ./systemd/install-service.sh
    "
    
    log_success "Deployment completed"
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment"
    
    # Wait a moment for service to start
    sleep 5
    
    # Check service status
    local service_status
    service_status=$(ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "systemctl is-active $SERVICE_NAME 2>/dev/null || echo 'inactive'")
    
    if [[ "$service_status" == "active" ]]; then
        log_success "Service is running"
        
        # Check API health
        log_info "Testing API endpoint"
        if ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "curl -s -m 10 http://localhost:5000/api/status >/dev/null 2>&1"; then
            log_success "API endpoint is responding"
        else
            log_warning "API endpoint is not responding (this may be normal during startup)"
        fi
        
        # Show service status
        ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "systemctl status $SERVICE_NAME --no-pager -l"
        
    else
        log_error "Service is not running"
        log_info "Checking logs:"
        ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "sudo journalctl -u $SERVICE_NAME --no-pager -l --since '5 minutes ago'"
        exit 1
    fi
}

# Cleanup temporary files
cleanup() {
    log_info "Cleaning up temporary files"
    
    # Local cleanup
    rm -rf "$DEPLOY_DIR"
    
    # Remote cleanup
    ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "rm -rf /tmp/plant-wall-deployment" || true
    
    log_success "Cleanup completed"
}

# Show post-deployment information
show_deployment_info() {
    echo
    log_success "Deployment completed successfully!"
    echo
    echo "Service Information:"
    echo "  Host: $PI_HOST"
    echo "  Service: $SERVICE_NAME"
    echo "  API: http://$PI_HOST:5000/api/status"
    echo
    echo "Useful commands:"
    echo "  Check status:  ssh $PI_USER@$PI_HOST 'systemctl status $SERVICE_NAME'"
    echo "  View logs:     ssh $PI_USER@$PI_HOST 'journalctl -u $SERVICE_NAME -f'"
    echo "  Restart:       ssh $PI_USER@$PI_HOST 'sudo systemctl restart $SERVICE_NAME'"
    echo "  Health check:  ssh $PI_USER@$PI_HOST 'sudo /opt/plant-wall-control/systemd/health-check.sh --status'"
    echo
}

# Rollback function
rollback_deployment() {
    log_warning "Rolling back deployment"
    
    # This is a simple rollback - in a production environment,
    # you would restore from backup
    ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "
        sudo systemctl stop $SERVICE_NAME 2>/dev/null || true
        sudo systemctl disable $SERVICE_NAME 2>/dev/null || true
    "
    
    log_info "Service stopped and disabled. Manual recovery may be required."
}

# Main deployment process
main() {
    local start_time=$(date +%s)
    
    log_info "Starting Plant Wall Control deployment to $PI_HOST"
    echo
    
    # Set trap for cleanup on exit
    trap cleanup EXIT
    
    check_prerequisites
    check_current_deployment
    build_application
    create_deployment_package
    transfer_files
    deploy_to_pi
    verify_deployment
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    show_deployment_info
    
    log_success "Deployment completed in ${duration} seconds"
}

# Handle script arguments
case "${1:-}" in
    --check)
        log_info "Checking deployment prerequisites"
        check_prerequisites
        check_current_deployment
        ;;
    --build-only)
        log_info "Building application only"
        build_application
        log_success "Build completed"
        ;;
    --rollback)
        log_warning "Rolling back deployment"
        check_prerequisites
        rollback_deployment
        ;;
    --status)
        log_info "Checking remote service status"
        check_prerequisites
        ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "systemctl status $SERVICE_NAME --no-pager -l"
        ;;
    --logs)
        log_info "Viewing remote service logs"
        check_prerequisites
        ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "journalctl -u $SERVICE_NAME -f"
        ;;
    --health)
        log_info "Running health check on remote Pi"
        check_prerequisites
        ssh -p "$PI_SSH_PORT" "$PI_USER@$PI_HOST" "sudo /opt/plant-wall-control/systemd/health-check.sh --status 2>/dev/null || echo 'Health check script not found'"
        ;;
    --help|-h)
        echo "Plant Wall Control Deployment Script"
        echo
        echo "Environment Variables:"
        echo "  PI_HOST=hostname    Target Pi hostname/IP (default: plantwall.local)"
        echo "  PI_USER=username    SSH username (default: pi)"
        echo "  PI_SSH_PORT=port    SSH port (default: 22)"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)       Full deployment"
        echo "  --check      Check prerequisites and current status"
        echo "  --build-only Build application only"
        echo "  --rollback   Rollback deployment"
        echo "  --status     Show remote service status"
        echo "  --logs       View remote service logs"
        echo "  --health     Run health check on remote Pi"
        echo "  --help, -h   Show this help message"
        echo
        echo "Examples:"
        echo "  $0                                    # Deploy to plantwall.local"
        echo "  PI_HOST=192.168.1.100 $0             # Deploy to specific IP"
        echo "  PI_USER=plantwall PI_HOST=pi4.local $0  # Deploy with different user"
        ;;
    *)
        main "$@"
        ;;
esac