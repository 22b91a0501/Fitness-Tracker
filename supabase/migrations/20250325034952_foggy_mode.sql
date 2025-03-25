/*
  # Initial Schema for MyFitnessPal Clone

  1. New Tables
    - users_metadata
      - id (references auth.users)
      - height_cm (numeric)
      - weight_kg (numeric)
      - target_weight_kg (numeric)
      - daily_calorie_goal (integer)
      - created_at (timestamp)
      - updated_at (timestamp)
    
    - food_items
      - id (uuid)
      - name (text)
      - calories (integer)
      - protein_g (numeric)
      - carbs_g (numeric)
      - fat_g (numeric)
      - user_id (uuid, for custom foods)
      - is_verified (boolean)
      - created_at (timestamp)
    
    - food_logs
      - id (uuid)
      - user_id (uuid)
      - food_item_id (uuid)
      - date (date)
      - meal_type (text)
      - quantity (numeric)
      - created_at (timestamp)
    
    - weight_logs
      - id (uuid)
      - user_id (uuid)
      - weight_kg (numeric)
      - date (date)
      - created_at (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Users metadata table
CREATE TABLE users_metadata (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  height_cm numeric,
  weight_kg numeric,
  target_weight_kg numeric,
  daily_calorie_goal integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE users_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own metadata"
  ON users_metadata
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own metadata"
  ON users_metadata
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own metadata"
  ON users_metadata
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Food items table
CREATE TABLE food_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  calories integer NOT NULL,
  protein_g numeric NOT NULL,
  carbs_g numeric NOT NULL,
  fat_g numeric NOT NULL,
  user_id uuid REFERENCES auth.users(id),
  is_verified boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE food_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read all food items"
  ON food_items
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create custom food items"
  ON food_items
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Food logs table
CREATE TABLE food_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  food_item_id uuid REFERENCES food_items(id) NOT NULL,
  date date DEFAULT CURRENT_DATE,
  meal_type text CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  quantity numeric DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE food_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own food logs"
  ON food_logs
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own food logs"
  ON food_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own food logs"
  ON food_logs
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Weight logs table
CREATE TABLE weight_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  weight_kg numeric NOT NULL,
  date date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE weight_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own weight logs"
  ON weight_logs
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own weight logs"
  ON weight_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Trigger to update users_metadata updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_metadata_updated_at
    BEFORE UPDATE ON users_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
