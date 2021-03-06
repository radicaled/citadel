import 'dart:html' hide Rectangle;
import 'dart:async';
import 'dart:convert';
import 'package:tmx/tmx.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:citadel/citadel_client/citadel_client.dart' as c;
import 'package:citadel/citadel_network/citadel_network.dart';
import 'package:citadel/citadel_network/client.dart';
import 'package:citadel/game/animations.dart' as animations;

// Goddamn it, shut up, Dart.
// You've been telling me for 8 versions now query and queryAll are deprecated.
// Either remove them or STFU
final query = querySelector;
final queryAll = querySelectorAll;

tmx.TileMapParser parser = new tmx.TileMapParser();
tmx.TileMap map;

Stage stage;
Sprite gameLayer = new Sprite();
Sprite guiLayer = new Sprite();

var resourceManager = new ResourceManager();

int currentPlayerId;
// TODO: hacky.
c.GameSprite _currentTarget;
c.GameSprite get currentTarget => _currentTarget;
             set currentTarget(c.GameSprite gs) {
               if (currentTarget != null) {
                 _currentTarget.filters = [];
                 _currentTarget.refreshCache();
               }
               if (gs.selectable) {
                 _currentTarget = gs;

                 query('#container #looking-at')..innerHtml = ''
                  ..appendText('Looking at ${gs.entityId}')
                  ..append(new ImageElement(src: _bitmapDataToDataUri(gs.bitmapData)));
               }
             }

Map<int, c.GameSprite> entities = new Map<int, c.GameSprite>();
c.ContextMenu currentContextMenu;
int currentActionIndex = 0;
int leftHand, rightHand;

int _currentlySelectedInventoryEntityId;
int get currentlySelectedInventoryEntityId => _currentlySelectedInventoryEntityId;
    set currentlySelectedInventoryEntityId(int entityId) {
      query('#container #using').text = 'Using $entityId';
      _currentlySelectedInventoryEntityId = entityId;
      networkHub.getActions(entityId);
    }

ClientNetworkHub networkHub;

List<animations.AnimationSet> animationSets = [];

Future ready = new Future.value(true);

c.Camera camera;

void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage(canvas);
  stage.focus = stage;



  gameLayer.doubleClickEnabled = true;

  canvas.onContextMenu.listen((event) => event.preventDefault() );

  stage.onMouseRightClick.listen((event) {
    if (currentContextMenu != null) { currentContextMenu.dismiss(); }

    var hitX = event.stageX + (camera.transformationMatrix.tx * -1);
    var hitY = event.stageY + (camera.transformationMatrix.ty * -1);

    var cmis = entities.values
        .where((gs) => gs.hitTestPoint(hitX, hitY))
        .map((gs) => new c.ContextMenuItem(gs.name, gs) )
        .toList();

    currentContextMenu = new c.ContextMenu(stage, cmis)
      ..show(event.stageX, event.stageY);
  });

  stage.onMouseClick.listen((event) {
    if (currentContextMenu != null) {
      var cm = currentContextMenu;
      if(!cm.displayable.hitTestPoint(event.stageX, event.stageY, true)) {
        cm.dismiss();
        currentContextMenu = null;
      }
    } else {
      // There was no context menu to interact with; they were trying to click on an entity.
      var hitX = event.stageX + (camera.transformationMatrix.tx * -1);
      var hitY = event.stageY + (camera.transformationMatrix.ty * -1);
      var gs = gameLayer.hitTestInput(hitX, hitY);
      if (gs is c.GameSprite) {
        currentTarget = gs;
      }
    }

  });

  gameLayer.onMouseDoubleClick.listen((event) {
    if (currentContextMenu != null) { return; }
    var gs = stage.hitTestInput(event.stageX, event.stageY);
    if (gs is c.GameSprite) {
      networkHub.interactWith(gs.entityId, 'use', withEntityId: currentlySelectedInventoryEntityId);
    }
  });

  c.ContextMenu.onSelection.listen((cmi) {
    currentContextMenu.dismiss();
    currentContextMenu = null;

    currentTarget = cmi.value;

  });
  // FIXME: this entire damn thing.
  canvas.onKeyPress.listen( (ke) {
    // a = 97
    // d = 100
    // s = 115
    // w = 119
    switch(ke.keyCode){
      case 97:
        networkHub.move('MOVE_W');
        break;
      case 100:
        networkHub.move('MOVE_E');
        break;
      case 115:
        networkHub.move('MOVE_S');
        break;
      case 119:
        networkHub.move('MOVE_N');
        break;
    }
    if (ke.keyCode >= 48 && ke.keyCode <= 57) {
      var number = ke.keyCode - 48;
      if (number == 0) { number = 10; } // Keyboard is 1234567890, not 0123456789
    }

  });

  var renderLoop = new RenderLoop();

  renderLoop.addStage(stage);

  setupLayers(canvas.width, canvas.height);

  document.onReadyStateChange.first.then((_) {
    setupHtmlGuiEvents();
  });

  var loginWindow = new c.LoginWindow()
    ..show();

  loginWindow.onLogin.listen((me) {
    me.preventDefault();
    loginWindow.hide();

    var url = "packages/citadel/assets/maps/shit_station-1.tmx";
    HttpRequest.getString(url)
      .then(loadMap)
      .then((_) => initWebSocket())
      .then((_) => querySelector('#game-window').classes.remove('hidden'));
  });
}

