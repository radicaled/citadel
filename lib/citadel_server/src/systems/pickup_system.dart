part of citadel_server;

void pickupSystem() {
  var entities = entitiesWithComponents([PickingUp]);

  entities.forEach((entity) {
    var target = entity[PickingUp].entity;
    var actionName = entity.has([Name]) ? entity[Name].text : 'Someone';
    var targetName = target.has([Name]) ? target[Name].text : 'Something';
    entity.emitNear('$actionName picks up the $targetName');
    EntityManager.hidden(target);

    commandQueue.add(_makeCommand('picked_up', {
      'entity_id': target.id,
      'name': target[Name].text,
      'hand': entity[PickingUp].hand,
      'actions': target.behaviors.keys.toList()
    }));

    entity.components.remove(PickingUp);
  });
}