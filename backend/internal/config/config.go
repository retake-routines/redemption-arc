package config

import (
	"errors"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds all configuration values for the application.
type Config struct {
	Port               string
	DatabaseURL        string
	JWTSecret          string
	JWTExpirationHours int
	RunMigrations      bool
}

// LoadConfig reads configuration from environment variables with sensible defaults.
func LoadConfig() (*Config, error) {
	// Load .env file if it exists (ignore error if not found)
	_ = godotenv.Load()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = "postgres://postgres:postgres@localhost:5432/habitpal?sslmode=disable"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "default-secret-change-me"
	}

	jwtExpHours := 24
	if val := os.Getenv("JWT_EXPIRATION_HOURS"); val != "" {
		parsed, err := strconv.Atoi(val)
		if err != nil {
			return nil, errors.New("JWT_EXPIRATION_HOURS must be a valid integer")
		}
		if parsed < 1 {
			return nil, errors.New("JWT_EXPIRATION_HOURS must be at least 1")
		}
		jwtExpHours = parsed
	}

	runMigrations := false
	if val := os.Getenv("RUN_MIGRATIONS"); val == "true" || val == "1" {
		runMigrations = true
	}

	cfg := &Config{
		Port:               port,
		DatabaseURL:        databaseURL,
		JWTSecret:          jwtSecret,
		JWTExpirationHours: jwtExpHours,
		RunMigrations:      runMigrations,
	}

	if err := cfg.Validate(); err != nil {
		return nil, err
	}

	return cfg, nil
}

// Validate checks that all required configuration values are present.
func (c *Config) Validate() error {
	if c.DatabaseURL == "" {
		return errors.New("DATABASE_URL is required")
	}
	if c.JWTSecret == "" {
		return errors.New("JWT_SECRET is required")
	}
	if c.Port == "" {
		return errors.New("PORT is required")
	}
	return nil
}
