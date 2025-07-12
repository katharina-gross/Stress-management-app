package WebSocket

import (
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"net/http"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// HandleWS godoc
// @Summary WebSocket endpoint for real-time session updates
// @Description Establish WebSocket connection to receive real-time "new_session" events
// @Tags websocket
// @Produce plain
// @Success 101 {string} string "Switching Protocols"
// @Failure 400 {object} map[string]string
// @Router /ws [get]
func HandleWS(hub *Hub) gin.HandlerFunc {
	return func(c *gin.Context) {
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			return
		}
		hub.AddClient(conn)

		defer hub.RemoveClient(conn)

		for {
			_, _, err := conn.ReadMessage()
			if err != nil {
				break
			}
		}
	}
}
