part of citadel_server;

class AssetManager {
  Map<String, AnimationSet> animationSets = {};
  Map<String, Animation> animations = {};
  Set<String> animationUrls = new Set();

  void loadAnimations(String directory) {
    var dir = new Directory(directory);
    var files = dir.listSync(recursive: true).where((fe) => fe is File).where((fe) => path.extension(fe.path) == '.json');

    files.forEach((file) {
      var json = JSON.decode(file.readAsStringSync());
      var animationSet = new AnimationSet.fromJSON(json);
      var animationUrl = path.relative(file.path);

      animationUrls.add(animationUrl);
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
