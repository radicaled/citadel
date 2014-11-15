part of citadel_server;

class AnimationCallbackSystem extends GenericSystem {
  List<AnimationTimer> animationTimers = [];
  bool get shouldExecute =>
    animationTimers.isNotEmpty;

  void execute() {
    var readyToEnd = animationTimers.where((at) => at.isFinished).toList();
    readyToEnd.forEach((at) {
      if (at.animation.onDone != null) {
        at.animatingEntity.execute(at.animation.onDone);
      }
      // "removeWhere" doesn't return removed items, because that's too scary for Java programmers!
      animationTimers.remove(at);
    });
  }
}
