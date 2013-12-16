library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart' as logging;
import 'dart:io';

part 'src/entity.dart';
part 'src/components/component.dart';
part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';
part 'src/builders/build_player.dart';

final logging.Logger log = new logging.Logger('CitadelServer')
  ..onRecord.listen((logging.LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

List<Entity> liveEntities = new List<Entity>();
List<Map> commandQueue = new List<Map>();

var player = buildPlayer();

class CitadelServer {
  WebSocket websocket;

  void start() {
    log.info('starting server');
    _startLoop();
    _startServer();
  }

  void _startLoop() {
    var gl = new GameLoopIsolate();

    gl.onUpdate = (gameLoop) {
      _executeSystems();
      _processCommands();
    };

    gl.start();
  }

  void _startServer() {
    HttpServer.bind('127.0.0.1', 8000)
      .then((HttpServer server) {

        server.listen((HttpRequest request) {
           if (request.uri.path == '/ws') {
             WebSocketTransformer.upgrade(request).then((WebSocket ws) {
               websocket = ws;
               websocket.listen(_handleWebSocketMessage);
             });
           }
        });
    });
  }

  void _handleWebSocketMessage(message) {
    var request = json.parse(message);

    switch (request['type']) {
      case 'move':
        _doMovement(request['payload']);
        break;
    }
    print("Received: $message");
  }

  void _doMovement(Map payload) {
    var pos = player['position'];
    var velocity = player['velocity'];
    switch (payload['direction']) {
      case 'N':
        velocity['y'] -= 1;
        break;
      case 'W':
        velocity['x'] -= 1;
        break;
      case 'S':
        velocity['y'] += 1;
        break;
      case 'E':
        velocity['x'] += 1;
        break;
    }
  }

  void _send(type, payload) {
    var msg = json.stringify({ 'type': type, 'payload': payload });
    websocket.add(msg);
  }

  _executeSystems() {
    movementSystem();
  }

  _processCommands() {
    commandQueue.forEach((Map cmd) {
      _send(cmd['name'], cmd['payload']);
    });

    commandQueue.clear();
  }
}