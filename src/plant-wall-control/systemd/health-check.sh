#!/bin/bash
# health-check.sh - Plant Wall Control Service Health Monitor
# Monitors service health and performs automatic recovery actions

set -e

# Configuration
SERVICE_NAME="plant-wall-control"
API_ENDPOINT="http://localhost:5000/api/status"
LOG_FILE="/var/log/plant-wall-control/health-check.log"
ALERT_THRESHOLD=3  # Number of consecutive failures before alert
MAX_RESTART_ATTEMPTS=5
RESTART_COOLDOWN=300  # 5 minutes between restart attempts

# State file to track failures and restart attempts
STATE_FILE="/var/lib/plant-wall-control/health-check.state"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case $level in
        "INFO")  color=$BLUE ;;
        "WARN")  color=$YELLOW ;;
        "ERROR") color=$RED ;;
        "SUCCESS") color=$GREEN ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Output to console if running interactively
    if [[ -t 1 ]]; then
        echo -e "${color}[$timestamp] [$level]${NC} $message"
    fi
}

# Load state from file
load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        source "$STATE_FILE"
    else
        CONSECUTIVE_FAILURES=0
        RESTART_ATTEMPTS=0
        LAST_RESTART=0
    fi
}

# Save state to file
save_state() {
    cat > "$STATE_FILE" << EOF
CONSECUTIVE_FAILURES=$CONSECUTIVE_FAILURES
RESTART_ATTEMPTS=$RESTART_ATTEMPTS
LAST_RESTART=$LAST_RESTART
EOF
}

# Check if service is running
check_service_status() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        return 0
    else
        return 1
    fi
}

