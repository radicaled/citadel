part of citadel_server;

class AnimationTimer {
  Animation animation;
  DateTime startTime;
  DateTime endTime;
  // TODO: possibly remove this / replace with entity id?
  Entity animatingEntity;

  AnimationTimer(this.animation);

  bool get isFinished =>
    endTime != null && endTime.isBefore(new DateTime.now());

  void start() {
    startTime = new DateTime.now();
    endTime   = startTime.add(new Duration(seconds: animation.duration));
  }
}
