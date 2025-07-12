package models

import "time"

type User struct {
	ID        uint   `gorm:"primaryKey"`
	Nickname  string `json:"nickname"`
	Email     string `json:"email" gorm:"unique"`
	Password  string `json:"password"`
	CreatedAt time.Time
}
