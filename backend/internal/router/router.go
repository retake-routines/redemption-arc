package router

import (
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"habitpal-backend/internal/handler"
	"habitpal-backend/internal/middleware"
)

func SetupRouter(
	authHandler *handler.AuthHandler,
	habitHandler *handler.HabitHandler,
	completionHandler *handler.CompletionHandler,
	jwtSecret string,
) *gin.Engine {
	r := gin.Default()

	r.Use(middleware.CORSMiddleware())

	// Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	api := r.Group("/api/v1")

	// Public routes
	auth := api.Group("/auth")
	{
		auth.POST("/register", authHandler.HandleRegister)
		auth.POST("/login", authHandler.HandleLogin)
	}

	// Protected routes
	protected := api.Group("")
	protected.Use(middleware.JWTAuthMiddleware(jwtSecret))
	{
		habits := protected.Group("/habits")
		{
			habits.POST("", habitHandler.HandleCreate)
			habits.GET("", habitHandler.HandleGetAll)
			habits.GET("/:id", habitHandler.HandleGetByID)
			habits.PUT("/:id", habitHandler.HandleUpdate)
			habits.DELETE("/:id", habitHandler.HandleDelete)
		}

		completions := protected.Group("/completions")
		{
			completions.POST("", completionHandler.HandleComplete)
			completions.DELETE("/:id", completionHandler.HandleUncomplete)
			completions.GET("", completionHandler.HandleGetCompletions)
			completions.GET("/streak/:habitId", completionHandler.HandleGetStreak)
		}
	}

	return r
}
