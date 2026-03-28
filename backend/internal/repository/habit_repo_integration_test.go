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

func setupHabitTestDB(t *testing.T) (*pgxpool.Pool, string, func()) {
	t.Helper()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		t.Skip("DATABASE_URL not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	require.NoError(t, err)

	// Create a test user to own the habits
	userRepo := NewPostgresUserRepository(pool)
	user := &models.User{
		Email:        "habit-test-" + time.Now().Format("150405.000") + "@example.com",
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "Habit Test User",
	}
	err = userRepo.Create(ctx, user)
	require.NoError(t, err)

	cleanup := func() {
		_, _ = pool.Exec(ctx, "DELETE FROM habit_completions")
		_, _ = pool.Exec(ctx, "DELETE FROM habits")
		_, _ = pool.Exec(ctx, "DELETE FROM users")
		pool.Close()
	}

	return pool, user.ID, cleanup
}

func TestCreateHabit_Integration(t *testing.T) {
	pool, userID, cleanup := setupHabitTestDB(t)
	defer cleanup()

	repo := NewPostgresHabitRepository(pool)
	ctx := context.Background()

	habit := &models.Habit{
		UserID:         userID,
		Title:          "Test Habit",
		Description:    "Integration test habit",
		Icon:           "star",
		Color:          "#00FF00",
		FrequencyType:  "daily",
		FrequencyValue: 1,
		IsArchived:     false,
	}

	err := repo.Create(ctx, habit)
	require.NoError(t, err)
	assert.NotEmpty(t, habit.ID)
	assert.False(t, habit.CreatedAt.IsZero())
}

func TestGetByUserID_Integration(t *testing.T) {
	pool, userID, cleanup := setupHabitTestDB(t)
	defer cleanup()

	repo := NewPostgresHabitRepository(pool)
	ctx := context.Background()

	// Create two habits
	for _, title := range []string{"Habit A", "Habit B"} {
		h := &models.Habit{
			UserID:         userID,
			Title:          title,
			FrequencyType:  "daily",
			FrequencyValue: 1,
		}
		err := repo.Create(ctx, h)
		require.NoError(t, err)
	}

	habits, err := repo.GetByUserID(ctx, userID)
	require.NoError(t, err)
	assert.Len(t, habits, 2)
}

func TestUpdateHabit_Integration(t *testing.T) {
	pool, userID, cleanup := setupHabitTestDB(t)
	defer cleanup()

	repo := NewPostgresHabitRepository(pool)
	ctx := context.Background()

	habit := &models.Habit{
		UserID:         userID,
		Title:          "Original Title",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}
	err := repo.Create(ctx, habit)
	require.NoError(t, err)

	habit.Title = "Updated Title"
	err = repo.Update(ctx, habit)
	require.NoError(t, err)

	fetched, err := repo.GetByID(ctx, habit.ID)
	require.NoError(t, err)
	assert.Equal(t, "Updated Title", fetched.Title)
}

func TestDeleteHabit_Integration(t *testing.T) {
	pool, userID, cleanup := setupHabitTestDB(t)
	defer cleanup()

	repo := NewPostgresHabitRepository(pool)
	ctx := context.Background()

	habit := &models.Habit{
		UserID:         userID,
		Title:          "To Delete",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}
	err := repo.Create(ctx, habit)
	require.NoError(t, err)

	err = repo.Delete(ctx, habit.ID)
	require.NoError(t, err)

	_, err = repo.GetByID(ctx, habit.ID)
	assert.ErrorIs(t, err, ErrHabitNotFound)
}
