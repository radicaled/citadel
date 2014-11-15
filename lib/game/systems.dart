library systems;

import 'entities.dart';

part 'systems/entity_system.dart';
part 'systems/message_system.dart';
part 'systems/generic_system.dart';

class SystemMessage {
  String name;

  SystemMessage(this.name);
}
