part of citadel_server;

class AnimationBufferSystem extends EntitySystem {
  filter(entities) => entities.where((e) => e.animationBuffer.isNotEmpty);

  void process(Entity entity) {
    entity.animationBuffer.forEach((aniName) {
      var frames = tileManager.lookup(entity, aniName);
      frames.forEach((frame) {
        // FIXME: >:(
        var done = frame['on_done'] != null ? () => entity.scripts[frame['on_done']](entity) : null;
        AnimationBuilder.on(entity).animate(frame['graphic_id'], frame['transition'], onDone: done);
      });

    });
    entity.animationBuffer.clear();
  }


}
