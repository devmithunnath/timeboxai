import React, { useState, useEffect, useRef } from 'react';
import { Play, Pause, Square, Settings } from 'lucide-react';

const TimerDemo: React.FC = () => {
  const [seconds, setSeconds] = useState(1500); // 25:00
  const [isActive, setIsActive] = useState(false);
  const [totalTime, setTotalTime] = useState(1500);
  const audioContext = useRef<AudioContext | null>(null);

  useEffect(() => {
    let interval: number | undefined;

    if (isActive && seconds > 0) {
      interval = setInterval(() => {
        setSeconds((s) => s - 1);
      }, 1000);
    } else if (seconds === 0) {
      setIsActive(false);
      playFinishSound();
    }

    return () => clearInterval(interval);
  }, [isActive, seconds]);

  const toggleTimer = () => {
    if (!audioContext.current) {
      audioContext.current = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    setIsActive(!isActive);
  };

  const stopTimer = () => {
    setIsActive(false);
    setSeconds(totalTime);
  };

  const playFinishSound = () => {
    if (!audioContext.current) return;
    const osc = audioContext.current.createOscillator();
    const gain = audioContext.current.createGain();
    osc.connect(gain);
    gain.connect(audioContext.current.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, audioContext.current.currentTime);
    gain.gain.setValueAtTime(0, audioContext.current.currentTime);
    gain.gain.linearRampToValueAtTime(0.1, audioContext.current.currentTime + 0.1);
    gain.gain.exponentialRampToValueAtTime(0.01, audioContext.current.currentTime + 1);
    osc.start();
    osc.stop(audioContext.current.currentTime + 1);
  };

  const formatTime = (s: number) => {
    const m = Math.floor(s / 60);
    const rs = s % 60;
    return `${m.toString().padStart(2, '0')}:${rs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="timer-window" style={{
      background: '#fff',
      borderRadius: '24px',
      boxShadow: '0 30px 60px rgba(0,0,0,0.12)',
      width: '100%',
      maxWidth: '500px',
      aspectRatio: '1/1',
      padding: '24px',
      display: 'flex',
      flexDirection: 'column',
      position: 'relative',
      overflow: 'hidden',
      border: '1px solid rgba(0,0,0,0.05)'
    }}>
      {/* Window Controls */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
        <div style={{ display: 'flex', gap: '8px' }}>
          <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#FF5F57' }} />
          <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#FFBD2E' }} />
          <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#27C93F' }} />
        </div>
        <Settings size={18} color="#D1D1D1" />
      </div>

      {/* Main Content */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '40px' }}>
        <h1 style={{
          fontSize: '110px',
          fontWeight: '700',
          color: 'var(--primary)',
          fontFamily: 'var(--font-rounded)',
          margin: 0,
          lineHeight: 1
        }}>
          {formatTime(seconds)}
        </h1>

        <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
          {isActive && (
            <button
              onClick={stopTimer}
              style={{
                background: '#F2F2F7',
                border: 'none',
                width: '44px',
                height: '44px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer'
              }}
            >
              <Square size={16} fill="#A2845E" color="#A2845E" />
            </button>
          )}
          <button
            onClick={toggleTimer}
            style={{
              background: 'var(--primary)',
              border: 'none',
              width: '56px',
              height: '56px',
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: '#fff',
              boxShadow: '0 8px 20px rgba(255, 93, 57, 0.3)'
            }}
          >
            {isActive ? <Pause size={24} fill="#fff" /> : <Play size={24} fill="#fff" />}
          </button>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          {[5, 10, 15, 20].map((m) => {
            const displayTime = m === 20 ? "20:05" : `${m.toString().padStart(2, '0')}:00`;
            const isSelected = totalTime === (m === 20 ? 1205 : m * 60);
            return (
              <button
                key={m}
                onClick={() => {
                  const s = m === 20 ? 1205 : m * 60;
                  setTotalTime(s);
                  setSeconds(s);
                  setIsActive(false);
                }}
                style={{
                  padding: '8px 16px',
                  borderRadius: '12px',
                  border: '1px solid #E5E5EA',
                  background: isSelected ? 'var(--primary)' : '#fff',
                  color: isSelected ? '#fff' : '#8E8E93',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  transition: 'all 0.2s'
                }}
              >
                {displayTime}
              </button>
            )
          })}
        </div>
      </div>

      {/* Footer Area */}
      <div style={{ marginTop: 'auto', position: 'relative', height: '100px' }}>
        <div style={{
          position: 'absolute',
          bottom: '20px',
          right: '40px',
          width: '80px',
          zIndex: 1
        }}>
          <img src="/assets/ant.svg" alt="Mascot" style={{ width: '100%', transform: 'scaleX(-1)' }} />
        </div>
        <div style={{
          position: 'absolute',
          bottom: '0',
          left: '0',
          right: '0',
          textAlign: 'center',
          padding: '12px',
          fontSize: '13px',
          fontWeight: '600',
          color: '#1D1D1F',
          borderTop: '1px solid rgba(0,0,0,0.03)'
        }}>
          Small steps matter.
        </div>
      </div>
    </div>
  );
};

export default TimerDemo;
