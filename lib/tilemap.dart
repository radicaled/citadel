library tilemap;

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'dart:io';

part 'tilemap/parser.dart';
part 'tilemap/map.dart';
part 'tilemap/tileset.dart';
part 'tilemap/image.dart';
part 'tilemap/layer.dart';

class Tilemap {
  loadMap(xml) {
    Parser.parse(xml);
  }
}