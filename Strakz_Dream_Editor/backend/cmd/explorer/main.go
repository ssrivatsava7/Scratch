package main

import (
	"log"
	"net/http"

	"backend/internal/explorer"
)

func main() {
	http.HandleFunc("/ws", explorer.HandleWebSocket)

	log.Println("Explorer backend running on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