void interactWith(entityId, actionName, {withEntityId}) {
  intent('INTERACT', targetEntityId: entityId, withEntityId: withEntityId, actionName: actionName);
}

void intent(intentName, {targetEntityId, withEntityId, actionName, Map details}) {
  var payload = {
                  'intent_name': intentName,
                  'target_entity_id': targetEntityId,
                  'with_entity_id': withEntityId,
                  'action_name': actionName,
                  'details': details
                };
  send('intent', payload);

}

void send(type, payload) {
  networkHub.send(type, payload);
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;
  print('Current Player ID: $currentPlayerId');
  var ws = new WebSocket('ws://127.0.0.1:8000/ws/game');

  print("Connecting to websocket");


  void scheduleReconnect() {
    if (!reconnectScheduled) {
      new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
    }
    reconnectScheduled = true;
  }

  ws.onOpen.listen((e) {
    _processChatMessage('You are now connected to the server!');
    querySelector('#ws-status').text = 'ONLINE';
    listenForEvents(ws, ws.onMessage);
    networkHub.login(querySelector('input[name="player-name"]').value);
  });

  ws.onClose.listen((e) {
    _processChatMessage('You have been disconnected.');
    querySelector('#ws-status').text = 'OFFLINE';
    scheduleReconnect();
  });

  ws.onError.listen((e) {
    print("Error connecting to ws");
    scheduleReconnect();
  });

}

void listenForEvents(WebSocket ws, Stream stream) {
  var transformer = new StreamTransformer.fromHandlers(handleData: (MessageEvent me, sink) {
    sink.add(me.data);
  });
  stream.listen((MessageEvent me) => print('Received message: ${me.data}'));
  networkHub = new ClientNetworkHub(stream.transform(transformer), ws.send);

  networkHub.onLoadAssets.listen(_loadAssets);
  networkHub.onAnimate.listen(_animate);

  networkHub.on('move_entity').listen(_moveEntity);
  networkHub.on('create_entity').listen(_createEntity);
  networkHub.on('update_entity').listen(_updateEntity);
  networkHub.on('remove_entity').listen(_removeEntity);
  networkHub.on('follow_entity').listen(_followEntity);
  networkHub.on('emit').listen(_emit);
  networkHub.on('picked_up').listen(_pickedUpEntity);
  networkHub.on('set_actions').listen(_setActions);
}

