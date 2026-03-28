package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"habitpal-backend/internal/models"
)

// ErrHabitNotFound is returned when a habit cannot be found.
var ErrHabitNotFound = errors.New("habit not found")

// HabitRepository defines the interface for habit data access.
type HabitRepository interface {
	Create(ctx context.Context, habit *models.Habit) error
	GetByID(ctx context.Context, id string) (*models.Habit, error)
	GetByUserID(ctx context.Context, userID string) ([]models.Habit, error)
	Update(ctx context.Context, habit *models.Habit) error
	Delete(ctx context.Context, id string) error
	CountByUserID(ctx context.Context, userID string) (int, error)
}

// PostgresHabitRepository implements HabitRepository using PostgreSQL.
type PostgresHabitRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresHabitRepository creates a new PostgresHabitRepository.
func NewPostgresHabitRepository(pool *pgxpool.Pool) *PostgresHabitRepository {
	return &PostgresHabitRepository{pool: pool}
}

// Create inserts a new habit into the database. The habit's ID, CreatedAt, and UpdatedAt
// are populated by the database via RETURNING.
func (r *PostgresHabitRepository) Create(ctx context.Context, habit *models.Habit) error {
	query := `
		INSERT INTO habits (user_id, title, description, icon, color, frequency_type, frequency_value, is_archived)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`

	err := r.pool.QueryRow(ctx, query,
		habit.UserID,
		habit.Title,
		habit.Description,
		habit.Icon,
		habit.Color,
		habit.FrequencyType,
		habit.FrequencyValue,
		habit.IsArchived,
	).Scan(&habit.ID, &habit.CreatedAt, &habit.UpdatedAt)
	if err != nil {
		return fmt.Errorf("creating habit: %w", err)
	}
	return nil
}

// GetByID retrieves a habit by its UUID.
func (r *PostgresHabitRepository) GetByID(ctx context.Context, id string) (*models.Habit, error) {
	query := `
		SELECT id, user_id, title, description, icon, color, frequency_type, frequency_value, is_archived, created_at, updated_at
		FROM habits
		WHERE id = $1`

	habit := &models.Habit{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&habit.ID,
		&habit.UserID,
		&habit.Title,
		&habit.Description,
		&habit.Icon,
		&habit.Color,
		&habit.FrequencyType,
		&habit.FrequencyValue,
		&habit.IsArchived,
		&habit.CreatedAt,
		&habit.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrHabitNotFound
		}
		return nil, fmt.Errorf("getting habit by id: %w", err)
	}
	return habit, nil
}

// GetByUserID retrieves all habits for a user, ordered by created_at descending.
func (r *PostgresHabitRepository) GetByUserID(ctx context.Context, userID string) ([]models.Habit, error) {
	query := `
		SELECT id, user_id, title, description, icon, color, frequency_type, frequency_value, is_archived, created_at, updated_at
		FROM habits
		WHERE user_id = $1
		ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("getting habits by user id: %w", err)
	}
	defer rows.Close()

	var habits []models.Habit
	for rows.Next() {
		var h models.Habit
		err := rows.Scan(
			&h.ID,
			&h.UserID,
			&h.Title,
			&h.Description,
			&h.Icon,
			&h.Color,
			&h.FrequencyType,
			&h.FrequencyValue,
			&h.IsArchived,
			&h.CreatedAt,
			&h.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scanning habit row: %w", err)
		}
		habits = append(habits, h)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating habit rows: %w", err)
	}

	if habits == nil {
		habits = []models.Habit{}
	}
	return habits, nil
}

// Update modifies a habit's fields. Only non-nil/non-zero fields in the provided
// habit struct are updated. The habit struct is updated in place with the new values.
func (r *PostgresHabitRepository) Update(ctx context.Context, habit *models.Habit) error {
	query := `
		UPDATE habits
		SET title = $2, description = $3, icon = $4, color = $5,
		    frequency_type = $6, frequency_value = $7, is_archived = $8, updated_at = NOW()
		WHERE id = $1
		RETURNING updated_at`

	err := r.pool.QueryRow(ctx, query,
		habit.ID,
		habit.Title,
		habit.Description,
		habit.Icon,
		habit.Color,
		habit.FrequencyType,
		habit.FrequencyValue,
		habit.IsArchived,
	).Scan(&habit.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return ErrHabitNotFound
		}
		return fmt.Errorf("updating habit: %w", err)
	}
	return nil
}

// Delete removes a habit by its UUID. Completions are cascade-deleted by the database.
func (r *PostgresHabitRepository) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM habits WHERE id = $1`

	result, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("deleting habit: %w", err)
	}
	if result.RowsAffected() == 0 {
		return ErrHabitNotFound
	}
	return nil
}

// CountByUserID returns the total number of habits for a user.
func (r *PostgresHabitRepository) CountByUserID(ctx context.Context, userID string) (int, error) {
	query := `SELECT COUNT(*) FROM habits WHERE user_id = $1`

	var count int
	err := r.pool.QueryRow(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("counting habits by user id: %w", err)
	}
	return count, nil
}
