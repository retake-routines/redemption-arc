package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"

	authpb "habitpal-backend/proto/gen/auth"
)

// GRPCAuthMiddleware validates JWT tokens by calling the Auth Service gRPC endpoint
// instead of validating JWT locally. This is used by habit-service and completion-service.
func GRPCAuthMiddleware(authGRPCAddr string) gin.HandlerFunc {
	// Create a shared gRPC connection with keepalive.
	// grpc.Dial is non-blocking by default and will connect lazily.
	conn, err := grpc.Dial(authGRPCAddr, //nolint:staticcheck
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithKeepaliveParams(keepalive.ClientParameters{
			Time:                5 * time.Minute,
			Timeout:             20 * time.Second,
			PermitWithoutStream: false,
		}),
	)
	if err != nil {
		log.Printf("WARNING: failed to create gRPC connection to auth service at %s: %v", authGRPCAddr, err)
		conn = nil
	}

	var client authpb.AuthServiceClient
	if conn != nil {
		client = authpb.NewAuthServiceClient(conn)
	}

	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "authorization header required"})
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid authorization header format"})
			return
		}

		tokenString := parts[1]

		// If we don't have a client, try to create one
		activeClient := client
		if activeClient == nil {
			newConn, dialErr := grpc.Dial(authGRPCAddr, //nolint:staticcheck
				grpc.WithTransportCredentials(insecure.NewCredentials()),
			)
			if dialErr != nil {
				c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "auth service unavailable"})
				return
			}
			activeClient = authpb.NewAuthServiceClient(newConn)
		}

		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		resp, err := activeClient.ValidateToken(ctx, &authpb.ValidateTokenRequest{
			Token: tokenString,
		})
		if err != nil || !resp.GetValid() {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
			return
		}

		c.Set("userID", resp.GetUserId())
		c.Next()
	}
}
