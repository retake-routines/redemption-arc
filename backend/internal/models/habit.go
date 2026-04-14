package models

import (
	"errors"
	"time"
)

// FrequencyType represents the frequency of a habit.
type FrequencyType string

const (
	FrequencyDaily  FrequencyType = "daily"
	FrequencyWeekly FrequencyType = "weekly"
)

// IsValid checks if the frequency type is valid.
func (f FrequencyType) IsValid() bool {
	return f == FrequencyDaily || f == FrequencyWeekly
}

// Habit represents a habit in the database.
type Habit struct {
	ID             string    `json:"id" db:"id"`
	UserID         string    `json:"user_id" db:"user_id"`
	Title          string    `json:"title" db:"title"`
	Description    string    `json:"description" db:"description"`
	Icon           string    `json:"icon" db:"icon"`
	Color          string    `json:"color" db:"color"`
	FrequencyType  string    `json:"frequency_type" db:"frequency_type"`
	FrequencyValue int       `json:"frequency_value" db:"frequency_value"`
	TemplateKey    string    `json:"template_key,omitempty" db:"template_key"`
	IsArchived     bool      `json:"is_archived" db:"is_archived"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
}

// HabitCreateRequest is the request body for creating a habit.
type HabitCreateRequest struct {
	Title          string `json:"title" binding:"required"`
	Description    string `json:"description"`
	Icon           string `json:"icon"`
	Color          string `json:"color"`
	FrequencyType  string `json:"frequency_type" binding:"required"`
	FrequencyValue int    `json:"frequency_value" binding:"required"`
	TemplateKey    string `json:"template_key"`
}

// Validate checks that the create request fields are valid.
func (r *HabitCreateRequest) Validate() error {
	if r.Title == "" {
		return errors.New("title is required")
	}
	if len(r.Title) > 255 {
		return errors.New("title must be at most 255 characters")
	}
	if !FrequencyType(r.FrequencyType).IsValid() {
		return errors.New("frequency_type must be 'daily' or 'weekly'")
	}
	if r.FrequencyValue < 1 {
		return errors.New("frequency_value must be at least 1")
	}
	if len(r.TemplateKey) > 64 {
		return errors.New("template_key must be at most 64 characters")
	}
	return nil
}

// HabitUpdateRequest is the request body for updating a habit (partial update).
type HabitUpdateRequest struct {
	Title          *string `json:"title"`
	Description    *string `json:"description"`
	Icon           *string `json:"icon"`
	Color          *string `json:"color"`
	FrequencyType  *string `json:"frequency_type"`
	FrequencyValue *int    `json:"frequency_value"`
	TemplateKey    *string `json:"template_key"`
	IsArchived     *bool   `json:"is_archived"`
}

// Validate checks that the update request fields are valid.
func (r *HabitUpdateRequest) Validate() error {
	if r.Title != nil && len(*r.Title) > 255 {
		return errors.New("title must be at most 255 characters")
	}
	if r.Title != nil && *r.Title == "" {
		return errors.New("title cannot be empty")
	}
	if r.FrequencyType != nil && !FrequencyType(*r.FrequencyType).IsValid() {
		return errors.New("frequency_type must be 'daily' or 'weekly'")
	}
	if r.FrequencyValue != nil && *r.FrequencyValue < 1 {
		return errors.New("frequency_value must be at least 1")
	}
	if r.TemplateKey != nil && len(*r.TemplateKey) > 64 {
		return errors.New("template_key must be at most 64 characters")
	}
	return nil
}

// HabitResponse includes the habit with optional streak info.
type HabitResponse struct {
	Habit
	CurrentStreak int `json:"current_streak,omitempty"`
	LongestStreak int `json:"longest_streak,omitempty"`
}

// HabitListResponse is the paginated response for listing habits.
type HabitListResponse struct {
	Habits []Habit `json:"habits"`
	Total  int     `json:"total"`
	Page   int     `json:"page"`
	Limit  int     `json:"limit"`
}
