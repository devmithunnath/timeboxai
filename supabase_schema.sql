-- Enable UUID extension (usually enabled by default, but good to ensure)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create 'users' table with comprehensive tracking fields
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT,
  preferred_language TEXT DEFAULT 'en',
  onboarding_completed_at TIMESTAMP WITH TIME ZONE,
  preset_timers JSONB DEFAULT '[]'::jsonb,
  notification_permission_status TEXT DEFAULT 'not_asked',
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  app_version TEXT,
  platform TEXT,
  timezone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create 'timer_sessions' table with UPDATED SCHEMA
-- Note: If the table already exists, you will need to DROP it first or ALTER it. 
-- Since we are in development, dropping and recreating is easiest.
-- DROP TABLE IF EXISTS timer_sessions; 

CREATE TABLE IF NOT EXISTS timer_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,

  platform TEXT NOT NULL, -- 'macos', 'windows', 'web', etc.
  session_source TEXT NOT NULL, -- 'main_timer', 'menu_quick_start', etc.

  start_time TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  
  planned_duration_seconds INTEGER NOT NULL, -- The target duration (e.g. 25*60)
  duration_seconds INTEGER, -- The actual duration elapsed when stopped/completed

  status TEXT NOT NULL, -- 'active', 'ended'
  completion_reason TEXT, -- 'completed', 'user_stopped', 'app_closed', etc.

  was_paused BOOLEAN DEFAULT FALSE,
  pause_count SMALLINT DEFAULT 0,
  notification_displayed BOOLEAN DEFAULT FALSE,
  
  locale TEXT,
  preset_duration INTEGER,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create 'app_sessions' table to track app usage sessions
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

-- 4. Set up Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE timer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_sessions ENABLE ROW LEVEL SECURITY;

-- Allow anonymous access 
CREATE POLICY "Allow public access to users" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access to timer_sessions" ON timer_sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public access to app_sessions" ON app_sessions FOR ALL USING (true) WITH CHECK (true);
