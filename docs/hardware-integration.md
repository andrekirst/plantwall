# Hardware Integration Guide

**Plant Wall Control System - GPIO & Sensor Integration**

This guide covers the detailed hardware integration for the automated plant wall system, including GPIO pin mappings, sensor connections, and electrical specifications.

## 🔌 Complete GPIO Pin Assignment

### Raspberry Pi Zero 2W Pin Layout

```
         3V3  (1) (2)  5V
   I2C1 SDA  (3) (4)  5V
   I2C1 SCL  (5) (6)  GND
        GPIO4 (7) (8)  GPIO14 (UART TX)
         GND  (9) (10) GPIO15 (UART RX)
       GPIO17 (11)(12) GPIO18 (PWM0)
       GPIO27 (13)(14) GND
       GPIO22 (15)(16) GPIO23
         3V3 (17)(18) GPIO24
SPI0 MOSI GPIO10 (19)(20) GND
SPI0 MISO GPIO9  (21)(22) GPIO25
SPI0 SCLK GPIO11 (23)(24) GPIO8  (SPI0 CE0)
         GND (25)(26) GPIO7  (SPI0 CE1)
       ID_SD (27)(28) ID_SC
        GPIO5 (29)(30) GND
        GPIO6 (31)(32) GPIO12
       GPIO13 (33)(34) GND
       GPIO19 (35)(36) GPIO16
       GPIO26 (37)(38) GPIO20
         GND (39)(40) GPIO21
```

### Plant Wall Control Pin Mapping

| GPIO Pin | Physical Pin | Function | Connection | Specifications |
|----------|--------------|----------|------------|----------------|
| **GPIO 2** | 3 | I2C1 SDA | Light Sensor, OLED Display | 3.3V, Pull-up 4.7kΩ |
| **GPIO 3** | 5 | I2C1 SCL | Light Sensor, OLED Display | 3.3V, Pull-up 4.7kΩ |
| **GPIO 4** | 7 | DHT22 Data | Temperature/Humidity | 3.3V, Pull-up 10kΩ |
| **GPIO 5** | 29 | Status LED Red | System Status | 3.3V, 220Ω resistor |
| **GPIO 6** | 31 | Status LED Green | System Status | 3.3V, 220Ω resistor |
| **GPIO 8** | 24 | SPI0 CE0 | MCP3008 Chip Select | 3.3V SPI |
| **GPIO 9** | 21 | SPI0 MISO | MCP3008 Data Out | 3.3V SPI |
| **GPIO 10** | 19 | SPI0 MOSI | MCP3008 Data In | 3.3V SPI |
| **GPIO 11** | 23 | SPI0 SCLK | MCP3008 Clock | 3.3V SPI |
| **GPIO 13** | 33 | Status LED Blue | WiFi/Network Status | 3.3V, 220Ω resistor |
| **GPIO 17** | 11 | Flow Sensor | Water Flow Interrupt | 3.3V, 10kΩ pull-up |
| **GPIO 18** | 12 | PWM LED Control | 24V LED Strip PWM | Hardware PWM, 1kHz |
| **GPIO 19** | 35 | LED Enable | LED Strip Main Switch | 3.3V → TIP120 Base |
| **GPIO 20** | 38 | Water Pump | 12V Pump Relay | 3.3V → Optocoupler |
| **GPIO 21** | 40 | Valve 1 | Module 1 Water Valve | 3.3V → BC547 Base |
| **GPIO 22** | 15 | Valve 2 | Module 2 Water Valve | 3.3V → BC547 Base |
| **GPIO 23** | 16 | Valve 3 | Module 3 Water Valve | 3.3V → BC547 Base |
| **GPIO 24** | 18 | Valve 4 | Module 4 Water Valve | 3.3V → BC547 Base |
| **GPIO 25** | 22 | Emergency Stop | Hardware Emergency Button | 3.3V, Pull-up 10kΩ |

## 📡 Sensor Integration Details

### 1. Soil Moisture Sensors (Capacitive)

**Hardware**: 4x Capacitive soil moisture sensors via MCP3008 ADC

