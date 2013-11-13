import 'dart:html';
import 'package:citadel/tilemap.dart';
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;


Tilemap tilemap;
var map;

void main() {
  var canvas = querySelector('#stage');
  var stage = new Stage('Test Stage', canvas);
  
  var renderLoop = new RenderLoop();
  
  renderLoop.addStage(stage);
  
  tilemap = new Tilemap(_inflateZlib);
  
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
  map = tilemap.loadMap(xml);
}