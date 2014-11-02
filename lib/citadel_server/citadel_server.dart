library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart' as logging;
import 'package:tmx/tmx.dart' as tmx;
import 'package:route/server.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'dart:io';
import 'dart:async';

import 'package:citadel/game/entities.dart';
import 'package:citadel/game/components.dart';
import 'package:citadel/game/intents.dart';
import 'package:citadel/game/world.dart';

import 'src/components.dart';
import 'src/entities.dart';



// Component Systems
part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';
part 'src/systems/pickup_intent_system.dart';
part 'src/systems/animation_system.dart';
part 'src/systems/animation_buffer_system.dart';
part 'src/systems/container_system.dart';
part 'src/systems/openable_system.dart';

// Intent systems
part 'src/systems/intent_system.dart';
part 'src/systems/move_intent_system.dart';
part 'src/systems/look_intent_system.dart';
part 'src/systems/interact_intent_system.dart';
part 'src/systems/harm_intent_system.dart';
part 'src/systems/speak_intent_system.dart';

part 'src/entity_utils.dart';

// misc
part 'src/events/game_event.dart';
part 'src/game_connection.dart';
part 'src/tile_manager.dart';
part 'src/helpers/animation_builder.dart';

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

final world = new World();

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
TileManager tileManager;

class CitadelServer {
  tmx.TileMap map;

  void _setupEvents() {
    EntityManager.onChanged.listen((entityEvent) {
      var entity = entityEvent.entity;
      _send(_makeCommand('update_entity', {
        // FIXME: send the rest of the 'changed' attributes
        'entity_id': entity.id,
        'tile_phrases': entity[TileGraphics].tilePhrases
      }));
    });

    EntityManager.onHidden.listen((entityEvent) {
      var entity = entityEvent.entity;
      _queueCommand('remove_entity', { 'entity_id': entity.id });
    });

    EntityManager.onCreated.listen((entityEvent) {
      var entity = entityEvent.entity;
      _queueCommand('create_entity', {
        'x': entity[Position].x,
        'y': entity[Position].y,
        'z': entity[Position].z,
        'tile_phrases': entity[TileGraphics].tilePhrases,
        'entity_id': entity.id,
        'name': entity[Name] != null ? entity[Name].text : 'Something'
      });
    });


    world.onEmit
      .where((emitEvent) => emitEvent.nearEntity != null)
      .listen((emitEvent) => _emitNear(emitEvent.nearEntity, emitEvent.message));

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
        ..actionName = ge.payload['action_name']
        ..details.addAll(ge.payload['details'] ? ge.payload['details'] : {});
      intentSystem.intentQueue.add(intent);
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

    intentSystem.register('ATTACK', harmIntentSystem);

    intentSystem.register('SPEAK', speakIntentSystem);
  }

  void start() {
    // TODO: make sure these run in order.
    log.info('loading map');
    _loadMap();

    log.info('loading tile information');
    _loadTiles();

    log.info('listening for game events');
    _setupEvents();

    log.info('setting up systems');
    _setupSystems();

    log.info('starting server');
    _startLoop();
    _startServer();

    log.info('Server started');
  }

  _loadTiles() {
    tileManager = new TileManager('packages/citadel/config/tiles');
    tileManager.load();
  }

  _loadMap() {
    var parser = new tmx.TileMapParser();
    new File('packages/citadel/assets/maps/shit_station-1.tmx').readAsString().then((xml) {
      map = parser.parse(xml);
      int z = -1;
      map.layers.forEach( (tmx.Layer layer) {
        z++;
        layer.tiles.forEach( (tmx.Tile tile) {
          int x = tile.x ~/ 32;
          int y = tile.y ~/ 32;

          if (!tile.isEmpty) {
            var entityType = [
                              tile.properties['entity'],
                              tile.tileset.properties['entity'],
                              'placeholder'
                             ].firstWhere((et) => et != null);
            var entity = buildEntity(entityType, world);
            entity[Position].x = x;
            entity[Position].y = y;
            entity[Position].z = z;
            entity[TileGraphics].tilePhrases = ["${tile.tileset.name}|${tile.tileId}"];
            entity.attach(new Visible());
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
    Entity player = trackEntity(buildEntity('human', world)..attach(new Player()));

    Position pos = player[Position];
    TileGraphics tgs = player[TileGraphics];
    pos
      ..x = 8
      ..y = 8
      ..z = 16;
    tgs.tilePhrases = ['Humans|1'];

    _send(_makeCommand('create_entity', {
        'x': pos.x,
        'y': pos.y,
        'z': pos.z,
        'entity_id': player.id,
        'tile_phrases': tgs.tilePhrases,
    }));
    player.attach(new Visible());

    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      var gc = new GameConnection(ws, player);
      gameConnections.add(gc);

      world.onEmit.where((ee) => ee.toEntity == player).listen((emitEvent) => _emitTo(emitEvent.message, gc));

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
    var messages = [];
    var payload = { 'messages': messages };
    entitiesWithComponents([Visible, TileGraphics, Position]).forEach( (entity) {
      messages.add(_makeCommand('create_entity', {
          'x': entity[Position].x,
          'y': entity[Position].y,
          'z': entity[Position].z,
          'tile_phrases': entity[TileGraphics].tilePhrases,
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
    openableSystem();
    containerSystem();

    // Should always be last.
    animationBufferSystem();
    animationSystem();

    EntityManager.clearMessages();

  }

  _processCommands() {
    commandQueue.forEach((Map cmd) {
      _send(cmd);
    });

    commandQueue.clear();
  }
}
