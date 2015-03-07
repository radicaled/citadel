library citadel_server.entities;

import 'components.dart';
import 'package:citadel/game/entities.dart';
import 'package:citadel/game/world.dart';

part 'entities/placeholder.dart';
part 'entities/hvac.dart';
part 'entities/human.dart';
part 'entities/multi_tool.dart';
part 'entities/command_door.dart';
part 'entities/locker.dart';

abstract class CEntityBuilder extends EntityBuilder {
  World world;
}

final EntityParser entityParser = setupEntityParser();
final Map<String, Map> entityDefinitions = {};

EntityParser setupEntityParser() {
  var ep = new EntityParser();

  ep.register("Collidable", Collidable);
  ep.register("Container", Container);
  ep.register("Damage", Damage);
  ep.register("Description", Description);
  ep.register("Disabled", Disabled);
  ep.register("Electronic", Electronic);
  ep.register("Health", Health);
  ep.register("Inventory", Inventory);
  ep.register("Name", Name);
  ep.register("Openable", Openable);
  ep.register("Player", Player);
  ep.register("Position", Position);
  ep.register("Power", Power);
  ep.register("TileGraphics", TileGraphics);
  ep.register("Velocity", Velocity);
  ep.register("Visible", Visible);
  ep.register("Vision", Vision);

  return ep;
}
