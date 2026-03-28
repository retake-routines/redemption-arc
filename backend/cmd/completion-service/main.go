package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"habitpal-backend/internal/config"
	"habitpal-backend/internal/handler"
	"habitpal-backend/internal/middleware"
	"habitpal-backend/internal/repository"
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

	// Initialize repositories and services
	completionRepo := repository.NewPostgresCompletionRepository(pool)
	habitRepo := repository.NewPostgresHabitRepository(pool)
	streakService := service.NewStreakService(completionRepo)
	streakService.SetHabitRepo(habitRepo)
	completionHandler := handler.NewCompletionHandler(completionRepo, streakService)

	// Determine port and auth service address
	httpPort := os.Getenv("COMPLETION_HTTP_PORT")
	if httpPort == "" {
		httpPort = cfg.Port
		if httpPort == "" {
			httpPort = "8083"
		}
	}

	authGRPCAddr := os.Getenv("AUTH_GRPC_ADDR")
	if authGRPCAddr == "" {
		authGRPCAddr = "localhost:9091"
	}

	// Setup HTTP server with Gin
	r := gin.Default()
	r.Use(middleware.CORSMiddleware())

	// Protected routes using gRPC auth middleware
	completions := r.Group("/completions")
	completions.Use(middleware.GRPCAuthMiddleware(authGRPCAddr))
	{
		completions.POST("", completionHandler.HandleComplete)
		completions.DELETE("/:id", completionHandler.HandleUncomplete)
		completions.GET("", completionHandler.HandleGetCompletions)
		completions.GET("/streak/:habitId", completionHandler.HandleGetStreak)
	}

	// Also serve under /api/v1/completions for backward compatibility
	apiCompletions := r.Group("/api/v1/completions")
	apiCompletions.Use(middleware.GRPCAuthMiddleware(authGRPCAddr))
	{
		apiCompletions.POST("", completionHandler.HandleComplete)
		apiCompletions.DELETE("/:id", completionHandler.HandleUncomplete)
		apiCompletions.GET("", completionHandler.HandleGetCompletions)
		apiCompletions.GET("/streak/:habitId", completionHandler.HandleGetStreak)
	}

	log.Printf("Completion HTTP server starting on port %s", httpPort)
	if err := r.Run(":" + httpPort); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}
}
