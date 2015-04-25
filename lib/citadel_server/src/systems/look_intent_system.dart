part of citadel_server;

lookIntentSystem(Intent intent) {
  // TODO: should we trigger lookReaction AND emit the description?
  // Or should we just rely on lookReaction to emit the right text?
  var invoker = findEntity(intent.invokingEntityId);
  var target  = findEntity(intent.targetEntityId);

  target.receive('look', invoker, orElse: () {
    target.use(Description, (description) => world.emit(description.text, toEntity: invoker));
  });

}
