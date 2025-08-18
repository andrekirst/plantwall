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

// LightingMode defines different lighting operation modes
type LightingMode int

const (
	LightingModeManual LightingMode = iota
	LightingModeScheduled
	LightingModeAutomatic // Based on light sensor
)

// LightingStatus represents current lighting system status
type LightingStatus struct {
	IsOn           bool          `json:"is_on"`
	Brightness     uint8         `json:"brightness"`     // 0-255
	Mode           LightingMode  `json:"mode"`
	CurrentProgram string        `json:"current_program"`
	PowerUsage     float64       `json:"power_usage"`    // Watts
	Temperature    float64       `json:"temperature"`    // LED temperature °C
	RunTime        time.Duration `json:"runtime"`        // How long lights have been on
	Schedule       *LightSchedule `json:"schedule,omitempty"`
}

// LightSchedule defines lighting schedule
type LightSchedule struct {
	Enabled       bool          `json:"enabled"`
	OnTime        time.Time     `json:"on_time"`        // Daily on time
	OffTime       time.Time     `json:"off_time"`       // Daily off time
	Duration      time.Duration `json:"duration"`       // How long to stay on
	DimmingCurve  []DimPoint    `json:"dimming_curve"`  // Brightness curve throughout day
	WeekdaysOnly  bool          `json:"weekdays_only"`
}

// DimPoint defines a point in the dimming curve
type DimPoint struct {
	Time       time.Duration `json:"time"`       // Time offset from start
	Brightness uint8         `json:"brightness"` // Brightness at this point (0-255)
}

// LightingProgram defines preset lighting programs
type LightingProgram struct {
	Name        string        `json:"name"`
	Description string        `json:"description"`
	Duration    time.Duration `json:"duration"`
	Steps       []LightStep   `json:"steps"`
}

// LightStep defines a step in a lighting program
type LightStep struct {
	Duration   time.Duration `json:"duration"`
	Brightness uint8         `json:"brightness"`
	Transition time.Duration `json:"transition"` // Fade time to this brightness
}

// LightingSystem manages the complete LED lighting system
type LightingSystem struct {
	mu              sync.RWMutex
	ledStrip        *LEDStrip
	status          LightingStatus
	schedule        *LightSchedule
	programs        map[string]*LightingProgram
	currentProgram  string
	startTime       time.Time
	mockMode        bool
	shutdownCtx     context.Context
	shutdownCancel  context.CancelFunc
	scheduleTicker  *time.Ticker
}

// NewLightingSystem creates a new lighting system
func NewLightingSystem(mockMode bool) *LightingSystem {
	ctx, cancel := context.WithCancel(context.Background())
	
	ls := &LightingSystem{
		programs:       make(map[string]*LightingProgram),
		mockMode:       mockMode,
		shutdownCtx:    ctx,
		shutdownCancel: cancel,
		status: LightingStatus{
			Mode: LightingModeManual,
		},
	}

	// Initialize default programs
	ls.initializeDefaultPrograms()
	
	return ls
}

// Initialize initializes the lighting system
func (ls *LightingSystem) Initialize() error {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	// Initialize LED strip (24V PWM control on GPIO 18)
	ledStrip := NewLEDStrip(18, 19, ls.mockMode) // PWM pin 18, Enable pin 19
	if err := ledStrip.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize LED strip: %w", err)
	}
	ls.ledStrip = ledStrip

	// Initialize default schedule
	ls.schedule = &LightSchedule{
		Enabled:  false,
		OnTime:   time.Date(0, 1, 1, 8, 0, 0, 0, time.Local),  // 8:00 AM
		OffTime:  time.Date(0, 1, 1, 20, 0, 0, 0, time.Local), // 8:00 PM
		Duration: 12 * time.Hour,
		DimmingCurve: []DimPoint{
			{Time: 0, Brightness: 50},           // Start dim
			{Time: 1 * time.Hour, Brightness: 255}, // Full brightness
			{Time: 10 * time.Hour, Brightness: 255}, // Stay full
			{Time: 11 * time.Hour, Brightness: 100}, // Dim down
			{Time: 12 * time.Hour, Brightness: 0},   // Off
		},
	}

	// Start monitoring goroutine
	go ls.monitoringLoop()

	return nil
}

