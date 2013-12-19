library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart' as logging;
import 'package:citadel/tilemap.dart' as tmx;
import 'package:route/server.dart';
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

final loginUrl = '/login';
final wsGameUrl = '/ws/game';
int currentPlayerId = 1;

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
  }

  _loadMap() {
    var tilemap = new tmx.Tilemap((List<int> bytes) => new ZLibDecoder().convert(bytes));
    new File('./assets/maps/shit_station-1.tmx').readAsString().then((xml) {
      map = tilemap.loadMap(xml);

      map.layers.forEach( (tmx.Layer layer) {
        layer.tiles.forEach( (tmx.Tile tile) {
          if (!tile.isEmpty && tile.tileset.properties['entity'] == 'wall') {
            buildWall(tile.x / 32, tile.y / 32);
          }
        });
      });
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

        var router = new Router(server)
          ..serve(loginUrl).listen(_loginUser)
          ..serve(wsGameUrl).listen(_gameConnection);
    });
  }

  void _gameConnection(HttpRequest req) {
    log.info('New game connection');
    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      websocket = ws;
      websocket.listen((data) => _handleWebSocketMessage(data, ws)); // onDone here.
    });
  }

  void _loginUser(HttpRequest req) {
    // TODO: security
    var newPlayerId = currentPlayerId++;
    var cookie = new Cookie('playerId', (newPlayerId).toString());
    log.info('Logged in new user');

    var res = req.response;
    res.headers.contentType = new ContentType('text', 'text');
    res.headers.add('Access-Control-Allow-Origin', '*');
    res.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS, GET");
    res.cookies.add(cookie);
    res.statusCode = 200;
    res.write(json.stringify({ 'id': newPlayerId }));
    res.close();

    Entity player = buildPlayer();
    player.id = newPlayerId;

    // TODO: generics.
    (player.components[Position] as Position)
      ..x = 8
      ..y = 8;
  }

  void _handleWebSocketMessage(message, [WebSocket ws]) {
    var request = json.parse(message);

    switch (request['type']) {
      case 'move':
        _doMovement(request['payload']);
        break;
    }
    print("Received: $message");
  }

  void _doMovement(int entityId, Map payload) {
    print('Looking for ID of $entityId');
    var player = liveEntities.firstWhere( (entity) => entity.id == entityId );
    var comps = player.components;
    print('Found player $player with components: $comps');
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
    log.info('Sent: $msg');
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