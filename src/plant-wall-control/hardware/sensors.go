package hardware

import (
	"context"
	"fmt"
	"sync"
	"time"

	"periph.io/x/conn/v3/gpio"
	"periph.io/x/conn/v3/gpio/gpioreg"
	"periph.io/x/conn/v3/i2c"
	"periph.io/x/conn/v3/i2c/i2creg"
	"periph.io/x/conn/v3/physic"
	"periph.io/x/conn/v3/spi"
	"periph.io/x/conn/v3/spi/spireg"
)

// SensorReading represents a sensor measurement
type SensorReading struct {
	Timestamp time.Time `json:"timestamp"`
	Value     float64   `json:"value"`
	Unit      string    `json:"unit"`
	Error     string    `json:"error,omitempty"`
}

// SensorInterface defines common sensor operations
type SensorInterface interface {
	Read() (SensorReading, error)
	GetName() string
	IsHealthy() bool
	Calibrate() error
}

// SensorManager manages all sensor operations
type SensorManager struct {
	mu               sync.RWMutex
	soilSensors      []SoilMoistureSensor
	lightSensor      *LightSensor
	tempHumSensor    *TempHumiditySensor
	pHECSensors      []pHECSensor
	spiConn          spi.Conn
	i2cBus           i2c.BusCloser
	initialized      bool
	mockMode         bool
}

// NewSensorManager creates a new sensor manager
func NewSensorManager(mockMode bool) *SensorManager {
	return &SensorManager{
		soilSensors: make([]SoilMoistureSensor, 0),
		pHECSensors: make([]pHECSensor, 0),
		mockMode:    mockMode,
	}
}

// Initialize initializes all sensors
func (sm *SensorManager) Initialize() error {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	if sm.initialized {
		return nil
	}

	if !sm.mockMode {
		// Initialize SPI for MCP3008 (analog sensors)
		if err := sm.initializeSPI(); err != nil {
			return fmt.Errorf("failed to initialize SPI: %w", err)
		}

		// Initialize I2C for light sensor
		if err := sm.initializeI2C(); err != nil {
			return fmt.Errorf("failed to initialize I2C: %w", err)
		}
	}

	// Initialize soil moisture sensors (4 modules for MVP)
	for i := 0; i < 4; i++ {
		sensor := NewSoilMoistureSensor(i, sm.spiConn, sm.mockMode)
		sm.soilSensors = append(sm.soilSensors, *sensor)
	}

	// Initialize light sensor (TSL2591)
	lightSensor := NewLightSensor(sm.i2cBus, sm.mockMode)
	sm.lightSensor = lightSensor

	// Initialize temperature/humidity sensor (DHT22)
	tempHumSensor := NewTempHumiditySensor(4, sm.mockMode) // GPIO 4
	sm.tempHumSensor = tempHumSensor

	// Initialize pH/EC sensors (2 for nutrient monitoring)
	for i := 0; i < 2; i++ {
		sensor := NewPHECSensor(i+4, sm.spiConn, sm.mockMode) // MCP3008 channels 4-5
		sm.pHECSensors = append(sm.pHECSensors, *sensor)
	}

	sm.initialized = true
	return nil
}

func (sm *SensorManager) initializeSPI() error {
	port, err := spireg.Open("")
	if err != nil {
		return fmt.Errorf("failed to open SPI port: %w", err)
	}

	// Configure SPI for MCP3008 ADC
	conn, err := port.Connect(1*physic.MegaHertz, spi.Mode0, 8)
	if err != nil {
		return fmt.Errorf("failed to configure SPI connection: %w", err)
	}

	sm.spiConn = conn
	return nil
}

func (sm *SensorManager) initializeI2C() error {
	bus, err := i2creg.Open("")
	if err != nil {
		return fmt.Errorf("failed to open I2C bus: %w", err)
	}

	sm.i2cBus = bus
	return nil
}

