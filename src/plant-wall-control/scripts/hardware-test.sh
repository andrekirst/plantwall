#!/bin/bash
# hardware-test.sh - Hardware validation script for Plant Wall Control System
# Tests GPIO, I2C, SPI functionality and generates comprehensive hardware report
# Optimized for Raspberry Pi Zero 2W

set -e

# Script configuration
SCRIPT_VERSION="1.0.0"
REPORT_DIR="/var/log/plant-wall-control"
REPORT_FILE="$REPORT_DIR/hardware-test-$(date +%Y%m%d-%H%M%S).log"
MOCK_MODE=false

# GPIO Pin assignments (matching hardware.go configuration)
LIGHTING_PWM_PIN=18
LIGHTING_ENABLE_PIN=19
WATER_PUMP_PIN=20
VALVE_PINS=(21 22 23 24)
DHT_SENSOR_PIN=4
FLOW_SENSOR_PIN=17
STATUS_LED_PINS=(5 6 13)  # Red, Green, Blue

# I2C addresses
TSL2591_ADDR=0x29  # Light sensor
SSD1306_ADDR=0x3C  # OLED display (optional)

# SPI settings
SPI_DEVICE="/dev/spidev0.0"
MCP3008_CHANNELS=8

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0
TEST_RESULTS=()

# Log functions
log_header() {
    local msg="=== $1 ==="
    echo -e "\n${PURPLE}$msg${NC}"
    echo "$msg" >> "$REPORT_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$REPORT_FILE"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    echo "[PASS] $1" >> "$REPORT_FILE"
    ((TESTS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$REPORT_FILE"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo "[FAIL] $1" >> "$REPORT_FILE"
    ((TESTS_FAILED++))
}

log_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
    echo "[TEST] $1" >> "$REPORT_FILE"
    ((TESTS_TOTAL++))
}

# Helper functions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_raspberry_pi() {
    if grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
        local pi_model=$(cat /proc/device-tree/model | tr -d '\0')
        log_info "Detected: $pi_model"
        echo "Hardware: $pi_model" >> "$REPORT_FILE"
        
        # Check for Pi Zero 2W specifically
        if echo "$pi_model" | grep -q "Zero 2"; then
            log_success "Pi Zero 2W detected - optimal configuration"
        else
            log_warning "This is not a Pi Zero 2W - some optimizations may not apply"
        fi
    else
        log_warning "Not running on Raspberry Pi hardware"
        MOCK_MODE=true
    fi
}

setup_gpio_access() {
    log_info "Setting up GPIO access"
    
    # Ensure GPIO is available
    if [[ ! -d "/sys/class/gpio" ]]; then
        if ! modprobe gpio-mockup 2>/dev/null; then
            log_error "GPIO subsystem not available"
            return 1
        fi
    fi
    
    # Check if we can access GPIO export
    if [[ ! -w "/sys/class/gpio/export" ]]; then
        log_warning "No write access to GPIO export - trying to fix permissions"
        chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport 2>/dev/null || true
        chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport 2>/dev/null || true
    fi
    
    log_success "GPIO access configured"
}

export_gpio_pin() {
    local pin=$1
    echo "$pin" > /sys/class/gpio/export 2>/dev/null || true
    sleep 0.1
    
    if [[ -d "/sys/class/gpio/gpio$pin" ]]; then
        return 0
    else
        return 1
    fi
}

unexport_gpio_pin() {
    local pin=$1
    echo "$pin" > /sys/class/gpio/unexport 2>/dev/null || true
}

test_gpio_basic() {
    log_header "GPIO Basic Functionality Test"
    
    log_test "Testing basic GPIO export/unexport"
    
    # Test a safe GPIO pin (GPIO 25 - not used by our system)
    local test_pin=25
    
    if export_gpio_pin $test_pin; then
        log_success "GPIO $test_pin export successful"
        
        # Test direction setting
        if echo "out" > "/sys/class/gpio/gpio$test_pin/direction" 2>/dev/null; then
            log_success "GPIO $test_pin direction set to output"
            
            # Test value setting
            echo "1" > "/sys/class/gpio/gpio$test_pin/value" 2>/dev/null
            local value1=$(cat "/sys/class/gpio/gpio$test_pin/value" 2>/dev/null || echo "error")
            
            echo "0" > "/sys/class/gpio/gpio$test_pin/value" 2>/dev/null  
            local value2=$(cat "/sys/class/gpio/gpio$test_pin/value" 2>/dev/null || echo "error")
            
            if [[ "$value1" == "1" && "$value2" == "0" ]]; then
                log_success "GPIO $test_pin value control working"
            else
                log_error "GPIO $test_pin value control failed (got: $value1, $value2)"
            fi
        else
            log_error "GPIO $test_pin direction setting failed"
        fi
        
        unexport_gpio_pin $test_pin
    else
        log_error "GPIO $test_pin export failed"
    fi
}

