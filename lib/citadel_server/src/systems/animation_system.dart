part of citadel_server;

class AnimationSystem extends EntitySystem {
  TileManager tileManager;

  filter(Iterable<Entity> entities) =>
    entities.where((e) => e.has([TileGraphics]) && e[TileGraphics].animationQueue.isNotEmpty);

  void process(Entity entity) {
    TileGraphics tg = entity[TileGraphics];
    var animationName = tg.animationQueue.removeFirst();
    var animation = tileManager.getAnimation(animationName);
    AnimationCallbackSystem acs = world.getGenericSystem(AnimationCallbackSystem);

    acs.animationTimers.add(new AnimationTimer(animation)
      ..animatingEntity = entity
      ..start());
  }
}
