package explorer

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("upgrade error: %v", err)
		return
	}
	defer conn.Close()

	svc := &Service{} // Changed to pointer
	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Printf("read error: %v", err)
			break
		}

		req := struct {
			Cmd  string `json:"cmd"`
			Path string `json:"path"`
		}{}
		if err := json.Unmarshal(msg, &req); err != nil {
			log.Printf("invalid message: %v", err)
			continue
		}

		switch req.Cmd {
		case "list":
			files, err := svc.ListDir(req.Path)
			if err != nil {
				conn.WriteJSON(map[string]string{"error": err.Error()})
				continue
			}
			conn.WriteJSON(files)

		case "read":
			data, err := svc.ReadRawFile(req.Path)
			if err != nil {
				conn.WriteJSON(map[string]string{"error": err.Error()})
				continue
			}
			conn.WriteMessage(websocket.BinaryMessage, data)

		default:
			conn.WriteJSON(map[string]string{"error": "unknown command"})
		}
	}
}
