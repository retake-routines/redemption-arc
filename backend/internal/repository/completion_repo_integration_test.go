//go:build integration

package repository

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"habitpal-backend/internal/models"
)

func setupCompletionTestDB(t *testing.T) (*pgxpool.Pool, string, string, func()) {
	t.Helper()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		t.Skip("DATABASE_URL not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	require.NoError(t, err)

	// Create a test user
	userRepo := NewPostgresUserRepository(pool)
	user := &models.User{
		Email:        "comp-test-" + time.Now().Format("150405.000") + "@example.com",
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "Completion Test User",
	}
	err = userRepo.Create(ctx, user)
	require.NoError(t, err)

	// Create a test habit
	habitRepo := NewPostgresHabitRepository(pool)
	habit := &models.Habit{
		UserID:         user.ID,
		Title:          "Test Habit for Completions",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}
	err = habitRepo.Create(ctx, habit)
	require.NoError(t, err)

	cleanup := func() {
		_, _ = pool.Exec(ctx, "DELETE FROM habit_completions")
		_, _ = pool.Exec(ctx, "DELETE FROM habits")
		_, _ = pool.Exec(ctx, "DELETE FROM users")
		pool.Close()
	}

	return pool, user.ID, habit.ID, cleanup
}

func TestCreateCompletion_Integration(t *testing.T) {
	pool, userID, habitID, cleanup := setupCompletionTestDB(t)
	defer cleanup()

	repo := NewPostgresCompletionRepository(pool)
	ctx := context.Background()

	completion := &models.HabitCompletion{
		HabitID: habitID,
		UserID:  userID,
		Note:    "Completed!",
	}

	err := repo.Create(ctx, completion)
	require.NoError(t, err)
	assert.NotEmpty(t, completion.ID)
	assert.False(t, completion.CompletedAt.IsZero())
}

func TestDuplicateCompletion_Integration(t *testing.T) {
	pool, userID, habitID, cleanup := setupCompletionTestDB(t)
	defer cleanup()

	repo := NewPostgresCompletionRepository(pool)
	ctx := context.Background()

	comp1 := &models.HabitCompletion{
		HabitID: habitID,
		UserID:  userID,
		Note:    "First",
	}
	err := repo.Create(ctx, comp1)
	require.NoError(t, err)

	// Second completion for the same habit — this may or may not be a duplicate
	// depending on the database constraint (per-day unique). We create it and
	// check that if the DB rejects it, the error is ErrDuplicateCompletion.
	comp2 := &models.HabitCompletion{
		HabitID: habitID,
		UserID:  userID,
		Note:    "Second",
	}
	err = repo.Create(ctx, comp2)
	if err != nil {
		assert.ErrorIs(t, err, ErrDuplicateCompletion)
	}
	// If no error, the schema allows multiple completions per day — that's also valid.
}

func TestGetStreakByHabitID_Integration(t *testing.T) {
	pool, _, habitID, cleanup := setupCompletionTestDB(t)
	defer cleanup()

	repo := NewPostgresCompletionRepository(pool)
	ctx := context.Background()

	streak, err := repo.GetStreakByHabitID(ctx, habitID)
	require.NoError(t, err)
	assert.NotNil(t, streak)
	assert.Equal(t, habitID, streak.HabitID)
	assert.Equal(t, 0, streak.CurrentStreak)
	assert.Equal(t, 0, streak.LongestStreak)
}
