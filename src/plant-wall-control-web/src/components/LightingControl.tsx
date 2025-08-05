import React, { useState } from 'react';

const LightingControl: React.FC = () => {
    const [brightness, setBrightness] = useState<number>(50);

    const handleBrightnessChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setBrightness(Number(event.target.value));
    };

    const handleSubmit = async (event: React.FormEvent) => {
        event.preventDefault();
        const response = await fetch('/settings', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ brightness }),
        });
        const data = await response.json();
        if (data.status === 'success') {
            alert('Lighting settings updated successfully!');
        } else {
            alert('Failed to update lighting settings.');
        }
    };

    return (
        <div>
            <h2>Lighting Control</h2>
            <form onSubmit={handleSubmit}>
                <label>
                    Brightness:
                    <input
                        type="range"
                        min="0"
                        max="100"
                        value={brightness}
                        onChange={handleBrightnessChange}
                    />
                </label>
                <button type="submit">Update</button>
            </form>
        </div>
    );
};

export default LightingControl;