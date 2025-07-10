package main

import (
	"fmt"

	"github.com/slickip/Stress-management-app/backend/config"
)

func main() {
	cfg := config.LoadConfig()

	fmt.Println("запускаем сервер на порту:", cfg.Port)
}
