-- Add missing columns for Banners schedule if they do not exist
ALTER TABLE banners
  ADD COLUMN IF NOT EXISTS starts_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS ends_at TIMESTAMPTZ;

-- Drop and recreate the policy to ensure it uses the new columns
DROP POLICY IF EXISTS "Active banners are public" ON banners;
CREATE POLICY "Active banners are public" ON banners
  FOR SELECT USING (
    is_active = TRUE
    AND (starts_at IS NULL OR starts_at <= NOW())
    AND (ends_at IS NULL OR ends_at >= NOW())
  );
