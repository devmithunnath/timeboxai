-- Migration: Add Feedback Table and Notification Permissions
-- Created: 2026-01-28

-- 1. Add notification_permission column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS notification_permission TEXT DEFAULT 'granted';

-- 2. Create the feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  attachment_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT feedback_title_not_empty CHECK (char_length(title) > 0)
);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- 4. Create policies
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'feedback' AND policyname = 'Users can insert their own feedback'
    ) THEN
        CREATE POLICY "Users can insert their own feedback" 
        ON feedback FOR INSERT 
        WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'feedback' AND policyname = 'Users can view their own feedback'
    ) THEN
        CREATE POLICY "Users can view their own feedback" 
        ON feedback FOR SELECT 
        USING (auth.uid() = user_id);
    END IF;
END $$;
