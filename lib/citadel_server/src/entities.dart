library citadel_server.entities;

import 'components.dart';
import 'behaviors.dart';
import 'package:citadel/game/entities.dart';
import 'package:citadel/game/world.dart';

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

  ep.registerBehavior("HumanUseBehavior", HumanUseBehavior);
  ep.registerBehavior("LockerUseBehavior", LockerUseBehavior);
  ep.registerBehavior("MultiToolUseBehavior", MultiToolUseBehavior);
  ep.registerBehavior("PlaceholderLookBehavior", PlaceholderLookBehavior);
  ep.registerBehavior("HvacUseBehavior", HvacUseBehavior);
  ep.registerBehavior("HvacDisableBehavior", HvacDisableBehavior);
  ep.registerBehavior("CommandDoorCollideBehavior", CommandDoorCollideBehavior);
  ep.registerBehavior("CommandDoorUseBehavior", CommandDoorUseBehavior);
  ep.registerBehavior("CommandDoorOpenBehavior", CommandDoorOpenBehavior);
  ep.registerBehavior("CommandDoorCloseBehavior", CommandDoorCloseBehavior);
  return ep;
}
