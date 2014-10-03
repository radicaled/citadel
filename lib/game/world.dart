library game.world;

import 'package:citadel/game/entities.dart';
import 'dart:async';

class World {
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream onEmit;

  World() {
    onEmit = _emitController.stream;
  }

  void emit(String text, {Entity nearEntity, Entity fromEntity}) {
    _emitController.add(new EmitEvent(text, nearEntity: nearEntity, fromEntity: fromEntity));
  }
}

class EmitEvent {
  String message;
  Entity nearEntity;
  Entity fromEntity;
  EmitEvent(this.message, {this.nearEntity, this.fromEntity});
}