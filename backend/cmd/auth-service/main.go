package main

import (
	"context"
	"log"
	"net"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/grpc"

	"habitpal-backend/internal/config"
	"habitpal-backend/internal/handler"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/service"
	authpb "habitpal-backend/proto/gen/auth"
)

// authGRPCServer implements the AuthService gRPC server.
type authGRPCServer struct {
	authpb.UnimplementedAuthServiceServer
	authService *service.AuthService
}

// ValidateToken validates a JWT token via gRPC, returning the user ID if valid.
func (s *authGRPCServer) ValidateToken(ctx context.Context, req *authpb.ValidateTokenRequest) (*authpb.ValidateTokenResponse, error) {
	userID, err := s.authService.ValidateToken(req.GetToken())
	if err != nil {
		return &authpb.ValidateTokenResponse{
			UserId: "",
			Valid:  false,
		}, nil
	}
	return &authpb.ValidateTokenResponse{
		UserId: userID,
		Valid:  true,
	}, nil
}

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

	// Initialize repository and service
	userRepo := repository.NewPostgresUserRepository(pool)
	authService := service.NewAuthService(userRepo, cfg.JWTSecret, cfg.JWTExpirationHours)
	authHandler := handler.NewAuthHandler(authService)

	// Determine ports
	httpPort := os.Getenv("AUTH_HTTP_PORT")
	if httpPort == "" {
		httpPort = cfg.Port
		if httpPort == "" {
			httpPort = "8081"
		}
	}

	grpcPort := os.Getenv("AUTH_GRPC_PORT")
	if grpcPort == "" {
		grpcPort = "9091"
	}

	// Start gRPC server in a goroutine
	go func() {
		lis, err := net.Listen("tcp", ":"+grpcPort)
		if err != nil {
			log.Fatalf("Failed to listen for gRPC: %v", err)
		}

		grpcServer := grpc.NewServer()
		authpb.RegisterAuthServiceServer(grpcServer, &authGRPCServer{authService: authService})

		log.Printf("Auth gRPC server listening on port %s", grpcPort)
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()

	// Setup HTTP server with Gin
	r := gin.Default()

	auth := r.Group("/auth")
	{
		auth.POST("/register", authHandler.HandleRegister)
		auth.POST("/login", authHandler.HandleLogin)
	}

	// Also serve under /api/v1/auth for backward compatibility
	apiAuth := r.Group("/api/v1/auth")
	{
		apiAuth.POST("/register", authHandler.HandleRegister)
		apiAuth.POST("/login", authHandler.HandleLogin)
	}

	log.Printf("Auth HTTP server starting on port %s", httpPort)
	if err := r.Run(":" + httpPort); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
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
