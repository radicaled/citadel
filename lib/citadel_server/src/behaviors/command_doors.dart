part of behaviors;

@GameName("CommandDoorCollideBehavior")
class CommandDoorCollideBehavior extends Behavior with _CommandDoorHelpers {
  final triggers = ['collide'];

  update(Entity proxy, Entity target) {
    world.emit('CLANK!!', nearEntity: proxy, fromEntity: proxy);
    open(proxy, target);
  }
}

@GameName("CommandDoorUseBehavior")
class CommandDoorUseBehavior extends Behavior with _CommandDoorHelpers {
  final triggers = ['use'];

  update(Entity proxy, Entity target) {
    var opening = open(proxy, target);
    if (opening) {
      world.emit('The door scans your ID and chirps happily', fromEntity: target, toEntity: proxy);
      world.emit('Swoosh!', nearEntity: proxy, fromEntity: proxy);
    }
  }
}

@GameName("CommandDoorOpenBehavior")
class CommandDoorOpenBehavior extends Behavior {
  final triggers = ['opened'];

  update(Entity proxy, Entity target) {
    target.detachComponent(Collidable);
  }
}

@GameName("CommandDoorCloseBehavior")
class CommandDoorCloseBehavior extends Behavior {
  final triggers = ['closed'];

  update(Entity proxy, Entity target) {
    target.attachComponent(new Collidable());
  }
}

class _CommandDoorHelpers {

  bool open(Entity proxy, Entity target) {
    Openable o = target[Openable];
    RequiredSecurityClearance rsc = target[RequiredSecurityClearance];
    SecurityClearanceLevel scl = proxy[SecurityClearanceLevel];

    if (!shouldOpen(rsc, scl)) return true;
    if (o.isTransitioning) return false;

    o.transition();
    target.use(TileGraphics, (TileGraphics tileGraphics) {
      var name = target[Name].text;
      tileGraphics.animationQueue.add('$name|opening');
    });

    return true;
  }

  shouldOpen(RequiredSecurityClearance rsc, SecurityClearanceLevel scl) {
    if (rsc == null)
      return true;

    if (scl == null)
      return false;

    // TODO: should check security levels based on a tree or something.
    return true;
  }
}