import React, { useState, useEffect } from 'react';
import Navigation from '../components/Navigation';
import { 
    fetchLightingStatus, 
    fetchWateringStatus, 
    fetchSensorData, 
    checkHealth,
    updateLighting, 
    triggerWatering 
} from '../utils/api';
import { 
    LightingStatus, 
    WateringStatus, 
    SensorData, 
    LightingControl, 
    WateringControl 
} from '../types/index';

const SettingsPage: React.FC = () => {
    const [lightingStatus, setLightingStatus] = useState<LightingStatus | null>(null);
    const [wateringStatus, setWateringStatus] = useState<WateringStatus | null>(null);
    const [sensorData, setSensorData] = useState<SensorData | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);

    // Lighting settings
    const [brightness, setBrightness] = useState(50);
    const [lightingScheduleEnabled, setLightingScheduleEnabled] = useState(false);
    const [lightOnTime, setLightOnTime] = useState('07:00');
    const [lightOffTime, setLightOffTime] = useState('20:00');

    // Watering settings  
    const [wateringAutoMode, setWateringAutoMode] = useState(false);
    const [wateringInterval, setWateringInterval] = useState(24); // hours
    const [wateringDuration, setWateringDuration] = useState(30); // seconds

    // Load current settings
    const loadSettings = async () => {
        try {
            setError(null);
            
            // Load lighting settings
            try {
                const lighting = await fetchLightingStatus();
                setLightingStatus(lighting);
                setBrightness(lighting.brightness || 50);
                setLightingScheduleEnabled(lighting.schedule_enabled || false);
            } catch (lightingErr) {
                console.warn('Could not load lighting settings:', lightingErr);
            }

            // Load watering settings
            try {
                const watering = await fetchWateringStatus();
                setWateringStatus(watering);
                setWateringAutoMode(watering.auto_mode || false);
            } catch (wateringErr) {
                console.warn('Could not load watering settings:', wateringErr);
            }

            // Load sensor data for reference
            try {
                const sensors = await fetchSensorData();
                setSensorData(sensors);
            } catch (sensorErr) {
                console.warn('Could not load sensor data:', sensorErr);
            }

        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to load settings';
            setError(errorMessage);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadSettings();
    }, []);

    // Clear messages after 5 seconds
    useEffect(() => {
        if (message || error) {
            const timer = setTimeout(() => {
                setMessage(null);
                setError(null);
            }, 5000);
            return () => clearTimeout(timer);
        }
    }, [message, error]);

    const handleLightingSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        setLoading(true);
        
        try {
            const lightingData: LightingControl = {
                brightness: brightness,
                schedule: {
                    on_time: lightOnTime,
                    off_time: lightOffTime,
                    enabled: lightingScheduleEnabled,
                },
            };

            await updateLighting(lightingData);
            setMessage('Lighting settings updated successfully!');
            
            // Reload settings
            setTimeout(loadSettings, 1000);
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to update lighting settings';
            setError(`Lighting update failed: ${errorMessage}`);
        } finally {
            setLoading(false);
        }
    };

    const handleWateringSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        setLoading(true);
        
        try {
            const wateringData: WateringControl = {
                auto_mode: wateringAutoMode,
                schedule: {
                    interval_hours: wateringInterval,
                    duration_seconds: wateringDuration,
                    enabled: wateringAutoMode,
                },
            };

            await triggerWatering(wateringData);
            setMessage('Watering settings updated successfully!');
            
            // Reload settings
            setTimeout(loadSettings, 1000);
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to update watering settings';
            setError(`Watering update failed: ${errorMessage}`);
        } finally {
            setLoading(false);
        }
    };

    const handleSystemHealthCheck = async () => {
        try {
            const health = await checkHealth();
            setMessage(`System health check: ${health.status}`);
        } catch (err) {
            setError('Health check failed - backend may be unavailable');
        }
    };

    if (loading && !lightingStatus && !wateringStatus) {
        return (
            <div className="settings-page loading">
                <h1>Settings</h1>
                <div className="loading-spinner">Loading settings...</div>
            </div>
        );
    }

    return (
        <div className="plant-wall-app">
            <Navigation />
            <div className="settings-page">
                <header className="settings-header">
                    <h1>Plant Wall Settings</h1>
                    <p>Configure lighting, watering, and system parameters</p>
                </header>

            {/* Error/Success Messages */}
            {error && (
                <div className="alert alert-error">
                    <strong>Error:</strong> {error}
                </div>
            )}
            {message && (
                <div className="alert alert-success">
                    {message}
                </div>
            )}

            <div className="settings-grid">
                {/* Lighting Settings */}
                <section className="settings-section">
                    <h2>Lighting Settings</h2>
                    <form onSubmit={handleLightingSubmit}>
                        <div className="setting-group">
                            <label htmlFor="brightness">
                                Default Brightness: {brightness}%
                            </label>
                            <input
                                id="brightness"
                                type="range"
                                min="0"
                                max="100"
                                step="5"
                                value={brightness}
                                onChange={(e) => setBrightness(Number(e.target.value))}
                                disabled={loading}
                            />
                        </div>

                        <div className="setting-group">
                            <label>
                                <input
                                    type="checkbox"
                                    checked={lightingScheduleEnabled}
                                    onChange={(e) => setLightingScheduleEnabled(e.target.checked)}
                                    disabled={loading}
                                />
                                Enable lighting schedule
                            </label>
                        </div>

                        {lightingScheduleEnabled && (
                            <div className="schedule-settings">
                                <div className="setting-group">
                                    <label htmlFor="light-on-time">Turn on at:</label>
                                    <input
                                        id="light-on-time"
                                        type="time"
                                        value={lightOnTime}
                                        onChange={(e) => setLightOnTime(e.target.value)}
                                        disabled={loading}
                                    />
                                </div>
                                <div className="setting-group">
                                    <label htmlFor="light-off-time">Turn off at:</label>
                                    <input
                                        id="light-off-time"
                                        type="time"
                                        value={lightOffTime}
                                        onChange={(e) => setLightOffTime(e.target.value)}
                                        disabled={loading}
                                    />
                                </div>
                            </div>
                        )}

                        <button type="submit" disabled={loading} className="save-button">
                            {loading ? 'Saving...' : 'Save Lighting Settings'}
                        </button>
                    </form>
                </section>

                {/* Watering Settings */}
                <section className="settings-section">
                    <h2>Watering Settings</h2>
                    <form onSubmit={handleWateringSubmit}>
                        <div className="setting-group">
                            <label>
                                <input
                                    type="checkbox"
                                    checked={wateringAutoMode}
                                    onChange={(e) => setWateringAutoMode(e.target.checked)}
                                    disabled={loading}
                                />
                                Enable automatic watering
                            </label>
                        </div>

                        {wateringAutoMode && (
                            <div className="watering-settings">
                                <div className="setting-group">
                                    <label htmlFor="watering-interval">
                                        Watering interval: {wateringInterval} hours
                                    </label>
                                    <input
                                        id="watering-interval"
                                        type="range"
                                        min="1"
                                        max="168"
                                        step="1"
                                        value={wateringInterval}
                                        onChange={(e) => setWateringInterval(Number(e.target.value))}
                                        disabled={loading}
                                    />
                                    <div className="range-labels">
                                        <span>1h</span>
                                        <span>24h</span>
                                        <span>72h</span>
                                        <span>168h</span>
                                    </div>
                                </div>

                                <div className="setting-group">
                                    <label htmlFor="watering-duration">
                                        Watering duration: {wateringDuration} seconds
                                    </label>
                                    <input
                                        id="watering-duration"
                                        type="range"
                                        min="10"
                                        max="300"
                                        step="5"
                                        value={wateringDuration}
                                        onChange={(e) => setWateringDuration(Number(e.target.value))}
                                        disabled={loading}
                                    />
                                    <div className="range-labels">
                                        <span>10s</span>
                                        <span>60s</span>
                                        <span>180s</span>
                                        <span>300s</span>
                                    </div>
                                </div>
                            </div>
                        )}

                        <button type="submit" disabled={loading} className="save-button">
                            {loading ? 'Saving...' : 'Save Watering Settings'}
                        </button>
                    </form>
                </section>

                {/* System Information */}
                <section className="settings-section">
                    <h2>System Information</h2>
                    
                    <div className="system-info">
                        <button onClick={handleSystemHealthCheck} className="health-check-button">
                            Run Health Check
                        </button>
                        
                        {lightingStatus && (
                            <div className="info-block">
                                <h3>Current Lighting Status</h3>
                                <ul>
                                    <li>State: {lightingStatus.is_on ? 'ON' : 'OFF'}</li>
                                    <li>Brightness: {lightingStatus.brightness}%</li>
                                    <li>Power Usage: {lightingStatus.power_usage.toFixed(1)}W</li>
                                    <li>Schedule: {lightingStatus.schedule_enabled ? 'Enabled' : 'Disabled'}</li>
                                </ul>
                            </div>
                        )}

                        {wateringStatus && (
                            <div className="info-block">
                                <h3>Current Watering Status</h3>
                                <ul>
                                    <li>State: {wateringStatus.is_running ? 'RUNNING' : 'STOPPED'}</li>
                                    <li>Water Level: {wateringStatus.water_level.toFixed(1)}L</li>
                                    <li>Auto Mode: {wateringStatus.auto_mode ? 'Enabled' : 'Disabled'}</li>
                                    <li>Emergency Stop: {wateringStatus.emergency_stop ? 'ACTIVE' : 'Normal'}</li>
                                </ul>
                            </div>
                        )}

                        {sensorData && (
                            <div className="info-block">
                                <h3>Current Sensor Readings</h3>
                                <ul>
                                    <li>Temperature: {sensorData.temperature.toFixed(1)}°C</li>
                                    <li>Humidity: {sensorData.humidity.toFixed(1)}%</li>
                                    <li>Soil Moisture: {sensorData.soil_moisture_0.toFixed(1)}%</li>
                                    <li>Light Level: {sensorData.light_level.toFixed(1)} lux</li>
                                    <li>Last Updated: {new Date(sensorData.timestamp).toLocaleString()}</li>
                                </ul>
                            </div>
                        )}
                    </div>
                </section>
            </div>
            </div>
        </div>
    );
};

export default SettingsPage;