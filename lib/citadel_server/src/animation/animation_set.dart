part of citadel_server;

class AnimationSet {
  String name;
  String tileset;

  Map<String, Animation> animations = {};

  AnimationSet(this.name, this.tileset);
  AnimationSet.fromJSON(Map json) : name = json["name"], tileset = json["tileset"] {
    for(var anim in json["data"]) {
      var animation = new Animation.fromJSON(anim, this);
      animations[animation.name] = animation;
    }
  }
}
