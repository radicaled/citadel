part of behaviors;

class CommandDoorCollideBehavior extends Behavior {
  final triggers = ['collide'];

  update(Entity proxy, Entity target) {
    world.emit('You crash into the command door!', fromEntity: proxy, toEntity: target);
    world.emit('CLANK!!', nearEntity: proxy, fromEntity: proxy);
    Openable o = target[Openable];
    if (o.isTransitioning) { return; }
    o.transition();
    target.use(TileGraphics, (TileGraphics tileGraphics) {
      tileGraphics.animationQueue.add('Command Door|opening');
    });
  }
}

class CommandDoorUseBehavior extends Behavior {
  final triggers = ['use'];

  update(Entity proxy, Entity target) {
    // FIXME: assumed everyone has access.
    Openable o = target[Openable];
    if (o.isTransitioning) { return; }

    world.emit('The door scans your ID and chirps happily', fromEntity: proxy, toEntity: target);
    world.emit('Swoosh!', nearEntity: proxy, fromEntity: proxy);
    o.transition();
    target.use(TileGraphics, (TileGraphics tileGraphics) {
      tileGraphics.animationQueue.add('Command Door|opening');
    });
  }
}

class CommandDoorOpenBehavior extends Behavior {
  final triggers = ['opened'];

  update(Entity proxy, Entity target) {
    target.detachComponent(Collidable);
  }
}

class CommandDoorCloseBehavior extends Behavior {
  final triggers = ['closed'];

  update(Entity proxy, Entity target) {
    target.attachComponent(new Collidable());
  }
}