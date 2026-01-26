-- Migration: Add comprehensive tracking fields to existing tables
-- Date: 2026-01-21

-- ============================================
-- 1. UPDATE USERS TABLE
-- ============================================

-- Add onboarding completion timestamp
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMP WITH TIME ZONE;

-- Add preset timers as JSONB array
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS preset_timers JSONB DEFAULT '[]'::jsonb;

-- Add notification permission status
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS notification_permission_status TEXT DEFAULT 'not_asked';
-- Valid values: 'not_asked', 'granted', 'denied'

-- Add last activity tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- Add app version tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS app_version TEXT;

-- Add platform tracking
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS platform TEXT;

-- Add timezone
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS timezone TEXT;

-- Add comments for documentation
COMMENT ON COLUMN users.onboarding_completed_at IS 'Timestamp when user completed onboarding flow';
COMMENT ON COLUMN users.preset_timers IS 'User''s saved timer presets in seconds as JSON array, e.g., [300, 600, 900]';
COMMENT ON COLUMN users.notification_permission_status IS 'Notification permission state: not_asked, granted, or denied';
COMMENT ON COLUMN users.last_active_at IS 'Last time user was active in the app';
COMMENT ON COLUMN users.app_version IS 'App version string, e.g., 1.0.0';
COMMENT ON COLUMN users.platform IS 'Platform: macos, windows, web, ios, android';
COMMENT ON COLUMN users.timezone IS 'User timezone, e.g., America/New_York';

-- ============================================
-- 2. UPDATE TIMER_SESSIONS TABLE
-- ============================================

-- Add locale to track which language was active during session
ALTER TABLE timer_sessions 
ADD COLUMN IF NOT EXISTS locale TEXT;

-- Add preset ID to track which preset was used
ALTER TABLE timer_sessions 
ADD COLUMN IF NOT EXISTS preset_duration INTEGER;
-- Stores the preset duration if a preset was used (null for custom)

COMMENT ON COLUMN timer_sessions.locale IS 'Language code active during this timer session, e.g., en, zh-Hans';
COMMENT ON COLUMN timer_sessions.preset_duration IS 'Preset timer duration in seconds if preset was used, null for custom timers';

-- ============================================
-- 3. CREATE APP_SESSIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS app_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  
  session_start TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  session_end TIMESTAMP WITH TIME ZONE,
  
  platform TEXT NOT NULL,
  app_version TEXT,
  locale TEXT,
  
  timers_run INTEGER DEFAULT 0,
  total_focus_time_seconds INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add RLS policy
ALTER TABLE app_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public access to app_sessions" ON app_sessions FOR ALL USING (true) WITH CHECK (true);

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_app_sessions_user_id ON app_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_app_sessions_start ON app_sessions(session_start DESC);

COMMENT ON TABLE app_sessions IS 'Tracks individual app usage sessions from open to close';
COMMENT ON COLUMN app_sessions.timers_run IS 'Number of timer sessions started during this app session';
COMMENT ON COLUMN app_sessions.total_focus_time_seconds IS 'Total focused time (completed timers) during this session';
