export interface UserMetadata {
  id: string;
  height_cm: number | null;
  weight_kg: number | null;
  target_weight_kg: number | null;
  daily_calorie_goal: number | null;
  created_at: string;
  updated_at: string;
}

export interface FoodItem {
  id: string;
  name: string;
  calories: number;
  protein_g: number;
  carbs_g: number;
  fat_g: number;
  user_id: string | null;
  is_verified: boolean;
  created_at: string;
}

export interface FoodLog {
  id: string;
  user_id: string;
  food_item_id: string;
  date: string;
  meal_type: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  quantity: number;
  created_at: string;
  food_item?: FoodItem;
}

export interface WeightLog {
  id: string;
  user_id: string;
  weight_kg: number;
  date: string;
  created_at: string;
}