```
MCP3008 ADC Configuration:
┌─────────────────────────────────────┐
│ MCP3008 10-bit ADC (SPI Interface) │
│                                     │
│ VDD (16) ────── 3.3V               │
│ VREF (15) ───── 3.3V               │
│ AGND (14) ───── GND                │
│ CLK (13) ────── GPIO 11 (SCLK)     │
│ DOUT (12) ───── GPIO 9 (MISO)      │
│ DIN (11) ────── GPIO 10 (MOSI)     │
│ CS (10) ─────── GPIO 8 (CE0)       │
│ DGND (9) ────── GND                │
│                                     │
│ CH0 (1) ─────── Soil Sensor 1      │
│ CH1 (2) ─────── Soil Sensor 2      │
│ CH2 (3) ─────── Soil Sensor 3      │
│ CH3 (4) ─────── Soil Sensor 4      │
│ CH4 (5) ─────── pH Sensor          │
│ CH5 (6) ─────── EC Sensor          │
│ CH6 (7) ─────── Reserved           │
│ CH7 (8) ─────── Reserved           │
└─────────────────────────────────────┘
```

**Calibration Values**:
- Air (dry): 850-1023 (ADC values)
- Water (wet): 400-500 (ADC values)
- Operating range: 0-100% moisture

**Circuit per Sensor**:
```
Sensor VCC ────┐
               ├── 3.3V
Sensor GND ────┤
               └── GND

Sensor OUT ────┬── 100nF ──── GND (noise filter)
               │
               ├── 10kΩ ──── GND (pull-down)
               │
               └── MCP3008 CHx
```

### 2. Light Sensor (TSL2591)

**Hardware**: High Dynamic Range Digital Light Sensor

```
TSL2591 I2C Configuration:
┌────────────────────────────────┐
│ TSL2591 Light Sensor Module   │
│                                │
│ VIN ─────── 3.3V              │
│ GND ─────── GND               │
│ SCL ─────── GPIO 3 (I2C SCL)  │
│ SDA ─────── GPIO 2 (I2C SDA)  │
│ INT ─────── (Optional) GPIO 26 │
└────────────────────────────────┘

I2C Address: 0x29 (default)
Pull-up Resistors: 4.7kΩ on SDA/SCL
```

**Specifications**:
- Dynamic Range: 600M:1
- Lux Range: 188 μLux to 88,000 Lux
- Integration Time: 100-600ms (configurable)
- Gain: 1x, 25x, 428x (configurable)

### 3. Temperature/Humidity Sensor (DHT22)

**Hardware**: Digital temperature and humidity sensor

```
DHT22 Connection:
┌─────────────────┐
│ DHT22 Sensor    │
│                 │
│ VCC ── 3.3V     │
│ DATA ─ GPIO 4   │ ──── 10kΩ pull-up to 3.3V
│ NC ── (unused)  │
│ GND ── GND      │
└─────────────────┘

Signal Conditioning:
- 100nF bypass capacitor (VCC to GND)
- 10kΩ pull-up resistor on data line
- Keep wiring short (<20cm)
```

**Specifications**:
- Temperature: -40°C to 80°C (±0.5°C)
- Humidity: 0-100% RH (±2-5% RH)
- Sampling: One reading per 2 seconds maximum

### 4. pH/EC Sensors (Analog)

**Hardware**: Analog pH and EC probes with signal conditioning

```
pH Sensor Signal Conditioning:
┌──────────────────────────────────────┐
│ pH Probe ─── Signal Conditioner     │
│              │                      │
│              ├── Op-Amp Buffer      │ ──── MCP3008 CH4
│              ├── Gain Adj (10kΩ)    │
│              ├── Offset Adj (10kΩ)  │
│              └── Anti-Alias Filter  │
└──────────────────────────────────────┘

EC Sensor Signal Conditioning:
┌──────────────────────────────────────┐
│ EC Probe ─── Signal Conditioner     │
│              │                      │
│              ├── Op-Amp Buffer      │ ──── MCP3008 CH5
│              ├── Gain Adj (10kΩ)    │
│              ├── Offset Adj (10kΩ)  │
│              └── Anti-Alias Filter  │
└──────────────────────────────────────┘
```

**Calibration**:
- pH: 4.00, 7.00, 10.00 buffer solutions
- EC: 1413 μS/cm, 12.88 mS/cm standards

## ⚡ Actuator Control Circuits

### 1. Water Pump Control (12V, 2A)

