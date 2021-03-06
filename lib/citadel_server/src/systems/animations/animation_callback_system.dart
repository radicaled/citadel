part of citadel_server;

class AnimationCallbackSystem extends GenericSystem {
  Set<AnimationTimer> animationTimers = new Set();
  bool get shouldExecute =>
    animationTimers.isNotEmpty;

  void execute() {
    _updateCurrentFrame();
    _handleCallbacks();
  }

  void _updateCurrentFrame() {
    animationTimers.forEach((at) {
      TileGraphics tg = at.animatingEntity[TileGraphics];
      var animation = at.animation;
      var elapsed = at.elapsed;
      var targetFrame = animation.getFrame(elapsed);
      var currentTile = at.animation.animationSet.tileset + '|' + targetFrame.toString();

      // TODO: destructive; sort me out
      tg.tilePhrases.clear();
      tg.tilePhrases.add(currentTile);
    });
  }

  void _handleCallbacks() {
    var readyToEnd = animationTimers.where((at) => at.isFinished).toList();
    readyToEnd.forEach((at) {
      if (at.animation.onDone != null) {
        at.animatingEntity.receive(at.animation.onDone, null);
      }
      TileGraphics tg = at.animatingEntity[TileGraphics];
      var frame = at.animation.startFrame + at.animation.frameCount;
      // This animation is done, so make sure the last frame is selected
      // TODO: destructive; sort me out
      tg.tilePhrases.clear();
      tg.tilePhrases.add(at.animation.animationSet.tileset + '|' + frame.toString());
      // "removeWhere" doesn't return removed items, because that's too scary for Java programmers!
      animationTimers.remove(at);
    });
  }
}
