import 'dart:html';
import 'dart:async';
import 'package:citadel/tilemap.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;
import 'package:json/json.dart' as json;

tmx.Tilemap tilemap;
Stage stage;
Sprite guy = new Sprite();
WebSocket ws;

void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage('Test Stage', canvas);
  stage.focus = stage;

  stage.onKeyDown.listen( (key) {
    print('key event?');
  });

  stage.onMouseClick.listen( (click) {
    print('mouse clicked?');
  });

  canvas.onKeyPress.listen( (ke) {
    print("got ${ke.keyCode}");
    // a = 97
    // d = 100
    // s = 115
    // w = 119
    switch(ke.keyCode){
      case 97:
        guy.x -= 32;
        movePlayer('W');
        break;
      case 100:
        guy.x += 32;
        movePlayer('E');
        break;
      case 115:
        guy.y += 32;
        movePlayer('S');
        break;
      case 119:
        guy.y -= 32;
        movePlayer('N');
        break;
    }

  });

  var renderLoop = new RenderLoop();

  renderLoop.addStage(stage);

  tilemap = new tmx.Tilemap(_inflateZlib);

  var url = "http://127.0.0.1:3030/citadel/assets/maps/shit_station-1.tmx";

  // call the web server asynchronously
  var request = HttpRequest.getString(url).then(parseMap);
  initWebSocket();
}

void movePlayer(direction) {
  send('move', { 'direction': direction });
}

void send(type, payload) {
  ws.send(json.stringify({ 'type': type, 'payload': payload }));
}
void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;
  ws = new WebSocket('ws://127.0.0.1:8000/ws');

  print("Connecting to websocket");


  void scheduleReconnect() {
    if (!reconnectScheduled) {
      new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
    }
    reconnectScheduled = true;
  }

  ws.onOpen.listen((e) {
    print('Connected');
    //ws.send('Hello from Dart!');
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
  });

}

// TODO: I forgot what the Uint8 type is in JS. Uint8?
List<int> _inflateZlib(List<int> bytes) {
  var zlib = new js.Proxy(js.context.Zlib.Inflate, js.array(bytes));
  return zlib.decompress();
}

parseMap(String xml) {
  var map = tilemap.loadMap(xml);
  renderMap(map);
}

renderMap(tmx.Map map) {
  var resourceManager = new ResourceManager();

  map.tilesets.forEach( (tileset) {
    var image = tileset.images.first;

    // Welcome to 2013: where they still make languages without RegExp literals.
    var pattern = new RegExp(r"^\.\.");
    var imagePath = image.source.splitMapJoin(pattern, onMatch: (m) => "../assets");

    resourceManager.addBitmapData(tileset.name, imagePath);
  });

  resourceManager.load().then( (_) {
    map.layers.forEach( (layer) {
      var i = true;
      if (i) {
        layer.tiles.where( (tile) => !tile.isEmpty).forEach( (tile) {
          var bd = resourceManager.getBitmapData(tile.tileset.name);
          var ss = new SpriteSheet(bd, tile.width, tile.height);
          var sbd = ss.frameAt(tile.tileId - 1);
          var bitmap = new Bitmap(sbd);
          bitmap.x = tile.x;
          bitmap.y = tile.y;
          stage.addChild(bitmap);
        });
      }
    });
    var ss = new SpriteSheet(resourceManager.getBitmapData('Humans'), 32, 32);
    guy.addChild(new Bitmap(ss.frameAt(1)));
    stage.addChild(guy);
  });
}