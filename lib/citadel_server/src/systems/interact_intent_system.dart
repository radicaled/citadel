part of citadel_server;

interactIntentSystem(Intent intent) {
  var invoker = findEntity(intent.invokingEntityId);
  var target = findEntity(intent.targetEntityId);
  // the invoker could be trying to use an action native to themselves -- eg, a changeling with their gross suck-u-probe.
  var withEntity   = intent.withEntityId == null ? invoker : findEntity(intent.withEntityId);
  var actionName = intent.actionName;

  var behavior = withEntity.behaviors[actionName];
  if (behavior == null) {
    invoker.emit('You have tried to do the impossible ($actionName).');
  } else {
    behavior(withEntity, target);
  }
}