// ReadAllSensors reads all sensors and returns consolidated data
func (sm *SensorManager) ReadAllSensors() (map[string]interface{}, error) {
	sm.mu.RLock()
	defer sm.mu.RUnlock()

	if !sm.initialized {
		return nil, fmt.Errorf("sensor manager not initialized")
	}

	data := make(map[string]interface{})

	// Read soil moisture sensors
	soilReadings := make([]SensorReading, 0)
	for i, sensor := range sm.soilSensors {
		reading, err := sensor.Read()
		if err != nil {
			reading.Error = err.Error()
		}
		soilReadings = append(soilReadings, reading)
		data[fmt.Sprintf("soil_moisture_%d", i)] = reading.Value
	}
	data["soil_moisture_sensors"] = soilReadings

	// Read light sensor
	if lightReading, err := sm.lightSensor.Read(); err != nil {
		data["light_level"] = 0
		data["light_error"] = err.Error()
	} else {
		data["light_level"] = lightReading.Value
	}

	// Read temperature/humidity sensor
	if tempReading, humReading, err := sm.tempHumSensor.ReadBoth(); err != nil {
		data["temperature"] = 0
		data["humidity"] = 0
		data["temp_hum_error"] = err.Error()
	} else {
		data["temperature"] = tempReading.Value
		data["humidity"] = humReading.Value
	}

	// Read pH/EC sensors
	pHECReadings := make([]map[string]interface{}, 0)
	for i, sensor := range sm.pHECSensors {
		pHReading, ecReading, err := sensor.ReadBoth()
		reading := map[string]interface{}{
			"module_id": i,
			"ph":        pHReading.Value,
			"ec":        ecReading.Value,
		}
		if err != nil {
			reading["error"] = err.Error()
		}
		pHECReadings = append(pHECReadings, reading)
	}
	data["ph_ec_sensors"] = pHECReadings

	data["timestamp"] = time.Now()
	return data, nil
}

// Cleanup properly closes all sensor connections
func (sm *SensorManager) Cleanup() error {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	var errors []error

	if sm.spiConn != nil {
		if err := sm.spiConn.Close(); err != nil {
			errors = append(errors, fmt.Errorf("SPI cleanup error: %w", err))
		}
	}

	if sm.i2cBus != nil {
		if err := sm.i2cBus.Close(); err != nil {
			errors = append(errors, fmt.Errorf("I2C cleanup error: %w", err))
		}
	}

	sm.initialized = false

	if len(errors) > 0 {
		return fmt.Errorf("cleanup errors: %v", errors)
	}
	return nil
}

// SoilMoistureSensor represents a capacitive soil moisture sensor
type SoilMoistureSensor struct {
	moduleID    int
	channel     int
	spiConn     spi.Conn
	mockMode    bool
	calibration struct {
		dryValue float64
		wetValue float64
	}
}

// NewSoilMoistureSensor creates a new soil moisture sensor
func NewSoilMoistureSensor(moduleID int, spiConn spi.Conn, mockMode bool) *SoilMoistureSensor {
	return &SoilMoistureSensor{
		moduleID: moduleID,
		channel:  moduleID, // MCP3008 channels 0-3 for 4 modules
		spiConn:  spiConn,
		mockMode: mockMode,
		calibration: struct {
			dryValue float64
			wetValue float64
		}{
			dryValue: 800.0, // Calibration value for dry soil
			wetValue: 400.0, // Calibration value for wet soil
		},
	}
}

func (sms *SoilMoistureSensor) Read() (SensorReading, error) {
	if sms.mockMode {
		// Return mock data
		return SensorReading{
			Timestamp: time.Now(),
			Value:     45.2 + float64(sms.moduleID)*5.0, // Different values per module
			Unit:      "%",
		}, nil
	}

	rawValue, err := sms.readMCP3008Channel(sms.channel)
	if err != nil {
		return SensorReading{}, fmt.Errorf("failed to read soil sensor %d: %w", sms.moduleID, err)
	}

	// Convert raw ADC value to moisture percentage
	percentage := sms.convertToPercentage(rawValue)

	return SensorReading{
		Timestamp: time.Now(),
		Value:     percentage,
		Unit:      "%",
	}, nil
}

