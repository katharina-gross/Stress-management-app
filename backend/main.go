package main

import (
	"github.com/gin-gonic/gin"
	"github.com/slickip/Stress-management-app/backend/WebSocket"
	"github.com/slickip/Stress-management-app/backend/config"
	"github.com/slickip/Stress-management-app/backend/docs"
	"github.com/slickip/Stress-management-app/backend/internal/handlers"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {

	config.ConnectDatabase()

	r := gin.Default()

	// 🔥 CORS Middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// 🔥 Подключение Swagger-документации
	docs.SwaggerInfo.BasePath = "/"
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	hub := WebSocket.NewHub()
	r.GET("/ws", WebSocket.HandleWS(hub))
	r.POST("/register", handlers.Register)
	r.POST("/login", handlers.Login)

	protected := r.Group("/", handlers.AuthMiddleware())
	{
		protected.POST("/sessions", handlers.CreateSessionWithWS(hub))
		protected.GET("/sessions", handlers.GetSessions)
		protected.GET("/session/:id", handlers.GetSessionById)
		protected.DELETE("/session/:id", handlers.DeleteSession)
		protected.GET("/stats", handlers.GetStats)
		protected.GET("/recommendations", handlers.GetRecommendations)
		protected.GET("/recommendations/:id", handlers.GetRecommendationByID)
		protected.POST("/recommendations", handlers.CreateRecommendation)
		protected.PUT("/recommendations/:id", handlers.UpdateRecommendationByID)
		protected.DELETE("/recommendations/:id", handlers.DeleteRecommendationByID)
	}

	r.Run(":8080")
}
