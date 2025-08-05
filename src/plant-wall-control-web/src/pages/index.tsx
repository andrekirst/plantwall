import { useEffect, useState } from 'react';
import StatusPanel from '../components/StatusPanel';
import LightingControl from '../components/LightingControl';
import { fetchStatus } from '../utils/api';

const Home = () => {
    const [status, setStatus] = useState(null);

    useEffect(() => {
        const getStatus = async () => {
            const currentStatus = await fetchStatus();
            setStatus(currentStatus);
        };

        getStatus();
    }, []);

    return (
        <div>
            <h1>Plant Wall Control</h1>
            {status ? (
                <>
                    <StatusPanel status={status} />
                    <LightingControl />
                </>
            ) : (
                <p>Loading...</p>
            )}
        </div>
    );
};

export default Home;