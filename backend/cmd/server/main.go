package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"habitpal-backend/internal/config"
	"habitpal-backend/internal/handler"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/router"
	"habitpal-backend/internal/service"
)

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Connect to PostgreSQL
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to create connection pool: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Connected to PostgreSQL")

	// Run migrations if enabled
	if cfg.RunMigrations {
		if err := runMigrations(ctx, pool); err != nil {
			log.Fatalf("Failed to run migrations: %v", err)
		}
		log.Println("Migrations applied successfully")
	}

	// Initialize repositories
	userRepo := repository.NewPostgresUserRepository(pool)
	habitRepo := repository.NewPostgresHabitRepository(pool)
	completionRepo := repository.NewPostgresCompletionRepository(pool)

	// Initialize services
	authService := service.NewAuthService(userRepo, cfg.JWTSecret, cfg.JWTExpirationHours)
	habitService := service.NewHabitService(habitRepo)
	streakService := service.NewStreakService(completionRepo)
	streakService.SetHabitRepo(habitRepo)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	habitHandler := handler.NewHabitHandler(habitService)
	completionHandler := handler.NewCompletionHandler(completionRepo, streakService)

	// Setup router and start server
	r := router.SetupRouter(authHandler, habitHandler, completionHandler, cfg.JWTSecret)

	log.Printf("Starting server on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func runMigrations(ctx context.Context, pool *pgxpool.Pool) error {
	sql, err := os.ReadFile("migrations/001_init.sql")
	if err != nil {
		return err
	}
	_, err = pool.Exec(ctx, string(sql))
	return err
}
