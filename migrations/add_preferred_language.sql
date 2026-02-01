-- Migration: Add preferred_language column to users table
-- This stores the user's selected language preference (e.g., 'en', 'zh-Hans', 'ja', etc.)

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'en';

-- Add comment to document the column
COMMENT ON COLUMN users.preferred_language IS 'User''s preferred language code (e.g., en, zh-Hans, ja, de, fr)';
