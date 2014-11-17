part of citadel_server;

class Animation {
  String name;
  int startFrame;
  int frameCount;
  num duration;
  String onDone;
  AnimationSet animationSet;

  Animation(this.name, this.animationSet);
  Animation.fromJSON(Map json, this.animationSet) : name = json["name"] {
    startFrame = json['start_frame'];
    frameCount = json['frame_count'];
    duration   = json['duration'];
    onDone     = json['on_done'];
  }
}