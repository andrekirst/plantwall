package hardware

import (
	"context"
	"fmt"
	"sync"
	"time"

	"periph.io/x/conn/v3/gpio"
	"periph.io/x/conn/v3/gpio/gpioreg"
	"periph.io/x/conn/v3/physic"
)

// WateringStatus represents the current watering system status
type WateringStatus struct {
	PumpActive        bool      `json:"pump_active"`
	ValveOpen         bool      `json:"valve_open"`
	WaterLevel        float64   `json:"water_level"` // Percentage
	FlowRate          float64   `json:"flow_rate"`   // L/min
	LastWateringTime  time.Time `json:"last_watering_time"`
	TotalVolumeToday  float64   `json:"total_volume_today"` // Liters
	EmergencyStop     bool      `json:"emergency_stop"`
	ScheduleActive    bool      `json:"schedule_active"`
}

// WateringSchedule defines watering schedule for plant modules
type WateringSchedule struct {
	ModuleID        int           `json:"module_id"`
	Enabled         bool          `json:"enabled"`
	Duration        time.Duration `json:"duration"`        // How long to water
	Interval        time.Duration `json:"interval"`        // Time between waterings
	MoistureTarget  float64       `json:"moisture_target"` // Target soil moisture %
	LastWatered     time.Time     `json:"last_watered"`
	NextWatering    time.Time     `json:"next_watering"`
}

// WateringSystem manages the complete watering system
type WateringSystem struct {
	mu                sync.RWMutex
	pump              *WaterPump
	valves            []*WaterValve
	flowSensor        *FlowSensor
	waterLevelSensor  *WaterLevelSensor
	schedules         map[int]*WateringSchedule // moduleID -> schedule
	status            WateringStatus
	emergencyStop     bool
	mockMode          bool
	shutdownCtx       context.Context
	shutdownCancel    context.CancelFunc
}

// NewWateringSystem creates a new watering system
func NewWateringSystem(mockMode bool) *WateringSystem {
	ctx, cancel := context.WithCancel(context.Background())
	
	return &WateringSystem{
		valves:         make([]*WaterValve, 0),
		schedules:      make(map[int]*WateringSchedule),
		mockMode:       mockMode,
		shutdownCtx:    ctx,
		shutdownCancel: cancel,
		status: WateringStatus{
			LastWateringTime: time.Now().AddDate(0, 0, -1), // Yesterday
		},
	}
}

// Initialize initializes the watering system
func (ws *WateringSystem) Initialize() error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	// Initialize water pump (12V relay on GPIO 20)
	pump := NewWaterPump(20, ws.mockMode)
	if err := pump.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize water pump: %w", err)
	}
	ws.pump = pump

	// Initialize valves for 4 plant modules (GPIO 21-24)
	for i := 0; i < 4; i++ {
		valve := NewWaterValve(i, 21+i, ws.mockMode)
		if err := valve.Initialize(); err != nil {
			return fmt.Errorf("failed to initialize valve %d: %w", i, err)
		}
		ws.valves = append(ws.valves, valve)
	}

	// Initialize flow sensor (GPIO 17 with interrupts)
	flowSensor := NewFlowSensor(17, ws.mockMode)
	if err := flowSensor.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize flow sensor: %w", err)
	}
	ws.flowSensor = flowSensor

	// Initialize water level sensor (analog via MCP3008 channel 6)
	waterLevelSensor := NewWaterLevelSensor(6, ws.mockMode)
	ws.waterLevelSensor = waterLevelSensor

	// Initialize default schedules for all modules
	for i := 0; i < 4; i++ {
		ws.schedules[i] = &WateringSchedule{
			ModuleID:       i,
			Enabled:        true,
			Duration:       30 * time.Second,  // Water for 30 seconds
			Interval:       6 * time.Hour,     // Every 6 hours
			MoistureTarget: 60.0,              // Target 60% moisture
			NextWatering:   time.Now().Add(time.Hour),
		}
	}

	// Start monitoring goroutine
	go ws.monitoringLoop()

	return nil
}

