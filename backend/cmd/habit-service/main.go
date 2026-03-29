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

	// Initialize repository and service
	habitRepo := repository.NewPostgresHabitRepository(pool)
	habitService := service.NewHabitService(habitRepo)
	habitHandler := handler.NewHabitHandler(habitService)

	// Determine port and auth service address
	httpPort := os.Getenv("HABIT_HTTP_PORT")
	if httpPort == "" {
		httpPort = cfg.Port
		if httpPort == "" {
			httpPort = "8082"
		}
	}

	authGRPCAddr := os.Getenv("AUTH_GRPC_ADDR")
	if authGRPCAddr == "" {
		authGRPCAddr = "localhost:9091"
	}

	// Setup HTTP server with Gin
	r := gin.Default()
	// Protected routes using gRPC auth middleware
	habits := r.Group("/habits")
	habits.Use(middleware.GRPCAuthMiddleware(authGRPCAddr))
	{
		habits.POST("", habitHandler.HandleCreate)
		habits.GET("", habitHandler.HandleGetAll)
		habits.GET("/:id", habitHandler.HandleGetByID)
		habits.PUT("/:id", habitHandler.HandleUpdate)
		habits.DELETE("/:id", habitHandler.HandleDelete)
	}

	// Also serve under /api/v1/habits for backward compatibility
	apiHabits := r.Group("/api/v1/habits")
	apiHabits.Use(middleware.GRPCAuthMiddleware(authGRPCAddr))
	{
		apiHabits.POST("", habitHandler.HandleCreate)
		apiHabits.GET("", habitHandler.HandleGetAll)
		apiHabits.GET("/:id", habitHandler.HandleGetByID)
		apiHabits.PUT("/:id", habitHandler.HandleUpdate)
		apiHabits.DELETE("/:id", habitHandler.HandleDelete)
	}

	log.Printf("Habit HTTP server starting on port %s", httpPort)
	if err := r.Run(":" + httpPort); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}
}
