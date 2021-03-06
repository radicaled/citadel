library citadel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'package:yaml/yaml.dart';
import 'package:logging/logging.dart' as logging;
import 'package:tmx/tmx.dart' as tmx;
import 'package:route/server.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/core.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:citadel/game/entities.dart';
import 'package:citadel/game/animations.dart';
import 'package:citadel/game/intents.dart';
import 'package:citadel/game/systems.dart';
import 'package:citadel/game/world.dart';
import 'package:citadel/citadel_network/citadel_network.dart';
import 'package:citadel/citadel_network/server.dart';

import 'src/components.dart';
import 'src/entities.dart';


// Component Systems
part 'src/systems/collision_system.dart';
part 'src/systems/movement_system.dart';
part 'src/systems/pickup_intent_system.dart';
part 'src/systems/animations/animation_system.dart';
part 'src/systems/container_system.dart';
part 'src/systems/openable_system.dart';

// Intent systems
part 'src/systems/intent_system.dart';
part 'src/systems/move_intent_system.dart';
part 'src/systems/look_intent_system.dart';
part 'src/systems/interact_intent_system.dart';
part 'src/systems/harm_intent_system.dart';
part 'src/systems/speak_intent_system.dart';

// Generic systems
part 'src/systems/animations/animation_callback_system.dart';

// Event systems
part 'src/systems/animations/animation_sync_system.dart';

// Events
part 'src/events/login_event.dart';

part 'src/entity_utils.dart';

// misc
part 'src/game_connection.dart';
part 'src/tile_manager.dart';
part 'src/asset_manager.dart';


// Animation Stuff?
part 'src/animation/animation_timer.dart';

// Player stuff?
part 'src/player/player_spawner.dart';

