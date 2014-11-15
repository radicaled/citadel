library game.world;

import 'package:citadel/game/entities.dart';
import 'package:citadel/game/systems.dart';
import 'dart:async';

class World {
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream onEmit;
  List<EntitySystem> entitySystems = [];
  List<MessageSystem> messageSystems = [];
  List<GenericSystem> genericSystems = [];

  Set<Entity> entities = new Set();
  List<SystemMessage> messages = new List();

  // TODO: Could probably be refined?
  Map<String, dynamic> attributes = {};

  World() {
    onEmit = _emitController.stream;
  }

  void emit(String text, {Entity nearEntity, Entity fromEntity, Entity toEntity}) {
    _emitController.add(new EmitEvent(text, nearEntity: nearEntity, fromEntity: fromEntity, toEntity: toEntity));
  }

  void process() {
    entitySystems.forEach((s) => s.processEntities(entities));
    messageSystems.forEach((s) => s.processMessages(messages));
    genericSystems.where((s) => s.shouldExecute).forEach((s) => s.execute());

    messages.clear();
  }

  MessageSystem getMessageSystem(Type type) {
    return messageSystems.firstWhere((ms) => ms.runtimeType == type, orElse: () => throw "Unable to find $type");
  }

  GenericSystem getGenericSystem(Type type) {
    return genericSystems.firstWhere((gs) => gs.runtimeType == type, orElse: () => throw "Unable to find $type");
  }
}

class EmitEvent {
  String message;
  Entity nearEntity;
  Entity fromEntity;
  Entity toEntity;
  EmitEvent(this.message, {this.nearEntity, this.fromEntity, this.toEntity});
}
