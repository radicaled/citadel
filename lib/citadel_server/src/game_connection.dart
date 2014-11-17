part of citadel_server;

// TODO: do I need to clean this up?
class GameConnection implements NetworkConnection {
  Stream get incoming => ws;
  WebSocket ws;
  // TODO: this represents the player owned by the websocket connection.
  Entity entity;
  GameConnection(this.ws, this.entity);

  void send(String message) {
    ws.add(message);
  }
}
