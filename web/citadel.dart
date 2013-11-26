import 'dart:html';
import 'package:citadel/tilemap.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;


tmx.Tilemap tilemap;
Stage stage;
void main() {
  var canvas = querySelector('#stage');
  stage = new Stage('Test Stage', canvas);

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
      var i = false;
      if (i) {
        layer.forEachTile( (tile) {
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
    var bd = resourceManager.getBitmapData('Humans');
    var frames = bd.sliceIntoFrames(32, 32);
    var first = new Bitmap(frames[4]);
    first.x = 12;
    first.y = 12;
    stage.addChild(first);
  });
}