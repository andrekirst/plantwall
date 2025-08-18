package hardware

import (
	"fmt"
	"sync"
	"time"

	"periph.io/x/conn/v3/gpio"
	"periph.io/x/conn/v3/gpio/gpioreg"
	"periph.io/x/conn/v3/i2c"
	"periph.io/x/conn/v3/i2c/i2creg"
)

// DisplayColor represents LED colors
type DisplayColor int

const (
	ColorOff DisplayColor = iota
	ColorRed
	ColorGreen
	ColorBlue
	ColorYellow  // Red + Green
	ColorMagenta // Red + Blue
	ColorCyan    // Green + Blue
	ColorWhite   // Red + Green + Blue
)

// SystemAlert represents different system alert levels
type SystemAlert int

const (
	AlertNone SystemAlert = iota
	AlertInfo
	AlertWarning
	AlertError
	AlertCritical
)

// DisplayStatus represents current display status
type DisplayStatus struct {
	StatusLEDs struct {
		Red   bool `json:"red"`
		Green bool `json:"green"`
		Blue  bool `json:"blue"`
	} `json:"status_leds"`
	OLEDEnabled   bool   `json:"oled_enabled"`
	CurrentScreen string `json:"current_screen"`
	Brightness    uint8  `json:"brightness"`
	LastUpdate    time.Time `json:"last_update"`
}

// Screen represents different display screens
type Screen struct {
	Name     string        `json:"name"`
	Title    string        `json:"title"`
	Lines    []string      `json:"lines"`
	Duration time.Duration `json:"duration"` // How long to show this screen
}

// DisplaySystem manages status LEDs and optional OLED display
type DisplaySystem struct {
	mu           sync.RWMutex
	statusLEDs   *StatusLEDs
	oledDisplay  *OLEDDisplay
	currentAlert SystemAlert
	screens      []Screen
	currentScreen int
	status       DisplayStatus
	mockMode     bool
	autoRotate   bool
	rotateTimer  *time.Timer
}

// NewDisplaySystem creates a new display system
func NewDisplaySystem(mockMode bool) *DisplaySystem {
	return &DisplaySystem{
		screens:  make([]Screen, 0),
		mockMode: mockMode,
		status: DisplayStatus{
			LastUpdate: time.Now(),
		},
	}
}

// Initialize initializes the display system
func (ds *DisplaySystem) Initialize() error {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	// Initialize status LEDs (GPIO 5, 6, 13)
	statusLEDs := NewStatusLEDs(5, 6, 13, ds.mockMode) // Red, Green, Blue pins
	if err := statusLEDs.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize status LEDs: %w", err)
	}
	ds.statusLEDs = statusLEDs

	// Initialize OLED display (optional, I2C address 0x3C)
	oledDisplay := NewOLEDDisplay(0x3C, ds.mockMode)
	if err := oledDisplay.Initialize(); err != nil {
		fmt.Printf("Warning: OLED display not available: %v\n", err)
		ds.status.OLEDEnabled = false
	} else {
		ds.oledDisplay = oledDisplay
		ds.status.OLEDEnabled = true
	}

	// Initialize default screens
	ds.initializeDefaultScreens()

	// Show welcome screen
	ds.ShowWelcomeScreen()

	return nil
}

// SetAlert sets the system alert level and updates LED display
func (ds *DisplaySystem) SetAlert(alert SystemAlert) error {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	ds.currentAlert = alert
	
	// Update status LEDs based on alert level
	switch alert {
	case AlertNone:
		return ds.statusLEDs.SetColor(ColorGreen) // All good
	case AlertInfo:
		return ds.statusLEDs.SetColor(ColorBlue) // Information
	case AlertWarning:
		return ds.statusLEDs.SetColor(ColorYellow) // Warning
	case AlertError:
		return ds.statusLEDs.SetColor(ColorRed) // Error
	case AlertCritical:
		return ds.statusLEDs.Blink(ColorRed, 500*time.Millisecond) // Critical - blinking red
	default:
		return ds.statusLEDs.SetColor(ColorOff)
	}
}

