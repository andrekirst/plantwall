import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';

const Navigation: React.FC = () => {
    const router = useRouter();
    
    const isActive = (path: string) => {
        return router.pathname === path;
    };

    return (
        <nav className="main-navigation">
            <div className="nav-container">
                <div className="nav-brand">
                    <Link href="/">
                        <span className="brand-text">🌿 Plant Wall</span>
                    </Link>
                </div>
                
                <div className="nav-links">
                    <Link href="/" className={`nav-link ${isActive('/') ? 'active' : ''}`}>
                        <span className="nav-icon">📊</span>
                        Dashboard
                    </Link>
                    <Link href="/settings" className={`nav-link ${isActive('/settings') ? 'active' : ''}`}>
                        <span className="nav-icon">⚙️</span>
                        Settings
                    </Link>
                </div>
            </div>
        </nav>
    );
};

export default Navigation;