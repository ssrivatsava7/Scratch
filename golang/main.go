package main

import (
	"fmt"
	"log"
	"net"
	"os"

	"github.com/gofiber/fiber/v2"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()
	buf := make([]byte, 1024)
	n, err := conn.Read(buf)
	if err != nil {
		fmt.Println("Read error:", err)
		return
	}
	fmt.Printf("Received via Unix socket: %q\n", string(buf[:n]))
}

func startUnixSocketServer() {
	socketPath := "/tmp/shared_socket"

	if _, err := os.Stat(socketPath); err == nil {
		os.Remove(socketPath)
	}

	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		log.Fatalf("Listen error: %v", err)
	}
	defer listener.Close()

	fmt.Println("Go server listening on Unix socket...")

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Accept error:", err)
			continue
		}
		go handleConnection(conn)
	}
}

func startFiberServer() {
	app := fiber.New()

	app.Get("/hello", func(c *fiber.Ctx) error {
		return c.SendString("hello from gofiber")
	})

	fmt.Println("Fiber HTTP server running on port 8080...")
	log.Fatal(app.Listen(":8080"))
}

func main() {
	go startUnixSocketServer()
	startFiberServer()
}
