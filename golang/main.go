package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	socketPath := "/tmp/shared_socket"

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		fmt.Println("Dial error:", err)
		os.Exit(1)
	}

	message := "Hello from Go!"
	_, err = conn.Write([]byte(message))
	if err != nil {
		fmt.Println("Write error:", err)
	}
	conn.Close()
}
