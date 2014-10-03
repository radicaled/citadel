library game.world;

import 'package:citadel/game/entities.dart';
import 'dart:async';

class World {
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream onEmit;

  World() {
    onEmit = _emitController.stream;
  }

  void emit(String text, {Entity nearEntity, Entity fromEntity, Entity toEntity}) {
    _emitController.add(new EmitEvent(text, nearEntity: nearEntity, fromEntity: fromEntity, toEntity: toEntity));
  }
}

class EmitEvent {
  String message;
  Entity nearEntity;
  Entity fromEntity;
  Entity toEntity;
  EmitEvent(this.message, {this.nearEntity, this.fromEntity, this.toEntity});
}