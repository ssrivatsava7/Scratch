package explorer

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/gorilla/websocket"
)

func setupServer(t *testing.T) (string, func()) {
	s := httptest.NewServer(http.HandlerFunc(HandleWebSocket))
	return "ws" + s.URL[4:] + "/ws", s.Close
}

func createTempTestDir(t *testing.T) string {
	tmp := t.TempDir()
	os.WriteFile(filepath.Join(tmp, "test.txt"), []byte("hello"), 0644)
	return tmp
}

func TestWebSocketListDir(t *testing.T) {
	url, teardown := setupServer(t)
	defer teardown()

	// Prepare test dir
	dir := createTempTestDir(t)

	// Connect
	ws, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		t.Fatalf("Dial failed: %v", err)
	}
	defer ws.Close()

	// Send command
	req := map[string]string{"cmd": "list", "path": dir}
	if err := ws.WriteJSON(req); err != nil {
		t.Fatalf("WriteJSON failed: %v", err)
	}

	var resp []FileEntry
	if err := ws.ReadJSON(&resp); err != nil {
		t.Fatalf("ReadJSON failed: %v", err)
	}

	if len(resp) != 1 || resp[0].Name != "test.txt" {
		t.Errorf("Expected test.txt in response, got: %+v", resp)
	}
}

func TestWebSocketReadFile(t *testing.T) {
	url, teardown := setupServer(t)
	defer teardown()

	// Prepare test file
	tmp := t.TempDir()
	fpath := filepath.Join(tmp, "file.bin")
	expected := []byte("123456")
	os.WriteFile(fpath, expected, 0644)

	ws, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		t.Fatalf("Dial failed: %v", err)
	}
	defer ws.Close()

	req := map[string]string{"cmd": "read", "path": fpath}
	if err := ws.WriteJSON(req); err != nil {
		t.Fatalf("WriteJSON failed: %v", err)
	}

	_, data, err := ws.ReadMessage()
	if err != nil {
		t.Fatalf("ReadMessage failed: %v", err)
	}

	if string(data) != string(expected) {
		t.Errorf("Expected %q, got %q", expected, data)
	}
}