// SetBrightness sets the LED brightness (0-255)
func (ls *LightingSystem) SetBrightness(brightness uint8) error {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	if err := ls.ledStrip.SetBrightness(brightness); err != nil {
		return fmt.Errorf("failed to set brightness: %w", err)
	}

	ls.status.Brightness = brightness
	ls.status.IsOn = brightness > 0

	if brightness > 0 && ls.startTime.IsZero() {
		ls.startTime = time.Now()
	} else if brightness == 0 {
		if !ls.startTime.IsZero() {
			ls.status.RunTime += time.Since(ls.startTime)
			ls.startTime = time.Time{}
		}
	}

	return nil
}

// TurnOn turns on the lights at specified brightness
func (ls *LightingSystem) TurnOn(brightness uint8) error {
	if brightness == 0 {
		brightness = 255 // Default to full brightness
	}
	return ls.SetBrightness(brightness)
}

// TurnOff turns off the lights
func (ls *LightingSystem) TurnOff() error {
	return ls.SetBrightness(0)
}

// FadeTo gradually changes brightness over specified duration
func (ls *LightingSystem) FadeTo(targetBrightness uint8, duration time.Duration) error {
	ls.mu.Lock()
	currentBrightness := ls.status.Brightness
	ls.mu.Unlock()

	if duration <= 0 {
		return ls.SetBrightness(targetBrightness)
	}

	steps := 50 // Number of fade steps
	stepDuration := duration / time.Duration(steps)
	brightnessStep := int(targetBrightness) - int(currentBrightness)
	stepSize := float64(brightnessStep) / float64(steps)

	go func() {
		for i := 0; i < steps; i++ {
			select {
			case <-ls.shutdownCtx.Done():
				return
			default:
				newBrightness := uint8(float64(currentBrightness) + stepSize*float64(i+1))
				ls.SetBrightness(newBrightness)
				time.Sleep(stepDuration)
			}
		}
		// Ensure we reach exact target
		ls.SetBrightness(targetBrightness)
	}()

	return nil
}

// StartProgram starts a predefined lighting program
func (ls *LightingSystem) StartProgram(programName string) error {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	program, exists := ls.programs[programName]
	if !exists {
		return fmt.Errorf("program '%s' not found", programName)
	}

	ls.currentProgram = programName
	ls.status.CurrentProgram = programName
	ls.status.Mode = LightingModeManual

	go ls.executeProgram(program)
	return nil
}

func (ls *LightingSystem) executeProgram(program *LightingProgram) {
	for _, step := range program.Steps {
		select {
		case <-ls.shutdownCtx.Done():
			return
		default:
			// Fade to step brightness
			if step.Transition > 0 {
				ls.FadeTo(step.Brightness, step.Transition)
				time.Sleep(step.Transition)
			} else {
				ls.SetBrightness(step.Brightness)
			}

			// Hold at this brightness for step duration
			if step.Duration > step.Transition {
				time.Sleep(step.Duration - step.Transition)
			}
		}
	}
}

// SetMode sets the lighting operation mode
func (ls *LightingSystem) SetMode(mode LightingMode) error {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	ls.status.Mode = mode

	switch mode {
	case LightingModeScheduled:
		if ls.schedule != nil {
			ls.schedule.Enabled = true
		}
		ls.startScheduleMonitoring()
	case LightingModeAutomatic:
		// TODO: Implement automatic mode based on light sensor
		return fmt.Errorf("automatic mode not implemented yet")
	case LightingModeManual:
		if ls.schedule != nil {
			ls.schedule.Enabled = false
		}
		ls.stopScheduleMonitoring()
	}

	return nil
}