// ShowSystemStatus displays system status information
func (ds *DisplaySystem) ShowSystemStatus(temperature, humidity, soilMoisture, waterLevel float64, lightingOn bool) error {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	// Update status LEDs based on system health
	alert := ds.calculateSystemAlert(temperature, humidity, soilMoisture, waterLevel)
	ds.SetAlert(alert)

	// Update OLED display if available
	if ds.oledDisplay != nil {
		lines := []string{
			fmt.Sprintf("Temp: %.1f°C", temperature),
			fmt.Sprintf("Humidity: %.1f%%", humidity),
			fmt.Sprintf("Soil: %.1f%%", soilMoisture),
			fmt.Sprintf("Water: %.1f%%", waterLevel),
			fmt.Sprintf("Light: %s", map[bool]string{true: "ON", false: "OFF"}[lightingOn]),
			time.Now().Format("15:04:05"),
		}

		if err := ds.oledDisplay.ShowScreen("Status", lines); err != nil {
			return fmt.Errorf("failed to update OLED display: %w", err)
		}
	}

	ds.status.CurrentScreen = "system_status"
	ds.status.LastUpdate = time.Now()
	return nil
}

func (ds *DisplaySystem) calculateSystemAlert(temperature, humidity, soilMoisture, waterLevel float64) SystemAlert {
	// Critical conditions
	if waterLevel < 10.0 {
		return AlertCritical // Very low water
	}
	if temperature > 35.0 || temperature < 5.0 {
		return AlertCritical // Extreme temperature
	}

	// Error conditions
	if waterLevel < 20.0 {
		return AlertError // Low water
	}
	if soilMoisture < 20.0 {
		return AlertError // Soil too dry
	}
	if temperature > 30.0 || temperature < 10.0 {
		return AlertError // Temperature warning
	}

	// Warning conditions
	if soilMoisture < 40.0 {
		return AlertWarning // Soil getting dry
	}
	if humidity < 40.0 || humidity > 80.0 {
		return AlertWarning // Humidity outside optimal range
	}

	// All good
	return AlertNone
}

// ShowWelcomeScreen displays a welcome message
func (ds *DisplaySystem) ShowWelcomeScreen() error {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	// Set status LEDs to blue (system starting)
	if err := ds.statusLEDs.SetColor(ColorBlue); err != nil {
		return fmt.Errorf("failed to set welcome LED color: %w", err)
	}

	// Show welcome message on OLED
	if ds.oledDisplay != nil {
		lines := []string{
			"Plant Wall Control",
			"System Starting...",
			"",
			fmt.Sprintf("v1.0 - %s", time.Now().Format("2006-01-02")),
			"",
			"Initializing...",
		}

		if err := ds.oledDisplay.ShowScreen("Welcome", lines); err != nil {
			return fmt.Errorf("failed to show welcome screen: %w", err)
		}
	}

	ds.status.CurrentScreen = "welcome"
	ds.status.LastUpdate = time.Now()
	return nil
}

// ShowCustomScreen displays a custom screen
func (ds *DisplaySystem) ShowCustomScreen(title string, lines []string) error {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	if ds.oledDisplay != nil {
		if err := ds.oledDisplay.ShowScreen(title, lines); err != nil {
			return fmt.Errorf("failed to show custom screen: %w", err)
		}
	}

	ds.status.CurrentScreen = fmt.Sprintf("custom_%s", title)
	ds.status.LastUpdate = time.Now()
	return nil
}

// StartAutoRotate starts automatic screen rotation
func (ds *DisplaySystem) StartAutoRotate(interval time.Duration) {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	if ds.rotateTimer != nil {
		ds.rotateTimer.Stop()
	}

	ds.autoRotate = true
	ds.rotateTimer = time.AfterFunc(interval, func() {
		ds.rotateScreen()
		if ds.autoRotate {
			ds.StartAutoRotate(interval) // Reschedule
		}
	})
}

// StopAutoRotate stops automatic screen rotation
func (ds *DisplaySystem) StopAutoRotate() {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	ds.autoRotate = false
	if ds.rotateTimer != nil {
		ds.rotateTimer.Stop()
		ds.rotateTimer = nil
	}
}

