package service

import (
	"context"
	"errors"
	"fmt"

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
)

// ErrHabitNotFound is returned when a habit is not found.
var ErrHabitNotFound = errors.New("habit not found")

// ErrForbidden is returned when a user tries to access a habit they don't own.
var ErrForbidden = errors.New("you do not have access to this habit")

// HabitService handles habit business logic.
type HabitService struct {
	HabitRepo repository.HabitRepository
}

// NewHabitService creates a new HabitService.
func NewHabitService(habitRepo repository.HabitRepository) *HabitService {
	return &HabitService{HabitRepo: habitRepo}
}

// CreateHabit validates input, sets defaults, and creates a new habit.
func (s *HabitService) CreateHabit(ctx context.Context, userID string, req models.HabitCreateRequest) (*models.Habit, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation: %w", err)
	}

	habit := &models.Habit{
		UserID:         userID,
		Title:          req.Title,
		Description:    req.Description,
		Icon:           req.Icon,
		Color:          req.Color,
		FrequencyType:  req.FrequencyType,
		FrequencyValue: req.FrequencyValue,
		IsArchived:     false,
	}

	if err := s.HabitRepo.Create(ctx, habit); err != nil {
		return nil, fmt.Errorf("creating habit: %w", err)
	}

	return habit, nil
}

// GetUserHabits retrieves all habits for a user.
func (s *HabitService) GetUserHabits(ctx context.Context, userID string) ([]models.Habit, error) {
	habits, err := s.HabitRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("getting user habits: %w", err)
	}
	return habits, nil
}

// GetHabit retrieves a single habit by ID and verifies ownership.
func (s *HabitService) GetHabit(ctx context.Context, id string, userID string) (*models.Habit, error) {
	habit, err := s.HabitRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrHabitNotFound) {
			return nil, ErrHabitNotFound
		}
		return nil, fmt.Errorf("getting habit: %w", err)
	}

	if habit.UserID != userID {
		return nil, ErrHabitNotFound
	}

	return habit, nil
}

// UpdateHabit validates input, verifies ownership, and applies partial updates.
func (s *HabitService) UpdateHabit(ctx context.Context, id string, userID string, req models.HabitUpdateRequest) (*models.Habit, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation: %w", err)
	}

	// Fetch the existing habit and verify ownership
	habit, err := s.HabitRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrHabitNotFound) {
			return nil, ErrHabitNotFound
		}
		return nil, fmt.Errorf("getting habit for update: %w", err)
	}

	if habit.UserID != userID {
		return nil, ErrHabitNotFound
	}

	// Apply partial updates (only non-nil fields)
	if req.Title != nil {
		habit.Title = *req.Title
	}
	if req.Description != nil {
		habit.Description = *req.Description
	}
	if req.Icon != nil {
		habit.Icon = *req.Icon
	}
	if req.Color != nil {
		habit.Color = *req.Color
	}
	if req.FrequencyType != nil {
		habit.FrequencyType = *req.FrequencyType
	}
	if req.FrequencyValue != nil {
		habit.FrequencyValue = *req.FrequencyValue
	}
	if req.IsArchived != nil {
		habit.IsArchived = *req.IsArchived
	}

	if err := s.HabitRepo.Update(ctx, habit); err != nil {
		return nil, fmt.Errorf("updating habit: %w", err)
	}

	return habit, nil
}

// DeleteHabit verifies ownership and deletes a habit.
func (s *HabitService) DeleteHabit(ctx context.Context, id string, userID string) error {
	// Verify ownership first
	habit, err := s.HabitRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrHabitNotFound) {
			return ErrHabitNotFound
		}
		return fmt.Errorf("getting habit for delete: %w", err)
	}

	if habit.UserID != userID {
		return ErrHabitNotFound
	}

	if err := s.HabitRepo.Delete(ctx, id); err != nil {
		return fmt.Errorf("deleting habit: %w", err)
	}

	return nil
}