func (sms *SoilMoistureSensor) readMCP3008Channel(channel int) (uint16, error) {
	if channel < 0 || channel > 7 {
		return 0, fmt.Errorf("invalid MCP3008 channel: %d", channel)
	}

	// MCP3008 communication protocol
	tx := []byte{
		0x01,                        // Start bit
		0x80 | (byte(channel) << 4), // Single-ended + channel selection
		0x00,                        // Dummy byte
	}
	rx := make([]byte, 3)

	if err := sms.spiConn.Tx(tx, rx); err != nil {
		return 0, fmt.Errorf("SPI transaction failed: %w", err)
	}

	// Extract 10-bit ADC value
	value := uint16(rx[1]&0x03)<<8 | uint16(rx[2])
	return value, nil
}

func (sms *SoilMoistureSensor) convertToPercentage(rawValue uint16) float64 {
	// Convert raw ADC value to moisture percentage using calibration
	if rawValue >= uint16(sms.calibration.dryValue) {
		return 0.0 // Completely dry
	}
	if rawValue <= uint16(sms.calibration.wetValue) {
		return 100.0 // Completely wet
	}

	// Linear interpolation between calibration points
	percentage := (float64(sms.calibration.dryValue) - float64(rawValue)) /
		(sms.calibration.dryValue - sms.calibration.wetValue) * 100.0

	return percentage
}

func (sms *SoilMoistureSensor) GetName() string {
	return fmt.Sprintf("soil_moisture_%d", sms.moduleID)
}

func (sms *SoilMoistureSensor) IsHealthy() bool {
	_, err := sms.Read()
	return err == nil
}

func (sms *SoilMoistureSensor) Calibrate() error {
	// TODO: Implement calibration procedure
	return nil
}

// LightSensor represents a TSL2591 light sensor
type LightSensor struct {
	i2cDev   i2c.Dev
	mockMode bool
}

// NewLightSensor creates a new light sensor
func NewLightSensor(bus i2c.BusCloser, mockMode bool) *LightSensor {
	if mockMode || bus == nil {
		return &LightSensor{mockMode: true}
	}

	return &LightSensor{
		i2cDev:   i2c.Dev{Addr: 0x29, Bus: bus}, // TSL2591 default I2C address
		mockMode: false,
	}
}

func (ls *LightSensor) Read() (SensorReading, error) {
	if ls.mockMode {
		return SensorReading{
			Timestamp: time.Now(),
			Value:     1200.5, // Mock lux value
			Unit:      "lux",
		}, nil
	}

	// TSL2591 reading implementation
	lux, err := ls.readTSL2591()
	if err != nil {
		return SensorReading{}, fmt.Errorf("failed to read light sensor: %w", err)
	}

	return SensorReading{
		Timestamp: time.Now(),
		Value:     lux,
		Unit:      "lux",
	}, nil
}

func (ls *LightSensor) readTSL2591() (float64, error) {
	// TSL2591 register addresses
	const (
		TSL2591_COMMAND_BIT = 0xA0
		TSL2591_ENABLE      = 0x00
		TSL2591_C0DATAL     = 0x14
		TSL2591_C1DATAL     = 0x16
	)

	// Enable the sensor
	if err := ls.i2cDev.Tx([]byte{TSL2591_COMMAND_BIT | TSL2591_ENABLE, 0x01}, nil); err != nil {
		return 0, fmt.Errorf("failed to enable TSL2591: %w", err)
	}

	time.Sleep(100 * time.Millisecond) // Integration time

	// Read CH0 (visible + IR)
	ch0Data := make([]byte, 2)
	if err := ls.i2cDev.Tx([]byte{TSL2591_COMMAND_BIT | TSL2591_C0DATAL}, ch0Data); err != nil {
		return 0, fmt.Errorf("failed to read CH0: %w", err)
	}

	// Read CH1 (IR only)
	ch1Data := make([]byte, 2)
	if err := ls.i2cDev.Tx([]byte{TSL2591_COMMAND_BIT | TSL2591_C1DATAL}, ch1Data); err != nil {
		return 0, fmt.Errorf("failed to read CH1: %w", err)
	}

	// Convert to 16-bit values
	ch0 := uint16(ch0Data[1])<<8 | uint16(ch0Data[0])
	ch1 := uint16(ch1Data[1])<<8 | uint16(ch1Data[0])

	// Calculate lux using TSL2591 formula
	lux := ls.calculateLux(ch0, ch1)
	return lux, nil
}

