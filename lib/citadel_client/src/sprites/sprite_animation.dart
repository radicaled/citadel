part of citadel_client;

class SpriteAnimation extends Animatable {
  GameSprite sprite;
  animations.Animation animation;
  SpriteSheet spriteSheet;
  SpriteAnimation(this.sprite, this.animation, this.spriteSheet);

  num _totalTime = 0.0;
  int currentFrameIndex;

  bool advanceTime(num time) {
    _totalTime += time;
    var frameIndex;
    if (animation.isInstant) {
      frameIndex = animation.frameCount;
    } else {
      frameIndex = (animation.frameCount * (_totalTime / animation.duration)).floor();
    }

    if (currentFrameIndex != frameIndex) {
      currentFrameIndex = frameIndex;

      sprite.removeChildren();
      sprite.bitmapData = spriteSheet.frameAt(animation.startFrame + frameIndex);
      sprite.addChild(new Bitmap(sprite.bitmapData));
    }
    return _totalTime <= animation.duration;
  }
}
