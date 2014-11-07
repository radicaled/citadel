part of citadel_server;

/**
 * This class is responsible for spawning a player entity into the world.
 */
class PlayerSpawner {
  World world;

  PlayerSpawner(this.world);

  Entity spawnPlayer() {
    var entity = buildEntity('human', world)
      ..attach(new Player())
      ..attach(new Visible());

    Position pos = entity[Position];
    TileGraphics tgs = entity[TileGraphics];
    pos
      ..x = 8
      ..y = 8
      ..z = 16;
    tgs.tilePhrases = ['Humans|1'];

    return entity;
  }
}
