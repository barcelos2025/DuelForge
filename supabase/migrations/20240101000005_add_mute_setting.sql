-- Add is_muted column to profiles table for audio settings persistence
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN public.profiles.is_muted IS 'User audio mute preference';