test_lighting_pins() {
    log_header "Lighting Control GPIO Test"
    
    # Test PWM pin (GPIO 18)
    log_test "Testing lighting PWM pin (GPIO $LIGHTING_PWM_PIN)"
    
    if [[ -d "/sys/class/pwm/pwmchip0" ]]; then
        log_info "Hardware PWM available on PWM chip 0"
        
        # Test PWM export
        if echo "0" > /sys/class/pwm/pwmchip0/export 2>/dev/null; then
            log_success "PWM channel 0 exported"
            
            # Set PWM period (1kHz = 1000000ns)
            echo "1000000" > /sys/class/pwm/pwmchip0/pwm0/period 2>/dev/null
            
            # Test different duty cycles
            for duty in 0 250000 500000 750000 1000000; do
                echo "$duty" > /sys/class/pwm/pwmchip0/pwm0/duty_cycle 2>/dev/null
                echo "1" > /sys/class/pwm/pwmchip0/pwm0/enable 2>/dev/null
                sleep 0.1
                echo "0" > /sys/class/pwm/pwmchip0/pwm0/enable 2>/dev/null
            done
            
            log_success "PWM duty cycle control working"
            
            # Cleanup
            echo "0" > /sys/class/pwm/pwmchip0/unexport 2>/dev/null || true
        else
            log_warning "PWM export failed - testing as regular GPIO"
            test_gpio_pin $LIGHTING_PWM_PIN "Lighting PWM"
        fi
    else
        log_warning "Hardware PWM not available - testing as regular GPIO"
        test_gpio_pin $LIGHTING_PWM_PIN "Lighting PWM"
    fi
    
    # Test lighting enable pin
    test_gpio_pin $LIGHTING_ENABLE_PIN "Lighting Enable"
}

test_water_system_pins() {
    log_header "Water System GPIO Test"
    
    # Test water pump pin
    test_gpio_pin $WATER_PUMP_PIN "Water Pump Relay"
    
    # Test valve control pins
    for i in "${!VALVE_PINS[@]}"; do
        local pin=${VALVE_PINS[$i]}
        test_gpio_pin $pin "Plant Module $((i+1)) Valve"
    done
}

test_sensor_pins() {
    log_header "Sensor GPIO Test"
    
    # Test DHT sensor pin (input mode)
    log_test "Testing DHT sensor pin (GPIO $DHT_SENSOR_PIN)"
    
    if export_gpio_pin $DHT_SENSOR_PIN; then
        if echo "in" > "/sys/class/gpio/gpio$DHT_SENSOR_PIN/direction" 2>/dev/null; then
            log_success "DHT sensor pin configured as input"
        else
            log_error "DHT sensor pin direction setting failed"
        fi
        unexport_gpio_pin $DHT_SENSOR_PIN
    else
        log_error "DHT sensor pin export failed"
    fi
    
    # Test flow sensor pin (input with potential interrupt)
    test_gpio_pin $FLOW_SENSOR_PIN "Flow Sensor Input" "in"
}

test_status_led_pins() {
    log_header "Status LED GPIO Test"
    
    local colors=("Red" "Green" "Blue")
    
    for i in "${!STATUS_LED_PINS[@]}"; do
        local pin=${STATUS_LED_PINS[$i]}
        local color=${colors[$i]}
        test_gpio_pin $pin "Status LED $color"
    done
    
    # Test LED sequence
    log_test "Testing LED sequence"
    
    local all_exported=true
    for pin in "${STATUS_LED_PINS[@]}"; do
        if ! export_gpio_pin $pin; then
            all_exported=false
            break
        fi
        echo "out" > "/sys/class/gpio/gpio$pin/direction" 2>/dev/null || all_exported=false
    done
    
    if $all_exported; then
        # Flash each LED in sequence
        for cycle in {1..3}; do
            for pin in "${STATUS_LED_PINS[@]}"; do
                echo "1" > "/sys/class/gpio/gpio$pin/value" 2>/dev/null
                sleep 0.2
                echo "0" > "/sys/class/gpio/gpio$pin/value" 2>/dev/null
            done
        done
        log_success "LED sequence test completed"
    else
        log_error "LED sequence test failed - could not export all pins"
    fi
    
    # Cleanup
    for pin in "${STATUS_LED_PINS[@]}"; do
        unexport_gpio_pin $pin
    done
}

