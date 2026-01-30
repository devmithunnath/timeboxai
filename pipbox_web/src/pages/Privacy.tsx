import { Link } from 'react-router-dom';

const Privacy: React.FC = () => {
    return (
        <div style={{ paddingBottom: '120px' }}>
            <div className="container" style={{ padding: '0 24px' }}>
                <div style={{ padding: '20px 0', textAlign: 'left' }}>
                    <Link to="/" style={{ display: 'inline-flex', alignItems: 'center' }}>
                        <span style={{ fontSize: '32px', fontWeight: '800', fontFamily: 'var(--font-rounded)', color: '#1D1D1F' }}>
                            PipBox
                        </span>
                    </Link>
                </div>

                <h1 style={{ fontSize: '32px', marginBottom: '32px' }}>Privacy Policy</h1>

                <div style={{ fontSize: '18px', color: 'var(--text)', lineHeight: '1.8', display: 'flex', flexDirection: 'column', gap: '32px', maxWidth: '800px' }}>
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Your Privacy Matters</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            At PipBox, we are committed to being transparent about the data we collect and how it's used. Our goal is to provide you with the best focus experience while ensuring your personal information is handled responsibly.
                        </p>
                    </section>

                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Data Collection</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            To provide a seamless experience and help you track your productivity over time, PipBox stores your settings, timer presets, and session history securely in our cloud database. This allow us to provide you with insights into your focus patterns and ensure your data is always available to you.
                        </p>
                    </section>

                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Microphone & Speech Data</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            If you enable voice commands, PipBox uses the native macOS Speech Recognition framework. Audio processing happens on-device as provided by macOS. We do not record or upload your voice data to any servers.
                        </p>
                    </section>

                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Third-Party Services</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            PipBox does not use third-party tracking services, analytics, or advertising networks. We do not share any data with third parties.
                        </p>
                    </section>

                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Updates to this Policy</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.
                        </p>
                    </section>

                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Contact Us</h2>
                        <p style={{ color: 'var(--text-muted)' }}>
                            If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at <a href="mailto:support@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>support@timeboxai.com</a>.
                        </p>
                    </section>
                </div>
            </div>
        </div>
    );
};

export default Privacy;
