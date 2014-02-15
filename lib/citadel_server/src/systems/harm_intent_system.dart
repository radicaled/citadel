part of citadel_server;

void harmIntentSystem(Intent intent) {
  print('called to harm');
  var attacker = findEntity(intent.invokingEntityId);
  var target = findEntity(intent.targetEntityId);
  var weapon = findEntity(intent.withEntityId);
  if (weapon == null) weapon = attacker;

  var maxDamage = 15;
  // FIXME: query entity for damage components.
  // FIXME: assume hit, always.
  var health = target[Health];
  var name = target[Name].text;
  if (health != null) {
    health.currentHP -= maxDamage;
    target.emitNear('$name: Ow! That hurts a ton!');

    if (health.currentHP <= 0) {
      target.emitNear('${name} dies!');
      EntityManager.hidden(target);
    }
  }
}