// StartWatering starts watering for a specific module
func (ws *WateringSystem) StartWatering(moduleID int, duration time.Duration) error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	if ws.emergencyStop {
		return fmt.Errorf("watering system in emergency stop mode")
	}

	if moduleID < 0 || moduleID >= len(ws.valves) {
		return fmt.Errorf("invalid module ID: %d", moduleID)
	}

	// Check water level
	waterLevel, err := ws.waterLevelSensor.Read()
	if err != nil {
		return fmt.Errorf("failed to read water level: %w", err)
	}

	if waterLevel < 20.0 { // Below 20%
		return fmt.Errorf("water level too low: %.1f%%", waterLevel)
	}

	// Start pump
	if err := ws.pump.Start(); err != nil {
		return fmt.Errorf("failed to start pump: %w", err)
	}

	// Open valve for specific module
	valve := ws.valves[moduleID]
	if err := valve.Open(); err != nil {
		ws.pump.Stop() // Stop pump if valve fails
		return fmt.Errorf("failed to open valve %d: %w", moduleID, err)
	}

	// Start flow monitoring
	ws.flowSensor.StartMonitoring(ws.shutdownCtx)

	// Update status
	ws.status.PumpActive = true
	ws.status.ValveOpen = true
	ws.status.LastWateringTime = time.Now()

	// Schedule automatic stop
	go func() {
		time.Sleep(duration)
		ws.StopWatering(moduleID)
	}()

	return nil
}

// StopWatering stops watering for a specific module
func (ws *WateringSystem) StopWatering(moduleID int) error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	if moduleID < 0 || moduleID >= len(ws.valves) {
		return fmt.Errorf("invalid module ID: %d", moduleID)
	}

	// Close valve
	valve := ws.valves[moduleID]
	if err := valve.Close(); err != nil {
		return fmt.Errorf("failed to close valve %d: %w", moduleID, err)
	}

	// Check if any other valves are open
	anyValveOpen := false
	for _, v := range ws.valves {
		if v.IsOpen() {
			anyValveOpen = true
			break
		}
	}

	// Stop pump if no valves are open
	if !anyValveOpen {
		if err := ws.pump.Stop(); err != nil {
			return fmt.Errorf("failed to stop pump: %w", err)
		}
		ws.status.PumpActive = false
	}

	ws.status.ValveOpen = anyValveOpen

	// Update schedule
	if schedule, exists := ws.schedules[moduleID]; exists {
		schedule.LastWatered = time.Now()
		schedule.NextWatering = time.Now().Add(schedule.Interval)
	}

	return nil
}

// EmergencyStop immediately stops all watering operations
func (ws *WateringSystem) EmergencyStop() error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	ws.emergencyStop = true
	var errors []error

	// Stop pump
	if ws.pump != nil {
		if err := ws.pump.Stop(); err != nil {
			errors = append(errors, fmt.Errorf("failed to stop pump: %w", err))
		}
	}

	// Close all valves
	for i, valve := range ws.valves {
		if err := valve.Close(); err != nil {
			errors = append(errors, fmt.Errorf("failed to close valve %d: %w", i, err))
		}
	}

	ws.status.PumpActive = false
	ws.status.ValveOpen = false
	ws.status.EmergencyStop = true

	if len(errors) > 0 {
		return fmt.Errorf("emergency stop errors: %v", errors)
	}
	return nil
}

// ResetEmergencyStop clears the emergency stop condition
func (ws *WateringSystem) ResetEmergencyStop() error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	ws.emergencyStop = false
	ws.status.EmergencyStop = false
	return nil
}

// GetStatus returns current watering system status
func (ws *WateringSystem) GetStatus() WateringStatus {
	ws.mu.RLock()
	defer ws.mu.RUnlock()

	// Update dynamic values
	if ws.waterLevelSensor != nil {
		if level, err := ws.waterLevelSensor.Read(); err == nil {
			ws.status.WaterLevel = level
		}
	}

	if ws.flowSensor != nil {
		ws.status.FlowRate = ws.flowSensor.GetCurrentFlowRate()
	}

	return ws.status
}

// UpdateSchedule updates the watering schedule for a module
func (ws *WateringSystem) UpdateSchedule(moduleID int, schedule WateringSchedule) error {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	if moduleID < 0 || moduleID >= len(ws.valves) {
		return fmt.Errorf("invalid module ID: %d", moduleID)
	}

	schedule.ModuleID = moduleID
	ws.schedules[moduleID] = &schedule
	return nil
}

// GetSchedules returns all watering schedules
func (ws *WateringSystem) GetSchedules() map[int]*WateringSchedule {
	ws.mu.RLock()
	defer ws.mu.RUnlock()

	schedules := make(map[int]*WateringSchedule)
	for k, v := range ws.schedules {
		schedules[k] = v
	}
	return schedules
}

// monitoringLoop runs continuous monitoring and automatic watering
func (ws *WateringSystem) monitoringLoop() {
	ticker := time.NewTicker(1 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ws.shutdownCtx.Done():
			return
		case <-ticker.C:
			ws.checkScheduledWatering()
		}
	}
}

