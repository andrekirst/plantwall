import React, { useState, useEffect } from 'react';
import { fetchWateringStatus, triggerWatering } from '../utils/api';
import { WateringStatus, WateringControl } from '../types/index';

const WateringControlComponent: React.FC = () => {
    const [status, setStatus] = useState<WateringStatus | null>(null);
    const [duration, setDuration] = useState<number>(30); // seconds
    const [autoMode, setAutoMode] = useState<boolean>(false);
    const [intervalHours, setIntervalHours] = useState<number>(24);
    const [loading, setLoading] = useState<boolean>(true);
    const [updating, setUpdating] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);

    // Fetch current watering status
    const fetchCurrentStatus = async () => {
        try {
            setError(null);
            const wateringStatus = await fetchWateringStatus();
            setStatus(wateringStatus);
            
            // Update local state with current values
            if (wateringStatus) {
                setAutoMode(wateringStatus.auto_mode || false);
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to fetch watering status';
            setError(errorMessage);
            console.error('Watering status fetch error:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCurrentStatus();
        
        // Refresh status every 30 seconds
        const interval = setInterval(fetchCurrentStatus, 30000);
        return () => clearInterval(interval);
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

    const handleManualWatering = async () => {
        if (status?.emergency_stop) {
            setError('Cannot start watering: Emergency stop is active');
            return;
        }

        setUpdating(true);
        try {
            const wateringData: WateringControl = {
                duration: duration,
                auto_mode: false,
            };

            const result = await triggerWatering(wateringData);
            
            if (result.status === 'watering started' || result.status === 'success') {
                setMessage(`Manual watering started for ${duration} seconds`);
                
                // Refresh status to get latest values
                setTimeout(fetchCurrentStatus, 1000);
            } else {
                throw new Error('Unexpected response from server');
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to start watering';
            setError(`Failed to start watering: ${errorMessage}`);
        } finally {
            setUpdating(false);
        }
    };

    const handleAutoModeToggle = async () => {
        setUpdating(true);
        try {
            const wateringData: WateringControl = {
                auto_mode: !autoMode,
                schedule: {
                    interval_hours: intervalHours,
                    duration_seconds: duration,
                    enabled: !autoMode,
                },
            };

            const result = await triggerWatering(wateringData);
            
            if (result.status === 'success' || result.status === 'watering started') {
                setAutoMode(!autoMode);
                setMessage(`Auto mode ${!autoMode ? 'enabled' : 'disabled'} successfully!`);
                
                // Refresh status to get latest values
                setTimeout(fetchCurrentStatus, 1000);
            } else {
                throw new Error('Unexpected response from server');
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to toggle auto mode';
            setError(`Failed to toggle auto mode: ${errorMessage}`);
        } finally {
            setUpdating(false);
        }
    };

    const handleScheduleUpdate = async (event: React.FormEvent) => {
        event.preventDefault();
        setUpdating(true);
        
        try {
            const wateringData: WateringControl = {
                auto_mode: autoMode,
                schedule: {
                    interval_hours: intervalHours,
                    duration_seconds: duration,
                    enabled: autoMode,
                },
            };

            const result = await triggerWatering(wateringData);
            
            if (result.status === 'success' || result.status === 'watering started') {
                setMessage('Schedule updated successfully!');
                
                // Refresh status to get latest values
                setTimeout(fetchCurrentStatus, 1000);
            } else {
                throw new Error('Unexpected response from server');
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to update schedule';
            setError(`Failed to update schedule: ${errorMessage}`);
        } finally {
            setUpdating(false);
        }
    };

    const formatLastWatering = (timestamp: string) => {
        try {
            const date = new Date(timestamp);
            const now = new Date();
            const diffMs = now.getTime() - date.getTime();
            const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
            const diffMins = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
            
            if (diffHours > 0) {
                return `${diffHours}h ${diffMins}m ago`;
            }
            return `${diffMins}m ago`;
        } catch {
            return 'Unknown';
        }
    };

    const getWaterLevelColor = (level: number) => {
        if (level < 20) return '#ff4444'; // Low - red
        if (level < 40) return '#ffaa00'; // Medium - orange
        return '#44ff44'; // High - green
    };

    if (loading && !status) {
        return (
            <div className="watering-control loading">
                <h2>Watering Control</h2>
                <div className="loading-spinner">Loading watering status...</div>
            </div>
        );
    }

    return (
        <div className="watering-control">
            <div className="control-header">
                <h2>Watering Control</h2>
                {status && (
                    <div className="current-status">
                        <span className={`status-indicator ${status.is_running ? 'running' : 'stopped'}`}>
                            {status.is_running ? '💧 RUNNING' : '⏸️ STOPPED'}
                        </span>
                        <span 
                            className="water-level"
                            style={{ color: getWaterLevelColor(status.water_level) }}
                        >
                            {status.water_level.toFixed(1)}L
                        </span>
                    </div>
                )}
            </div>

            {/* Emergency Stop Warning */}
            {status?.emergency_stop && (
                <div className="alert alert-error emergency">
                    <strong>EMERGENCY STOP ACTIVE</strong>
                    <p>Watering system is disabled. Check system status before continuing.</p>
                </div>
            )}

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

            {/* Manual Watering */}
            <div className="control-section">
                <h3>Manual Watering</h3>
                <div className="manual-control">
                    <div className="duration-control">
                        <label htmlFor="duration">
                            Duration: {duration} seconds
                        </label>
                        <input
                            id="duration"
                            type="range"
                            min="10"
                            max="300"
                            step="5"
                            value={duration}
                            onChange={(e) => setDuration(Number(e.target.value))}
                            disabled={updating || status?.emergency_stop}
                        />
                        <div className="duration-marks">
                            <span>10s</span>
                            <span>60s</span>
                            <span>120s</span>
                            <span>240s</span>
                            <span>300s</span>
                        </div>
                    </div>
                    <button 
                        onClick={handleManualWatering}
                        disabled={updating || status?.emergency_stop || status?.is_running}
                        className="water-button manual"
                    >
                        {updating ? 'Starting...' : 'Start Manual Watering'}
                    </button>
                    {status?.is_running && (
                        <div className="watering-active">
                            <span className="running-indicator">🌊 Watering in progress...</span>
                        </div>
                    )}
                </div>
            </div>

            {/* Automatic Mode */}
            <div className="control-section">
                <h3>Automatic Mode</h3>
                <div className="auto-control">
                    <label>
                        <input
                            type="checkbox"
                            checked={autoMode}
                            onChange={handleAutoModeToggle}
                            disabled={updating || status?.emergency_stop}
                        />
                        Enable automatic watering
                    </label>
                    
                    {autoMode && (
                        <form onSubmit={handleScheduleUpdate}>
                            <div className="schedule-settings">
                                <div className="setting-row">
                                    <label htmlFor="interval">
                                        Watering interval: {intervalHours} hours
                                    </label>
                                    <input
                                        id="interval"
                                        type="range"
                                        min="1"
                                        max="168"
                                        step="1"
                                        value={intervalHours}
                                        onChange={(e) => setIntervalHours(Number(e.target.value))}
                                        disabled={updating}
                                    />
                                    <div className="interval-marks">
                                        <span>1h</span>
                                        <span>12h</span>
                                        <span>24h</span>
                                        <span>72h</span>
                                        <span>168h</span>
                                    </div>
                                </div>
                                
                                <div className="setting-row">
                                    <label htmlFor="auto-duration">
                                        Auto watering duration: {duration} seconds
                                    </label>
                                    <input
                                        id="auto-duration"
                                        type="range"
                                        min="10"
                                        max="300"
                                        step="5"
                                        value={duration}
                                        onChange={(e) => setDuration(Number(e.target.value))}
                                        disabled={updating}
                                    />
                                </div>
                            </div>
                            <button 
                                type="submit" 
                                disabled={updating}
                                className="update-button"
                            >
                                {updating ? 'Updating...' : 'Update Schedule'}
                            </button>
                        </form>
                    )}
                </div>
            </div>

            {/* Status Information */}
            {status && (
                <div className="status-info">
                    <h3>Status Information</h3>
                    <div className="info-grid">
                        <div className="info-item">
                            <span className="info-label">Current State:</span>
                            <span className="info-value">{status.is_running ? 'RUNNING' : 'STOPPED'}</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Water Level:</span>
                            <span 
                                className="info-value"
                                style={{ color: getWaterLevelColor(status.water_level) }}
                            >
                                {status.water_level.toFixed(1)}L
                            </span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Auto Mode:</span>
                            <span className="info-value">{status.auto_mode ? 'Enabled' : 'Disabled'}</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Last Watering:</span>
                            <span className="info-value">
                                {formatLastWatering(status.last_watering)}
                            </span>
                        </div>
                        {status.next_scheduled && (
                            <div className="info-item">
                                <span className="info-label">Next Scheduled:</span>
                                <span className="info-value">
                                    {new Date(status.next_scheduled).toLocaleString()}
                                </span>
                            </div>
                        )}
                        <div className="info-item">
                            <span className="info-label">Emergency Stop:</span>
                            <span className={`info-value ${status.emergency_stop ? 'error' : 'success'}`}>
                                {status.emergency_stop ? 'ACTIVE' : 'Normal'}
                            </span>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default WateringControlComponent;