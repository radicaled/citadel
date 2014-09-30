library entities;

import 'dart:mirrors';
import 'dart:async';
import 'components.dart';

// The only public API anyone needs to worry about here is 'buildEntity'
export 'entities.dart' show buildEntity;

part 'entities/src/entity_builder.dart';
part 'entities/src/entity_manager.dart';
part 'entities/src/entity_behavior.dart';

part 'entities/src/events/entity_event.dart';

part 'entities/entity.dart';
