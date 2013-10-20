part of tilemap;

class Parser {
  static Map parse(String xml) {
    var xmlElement = XML.parse(xml);

    if (xmlElement.name != 'map') {
      throw 'XML is not in TMX format';
    }

    var map = new Map();

    xmlElement.children.forEach( (XmlElement node) {
      switch(node.name) {
        case 'tileset':
          map.tilesets.add(_parseTileset(node));
          break;
      }
    });

    return map;
  }

  static Tileset _parseTileset(XmlElement node) {
    return new Tileset(int.parse(node.attributes['firstgid']));

  }
}