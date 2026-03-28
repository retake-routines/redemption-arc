package repository

import (
	"strings"
)

// isDuplicateKeyError checks if the error is a PostgreSQL unique constraint violation.
// pgx returns errors that contain SQLSTATE 23505 for unique violations.
func isDuplicateKeyError(err error) bool {
	if err == nil {
		return false
	}
	// pgconn.PgError has a Code field, but we check the error string
	// to avoid importing pgconn directly and to handle wrapped errors.
	errMsg := err.Error()
	return strings.Contains(errMsg, "23505") || strings.Contains(errMsg, "duplicate key")
}
