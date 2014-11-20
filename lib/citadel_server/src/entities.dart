library citadel_server.entities;

import 'components.dart';
import 'package:citadel/game/entities.dart';
import 'package:citadel/game/world.dart';

part 'entities/wall.dart';
part 'entities/placeholder.dart';
part 'entities/floor.dart';
part 'entities/hvac.dart';
part 'entities/human.dart';
part 'entities/multi_tool.dart';
part 'entities/command_door.dart';
part 'entities/locker.dart';
part 'entities/arcade_machine.dart';
part 'entities/donut.dart';

abstract class CEntityBuilder extends EntityBuilder {
  World world;
}

