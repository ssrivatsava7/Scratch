import socket
import time

SOCKET_FILE = "/tmp/shared_socket"

# Wait to ensure the Go server is up
time.sleep(2)

client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
client.connect(SOCKET_FILE)
client.sendall(b"Hello from Python!")
client.close()
