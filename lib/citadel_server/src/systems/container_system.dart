part of citadel_server;

containerSystem() {
  var containers = entitiesWithComponents([Container]);

  containers.forEach((entity) {
    Container containerComponent = entity[Container];
    TileGraphics tileGraphics = entity[TileGraphics];

    var tileConfig = tileManager.tiles[tileGraphics.tileConfig];
    var aniName;
    switch(containerComponent.state) {
      case Container.CLOSING:
        containerComponent.state = Container.CLOSED;
        aniName = 'closing';
        break;
      case Container.OPENING:
        containerComponent.state = Container.OPENED;
        aniName = 'opening';
        break;
    }
    if (tileConfig != null) {
      var frames = tileConfig[aniName];
      if (frames != null) {
        var ab = AnimationBuilder.on(entity);
        frames.forEach((frame) {
          ab.animate(frame['graphic_id'], frame['transition']);
        });
      }
    }
  });
}