part of citadel_server;

void harmIntentSystem(Intent intent) {
  var attacker = findEntity(intent.invokingEntityId);
  var target = findEntity(intent.targetEntityId);
  var weapon = findEntity(intent.withEntityId);
  if (weapon == null) weapon = attacker;

  var maxDamage = 15;
  if (weapon.has([Damage])) maxDamage = weapon[Damage].maxDamage;
  // FIXME: assume hit, always.
  // FIXME: This code is so WTFy.
  // FIXME: be event-based in the future
  if (target.has([Health, Name])) {
    var health = target[Health];
    var name = target[Name].text;
    if (health != null) {
      health.currentHP -= maxDamage;
      world.emit('$name: Ow! That hurts a ton!', fromEntity: target, nearEntity: target);

      if (health.currentHP <= 0) {
        world.emit('${name} dies!', fromEntity: target, nearEntity: target);
        EntityManager.hidden(target);
        // TODO: this assume... I don't know, something.
        // Drop all inventory items
        target.use(Container, (container) {
          container.entityIds.map(findEntity)
            ..forEach((e) => e.attach(new Visible()))
            ..forEach(EntityManager.created);
        });
      }
    }
  }
}
