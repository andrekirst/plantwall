package hardware

import (
	"fmt"
	"time"
)

// ExampleUsage demonstrates how to use the hardware abstraction layer
func ExampleUsage() {
	fmt.Println("=== Plant Wall Hardware Abstraction Layer Example ===")

	// Create hardware manager in mock mode for testing
	mockMode := true
	hardwareManager := NewHardwareManager(mockMode)

	// Initialize all hardware subsystems
	if err := hardwareManager.Initialize(); err != nil {
		fmt.Printf("Failed to initialize hardware: %v\n", err)
		return
	}
	defer hardwareManager.Cleanup()

	fmt.Println("✓ Hardware initialized successfully")

	// Example 1: Read all sensors
	fmt.Println("\n--- Reading Sensors ---")
	sensorData, err := hardwareManager.GetSensorManager().ReadAllSensors()
	if err != nil {
		fmt.Printf("Error reading sensors: %v\n", err)
	} else {
		fmt.Printf("Temperature: %.1f°C\n", sensorData["temperature"])
		fmt.Printf("Humidity: %.1f%%\n", sensorData["humidity"])
		fmt.Printf("Soil Moisture Module 0: %.1f%%\n", sensorData["soil_moisture_0"])
		fmt.Printf("Light Level: %.1f lux\n", sensorData["light_level"])
	}

	// Example 2: Control lighting
	fmt.Println("\n--- Controlling Lighting ---")
	lightingSystem := hardwareManager.GetLightingSystem()
	
	// Turn on lights at 50% brightness
	if err := lightingSystem.TurnOn(128); err != nil {
		fmt.Printf("Error turning on lights: %v\n", err)
	} else {
		fmt.Println("✓ Lights turned on at 50% brightness")
	}

	// Start a sunrise program
	if err := lightingSystem.StartProgram("sunrise"); err != nil {
		fmt.Printf("Error starting sunrise program: %v\n", err)
	} else {
		fmt.Println("✓ Sunrise program started")
	}

	// Check lighting status
	lightingStatus := lightingSystem.GetStatus()
	fmt.Printf("Lighting Status - On: %t, Brightness: %d, Power: %.1fW\n", 
		lightingStatus.IsOn, lightingStatus.Brightness, lightingStatus.PowerUsage)

	// Example 3: Control watering
	fmt.Println("\n--- Controlling Watering ---")
	wateringSystem := hardwareManager.GetWateringSystem()

	// Water module 0 for 30 seconds
	if err := wateringSystem.StartWatering(0, 30*time.Second); err != nil {
		fmt.Printf("Error starting watering: %v\n", err)
	} else {
		fmt.Println("✓ Started watering module 0 for 30 seconds")
	}

	// Check watering status
	wateringStatus := wateringSystem.GetStatus()
	fmt.Printf("Watering Status - Pump: %t, Water Level: %.1f%%, Flow: %.1f L/min\n",
		wateringStatus.PumpActive, wateringStatus.WaterLevel, wateringStatus.FlowRate)

	// Example 4: Update display
	fmt.Println("\n--- Updating Display ---")
	displaySystem := hardwareManager.GetDisplaySystem()

	// Show custom screen
	customLines := []string{
		"Plant Wall Active",
		"4 Modules Online",
		"Watering: Module 0",
		"Light: Sunrise Mode",
		"All Systems OK",
		time.Now().Format("15:04:05"),
	}
	if err := displaySystem.ShowCustomScreen("Status", customLines); err != nil {
		fmt.Printf("Error updating display: %v\n", err)
	} else {
		fmt.Println("✓ Display updated with custom screen")
	}

	// Set alert level based on conditions
	displaySystem.SetAlert(AlertNone) // All good
	fmt.Println("✓ Display alert set to normal (green)")

	// Example 5: Get complete system status
	fmt.Println("\n--- Complete System Status ---")
	systemStatus, err := hardwareManager.GetSystemStatus()
	if err != nil {
		fmt.Printf("Error getting system status: %v\n", err)
	} else {
		fmt.Printf("System Status Retrieved:\n")
		fmt.Printf("- Mock Mode: %t\n", systemStatus["mock_mode"])
		fmt.Printf("- Timestamp: %s\n", systemStatus["timestamp"])
		
		if sensors, ok := systemStatus["sensors"].(map[string]interface{}); ok {
			fmt.Printf("- Temperature: %.1f°C\n", sensors["temperature"])
			fmt.Printf("- Humidity: %.1f%%\n", sensors["humidity"])
		}
	}

	// Example 6: Health check
	fmt.Println("\n--- Health Check ---")
	health := hardwareManager.PerformHealthCheck()
	fmt.Printf("Subsystem Health:\n")
	fmt.Printf("- Sensors: %t\n", health["sensors"])
	fmt.Printf("- Watering: %t\n", health["watering"])
	fmt.Printf("- Lighting: %t\n", health["lighting"])
	fmt.Printf("- Display: %t\n", health["display"])

	fmt.Println("\n✓ Hardware example completed successfully")
}

