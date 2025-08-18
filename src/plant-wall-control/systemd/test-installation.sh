#!/bin/bash
# test-installation.sh - Test Plant Wall Control Installation
# Comprehensive testing script for validating service installation

set -e

# Configuration
SERVICE_NAME="plant-wall-control"
SERVICE_USER="plantwall"
INSTALL_DIR="/opt/plant-wall-control"
CONFIG_DIR="/etc/plant-wall-control"
LOG_DIR="/var/log/plant-wall-control"
DATA_DIR="/var/lib/plant-wall-control"
API_ENDPOINT="http://localhost:5000/api/status"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
test_header() {
    echo
    echo -e "${BLUE}=== $1 ===${NC}"
}

test_case() {
    local test_name="$1"
    local test_command="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

test_case_with_output() {
    local test_name="$1"
    local test_command="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testing $test_name... "
    
    local output
    output=$(eval "$test_command" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test service user and groups
test_user_configuration() {
    test_header "Service User Configuration"
    
    test_case "Service user exists" "id $SERVICE_USER"
    test_case "User is in gpio group" "groups $SERVICE_USER | grep -q gpio"
    test_case "User is in i2c group" "groups $SERVICE_USER | grep -q i2c"
    test_case "User is in spi group" "groups $SERVICE_USER | grep -q spi"
}

# Test directory structure
test_directory_structure() {
    test_header "Directory Structure"
    
    test_case "Install directory exists" "test -d $INSTALL_DIR"
    test_case "Config directory exists" "test -d $CONFIG_DIR"
    test_case "Log directory exists" "test -d $LOG_DIR"
    test_case "Data directory exists" "test -d $DATA_DIR"
    test_case "Systemd scripts directory exists" "test -d $INSTALL_DIR/systemd"
    
    test_case "Install directory ownership" "test \$(stat -c '%U:%G' $INSTALL_DIR) = '$SERVICE_USER:$SERVICE_USER'"
    test_case "Log directory ownership" "test \$(stat -c '%U:%G' $LOG_DIR) = '$SERVICE_USER:$SERVICE_USER'"
    test_case "Data directory ownership" "test \$(stat -c '%U:%G' $DATA_DIR) = '$SERVICE_USER:$SERVICE_USER'"
}

# Test binary and configuration files
test_files() {
    test_header "Files and Permissions"
    
    test_case "Service binary exists" "test -f $INSTALL_DIR/plant-wall-control"
    test_case "Configuration file exists" "test -f $CONFIG_DIR/config.yaml"
    test_case "Health check script exists" "test -f $INSTALL_DIR/systemd/health-check.sh"
    
    test_case "Binary is executable" "test -x $INSTALL_DIR/plant-wall-control"
    test_case "Health check script is executable" "test -x $INSTALL_DIR/systemd/health-check.sh"
    
    test_case "Binary ownership" "test \$(stat -c '%U:%G' $INSTALL_DIR/plant-wall-control) = '$SERVICE_USER:$SERVICE_USER'"
    test_case "Config file readable" "test -r $CONFIG_DIR/config.yaml"
}

# Test systemd service configuration
test_systemd_configuration() {
    test_header "Systemd Configuration"
    
    test_case "Service file exists" "test -f /etc/systemd/system/$SERVICE_NAME.service"
    test_case "Service is enabled" "systemctl is-enabled $SERVICE_NAME.service"
    test_case "Service is active" "systemctl is-active $SERVICE_NAME.service"
    
    # Test health check components
    if [[ -f /etc/systemd/system/health-check.timer ]]; then
        test_case "Health check timer exists" "test -f /etc/systemd/system/health-check.timer"
        test_case "Health check timer is enabled" "systemctl is-enabled health-check.timer"
        test_case "Health check timer is active" "systemctl is-active health-check.timer"
    fi
    
    if [[ -f /etc/systemd/system/health-check-oneshot.service ]]; then
        test_case "Health check one-shot service exists" "test -f /etc/systemd/system/health-check-oneshot.service"
    fi
}

# Test GPIO permissions
test_gpio_permissions() {
    test_header "GPIO Permissions"
    
    test_case "GPIO export is writable" "test -w /sys/class/gpio/export"
    test_case "GPIO unexport is writable" "test -w /sys/class/gpio/unexport"
    test_case "udev rules exist" "test -f /etc/udev/rules.d/99-plant-wall-gpio.rules"
    
    # Test I2C access if available
    if [[ -c /dev/i2c-1 ]]; then
        test_case "I2C device accessible" "test -r /dev/i2c-1 -a -w /dev/i2c-1"
    fi
    
    # Test SPI access if available
    if [[ -c /dev/spidev0.0 ]]; then
        test_case "SPI device accessible" "test -r /dev/spidev0.0 -a -w /dev/spidev0.0"
    fi
}

# Test service functionality
test_service_functionality() {
    test_header "Service Functionality"
    
    # Wait a moment for service to fully start
    sleep 3
    
    test_case "Service is responding" "systemctl status $SERVICE_NAME.service"
    test_case "Service has no recent failures" "! journalctl -u $SERVICE_NAME.service --since '5 minutes ago' | grep -i 'failed\\|error'"
    
    # Test API endpoint if service is running
    if systemctl is-active --quiet "$SERVICE_NAME.service"; then
        test_case_with_output "API endpoint responds" "curl -s -m 10 $API_ENDPOINT"
        test_case_with_output "API returns valid JSON" "curl -s -m 10 $API_ENDPOINT | jq -e .timestamp"
    fi
}

# Test log rotation
test_log_configuration() {
    test_header "Log Configuration"
    
    test_case "Logrotate config exists" "test -f /etc/logrotate.d/$SERVICE_NAME"
    test_case "Logrotate config is valid" "logrotate -d /etc/logrotate.d/$SERVICE_NAME"
}

# Test health check functionality
test_health_check() {
    test_header "Health Check Functionality"
    
    if [[ -x "$INSTALL_DIR/systemd/health-check.sh" ]]; then
        test_case_with_output "Health check script runs" "sudo -u $SERVICE_USER $INSTALL_DIR/systemd/health-check.sh"
        test_case_with_output "Health check status command" "sudo -u $SERVICE_USER $INSTALL_DIR/systemd/health-check.sh --status"
    fi
}

# Test system resources
test_system_resources() {
    test_header "System Resources"
    
    # Check memory usage
    local memory_usage
    memory_usage=$(systemctl show "$SERVICE_NAME.service" -p MemoryCurrent --value 2>/dev/null || echo "0")
    
    if [[ $memory_usage -gt 0 ]]; then
        local memory_mb=$((memory_usage / 1024 / 1024))
        echo "Current memory usage: ${memory_mb}MB"
        test_case "Memory usage under limit" "test $memory_mb -lt 150"
    fi
    
    # Check if service is within systemd limits
    test_case "Service within systemd limits" "systemctl show $SERVICE_NAME.service -p ActiveState --value | grep -q active"
}

# Performance test
test_performance() {
    test_header "Performance Test"
    
    if systemctl is-active --quiet "$SERVICE_NAME.service"; then
        # Test API response time
        local response_time
        response_time=$(curl -o /dev/null -s -w '%{time_total}' -m 10 "$API_ENDPOINT" 2>/dev/null || echo "10")
        
        echo "API response time: ${response_time}s"
        test_case "API response under 2 seconds" "awk 'BEGIN{exit !('$response_time' < 2)}'"
        
        # Test multiple concurrent requests
        test_case_with_output "Handle concurrent requests" "for i in {1..5}; do curl -s -m 5 $API_ENDPOINT >/dev/null & done; wait"
    fi
}

# Show detailed status
show_detailed_status() {
    test_header "Detailed Status Information"
    
    echo "Service Status:"
    systemctl status "$SERVICE_NAME.service" --no-pager -l || true
    echo
    
    if [[ -f /etc/systemd/system/health-check.timer ]]; then
        echo "Health Check Timer Status:"
        systemctl status health-check.timer --no-pager -l || true
        echo
        
        echo "Next Health Check Runs:"
        systemctl list-timers health-check.timer --no-pager || true
        echo
    fi
    
    echo "Recent Logs (last 20 lines):"
    journalctl -u "$SERVICE_NAME.service" --no-pager -l -n 20 || true
    echo
    
    echo "System Resource Usage:"
    echo "Memory: $(free -h | awk 'NR==2{print $3"/"$2" ("$3*100/$2"%)"}')"
    
    if command -v vcgencmd >/dev/null 2>&1; then
        echo "CPU Temperature: $(vcgencmd measure_temp 2>/dev/null || echo 'N/A')"
    fi
    
    echo "Disk Usage: $(df -h / | awk 'NR==2{print $5" ("$3"/"$2")"}')"
}

# Show summary
show_summary() {
    echo
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo
        echo -e "${GREEN}✅ All tests passed! Plant Wall Control service is properly installed and configured.${NC}"
        return 0
    else
        echo
        echo -e "${RED}❌ Some tests failed. Please review the issues above.${NC}"
        echo
        echo "Common troubleshooting steps:"
        echo "1. Check service logs: journalctl -u $SERVICE_NAME.service -f"
        echo "2. Verify configuration: cat $CONFIG_DIR/config.yaml"
        echo "3. Test GPIO access: ls -la /sys/class/gpio/"
        echo "4. Restart service: sudo systemctl restart $SERVICE_NAME.service"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}Plant Wall Control Installation Test Suite${NC}"
    echo "=========================================="
    echo "Testing installation integrity and functionality..."
    
    test_user_configuration
    test_directory_structure
    test_files
    test_systemd_configuration
    test_gpio_permissions
    test_log_configuration
    test_service_functionality
    test_health_check
    test_system_resources
    test_performance
    
    show_detailed_status
    show_summary
}

# Handle script arguments
case "${1:-}" in
    --quick)
        echo "Running quick tests only..."
        test_user_configuration
        test_directory_structure
        test_files
        test_systemd_configuration
        show_summary
        ;;
    --performance)
        echo "Running performance tests..."
        test_performance
        show_summary
        ;;
    --status)
        show_detailed_status
        ;;
    --help|-h)
        echo "Plant Wall Control Installation Test Suite"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)       Run full test suite"
        echo "  --quick      Run basic installation tests only"
        echo "  --performance Run performance tests only"
        echo "  --status     Show detailed status information"
        echo "  --help, -h   Show this help message"
        echo
        echo "This script validates the Plant Wall Control service installation"
        echo "and verifies that all components are properly configured."
        ;;
    *)
        main "$@"
        ;;
esac