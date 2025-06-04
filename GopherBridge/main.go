package main

import (
	"C" // Required for cgo

	"log"

	"github.com/gofiber/fiber/v2"
)

//export StartServer
func StartServer() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello from GoFiber!")
	})

	log.Fatal(app.Listen(":8080"))
}

func main() {
	// Needed for C export, but unused in shared lib mode
}