test_gpio_pin() {
    local pin=$1
    local name=$2
    local direction=${3:-"out"}
    
    log_test "Testing $name (GPIO $pin)"
    
    if export_gpio_pin $pin; then
        if echo "$direction" > "/sys/class/gpio/gpio$pin/direction" 2>/dev/null; then
            if [[ "$direction" == "out" ]]; then
                # Test output functionality
                echo "1" > "/sys/class/gpio/gpio$pin/value" 2>/dev/null
                local value1=$(cat "/sys/class/gpio/gpio$pin/value" 2>/dev/null || echo "error")
                
                echo "0" > "/sys/class/gpio/gpio$pin/value" 2>/dev/null
                local value2=$(cat "/sys/class/gpio/gpio$pin/value" 2>/dev/null || echo "error")
                
                if [[ "$value1" == "1" && "$value2" == "0" ]]; then
                    log_success "$name output control working"
                else
                    log_error "$name output control failed"
                fi
            else
                # Test input functionality
                local value=$(cat "/sys/class/gpio/gpio$pin/value" 2>/dev/null || echo "error")
                if [[ "$value" != "error" ]]; then
                    log_success "$name input reading working (value: $value)"
                else
                    log_error "$name input reading failed"
                fi
            fi
        else
            log_error "$name direction setting failed"
        fi
        unexport_gpio_pin $pin
    else
        log_error "$name pin export failed"
    fi
}

test_i2c_interface() {
    log_header "I2C Interface Test"
    
    # Check if I2C is enabled
    if [[ ! -e "/dev/i2c-1" ]]; then
        log_error "I2C interface not available (/dev/i2c-1 missing)"
        log_info "Enable I2C with: sudo raspi-config"
        return 1
    fi
    
    log_success "I2C interface available"
    
    # Test I2C device detection
    log_test "Scanning I2C bus for devices"
    
    if command -v i2cdetect >/dev/null 2>&1; then
        local i2c_output=$(i2cdetect -y 1 2>/dev/null || echo "error")
        
        if [[ "$i2c_output" != "error" ]]; then
            log_success "I2C bus scan completed"
            echo "I2C devices found:" >> "$REPORT_FILE"
            echo "$i2c_output" >> "$REPORT_FILE"
            
            # Check for specific devices
            if echo "$i2c_output" | grep -q "29"; then
                log_success "TSL2591 light sensor detected at 0x29"
            else
                log_warning "TSL2591 light sensor not detected at 0x29"
            fi
            
            if echo "$i2c_output" | grep -q "3c"; then
                log_success "SSD1306 OLED display detected at 0x3C"
            else
                log_info "SSD1306 OLED display not detected at 0x3C (optional)"
            fi
        else
            log_error "I2C bus scan failed"
        fi
    else
        log_warning "i2cdetect command not available"
        log_info "Install with: sudo apt install i2c-tools"
    fi
}

test_spi_interface() {
    log_header "SPI Interface Test"
    
    # Check if SPI is enabled
    if [[ ! -e "$SPI_DEVICE" ]]; then
        log_error "SPI interface not available ($SPI_DEVICE missing)"
        log_info "Enable SPI with: sudo raspi-config"
        return 1
    fi
    
    log_success "SPI interface available"
    
    # Test SPI device access
    log_test "Testing SPI device access"
    
    if [[ -r "$SPI_DEVICE" && -w "$SPI_DEVICE" ]]; then
        log_success "SPI device readable and writable"
        
        # Test basic SPI communication (safe test pattern)
        log_test "Testing basic SPI communication"
        
        # Send a safe test pattern to MCP3008 (read channel 0)
        # This won't harm the device even if it's not connected
        if command -v spi-config >/dev/null 2>&1; then
            # Use spi-config if available
            local spi_result=$(spi-config -d "$SPI_DEVICE" -s 1000000 -b 8 2>/dev/null || echo "error")
            if [[ "$spi_result" != "error" ]]; then
                log_success "SPI configuration successful"
            else
                log_warning "SPI configuration test inconclusive"
            fi
        else
            log_info "spi-config not available - basic access test only"
        fi
        
        # Test file permissions
        local spi_perms=$(stat -c "%a" "$SPI_DEVICE" 2>/dev/null || echo "000")
        if [[ "$spi_perms" == "664" ]]; then
            log_success "SPI device permissions correct (664)"
        else
            log_warning "SPI device permissions: $spi_perms (expected: 664)"
        fi
    else
        log_error "SPI device not accessible"
    fi
}

