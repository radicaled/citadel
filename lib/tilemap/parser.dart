library tilemap;

import 'package:xml/xml.dart';

class Parser {
  static parse(String xml) {
    var xmlElement = XML.parse(xml);

    if (xmlElement.name != 'map') {
      throw 'XML is not in TMX format';
    }
  }
}