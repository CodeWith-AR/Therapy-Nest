-- 💡 Therapy Nest: Profile & Avatar Storage Migration SQL
-- Run this script in your Supabase Dashboard -> SQL Editor -> New query -> Click "Run".

-- 1. Add avatar_url column to user_profiles table if not present
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Create the 'avatars' storage bucket in Supabase Storage (publicly accessible)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Row Level Security (RLS) policies for the 'avatars' storage bucket
DROP POLICY IF EXISTS "Public Avatar Access" ON storage.objects;
CREATE POLICY "Public Avatar Access" ON storage.objects 
FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated Users Upload Avatar" ON storage.objects;
CREATE POLICY "Authenticated Users Upload Avatar" ON storage.objects 
FOR INSERT TO authenticated 
WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated Users Update Avatar" ON storage.objects;
CREATE POLICY "Authenticated Users Update Avatar" ON storage.objects 
FOR UPDATE TO authenticated 
USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated Users Delete Avatar" ON storage.objects;
CREATE POLICY "Authenticated Users Delete Avatar" ON storage.objects 
FOR DELETE TO authenticated 
USING (bucket_id = 'avatars');
