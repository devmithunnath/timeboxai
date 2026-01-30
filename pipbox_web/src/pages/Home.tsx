import React from 'react';
import TimerDemo from '../components/TimerDemo';
import { Apple, CheckCircle, Zap, Clock } from 'lucide-react';

const Home: React.FC = () => {
    return (
        <div>
            {/* Hero Section */}
            <section style={{ padding: '80px 0 120px', textAlign: 'center', overflow: 'hidden' }}>
                <div className="container">
                    <div style={{ padding: '0', textAlign: 'center' }}>
                        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0', marginBottom: '0' }}>
                            <img src="/assets/ant.svg" alt="PipBox Logo" style={{ width: '200px', height: 'auto' }} />
                            <span style={{ fontSize: '100px', fontWeight: '800', fontFamily: 'var(--font-rounded)', letterSpacing: '-2px' }}>
                                PipBox
                            </span>
                        </div>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '24px', marginBottom: '60px' }}>
                        <h1 style={{
                            fontSize: '84px',
                            lineHeight: '1',
                            color: 'var(--text)',
                            maxWidth: '800px',
                            fontFamily: 'var(--font-rounded)'
                        }}>
                            built for <span style={{ color: 'var(--primary)' }}>deep focus</span>
                        </h1>
                        <p style={{
                            fontSize: '24px',
                            color: 'var(--text-muted)',
                            maxWidth: '600px',
                            fontWeight: '500'
                        }}>
                            Small steps matter. Block your time, beat distraction, and do your best work.
                        </p>
                        <div style={{ display: 'flex', gap: '16px', marginTop: '12px' }}>
                            <button style={{
                                background: 'var(--text)',
                                color: '#fff',
                                padding: '16px 32px',
                                borderRadius: '20px',
                                display: 'flex',
                                alignItems: 'center',
                                gap: '12px',
                                fontSize: '18px',
                                fontWeight: '600'
                            }}>
                                <Apple fill="#fff" size={24} />
                                Download for macOS
                            </button>
                        </div>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'center', perspective: '1000px' }}>
                        <div style={{
                            transform: 'rotateX(5deg) scale(1.05)',
                            boxShadow: '0 40px 100px rgba(0,0,0,0.1)',
                            borderRadius: '40px',
                            overflow: 'hidden'
                        }}>
                            <img src="/assets/screenshots/hero_main.png" alt="PipBox UI" style={{ maxWidth: '900px', width: '100%' }} />
                        </div>
                    </div>
                </div>
            </section>

            {/* Interactive Demo Section */}
            <section style={{ background: '#F9F9FB', padding: '120px 0' }}>
                <div className="container" style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: '80px', alignItems: 'center' }}>
                    <div>
                        <h2 style={{ fontSize: '48px', marginBottom: '24px' }}>Try the <span style={{ color: 'var(--primary)' }}>live timer</span></h2>
                        <p style={{ fontSize: '20px', color: 'var(--text-muted)', marginBottom: '40px' }}>
                            Experience the minimalist flow. Tap the timer to start your session. No complex setup, no noise—just pure focus.
                        </p>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
                            <div style={{ display: 'flex', gap: '16px', alignItems: 'start' }}>
                                <div style={{ background: 'var(--accent-soft)', padding: '10px', borderRadius: '12px', color: 'var(--primary)' }}>
                                    <Clock size={24} />
                                </div>
                                <div>
                                    <h4 style={{ fontSize: '18px', marginBottom: '8px' }}>Optimized Intervals</h4>
                                    <p style={{ color: 'var(--text-muted)' }}>Proven durations for productivity. 5, 10, or 25 minutes sessions.</p>
                                </div>
                            </div>
                            <div style={{ display: 'flex', gap: '16px', alignItems: 'start' }}>
                                <div style={{ background: 'var(--accent-soft)', padding: '10px', borderRadius: '12px', color: 'var(--primary)' }}>
                                    <Zap size={24} />
                                </div>
                                <div>
                                    <h4 style={{ fontSize: '18px', marginBottom: '8px' }}>Visual Feedback</h4>
                                    <p style={{ color: 'var(--text-muted)' }}>Beautiful animated ring helps you track your progress subconsciously.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'center' }}>
                        <TimerDemo />
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section id="features" style={{ padding: '120px 0' }}>
                <div className="container">
                    <div style={{ textAlign: 'center', marginBottom: '80px' }}>
                        <span style={{ color: 'var(--primary)', fontWeight: '700', fontSize: '14px', letterSpacing: '2px', textTransform: 'uppercase' }}>Features</span>
                        <h2 style={{ fontSize: '48px', marginTop: '16px' }}>Crafted for your flow.</h2>
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '40px', maxWidth: '800px', margin: '0 auto' }}>
                        <FeatureCard
                            icon={<Zap size={32} />}
                            title="Super Fast"
                            description="Built with a focus on performance. Zero lag, zero noise, just productivity."
                        />
                        <FeatureCard
                            icon={<CheckCircle size={32} />}
                            title="Custom Presets"
                            description="Save your favorite intervals for different tasks like coding or reading."
                        />
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section style={{ padding: '120px 0' }}>
                <div className="container">
                    <div style={{
                        background: 'var(--primary)',
                        borderRadius: '48px',
                        padding: '80px',
                        textAlign: 'center',
                        color: '#fff',
                        boxShadow: '0 40px 80px rgba(255, 93, 57, 0.2)'
                    }}>
                        <h2 style={{ fontSize: '48px', marginBottom: '24px' }}>Ready to start your focus journey?</h2>
                        <p style={{ fontSize: '20px', opacity: '0.9', maxWidth: '600px', margin: '0 auto 40px' }}>
                            Download PipBox for macOS and experience the simplest way to manage your time.
                        </p>
                        <button style={{
                            background: '#fff',
                            color: 'var(--primary)',
                            padding: '20px 48px',
                            borderRadius: '24px',
                            fontSize: '20px',
                            fontWeight: '700',
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '12px'
                        }}>
                            <Apple size={24} fill="var(--primary)" />
                            Download Now
                        </button>
                    </div>
                </div>
            </section>
        </div>
    );
};

const FeatureCard = ({ icon, title, description }: { icon: any, title: string, description: string }) => (
    <div style={{
        padding: '40px',
        background: '#fff',
        borderRadius: '32px',
        border: '1px solid #F2F2F7',
        textAlign: 'center'
    }}>
        <div style={{ color: 'var(--primary)', marginBottom: '24px', display: 'flex', justifyContent: 'center' }}>{icon}</div>
        <h3 style={{ fontSize: '20px', marginBottom: '16px' }}>{title}</h3>
        <p style={{ color: 'var(--text-muted)' }}>{description}</p>
    </div>
);

export default Home;
