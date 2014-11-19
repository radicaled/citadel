part of citadel_server;

class AnimationTimer {
  Animation animation;
  DateTime startTime;
  num get duration => animation.duration;
  num get elapsed => st.elapsedMilliseconds / 1000;
  // TODO: possibly remove this / replace with entity id?
  Entity animatingEntity;

  Stopwatch st = new Stopwatch();

  AnimationTimer(this.animation);

  bool get isFinished =>
  (st.elapsedMilliseconds / 1000) > duration;

  void start() {
    startTime = new DateTime.now();
    st.start();
  }
}