// UpdateSchedule updates the lighting schedule
func (ls *LightingSystem) UpdateSchedule(schedule LightSchedule) error {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	ls.schedule = &schedule
	ls.status.Schedule = &schedule

	if ls.status.Mode == LightingModeScheduled && schedule.Enabled {
		ls.startScheduleMonitoring()
	}

	return nil
}

// GetStatus returns current lighting system status
func (ls *LightingSystem) GetStatus() LightingStatus {
	ls.mu.RLock()
	defer ls.mu.RUnlock()

	status := ls.status

	// Update runtime if lights are on
	if ls.status.IsOn && !ls.startTime.IsZero() {
		status.RunTime = ls.status.RunTime + time.Since(ls.startTime)
	}

	// Update power usage based on brightness
	if ls.ledStrip != nil {
		status.PowerUsage = ls.ledStrip.GetPowerUsage()
		status.Temperature = ls.ledStrip.GetTemperature()
	}

	return status
}

// GetPrograms returns available lighting programs
func (ls *LightingSystem) GetPrograms() map[string]*LightingProgram {
	ls.mu.RLock()
	defer ls.mu.RUnlock()

	programs := make(map[string]*LightingProgram)
	for k, v := range ls.programs {
		programs[k] = v
	}
	return programs
}

func (ls *LightingSystem) initializeDefaultPrograms() {
	// Sunrise simulation
	ls.programs["sunrise"] = &LightingProgram{
		Name:        "Sunrise",
		Description: "Gradual sunrise simulation over 30 minutes",
		Duration:    30 * time.Minute,
		Steps: []LightStep{
			{Duration: 5 * time.Minute, Brightness: 0, Transition: 0},
			{Duration: 10 * time.Minute, Brightness: 50, Transition: 5 * time.Minute},
			{Duration: 10 * time.Minute, Brightness: 150, Transition: 5 * time.Minute},
			{Duration: 5 * time.Minute, Brightness: 255, Transition: 5 * time.Minute},
		},
	}

	// Sunset simulation
	ls.programs["sunset"] = &LightingProgram{
		Name:        "Sunset",
		Description: "Gradual sunset simulation over 30 minutes",
		Duration:    30 * time.Minute,
		Steps: []LightStep{
			{Duration: 5 * time.Minute, Brightness: 255, Transition: 0},
			{Duration: 10 * time.Minute, Brightness: 150, Transition: 5 * time.Minute},
			{Duration: 10 * time.Minute, Brightness: 50, Transition: 5 * time.Minute},
			{Duration: 5 * time.Minute, Brightness: 0, Transition: 5 * time.Minute},
		},
	}

	// Growth cycle (14-hour day)
	ls.programs["growth"] = &LightingProgram{
		Name:        "Growth Cycle",
		Description: "14-hour growth lighting with natural dimming curve",
		Duration:    14 * time.Hour,
		Steps: []LightStep{
			{Duration: 1 * time.Hour, Brightness: 100, Transition: 30 * time.Minute},   // Dawn
			{Duration: 6 * time.Hour, Brightness: 255, Transition: 30 * time.Minute},   // Morning/midday
			{Duration: 6 * time.Hour, Brightness: 200, Transition: 1 * time.Hour},      // Afternoon
			{Duration: 1 * time.Hour, Brightness: 0, Transition: 30 * time.Minute},     // Dusk
		},
	}

	// Quick test
	ls.programs["test"] = &LightingProgram{
		Name:        "Test",
		Description: "Quick brightness test cycle",
		Duration:    2 * time.Minute,
		Steps: []LightStep{
			{Duration: 30 * time.Second, Brightness: 255, Transition: 5 * time.Second},
			{Duration: 30 * time.Second, Brightness: 128, Transition: 5 * time.Second},
			{Duration: 30 * time.Second, Brightness: 64, Transition: 5 * time.Second},
			{Duration: 30 * time.Second, Brightness: 0, Transition: 5 * time.Second},
		},
	}
}

