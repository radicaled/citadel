part of citadel_server;

class TileManager {
  String configDir;
  Map<String, Map> tiles = new Map();

  TileManager(this.configDir);

  /**
   * Searches [configDir] for *.yml files and loads them into [tiles]
   */
  void load() {
    var dir = new Directory(configDir);
    var files = dir.listSync(recursive: true).where((fe) => fe is File).where((fe) => path.extension(fe.path) == '.yml');

    files.forEach((file) {
      // TODO: is namespacing the configs the right idea?
      // the possibilities of a collision are slim, but...
      // how will you check if a tile graphic set already exists?
      // var ns = path.basenameWithoutExtension(file.path);
      var yaml = loadYaml(file.readAsStringSync());
      tiles.addAll(yaml);
      print(tiles);
    });
  }

  /**
   * Safely queries an entity for its [TileGraphics] component and [Entity.entityType], then returns a [List<Map>] in the following form:
   *     {
   *       'graphic_id': 'some_graphic_id',
   *       'transition': 0, // can be null
   *       'on_done':  'name_of_script_on_entity' // can be null
   *     }
   */
  List<Map> lookup(Entity e, String frameSet) {
    // FIXME: the whole null check / return pattern.
    var list = [];

    if (!e.has([TileGraphics])) return list;

    var tileAnimations = tiles[e.entityType];
    if (tileAnimations == null) return list;

    var frames = tileAnimations[frameSet];
    if (frames == null) return list;

    if (frames is String) {
      list.add({ 'graphic_id': frames });
    } else if (frames is List) {
      list.addAll(frames);
    } else {
      throw new ArgumentError('Unable to interpret the following class: $frames');
    }

    return list;
  }
}
