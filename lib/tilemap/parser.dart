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
        case 'layer':
          map.layers.add(_parseLayer(node));
          break;
      }
    });

    return map;
  }

  static Tileset _parseTileset(XmlElement node) {
    var attrs = node.attributes;
    return new Tileset(int.parse(attrs['firstgid']))
      ..name = attrs['name']
      ..width = int.parse(attrs['tilewidth'])
      ..height = int.parse(attrs['tileheight'])
      ..images.addAll(node.query('image').map((XmlElement node)=> _parseImage(node)));

  }

  static Image _parseImage(XmlElement node) {
    var attrs = node.attributes;
    return new Image(attrs['source'], int.parse(attrs['width']), int.parse(attrs['height']));
  }

  static Layer _parseLayer(XmlElement node) {
    var attrs = node.attributes;
    return new Layer(attrs['name'])
      ..width = int.parse(attrs['width'])
      ..height = int.parse(attrs['height']);
  }
}