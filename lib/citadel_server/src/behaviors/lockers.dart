part of behaviors;

@GameName("LockerUseBehavior")
class LockerUseBehavior extends Behavior {
  final triggers = ['use'];

  update(Entity proxy, Entity target) {
    world.emit('The locker rustles', nearEntity: proxy);
    Openable o = target[Openable];
    if (!o.isTransitioning) { o.transition(); }
    target.use(TileGraphics, (TileGraphics tileGraphics) {
      var transition = o.currentState == Openable.CLOSING ? 'closing' : 'opening';
      tileGraphics.animationQueue.add('Gray Locker|$transition');
    });
  }
}