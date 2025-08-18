// System Status from Go backend - matches SystemStatus struct
export interface SystemStatus {
    timestamp: string;
    lighting_on: boolean;
    water_level: number;
    nutrient_level: number;
    temperature: number;
    humidity: number;
    soil_moisture: number;
}

// Health check response
export interface HealthStatus {
    status: string;
    timestamp: string;
    version?: string;
}

// Lighting system status and control
export interface LightingStatus {
    is_on: boolean;
    brightness: number;
    power_usage: number;
    schedule_enabled: boolean;
    last_changed: string;
}

export interface LightingControl {
    brightness?: number;
    enabled?: boolean;
    schedule?: {
        on_time: string;
        off_time: string;
        enabled: boolean;
    };
}

// Watering system status and control
export interface WateringStatus {
    is_running: boolean;
    water_level: number;
    last_watering: string;
    emergency_stop: boolean;
    auto_mode: boolean;
    next_scheduled?: string;
}

export interface WateringControl {
    duration?: number; // in seconds
    auto_mode?: boolean;
    schedule?: {
        interval_hours: number;
        duration_seconds: number;
        enabled: boolean;
    };
}

// Sensor readings
export interface SensorData {
    temperature: number;
    humidity: number;
    soil_moisture_0: number;
    soil_moisture_1?: number;
    soil_moisture_2?: number;
    soil_moisture_3?: number;
    ph_level?: number;
    ec_level?: number;
    light_level: number;
    water_level: number;
    timestamp: string;
}

// Error response structure
export interface ApiError {
    error: string;
    code?: number;
    timestamp: string;
}

// API Response wrapper
export interface ApiResponse<T> {
    data?: T;
    error?: string;
    status: 'success' | 'error';
    timestamp: string;
}

// Legacy interfaces for backward compatibility
export interface Status {
    soilMoisture: number;
    externalLight: number;
    waterTankLevel: number;
}

export interface Settings {
    brightness: number;
    wateringInterval: number;
    nutrientLevel: number;
}

// Hardware system health
export interface SystemHealth {
    sensors: boolean;
    watering: boolean;
    lighting: boolean;
    display: boolean;
    overall: boolean;
}