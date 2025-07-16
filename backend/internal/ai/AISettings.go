package ai

import (
	"context"
	"errors"
	"fmt"
	"log"

	"google.golang.org/genai"
)

var ctx context.Context
var client genai.Client

func SetupAI() {
	ctx = context.Background()
	newClient, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  "AIzaSyCoOziQyc1ZoekZ1M5qP9B06M1pqoXV9pE",
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		log.Fatal(err)
		return
	}
	client = *newClient
}

func newTextMessge(message string) (string, error) {
	if message == "" {
		return "", errors.New("message is empty")
	}
	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		genai.Text(message),
		nil,
	)
	if err != nil {
		return "", err
	}
	fmt.Println(result.Text())
	return result.Text(), nil
}
