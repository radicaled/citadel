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

  // Operators

  bool operator ==(AnimationTimer other) =>
    other != null && (other.animatingEntity == animatingEntity && other.animation == animation);

  // overrides

  String toString() =>
    "AnimationTimer<${animation.fullName} for Entity ${animatingEntity.id}>";

  int get hashCode =>
    hashObjects([animatingEntity, animation]);
}
