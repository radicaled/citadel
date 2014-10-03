part of citadel_server.entities;

class MultiTool extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
    has(Power, [15 * 99]);
    has(Name, ['A multi-tool']);
    has(Description, ['A tool for hacking and cracking gibsons']);

    behavior('disable', (b) {
      b.require(Power, (power) => power.level > 15);
      b.before((thisEntity, thatEntity) => thisEntity[Power].level -= 15);
      b.after((thisEntity, thatEntity) => world.emit('The theme to Ghostbusters plays', fromEntity: thisEntity, nearEntity: thatEntity));
    });
  }


}