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
import 'package:citadel/game/intents.dart';

// Component Systems
part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';
part 'src/systems/pickup_intent_system.dart';

// Intent systems
part 'src/systems/intent_system.dart';
part 'src/systems/move_intent_system.dart';
part 'src/systems/look_intent_system.dart';
part 'src/systems/interact_intent_system.dart';

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

Map _makeCommand(String type, payload) {
  return { 'type': type, 'payload': payload };
}


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

IntentSystem intentSystem = new IntentSystem();

class CitadelServer {
  tmx.TileMap map;

  void _setupEvents() {
    EntityManager.onChanged.listen((entityEvent) {
      var entity = entityEvent.entity;
      _send(_makeCommand('update_entity', {
        // FIXME: send the rest of the 'changed' attributes
        'entity_id': entity.id,
        'tile_gids': entity[TileGraphics].tileGids
      }));
    });

    EntityManager.onHidden.listen((entityEvent) {
      var entity = entityEvent.entity;
      _queueCommand('remove_entity', { 'entity_id': entity.id });
    });

    Entity.onEmitNear.listen((emitEvent) => _emitNear(emitEvent.entity, emitEvent.text));

    gameStream.listen((ge) => log.info("Received Event: $ge"));
    subscribe('intent', handlePlayerIntent());
    subscribe('get_gamestate', (ge) => _sendGamestate(ge.gameConnection));
  }

  // Handle a player intent
  handlePlayerIntent() {
    return (GameEvent ge) {
      var intentName = ge.payload['intent_name'];
      var intent = new Intent(intentName)
        ..invokingEntityId = ge.gameConnection.entity.id
        ..targetEntityId = ge.payload['target_entity_id']
        ..withEntityId = ge.payload['with_entity_id']
        ..actionName = ge.payload['action_name'];
      intentSystem.intentQueue.add(intent);
    };
  }
  // Handle an action invoked by the player
  handlePlayerAction(Type actionType) {
    return (GameEvent ge) {
      var actioneer = findEntity(ge.payload['with_entity_id']);
      if (actioneer == null) { actioneer = ge.gameConnection.entity; }
      var target = findEntity(ge.payload['entity_id']);

      Action action = reflectClass(actionType).newInstance(new Symbol(''), [actioneer, target]).reflectee;
      action.options = ge.payload;
      action.execute();
    };
  }

  void _setupSystems() {
    intentSystem.register('MOVE_N', moveIntentSystem);
    intentSystem.register('MOVE_S', moveIntentSystem);
    intentSystem.register('MOVE_E', moveIntentSystem);
    intentSystem.register('MOVE_W', moveIntentSystem);

    intentSystem.register('LOOK', lookIntentSystem);
    intentSystem.register('PICKUP', pickupIntentSystem);
    intentSystem.register('INTERACT', interactIntentSystem);
  }

  void start() {
    // TODO: make sure these run in order.
    log.info('loading map');
    _loadMap();

    log.info('listening for game events');
    _setupEvents();

    log.info('setting up systems');
    _setupSystems();

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
    Entity player = trackEntity(buildEntity('human')..attach(new Player()));

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
        'tile_gids': tgs.tileGids,
    }));

    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      var gc = new GameConnection(ws, player);
      gameConnections.add(gc);

      player.onEmit.listen((emitEvent) => _emitTo(emitEvent.text, gc));

      ws.listen((data) => _handleWebSocketMessage(data, ws),
        onDone: () => _removeConnection(gc));
      _sendGamestate(gc);
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

  void _emit(String text) {
    _send(_makeCommand('emit', { 'text': text }));
  }

  void _emitNear(Entity entity, String text) {
    _emit(text);
  }

  void _emitTo(String text, GameConnection gc) {
    _sendTo(_makeCommand('emit', { 'text': text }),
        [gc]);
  }

  void _sendGamestate(GameConnection gc) {
    var payload = [];
    entitiesWithComponents([TileGraphics, Position]).forEach( (entity) {
      payload.add(_makeCommand('create_entity', {
          'x': entity[Position].x,
          'y': entity[Position].y,
          'z': entity[Position].z,
          'tile_gids': entity[TileGraphics].tileGids,
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

  void _queueCommand(String type, Map payload) {
    commandQueue.add(_makeCommand(type, payload));
  }

  _executeSystems() {
    intentSystem.execute();
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