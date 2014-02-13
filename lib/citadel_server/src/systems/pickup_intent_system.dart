part of citadel_server;

void pickupIntentSystem(Intent intent) {
  var invoker = findEntity(intent.invokingEntityId);
  var target = findEntity(intent.targetEntityId);

  var actionName = invoker.has([Name]) ? invoker[Name].text : 'Someone';
  var targetName = target.has([Name]) ? target[Name].text : 'Something';
  invoker.emitNear('$actionName picks up the $targetName');
  target.root = invoker; // FIXME?
  EntityManager.hidden(target);

  commandQueue.add(_makeCommand('picked_up', {
    'entity_id': target.id,
    'name': targetName,
    'hand': 'left', // FIXME: hard-coded
    'actions': target.behaviors.keys.toList()
  }));

}