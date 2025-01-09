/*
  # Create analyses table for video analysis tracking

  1. New Tables
    - `analyses`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `video_id` (text)
      - `model` (text)
      - `custom_instructions` (text)
      - `summary` (text)
      - `status` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `analyses` table
    - Add policies for users to manage their own analyses
*/

CREATE TABLE public.analyses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  video_id text NOT NULL,
  model text NOT NULL,
  custom_instructions text,
  summary text,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX analyses_user_id_idx ON public.analyses(user_id);
CREATE INDEX analyses_status_idx ON public.analyses(status);

ALTER TABLE public.analyses ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own analyses
CREATE POLICY "Users can read own analyses" ON public.analyses
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Allow users to insert their own analyses
CREATE POLICY "Users can insert own analyses" ON public.analyses
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own analyses
CREATE POLICY "Users can update own analyses" ON public.analyses
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_analyses_updated_at
  BEFORE UPDATE ON public.analyses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();