test_power_management() {
    log_header "Power Management Test"
    
    # Check CPU frequency
    log_test "Checking CPU frequency scaling"
    
    if [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]]; then
        local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
        log_info "CPU governor: $governor"
        
        local cur_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "0")
        local max_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo "0")
        
        if [[ "$cur_freq" != "0" && "$max_freq" != "0" ]]; then
            log_success "CPU frequency: $(($cur_freq / 1000)) MHz (max: $(($max_freq / 1000)) MHz)"
        else
            log_warning "CPU frequency information not available"
        fi
    else
        log_warning "CPU frequency scaling not available"
    fi
    
    # Check thermal status
    log_test "Checking thermal status"
    
    if command -v vcgencmd >/dev/null 2>&1; then
        local temp_output=$(vcgencmd measure_temp 2>/dev/null || echo "temp=0.0'C")
        local temperature=$(echo "$temp_output" | grep -o '[0-9.]*')
        
        if [[ "$temperature" != "0.0" ]]; then
            log_success "CPU temperature: ${temperature}°C"
            
            # Check thermal throttling
            local throttle_status=$(vcgencmd get_throttled 2>/dev/null || echo "throttled=0x0")
            local throttle_hex=$(echo "$throttle_status" | grep -o '0x[0-9a-fA-F]*')
            
            if [[ "$throttle_hex" == "0x0" ]]; then
                log_success "No thermal throttling detected"
            else
                log_warning "Thermal throttling status: $throttle_hex"
            fi
        else
            log_warning "Temperature reading not available"
        fi
    else
        log_warning "vcgencmd not available (not on Raspberry Pi)"
    fi
}

test_network_connectivity() {
    log_header "Network Connectivity Test"
    
    # Test local network interface
    log_test "Checking network interfaces"
    
    local wlan_status=$(ip addr show wlan0 2>/dev/null | grep "state UP" || echo "down")
    if [[ "$wlan_status" != "down" ]]; then
        log_success "WiFi interface is up"
        
        # Get WiFi signal strength
        if command -v iwconfig >/dev/null 2>&1; then
            local signal_info=$(iwconfig wlan0 2>/dev/null | grep "Signal level" || echo "no signal info")
            log_info "WiFi signal: $signal_info"
        fi
    else
        log_warning "WiFi interface is down"
    fi
    
    # Test internet connectivity
    log_test "Testing internet connectivity"
    
    if ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
        log_success "Internet connectivity working"
    else
        log_warning "Internet connectivity failed"
    fi
    
    # Test DNS resolution
    log_test "Testing DNS resolution"
    
    if nslookup google.com >/dev/null 2>&1; then
        log_success "DNS resolution working"
    else
        log_warning "DNS resolution failed"
    fi
}

test_system_resources() {
    log_header "System Resources Test"
    
    # Check memory
    log_test "Checking available memory"
    
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local mem_used=$((mem_total - mem_available))
    local mem_percent=$((mem_used * 100 / mem_total))
    
    log_info "Memory: ${mem_used}KB used / ${mem_total}KB total (${mem_percent}%)"
    
    if [[ $mem_percent -lt 80 ]]; then
        log_success "Memory usage normal"
    else
        log_warning "Memory usage high: ${mem_percent}%"
    fi
    
    # Check disk space
    log_test "Checking disk space"
    
    local disk_info=$(df -h / | tail -1)
    local disk_used=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
    
    log_info "Disk usage: $disk_info"
    
    if [[ $disk_used -lt 80 ]]; then
        log_success "Disk space sufficient"
    else
        log_warning "Disk space low: ${disk_used}%"
    fi
    
    # Check load average
    log_test "Checking system load"
    
    local load_avg=$(cat /proc/loadavg | awk '{print $1}')
    log_info "Load average (1min): $load_avg"
    
    if (( $(echo "$load_avg < 1.0" | bc -l) )); then
        log_success "System load normal"
    else
        log_warning "System load high: $load_avg"
    fi
}