```
GPIO 20 Water Pump Control:
┌────────────────────────────────────────┐
│                12V Supply              │
│                    │                   │
│              ┌─────┼─────┐             │
│              │ Water Pump │             │
│              │     (-)    │             │
│              └─────┼─────┘             │
│                    │                   │
│               IRF540N MOSFET           │
│               Drain │                  │
│                     │                  │
│ GPIO 20 ──220Ω──┬── Gate               │
│                 │                      │
│            10kΩ │   Source              │
│                 │     │                │
│               GND ────┴── GND          │
│                                        │
│ Protection: 1N4007 Flyback Diode      │
│ Fuse: 3A Fast-blow                    │
└────────────────────────────────────────┘
```

### 2. Water Valve Control (5V, 500mA each)

```
GPIO 21-24 Valve Control (4 identical circuits):
┌────────────────────────────────────┐
│              5V Supply             │
│                 │                  │
│           ┌─────┼─────┐            │
│           │ Water Valve │           │
│           │     (+)     │           │
│           └─────┼─────┘            │
│                 │                  │
│            BC547 NPN               │
│            Collector               │
│                 │                  │
│ GPIO 2x ─4.7kΩ─┬─ Base             │
│                │                   │
│           10kΩ │  Emitter          │
│                │     │             │
│              GND ────┴─ GND        │
│                                    │
│ Protection: 1N4148 Flyback Diode  │
└────────────────────────────────────┘
```

### 3. LED Strip Control (24V, 50W PWM)

```
GPIO 18 LED Strip PWM Control:
┌─────────────────────────────────────────┐
│                24V Supply               │
│                    │                    │
│              ┌─────┼─────┐              │
│              │ LED Strip  │              │
│              │    (-)     │              │
│              └─────┼─────┘              │
│                    │                    │
│               TIP120 Darlington         │
│               Collector                 │
│                    │                    │
│ GPIO 18 ──1kΩ───── Base                 │
│                                         │
│                  Emitter                │
│                    │                    │
│                  GND ────── GND         │
│                                         │
│ Heat Sink: TO-220 with ≥10°C/W         │
│ PWM Frequency: 1kHz                     │
│ Duty Cycle: 0-100%                     │
└─────────────────────────────────────────┘
```

### 4. Status LED Indicators

```
Status LEDs (GPIO 5, 6, 13):
┌─────────────────────────────┐
│ GPIO 5 ──220Ω──┬── Red LED  │ ──── GND (System Status)
│                                    │
│ GPIO 6 ──220Ω──┬── Green LED │ ──── GND (Plant Health)
│                                    │
│ GPIO 13 ─220Ω──┬── Blue LED  │ ──── GND (Network Status)
└─────────────────────────────┘

LED Specifications:
- Forward Voltage: 2.0-3.3V
- Forward Current: 15mA
- Resistor: 220Ω (limits current to ~10mA)
```

## 🔧 Hardware Assembly Instructions

### PCB Layout Recommendations

```
Recommended PCB Stack-up (2-layer):
┌─────────────────────────────────────┐
│ Top Layer (Components)              │
│ ├── Signal traces (GPIO, I2C, SPI) │
│ ├── Component placement             │
│ └── Via connections                 │
│                                     │
│ Bottom Layer (Power & Ground)       │
│ ├── Ground plane (continuous)      │
│ ├── Power distribution (3.3V, 5V)  │
│ └── Heat dissipation copper pour   │
└─────────────────────────────────────┘
```

### Component Placement Guidelines

1. **Power Section**:
   - Place power regulators close to Pi connector
   - Use proper heat sinks for switching regulators
   - Include bypass capacitors (100nF ceramic + 10μF tantalum)

2. **Sensor Interface**:
   - Keep analog section away from switching circuits
   - Use star ground configuration
   - Include test points for debugging

3. **Actuator Control**:
   - Isolate high-power switching from digital logic
   - Include flyback diodes for inductive loads
   - Use proper gauge wires for current capacity

### Cable Specifications

| Connection Type | Cable Spec | Max Length | Notes |
|-----------------|------------|------------|--------|
| **Power (5V/3A)** | 18 AWG | 2m | Include voltage drop calculation |
| **GPIO Control** | 22 AWG | 1m | Twisted pair for noise immunity |
| **I2C Bus** | 22 AWG | 3m | Twisted pair, 4.7kΩ pull-ups |
| **SPI Bus** | 24 AWG | 1m | Use ribbon cable with ground |
| **Sensor Analog** | Shielded 24 AWG | 2m | Shield connected to analog ground |
| **High Power (24V)** | 16 AWG | 3m | Use separate conduit from logic |

## 🧪 Testing and Validation

### Hardware Test Sequence

