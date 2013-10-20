import 'package:unittest/unittest.dart';
import 'package:citadel/tilemap.dart';

main() {
  test('Parser.parse raises an error when the XML is not in TMX format', () {
    var wrongXml = '<xml></xml>';

    expect( ()=> Parser.parse(wrongXml),
        throwsA('XML is not in TMX format'));
  });

  test('Parser.parse returns a Map object', () {
    var xml = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <map>
      </map>      
    ''';
    var map = Parser.parse(xml);

    expect(map, new isInstanceOf<Map>());
  });

  group('Parser.parse populates Map with tilesets', () {
    var xml = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <map>
        <tileset firstgid="1" name="Humans" tilewidth="64" tileheight="32">
          <image source="../icons/mob/human.png" width="512" height="512"/>
        </tileset>
    </map>
    ''';
    var map;
    setUp(() { map = Parser.parse(xml); });

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
    });


  });
}