# Check API endpoint health
check_api_health() {
    local timeout=10
    local response
    
    # Try to get status from API
    response=$(curl -s -m $timeout "$API_ENDPOINT" 2>/dev/null || echo "")
    
    if [[ -n "$response" ]] && echo "$response" | jq -e .timestamp >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check GPIO hardware access
check_gpio_access() {
    # Check if GPIO export is accessible
    if [[ -w /sys/class/gpio/export ]]; then
        return 0
    else
        return 1
    fi
}

# Check system resources
check_system_resources() {
    local memory_usage
    local cpu_temp
    local disk_usage
    
    # Check memory usage (should be under 80% for Pi Zero 2W)
    memory_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    if (( $(echo "$memory_usage > 80" | bc -l) )); then
        log_message "WARN" "High memory usage: ${memory_usage}%"
        return 1
    fi
    
    # Check CPU temperature (should be under 70°C)
    if command -v vcgencmd >/dev/null 2>&1; then
        cpu_temp=$(vcgencmd measure_temp | grep -o '[0-9.]*')
        if (( $(echo "$cpu_temp > 70" | bc -l) )); then
            log_message "WARN" "High CPU temperature: ${cpu_temp}°C"
            return 1
        fi
    fi
    
    # Check disk usage (should be under 90%)
    disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        log_message "WARN" "High disk usage: ${disk_usage}%"
        return 1
    fi
    
    return 0
}

# Restart service with cooldown
restart_service() {
    local current_time=$(date +%s)
    local time_since_last_restart=$((current_time - LAST_RESTART))
    
    # Check restart cooldown
    if [[ $time_since_last_restart -lt $RESTART_COOLDOWN ]] && [[ $RESTART_ATTEMPTS -gt 0 ]]; then
        local remaining=$((RESTART_COOLDOWN - time_since_last_restart))
        log_message "WARN" "Restart cooldown active. $remaining seconds remaining."
        return 1
    fi
    
    # Check max restart attempts
    if [[ $RESTART_ATTEMPTS -ge $MAX_RESTART_ATTEMPTS ]]; then
        log_message "ERROR" "Maximum restart attempts ($MAX_RESTART_ATTEMPTS) reached. Manual intervention required."
        return 1
    fi
    
    log_message "INFO" "Attempting to restart service (attempt $((RESTART_ATTEMPTS + 1))/$MAX_RESTART_ATTEMPTS)"
    
    if systemctl restart "$SERVICE_NAME"; then
        RESTART_ATTEMPTS=$((RESTART_ATTEMPTS + 1))
        LAST_RESTART=$current_time
        CONSECUTIVE_FAILURES=0
        save_state
        
        # Wait for service to start
        sleep 5
        
        if check_service_status && check_api_health; then
            log_message "SUCCESS" "Service restarted successfully"
            return 0
        else
            log_message "ERROR" "Service restart failed"
            return 1
        fi
    else
        log_message "ERROR" "Failed to restart service"
        return 1
    fi
}

# Send alert (can be extended to send emails, webhooks, etc.)
send_alert() {
    local message=$1
    log_message "ERROR" "ALERT: $message"
    
    # Example: Send to system log
    logger -t "plant-wall-health" "ALERT: $message"
    
    # Example: Write to alert file
    echo "$(date): $message" >> "/var/log/plant-wall-control/alerts.log"
}

# Main health check routine
perform_health_check() {
    local health_ok=true
    local issues=()
    
    log_message "INFO" "Starting health check"
    
    # Check service status
    if ! check_service_status; then
        health_ok=false
        issues+=("Service not running")
    fi
    
    # Check API health
    if ! check_api_health; then
        health_ok=false
        issues+=("API endpoint not responding")
    fi
    
    # Check GPIO access
    if ! check_gpio_access; then
        health_ok=false
        issues+=("GPIO access denied")
    fi
    
    # Check system resources
    if ! check_system_resources; then
        # This is a warning, not a failure
        log_message "WARN" "System resources under stress"
    fi
    
    if $health_ok; then
        log_message "SUCCESS" "Health check passed"
        CONSECUTIVE_FAILURES=0
        
        # Reset restart attempts after successful check
        if [[ $RESTART_ATTEMPTS -gt 0 ]]; then
            local current_time=$(date +%s)
            local time_since_last_restart=$((current_time - LAST_RESTART))
            
            # Reset restart counter after 1 hour of successful operation
            if [[ $time_since_last_restart -gt 3600 ]]; then
                RESTART_ATTEMPTS=0
                log_message "INFO" "Reset restart attempt counter after successful operation"
            fi
        fi
        
        save_state
        return 0
    else
        CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        log_message "ERROR" "Health check failed (${CONSECUTIVE_FAILURES}/${ALERT_THRESHOLD}): ${issues[*]}"
        
        # Try to restart service after threshold
        if [[ $CONSECUTIVE_FAILURES -ge $ALERT_THRESHOLD ]]; then
            if restart_service; then
                log_message "INFO" "Service recovery successful"
            else
                send_alert "Service recovery failed after $CONSECUTIVE_FAILURES consecutive failures"
            fi
        fi
        
        save_state
        return 1
    fi
}

# Show service status
show_status() {
    echo "Plant Wall Control Health Status"
    echo "==============================="
    echo
    
    # Service status
    if check_service_status; then
        echo -e "Service Status: ${GREEN}Running${NC}"
    else
        echo -e "Service Status: ${RED}Stopped${NC}"
    fi
    
    # API status
    if check_api_health; then
        echo -e "API Status: ${GREEN}Healthy${NC}"
    else
        echo -e "API Status: ${RED}Unhealthy${NC}"
    fi
    
    # GPIO status
    if check_gpio_access; then
        echo -e "GPIO Access: ${GREEN}Available${NC}"
    else
        echo -e "GPIO Access: ${RED}Denied${NC}"
    fi
    
    # System resources
    if command -v free >/dev/null; then
        local memory_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
        echo "Memory Usage: ${memory_usage}%"
    fi
    
    if command -v vcgencmd >/dev/null 2>&1; then
        local cpu_temp=$(vcgencmd measure_temp | grep -o '[0-9.]*')
        echo "CPU Temperature: ${cpu_temp}°C"
    fi
    
    local disk_usage=$(df / | awk 'NR==2{print $5}')
    echo "Disk Usage: $disk_usage"
    
    # State information
    load_state
    echo
    echo "Health Check State:"
    echo "  Consecutive Failures: $CONSECUTIVE_FAILURES"
    echo "  Restart Attempts: $RESTART_ATTEMPTS"
    
    if [[ $LAST_RESTART -gt 0 ]]; then
        local last_restart_date=$(date -d "@$LAST_RESTART" '+%Y-%m-%d %H:%M:%S')
        echo "  Last Restart: $last_restart_date"
    fi
}

# Main script logic
main() {
    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"
    mkdir -p "$(dirname "$STATE_FILE")"
    
    load_state
    perform_health_check
}

# Handle script arguments
case "${1:-}" in
    --status|-s)
        show_status
        ;;
    --restart|-r)
        log_message "INFO" "Manual restart requested"
        CONSECUTIVE_FAILURES=$ALERT_THRESHOLD  # Force restart
        load_state
        restart_service
        ;;
    --reset-state)
        log_message "INFO" "Resetting health check state"
        rm -f "$STATE_FILE"
        ;;
    --continuous|-c)
        log_message "INFO" "Starting continuous health monitoring"
        while true; do
            main
            sleep 60  # Check every minute
        done
        ;;
    --help|-h)
        echo "Plant Wall Control Health Check Script"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)        Perform single health check"
        echo "  --status, -s  Show current status"
        echo "  --restart, -r Force service restart"
        echo "  --reset-state Reset health check state"
        echo "  --continuous  Run continuous monitoring"
        echo "  --help, -h    Show this help message"
        echo
        echo "This script monitors the Plant Wall Control service and"
        echo "automatically attempts recovery on failures."
        ;;
    *)
        main "$@"
        ;;
esac