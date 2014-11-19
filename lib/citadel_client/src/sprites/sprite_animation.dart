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
    var frame = animation.getFrame(_totalTime);

    if (currentFrame != frame) {
      currentFrame = frame;

      sprite.removeChildren();
      sprite.bitmapData = spriteSheet.frameAt(frame);
      sprite.addChild(new Bitmap(sprite.bitmapData));
    }
    return !animation.shouldFinish(_totalTime);
  }
}
