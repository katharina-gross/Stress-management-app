package models

import "time"

type StressSession struct {
	ID          uint      `gorm:"primaryKey"`
	UserID      uint      `json:"user_id"`
	Description string    `json:"description"`
	StressLevel int       `json:"stress_level"`
	Date        time.Time `json:"date"`
	CreatedAt   time.Time
}