Future loadMap(String xml) {
  map = parser.parse(xml);

  map.tilesets.forEach( (tileset) {
    var image = tileset.images.first;

    // Welcome to 2013: where they still make languages without RegExp literals.
    var pattern = new RegExp(r"^\.\.");
    var imagePath = image.source.splitMapJoin(pattern, onMatch: (m) => "packages/citadel/assets");

    resourceManager.addBitmapData(tileset.name, imagePath);
  });

  return resourceManager.load();
}

void _emit(NetworkMessage message) {
  var msg = message.payload['text'];
  _processChatMessage(msg);
}

void _pickedUpEntity(NetworkMessage message) {
  var payload = message.payload;
  var entityId = payload['entity_id'];
  var hand = payload['hand'];

  // TODO: What are you holding?
  var entity = entities[entityId];


  var dataUri = _bitmapDataToDataUri(entity.bitmapData);

  var li = new Element.li()
    ..append(new ImageElement(src: dataUri))
    ..append(new Element.br())
    ..append(new Element.span()..text = entity.entityId.toString())
    ..append(new Element.br())
    ..dataset['entity-id'] = entity.entityId.toString();


  query('#currently-holding').append(li);
//  query('.selected-item-action-menu').classes.remove('hidden');

  _setupSelectedItemActions(entityId, payload['actions']);

  ['attack', 'throw', 'drop'].forEach((action) {
    // TODO: ??
  });
}

// TODO: check to see if redundant entites have been created?
// EG, we already have an entity with ID=1, but now there are more?
void _createEntity(NetworkMessage message) {
  var s = new c.GameSprite();
  var payload = message.payload;
  s.entityId = payload['entity_id'];
  s.name = payload['name'];
  s.x = payload['x'] * 32;
  s.y = payload['y'] * 32;

  (payload['tile_phrases'] as List).forEach((String tilePhrase) {
    var tile = map.getTileByPhrase(tilePhrase);
    var ss = getSpriteSheet(tile.tileset);
    s.bitmapData = ss.frameAt(tile.tileId);
    s.addChild(new Bitmap(s.bitmapData));
  });

  gameLayer.addChild(s);

  entities[s.entityId] = s;
}

void _updateEntity(NetworkMessage message) {
  var payload = message.payload;
  var gs = entities[payload['entity_id']];
  if (payload.containsKey('x')) { gs.x = payload['x']; }
  if (payload.containsKey('y')) { gs.x = payload['x']; }

  if (payload.containsKey('tile_phrases')) {
    gs.removeChildren();
    (payload['tile_phrases'] as List).forEach((tilePhrase) {
      var tile = map.getTileByPhrase(tilePhrase);
      var ss = getSpriteSheet(tile.tileset);
      gs.bitmapData = ss.frameAt(tile.tileId);
      gs.addChild(new Bitmap(gs.bitmapData));
    });
  }
}

void _followEntity(NetworkMessage message) {
  var gs = entities[message.payload['entity_id']];
  camera.follow(gs);
}

void _removeEntity(NetworkMessage message) {
  var payload = message.payload;
  var gs = entities.remove(payload['entity_id']);
  gs.removeFromParent();
}

void _moveEntity(NetworkMessage message) {
  var payload = message.payload;
  var entity = entities[payload['entity_id']];
  entity.x = payload['x'] * 32;
  entity.y = payload['y'] * 32;
}

void _animate(NetworkMessage message) {
  ready.then((_) {
    var entityId = message.payload['entity_id'];
    var animatioName = message.payload['animation_name'];
    var elapsed = message.payload['elapsed'];

    var entity = entities[entityId];
    var anim   = getAnimation(animatioName);
    var ss = getSpriteSheet(map.getTileset(anim.animationSet.tileset));

    stage.juggler.add(new c.SpriteAnimation(entity, anim, ss, elapsed: elapsed));
  });
}