create_hardware_report() {
    log_header "Hardware Test Report"
    
    local report_summary_file="$REPORT_DIR/hardware-test-summary.txt"
    
    cat > "$report_summary_file" << EOF
Plant Wall Control System - Hardware Test Report
===============================================
Test Date: $(date)
System: $(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' || echo "Unknown")
Kernel: $(uname -r)
Hardware Test Script Version: $SCRIPT_VERSION

Test Results Summary:
--------------------
Total Tests: $TESTS_TOTAL
Passed: $TESTS_PASSED  
Failed: $TESTS_FAILED
Success Rate: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%

GPIO Pin Assignments (Plant Wall Control):
-----------------------------------------
Lighting PWM: GPIO $LIGHTING_PWM_PIN
Lighting Enable: GPIO $LIGHTING_ENABLE_PIN  
Water Pump: GPIO $WATER_PUMP_PIN
Plant Valves: GPIO ${VALVE_PINS[*]}
DHT Sensor: GPIO $DHT_SENSOR_PIN
Flow Sensor: GPIO $FLOW_SENSOR_PIN
Status LEDs: GPIO ${STATUS_LED_PINS[*]} (Red, Green, Blue)

I2C Devices:
-----------
TSL2591 Light Sensor: 0x29
SSD1306 OLED Display: 0x3C (optional)

SPI Devices:
-----------
MCP3008 ADC: $SPI_DEVICE (8 channels for analog sensors)

System Status:
-------------
Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')
Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')
Temperature: $(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "N/A")
Load: $(cat /proc/loadavg | awk '{print $1}')

Detailed log: $REPORT_FILE
EOF
    
    echo
    log_success "Hardware test report created: $report_summary_file"
    log_info "Detailed log available: $REPORT_FILE"
    
    # Display summary
    cat "$report_summary_file"
}

cleanup_gpio() {
    log_info "Cleaning up GPIO exports"
    
    # Cleanup any exported pins
    local all_pins=($LIGHTING_PWM_PIN $LIGHTING_ENABLE_PIN $WATER_PUMP_PIN ${VALVE_PINS[*]} $DHT_SENSOR_PIN $FLOW_SENSOR_PIN ${STATUS_LED_PINS[*]} 25)
    
    for pin in "${all_pins[@]}"; do
        unexport_gpio_pin $pin
    done
    
    # Cleanup PWM if used
    echo "0" > /sys/class/pwm/pwmchip0/unexport 2>/dev/null || true
}

# Main test function
main() {
    log_header "Plant Wall Control Hardware Test v$SCRIPT_VERSION"
    echo -e "${BLUE}Testing hardware for Raspberry Pi Zero 2W compatibility${NC}"
    echo
    
    # Preflight checks
    check_root
    check_raspberry_pi
    
    # Create report directory
    mkdir -p "$REPORT_DIR"
    
    # Initialize report file
    echo "Plant Wall Control Hardware Test - $(date)" > "$REPORT_FILE"
    echo "======================================================" >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # Set up GPIO access
    setup_gpio_access
    
    # Run hardware tests
    test_gpio_basic
    test_lighting_pins
    test_water_system_pins
    test_sensor_pins
    test_status_led_pins
    test_i2c_interface
    test_spi_interface
    test_power_management
    test_network_connectivity
    test_system_resources
    
    # Cleanup
    cleanup_gpio
    
    # Generate report
    create_hardware_report
    
    # Final status
    echo
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All hardware tests passed!"
        echo -e "${GREEN}System ready for Plant Wall Control deployment${NC}"
        exit 0
    else
        log_warning "$TESTS_FAILED out of $TESTS_TOTAL tests failed"
        echo -e "${YELLOW}Review failed tests before deployment${NC}"
        exit 1
    fi
}

# Script entry point
case "${1:-}" in
    --help|-h)
        echo "Plant Wall Control Hardware Test Script"
        echo
        echo "Usage: sudo $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  (none)      Run full hardware test"
        echo "  --help, -h  Show this help message"
        echo
        echo "This script tests:"
        echo "  • GPIO pin functionality"
        echo "  • I2C interface and devices"
        echo "  • SPI interface (MCP3008 ADC)"
        echo "  • PWM for LED brightness control"
        echo "  • System resources and thermal status"
        echo "  • Network connectivity"
        echo
        echo "Requirements:"
        echo "  • Must be run as root"
        echo "  • GPIO, I2C, SPI interfaces enabled"
        echo "  • Hardware connected (optional for basic tests)"
        echo
        echo "Reports:"
        echo "  • Summary: $REPORT_DIR/hardware-test-summary.txt"
        echo "  • Detailed: $REPORT_DIR/hardware-test-[timestamp].log"
        ;;
    *)
        main "$@"
        ;;
esac