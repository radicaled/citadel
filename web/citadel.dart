import 'dart:html';
import 'package:citadel/tilemap.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;


tmx.Tilemap tilemap;
Stage stage;
Sprite guy = new Sprite();

void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage('Test Stage', canvas);

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
        break;
      case 100:
        guy.x += 32;
        break;
      case 115:
        guy.y += 32;
        break;
      case 119:
        guy.y -= 32;
        break;
    }

  });

  var renderLoop = new RenderLoop();

  renderLoop.addStage(stage);

  tilemap = new tmx.Tilemap(_inflateZlib);

  var url = "http://127.0.0.1:3030/citadel/assets/maps/shit_station-1.tmx";

  // call the web server asynchronously
  var request = HttpRequest.getString(url).then(parseMap);
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