func (ls *LightingSystem) startScheduleMonitoring() {
	ls.stopScheduleMonitoring() // Stop existing monitoring

	ls.scheduleTicker = time.NewTicker(1 * time.Minute)
	go func() {
		for {
			select {
			case <-ls.shutdownCtx.Done():
				return
			case <-ls.scheduleTicker.C:
				ls.checkSchedule()
			}
		}
	}()
}

func (ls *LightingSystem) stopScheduleMonitoring() {
	if ls.scheduleTicker != nil {
		ls.scheduleTicker.Stop()
		ls.scheduleTicker = nil
	}
}

func (ls *LightingSystem) checkSchedule() {
	ls.mu.Lock()
	defer ls.mu.Unlock()

	if ls.schedule == nil || !ls.schedule.Enabled {
		return
	}

	now := time.Now()
	
	// Skip weekends if weekdays only
	if ls.schedule.WeekdaysOnly && (now.Weekday() == time.Saturday || now.Weekday() == time.Sunday) {
		return
	}

	// Create today's schedule times
	onTime := time.Date(now.Year(), now.Month(), now.Day(), 
		ls.schedule.OnTime.Hour(), ls.schedule.OnTime.Minute(), ls.schedule.OnTime.Second(), 0, now.Location())
	offTime := onTime.Add(ls.schedule.Duration)

	// Check if we should be on
	if now.After(onTime) && now.Before(offTime) {
		// Calculate brightness based on dimming curve
		elapsed := now.Sub(onTime)
		brightness := ls.calculateBrightnessFromCurve(elapsed)
		
		if ls.status.Brightness != brightness {
			ls.ledStrip.SetBrightness(brightness)
			ls.status.Brightness = brightness
			ls.status.IsOn = brightness > 0
		}
	} else if ls.status.IsOn {
		// Turn off if we're past the schedule
		ls.ledStrip.SetBrightness(0)
		ls.status.Brightness = 0
		ls.status.IsOn = false
	}
}

func (ls *LightingSystem) calculateBrightnessFromCurve(elapsed time.Duration) uint8 {
	if len(ls.schedule.DimmingCurve) == 0 {
		return 255 // Default full brightness
	}

	// Find the appropriate curve segment
	for i, point := range ls.schedule.DimmingCurve {
		if elapsed <= point.Time {
			if i == 0 {
				return point.Brightness
			}
			
			// Interpolate between previous and current point
			prevPoint := ls.schedule.DimmingCurve[i-1]
			timeDiff := point.Time - prevPoint.Time
			timeOffset := elapsed - prevPoint.Time
			
			if timeDiff > 0 {
				ratio := float64(timeOffset) / float64(timeDiff)
				brightnessDiff := int(point.Brightness) - int(prevPoint.Brightness)
				brightness := int(prevPoint.Brightness) + int(float64(brightnessDiff)*ratio)
				
				if brightness < 0 {
					brightness = 0
				}
				if brightness > 255 {
					brightness = 255
				}
				
				return uint8(brightness)
			}
			return prevPoint.Brightness
		}
	}

	// Past the end of curve, return last brightness
	return ls.schedule.DimmingCurve[len(ls.schedule.DimmingCurve)-1].Brightness
}

func (ls *LightingSystem) monitoringLoop() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ls.shutdownCtx.Done():
			return
		case <-ticker.C:
			// Update power usage and temperature readings
			if ls.ledStrip != nil {
				ls.mu.Lock()
				ls.status.PowerUsage = ls.ledStrip.GetPowerUsage()
				ls.status.Temperature = ls.ledStrip.GetTemperature()
				ls.mu.Unlock()
			}
		}
	}
}

