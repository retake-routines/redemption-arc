// @title HabitPal API
// @version 1.0
// @description REST API for HabitPal habit tracking application
// @host localhost:8080
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "habitpal-backend/docs"
	"habitpal-backend/internal/middleware"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	authServiceURL := os.Getenv("AUTH_SERVICE_URL")
	if authServiceURL == "" {
		authServiceURL = "http://localhost:8081"
	}

	habitServiceURL := os.Getenv("HABIT_SERVICE_URL")
	if habitServiceURL == "" {
		habitServiceURL = "http://localhost:8082"
	}

	completionServiceURL := os.Getenv("COMPLETION_SERVICE_URL")
	if completionServiceURL == "" {
		completionServiceURL = "http://localhost:8083"
	}

	r := gin.Default()
	r.Use(middleware.CORSMiddleware())

	// Swagger UI
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Reverse proxy routes
	api := r.Group("/api/v1")
	{
		// Auth routes -> Auth Service
		api.Any("/auth/*path", reverseProxy(authServiceURL, "/api/v1/auth"))

		// Habit routes -> Habit Service
		api.Any("/habits", reverseProxy(habitServiceURL, "/api/v1/habits"))
		api.Any("/habits/*path", reverseProxy(habitServiceURL, "/api/v1/habits"))

		// Completion routes -> Completion Service
		api.Any("/completions", reverseProxy(completionServiceURL, "/api/v1/completions"))
		api.Any("/completions/*path", reverseProxy(completionServiceURL, "/api/v1/completions"))
	}

	log.Printf("API Gateway starting on port %s", port)
	log.Printf("  Auth Service:       %s", authServiceURL)
	log.Printf("  Habit Service:      %s", habitServiceURL)
	log.Printf("  Completion Service: %s", completionServiceURL)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start gateway: %v", err)
	}
}

// reverseProxy creates a Gin handler that proxies requests to the target service.
// The basePath is the prefix on the target service that corresponds to the route group.
func reverseProxy(target string, basePath string) gin.HandlerFunc {
	targetURL, err := url.Parse(target)
	if err != nil {
		log.Fatalf("Invalid proxy target URL %s: %v", target, err)
	}

	proxy := httputil.NewSingleHostReverseProxy(targetURL)
	return func(c *gin.Context) {
		// Reconstruct the path for the upstream service
		// c.Request.URL.Path is the full original path, e.g. /api/v1/habits/123
		// We forward it as-is since upstream services also listen on /api/v1/...
		originalPath := c.Request.URL.Path

		// For routes captured with /*path, Gin may have extra processing.
		// We preserve the original request path to forward to the upstream.
		// The upstream services listen on the same /api/v1/... paths.

		// Handle the case where the path param is empty (e.g., /api/v1/habits)
		if pathParam := c.Param("path"); pathParam != "" {
			// Path already correct from original request
			_ = pathParam
		}

		// Ensure the path is forwarded correctly
		c.Request.URL.Path = originalPath
		c.Request.URL.Host = targetURL.Host
		c.Request.URL.Scheme = targetURL.Scheme
		c.Request.Host = targetURL.Host

		// Remove gin's context-specific headers that might interfere
		c.Request.Header.Del("X-Forwarded-For")

		// Set X-Forwarded headers
		if clientIP := c.ClientIP(); clientIP != "" {
			c.Request.Header.Set("X-Forwarded-For", clientIP)
		}
		c.Request.Header.Set("X-Forwarded-Host", c.Request.Host)
		c.Request.Header.Set("X-Forwarded-Proto", schemeFromRequest(c.Request))

		proxy.ServeHTTP(c.Writer, c.Request)

		// Prevent Gin from writing additional response
		c.Abort()
	}
}

func schemeFromRequest(r *http.Request) string {
	if r.TLS != nil {
		return "https"
	}
	if scheme := r.Header.Get("X-Forwarded-Proto"); scheme != "" {
		return scheme
	}
	if strings.HasPrefix(r.Host, "localhost") {
		return "http"
	}
	return "http"
}
