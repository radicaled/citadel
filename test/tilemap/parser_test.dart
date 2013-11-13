import 'package:unittest/unittest.dart';
import 'package:citadel/tilemap.dart';
import 'dart:io';

main() {
  var inflateZlib = (List<int> bytes) => new ZLibDecoder().convert(bytes);
  var parser = new Parser(inflateZlib);
  
  test('Parser.parse raises an error when the XML is not in TMX format', () {
    var wrongXml = '<xml></xml>';

    expect( ()=> parser.parse(wrongXml),
        throwsA('XML is not in TMX format'));
  });

  test('Parser.parse returns a Map object', () {
    var xml = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <map>
      </map>      
    ''';
    var map = parser.parse(xml);

    expect(map, new isInstanceOf<Map>());
  });

  group('Parser.parse populates Map with tilesets', () {
    var xml = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <map>
        <tileset firstgid="1" name="Humans" tilewidth="64" tileheight="32">
          <image source="../icons/mob/human.png" width="1024" height="512"/>
        </tileset>
    </map>
    ''';
    var map;
    setUp(() { map = parser.parse(xml); });

    test('and Map.tilesets is the correct size', () {
      expect(map.tilesets.length, equals(1));
    });

    group('and the first tileset', () {
      var tileset;
      setUp( ()=> tileset = map.tilesets[0] );

      test('has its firstgid = 1', ()=> expect(tileset.gid, equals(1)) );
      test('has its name = "Humans"', ()=> expect(tileset.name, equals('Humans')));
      test('has its tilewidth = 64', ()=> expect(tileset.width, equals(64)));
      test('has its tileheight = 32', ()=> expect(tileset.height, equals(32)));
      test('has its images.length = 1', ()=> expect(tileset.images.length, equals(1)));

      group('populates its first image correctly and', () {
        var image;
        setUp( ()=> image = tileset.images[0]);

        test('has its width = 1024', ()=> expect(image.width, equals(1024)));
        test('has its height = 512', ()=> expect(image.height, equals(512)));
        test('has its source = "../icons/mob/human.png"', ()=> expect(image.source, equals('../icons/mob/human.png')));
      });
    });

  });

  group('Parser.parse populates Map with layers', () {
    var xml = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <map>
         <layer name="Floor Layer" width="10" height="10">
          <data encoding="base64" compression="zlib">
            eJxjZCAeMI6qpblaAAl0AAs=
          </data>
        </layer>
      </map>
    ''';

    var map;
    setUp(() { map = parser.parse(xml); });

    test('and Map.layers is the correct length', ()=> expect(map.layers.length, equals(1)));

    group('and the first layer', () {
      var layer;
      setUp( ()=> layer = map.layers[0] );

      test('has its name = "Floor Layer"', ()=> expect(layer.name, equals('Floor Layer')));
      test('has its width  = 10', ()=> expect(layer.width, equals(10)));
      test('has its height = 10', ()=> expect(layer.height, equals(10)));

      // This test is very simple. Theoretically, if this case works, they should all work.
      // It's a 10x10 matrix because anything smaller seems to default to gzip in Tiled (bug?).
      test('populates its tile matrix', () {
        expect(layer.tileMatrix[0], equals([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
        expect(layer.tileMatrix[1], equals([0, 1, 0, 0, 0, 0, 0, 0, 0, 0]));
        expect(layer.tileMatrix[2], equals([0, 0, 1, 0, 0, 0, 0, 0, 0, 0]));
        expect(layer.tileMatrix[3], equals([0, 0, 0, 1, 0, 0, 0, 0, 0, 0]));
        expect(layer.tileMatrix[4], equals([0, 0, 0, 0, 1, 0, 0, 0, 0, 0]));
        expect(layer.tileMatrix[5], equals([0, 0, 0, 0, 0, 1, 0, 0, 0, 0]));
        expect(layer.tileMatrix[6], equals([0, 0, 0, 0, 0, 0, 1, 0, 0, 0]));
        expect(layer.tileMatrix[7], equals([0, 0, 0, 0, 0, 0, 0, 1, 0, 0]));
        expect(layer.tileMatrix[8], equals([0, 0, 0, 0, 0, 0, 0, 0, 1, 0]));
        expect(layer.tileMatrix[9], equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 1]));
      });

    });
  });
}



