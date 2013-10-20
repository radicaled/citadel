library tilemap;
import 'package:xml/xml.dart';

part 'tilemap/parser.dart';
part 'tilemap/map.dart';
part 'tilemap/tileset.dart';

class Tilemap {
  loadMap(xml) {
    Parser.parse(xml);
  }
}