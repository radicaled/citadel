import 'dart:html';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'package:tmx/tmx.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;
import 'package:citadel/citadel_client/citadel_client.dart' as c;
import 'package:citadel/citadel_network/citadel_network.dart';

tmx.TileMapParser parser = new tmx.TileMapParser();
tmx.TileMap map;

Stage stage;
Sprite gameLayer = new Sprite();
Sprite guiLayer = new Sprite();

var resourceManager = new ResourceManager();
WebSocket ws;
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

                 _currentTarget.filters.add(new ColorMatrixFilter.invert());
                 _currentTarget.applyCache(0, 0, gs.width.toInt(), gs.height.toInt());
                 // ... hm. Are my tiles too close together?
                 //currentTarget.shadow = new Shadow(Color.Yellow, 0, 0, 10.0);
                 query('#container #looking-at').text = 'Looking at ${gs.entityId}';
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
    }

NetworkHub networkHub;

void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage(canvas);
  stage.focus = stage;

  canvas.onContextMenu.listen((event) => event.preventDefault() );

  stage.onMouseRightClick.listen((event) {
    if (currentContextMenu != null) { currentContextMenu.dismiss(); }
    var cmis = entities.values
        .where((gs) => gs.hitTestPoint(event.stageX, event.stageY))
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
      var gs = stage.hitTestInput(event.stageX, event.stageY);
      if (gs is c.GameSprite) {
        currentTarget = gs;
      }
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
        movePlayer('MOVE_W');
        break;
      case 100:
        movePlayer('MOVE_E');
        break;
      case 115:
        movePlayer('MOVE_S');
        break;
      case 119:
        movePlayer('MOVE_N');
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

  var url = "packages/citadel/assets/maps/shit_station-1.tmx";
  HttpRequest.getString(url)
    .then(loadMap)
    .then((_) => initWebSocket());
}

void movePlayer(direction) {
  intent(direction);
}
// FIXME: this should be an interaction, right?
void pickupEntity(entityId) {
  intent('PICKUP', targetEntityId: entityId);
}
// FIXME: this should be an interaction, right?
void lookEntity(entityId) {
  intent('LOOK', targetEntityId: entityId);
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
  ws.send(JSON.encode({ 'type': type, 'payload': payload }));
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;
  print('Current Player ID: $currentPlayerId');
  ws = new WebSocket('ws://127.0.0.1:8000/ws/game');

  print("Connecting to websocket");


  void scheduleReconnect() {
    if (!reconnectScheduled) {
      new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
    }
    reconnectScheduled = true;
  }

  ws.onOpen.listen((e) {
    print('Connected');
    querySelector('#ws-status').text = 'ONLINE';
    listenForEvents(ws.onMessage);
  });

  ws.onClose.listen((e) {
    print('Websocket closed, retrying in $retrySeconds seconds');
    querySelector('#ws-status').text = 'OFFLINE';
    scheduleReconnect();
  });

  ws.onError.listen((e) {
    print("Error connecting to ws");
    scheduleReconnect();
  });

  ws.onMessage.listen((MessageEvent e) {

  });

}

void listenForEvents(Stream stream) {
  var transformer = new StreamTransformer.fromHandlers(handleData: (MessageEvent me, sink) {
    sink.add(me.data);
  });
  stream.listen((MessageEvent me) => print('Received message: ${me.data}'));
  networkHub = new NetworkHub(stream.transform(transformer));

  networkHub.on('move_entity').listen(_moveEntity);
  networkHub.on('create_entity').listen(_createEntity);
  networkHub.on('update_entity').listen(_updateEntity);
  networkHub.on('remove_entity').listen(_removeEntity);
  networkHub.on('emit').listen(_emit);
  networkHub.on('picked_up').listen(_pickedUpEntity);
}

// TODO: I forgot what the Uint8 type is in JS. Uint8?
List<int> _inflateZlib(List<int> bytes) {
  var zlib = new js.Proxy(js.context.Zlib.Inflate, js.array(bytes));
  return zlib.decompress();
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

void _emit(Message message) {
  var payload = message.payload;
  querySelector('#log').appendHtml('<p>${payload['text']}');
  querySelector('#log p:last-child').scrollIntoView();
}

void _pickedUpEntity(Message message) {
  var payload = message.payload;
  var entityId = payload['entity_id'];
  var hand = payload['hand'];

  // TODO: What are you holding?
  var entity = entities[entityId];

  CanvasElement canvas = query('#temp-canvas');
  var imageData = entity.bitmapData.renderTextureQuad.getImageData();

  canvas.context2D.putImageData(imageData, 0, 0);
  var dataUri = canvas.toDataUrl('image/png');

  var li = new Element.li()
    ..append(new ImageElement(src: dataUri))
    ..append(new Element.br())
    ..append(new Element.span()..text = entity.entityId.toString())
    ..append(new Element.br())
    ..dataset['entity-id'] = entity.entityId.toString();


  query('#currently-holding').append(li);


  payload['actions'].forEach((action) {
    // TODO: ??
  });
  ['attack', 'throw', 'drop'].forEach((action) {
    // TODO: ??
  });
}

// TODO: check to see if redundant entites have been created?
// EG, we already have an entity with ID=1, but now there are more?
void _createEntity(Message message) {
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

void _updateEntity(Message message) {
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

void _removeEntity(Message message) {
  var payload = message.payload;
  var gs = entities.remove(payload['entity_id']);
  gs.removeFromParent();
}

void _moveEntity(Message message) {
  var payload = message.payload;
  var entity = entities[payload['entity_id']];
  entity.x = payload['x'] * 32;
  entity.y = payload['y'] * 32;
}

void speak(String text) {
  intent('SPEAK', details: { 'text': text });
}

SpriteSheet getSpriteSheet(tmx.Tileset ts) {
  return new SpriteSheet(resourceManager.getBitmapData(ts.name), ts.width, ts.height);
}

void setupLayers(width, height) {
  stage.addChild(gameLayer);
  stage.addChild(guiLayer);
}

void setupHtmlGuiEvents() {
  var find = (String action) => query("#container #$action-action");

  find('look').onClick.listen((me) {
    if (currentTarget != null) {
      lookEntity(currentTarget.entityId);
    }
  });

  find('use').onClick.listen((me) {
    if (currentTarget != null) {
      interactWith(currentTarget.entityId, 'use');
    }
  });

  find('pickup').onClick.listen((me) {
    if (currentTarget != null) {
      pickupEntity(currentTarget.entityId);
    }
  });

  find('attack').onClick.listen((me) {
    if (currentTarget != null) {
      intent('ATTACK', targetEntityId: currentTarget.entityId);
    }
  });

  query('#player-chat-input').onKeyPress.listen((ke) {
    if (ke.keyCode == 13) {
      speak(ke.target.value);
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
  });
}
