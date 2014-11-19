part of citadel_server;

class AnimationSystem extends EntitySystem {
  AssetManager assetManager;

  AnimationSystem(this.assetManager);

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
    world.messages.add(new AllClientsMessage('animate', {
        'entity_id': entity.id,
        'animation_name': animationName,
        'elapsed': at.elapsed,
    }));

  }
}
