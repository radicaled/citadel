library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart' as logging;
import 'package:tmx/tmx.dart' as tmx;
import 'package:route/server.dart';
import 'dart:io';
import 'dart:async';
import 'dart:mirrors';

import 'package:citadel/game/components.dart';
import 'package:citadel/game/entities.dart';
import 'package:citadel/game/actions.dart';

// Systems
part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';

part 'src/entity_utils.dart';

// misc
part 'src/events/game_event.dart';
part 'src/game_connection.dart';

final logging.Logger log = new logging.Logger('CitadelServer')
  ..onRecord.listen((logging.LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
// TODO: feel like this should be a map
List<Entity> liveEntities = new List<Entity>();
List<Map> commandQueue = new List<Map>();
List<GameConnection> gameConnections = new List<GameConnection>();

final loginUrl = '/login';
final wsGameUrl = '/ws/game';
int currentEntityId = 1;



Entity trackEntity(Entity e) {
  e.id = currentEntityId++;
  liveEntities.add(e);
  return e;
}

StreamController<GameEvent> gameStreamController = new StreamController.broadcast();
Stream<GameEvent> gameStream = gameStreamController.stream;

Stream<GameEvent> subscribe(event_name, [onData(GameEvent ge)]) {
  var stream = gameStream.where((gv) => gv.name == event_name);
  if (onData != null) { stream.listen(onData); }
  return stream; 
}


class CitadelServer {
  tmx.TileMap map;

  void test() {
    // GODDAMN IT NO REPL THE DEBUGGER DOESN'T COUNT
    var pos = new Position(0, 0);
    print(pos.runtimeType);
    print(Position == pos.runtimeType);
  }
  
  void _setupEvents() {
    gameStream.listen((ge) => log.info("Received Event: $ge"));
    subscribe('look_at', handlePlayerAction(LookAction));
    subscribe('move', _doMovement);
    subscribe('get_gamestate', (ge) => _sendGamestate(ge.gameConnection));    
  }
 
  // Handle an action invoked by the player
  handlePlayerAction(Type actionType) {    
    return (GameEvent ge) {      
      var player = ge.gameConnection.entity;
      var target = findEntity(ge.payload['entity_id']);     
      
      Action action = reflectClass(actionType).newInstance(new Symbol(''), [player, target]).reflectee;
      action.execute(onEmit: (text) => _emitTo(text, ge.gameConnection));
    };
  }
  
  // Attempt to locate an entity by its entityId
  // Returns null if entityId not found.
  Entity findEntity(int entityId) {
    if (entityId == null) return null;
    return liveEntities.firstWhere((e) => e.id == entityId, orElse: () => null);
  }

  void start() {
    // TODO: make sure these run in order.
    log.info('loading map');
    _loadMap();
    
    log.info('listening for game events');
    _setupEvents();
    
    log.info('starting server');
    _startLoop();
    _startServer();
    
    
  }

  _loadMap() {
    var parser = new tmx.TileMapParser();
    new File('./assets/maps/shit_station-1.tmx').readAsString().then((xml) {
      map = parser.parse(xml);

      map.layers.forEach( (tmx.Layer layer) {
        layer.tiles.forEach( (tmx.Tile tile) {
          int x = tile.x ~/ 32;
          int y = tile.y ~/ 32;
          
          if (!tile.isEmpty) {
            var entityType = [
                              tile.properties['entity'], 
                              tile.tileset.properties['entity'],
                              'placeholder'
                             ].firstWhere((et) => et != null);
            var entity = buildEntity(entityType);
            entity[Position].x = x;
            entity[Position].y = y;
            entity[TileGraphics].tileGids = [tile.gid];
            trackEntity(entity);
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
          ..serve(wsGameUrl).listen(_gameConnection);
    });
  }

  void _gameConnection(HttpRequest req) {
    Entity player = trackEntity(buildEntity('player'));

    Position pos = player[Position];
    TileGraphics tgs = player[TileGraphics];
    pos
      ..x = 8
      ..y = 8
      ..z = 16;
    tgs.tileGids = [2];
    
    _send(_makeCommand('create_entity', {
        'x': pos.x,
        'y': pos.y,
        'z': pos.z,
        'entity_id': player.id,
        'tileGids': tgs.tileGids,
    }));

    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      var ge = new GameConnection(ws, player);
      gameConnections.add(ge);

      ws.listen((data) => _handleWebSocketMessage(data, ws),
        onDone: () => _removeConnection(ge));
      _sendGamestate(ge);
    });
  }

  void _handleWebSocketMessage(message, [WebSocket ws]) {
    var request = json.parse(message);
    var ge = gameConnections.firstWhere((ge) => ge.ws == ws);
    
    gameStreamController.add(new GameEvent(request, ge));
  }

  _removeConnection(GameConnection ge) {
    gameConnections.remove(ge);
    liveEntities.remove(ge.entity);
    _queueCommand('remove_entity', { 'entity_id': ge.entity.id });
  }

  void _sendDescription(GameEvent ge) {
    int entityId = ge.payload['entity_id'];
    
    var entity = entitiesWithComponents([Description])
        .firstWhere( (e) => e.id == entityId, orElse: () => null);
    if (entity != null) {
      var lookAction = new LookAction(ge.gameConnection.entity, entity);
      lookAction.execute(onEmit: (text) => _emitTo(text, ge.gameConnection));
    }
  }
  
  void _emitTo(String text, GameConnection gc) {
    _sendTo(_makeCommand('emit', { 'text': text }),
        [gc]);
  }
  
  void _doMovement(GameEvent ge) {
    var player = ge.gameConnection.entity;
    var velocity = player[Velocity];
    switch (ge.payload['direction']) {
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

  void _sendGamestate(GameConnection gc) {
    var payload = [];
    entitiesWithComponents([TileGraphics, Position]).forEach( (entity) {
      payload.add(_makeCommand('create_entity', {
          'x': entity[Position].x,
          'y': entity[Position].y,
          'z': entity[Position].z,
          'tileGids': entity[TileGraphics].tileGids,
          'entity_id': entity.id,
          'name': entity[Name] != null ? entity[Name].text : 'Something'
      }));
    });
    _sendTo(_makeCommand('set_gamestate', payload), [gc]);
  }

  void _send(cmd) {
    _sendTo(cmd, gameConnections);
  }

  void _sendTo(cmd, List<GameConnection> connections) {
    var msg = json.stringify(cmd);
    connections.forEach((ge) => ge.ws.add(msg));
    log.info('Sent: $msg');
  }

  Map _makeCommand(String type, Map payload) {
    return { 'type': type, 'payload': payload };
  }

  void _queueCommand(String type, Map payload) {
    commandQueue.add(_makeCommand(type, payload));
  }

  _executeSystems() {
    collisionSystem();
    movementSystem();
  }

  _processCommands() {
    commandQueue.forEach((Map cmd) {
      _send(cmd);
    });

    commandQueue.clear();
  }
}