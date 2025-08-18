package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"gopkg.in/yaml.v3"
	"periph.io/x/conn/v3/gpio/gpioreg"
	"periph.io/x/host/v3"
)

// Config represents the application configuration
type Config struct {
	Server struct {
		Port string `yaml:"port"`
		Host string `yaml:"host"`
	} `yaml:"server"`
	Hardware struct {
		LightingPin int   `yaml:"lighting_pin"`
		WateringPin int   `yaml:"watering_pin"`
		NutrientPin int   `yaml:"nutrient_pin"`
		SensorPins  []int `yaml:"sensor_pins"`
	} `yaml:"hardware"`
}

// SystemStatus represents the current system status
type SystemStatus struct {
	Timestamp     time.Time `json:"timestamp"`
	LightingOn    bool      `json:"lighting_on"`
	WaterLevel    float64   `json:"water_level"`
	NutrientLevel float64   `json:"nutrient_level"`
	Temperature   float64   `json:"temperature"`
	Humidity      float64   `json:"humidity"`
	SoilMoisture  float64   `json:"soil_moisture"`
}

var config Config

func main() {
	// Load configuration
	if err := loadConfig("config.yaml"); err != nil {
		log.Printf("Warning: Could not load config file: %v. Using defaults.", err)
		setDefaultConfig()
	}

	// Initialize hardware
	if _, err := host.Init(); err != nil {
		log.Printf("Warning: Failed to initialize periph.io host: %v", err)
	}

	// Setup HTTP server
	r := mux.NewRouter()

	// API routes
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/status", getStatus).Methods("GET")
	api.HandleFunc("/lighting", toggleLighting).Methods("POST")
	api.HandleFunc("/watering", triggerWatering).Methods("POST")

	// Add CORS middleware for frontend communication
	r.Use(corsMiddleware)

	server := &http.Server{
		Addr:    fmt.Sprintf("%s:%s", config.Server.Host, config.Server.Port),
		Handler: r,
	}

	// Graceful shutdown
	go func() {
		log.Printf("Starting plant-wall-control server on %s", server.Addr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	<-c

	log.Println("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Printf("Server shutdown error: %v", err)
	}
	log.Println("Server stopped")
}

func loadConfig(filename string) error {
	data, err := os.ReadFile(filename)
	if err != nil {
		return err
	}
	return yaml.Unmarshal(data, &config)
}

func setDefaultConfig() {
	config = Config{}
	config.Server.Port = "5000"
	config.Server.Host = "0.0.0.0"
	config.Hardware.LightingPin = 18
	config.Hardware.WateringPin = 19
	config.Hardware.NutrientPin = 20
	config.Hardware.SensorPins = []int{21, 22, 23}
}

func getStatus(w http.ResponseWriter, r *http.Request) {
	status := SystemStatus{
		Timestamp:     time.Now(),
		LightingOn:    false, // TODO: Read from GPIO
		WaterLevel:    75.5,  // TODO: Read from sensor
		NutrientLevel: 68.2,  // TODO: Read from sensor
		Temperature:   23.4,  // TODO: Read from sensor
		Humidity:      65.8,  // TODO: Read from sensor
		SoilMoisture:  45.2,  // TODO: Read from sensor
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

func toggleLighting(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GPIO control for lighting
	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", config.Hardware.LightingPin))
	if pin == nil {
		http.Error(w, "Failed to find lighting pin", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "toggled"})
}

func triggerWatering(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GPIO control for watering pump
	pin := gpioreg.ByName(fmt.Sprintf("GPIO%d", config.Hardware.WateringPin))
	if pin == nil {
		http.Error(w, "Failed to find watering pin", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "watering started"})
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
