package mocks

import (
	"context"
	"time"

	"github.com/stretchr/testify/mock"

	"habitpal-backend/internal/models"
)

// MockUserRepository is a mock implementation of repository.UserRepository.
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(ctx context.Context, user *models.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepository) GetByID(ctx context.Context, id string) (*models.User, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	args := m.Called(ctx, email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.User), args.Error(1)
}

func (m *MockUserRepository) Update(ctx context.Context, user *models.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

// MockHabitRepository is a mock implementation of repository.HabitRepository.
type MockHabitRepository struct {
	mock.Mock
}

func (m *MockHabitRepository) Create(ctx context.Context, habit *models.Habit) error {
	args := m.Called(ctx, habit)
	return args.Error(0)
}

func (m *MockHabitRepository) GetByID(ctx context.Context, id string) (*models.Habit, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.Habit), args.Error(1)
}

func (m *MockHabitRepository) GetByUserID(ctx context.Context, userID string) ([]models.Habit, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.Habit), args.Error(1)
}

func (m *MockHabitRepository) Update(ctx context.Context, habit *models.Habit) error {
	args := m.Called(ctx, habit)
	return args.Error(0)
}

func (m *MockHabitRepository) Delete(ctx context.Context, id string) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockHabitRepository) CountByUserID(ctx context.Context, userID string) (int, error) {
	args := m.Called(ctx, userID)
	return args.Int(0), args.Error(1)
}

func (m *MockHabitRepository) ExistsActiveByTemplateKey(ctx context.Context, userID, templateKey string) (bool, error) {
	args := m.Called(ctx, userID, templateKey)
	return args.Bool(0), args.Error(1)
}

// MockCompletionRepository is a mock implementation of repository.CompletionRepository.
type MockCompletionRepository struct {
	mock.Mock
}

func (m *MockCompletionRepository) Create(ctx context.Context, completion *models.HabitCompletion) error {
	args := m.Called(ctx, completion)
	return args.Error(0)
}

func (m *MockCompletionRepository) GetByID(ctx context.Context, id string) (*models.HabitCompletion, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.HabitCompletion), args.Error(1)
}

func (m *MockCompletionRepository) GetByHabitID(ctx context.Context, habitID string) ([]models.HabitCompletion, error) {
	args := m.Called(ctx, habitID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.HabitCompletion), args.Error(1)
}

func (m *MockCompletionRepository) GetByUserIDAndDateRange(ctx context.Context, userID string, from, to time.Time) ([]models.HabitCompletion, error) {
	args := m.Called(ctx, userID, from, to)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.HabitCompletion), args.Error(1)
}

func (m *MockCompletionRepository) GetByUserID(ctx context.Context, userID string) ([]models.HabitCompletion, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.HabitCompletion), args.Error(1)
}

func (m *MockCompletionRepository) GetByHabitIDAndDateRange(ctx context.Context, habitID string, from, to time.Time) ([]models.HabitCompletion, error) {
	args := m.Called(ctx, habitID, from, to)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]models.HabitCompletion), args.Error(1)
}

func (m *MockCompletionRepository) Delete(ctx context.Context, id string) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockCompletionRepository) GetStreakByHabitID(ctx context.Context, habitID string) (*models.Streak, error) {
	args := m.Called(ctx, habitID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.Streak), args.Error(1)
}

func (m *MockCompletionRepository) CountByUserID(ctx context.Context, userID string) (int, error) {
	args := m.Called(ctx, userID)
	return args.Int(0), args.Error(1)
}

func (m *MockCompletionRepository) CountByHabitID(ctx context.Context, habitID string) (int, error) {
	args := m.Called(ctx, habitID)
	return args.Int(0), args.Error(1)
}

func (m *MockCompletionRepository) CountByUserIDAndHabitID(ctx context.Context, userID string, habitID string) (int, error) {
	args := m.Called(ctx, userID, habitID)
	return args.Int(0), args.Error(1)
}