func (ds *DisplaySystem) rotateScreen() {
	ds.mu.Lock()
	defer ds.mu.Unlock()

	if len(ds.screens) == 0 {
		return
	}

	ds.currentScreen = (ds.currentScreen + 1) % len(ds.screens)
	screen := ds.screens[ds.currentScreen]

	if ds.oledDisplay != nil {
		ds.oledDisplay.ShowScreen(screen.Title, screen.Lines)
	}

	ds.status.CurrentScreen = screen.Name
	ds.status.LastUpdate = time.Now()
}

func (ds *DisplaySystem) initializeDefaultScreens() {
	ds.screens = []Screen{
		{
			Name:     "status",
			Title:    "System Status",
			Lines:    []string{"Loading...", "", "", "", "", ""},
			Duration: 10 * time.Second,
		},
		{
			Name:  "network",
			Title: "Network Info",
			Lines: []string{
				"WiFi: Connected",
				"IP: 192.168.1.100",
				"API: :5000",
				"",
				"Web: :3000",
				time.Now().Format("15:04:05"),
			},
			Duration: 5 * time.Second,
		},
		{
			Name:  "uptime",
			Title: "System Info",
			Lines: []string{
				"Plant Wall v1.0",
				"Raspberry Pi Zero 2W",
				fmt.Sprintf("Started: %s", time.Now().Format("15:04")),
				"",
				"All systems ready",
				"",
			},
			Duration: 5 * time.Second,
		},
	}
}

// GetStatus returns current display status
func (ds *DisplaySystem) GetStatus() DisplayStatus {
	ds.mu.RLock()
	defer ds.mu.RUnlock()

	status := ds.status
	if ds.statusLEDs != nil {
		status.StatusLEDs.Red = ds.statusLEDs.IsLEDOn("red")
		status.StatusLEDs.Green = ds.statusLEDs.IsLEDOn("green")
		status.StatusLEDs.Blue = ds.statusLEDs.IsLEDOn("blue")
	}

	return status
}

// Cleanup properly shuts down the display system
func (ds *DisplaySystem) Cleanup() error {
	ds.StopAutoRotate()

	ds.mu.Lock()
	defer ds.mu.Unlock()

	var errors []error

	// Show shutdown screen
	if ds.oledDisplay != nil {
		lines := []string{
			"Plant Wall Control",
			"",
			"Shutting down...",
			"",
			"Safe to power off",
			time.Now().Format("15:04:05"),
		}
		ds.oledDisplay.ShowScreen("Shutdown", lines)
	}

	// Turn off status LEDs
	if ds.statusLEDs != nil {
		if err := ds.statusLEDs.SetColor(ColorOff); err != nil {
			errors = append(errors, fmt.Errorf("status LED cleanup error: %w", err))
		}
		if err := ds.statusLEDs.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("status LED cleanup error: %w", err))
		}
	}

	// Cleanup OLED display
	if ds.oledDisplay != nil {
		if err := ds.oledDisplay.Cleanup(); err != nil {
			errors = append(errors, fmt.Errorf("OLED cleanup error: %w", err))
		}
	}

	if len(errors) > 0 {
		return fmt.Errorf("display cleanup errors: %v", errors)
	}
	return nil
}

// StatusLEDs controls individual status LEDs
type StatusLEDs struct {
	redPin    gpio.PinIO
	greenPin  gpio.PinIO
	bluePin   gpio.PinIO
	mockMode  bool
	blinkStop chan bool
	ledState  map[string]bool
	mu        sync.RWMutex
}

// NewStatusLEDs creates new status LED controller
func NewStatusLEDs(redPin, greenPin, bluePin int, mockMode bool) *StatusLEDs {
	if mockMode {
		return &StatusLEDs{
			mockMode: true,
			ledState: make(map[string]bool),
		}
	}

	return &StatusLEDs{
		redPin:   gpioreg.ByName(fmt.Sprintf("GPIO%d", redPin)),
		greenPin: gpioreg.ByName(fmt.Sprintf("GPIO%d", greenPin)),
		bluePin:  gpioreg.ByName(fmt.Sprintf("GPIO%d", bluePin)),
		mockMode: false,
		ledState: make(map[string]bool),
	}
}

