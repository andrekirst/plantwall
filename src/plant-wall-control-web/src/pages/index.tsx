import React from 'react';
import StatusPanel from '../components/StatusPanel';
import LightingControl from '../components/LightingControl';
import WateringControl from '../components/WateringControl';
import Navigation from '../components/Navigation';

const Home: React.FC = () => {
    return (
        <div className="plant-wall-app">
            <Navigation />
            <header className="app-header">
                <h1>Plant Wall Control</h1>
                <p>Automated plant wall monitoring and control system</p>
            </header>

            <main className="app-main">
                <div className="dashboard-grid">
                    {/* Status Panel - Primary display */}
                    <section className="status-section">
                        <StatusPanel refreshInterval={30000} />
                    </section>

                    {/* Control Panels */}
                    <div className="controls-grid">
                        <section className="lighting-section">
                            <LightingControl />
                        </section>

                        <section className="watering-section">
                            <WateringControl />
                        </section>
                    </div>
                </div>
            </main>

            <footer className="app-footer">
                <p>Connected to backend at {process.env.NODE_ENV === 'production' ? 'backend:5000' : 'localhost:5000'}</p>
            </footer>
        </div>
    );
};

export default Home;