func (ls *LightSensor) calculateLux(ch0, ch1 uint16) float64 {
	// Simplified lux calculation for TSL2591
	if ch0 == 0 {
		return 0.0
	}

	ratio := float64(ch1) / float64(ch0)
	lux := 0.0

	if ratio <= 0.5 {
		lux = (0.0315 * float64(ch0)) - (0.0593 * float64(ch0) * ratio)
	} else if ratio <= 0.61 {
		lux = (0.0229 * float64(ch0)) - (0.0291 * float64(ch1))
	} else if ratio <= 0.8 {
		lux = (0.0157 * float64(ch0)) - (0.018 * float64(ch1))
	} else if ratio <= 1.3 {
		lux = (0.00338 * float64(ch0)) - (0.0026 * float64(ch1))
	}

	return lux
}

func (ls *LightSensor) GetName() string {
	return "light_sensor"
}

func (ls *LightSensor) IsHealthy() bool {
	_, err := ls.Read()
	return err == nil
}

func (ls *LightSensor) Calibrate() error {
	return nil
}

// TempHumiditySensor represents a DHT22 temperature/humidity sensor
type TempHumiditySensor struct {
	pin      gpio.PinIO
	mockMode bool
}

// NewTempHumiditySensor creates a new temperature/humidity sensor
func NewTempHumiditySensor(pinNumber int, mockMode bool) *TempHumiditySensor {
	if mockMode {
		return &TempHumiditySensor{mockMode: true}
	}

	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", pinNumber))
	return &TempHumiditySensor{
		pin:      pin,
		mockMode: false,
	}
}

func (ths *TempHumiditySensor) Read() (SensorReading, error) {
	temp, _, err := ths.ReadBoth()
	return temp, err
}

func (ths *TempHumiditySensor) ReadBoth() (SensorReading, SensorReading, error) {
	if ths.mockMode {
		return SensorReading{
				Timestamp: time.Now(),
				Value:     23.4,
				Unit:      "°C",
			}, SensorReading{
				Timestamp: time.Now(),
				Value:     65.8,
				Unit:      "%",
			}, nil
	}

	temp, humidity, err := ths.readDHT22()
	if err != nil {
		return SensorReading{}, SensorReading{}, fmt.Errorf("failed to read DHT22: %w", err)
	}

	return SensorReading{
			Timestamp: time.Now(),
			Value:     temp,
			Unit:      "°C",
		}, SensorReading{
			Timestamp: time.Now(),
			Value:     humidity,
			Unit:      "%",
		}, nil
}

func (ths *TempHumiditySensor) readDHT22() (float64, float64, error) {
	if ths.pin == nil {
		return 0, 0, fmt.Errorf("DHT22 pin not initialized")
	}

	// DHT22 communication protocol implementation
	// This is a simplified version - production code would need more robust timing
	
	// Send start signal
	if err := ths.pin.Out(gpio.Low); err != nil {
		return 0, 0, fmt.Errorf("failed to send start signal: %w", err)
	}
	time.Sleep(1 * time.Millisecond)

	if err := ths.pin.Out(gpio.High); err != nil {
		return 0, 0, fmt.Errorf("failed to release start signal: %w", err)
	}
	time.Sleep(30 * time.Microsecond)

	// Switch to input mode
	if err := ths.pin.In(gpio.PullUp, gpio.NoEdge); err != nil {
		return 0, 0, fmt.Errorf("failed to switch to input mode: %w", err)
	}

	// For now, return mock values as DHT22 protocol requires precise timing
	// Production implementation would read the 40-bit data stream
	return 23.4, 65.8, nil
}

