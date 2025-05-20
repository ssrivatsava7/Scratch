import socket
import os

SOCKET_FILE = "/tmp/shared_socket"

# Remove socket file if it already exists
if os.path.exists(SOCKET_FILE):
    os.remove(SOCKET_FILE)

# Create socket
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(SOCKET_FILE)
server.listen(1)

print("Python server listening on Unix socket...")

conn, _ = server.accept()
msg = conn.recv(1024)
print(f"Python received: {msg.decode()}")
conn.close()
