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

func setupUserTestDB(t *testing.T) (*pgxpool.Pool, func()) {
	t.Helper()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		t.Skip("DATABASE_URL not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	require.NoError(t, err)

	cleanup := func() {
		_, _ = pool.Exec(ctx, "DELETE FROM habit_completions")
		_, _ = pool.Exec(ctx, "DELETE FROM habits")
		_, _ = pool.Exec(ctx, "DELETE FROM users")
		pool.Close()
	}

	return pool, cleanup
}

func TestCreateUser_Integration(t *testing.T) {
	pool, cleanup := setupUserTestDB(t)
	defer cleanup()

	repo := NewPostgresUserRepository(pool)
	ctx := context.Background()

	user := &models.User{
		Email:        "integration-test@example.com",
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "Integration Test User",
	}

	err := repo.Create(ctx, user)
	require.NoError(t, err)
	assert.NotEmpty(t, user.ID)
	assert.False(t, user.CreatedAt.IsZero())
	assert.False(t, user.UpdatedAt.IsZero())

	// Retrieve and verify
	fetched, err := repo.GetByID(ctx, user.ID)
	require.NoError(t, err)
	assert.Equal(t, user.Email, fetched.Email)
	assert.Equal(t, user.DisplayName, fetched.DisplayName)
}

func TestGetByEmail_Integration(t *testing.T) {
	pool, cleanup := setupUserTestDB(t)
	defer cleanup()

	repo := NewPostgresUserRepository(pool)
	ctx := context.Background()

	email := "find-by-email-" + time.Now().Format("150405") + "@example.com"
	user := &models.User{
		Email:        email,
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "Email Test User",
	}

	err := repo.Create(ctx, user)
	require.NoError(t, err)

	fetched, err := repo.GetByEmail(ctx, email)
	require.NoError(t, err)
	assert.Equal(t, user.ID, fetched.ID)
	assert.Equal(t, email, fetched.Email)
}

func TestDuplicateEmail_Integration(t *testing.T) {
	pool, cleanup := setupUserTestDB(t)
	defer cleanup()

	repo := NewPostgresUserRepository(pool)
	ctx := context.Background()

	email := "duplicate-" + time.Now().Format("150405") + "@example.com"

	user1 := &models.User{
		Email:        email,
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "User 1",
	}
	err := repo.Create(ctx, user1)
	require.NoError(t, err)

	user2 := &models.User{
		Email:        email,
		PasswordHash: "$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012",
		DisplayName:  "User 2",
	}
	err = repo.Create(ctx, user2)
	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrEmailTaken)
}
