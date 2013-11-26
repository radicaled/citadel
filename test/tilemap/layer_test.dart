import 'package:unittest/unittest.dart';
import 'package:citadel/tilemap.dart';
import 'dart:io';

main() {
  var inflateZlib = (List<int> bytes) => new ZLibDecoder().convert(bytes);
  var parser = new Parser(inflateZlib);
  var map, layer;

  // Urgh. var xml = File.read(/* ... */); >:/
  setUp( () {
    return new File('../fixtures/test.tmx').readAsString().then((xml) {
      map = parser.parse(xml);
      layer = map.layers.first;
    });
  });

  group('Layer.forEachTile', () {

    test('executes a function once for each tile (EX: 100)', () {
      // Oh, RSpec for Dart, where are you?
      // test.tmx: 10 * 10 == 100
      var timesCalled = 0;
      layer.forEachTile( (tile) => timesCalled = timesCalled + 1);
      expect(timesCalled, equals(100));
    });

    test('calculates the x and y correctly for every tile', () {
      var coords = [];
      var expectedCoords = [];

      layer.forEachTile( (tile) => coords.add([tile.x, tile.y]));
      // Tileset is 32x32 in test.tmx, and the map is 10x10.
      for(var y = 0; y < 10; y++) {
        for(var x = 0; x < 10; x++) {
          expectedCoords.add([x * 32, y * 32]);
        }
      }

      expect(coords, equals(expectedCoords));
    });
  });
}