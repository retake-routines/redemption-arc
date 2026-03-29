package service

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/repository/mocks"
)

func newTestStreakService(completionRepo repository.CompletionRepository) *StreakService {
	return NewStreakService(completionRepo)
}

func TestCalculateStreak_NoCompletions(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	svc := newTestStreakService(mockCompRepo)

	streak := &models.Streak{
		HabitID:       "habit-1",
		CurrentStreak: 0,
		LongestStreak: 0,
	}

	mockCompRepo.On("GetStreakByHabitID", mock.Anything, "habit-1").Return(streak, nil)

	result, err := svc.CalculateStreak(context.Background(), "habit-1")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 0, result.CurrentStreak)
	assert.Equal(t, 0, result.LongestStreak)
	mockCompRepo.AssertExpectations(t)
}

func TestCalculateStreak_ConsecutiveDays(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	svc := newTestStreakService(mockCompRepo)

	lastCompleted := time.Now()
	streak := &models.Streak{
		HabitID:         "habit-1",
		CurrentStreak:   5,
		LongestStreak:   5,
		LastCompletedAt: &lastCompleted,
	}

	mockCompRepo.On("GetStreakByHabitID", mock.Anything, "habit-1").Return(streak, nil)

	result, err := svc.CalculateStreak(context.Background(), "habit-1")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 5, result.CurrentStreak)
	assert.Equal(t, 5, result.LongestStreak)
	mockCompRepo.AssertExpectations(t)
}

func TestCalculateStreak_BrokenStreak(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	svc := newTestStreakService(mockCompRepo)

	lastCompleted := time.Now().AddDate(0, 0, -3)
	streak := &models.Streak{
		HabitID:         "habit-1",
		CurrentStreak:   0,
		LongestStreak:   10,
		LastCompletedAt: &lastCompleted,
	}

	mockCompRepo.On("GetStreakByHabitID", mock.Anything, "habit-1").Return(streak, nil)

	result, err := svc.CalculateStreak(context.Background(), "habit-1")

	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, 0, result.CurrentStreak)
	assert.Equal(t, 10, result.LongestStreak)
	mockCompRepo.AssertExpectations(t)
}

func TestRecordCompletion_Success(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	mockHabitRepo := new(mocks.MockHabitRepository)
	svc := newTestStreakService(mockCompRepo)
	svc.SetHabitRepo(mockHabitRepo)

	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
		Title:  "Exercise",
	}

	mockHabitRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)
	mockCompRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.HabitCompletion")).
		Run(func(args mock.Arguments) {
			comp := args.Get(1).(*models.HabitCompletion)
			comp.ID = "comp-123"
			comp.CompletedAt = time.Now()
		}).
		Return(nil)

	req := models.CompletionCreateRequest{
		HabitID: "habit-1",
		Note:    "Great workout!",
	}

	completion, err := svc.RecordCompletion(context.Background(), "user-1", req)

	assert.NoError(t, err)
	assert.NotNil(t, completion)
	assert.Equal(t, "comp-123", completion.ID)
	assert.Equal(t, "habit-1", completion.HabitID)
	assert.Equal(t, "user-1", completion.UserID)
	assert.Equal(t, "Great workout!", completion.Note)
	mockCompRepo.AssertExpectations(t)
	mockHabitRepo.AssertExpectations(t)
}

func TestRecordCompletion_DuplicateCompletion(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	mockHabitRepo := new(mocks.MockHabitRepository)
	svc := newTestStreakService(mockCompRepo)
	svc.SetHabitRepo(mockHabitRepo)

	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
	}

	mockHabitRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)
	mockCompRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.HabitCompletion")).
		Return(repository.ErrDuplicateCompletion)

	req := models.CompletionCreateRequest{
		HabitID: "habit-1",
	}

	completion, err := svc.RecordCompletion(context.Background(), "user-1", req)

	assert.Error(t, err)
	assert.Nil(t, completion)
	assert.ErrorIs(t, err, repository.ErrDuplicateCompletion)
	mockCompRepo.AssertExpectations(t)
	mockHabitRepo.AssertExpectations(t)
}

func TestRemoveCompletion_Success(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	svc := newTestStreakService(mockCompRepo)

	completion := &models.HabitCompletion{
		ID:      "comp-1",
		HabitID: "habit-1",
		UserID:  "user-1",
	}

	mockCompRepo.On("GetByID", mock.Anything, "comp-1").Return(completion, nil)
	mockCompRepo.On("Delete", mock.Anything, "comp-1").Return(nil)

	err := svc.RemoveCompletion(context.Background(), "user-1", "comp-1")

	assert.NoError(t, err)
	mockCompRepo.AssertExpectations(t)
}

func TestRemoveCompletion_NotFound(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	svc := newTestStreakService(mockCompRepo)

	mockCompRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrCompletionNotFound)

	err := svc.RemoveCompletion(context.Background(), "user-1", "nonexistent")

	assert.Error(t, err)
	assert.ErrorIs(t, err, repository.ErrCompletionNotFound)
	mockCompRepo.AssertExpectations(t)
}
