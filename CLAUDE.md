## Database Structure (Level Up Fitness)

**Project**: https://uprgcseatwhpptlmmdjr.supabase.co
**Current State**: 79 users, 561 workouts, 12 tables

### Core Tables

**profiles** (79 rows, RLS enabled)
- `id` (uuid, PK) - links to auth.users.id
- `avatar_name` (text, unique)
- `credits` (integer, default: 0)
- `first_name`, `last_name` (text)
- `avatar_image_url`, `profile_picture_url` (text)
- `faction` (enum: echoreach, pulseforge, voidkind, neurospire)
- `hero_path` (enum: brute, ranger, sentinel, hunter, juggernaut, strider, champion)
- timestamps: created_at, updated_at

**xp_levels** (79 rows, RLS enabled)
- `user_id` (uuid, PK, FK to profiles.id)
- `xp` (integer, default: 0)
- `current_level` (integer, default: 1)
- `last_updated` (timestamptz)

**level_info** (19 rows, RLS enabled)
- `level` (smallint, PK, identity)
- `xp_to_reach` (integer)
- `cumulative_xp` (integer)

**workouts** (561 rows, RLS enabled)
- `id` (uuid, PK)
- `user_id` (uuid, FK to profiles.id)
- `duration` (integer)
- `xp_earned` (integer)
- `notes` (text)
- `date` (timestamptz)
- `type` (array of workout_type enum: cardio, strength, functional, other)

**streaks** (79 rows, RLS enabled)
- `user_id` (uuid, PK, FK to profiles.id)
- `current_streak`, `longest_streak` (integer)
- `last_workout_date` (date)
- timestamps: created_at, updated_at

### Game System Tables

**missions** (38 rows, RLS enabled)
- `id` (uuid, PK)
- `title`, `description` (text)
- `level_requirement` (integer)
- `success_chances` (jsonb)
- `duration` (smallint)
- `success_message`, `fail_message` (text)
- `reward` (smallint)

**user_missions** (465 rows, RLS enabled)
- `user_id`, `mission_id` (uuid, composite PK)
- `completed` (boolean, default: false)
- `started_at`, `finish_at` (timestamptz)

**items** (26 rows, RLS enabled)
- `id` (uuid, PK)
- `name`, `description` (text)
- `xp_bonus` (numeric)
- `price` (integer)
- `item_slot` (enum: armor, helmet, gloves, pants, boots, weapon)
- `required_paths` (array of hero_path)
- `required_level` (integer, default: 1)

**user_items** (87 rows, RLS enabled)
- `id` (uuid, PK)
- `user_id`, `item_id` (uuid, FK)
- `purchased_at` (timestamptz)
- `quantity` (integer, default: 1)

**user_equipped_items** (36 rows, RLS enabled)
- `id` (uuid, PK)
- `user_id`, `item_id` (uuid, FK)
- `item_slot` (item_slot enum)
- `equipped_at` (timestamptz)

### Social Features

**friendships** (1 row, RLS enabled)
- `id` (bigint, PK, identity)
- `user_1`, `user_2` (uuid)
- `created_at` (timestamptz)
- `status` (enum: pending, accepted, blocked, default: pending)

**avatar_assets** (16 rows, **RLS disabled**)
- `id` (uuid, PK)
- `style_number` (integer, unique)
- type_a/type_b profile/full_body image URLs
- `created_at` (timestamp)

### Migrations Applied (12 total)
- enum types, profiles, xp_levels, shop_items
- user_equipped_items, workouts, streaks
- missions, user_missions
- leaderboard views/functions
- profile trigger fixes
- xp_leaderboard view

### Known Issues
- **Security**: 24 warnings (function search_path, RLS on avatar_assets, auth config)
- **Performance**: 25 recommendations (unindexed FKs, RLS policy optimization)
- Missing indexes on foreign keys in user_equipped_items, user_items, user_missions