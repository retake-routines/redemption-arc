package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
)

// StreakService handles streak calculation and completion management.
type StreakService struct {
	CompletionRepo repository.CompletionRepository
	HabitRepo      repository.HabitRepository
}

// NewStreakService creates a new StreakService. The habitRepo can be nil if only
// streak calculation (not completion recording) is needed.
func NewStreakService(completionRepo repository.CompletionRepository) *StreakService {
	return &StreakService{
		CompletionRepo: completionRepo,
	}
}

// SetHabitRepo sets the habit repository, enabling ownership verification for completions.
func (s *StreakService) SetHabitRepo(habitRepo repository.HabitRepository) {
	s.HabitRepo = habitRepo
}

// CalculateStreak computes the current and longest streak for a habit.
func (s *StreakService) CalculateStreak(ctx context.Context, habitID string) (*models.Streak, error) {
	streak, err := s.CompletionRepo.GetStreakByHabitID(ctx, habitID)
	if err != nil {
		return nil, fmt.Errorf("calculating streak: %w", err)
	}
	return streak, nil
}

// GetUserStreaks computes streaks for all of a user's habits.
func (s *StreakService) GetUserStreaks(ctx context.Context, userID string) ([]models.Streak, error) {
	if s.HabitRepo == nil {
		return []models.Streak{}, nil
	}

	habits, err := s.HabitRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("getting user habits for streaks: %w", err)
	}

	streaks := make([]models.Streak, 0, len(habits))
	for _, habit := range habits {
		streak, err := s.CompletionRepo.GetStreakByHabitID(ctx, habit.ID)
		if err != nil {
			return nil, fmt.Errorf("calculating streak for habit %s: %w", habit.ID, err)
		}
		streaks = append(streaks, *streak)
	}

	return streaks, nil
}

// RecordCompletion creates a completion record for a habit and verifies ownership.
// Weekly habits: one action fills the current calendar week (Mon–Sun) with one
// completion per day when possible; existing days are skipped (no error).
func (s *StreakService) RecordCompletion(ctx context.Context, userID string, req models.CompletionCreateRequest) (*models.HabitCompletion, error) {
	if s.HabitRepo == nil {
		completion := &models.HabitCompletion{
			HabitID: req.HabitID,
			UserID:  userID,
			Note:    req.Note,
		}
		err := s.CompletionRepo.Create(ctx, completion)
		if err != nil {
			if errors.Is(err, repository.ErrDuplicateCompletion) {
				return nil, repository.ErrDuplicateCompletion
			}
			return nil, fmt.Errorf("creating completion: %w", err)
		}
		return completion, nil
	}

	habit, err := s.HabitRepo.GetByID(ctx, req.HabitID)
	if err != nil {
		if errors.Is(err, repository.ErrHabitNotFound) {
			return nil, ErrHabitNotFound
		}
		return nil, fmt.Errorf("getting habit for completion: %w", err)
	}
	if habit.UserID != userID {
		return nil, ErrHabitNotFound
	}

	if habit.FrequencyType == string(models.FrequencyWeekly) {
		return s.recordWeeklyWeekCompletions(ctx, userID, req)
	}

	completion := &models.HabitCompletion{
		HabitID: req.HabitID,
		UserID:  userID,
		Note:    req.Note,
	}
	err = s.CompletionRepo.Create(ctx, completion)
	if err != nil {
		if errors.Is(err, repository.ErrDuplicateCompletion) {
			return nil, repository.ErrDuplicateCompletion
		}
		return nil, fmt.Errorf("creating completion: %w", err)
	}

	return completion, nil
}

func startOfWeekMonday(t time.Time) time.Time {
	loc := t.Location()
	d := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, loc)
	daysFromMonday := (int(d.Weekday()) + 6) % 7
	return d.AddDate(0, 0, -daysFromMonday)
}

func noonOn(d time.Time) time.Time {
	return time.Date(d.Year(), d.Month(), d.Day(), 12, 0, 0, 0, d.Location())
}

func sameCalendarDay(a, b time.Time) bool {
	loc := b.Location()
	ay, am, ad := a.In(loc).Date()
	by, bm, bd := b.In(loc).Date()
	return ay == by && am == bm && ad == bd
}

func (s *StreakService) recordWeeklyWeekCompletions(ctx context.Context, userID string, req models.CompletionCreateRequest) (*models.HabitCompletion, error) {
	now := time.Now()
	weekStart := startOfWeekMonday(now)
	weekEnd := weekStart.AddDate(0, 0, 7)

	var last *models.HabitCompletion
	for i := 0; i < 7; i++ {
		day := weekStart.AddDate(0, 0, i)
		at := noonOn(day)
		c := &models.HabitCompletion{
			HabitID:     req.HabitID,
			UserID:      userID,
			CompletedAt: at,
			Note:        req.Note,
		}
		err := s.CompletionRepo.Create(ctx, c)
		if err != nil {
			if errors.Is(err, repository.ErrDuplicateCompletion) {
				continue
			}
			return nil, fmt.Errorf("creating weekly completion: %w", err)
		}
		last = c
	}
	if last != nil {
		return last, nil
	}

	comps, err := s.CompletionRepo.GetByHabitID(ctx, req.HabitID)
	if err != nil {
		return nil, fmt.Errorf("listing completions: %w", err)
	}
	for i := range comps {
		t := comps[i].CompletedAt
		if !t.Before(weekStart) && t.Before(weekEnd) && sameCalendarDay(t, now) {
			out := comps[i]
			return &out, nil
		}
	}
	for i := range comps {
		t := comps[i].CompletedAt
		if !t.Before(weekStart) && t.Before(weekEnd) {
			out := comps[i]
			return &out, nil
		}
	}
	return nil, repository.ErrDuplicateCompletion
}

// RemoveCompletion deletes a completion and verifies ownership.
func (s *StreakService) RemoveCompletion(ctx context.Context, userID string, completionID string) error {
	// Get the completion to verify ownership
	completion, err := s.CompletionRepo.GetByID(ctx, completionID)
	if err != nil {
		if errors.Is(err, repository.ErrCompletionNotFound) {
			return repository.ErrCompletionNotFound
		}
		return fmt.Errorf("getting completion for delete: %w", err)
	}

	if completion.UserID != userID {
		return repository.ErrCompletionNotFound
	}

	if err := s.CompletionRepo.Delete(ctx, completionID); err != nil {
		return fmt.Errorf("deleting completion: %w", err)
	}

	return nil
}
