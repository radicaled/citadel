part of citadel_server;

class TileManager {
  String animationDir;
  Map<String, AnimationSet> animationSets = {};
  Map<String, Animation> animations = {};

  TileManager(this.animationDir);

  /**
   * Searches [animationDir] for *.json files and loads them into [tiles]
   */
  void load() {
    var dir = new Directory(animationDir);
    var files = dir.listSync(recursive: true).where((fe) => fe is File).where((fe) => path.extension(fe.path) == '.json');

    files.forEach((file) {
      var json = JSON.decode(file.readAsStringSync());
      var animationSet = new AnimationSet.fromJSON(json);
      animationSets[animationSet.name] = animationSet;
      animationSet.animations.forEach((k, v) {
        var name = animationSet.name + '|' + v.name;
        animations[name] = v;
      });
    });
  }

  Animation getAnimation(String animationName) {
    var result = animations[animationName];
    if (result == null) { throw 'Animation not found: $animationName'; }
    return result;
  }
}
