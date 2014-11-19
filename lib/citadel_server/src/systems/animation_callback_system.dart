part of citadel_server;

class AnimationCallbackSystem extends GenericSystem {
  List<AnimationTimer> animationTimers = [];
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
      var targetFrame;
      if (animation.isInstant) {
        targetFrame = animation.startFrame + animation.frameCount;
      } else {
        var delta = new DateTime.now().difference(at.endTime);
        var frame = (animation.frameCount * ((delta.inMilliseconds / 1000) / animation.duration)).floor();
        targetFrame = animation.startFrame - frame;
      }
      var currentTile = at.animation.animationSet.tileset + '|' + targetFrame.toString();


      print('Updated to $currentTile');
      // TODO: destructive; sort me out
      tg.tilePhrases.clear();
      tg.tilePhrases.add(currentTile);
    });
  }

  void _handleCallbacks() {
    var readyToEnd = animationTimers.where((at) => at.isFinished).toList();
    readyToEnd.forEach((at) {
      if (at.animation.onDone != null) {
        at.animatingEntity.execute(at.animation.onDone);
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
