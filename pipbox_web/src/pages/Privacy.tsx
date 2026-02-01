import { Link } from 'react-router-dom';

const Privacy: React.FC = () => {
    const lastUpdated = "February 1, 2026";

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

                <h1 style={{ fontSize: '32px', marginBottom: '16px' }}>Privacy Policy</h1>
                <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '40px' }}>
                    Last updated: {lastUpdated}
                </p>

                <div style={{ fontSize: '17px', color: 'var(--text)', lineHeight: '1.8', display: 'flex', flexDirection: 'column', gap: '40px', maxWidth: '800px' }}>

                    {/* Introduction */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Introduction</h2>
                        <p>
                            Welcome to PipBox ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you understand how your information is collected, used, and safeguarded. This Privacy Policy explains our practices regarding the PipBox application for macOS ("App") and our website at pipbox.app ("Website").
                        </p>
                        <p style={{ marginTop: '16px' }}>
                            By using PipBox, you agree to the collection and use of information in accordance with this policy. If you do not agree with our policies and practices, please do not use PipBox.
                        </p>
                    </section>

                    {/* Information We Collect */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Information We Collect</h2>

                        <h3 style={{ fontSize: '18px', marginBottom: '12px', marginTop: '24px', fontWeight: '600' }}>Account Information</h3>
                        <p>
                            When you create a PipBox account, we collect:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>Email address (for account identification and communication)</li>
                            <li style={{ marginBottom: '8px' }}>Display name (optional, for personalization)</li>
                            <li style={{ marginBottom: '8px' }}>Account creation date</li>
                        </ul>

                        <h3 style={{ fontSize: '18px', marginBottom: '12px', marginTop: '24px', fontWeight: '600' }}>Usage Data</h3>
                        <p>
                            To provide our core functionality and help you track your productivity, we collect:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>Timer session history (start time, duration, completion status)</li>
                            <li style={{ marginBottom: '8px' }}>Custom timer presets you create</li>
                            <li style={{ marginBottom: '8px' }}>Application preferences and settings</li>
                            <li style={{ marginBottom: '8px' }}>Keyboard shortcuts you configure</li>
                            <li style={{ marginBottom: '8px' }}>Notification preferences</li>
                        </ul>

                        <h3 style={{ fontSize: '18px', marginBottom: '12px', marginTop: '24px', fontWeight: '600' }}>Technical Information</h3>
                        <p>
                            We automatically collect certain technical information:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>Device type and operating system version</li>
                            <li style={{ marginBottom: '8px' }}>App version</li>
                            <li style={{ marginBottom: '8px' }}>General usage patterns (feature usage frequency)</li>
                            <li style={{ marginBottom: '8px' }}>Crash reports and error logs (anonymized)</li>
                        </ul>
                    </section>

                    {/* How We Use Your Information */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>How We Use Your Information</h2>
                        <p>We use the information we collect to:</p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>Provide Core Services:</strong> Sync your timer sessions, presets, and settings across sessions</li>
                            <li style={{ marginBottom: '8px' }}><strong>Personalize Your Experience:</strong> Remember your preferences and display relevant insights</li>
                            <li style={{ marginBottom: '8px' }}><strong>Improve the App:</strong> Understand how features are used to make PipBox better</li>
                            <li style={{ marginBottom: '8px' }}><strong>Provide Support:</strong> Help troubleshoot issues and respond to your inquiries</li>
                            <li style={{ marginBottom: '8px' }}><strong>Send Communications:</strong> Important updates about your account or the service (you can opt out of non-essential communications)</li>
                        </ul>
                    </section>

                    {/* Voice Commands & Microphone */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Voice Commands & Microphone Access</h2>
                        <p>
                            PipBox offers optional voice command functionality to control your timer hands-free. Here's how we handle voice data:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>On-Device Processing:</strong> All speech recognition is performed locally on your Mac using Apple's native Speech Recognition framework. Your voice is never sent to our servers.</li>
                            <li style={{ marginBottom: '8px' }}><strong>No Audio Recording:</strong> We do not record, store, or transmit any audio data.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Permission Control:</strong> Microphone access is entirely optional and can be enabled or disabled at any time in your Mac's System Settings.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Apple's Privacy:</strong> Speech processing is subject to Apple's privacy policies. Apple may use anonymized speech data to improve Siri and dictation services as described in their privacy policy.</li>
                        </ul>
                    </section>

                    {/* Data Storage & Security */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Data Storage & Security</h2>
                        <p>
                            We take the security of your data seriously:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>Cloud Infrastructure:</strong> Your data is stored securely using Supabase, a trusted cloud database provider with enterprise-grade security.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Encryption:</strong> All data is encrypted in transit using TLS/SSL and encrypted at rest.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Access Controls:</strong> Strict access controls ensure only you can access your personal data.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Data Centers:</strong> Your data is stored in secure data centers with physical security measures, redundant power, and 24/7 monitoring.</li>
                        </ul>
                    </section>

                    {/* Data Retention */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Data Retention</h2>
                        <p>
                            We retain your personal information for as long as your account is active or as needed to provide you services. Specifically:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>Account Data:</strong> Retained until you delete your account</li>
                            <li style={{ marginBottom: '8px' }}><strong>Session History:</strong> Retained for the lifetime of your account to provide productivity insights</li>
                            <li style={{ marginBottom: '8px' }}><strong>Settings & Presets:</strong> Retained until you modify or delete them, or delete your account</li>
                            <li style={{ marginBottom: '8px' }}><strong>Technical Logs:</strong> Automatically deleted after 90 days</li>
                        </ul>
                        <p style={{ marginTop: '16px' }}>
                            When you delete your account, we will delete or anonymize your personal information within 30 days, except where we are required to retain certain information for legal or legitimate business purposes.
                        </p>
                    </section>

                    {/* Third-Party Services */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Third-Party Services</h2>
                        <p>
                            We are committed to minimizing third-party data sharing:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>No Advertising:</strong> We do not display ads or share data with advertising networks.</li>
                            <li style={{ marginBottom: '8px' }}><strong>No Data Selling:</strong> We never sell, rent, or trade your personal information to third parties.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Limited Analytics:</strong> We use privacy-focused analytics (PostHog) to understand app usage. This data is anonymized and used solely to improve PipBox.</li>
                            <li style={{ marginBottom: '8px' }}><strong>Infrastructure Providers:</strong> We use Supabase for data storage. They process data on our behalf and are bound by data processing agreements.</li>
                        </ul>
                    </section>

                    {/* Your Rights */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Your Rights & Choices</h2>
                        <p>
                            You have the following rights regarding your personal data:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}><strong>Access:</strong> Request a copy of the personal data we hold about you</li>
                            <li style={{ marginBottom: '8px' }}><strong>Correction:</strong> Request correction of inaccurate personal data</li>
                            <li style={{ marginBottom: '8px' }}><strong>Deletion:</strong> Request deletion of your personal data and account</li>
                            <li style={{ marginBottom: '8px' }}><strong>Export:</strong> Request a portable copy of your data</li>
                            <li style={{ marginBottom: '8px' }}><strong>Opt-Out:</strong> Opt out of non-essential communications at any time</li>
                            <li style={{ marginBottom: '8px' }}><strong>Withdraw Consent:</strong> Withdraw consent for optional features like voice commands</li>
                        </ul>
                        <p style={{ marginTop: '16px' }}>
                            To exercise any of these rights, please contact us at <a href="mailto:privacy@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>privacy@timeboxai.com</a>.
                        </p>
                    </section>

                    {/* Children's Privacy */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Children's Privacy</h2>
                        <p>
                            PipBox is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately at <a href="mailto:privacy@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>privacy@timeboxai.com</a>, and we will take steps to delete such information.
                        </p>
                    </section>

                    {/* International Data Transfers */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>International Data Transfers</h2>
                        <p>
                            Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws. When we transfer your data internationally, we ensure appropriate safeguards are in place to protect your information in accordance with this Privacy Policy and applicable law.
                        </p>
                    </section>

                    {/* California Privacy Rights */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>California Privacy Rights (CCPA)</h2>
                        <p>
                            If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>Right to know what personal information is collected, used, shared, or sold</li>
                            <li style={{ marginBottom: '8px' }}>Right to delete personal information held by us</li>
                            <li style={{ marginBottom: '8px' }}>Right to opt-out of sale of personal information (note: we do not sell personal information)</li>
                            <li style={{ marginBottom: '8px' }}>Right to non-discrimination for exercising your privacy rights</li>
                        </ul>
                        <p style={{ marginTop: '16px' }}>
                            To exercise these rights, please contact us at <a href="mailto:privacy@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>privacy@timeboxai.com</a>.
                        </p>
                    </section>

                    {/* European Privacy Rights */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>European Privacy Rights (GDPR)</h2>
                        <p>
                            If you are located in the European Economic Area (EEA), United Kingdom, or Switzerland, you have rights under the General Data Protection Regulation (GDPR):
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>Right of access to your personal data</li>
                            <li style={{ marginBottom: '8px' }}>Right to rectification of inaccurate data</li>
                            <li style={{ marginBottom: '8px' }}>Right to erasure ("right to be forgotten")</li>
                            <li style={{ marginBottom: '8px' }}>Right to restrict processing</li>
                            <li style={{ marginBottom: '8px' }}>Right to data portability</li>
                            <li style={{ marginBottom: '8px' }}>Right to object to processing</li>
                            <li style={{ marginBottom: '8px' }}>Right to withdraw consent at any time</li>
                            <li style={{ marginBottom: '8px' }}>Right to lodge a complaint with a supervisory authority</li>
                        </ul>
                        <p style={{ marginTop: '16px' }}>
                            <strong>Legal Basis for Processing:</strong> We process your personal data based on: (1) your consent, (2) performance of our contract with you, (3) our legitimate interests, and (4) compliance with legal obligations.
                        </p>
                    </section>

                    {/* Changes to This Policy */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Changes to This Privacy Policy</h2>
                        <p>
                            We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. When we make material changes:
                        </p>
                        <ul style={{ marginTop: '12px', marginLeft: '24px', listStyleType: 'disc' }}>
                            <li style={{ marginBottom: '8px' }}>We will update the "Last updated" date at the top of this policy</li>
                            <li style={{ marginBottom: '8px' }}>We will notify you via email or in-app notification for significant changes</li>
                            <li style={{ marginBottom: '8px' }}>We will post the updated policy on our website</li>
                        </ul>
                        <p style={{ marginTop: '16px' }}>
                            We encourage you to review this Privacy Policy periodically to stay informed about how we are protecting your information.
                        </p>
                    </section>

                    {/* Contact Us */}
                    <section>
                        <h2 style={{ fontSize: '24px', marginBottom: '16px', fontWeight: '700' }}>Contact Us</h2>
                        <p>
                            If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:
                        </p>
                        <div style={{ marginTop: '16px', padding: '24px', background: '#F9F9FB', borderRadius: '16px' }}>
                            <p style={{ marginBottom: '8px' }}><strong>Timebox AI</strong></p>
                            <p style={{ marginBottom: '8px' }}>Email: <a href="mailto:privacy@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>privacy@timeboxai.com</a></p>
                            <p style={{ marginBottom: '8px' }}>Support: <a href="mailto:support@timeboxai.com" style={{ color: 'var(--primary)', fontWeight: '600' }}>support@timeboxai.com</a></p>
                        </div>
                        <p style={{ marginTop: '24px' }}>
                            We will respond to your inquiry within 30 days.
                        </p>
                    </section>

                </div>
            </div>
        </div>
    );
};

export default Privacy;