// Initialize initializes status LED pins
func (sl *StatusLEDs) Initialize() error {
	if sl.mockMode {
		return nil
	}

	pins := map[string]gpio.PinIO{
		"red":   sl.redPin,
		"green": sl.greenPin,
		"blue":  sl.bluePin,
	}

	for name, pin := range pins {
		if pin == nil {
			return fmt.Errorf("%s LED pin not found", name)
		}
		if err := pin.Out(gpio.Low); err != nil {
			return fmt.Errorf("failed to configure %s LED pin: %w", name, err)
		}
	}

	return nil
}

// SetColor sets LEDs to display a specific color
func (sl *StatusLEDs) SetColor(color DisplayColor) error {
	sl.mu.Lock()
	defer sl.mu.Unlock()

	// Stop any blinking
	sl.stopBlinking()

	// Define color mappings
	colors := map[DisplayColor]map[string]bool{
		ColorOff:     {"red": false, "green": false, "blue": false},
		ColorRed:     {"red": true, "green": false, "blue": false},
		ColorGreen:   {"red": false, "green": true, "blue": false},
		ColorBlue:    {"red": false, "green": false, "blue": true},
		ColorYellow:  {"red": true, "green": true, "blue": false},
		ColorMagenta: {"red": true, "green": false, "blue": true},
		ColorCyan:    {"red": false, "green": true, "blue": true},
		ColorWhite:   {"red": true, "green": true, "blue": true},
	}

	colorMap, exists := colors[color]
	if !exists {
		return fmt.Errorf("unknown color: %d", color)
	}

	return sl.setLEDStates(colorMap)
}

// Blink makes LEDs blink in specified color
func (sl *StatusLEDs) Blink(color DisplayColor, interval time.Duration) error {
	sl.mu.Lock()
	defer sl.mu.Unlock()

	// Stop existing blinking
	sl.stopBlinking()

	// Start new blinking goroutine
	sl.blinkStop = make(chan bool)
	go func() {
		on := true
		ticker := time.NewTicker(interval)
		defer ticker.Stop()

		for {
			select {
			case <-sl.blinkStop:
				return
			case <-ticker.C:
				if on {
					sl.SetColor(color)
				} else {
					sl.SetColor(ColorOff)
				}
				on = !on
			}
		}
	}()

	return nil
}

func (sl *StatusLEDs) stopBlinking() {
	if sl.blinkStop != nil {
		close(sl.blinkStop)
		sl.blinkStop = nil
	}
}

func (sl *StatusLEDs) setLEDStates(states map[string]bool) error {
	if sl.mockMode {
		for name, state := range states {
			sl.ledState[name] = state
		}
		return nil
	}

	pins := map[string]gpio.PinIO{
		"red":   sl.redPin,
		"green": sl.greenPin,
		"blue":  sl.bluePin,
	}

	for name, state := range states {
		pin := pins[name]
		if pin == nil {
			continue
		}

		level := gpio.Low
		if state {
			level = gpio.High
		}

		if err := pin.Out(level); err != nil {
			return fmt.Errorf("failed to set %s LED: %w", name, err)
		}

		sl.ledState[name] = state
	}

	return nil
}

// IsLEDOn returns whether a specific LED is on
func (sl *StatusLEDs) IsLEDOn(name string) bool {
	sl.mu.RLock()
	defer sl.mu.RUnlock()
	return sl.ledState[name]
}

// Cleanup turns off all LEDs
func (sl *StatusLEDs) Cleanup() error {
	sl.stopBlinking()
	return sl.SetColor(ColorOff)
}

// OLEDDisplay controls an I2C OLED display
type OLEDDisplay struct {
	i2cDev   i2c.Dev
	mockMode bool
	width    int
	height   int
}

// NewOLEDDisplay creates a new OLED display controller
func NewOLEDDisplay(address uint16, mockMode bool) *OLEDDisplay {
	if mockMode {
		return &OLEDDisplay{
			mockMode: true,
			width:    128,
			height:   64,
		}
	}

	return &OLEDDisplay{
		mockMode: false,
		width:    128,
		height:   64,
		// i2cDev will be initialized in Initialize()
	}
}

