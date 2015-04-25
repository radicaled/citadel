library citadel_server.entities;

import 'components.dart';
import 'behaviors.dart';
import 'package:citadel/game/entities.dart';

final EntityParser entityParser = setupEntityParser();

EntityParser setupEntityParser() {
  var ep = new EntityParser();

  ep.registerComponent("Collidable", Collidable);
  ep.registerComponent("Container", Container);
  ep.registerComponent("Damage", Damage);
  ep.registerComponent("Description", Description);
  ep.registerComponent("Disabled", Disabled);
  ep.registerComponent("Electronic", Electronic);
  ep.registerComponent("Health", Health);
  ep.registerComponent("Inventory", Inventory);
  ep.registerComponent("Name", Name);
  ep.registerComponent("Openable", Openable);
  ep.registerComponent("Player", Player);
  ep.registerComponent("Position", Position);
  ep.registerComponent("Power", Power);
  ep.registerComponent("TileGraphics", TileGraphics);
  ep.registerComponent("Velocity", Velocity);
  ep.registerComponent("Visible", Visible);
  ep.registerComponent("Vision", Vision);

  ep.registerBehavior(HumanUseBehavior);
  ep.registerBehavior(LockerUseBehavior);
  ep.registerBehavior(MultiToolUseBehavior);
  ep.registerBehavior(PlaceholderLookBehavior);
  ep.registerBehavior(HvacUseBehavior);
  ep.registerBehavior(HvacDisableBehavior);
  ep.registerBehavior(CommandDoorCollideBehavior);
  ep.registerBehavior(CommandDoorUseBehavior);
  ep.registerBehavior(CommandDoorOpenBehavior);
  ep.registerBehavior(CommandDoorCloseBehavior);
  return ep;
}
