library tilemap;

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

part 'tilemap/parser.dart';
part 'tilemap/map.dart';
part 'tilemap/tileset.dart';
part 'tilemap/image.dart';
part 'tilemap/layer.dart';
part 'tilemap/tile.dart';

class Tilemap {
  var decompressor;
  Tilemap(this.decompressor);

  TiledMap loadMap(xml) {
    return new Parser(decompressor).parse(xml);
  }
}