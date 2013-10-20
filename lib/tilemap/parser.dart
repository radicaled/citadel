part of tilemap;

class Parser {
  static Map parse(String xml) {
    var xmlElement = XML.parse(xml);

    if (xmlElement.name != 'map') {
      throw 'XML is not in TMX format';
    }

    return new Map();
  }
}