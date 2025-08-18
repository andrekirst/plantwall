import React, { useState, useEffect } from 'react';
import { fetchLightingStatus, updateLighting } from '../utils/api';
import { LightingStatus, LightingControl } from '../types/index';

const LightingControlComponent: React.FC = () => {
    const [status, setStatus] = useState<LightingStatus | null>(null);
    const [brightness, setBrightness] = useState<number>(50);
    const [enabled, setEnabled] = useState<boolean>(false);
    const [scheduleEnabled, setScheduleEnabled] = useState<boolean>(false);
    const [onTime, setOnTime] = useState<string>('07:00');
    const [offTime, setOffTime] = useState<string>('20:00');
    const [loading, setLoading] = useState<boolean>(true);
    const [updating, setUpdating] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);
    const [message, setMessage] = useState<string | null>(null);

    // Fetch current lighting status
    const fetchCurrentStatus = async () => {
        try {
            setError(null);
            const lightingStatus = await fetchLightingStatus();
            setStatus(lightingStatus);
            
            // Update local state with current values
            if (lightingStatus) {
                setBrightness(lightingStatus.brightness || 50);
                setEnabled(lightingStatus.is_on || false);
                setScheduleEnabled(lightingStatus.schedule_enabled || false);
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to fetch lighting status';
            setError(errorMessage);
            console.error('Lighting status fetch error:', err);
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

    const handleBrightnessChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setBrightness(Number(event.target.value));
    };

    const handleToggleLighting = async () => {
        setUpdating(true);
        try {
            const lightingData: LightingControl = {
                brightness: brightness,
                enabled: !enabled,
            };

            const result = await updateLighting(lightingData);
            
            if (result.status === 'toggled' || result.status === 'success') {
                setEnabled(!enabled);
                setMessage(`Lighting ${!enabled ? 'turned on' : 'turned off'} successfully!`);
                
                // Refresh status to get latest values
                setTimeout(fetchCurrentStatus, 1000);
            } else {
                throw new Error('Unexpected response from server');
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to toggle lighting';
            setError(`Failed to toggle lighting: ${errorMessage}`);
        } finally {
            setUpdating(false);
        }
    };

    const handleBrightnessSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        setUpdating(true);
        
        try {
            const lightingData: LightingControl = {
                brightness: brightness,
                enabled: enabled,
            };

            const result = await updateLighting(lightingData);
            
            if (result.status === 'toggled' || result.status === 'success') {
                setMessage(`Brightness set to ${brightness}% successfully!`);
                
                // Refresh status to get latest values
                setTimeout(fetchCurrentStatus, 1000);
            } else {
                throw new Error('Unexpected response from server');
            }
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to update brightness';
            setError(`Failed to update brightness: ${errorMessage}`);
        } finally {
            setUpdating(false);
        }
    };

    const handleScheduleSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        setUpdating(true);
        
        try {
            const lightingData: LightingControl = {
                brightness: brightness,
                enabled: enabled,
                schedule: {
                    on_time: onTime,
                    off_time: offTime,
                    enabled: scheduleEnabled,
                },
            };

            const result = await updateLighting(lightingData);
            
            if (result.status === 'toggled' || result.status === 'success') {
                setMessage(`Schedule ${scheduleEnabled ? 'enabled' : 'disabled'} successfully!`);
                
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

    if (loading && !status) {
        return (
            <div className="lighting-control loading">
                <h2>Lighting Control</h2>
                <div className="loading-spinner">Loading lighting status...</div>
            </div>
        );
    }

    return (
        <div className="lighting-control">
            <div className="control-header">
                <h2>Lighting Control</h2>
                {status && (
                    <div className="current-status">
                        <span className={`status-indicator ${status.is_on ? 'on' : 'off'}`}>
                            {status.is_on ? '🔆 ON' : '🌙 OFF'}
                        </span>
                        <span className="power-usage">
                            {status.power_usage.toFixed(1)}W
                        </span>
                    </div>
                )}
            </div>

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

            {/* Quick Toggle */}
            <div className="control-section">
                <h3>Quick Control</h3>
                <button 
                    onClick={handleToggleLighting}
                    disabled={updating}
                    className={`toggle-button ${enabled ? 'on' : 'off'}`}
                >
                    {updating ? 'Updating...' : (enabled ? 'Turn OFF' : 'Turn ON')}
                </button>
            </div>

            {/* Brightness Control */}
            <div className="control-section">
                <form onSubmit={handleBrightnessSubmit}>
                    <h3>Brightness Control</h3>
                    <div className="brightness-control">
                        <label htmlFor="brightness">
                            Brightness: {brightness}%
                        </label>
                        <input
                            id="brightness"
                            type="range"
                            min="0"
                            max="100"
                            step="5"
                            value={brightness}
                            onChange={handleBrightnessChange}
                            disabled={updating}
                        />
                        <div className="brightness-marks">
                            <span>0%</span>
                            <span>25%</span>
                            <span>50%</span>
                            <span>75%</span>
                            <span>100%</span>
                        </div>
                    </div>
                    <button 
                        type="submit" 
                        disabled={updating}
                        className="update-button"
                    >
                        {updating ? 'Updating...' : 'Apply Brightness'}
                    </button>
                </form>
            </div>

            {/* Schedule Control */}
            <div className="control-section">
                <form onSubmit={handleScheduleSubmit}>
                    <h3>Schedule Control</h3>
                    <div className="schedule-control">
                        <label>
                            <input
                                type="checkbox"
                                checked={scheduleEnabled}
                                onChange={(e) => setScheduleEnabled(e.target.checked)}
                                disabled={updating}
                            />
                            Enable automatic scheduling
                        </label>
                        
                        {scheduleEnabled && (
                            <div className="schedule-times">
                                <div className="time-input">
                                    <label htmlFor="on-time">Turn on at:</label>
                                    <input
                                        id="on-time"
                                        type="time"
                                        value={onTime}
                                        onChange={(e) => setOnTime(e.target.value)}
                                        disabled={updating}
                                    />
                                </div>
                                <div className="time-input">
                                    <label htmlFor="off-time">Turn off at:</label>
                                    <input
                                        id="off-time"
                                        type="time"
                                        value={offTime}
                                        onChange={(e) => setOffTime(e.target.value)}
                                        disabled={updating}
                                    />
                                </div>
                            </div>
                        )}
                    </div>
                    <button 
                        type="submit" 
                        disabled={updating}
                        className="update-button"
                    >
                        {updating ? 'Updating...' : 'Apply Schedule'}
                    </button>
                </form>
            </div>

            {/* Status Information */}
            {status && (
                <div className="status-info">
                    <h3>Status Information</h3>
                    <div className="info-grid">
                        <div className="info-item">
                            <span className="info-label">Current State:</span>
                            <span className="info-value">{status.is_on ? 'ON' : 'OFF'}</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Brightness:</span>
                            <span className="info-value">{status.brightness}%</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Power Usage:</span>
                            <span className="info-value">{status.power_usage.toFixed(1)}W</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Schedule:</span>
                            <span className="info-value">{status.schedule_enabled ? 'Enabled' : 'Disabled'}</span>
                        </div>
                        <div className="info-item">
                            <span className="info-label">Last Changed:</span>
                            <span className="info-value">
                                {new Date(status.last_changed).toLocaleString()}
                            </span>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default LightingControlComponent;