// Initialize initializes the OLED display
func (oled *OLEDDisplay) Initialize() error {
	if oled.mockMode {
		return nil
	}

	// Open I2C bus
	bus, err := i2creg.Open("")
	if err != nil {
		return fmt.Errorf("failed to open I2C bus: %w", err)
	}

	// Create device
	oled.i2cDev = i2c.Dev{Addr: 0x3C, Bus: bus}

	// Initialize display with SSD1306 command sequence
	if err := oled.initializeDisplay(); err != nil {
		return fmt.Errorf("failed to initialize OLED: %w", err)
	}

	return nil
}

func (oled *OLEDDisplay) initializeDisplay() error {
	// SSD1306 initialization sequence
	initSequence := []byte{
		0x00, // Command mode
		0xAE, // Display off
		0xD5, 0x80, // Set display clock div
		0xA8, 0x3F, // Set multiplex (64-1)
		0xD3, 0x00, // Set display offset
		0x40, // Set start line
		0x8D, 0x14, // Charge pump on
		0x20, 0x00, // Memory mode horizontal
		0xA1, // Segment remap
		0xC8, // COM scan dec
		0xDA, 0x12, // COM pins
		0x81, 0xCF, // Set contrast
		0xD9, 0xF1, // Set precharge
		0xDB, 0x40, // Set vcom detect
		0xA4, // Display all on resume
		0xA6, // Normal display
		0xAF, // Display on
	}

	if _, err := oled.i2cDev.Write(initSequence); err != nil {
		return fmt.Errorf("failed to send init sequence: %w", err)
	}

	return nil
}

// ShowScreen displays a screen with title and lines
func (oled *OLEDDisplay) ShowScreen(title string, lines []string) error {
	if oled.mockMode {
		fmt.Printf("OLED Display - %s:\n", title)
		for i, line := range lines {
			if i < 6 { // Limit to 6 lines for display
				fmt.Printf("  %s\n", line)
			}
		}
		fmt.Println()
		return nil
	}

	// Clear display
	if err := oled.clearDisplay(); err != nil {
		return fmt.Errorf("failed to clear display: %w", err)
	}

	// Show title on first line
	if err := oled.writeText(0, 0, title); err != nil {
		return fmt.Errorf("failed to write title: %w", err)
	}

	// Show lines (max 5 more lines after title)
	for i, line := range lines {
		if i >= 5 { // Limit to available lines
			break
		}
		if err := oled.writeText(0, (i+1)*10, line); err != nil {
			return fmt.Errorf("failed to write line %d: %w", i, err)
		}
	}

	return nil
}

func (oled *OLEDDisplay) clearDisplay() error {
	// Clear display memory
	clearData := make([]byte, 1025) // Command byte + 1024 display bytes
	clearData[0] = 0x40 // Data mode

	// Set column and page address
	if _, err := oled.i2cDev.Write([]byte{0x00, 0x21, 0x00, 0x7F}); err != nil {
		return err
	}
	if _, err := oled.i2cDev.Write([]byte{0x00, 0x22, 0x00, 0x07}); err != nil {
		return err
	}

	// Clear all pixels
	if _, err := oled.i2cDev.Write(clearData); err != nil {
		return err
	}

	return nil
}

func (oled *OLEDDisplay) writeText(x, y int, text string) error {
	// Simplified text rendering - in production, this would use a proper font
	// For now, just acknowledge the text write
	return nil
}

// SetBrightness sets display brightness (0-255)
func (oled *OLEDDisplay) SetBrightness(brightness uint8) error {
	if oled.mockMode {
		return nil
	}

	cmd := []byte{0x00, 0x81, brightness} // Set contrast command
	_, err := oled.i2cDev.Write(cmd)
	return err
}

// Cleanup turns off the display
func (oled *OLEDDisplay) Cleanup() error {
	if oled.mockMode {
		fmt.Println("OLED Display: Shutting down")
		return nil
	}

	// Turn off display
	cmd := []byte{0x00, 0xAE} // Display off
	_, err := oled.i2cDev.Write(cmd)
	return err
}