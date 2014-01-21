import 'dart:html';
import 'dart:async';
import 'package:tmx/tmx.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;
import 'package:json/json.dart' as json;
import 'package:citadel/citadel_client/citadel_client.dart' as c;

tmx.TileMapParser parser = new tmx.TileMapParser();
tmx.TileMap map;

Stage stage;
var resourceManager = new ResourceManager();
WebSocket ws;
int currentPlayerId;

Map<int, c.GameSprite> entities = new Map<int, c.GameSprite>();
c.ContextMenu currentContextMenu;
void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage('Test Stage', canvas);
  stage.focus = stage;

  canvas.onContextMenu.listen((event) => event.preventDefault() );

  stage.onMouseRightClick.listen((event) {
    if (currentContextMenu != null) { currentContextMenu.dismiss(); }
    var cmis = entities.values
        .where((gs) => gs.hitTestPoint(event.stageX, event.stageY))
        .map((gs) => new c.ContextMenuItem(gs.name, gs.entityId) )
        .toList();

    currentContextMenu = new c.ContextMenu(stage, cmis)
      ..show(event.stageX, event.stageY);
  });

  stage.onMouseClick.listen((event) {
    if (currentContextMenu != null) {
      var cm = currentContextMenu;
      if(!cm.displayable.hitTestPoint(event.stageX, event.stageY, true)) {
        cm.dismiss();
      }
    } else {
      // There was no context menu to interact with; they were trying to click on an entity.
      var gs = stage.hitTestInput(event.stageX, event.stageY);
      if (gs is c.GameSprite) {
        print('Tried to interact with ${gs.entityId} / ${gs.name}');
        interactWith(gs.entityId, 'use');
      }
    }

  });

  c.ContextMenu.onSelection.listen((cmi) {
    currentContextMenu.dismiss();
    print('Selected ${cmi.name} with value ${cmi.value}');
    // TODO: just looking for now.
    lookEntity(cmi.value);
  });

  canvas.onKeyPress.listen( (ke) {
    // a = 97
    // d = 100
    // s = 115
    // w = 119
    switch(ke.keyCode){
      case 97:
        movePlayer('W');
        break;
      case 100:
        movePlayer('E');
        break;
      case 115:
        movePlayer('S');
        break;
      case 119:
        movePlayer('N');
        break;
    }

  });

  var renderLoop = new RenderLoop();

  renderLoop.addStage(stage);

  var url = "//${window.location.host}/citadel/assets/maps/shit_station-1.tmx";

  // call the web server asynchronously
  //HttpRequest.getString(url).then((xml) {
  //  parseMap(xml);
  //  login().then((_) => initWebSocket());
  //});
  HttpRequest.getString(url)
    .then(loadMap)
    .then((_) => initWebSocket());

  //login().then((_) => initWebSocket());
  //initWebSocket();
}

void movePlayer(direction) {
  send('move', { 'direction': direction });
}

void lookEntity(entityId) {
  send('look_at', { 'entity_id': entityId });
}

void send(type, payload) {
  ws.send(json.stringify({ 'type': type, 'payload': payload }));
}

void interactWith(entityId, action_name) {
  send('interact', { 'entity_id': entityId, 'action_name': action_name });
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
    //ws.send(json.stringify({ 'type': 'get_gamestate' }));
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
    print('Received message: ${e.data}');
    handleMessage(e.data);
  });

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
    var imagePath = image.source.splitMapJoin(pattern, onMatch: (m) => "../assets");

    resourceManager.addBitmapData(tileset.name, imagePath);
  });

  return resourceManager.load();
}

void handleMessage(jsonString) {
  var msg = json.parse(jsonString);
  executeMessage(msg['type'], msg['payload']);
}

void executeMessage(type, payload) {
  switch (type) {
    case 'move_entity':
      _moveEntity(payload);
      break;
    case 'create_entity':
      _createEntity(payload);
      break;
    case 'update_entity':
      _updateEntity(payload);
      break;
    case 'remove_entity':
      _removeEntity(payload);
      break;
    case 'set_gamestate':
      payload.forEach((submessage) => executeMessage(submessage['type'], submessage['payload']));
      break;
    case 'emit':
      querySelector('#log').appendHtml('<p>${payload['text']}');
      break;
  }
}

// TODO: check to see if redundant entites have been created?
// EG, we already have an entity with ID=1, but now there are more?
void _createEntity(payload) {
  var s = new c.GameSprite();
  s.entityId = payload['entity_id'];
  s.name = payload['name'];
  s.x = payload['x'] * 32;
  s.y = payload['y'] * 32;

  (payload['tile_gids'] as List).forEach((tileGid) {
    var tile = map.getTileByGID(tileGid);
    var ss = getSpriteSheet(tile.tileset);
    s.addChild(new Bitmap(ss.frameAt(tile.tileId)));
  });

  stage.addChild(s);

  entities[s.entityId] = s;
}

void _updateEntity(Map payload) {
  var gs = entities[payload['entity_id']];
  if (payload.containsKey('x')) { gs.x = payload['x']; }
  if (payload.containsKey('y')) { gs.x = payload['x']; }

  if (payload.containsKey('tile_gids')) {
    gs.removeChildren();
    (payload['tile_gids'] as List).forEach((tileGid) {
      var tile = map.getTileByGID(tileGid);
      var ss = getSpriteSheet(tile.tileset);
      gs.addChild(new Bitmap(ss.frameAt(tile.tileId)));
    });
  }
}

void _removeEntity(payload) {
  var gs = entities.remove(payload['entity_id']);
  gs.removeFromParent();
}

void _moveEntity(payload) {
  var entity = entities[payload['entity_id']];
  entity.x = payload['x'] * 32;
  entity.y = payload['y'] * 32;
}

SpriteSheet getSpriteSheet(tmx.Tileset ts) {
  return new SpriteSheet(resourceManager.getBitmapData(ts.name), ts.width, ts.height);
}