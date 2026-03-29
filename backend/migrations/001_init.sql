CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Habits table
CREATE TABLE IF NOT EXISTS habits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    icon VARCHAR(50) NOT NULL DEFAULT '',
    color VARCHAR(20) NOT NULL DEFAULT '',
    frequency_type VARCHAR(20) NOT NULL DEFAULT 'daily' CHECK (frequency_type IN ('daily', 'weekly')),
    frequency_value INTEGER NOT NULL DEFAULT 1,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_user_id_archived ON habits(user_id, is_archived);

-- Habit completions table
CREATE TABLE IF NOT EXISTS habit_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    note TEXT NOT NULL DEFAULT ''
);

-- Helper function for immutable date extraction (required for index expressions)
CREATE OR REPLACE FUNCTION completion_date(ts TIMESTAMPTZ) RETURNS DATE AS $$
  SELECT ts::date;
$$ LANGUAGE SQL IMMUTABLE;

-- Prevent duplicate completions for the same habit on the same date
CREATE UNIQUE INDEX IF NOT EXISTS idx_completions_habit_date
    ON habit_completions (habit_id, completion_date(completed_at));

CREATE INDEX IF NOT EXISTS idx_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_completions_user_id ON habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_completions_completed_at ON habit_completions(completed_at);
CREATE INDEX IF NOT EXISTS idx_completions_user_date ON habit_completions(user_id, completed_at);
