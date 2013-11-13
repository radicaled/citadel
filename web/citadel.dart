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
  
  var url = "http://127.0.0.1:3030/citadel/test/fixtures/test.tmx";

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
  
  //resourceManager.load();
  resourceManager.load().then( (_) {
    var basketball = new Bitmap(resourceManager.getBitmapData('basketball'));
    stage.addChild(basketball);
  });
}