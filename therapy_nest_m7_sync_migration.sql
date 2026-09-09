-- 💡 Therapy Nest Module 7 Supabase Migration SQL
-- Paste this script into your Supabase Dashboard SQL Editor and click "Run".
-- This adds the missing 'is_synced' column to the 'exercise_attempts' table.

ALTER TABLE exercise_attempts ADD COLUMN IF NOT EXISTS is_synced BOOLEAN DEFAULT TRUE;