// Cleanup properly shuts down the lighting system
func (ls *LightingSystem) Cleanup() error {
	ls.shutdownCancel()
	ls.stopScheduleMonitoring()
	
	ls.mu.Lock()
	defer ls.mu.Unlock()

	if ls.ledStrip != nil {
		// Turn off lights before cleanup
		ls.ledStrip.SetBrightness(0)
		return ls.ledStrip.Cleanup()
	}

	return nil
}

// LEDStrip controls the LED strip hardware
type LEDStrip struct {
	pwmPin     gpio.PinIO
	enablePin  gpio.PinIO
	brightness uint8
	mockMode   bool
	powerUsage float64 // Current power usage in watts
}

// NewLEDStrip creates a new LED strip controller
func NewLEDStrip(pwmPinNumber, enablePinNumber int, mockMode bool) *LEDStrip {
	if mockMode {
		return &LEDStrip{mockMode: true}
	}

	pwmPin := gpioreg.ByName(fmt.Sprintf("GPIO%d", pwmPinNumber))
	enablePin := gpioreg.ByName(fmt.Sprintf("GPIO%d", enablePinNumber))

	return &LEDStrip{
		pwmPin:    pwmPin,
		enablePin: enablePin,
		mockMode:  false,
	}
}

// Initialize initializes the LED strip GPIO pins
func (led *LEDStrip) Initialize() error {
	if led.mockMode {
		return nil
	}

	if led.enablePin == nil || led.pwmPin == nil {
		return fmt.Errorf("LED strip pins not found")
	}

	// Configure enable pin as output, initially low (disabled)
	if err := led.enablePin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to configure enable pin: %w", err)
	}

	// Configure PWM pin
	if err := led.pwmPin.Out(gpio.Low); err != nil {
		return fmt.Errorf("failed to configure PWM pin: %w", err)
	}

	return nil
}

// SetBrightness sets LED brightness (0-255)
func (led *LEDStrip) SetBrightness(brightness uint8) error {
	if led.mockMode {
		led.brightness = brightness
		led.powerUsage = float64(brightness) / 255.0 * 100.0 // Mock: max 100W
		return nil
	}

	led.brightness = brightness

	if brightness == 0 {
		// Turn off
		if err := led.enablePin.Out(gpio.Low); err != nil {
			return fmt.Errorf("failed to disable LED: %w", err)
		}
		if err := led.pwmPin.Halt(); err != nil {
			return fmt.Errorf("failed to stop PWM: %w", err)
		}
		led.powerUsage = 0
	} else {
		// Enable LED strip
		if err := led.enablePin.Out(gpio.High); err != nil {
			return fmt.Errorf("failed to enable LED: %w", err)
		}

		// Set PWM duty cycle (0-255 -> 0-100%)
		dutyCycle := physic.DutyCycle(brightness) * physic.PercentDutyCycle / 255
		frequency := 1 * physic.KiloHertz

		if err := led.pwmPin.PWM(gpio.DutyCycle(dutyCycle), frequency); err != nil {
			return fmt.Errorf("failed to set PWM: %w", err)
		}

		// Calculate power usage (simplified model)
		led.powerUsage = float64(brightness) / 255.0 * 100.0 // Max 100W at full brightness
	}

	return nil
}

// GetBrightness returns current brightness
func (led *LEDStrip) GetBrightness() uint8 {
	return led.brightness
}

// GetPowerUsage returns current power usage in watts
func (led *LEDStrip) GetPowerUsage() float64 {
	return led.powerUsage
}

// GetTemperature returns LED temperature (mock implementation)
func (led *LEDStrip) GetTemperature() float64 {
	// Mock temperature based on power usage
	baseTemp := 25.0 // Room temperature
	tempIncrease := led.powerUsage * 0.3 // 0.3°C per watt
	return baseTemp + tempIncrease
}

// Cleanup safely turns off and cleans up LED strip
func (led *LEDStrip) Cleanup() error {
	return led.SetBrightness(0)
}