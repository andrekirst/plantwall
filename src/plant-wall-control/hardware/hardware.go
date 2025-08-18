// Package hardware provides hardware abstraction layer for the Plant Wall Control System
// This package includes modules for sensors, watering, lighting, and display control
// optimized for Raspberry Pi Zero 2W with GPIO control via periph.io library.
package hardware

import (
	"context"
	"fmt"
	"sync"
	"time"

	"periph.io/x/host/v3"
)

// HardwareManager coordinates all hardware subsystems
type HardwareManager struct {
	mu             sync.RWMutex
	sensorManager  *SensorManager
	wateringSystem *WateringSystem
	lightingSystem *LightingSystem
	displaySystem  *DisplaySystem
	mockMode       bool
	initialized    bool
	shutdownCtx    context.Context
	shutdownCancel context.CancelFunc
}

// NewHardwareManager creates a new hardware manager
func NewHardwareManager(mockMode bool) *HardwareManager {
	ctx, cancel := context.WithCancel(context.Background())
	
	return &HardwareManager{
		mockMode:       mockMode,
		shutdownCtx:    ctx,
		shutdownCancel: cancel,
	}
}

// Initialize initializes all hardware subsystems
func (hm *HardwareManager) Initialize() error {
	hm.mu.Lock()
	defer hm.mu.Unlock()

	if hm.initialized {
		return nil
	}

	// Initialize periph.io host (only for real hardware)
	if !hm.mockMode {
		if _, err := host.Init(); err != nil {
			return fmt.Errorf("failed to initialize periph.io host: %w", err)
		}
	}

	// Initialize sensor manager
	sensorManager := NewSensorManager(hm.mockMode)
	if err := sensorManager.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize sensor manager: %w", err)
	}
	hm.sensorManager = sensorManager

	// Initialize watering system
	wateringSystem := NewWateringSystem(hm.mockMode)
	if err := wateringSystem.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize watering system: %w", err)
	}
	hm.wateringSystem = wateringSystem

	// Initialize lighting system
	lightingSystem := NewLightingSystem(hm.mockMode)
	if err := lightingSystem.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize lighting system: %w", err)
	}
	hm.lightingSystem = lightingSystem

	// Initialize display system
	displaySystem := NewDisplaySystem(hm.mockMode)
	if err := displaySystem.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize display system: %w", err)
	}
	hm.displaySystem = displaySystem

	// Start system monitoring
	go hm.monitoringLoop()

	hm.initialized = true
	return nil
}

// GetSensorManager returns the sensor manager
func (hm *HardwareManager) GetSensorManager() *SensorManager {
	hm.mu.RLock()
	defer hm.mu.RUnlock()
	return hm.sensorManager
}

// GetWateringSystem returns the watering system
func (hm *HardwareManager) GetWateringSystem() *WateringSystem {
	hm.mu.RLock()
	defer hm.mu.RUnlock()
	return hm.wateringSystem
}

// GetLightingSystem returns the lighting system
func (hm *HardwareManager) GetLightingSystem() *LightingSystem {
	hm.mu.RLock()
	defer hm.mu.RUnlock()
	return hm.lightingSystem
}

// GetDisplaySystem returns the display system
func (hm *HardwareManager) GetDisplaySystem() *DisplaySystem {
	hm.mu.RLock()
	defer hm.mu.RUnlock()
	return hm.displaySystem
}

// GetSystemStatus returns consolidated system status
func (hm *HardwareManager) GetSystemStatus() (map[string]interface{}, error) {
	hm.mu.RLock()
	defer hm.mu.RUnlock()

	if !hm.initialized {
		return nil, fmt.Errorf("hardware manager not initialized")
	}

	status := make(map[string]interface{})

	// Get sensor data
	if sensorData, err := hm.sensorManager.ReadAllSensors(); err != nil {
		status["sensor_error"] = err.Error()
	} else {
		status["sensors"] = sensorData
	}

	// Get watering system status
	status["watering"] = hm.wateringSystem.GetStatus()

	// Get lighting system status
	status["lighting"] = hm.lightingSystem.GetStatus()

	// Get display system status
	status["display"] = hm.displaySystem.GetStatus()

	status["timestamp"] = time.Now()
	status["mock_mode"] = hm.mockMode

	return status, nil
}

// EmergencyStop immediately stops all hardware operations
func (hm *HardwareManager) EmergencyStop() error {
	hm.mu.Lock()
	defer hm.mu.Unlock()

	var errors []error

	// Emergency stop watering system
	if hm.wateringSystem != nil {
		if err := hm.wateringSystem.EmergencyStop(); err != nil {
			errors = append(errors, fmt.Errorf("watering emergency stop failed: %w", err))
		}
	}

	// Turn off lighting
	if hm.lightingSystem != nil {
		if err := hm.lightingSystem.TurnOff(); err != nil {
			errors = append(errors, fmt.Errorf("lighting shutdown failed: %w", err))
		}
	}

	// Set display to critical alert
	if hm.displaySystem != nil {
		hm.displaySystem.SetAlert(AlertCritical)
		hm.displaySystem.ShowCustomScreen("EMERGENCY", []string{
			"EMERGENCY STOP",
			"All systems halted",
			"",
			"Check system status",
			"Manual reset required",
			time.Now().Format("15:04:05"),
		})
	}

	if len(errors) > 0 {
		return fmt.Errorf("emergency stop errors: %v", errors)
	}
	return nil
}