func (ws *WateringSystem) checkScheduledWatering() {
	ws.mu.Lock()
	defer ws.mu.Unlock()

	if ws.emergencyStop {
		return
	}

	now := time.Now()
	for moduleID, schedule := range ws.schedules {
		if !schedule.Enabled {
			continue
		}

		if now.After(schedule.NextWatering) {
			// Check if watering is needed based on soil moisture
			// This would typically integrate with the sensor manager
			go func(id int, duration time.Duration) {
				ws.StartWatering(id, duration)
			}(moduleID, schedule.Duration)
		}
	}
}

// Cleanup properly shuts down the watering system
func (ws *WateringSystem) Cleanup() error {
	ws.shutdownCancel()
	
	ws.mu.Lock()
	defer ws.mu.Unlock()

	var errors []error

	// Emergency stop to ensure everything is off
	if err := ws.EmergencyStop(); err != nil {
		errors = append(errors, err)
	}

	// Cleanup components
	if ws.pump != nil {
		if err := ws.pump.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("pump cleanup error: %w", err))
		}
	}

	for i, valve := range ws.valves {
		if err := valve.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("valve %d cleanup error: %w", i, err))
		}
	}

	if ws.flowSensor != nil {
		if err := ws.flowSensor.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("flow sensor cleanup error: %w", err))
		}
	}

	if len(errors) > 0 {
		return fmt.Errorf("cleanup errors: %v", errors)
	}
	return nil
}

// WaterPump controls the main water pump
type WaterPump struct {
	pin      gpio.PinIO
	active   bool
	mockMode bool
}

// NewWaterPump creates a new water pump controller
func NewWaterPump(pinNumber int, mockMode bool) *WaterPump {
	if mockMode {
		return &WaterPump{mockMode: true}
	}

	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", pinNumber))
	return &WaterPump{
		pin:      pin,
		mockMode: false,
	}
}

// Initialize initializes the pump GPIO
func (wp *WaterPump) Initialize() error {
	if wp.mockMode || wp.pin == nil {
		return nil
	}

	// Configure pin as output, initially low (pump off)
	if err := wp.pin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to configure pump pin: %w", err)
	}

	return nil
}

// Start starts the water pump
func (wp *WaterPump) Start() error {
	if wp.mockMode {
		wp.active = true
		return nil
	}

	if wp.pin == nil {
		return fmt.Errorf("pump pin not initialized")
	}

	if err := wp.pin.Out(gpio.High); err != nil {
		return fmt.Errorf("failed to start pump: %w", err)
	}

	wp.active = true
	return nil
}

// Stop stops the water pump
func (wp *WaterPump) Stop() error {
	if wp.mockMode {
		wp.active = false
		return nil
	}

	if wp.pin == nil {
		return fmt.Errorf("pump pin not initialized")
	}

	if err := wp.pin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to stop pump: %w", err)
	}

	wp.active = false
	return nil
}

// IsActive returns whether the pump is currently active
func (wp *WaterPump) IsActive() bool {
	return wp.active
}

// Cleanup safely shuts down the pump
func (wp *WaterPump) Cleanup() error {
	return wp.Stop()
}

// WaterValve controls individual module water valves
type WaterValve struct {
	moduleID int
	pin      gpio.PinIO
	open     bool
	mockMode bool
}

// NewWaterValve creates a new water valve controller
func NewWaterValve(moduleID, pinNumber int, mockMode bool) *WaterValve {
	if mockMode {
		return &WaterValve{
			moduleID: moduleID,
			mockMode: true,
		}
	}

	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", pinNumber))
	return &WaterValve{
		moduleID: moduleID,
		pin:      pin,
		mockMode: false,
	}
}

// Initialize initializes the valve GPIO
func (wv *WaterValve) Initialize() error {
	if wv.mockMode || wv.pin == nil {
		return nil
	}

	// Configure pin as output, initially low (valve closed)
	if err := wv.pin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to configure valve pin: %w", err)
	}

	return nil
}

// Open opens the water valve
func (wv *WaterValve) Open() error {
	if wv.mockMode {
		wv.open = true
		return nil
	}

	if wv.pin == nil {
		return fmt.Errorf("valve pin not initialized")
	}

	if err := wv.pin.Out(gpio.High); err != nil {
		return fmt.Errorf("failed to open valve: %w", err)
	}

	wv.open = true
	return nil
}

