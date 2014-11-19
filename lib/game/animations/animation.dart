part of game.animations;

class Animation {
  String name;
  int startFrame;
  int frameCount;
  num duration;
  String onDone;
  AnimationSet animationSet;

  bool get isInstant => duration == 0;
  int get endFrame => startFrame + frameCount;

  String get fullName => animationSet.name + '|' + name;

  Animation(this.name, this.animationSet);
  Animation.fromJSON(Map json, this.animationSet) : name = json["name"] {
    startFrame = json['start_frame'];
    frameCount = json['frame_count'];
    duration   = json['duration'];
    onDone     = json['on_done'];
  }

  int getFrame(num secondsElapsed) {
    if (secondsElapsed < 0) { throw 'secondsElapsed cannot be < 0 ($secondsElapsed)'; }
    if (shouldFinish(secondsElapsed)) { return endFrame; }
    if (isInstant) { return endFrame; }
    return startFrame + (frameCount * (secondsElapsed / duration)).floor();
  }

  bool shouldFinish(num secondsSinceAnimationStart) =>
    secondsSinceAnimationStart >= duration;

  bool operator==(Animation other) =>
    other != null && other.fullName == fullName;

  int get hashCode =>
    fullName.hashCode;
}
