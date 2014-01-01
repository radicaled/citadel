import 'dart:html';
import 'dart:async';
import 'package:tmx/tmx.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;
import 'package:json/json.dart' as json;

tmx.TileMapParser parser = new tmx.TileMapParser();
tmx.TileMap map;

Stage stage;
var resourceManager = new ResourceManager();
WebSocket ws;
int currentPlayerId;

Map<int, GameSprite> entities = new Map<int, GameSprite>();
void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage('Test Stage', canvas);
  stage.focus = stage;

  stage.onKeyDown.listen( (key) {
  });

  stage.onMouseClick.listen( (click) {
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

  var url = "http://127.0.0.1:3030/citadel/assets/maps/shit_station-1.tmx";

  // call the web server asynchronously
  //HttpRequest.getString(url).then((xml) {
  //  parseMap(xml);
  //  login().then((_) => initWebSocket());
  //});
  HttpRequest.getString(url)
    .then(parseMap)
    .then((_) => initWebSocket());

  //login().then((_) => initWebSocket());
  //initWebSocket();
}

void movePlayer(direction) {
  send('move', { 'direction': direction });
}

void send(type, payload) {
  ws.send(json.stringify({ 'type': type, 'payload': payload }));
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
    //ws.send(json.stringify({ 'type': 'get_gamestate' }));
  });

  ws.onClose.listen((e) {
    print('Websocket closed, retrying in $retrySeconds seconds');
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

Future parseMap(String xml) {
  map = parser.parse(xml);
  return renderMap(map);
}

Future renderMap(tmx.TileMap map) {
  map.tilesets.forEach( (tileset) {
    var image = tileset.images.first;

    // Welcome to 2013: where they still make languages without RegExp literals.
    var pattern = new RegExp(r"^\.\.");
    var imagePath = image.source.splitMapJoin(pattern, onMatch: (m) => "../assets");

    resourceManager.addBitmapData(tileset.name, imagePath);
  });

  return resourceManager.load().then( (_) {
    map.layers.forEach( (layer) {
      var i = false;
      if (i) {
        layer.tiles.where( (tile) => !tile.isEmpty).forEach( (tile) {
          var bd = resourceManager.getBitmapData(tile.tileset.name);
          var ss = new SpriteSheet(bd, tile.width, tile.height);
          var sbd = ss.frameAt(tile.tileId);
          var bitmap = new Bitmap(sbd);
          bitmap.x = tile.x;
          bitmap.y = tile.y;
          stage.addChild(bitmap);
        });
      }
    });
  });
}


void handleMessage(jsonString) {
  var msg = json.parse(jsonString);
  var payload = msg['payload'];

  switch (msg['type']) {
    case 'move_entity':
      _moveEntity(payload);
      break;
    case 'create_entity':
      _createEntity(payload);
      break;
    case 'remove_entity':
      _removeEntity(payload);
  }
}

// TODO: check to see if redundant entites have been created?
// EG, we already have an entity with ID=1, but now there are more?
void _createEntity(payload) {
  var s = new GameSprite();
  s.entityId = payload['entity_id'];
  s.x = payload['x'] * 32;
  s.y = payload['y'] * 32;

  (payload['tileGids'] as List).forEach((tileGid) {
    var tile = map.getTileByGID(tileGid);
    var ss = getSpriteSheet(tile.tileset);
    s.addChild(new Bitmap(ss.frameAt(tile.tileId)));
  });

  stage.addChild(s);

  entities[s.entityId] = s;
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

class GameSprite extends Sprite {
  int entityId;
}

SpriteSheet getSpriteSheet(tmx.Tileset ts) {
  return new SpriteSheet(resourceManager.getBitmapData(ts.name), ts.width, ts.height);
}