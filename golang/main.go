package main

import (
	"fmt"
	"net"
	"os"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()
	buf := make([]byte, 1024)
	n, err := conn.Read(buf)
	if err != nil {
		fmt.Println("Read error:", err)
		return
	}
	fmt.Printf("Go received: %s\n", string(buf[:n]))
}

func main() {
	socketPath := "/tmp/shared_socket"

	// Remove socket file if it already exists
	if _, err := os.Stat(socketPath); err == nil {
		os.Remove(socketPath)
	}

	// Listen on Unix socket
	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		fmt.Println("Listen error:", err)
		os.Exit(1)
	}
	defer listener.Close()

	fmt.Println("Go server listening on Unix socket...")

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Accept error:", err)
			continue
		}
		go handleConnection(conn) // handle each connection concurrently
	}
}
