import React from 'react';
import { Link } from 'react-router-dom';

export const Navbar: React.FC = () => {
    return (
        <div style={{
            padding: '32px 0',
            textAlign: 'center'
        }}>
            <Link to="/" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '16px' }}>
                <img src="/assets/ant.svg" alt="PipBox" style={{ width: '56px', height: '56px' }} />
                <span style={{ fontSize: '32px', fontWeight: '800', fontFamily: 'var(--font-rounded)', letterSpacing: '-0.5px' }}>
                    PipBox
                </span>
            </Link>
        </div>
    );
};

export const Footer: React.FC = () => {
    return (
        <footer style={{ background: '#F9F9FB', padding: '80px 0 40px', borderTop: '1px solid #E5E5EA' }}>
            <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <img src="/assets/ant.svg" alt="PipBox" style={{ width: '40px', height: '40px' }} />
                    <span style={{ fontSize: '24px', fontWeight: '800', fontFamily: 'var(--font-rounded)' }}>PipBox</span>
                </div>
                <div style={{ display: 'flex', gap: '32px', alignItems: 'center' }}>
                    <Link to="/privacy" style={{ fontWeight: '600', color: 'var(--text-muted)' }}>Privacy Policy</Link>
                    <div style={{ color: 'var(--text-muted)', fontSize: '14px' }}>
                        © {new Date().getFullYear()} Timebox AI
                    </div>
                </div>
            </div>
        </footer>
    );
};
