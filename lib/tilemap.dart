library tilemap;

import 'tilemap/parser.dart';

class Tilemap {
  loadMap(xml) {
    Parser.parse(xml);
  }
}