part of citadel_server.entities;

class MultiTool extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
    has(Electronic);
    has(Power, [100]);
    has(Name, ['A multi-tool']);
    has(Description, ['A tool for hacking and cracking gibsons']);

    behavior('use', (b) {
      b.require(Power, test: (power) => power.level > 15, onFail: (ei) {
        world.emit('The multi-tool makes a beep-boop noise, then falls silent.', nearEntity: ei.current);
      });

      b.before((ei) => ei.current[Power].level -= 15);

      b.before((ei) =>
        world.emit('You hold the multi-tool up to the object and its interface lights up colorfully.', fromEntity: ei.current, nearEntity: ei.target));

      b.activated((ei) {
        // TODO: need a way to get the invoking entity
        // EG, if a human holds a multi-tool and targets a door, that's three entities:
        // The human, the multi-tool, and the door.
        if (ei.target.has([Electronic])) {
          ei.target.react('disable', ei.invoker, ei.current);
        }
      });
    });
  }


}
