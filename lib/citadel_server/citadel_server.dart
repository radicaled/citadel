library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart' as logging;
import 'package:citadel/tilemap.dart' as tmx;
import 'dart:io';

part 'src/entity.dart';

// Components
part 'src/components/component.dart';
part 'src/components/position.dart';
part 'src/components/velocity.dart';
part 'src/components/collidable.dart';

part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';
// Builders
part 'src/builders/build_player.dart';
part 'src/builders/build_wall.dart';
part 'src/entity_utils.dart';

final logging.Logger log = new logging.Logger('CitadelServer')
  ..onRecord.listen((logging.LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

List<Entity> liveEntities = new List<Entity>();
List<Map> commandQueue = new List<Map>();

var player = buildPlayer();

class CitadelServer {
  WebSocket websocket;
  tmx.TiledMap map;

  void test() {
    // GODDAMN IT NO REPL THE DEBUGGER DOESN'T COUNT
    var pos = new Position(0, 0);
    print(pos.runtimeType);
    print(Position == pos.runtimeType);
  }

  void start() {
    // TODO: make sure these run in order.
    log.info('loading map');
    _loadMap();

    log.info('starting server');
    _startLoop();
    _startServer();

    var ee = new Entity();
    ee.attach(new Position(1, 1));
    ee.attach(new Collidable());
    liveEntities.add(ee);
  }

  _loadMap() {
    var tilemap = new tmx.Tilemap((List<int> bytes) => new ZLibDecoder().convert(bytes));
    new File('./assets/maps/shit_station-1.tmx').readAsString().then((xml) {
      map = tilemap.loadMap(xml);
    });
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
    var velocity = player[Velocity];
    switch (payload['direction']) {
      case 'N':
        velocity.y -= 1;
        break;
      case 'W':
        velocity.x -= 1;
        break;
      case 'S':
        velocity.y += 1;
        break;
      case 'E':
        velocity.x += 1;
        break;
    }
  }

  void _send(type, payload) {
    var msg = json.stringify({ 'type': type, 'payload': payload });
    websocket.add(msg);
  }

  _executeSystems() {
    collisionSystem();
    movementSystem();
  }

  _processCommands() {
    commandQueue.forEach((Map cmd) {
      _send(cmd['name'], cmd['payload']);
    });

    commandQueue.clear();
  }
}