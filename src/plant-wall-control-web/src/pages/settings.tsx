import { useState } from 'react';
import { updateSettings } from '../utils/api';

const SettingsPage = () => {
    const [brightness, setBrightness] = useState(0);
    const [wateringInterval, setWateringInterval] = useState(0);

    const handleBrightnessChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setBrightness(Number(event.target.value));
    };

    const handleWateringIntervalChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setWateringInterval(Number(event.target.value));
    };

    const handleSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        await updateSettings({ brightness, wateringInterval });
        alert('Settings updated successfully!');
    };

    return (
        <div>
            <h1>Settings</h1>
            <form onSubmit={handleSubmit}>
                <div>
                    <label>
                        Brightness:
                        <input
                            type="number"
                            value={brightness}
                            onChange={handleBrightnessChange}
                        />
                    </label>
                </div>
                <div>
                    <label>
                        Watering Interval (minutes):
                        <input
                            type="number"
                            value={wateringInterval}
                            onChange={handleWateringIntervalChange}
                        />
                    </label>
                </div>
                <button type="submit">Save Settings</button>
            </form>
        </div>
    );
};

export default SettingsPage;