```bash
# 1. Power Supply Test
# Verify all voltage rails with multimeter
3.3V: 3.2V - 3.4V ✓
5.0V: 4.75V - 5.25V ✓
12V: 11.5V - 12.5V ✓
24V: 23V - 25V ✓

# 2. GPIO Function Test
sudo /opt/plant-wall-control/scripts/hardware-test.sh --gpio

# 3. I2C Device Detection
i2cdetect -y 1
# Expected: TSL2591 at 0x29, OLED at 0x3c (if installed)

# 4. SPI Communication Test
# Test MCP3008 ADC communication
sudo /opt/plant-wall-control/scripts/hardware-test.sh --spi

# 5. Sensor Reading Test
# Verify all sensors produce valid readings
sudo /opt/plant-wall-control/scripts/hardware-test.sh --sensors

# 6. Actuator Control Test
# Test pump, valves, and LED control (without water)
sudo /opt/plant-wall-control/scripts/hardware-test.sh --actuators
```

### Calibration Procedures

#### Soil Moisture Sensor Calibration

```bash
# 1. Dry calibration (air)
# Place sensors in dry air for 10 minutes
# Record ADC values (should be 850-1023)

# 2. Wet calibration (distilled water)
# Submerge sensors in distilled water
# Record ADC values (should be 400-500)

# 3. Update calibration in config file
sudo nano /etc/plant-wall-control/config.yaml

hardware:
  sensors:
    soil_moisture:
      module_1:
        dry_value: 920
        wet_value: 450
        pin_channel: 0
```

#### pH/EC Sensor Calibration

```bash
# pH Calibration (3-point)
# 1. pH 4.00 buffer → Record voltage
# 2. pH 7.00 buffer → Record voltage  
# 3. pH 10.00 buffer → Record voltage
# Calculate slope and offset

# EC Calibration (2-point)
# 1. Distilled water (0 μS/cm) → Record voltage
# 2. 1413 μS/cm standard → Record voltage
# Calculate conversion factor
```

## ⚠️ Safety Considerations

### Electrical Safety

1. **Isolation**:
   - Use optocouplers for high-voltage switching
   - Separate digital ground from power ground
   - Include fuses on all power rails

2. **ESD Protection**:
   - TVS diodes on external connections
   - Proper grounding of enclosure
   - Anti-static procedures during assembly

3. **Water Protection**:
   - IP65-rated enclosure for electronics
   - Waterproof connectors for external sensors
   - GFCI protection for AC power

### Operational Safety

1. **Emergency Stop**:
   - Hardware emergency stop button (GPIO 25)
   - Software-based emergency procedures
   - Fail-safe modes for all actuators

2. **Monitoring**:
   - Temperature monitoring of components
   - Over-current protection
   - Water leak detection

3. **Maintenance**:
   - Regular inspection schedule
   - Component replacement guidelines
   - Backup and recovery procedures

## 🔍 Troubleshooting Common Issues

### GPIO Not Responding

```bash
# Check GPIO export/permissions
ls -la /sys/class/gpio/

# Verify group membership
groups $USER  # Should include 'gpio'

# Test direct GPIO control
echo 18 | sudo tee /sys/class/gpio/export
echo out | sudo tee /sys/class/gpio/gpio18/direction
echo 1 | sudo tee /sys/class/gpio/gpio18/value
```

### I2C Device Not Found

```bash
# Check I2C interface enabled
sudo raspi-config nonint get_i2c  # Should return 0

# Scan for devices
i2cdetect -y 1

# Check pull-up resistors
# Measure voltage on SDA/SCL (should be 3.3V when idle)

# Check wiring connections
# Verify continuity with multimeter
```

### SPI Communication Errors

```bash
# Verify SPI interface
ls /dev/spi*  # Should show spidev0.0

# Check MCP3008 wiring
# Verify VDD=3.3V, VSS=GND, VREF=3.3V

# Test with reduced clock speed
# Add to config.txt: dtparam=spi=on,speed=500000
```

### ADC Reading Issues

```bash
# Check reference voltage
# VREF should be stable 3.3V

# Verify input voltage range
# Input should be 0V to VREF (3.3V)

# Test with known voltage
# Use voltage divider to apply known voltage to ADC
```

---

**Hardware Integration Guide for Plant Wall Control System**

*This document covers the complete hardware setup for MVP prototype (4 plant modules). For production deployment and troubleshooting, refer to the main project documentation.*