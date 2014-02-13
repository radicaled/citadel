part of citadel_server;

void animationBufferSystem() {
  liveEntities.where((e) => e.animationBuffer.isNotEmpty).forEach((entity) {
    entity.animationBuffer.forEach((aniName) {
      var frames = tileManager.lookup(entity, aniName);
      frames.forEach((frame) {
        // FIXME: >:(
        var done = frame['on_done'] != null ? () => entity.scripts[frame['on_done']](entity) : null;
        AnimationBuilder.on(entity).animate(frame['graphic_id'], frame['transition'], onDone: done);
      });

    });
    entity.animationBuffer.clear();
  });
}