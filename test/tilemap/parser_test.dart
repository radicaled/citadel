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
}