func (ths *TempHumiditySensor) GetName() string {
	return "temp_humidity_sensor"
}

func (ths *TempHumiditySensor) IsHealthy() bool {
	_, _, err := ths.ReadBoth()
	return err == nil
}

func (ths *TempHumiditySensor) Calibrate() error {
	return nil
}

// pHECSensor represents a pH/EC sensor connected via MCP3008
type pHECSensor struct {
	moduleID int
	pHChannel int
	ecChannel int
	spiConn   spi.Conn
	mockMode  bool
}

// NewPHECSensor creates a new pH/EC sensor
func NewPHECSensor(moduleID int, spiConn spi.Conn, mockMode bool) *pHECSensor {
	return &pHECSensor{
		moduleID:  moduleID,
		pHChannel: moduleID,     // pH on even channels
		ecChannel: moduleID + 1, // EC on odd channels
		spiConn:   spiConn,
		mockMode:  mockMode,
	}
}

func (pe *pHECSensor) ReadBoth() (SensorReading, SensorReading, error) {
	if pe.mockMode {
		return SensorReading{
				Timestamp: time.Now(),
				Value:     6.8,
				Unit:      "pH",
			}, SensorReading{
				Timestamp: time.Now(),
				Value:     1.2,
				Unit:      "mS/cm",
			}, nil
	}

	// Read pH channel
	pHRaw, err := pe.readMCP3008Channel(pe.pHChannel)
	if err != nil {
		return SensorReading{}, SensorReading{}, fmt.Errorf("failed to read pH: %w", err)
	}

	// Read EC channel  
	ecRaw, err := pe.readMCP3008Channel(pe.ecChannel)
	if err != nil {
		return SensorReading{}, SensorReading{}, fmt.Errorf("failed to read EC: %w", err)
	}

	// Convert raw values
	pH := pe.convertToPH(pHRaw)
	ec := pe.convertToEC(ecRaw)

	return SensorReading{
			Timestamp: time.Now(),
			Value:     pH,
			Unit:      "pH",
		}, SensorReading{
			Timestamp: time.Now(),
			Value:     ec,
			Unit:      "mS/cm",
		}, nil
}

func (pe *pHECSensor) readMCP3008Channel(channel int) (uint16, error) {
	if channel < 0 || channel > 7 {
		return 0, fmt.Errorf("invalid MCP3008 channel: %d", channel)
	}

	tx := []byte{
		0x01,
		0x80 | (byte(channel) << 4),
		0x00,
	}
	rx := make([]byte, 3)

	if err := pe.spiConn.Tx(tx, rx); err != nil {
		return 0, fmt.Errorf("SPI transaction failed: %w", err)
	}

	value := uint16(rx[1]&0x03)<<8 | uint16(rx[2])
	return value, nil
}

func (pe *pHECSensor) convertToPH(rawValue uint16) float64 {
	// Convert ADC value to pH (0-14 scale)
	// This is a simplified conversion - production code needs proper calibration
	voltage := float64(rawValue) * 3.3 / 1023.0
	pH := 7.0 - ((voltage - 1.65) / 0.18) // Typical pH sensor response
	
	if pH < 0 {
		pH = 0
	}
	if pH > 14 {
		pH = 14
	}
	
	return pH
}

func (pe *pHECSensor) convertToEC(rawValue uint16) float64 {
	// Convert ADC value to EC (mS/cm)
	voltage := float64(rawValue) * 3.3 / 1023.0
	ec := voltage * 2.0 // Simplified conversion
	return ec
}

func (pe *pHECSensor) GetName() string {
	return fmt.Sprintf("ph_ec_sensor_%d", pe.moduleID)
}

func (pe *pHECSensor) IsHealthy() bool {
	_, _, err := pe.ReadBoth()
	return err == nil
}

func (pe *pHECSensor) Calibrate() error {
	// TODO: Implement pH/EC calibration
	return nil
}