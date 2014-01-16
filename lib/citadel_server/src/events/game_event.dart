part of citadel_server;

class GameEvent {
  Map _message;
  GameConnection gameConnection;
  
  String get name => _message['type'];
  Map get payload => _message['payload'];
  
  GameEvent(this._message, this.gameConnection);
  
  toString() {
    return "GameEvent($name: $payload)";  
  }
}