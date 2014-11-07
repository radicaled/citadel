part of citadel_server;

/**
 * This class is responsible for spawning a player entity into the world.
 */
class PlayerSpawner {
  World world;

  PlayerSpawner(this.world);

  /**
   * If [position] is null, spawnPlayer will query the World for spawn zones
   * and use a free zone.
   */
  Entity spawnPlayer([Position position]) {
    var entity = buildEntity('human', world)
      ..attach(new Player())
      ..attach(new Visible());

    if(position == null) {
      List<Map> spawnZones = world.attributes['spawn_zones'];
      if (spawnZones.isEmpty) { throw 'No spawn zones available!'; }
      position = _findAvailableSpawn(spawnZones);
    }

    entity.attach(position);
    TileGraphics tgs = entity[TileGraphics];
    // TODO: this is just for uniqueness
    var tile = new Random().nextInt(64);
    tgs.tilePhrases = ['Humans|$tile'];

    return entity;
  }

  // TODO: optimize this with a position map
  Position _findAvailableSpawn(Iterable<Map> spawnZones) {
    var sz = spawnZones.toList();
    for(var i = 0; i < sz.length; i++) {
      var spawnZone = sz[i];
      var width = spawnZone['width'];
      var height = spawnZone['height'];
      for(var x = spawnZone['x']; x < spawnZone['width'] + x; x++) {
        for (var y = spawnZone['y']; y < spawnZone['height'] + y; y++) {
          var pos = new Position(x, y);
          var blocking = world.entities.where((e) => e.has([Position, Collidable])).where((e) => e[Position] == pos);
          if (blocking.length == 0) return pos;
        }
      }
    }
    throw 'Unable to find a free spawn zone!';
  }
}
