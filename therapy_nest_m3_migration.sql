-- 💡 Therapy Nest Module 3 Supabase Migration SQL
-- Paste this script into your Supabase Dashboard SQL Editor and click "Run".
-- This fixes the missing table/column errors from the Flutter console logs.

-- 1. Add missing baseline fields to patient_profiles table
ALTER TABLE patient_profiles ADD COLUMN IF NOT EXISTS theta_scores JSONB DEFAULT '{}';
ALTER TABLE patient_profiles ADD COLUMN IF NOT EXISTS baseline_completed_at TIMESTAMPTZ;

-- 2. Create the therapy_sessions table matching the Flutter SessionModel
CREATE TABLE IF NOT EXISTS therapy_sessions (
    id UUID PRIMARY KEY,
    patient_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    target_domains TEXT[] DEFAULT '{}',
    target_item_count INT DEFAULT 10,
    device_info JSONB DEFAULT '{}'
);

-- 3. Create the exercise_attempts table matching the Flutter AttemptModel
CREATE TABLE IF NOT EXISTS exercise_attempts (
    id UUID PRIMARY KEY,
    session_id UUID REFERENCES therapy_sessions(id) ON DELETE CASCADE,
    exercise_item_id UUID REFERENCES exercise_items(id) ON DELETE SET NULL,
    domain VARCHAR(50) NOT NULL,
    response JSONB NOT NULL,
    is_correct BOOLEAN NOT NULL,
    partial_score NUMERIC(4,3) DEFAULT 0.0,
    response_time_ms INT NOT NULL,
    hint_count INT DEFAULT 0,
    theta_before NUMERIC(6,3) NOT NULL,
    theta_after NUMERIC(6,3) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE therapy_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_attempts ENABLE ROW LEVEL SECURITY;

-- 5. Create own-data policies for RLS
DROP POLICY IF EXISTS "own_data_sessions" ON therapy_sessions;
CREATE POLICY "own_data_sessions" ON therapy_sessions FOR ALL 
  USING (auth.uid() = patient_id);

DROP POLICY IF EXISTS "own_data_attempts" ON exercise_attempts;
CREATE POLICY "own_data_attempts" ON exercise_attempts FOR ALL 
  USING (
    session_id IN (
      SELECT id FROM therapy_sessions WHERE patient_id = auth.uid()
    )
  );
