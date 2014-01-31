part of citadel_server;

moveIntentSystem(Intent intent) {
  var entity = findEntity(intent.invokingEntityId);

  var velocity = entity[Velocity];
  switch (intent.name) {
    case 'MOVE_N':
      velocity.y -= 1;
      break;
    case 'MOVE_W':
      velocity.x -= 1;
      break;
    case 'MOVE_S':
      velocity.y += 1;
      break;
    case 'MOVE_E':
      velocity.x += 1;
      break;
  }
}