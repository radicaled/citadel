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
}