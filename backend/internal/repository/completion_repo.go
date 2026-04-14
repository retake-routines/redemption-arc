package repository

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"habitpal-backend/internal/models"
)

// ErrCompletionNotFound is returned when a completion cannot be found.
var ErrCompletionNotFound = errors.New("completion not found")

// ErrDuplicateCompletion is returned when a duplicate completion is attempted.
var ErrDuplicateCompletion = errors.New("completion already exists for this habit at this time")

// CompletionRepository defines the interface for completion data access.
type CompletionRepository interface {
	Create(ctx context.Context, completion *models.HabitCompletion) error
	GetByID(ctx context.Context, id string) (*models.HabitCompletion, error)
	GetByHabitID(ctx context.Context, habitID string) ([]models.HabitCompletion, error)
	GetByUserIDAndDateRange(ctx context.Context, userID string, from, to time.Time) ([]models.HabitCompletion, error)
	GetByUserID(ctx context.Context, userID string) ([]models.HabitCompletion, error)
	GetByHabitIDAndDateRange(ctx context.Context, habitID string, from, to time.Time) ([]models.HabitCompletion, error)
	Delete(ctx context.Context, id string) error
	GetStreakByHabitID(ctx context.Context, habitID string) (*models.Streak, error)
	CountByUserID(ctx context.Context, userID string) (int, error)
	CountByHabitID(ctx context.Context, habitID string) (int, error)
	CountByUserIDAndHabitID(ctx context.Context, userID string, habitID string) (int, error)
}

// PostgresCompletionRepository implements CompletionRepository using PostgreSQL.
type PostgresCompletionRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresCompletionRepository creates a new PostgresCompletionRepository.
func NewPostgresCompletionRepository(pool *pgxpool.Pool) *PostgresCompletionRepository {
	return &PostgresCompletionRepository{pool: pool}
}

// Create inserts a new completion record. The completion's ID and CompletedAt
// are populated by the database via RETURNING. If [completion.CompletedAt] is
// zero, the DB default (NOW()) is used.
func (r *PostgresCompletionRepository) Create(ctx context.Context, completion *models.HabitCompletion) error {
	var query string
	var args []interface{}
	if completion.CompletedAt.IsZero() {
		query = `
		INSERT INTO habit_completions (habit_id, user_id, note)
		VALUES ($1, $2, $3)
		RETURNING id, completed_at`
		args = []interface{}{completion.HabitID, completion.UserID, completion.Note}
	} else {
		query = `
		INSERT INTO habit_completions (habit_id, user_id, note, completed_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, completed_at`
		args = []interface{}{
			completion.HabitID,
			completion.UserID,
			completion.Note,
			completion.CompletedAt,
		}
	}

	err := r.pool.QueryRow(ctx, query, args...).Scan(&completion.ID, &completion.CompletedAt)
	if err != nil {
		if isDuplicateKeyError(err) {
			return ErrDuplicateCompletion
		}
		return fmt.Errorf("creating completion: %w", err)
	}
	return nil
}

// GetByID retrieves a completion by its UUID.
func (r *PostgresCompletionRepository) GetByID(ctx context.Context, id string) (*models.HabitCompletion, error) {
	query := `
		SELECT id, habit_id, user_id, completed_at, note
		FROM habit_completions
		WHERE id = $1`

	c := &models.HabitCompletion{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&c.ID, &c.HabitID, &c.UserID, &c.CompletedAt, &c.Note,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrCompletionNotFound
		}
		return nil, fmt.Errorf("getting completion by id: %w", err)
	}
	return c, nil
}

// GetByHabitID retrieves all completions for a habit, ordered by completed_at descending.
func (r *PostgresCompletionRepository) GetByHabitID(ctx context.Context, habitID string) ([]models.HabitCompletion, error) {
	query := `
		SELECT id, habit_id, user_id, completed_at, note
		FROM habit_completions
		WHERE habit_id = $1
		ORDER BY completed_at DESC`

	return r.queryCompletions(ctx, query, habitID)
}

// GetByUserIDAndDateRange retrieves all completions for a user in a date range.
func (r *PostgresCompletionRepository) GetByUserIDAndDateRange(ctx context.Context, userID string, from, to time.Time) ([]models.HabitCompletion, error) {
	query := `
		SELECT id, habit_id, user_id, completed_at, note
		FROM habit_completions
		WHERE user_id = $1 AND completed_at >= $2 AND completed_at <= $3
		ORDER BY completed_at DESC`

	return r.queryCompletions(ctx, query, userID, from, to)
}

// GetByUserID retrieves all completions for a user, ordered by completed_at descending.
func (r *PostgresCompletionRepository) GetByUserID(ctx context.Context, userID string) ([]models.HabitCompletion, error) {
	query := `
		SELECT id, habit_id, user_id, completed_at, note
		FROM habit_completions
		WHERE user_id = $1
		ORDER BY completed_at DESC`

	return r.queryCompletions(ctx, query, userID)
}

// GetByHabitIDAndDateRange retrieves completions for a habit in a date range.
func (r *PostgresCompletionRepository) GetByHabitIDAndDateRange(ctx context.Context, habitID string, from, to time.Time) ([]models.HabitCompletion, error) {
	query := `
		SELECT id, habit_id, user_id, completed_at, note
		FROM habit_completions
		WHERE habit_id = $1 AND completed_at >= $2 AND completed_at <= $3
		ORDER BY completed_at DESC`

	return r.queryCompletions(ctx, query, habitID, from, to)
}

