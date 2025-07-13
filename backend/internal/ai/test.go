package ai

import (
	"context"
	"fmt"
	"google.golang.org/genai"
	"log"
)

func main() {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  "AIzaSyCoOziQyc1ZoekZ1M5qP9B06M1pqoXV9pE",
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		log.Fatal(err)
	}
	result, err := client.Models.GenerateContent(
		ctx,
		"gemini-2.5-flash",
		genai.Text("что такое отдых?"),
		nil,
	)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result.Text())
}
