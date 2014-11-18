part of citadel_client;

class SpriteAnimation extends Animatable {
  GameSprite sprite;
  animations.Animation animation;
  SpriteSheet spriteSheet;
  SpriteAnimation(this.sprite, this.animation, this.spriteSheet);

  num _totalTime = 0.0;
  int currentFrame;

  bool advanceTime(num time) {
    _totalTime += time;
    var frame;
    if (animation.isInstant) {
      frame = animation.startFrame + animation.frameCount;
    } else {
      frame = (animation.frameCount * (_totalTime / animation.duration)).floor();
    }

    if (currentFrame != frame) {
      currentFrame = frame;

      sprite.removeChildren();
      sprite.bitmapData = spriteSheet.frameAt(animation.startFrame + frame);
      sprite.addChild(new Bitmap(sprite.bitmapData));
    }
    return _totalTime <= animation.duration;
  }
}