// ExampleIntegrationWithMainGo shows how to integrate with the existing main.go
func ExampleIntegrationWithMainGo() {
	fmt.Println("\n=== Integration Example with main.go ===")
	
	// This shows how to modify the existing main.go to use the hardware layer
	fmt.Println(`
To integrate with your existing main.go, replace the TODO comments with:

1. In main() function, after loading config:
   // Initialize hardware (set mockMode based on config or environment)
   mockMode := os.Getenv("MOCK_MODE") == "true"
   hardwareManager := hardware.NewHardwareManager(mockMode)
   if err := hardwareManager.Initialize(); err != nil {
       log.Fatalf("Failed to initialize hardware: %v", err)
   }
   defer hardwareManager.Cleanup()

2. In getStatus() function:
   // Replace static values with real sensor data
   systemStatus, err := hardwareManager.GetSystemStatus()
   if err != nil {
       http.Error(w, "Failed to get system status", http.StatusInternalServerError)
       return
   }
   
   status := SystemStatus{
       Timestamp:     time.Now(),
       LightingOn:    systemStatus["lighting"].(hardware.LightingStatus).IsOn,
       WaterLevel:    systemStatus["watering"].(hardware.WateringStatus).WaterLevel,
       NutrientLevel: 68.2, // From pH/EC sensors
       Temperature:   systemStatus["sensors"].(map[string]interface{})["temperature"].(float64),
       Humidity:      systemStatus["sensors"].(map[string]interface{})["humidity"].(float64),
       SoilMoisture:  systemStatus["sensors"].(map[string]interface{})["soil_moisture_0"].(float64),
   }

3. In toggleLighting() function:
   lightingSystem := hardwareManager.GetLightingSystem()
   if err := lightingSystem.TurnOn(255); err != nil {
       http.Error(w, "Failed to control lighting", http.StatusInternalServerError)
       return
   }

4. In triggerWatering() function:
   wateringSystem := hardwareManager.GetWateringSystem()
   if err := wateringSystem.StartWatering(0, 30*time.Second); err != nil {
       http.Error(w, "Failed to start watering", http.StatusInternalServerError)
       return
   }
`)
}

// Production Hardware Configuration Example
func ExampleProductionConfig() {
	fmt.Println("\n=== Production Configuration Example ===")
	
	fmt.Println(`
For production deployment on Raspberry Pi Zero 2W:

1. Enable hardware mode by setting environment variable:
   export MOCK_MODE=false

2. Ensure GPIO permissions:
   sudo usermod -a -G gpio $USER
   # Or run with sudo for testing

3. Hardware connections per GPIO pin mapping:
   - GPIO 18: LED Strip PWM (24V driver)
   - GPIO 19: LED Strip Enable  
   - GPIO 20: Water Pump Relay (12V)
   - GPIO 21-24: Valve Controls (5V)
   - GPIO 4: DHT22 Data Pin
   - GPIO 17: Flow Sensor Interrupt
   - GPIO 5,6,13: Status LEDs (Red, Green, Blue)
   - SPI: MCP3008 for analog sensors
   - I2C: TSL2591 light sensor, optional OLED display

4. Install required system packages:
   sudo apt update
   sudo apt install -y i2c-tools spi-tools
   
   # Enable I2C and SPI in raspi-config
   sudo raspi-config
   # Interface Options -> I2C -> Enable
   # Interface Options -> SPI -> Enable

5. Test GPIO access:
   # Check I2C devices
   sudo i2cdetect -y 1
   
   # Should show TSL2591 at 0x29, OLED at 0x3C (if connected)
   
6. Calibration procedures:
   - Run soil moisture calibration in dry/wet conditions
   - Calibrate pH sensors with reference solutions
   - Set water level sensor min/max values
   - Adjust lighting PWM frequency if needed
`)
}