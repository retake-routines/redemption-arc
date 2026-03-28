package models

import "time"

// HabitCompletion represents a habit completion record.
type HabitCompletion struct {
	ID          string    `json:"id" db:"id"`
	HabitID     string    `json:"habit_id" db:"habit_id"`
	UserID      string    `json:"user_id" db:"user_id"`
	CompletedAt time.Time `json:"completed_at" db:"completed_at"`
	Note        string    `json:"note" db:"note"`
}

// CompletionCreateRequest is the request body for recording a completion.
type CompletionCreateRequest struct {
	HabitID string `json:"habit_id" binding:"required"`
	Note    string `json:"note"`
}

// CompletionResponse is a single completion in the API response.
type CompletionResponse struct {
	ID          string    `json:"id"`
	HabitID     string    `json:"habit_id"`
	UserID      string    `json:"user_id"`
	CompletedAt time.Time `json:"completed_at"`
	Note        string    `json:"note"`
}

// CompletionListResponse is the paginated response for listing completions.
type CompletionListResponse struct {
	Completions []HabitCompletion `json:"completions"`
	Total       int               `json:"total"`
	Page        int               `json:"page"`
	Limit       int               `json:"limit"`
}

// Streak holds current and longest streak info for a habit.
type Streak struct {
	HabitID         string     `json:"habit_id"`
	CurrentStreak   int        `json:"current_streak"`
	LongestStreak   int        `json:"longest_streak"`
	LastCompletedAt *time.Time `json:"last_completed_at"`
}

// HabitStats holds aggregate statistics for a habit.
type HabitStats struct {
	TotalCompletions int     `json:"total_completions"`
	CurrentStreak    int     `json:"current_streak"`
	LongestStreak    int     `json:"longest_streak"`
	CompletionRate   float64 `json:"completion_rate"`
}