final logging.Logger log = new logging.Logger('CitadelServer')
  ..onRecord.listen((logging.LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

List<Map> commandQueue = new List<Map>();

final loginUrl = '/login';
final wsGameUrl = '/ws/game';
int currentEntityId = 1;

final world = new World(entityParser);

Map _makeCommand(String type, payload) {
  return { 'type': type, 'payload': payload };
}


Entity trackEntity(Entity e) {
  e.id = currentEntityId++;
  world.entities.add(e);
  return e;
}

IntentSystem intentSystem = new IntentSystem();
AssetManager assetManager;

class CitadelServer {
  tmx.TileMap map;
  ServerNetworkHub hub = new ServerNetworkHub();

  void _setupEvents() {
    EntityManager.onChanged.listen((entityEvent) {
      var entity = entityEvent.entity;
      hub
        ..custom('update_entity', {
          // FIXME: send the rest of the 'changed' attributes
          'entity_id': entity.id,
          'tile_phrases': entity[TileGraphics].tilePhrases
        })
        ..broadcast();
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

    hub.masterStream.listen((ge) => log.info("Received Event: $ge"));
    hub.onLogin.listen(_loginPlayer);
    hub.onIntent.map(_parsePlayerIntent).listen(intentSystem.intentQueue.add);
    hub.on('get_gamestate').listen((ge) => _sendGamestate(ge.connection));
    hub.on('get_actions').listen(_sendActions);
  }

  // Parse player intents
  Intent _parsePlayerIntent(ClientMessage ce) {
    var intentName = ce.payload['intent_name'];
    return new Intent(intentName)
      ..invokingEntityId = (ce.connection as GameConnection).entity.id
      ..targetEntityId = ce.payload['target_entity_id']
      ..withEntityId = ce.payload['with_entity_id']
      ..actionName = ce.payload['action_name']
      ..details.addAll(ce.payload['details'] != null ? ce.payload['details'] : {});
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

    world.entitySystems.addAll([
        new CollisionSystem(),
        new MovementSystem(),
        new ContainerSystem(),
        new OpenableSystem(),
        // Should always be last
        new AnimationSystem(assetManager, hub)
    ]);

    world.eventSystems.addAll([
        new AnimationSyncSystem(hub),
    ]);

    world.genericSystems.addAll([
        new AnimationCallbackSystem(),
    ]);
  }

  void start() {
    // TODO: make sure these run in order.
    log.info('loading assets');
    _loadAssets();

    log.info('loading map');
    _loadMap();



    log.info('listening for game events');
    _setupEvents();

    log.info('setting up systems');
    _setupSystems();

    log.info('starting server');
    _startLoop();
    _startServer();

    log.info('Server started');
  }

  _loadAssets() {
    assetManager = new AssetManager();
    assetManager.loadAnimations('packages/citadel/assets/animations');
    assetManager.loadEntities('packages/citadel/assets/entities');
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
            var entity = world.fetchEntity(entityType);
            entity[Position].x = x;
            entity[Position].y = y;
            entity[Position].z = z;
            entity[TileGraphics].tilePhrases = ["${tile.tileset.name}|${tile.tileId}"];
            entity.attachComponent(new Visible());
            trackEntity(entity);
          }
        });
      });
      // Locate spawn zones
      world.attributes.putIfAbsent('spawn_zones', () => new List());
      map.objectGroups.expand((og) => og.tmxObjects).where((to) => to.type == 'spawn_zone').forEach((to) {
        var spawnZones = world.attributes['spawn_zones'];
        spawnZones.add({
            'x': to.x ~/ 32,
            'y': to.y ~/ 32,
            'width': to.width ~/ 32,
            'height': to.height ~/ 32
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
    WebSocketTransformer.upgrade(req).then((WebSocket ws) {
      var gc = new GameConnection(ws, null);
      hub.addConnection(gc);
      _sendAssets(gc);
      ws.done.then((_) => _removeConnection(gc));
    });
  }

  void _loginPlayer(ClientMessage ce) {
    var player = new PlayerSpawner(world).spawnPlayer();
    trackEntity(player);

    player.use(Name, (name) => name.text = ce.payload['name']);
    (ce.connection as GameConnection).entity = player;

    world.onEmit.where((ee) => ee.toEntity == player).listen((emitEvent) => _emitTo(emitEvent.message, ce.connection));

    _sendCreateEntity(player);
    _sendGamestate(ce.connection);
    _followEntity(player.id, ce.connection);
//    _sendAssets(ce.connection);
    world.messages.add(new LoginEvent(ce.connection));
  }

  _removeConnection(GameConnection ge) {
    hub.removeConnection(ge);
    if (ge.entity != null) {
      world.entities.remove(ge.entity);
      _queueCommand('remove_entity', {
          'entity_id': ge.entity.id
      });
    }
  }

  void _emit(String text) {
    hub..custom('emit', { 'text': text })..broadcast();
  }

  void _emitNear(Entity entity, String text) {
    _emit(text);
  }

  void _emitTo(String text, GameConnection gc) {
    hub..custom('emit', { 'text': text })..send(gc);
  }

  void _sendCreateEntity(Entity entity) {
    var pos = entity[Position];
    var tgs = entity[TileGraphics];

    hub
      ..custom('create_entity', {
        'x': pos.x,
        'y': pos.y,
        'z': pos.z,
        'entity_id': entity.id,
        'tile_phrases': tgs.tilePhrases,
      })
      ..broadcast();
  }

  void _sendGamestate(GameConnection gc) {
    entitiesWithComponents([Visible, TileGraphics, Position]).forEach( (entity) {
      hub.createEntity(entity.id,
        x: entity[Position].x,
        y: entity[Position].y,
        z: entity[Position].z,
        tilePhrases: entity[TileGraphics].tilePhrases,
        name: entity[Name] != null ? entity[Name].text : 'Something'
      );
    });
    hub.send(gc);
  }

  void _followEntity(int entityId, GameConnection gc) {
    hub
      ..followEntity(entityId)
      ..send(gc);
  }

  void _sendAssets(GameConnection gc) {
    var animationUrls = assetManager.animationUrls.toList();
    hub
      ..loadAssets(animationUrls: animationUrls)
      ..send(gc);
  }

  void _sendActions(ClientMessage ce) {
    var entity = findEntity(ce.payload['entity_id']);
    hub // FIXME: hardcoded
      ..custom('set_actions', { 'entity_id': entity.id, 'actions': [] })
      ..send(ce.connection);
  }

  void _queueCommand(String type, Map payload) {
    commandQueue.add(_makeCommand(type, payload));
  }

  _executeSystems() {
    intentSystem.execute();
    world.process();

    EntityManager.clearMessages();

  }

  _processCommands() {
    commandQueue.forEach((Map cmd) {
      hub
        ..custom(cmd['type'], cmd['payload'])
        ..broadcast();
    });

    commandQueue.clear();
  }
}