// Close closes the water valve
func (wv *WaterValve) Close() error {
	if wv.mockMode {
		wv.open = false
		return nil
	}

	if wv.pin == nil {
		return fmt.Errorf("valve pin not initialized")
	}

	if err := wv.pin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to close valve: %w", err)
	}

	wv.open = false
	return nil
}

// IsOpen returns whether the valve is currently open
func (wv *WaterValve) IsOpen() bool {
	return wv.open
}

// Cleanup safely closes the valve
func (wv *WaterValve) Cleanup() error {
	return wv.Close()
}

// FlowSensor monitors water flow using a flow meter
type FlowSensor struct {
	pin           gpio.PinIO
	pulseCount    int64
	flowRate      float64
	totalVolume   float64
	lastReading   time.Time
	mockMode      bool
	mu            sync.RWMutex
}

// NewFlowSensor creates a new flow sensor
func NewFlowSensor(pinNumber int, mockMode bool) *FlowSensor {
	if mockMode {
		return &FlowSensor{
			mockMode:    true,
			lastReading: time.Now(),
		}
	}

	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", pinNumber))
	return &FlowSensor{
		pin:         pin,
		mockMode:    false,
		lastReading: time.Now(),
	}
}

// Initialize initializes the flow sensor
func (fs *FlowSensor) Initialize() error {
	if fs.mockMode || fs.pin == nil {
		return nil
	}

	// Configure pin as input with pull-up for interrupt-based counting
	if err := fs.pin.In(gpio.PullUp, gpio.FallingEdge); err != nil {
		return fmt.Errorf("failed to configure flow sensor pin: %w", err)
	}

	return nil
}

// StartMonitoring starts monitoring flow sensor pulses
func (fs *FlowSensor) StartMonitoring(ctx context.Context) {
	if fs.mockMode {
		// Mock flow monitoring
		go func() {
			ticker := time.NewTicker(1 * time.Second)
			defer ticker.Stop()

			for {
				select {
				case <-ctx.Done():
					return
				case <-ticker.C:
					fs.mu.Lock()
					fs.flowRate = 1.2 // Mock flow rate in L/min
					fs.totalVolume += fs.flowRate / 60.0 // Add per second
					fs.mu.Unlock()
				}
			}
		}()
		return
	}

	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			default:
				// Wait for falling edge (pulse)
				if fs.pin.WaitForEdge(-1) {
					fs.mu.Lock()
					fs.pulseCount++
					fs.calculateFlowRate()
					fs.mu.Unlock()
				}
			}
		}
	}()
}

func (fs *FlowSensor) calculateFlowRate() {
	now := time.Now()
	timeDiff := now.Sub(fs.lastReading).Seconds()

	if timeDiff >= 1.0 { // Calculate every second
		// Typical flow sensor: ~7.5 pulses per liter
		// Flow rate in L/min = (pulses/second) * 60 / 7.5
		pulsesPerSecond := float64(fs.pulseCount) / timeDiff
		fs.flowRate = pulsesPerSecond * 60.0 / 7.5

		fs.totalVolume += fs.flowRate * (timeDiff / 60.0) // Add volume
		fs.pulseCount = 0
		fs.lastReading = now
	}
}

// GetCurrentFlowRate returns current flow rate in L/min
func (fs *FlowSensor) GetCurrentFlowRate() float64 {
	fs.mu.RLock()
	defer fs.mu.RUnlock()
	return fs.flowRate
}

// GetTotalVolume returns total volume dispensed in liters
func (fs *FlowSensor) GetTotalVolume() float64 {
	fs.mu.RLock()
	defer fs.mu.RUnlock()
	return fs.totalVolume
}

// ResetTotalVolume resets the total volume counter
func (fs *FlowSensor) ResetTotalVolume() {
	fs.mu.Lock()
	defer fs.mu.Unlock()
	fs.totalVolume = 0
}

// Cleanup stops flow monitoring
func (fs *FlowSensor) Cleanup() error {
	return nil // No specific cleanup needed
}

// WaterLevelSensor measures water level in reservoir
type WaterLevelSensor struct {
	channel  int
	mockMode bool
}

// NewWaterLevelSensor creates a new water level sensor
func NewWaterLevelSensor(channel int, mockMode bool) *WaterLevelSensor {
	return &WaterLevelSensor{
		channel:  channel,
		mockMode: mockMode,
	}
}

// Read reads the current water level as percentage
func (wls *WaterLevelSensor) Read() (float64, error) {
	if wls.mockMode {
		return 75.5, nil // Mock water level
	}

	// This would integrate with the MCP3008 ADC via SPI
	// For now, return mock value
	// Production code would read analog voltage and convert to percentage
	return 75.5, nil
}