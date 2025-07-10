package main

import (
	"fmt"

	"./config"
)

func main() {
	cfg := config.LoadConfig()

	fmt.Println("запускаем сервер на порту:", cfg.Port)
}
