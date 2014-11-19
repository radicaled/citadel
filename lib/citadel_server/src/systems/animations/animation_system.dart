part of citadel_server;

class AnimationSystem extends EntitySystem {
  AssetManager assetManager;
  ServerNetworkHub hub;

  AnimationSystem(this.assetManager, this.hub);

  filter(Iterable<Entity> entities) =>
    entities.where((e) => e.has([TileGraphics]) && e[TileGraphics].animationQueue.isNotEmpty);

  void process(Entity entity) {
    TileGraphics tg = entity[TileGraphics];
    var animationName = tg.animationQueue.removeFirst();
    var animation = assetManager.getAnimation(animationName);
    AnimationCallbackSystem acs = world.getGenericSystem(AnimationCallbackSystem);
    var at = new AnimationTimer(animation)
      ..animatingEntity = entity
      ..start();

    acs.animationTimers.add(at);

    // TODO: should I be directly sending messages?
    hub
      ..animate(entity.id, animationName, elapsed: at.elapsed)
      ..broadcast();
  }
}