// Delete removes a completion by its UUID.
func (r *PostgresCompletionRepository) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM habit_completions WHERE id = $1`

	result, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("deleting completion: %w", err)
	}
	if result.RowsAffected() == 0 {
		return ErrCompletionNotFound
	}
	return nil
}

// GetStreakByHabitID calculates the current and longest streak for a habit.
// It fetches all completion dates and computes streaks in Go.
func (r *PostgresCompletionRepository) GetStreakByHabitID(ctx context.Context, habitID string) (*models.Streak, error) {
	query := `
		SELECT DISTINCT completed_at::date AS completion_date
		FROM habit_completions
		WHERE habit_id = $1
		ORDER BY completion_date DESC`

	rows, err := r.pool.Query(ctx, query, habitID)
	if err != nil {
		return nil, fmt.Errorf("getting streak dates: %w", err)
	}
	defer rows.Close()

	var dates []time.Time
	for rows.Next() {
		var d time.Time
		if err := rows.Scan(&d); err != nil {
			return nil, fmt.Errorf("scanning streak date: %w", err)
		}
		dates = append(dates, d)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating streak dates: %w", err)
	}

	streak := &models.Streak{
		HabitID: habitID,
	}

	if len(dates) == 0 {
		return streak, nil
	}

	// Get the last completed time for the response
	lastQuery := `
		SELECT completed_at FROM habit_completions
		WHERE habit_id = $1
		ORDER BY completed_at DESC
		LIMIT 1`

	var lastCompleted time.Time
	err = r.pool.QueryRow(ctx, lastQuery, habitID).Scan(&lastCompleted)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("getting last completed: %w", err)
	}
	if err == nil {
		streak.LastCompletedAt = &lastCompleted
	}

	// Sort dates descending (should already be, but ensure)
	sort.Slice(dates, func(i, j int) bool {
		return dates[i].After(dates[j])
	})

	// Calculate current streak: count consecutive days from today backwards.
	today := time.Now().UTC().Truncate(24 * time.Hour)
	currentStreak := 0
	expectedDate := today

	for _, d := range dates {
		day := d.UTC().Truncate(24 * time.Hour)
		if day.Equal(expectedDate) {
			currentStreak++
			expectedDate = expectedDate.AddDate(0, 0, -1)
		} else if day.Equal(expectedDate.AddDate(0, 0, -1)) {
			// Allow the streak to start from yesterday if today isn't completed yet
			if currentStreak == 0 {
				expectedDate = day
				currentStreak++
				expectedDate = expectedDate.AddDate(0, 0, -1)
			} else {
				break
			}
		} else if day.Before(expectedDate) {
			break
		}
	}

	// Calculate longest streak
	longestStreak := 0
	currentRun := 1
	for i := 1; i < len(dates); i++ {
		prevDay := dates[i-1].UTC().Truncate(24 * time.Hour)
		currDay := dates[i].UTC().Truncate(24 * time.Hour)
		diff := prevDay.Sub(currDay)
		if diff == 24*time.Hour {
			currentRun++
		} else {
			if currentRun > longestStreak {
				longestStreak = currentRun
			}
			currentRun = 1
		}
	}
	if currentRun > longestStreak {
		longestStreak = currentRun
	}

	streak.CurrentStreak = currentStreak
	streak.LongestStreak = longestStreak

	return streak, nil
}

// CountByUserID returns the total number of completions for a user.
func (r *PostgresCompletionRepository) CountByUserID(ctx context.Context, userID string) (int, error) {
	query := `SELECT COUNT(*) FROM habit_completions WHERE user_id = $1`
	var count int
	err := r.pool.QueryRow(ctx, query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("counting completions by user id: %w", err)
	}
	return count, nil
}

// CountByHabitID returns the total number of completions for a habit.
func (r *PostgresCompletionRepository) CountByHabitID(ctx context.Context, habitID string) (int, error) {
	query := `SELECT COUNT(*) FROM habit_completions WHERE habit_id = $1`
	var count int
	err := r.pool.QueryRow(ctx, query, habitID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("counting completions by habit id: %w", err)
	}
	return count, nil
}

// CountByUserIDAndHabitID returns the total number of completions for a specific habit by a user.
func (r *PostgresCompletionRepository) CountByUserIDAndHabitID(ctx context.Context, userID string, habitID string) (int, error) {
	query := `SELECT COUNT(*) FROM habit_completions WHERE user_id = $1 AND habit_id = $2`
	var count int
	err := r.pool.QueryRow(ctx, query, userID, habitID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("counting completions by user and habit id: %w", err)
	}
	return count, nil
}

// queryCompletions is a helper that runs a query and scans rows into HabitCompletion slices.
func (r *PostgresCompletionRepository) queryCompletions(ctx context.Context, query string, args ...interface{}) ([]models.HabitCompletion, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("querying completions: %w", err)
	}
	defer rows.Close()

	var completions []models.HabitCompletion
	for rows.Next() {
		var c models.HabitCompletion
		if err := rows.Scan(&c.ID, &c.HabitID, &c.UserID, &c.CompletedAt, &c.Note); err != nil {
			return nil, fmt.Errorf("scanning completion row: %w", err)
		}
		completions = append(completions, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating completion rows: %w", err)
	}

	if completions == nil {
		completions = []models.HabitCompletion{}
	}
	return completions, nil
}
