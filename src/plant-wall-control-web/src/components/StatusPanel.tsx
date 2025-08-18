import React, { useEffect, useState } from 'react';
import { fetchStatus, checkHealth } from '../utils/api';
import { SystemStatus, SystemHealth } from '../types/index';

interface StatusPanelProps {
    refreshInterval?: number; // in milliseconds
}

const StatusPanel: React.FC<StatusPanelProps> = ({ refreshInterval = 30000 }) => {
    const [status, setStatus] = useState<SystemStatus | null>(null);
    const [health, setHealth] = useState<SystemHealth | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [lastUpdate, setLastUpdate] = useState<Date | null>(null);

    const fetchSystemData = async () => {
        try {
            setError(null);
            
            // Fetch system status
            const statusData = await fetchStatus();
            setStatus(statusData);
            
            // Attempt to fetch health data (may not be available)
            try {
                const healthData = await checkHealth();
                if (healthData.status) {
                    setHealth(healthData);
                }
            } catch (healthError) {
                console.warn('Health endpoint not available:', healthError);
            }
            
            setLastUpdate(new Date());
        } catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Failed to fetch status';
            setError(errorMessage);
            console.error('Status fetch error:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        // Initial fetch
        fetchSystemData();

        // Set up interval for regular updates
        const interval = setInterval(() => {
            fetchSystemData();
        }, refreshInterval);

        return () => clearInterval(interval);
    }, [refreshInterval]);

    if (loading && !status) {
        return (
            <div className="status-panel loading">
                <h2>Plant Wall Status</h2>
                <div className="loading-spinner">Loading system status...</div>
            </div>
        );
    }

    if (error && !status) {
        return (
            <div className="status-panel error">
                <h2>Plant Wall Status</h2>
                <div className="error-message">
                    <strong>Connection Error:</strong> {error}
                    <button onClick={fetchSystemData} className="retry-button">
                        Retry
                    </button>
                </div>
            </div>
        );
    }

    const formatTimestamp = (timestamp: string) => {
        try {
            return new Date(timestamp).toLocaleString();
        } catch {
            return 'Unknown';
        }
    };

    const getStatusColor = (value: number, type: 'moisture' | 'temperature' | 'water') => {
        switch (type) {
            case 'moisture':
                if (value < 30) return '#ff4444'; // Low - red
                if (value < 60) return '#ffaa00'; // Medium - orange
                return '#44ff44'; // High - green
            case 'temperature':
                if (value < 18 || value > 28) return '#ff4444'; // Too cold/hot - red
                if (value < 20 || value > 26) return '#ffaa00'; // Suboptimal - orange
                return '#44ff44'; // Optimal - green
            case 'water':
                if (value < 20) return '#ff4444'; // Low - red
                if (value < 40) return '#ffaa00'; // Medium - orange
                return '#44ff44'; // High - green
            default:
                return '#666666';
        }
    };

    return (
        <div className="status-panel">
            <div className="status-header">
                <h2>Plant Wall Status</h2>
                {lastUpdate && (
                    <div className="last-update">
                        Last updated: {lastUpdate.toLocaleTimeString()}
                    </div>
                )}
                {error && (
                    <div className="connection-warning">
                        ⚠️ Connection issues detected
                    </div>
                )}
            </div>

            {status && (
                <div className="status-grid">
                    <div className="status-item">
                        <div className="status-label">Soil Moisture</div>
                        <div 
                            className="status-value"
                            style={{ color: getStatusColor(status.soil_moisture, 'moisture') }}
                        >
                            {status.soil_moisture.toFixed(1)}%
                        </div>
                    </div>

                    <div className="status-item">
                        <div className="status-label">Temperature</div>
                        <div 
                            className="status-value"
                            style={{ color: getStatusColor(status.temperature, 'temperature') }}
                        >
                            {status.temperature.toFixed(1)}°C
                        </div>
                    </div>

                    <div className="status-item">
                        <div className="status-label">Humidity</div>
                        <div className="status-value">
                            {status.humidity.toFixed(1)}%
                        </div>
                    </div>

                    <div className="status-item">
                        <div className="status-label">Water Level</div>
                        <div 
                            className="status-value"
                            style={{ color: getStatusColor(status.water_level, 'water') }}
                        >
                            {status.water_level.toFixed(1)}L
                        </div>
                    </div>

                    <div className="status-item">
                        <div className="status-label">Lighting</div>
                        <div className="status-value">
                            {status.lighting_on ? '🔆 ON' : '🌙 OFF'}
                        </div>
                    </div>

                    <div className="status-item">
                        <div className="status-label">Nutrients</div>
                        <div className="status-value">
                            {status.nutrient_level.toFixed(1)}%
                        </div>
                    </div>
                </div>
            )}

            {status?.timestamp && (
                <div className="system-timestamp">
                    System time: {formatTimestamp(status.timestamp)}
                </div>
            )}

            {health && (
                <div className="health-indicators">
                    <div className="health-title">System Health</div>
                    <div className="health-grid">
                        {Object.entries(health).map(([system, isHealthy]) => (
                            <div key={system} className="health-item">
                                <span className={`health-indicator ${isHealthy ? 'healthy' : 'unhealthy'}`}>
                                    {isHealthy ? '✅' : '❌'}
                                </span>
                                {system.replace('_', ' ').toUpperCase()}
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
};

export default StatusPanel;