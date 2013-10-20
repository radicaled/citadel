import 'package:unittest/unittest.dart';
import 'package:citadel/tilemap/parser.dart';

main() {
  test('Parser.parse', () {
    var wrongXml = '<xml></xml>';

    expect( ()=> Parser.parse(wrongXml),
        throwsA('XML is not in TMX format'));

  });
}



