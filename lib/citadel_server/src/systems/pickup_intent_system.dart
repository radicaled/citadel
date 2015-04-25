part of citadel_server;

void pickupIntentSystem(Intent intent) {
  var invoker = findEntity(intent.invokingEntityId);
  var target = findEntity(intent.targetEntityId);

  var actionName = invoker.has([Name]) ? invoker[Name].text : 'Someone';
  var targetName = target.has([Name]) ? target[Name].text : 'Something';

  invoker.require(Container);
  // TODO: maximum 4 items hard-coded
  if (invoker[Container].entityIds.length >= 4) { return; }

  world.emit('$actionName picks up the $targetName');
  // FIXME: what if the object is clothing?
  target.detachComponent(Visible);
  target.attachComponent(new Position.from(invoker[Position]));
  invoker[Container].entityIds.add(target.id);
  EntityManager.hidden(target);

  commandQueue.add(_makeCommand('picked_up', {
    'entity_id': target.id,
    'name': targetName,
    'hand': 'left', // FIXME: hard-coded
    'actions': [] // FIXME: hard-coded
  }));

}
