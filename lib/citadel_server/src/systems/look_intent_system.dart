part of citadel_server;

lookIntentSystem(Intent intent) {
  // TODO: should we trigger lookReaction AND emit the description?
  // Or should we just rely on lookReaction to emit the right text?
  var invoker = findEntity(intent.invokingEntityId);
  var target  = findEntity(intent.targetEntityId);
  var usi     = findEntity(intent.withEntityId);
  if (target.has([Description])) {
    target.react('look', invoker, usi, orElse: () => world.emit(target[Description].text, fromEntity: invoker));
  }
}
