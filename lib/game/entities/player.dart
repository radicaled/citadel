part of entities;

var _playerDef = entity('player', (eb) {
  eb.addAll([
              Position, 
              Velocity,
              Collidable,
              Player,
              TileGraphics
             ]);
  
});