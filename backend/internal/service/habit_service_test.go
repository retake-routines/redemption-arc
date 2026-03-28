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

func newTestHabitService(habitRepo repository.HabitRepository) *HabitService {
	return NewHabitService(habitRepo)
}

func TestCreateHabit_Success(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	req := models.HabitCreateRequest{
		Title:          "Exercise",
		Description:    "Go to the gym",
		Icon:           "fitness",
		Color:          "#FF0000",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}

	mockRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.Habit")).
		Run(func(args mock.Arguments) {
			habit := args.Get(1).(*models.Habit)
			habit.ID = "habit-123"
			habit.CreatedAt = time.Now()
			habit.UpdatedAt = time.Now()
		}).
		Return(nil)

	habit, err := svc.CreateHabit(context.Background(), "user-1", req)

	assert.NoError(t, err)
	assert.NotNil(t, habit)
	assert.Equal(t, "habit-123", habit.ID)
	assert.Equal(t, "user-1", habit.UserID)
	assert.Equal(t, "Exercise", habit.Title)
	assert.Equal(t, "daily", habit.FrequencyType)
	assert.Equal(t, 1, habit.FrequencyValue)
	assert.False(t, habit.IsArchived)
	mockRepo.AssertExpectations(t)
}

func TestCreateHabit_ValidationError(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	// Missing required fields
	req := models.HabitCreateRequest{
		Title:          "",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}

	habit, err := svc.CreateHabit(context.Background(), "user-1", req)

	assert.Error(t, err)
	assert.Nil(t, habit)
	assert.Contains(t, err.Error(), "validation")
	mockRepo.AssertNotCalled(t, "Create")
}

func TestGetUserHabits_Success(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	expectedHabits := []models.Habit{
		{ID: "h1", UserID: "user-1", Title: "Exercise", FrequencyType: "daily", FrequencyValue: 1},
		{ID: "h2", UserID: "user-1", Title: "Read", FrequencyType: "daily", FrequencyValue: 1},
	}

	mockRepo.On("GetByUserID", mock.Anything, "user-1").Return(expectedHabits, nil)

	habits, err := svc.GetUserHabits(context.Background(), "user-1")

	assert.NoError(t, err)
	assert.Len(t, habits, 2)
	assert.Equal(t, "Exercise", habits[0].Title)
	assert.Equal(t, "Read", habits[1].Title)
	mockRepo.AssertExpectations(t)
}

func TestGetUserHabits_Empty(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	mockRepo.On("GetByUserID", mock.Anything, "user-1").Return([]models.Habit{}, nil)

	habits, err := svc.GetUserHabits(context.Background(), "user-1")

	assert.NoError(t, err)
	assert.NotNil(t, habits)
	assert.Empty(t, habits)
	mockRepo.AssertExpectations(t)
}

func TestGetHabit_Success(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	expectedHabit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
		Title:  "Exercise",
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(expectedHabit, nil)

	habit, err := svc.GetHabit(context.Background(), "habit-1", "user-1")

	assert.NoError(t, err)
	assert.NotNil(t, habit)
	assert.Equal(t, "habit-1", habit.ID)
	assert.Equal(t, "user-1", habit.UserID)
	mockRepo.AssertExpectations(t)
}

func TestGetHabit_NotFound(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	habit, err := svc.GetHabit(context.Background(), "nonexistent", "user-1")

	assert.Error(t, err)
	assert.Nil(t, habit)
	assert.ErrorIs(t, err, ErrHabitNotFound)
	mockRepo.AssertExpectations(t)
}

func TestGetHabit_Forbidden(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	// Habit belongs to a different user
	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "other-user",
		Title:  "Exercise",
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)

	result, err := svc.GetHabit(context.Background(), "habit-1", "user-1")

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.ErrorIs(t, err, ErrHabitNotFound)
	mockRepo.AssertExpectations(t)
}

func TestUpdateHabit_Success(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	existingHabit := &models.Habit{
		ID:             "habit-1",
		UserID:         "user-1",
		Title:          "Exercise",
		Description:    "Old desc",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}

	newTitle := "Updated Exercise"
	req := models.HabitUpdateRequest{
		Title: &newTitle,
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(existingHabit, nil)
	mockRepo.On("Update", mock.Anything, mock.AnythingOfType("*models.Habit")).
		Run(func(args mock.Arguments) {
			h := args.Get(1).(*models.Habit)
			h.UpdatedAt = time.Now()
		}).
		Return(nil)

	habit, err := svc.UpdateHabit(context.Background(), "habit-1", "user-1", req)

	assert.NoError(t, err)
	assert.NotNil(t, habit)
	assert.Equal(t, "Updated Exercise", habit.Title)
	assert.Equal(t, "Old desc", habit.Description) // unchanged field preserved
	mockRepo.AssertExpectations(t)
}

func TestUpdateHabit_NotFound(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	newTitle := "Updated"
	req := models.HabitUpdateRequest{Title: &newTitle}

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	habit, err := svc.UpdateHabit(context.Background(), "nonexistent", "user-1", req)

	assert.Error(t, err)
	assert.Nil(t, habit)
	assert.ErrorIs(t, err, ErrHabitNotFound)
	mockRepo.AssertExpectations(t)
}

func TestDeleteHabit_Success(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	existingHabit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
		Title:  "Exercise",
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(existingHabit, nil)
	mockRepo.On("Delete", mock.Anything, "habit-1").Return(nil)

	err := svc.DeleteHabit(context.Background(), "habit-1", "user-1")

	assert.NoError(t, err)
	mockRepo.AssertExpectations(t)
}

func TestDeleteHabit_NotFound(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	svc := newTestHabitService(mockRepo)

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	err := svc.DeleteHabit(context.Background(), "nonexistent", "user-1")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrHabitNotFound)
	mockRepo.AssertExpectations(t)
}