// monitoringLoop continuously monitors system health
func (hm *HardwareManager) monitoringLoop() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-hm.shutdownCtx.Done():
			return
		case <-ticker.C:
			hm.updateSystemDisplay()
		}
	}
}

func (hm *HardwareManager) updateSystemDisplay() {
	// Get current sensor readings
	sensorData, err := hm.sensorManager.ReadAllSensors()
	if err != nil {
		return
	}

	// Extract values for display
	temperature := 0.0
	humidity := 0.0
	soilMoisture := 0.0
	waterLevel := 0.0

	if temp, ok := sensorData["temperature"].(float64); ok {
		temperature = temp
	}
	if hum, ok := sensorData["humidity"].(float64); ok {
		humidity = hum
	}
	if soil, ok := sensorData["soil_moisture_0"].(float64); ok {
		soilMoisture = soil
	}

	// Get watering status
	wateringStatus := hm.wateringSystem.GetStatus()
	waterLevel = wateringStatus.WaterLevel

	// Get lighting status
	lightingStatus := hm.lightingSystem.GetStatus()
	lightingOn := lightingStatus.IsOn

	// Update display
	hm.displaySystem.ShowSystemStatus(temperature, humidity, soilMoisture, waterLevel, lightingOn)
}

// PerformHealthCheck checks all subsystem health
func (hm *HardwareManager) PerformHealthCheck() map[string]bool {
	hm.mu.RLock()
	defer hm.mu.RUnlock()

	health := make(map[string]bool)

	// Check sensor manager
	if hm.sensorManager != nil {
		_, err := hm.sensorManager.ReadAllSensors()
		health["sensors"] = err == nil
	} else {
		health["sensors"] = false
	}

	// Check watering system
	if hm.wateringSystem != nil {
		status := hm.wateringSystem.GetStatus()
		health["watering"] = !status.EmergencyStop
	} else {
		health["watering"] = false
	}

	// Check lighting system
	if hm.lightingSystem != nil {
		status := hm.lightingSystem.GetStatus()
		health["lighting"] = status.PowerUsage >= 0 // Simple health check
	} else {
		health["lighting"] = false
	}

	// Check display system
	if hm.displaySystem != nil {
		status := hm.displaySystem.GetStatus()
		health["display"] = !status.LastUpdate.IsZero()
	} else {
		health["display"] = false
	}

	return health
}

// Cleanup properly shuts down all hardware subsystems
func (hm *HardwareManager) Cleanup() error {
	hm.shutdownCancel()
	
	hm.mu.Lock()
	defer hm.mu.Unlock()

	var errors []error

	// Cleanup in reverse order of initialization
	if hm.displaySystem != nil {
		if err := hm.displaySystem.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("display cleanup error: %w", err))
		}
	}

	if hm.lightingSystem != nil {
		if err := hm.lightingSystem.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("lighting cleanup error: %w", err))
		}
	}

	if hm.wateringSystem != nil {
		if err := hm.wateringSystem.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("watering cleanup error: %w", err))
		}
	}

	if hm.sensorManager != nil {
		if err := hm.sensorManager.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("sensor cleanup error: %w", err))
		}
	}

	hm.initialized = false

	if len(errors) > 0 {
		return fmt.Errorf("cleanup errors: %v", errors)
	}
	return nil
}

// GPIO Pin Mapping Configuration for Plant Wall MVP
//
// Raspberry Pi Zero 2W GPIO Pin Assignments:
//
// POWER & CONTROL:
// - GPIO 18: LED Strip PWM Control (Hardware PWM)
// - GPIO 19: LED Strip Enable Pin
// - GPIO 20: Water Pump Relay Control (12V)
// - GPIO 21: Plant Module 1 Valve Control
// - GPIO 22: Plant Module 2 Valve Control  
// - GPIO 23: Plant Module 3 Valve Control
// - GPIO 24: Plant Module 4 Valve Control
//
// SENSORS (Digital):
// - GPIO 4:  DHT22 Temperature/Humidity Sensor
// - GPIO 17: Flow Sensor (Interrupt-based)
//
// STATUS LEDS:
// - GPIO 5:  Status LED Red
// - GPIO 6:  Status LED Green
// - GPIO 13: Status LED Blue
//
// SPI (MCP3008 ADC for analog sensors):
// - GPIO 10: SPI MOSI
// - GPIO 9:  SPI MISO  
// - GPIO 11: SPI SCLK
// - GPIO 8:  SPI CE0 (Chip Select)
// - MCP3008 Ch0: Soil Moisture Sensor Module 1
// - MCP3008 Ch1: Soil Moisture Sensor Module 2
// - MCP3008 Ch2: Soil Moisture Sensor Module 3
// - MCP3008 Ch3: Soil Moisture Sensor Module 4
// - MCP3008 Ch4: pH Sensor
// - MCP3008 Ch5: EC Sensor
// - MCP3008 Ch6: Water Level Sensor
// - MCP3008 Ch7: Reserved
//
// I2C (Sensors & Display):
// - GPIO 2:  I2C SDA (Light Sensor TSL2591, OLED Display)
// - GPIO 3:  I2C SCL
// - TSL2591: 0x29 (Light Sensor)
// - SSD1306: 0x3C (OLED Display, optional)
//
// POWER REQUIREMENTS:
// - 5V:  Raspberry Pi, Relays, Sensors
// - 12V: Water Pump
// - 24V: LED Strips
// - 3.3V: GPIO Logic Level