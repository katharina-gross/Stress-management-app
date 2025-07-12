package config

import (
	"fmt"
	"github.com/joho/godotenv"
	"github.com/slickip/Stress-management-app/backend/internal/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
)

var DB *gorm.DB

func ConnectDatabase() string {

	if err := godotenv.Load(); err != nil {
		log.Println("⚠️ .env file not loaded, relying on system environment variables")
	} else {
		log.Println("✅ .env file loaded successfully")
	}
	log.Println(os.Getenv("DB_HOST"))
	dsn := fmt.Sprintf(
		"host=8080 user=postgres password=postgres dbname=stress_app port=5432 sslmode=disable",
		os.Getenv("DB_HOST="),
		os.Getenv("DB_USER="),
		os.Getenv("DB_PASSWORD="),
		os.Getenv("DB_NAME="),
		os.Getenv("DB_PORT="),
	)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	if err := DB.AutoMigrate(
		&models.User{},
		&models.StressSession{},
		&models.Recommendation{},
	); err != nil {
		log.Fatal("AutoMigrate failed:", err)
		return "ni hua ne robit"
	}
	return ""
}
