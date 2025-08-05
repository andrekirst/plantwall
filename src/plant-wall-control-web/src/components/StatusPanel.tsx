import React, { useEffect, useState } from 'react';
import { fetchStatus } from '../utils/api';

const StatusPanel: React.FC = () => {
    const [status, setStatus] = useState({
        soil_moisture: 0,
        external_light: 0,
        water_tank_level: 0,
    });

    useEffect(() => {
        const getStatus = async () => {
            const data = await fetchStatus();
            setStatus(data);
        };

        getStatus();
    }, []);

    return (
        <div className="status-panel">
            <h2>Plant Wall Status</h2>
            <p>Soil Moisture: {status.soil_moisture}%</p>
            <p>External Light: {status.external_light} lux</p>
            <p>Water Tank Level: {status.water_tank_level} liters</p>
        </div>
    );
};

export default StatusPanel;