animations.Animation getAnimation(String animationName) {
  var ns = animationName.split('|').first;
  var anim = animationName.split('|').last;
  var as = animationSets.firstWhere((as) => as.name == ns, orElse: () => throw 'AnimationSet not found: $animationName');
  var an = as.animations[anim];

  if (an == null) { throw 'Animation not found: $animationName'; }

  return an;
}

SpriteSheet getSpriteSheet(tmx.Tileset ts) {
  return new SpriteSheet(resourceManager.getBitmapData(ts.name), ts.width, ts.height);
}

void setupLayers(width, height) {
  stage.addChild(gameLayer);
  stage.addChild(guiLayer);

  var blackness = new Sprite();
  blackness.graphics
    ..rect(0, 0, 1000, 1000)
    ..fillColor(Color.Black);
  stage.addChild(blackness);

  camera = new c.Camera(gameLayer, new Rectangle(50, 50, 50, 50));
  camera.x = 0;
  camera.y = 0;
  stage.addChild(camera);
}

void setupHtmlGuiEvents() {
  var find = (String action) => query("#container #$action-action");

  find('look').onClick.listen((me) {
    if (currentTarget != null) {
      networkHub.look(currentTarget.entityId);
    }
    focusStage();
  });

  find('use').onClick.listen((me) {
    if (currentTarget != null) {
      networkHub.interactWith(currentTarget.entityId, 'use');
    }
    focusStage();
  });

  find('pickup').onClick.listen((me) {
    if (currentTarget != null) {
      networkHub.pickup(currentTarget.entityId);
    }
    focusStage();
  });

  find('attack').onClick.listen((me) {
    if (currentTarget != null) {
      networkHub.attack(currentTarget.entityId);
    }
    focusStage();
  });

  find('test').onClick.listen((me) {

  });

  query('#player-chat-input').onKeyPress.listen((ke) {
    if (ke.keyCode == 13) {
      networkHub.speak(ke.target.value);
      ke.target.value = '';
    }
  });

  query('#currently-holding').onClick.listen((e) {
    queryAll('#currently-holding li').forEach((n) => n.classes.remove('selected'));
    // Bullshit
    var parent = e.target.parent;
    if(parent is LIElement) {
      parent.classes.add('selected');

//      currentTarget = entities[int.parse(parent.dataset['entity-id'])];
      currentlySelectedInventoryEntityId = int.parse(parent.dataset['entity-id']);
    }
    focusStage();
  });
}

void _setActions(NetworkMessage message) {
  _setupSelectedItemActions(message.payload['entity_id'], message.payload['actions']);
}

void _loadAssets(NetworkMessage message) {
  List<String> animUrls = message.payload['animation_urls'];
  var futures = animUrls.map((url) {
    return HttpRequest.getString(url).then((data) {
      var animationSet = new animations.AnimationSet.fromJSON(JSON.decode(data));
      animationSets.add(animationSet);
    });
  });

  ready = ready.then((_) => Future.wait(futures));

}

_setupSelectedItemActions(int entityId, List actions) {
  if (actions == null) return;
  query('.selected-item-action-menu ul').innerHtml = '';
  actions.forEach((action) {
    var button = new ButtonElement()
      ..text = action;
    var li = new Element.li()
      ..append(button)
      ..onClick.listen((_) =>  networkHub.interactWith(currentTarget.entityId, action, withEntityId: entityId));

    query('.selected-item-action-menu').classes.remove('hidden');
    query('.selected-item-action-menu ul').append(li);
  });
}

_processChatMessage(String text) {
  querySelector('#log').appendHtml('<p>$text</p>');
  querySelector('#log p:last-child').scrollIntoView();
}

String _bitmapDataToDataUri(BitmapData bd) {
  CanvasElement canvas = query('#temp-canvas');
  var imageData = bd.renderTextureQuad.getImageData();
  canvas.context2D.putImageData(imageData, 0, 0);
  return canvas.toDataUrl('image/png');
}

focusStage() {
  var canvas = querySelector('#stage');
  canvas.focus();
}
