library game.world;

import 'package:citadel/game/entities.dart';
import 'package:citadel/game/systems.dart';
import 'dart:async';

class World {
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream onEmit;
  List<EntitySystem> entitySystems = [];
  List<EventSystem> eventSystems = [];
  List<GenericSystem> genericSystems = [];

  Set<Entity> entities = new Set();
  List<SystemMessage> messages = new List();

  Map<String, EntityBuilder> _entityBuilders = {};

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
    eventSystems.forEach((s) => s.processMessages(messages));
    genericSystems.where((s) => s.shouldExecute).forEach((s) => s.execute());

    messages.clear();
  }

  EventSystem getMessageSystem(Type type) {
    return eventSystems.firstWhere((ms) => ms.runtimeType == type, orElse: () => throw "Unable to find $type");
  }

  GenericSystem getGenericSystem(Type type) {
    return genericSystems.firstWhere((gs) => gs.runtimeType == type, orElse: () => throw "Unable to find $type");
  }

  // Entity-related code

  void registerEntity(String entityType, EntityBuilder builder) {
    _entityBuilders[entityType] = builder;
  }

  Entity fetchEntity(String entityType) {
    var builder = _entityBuilders[entityType];
    if (builder == null) { throw "Cannot find builder for $entityType"; }
    return builder.build(entityType);
  }
}

class EmitEvent {
  String message;
  Entity nearEntity;
  Entity fromEntity;
  Entity toEntity;
  EmitEvent(this.message, {this.nearEntity, this.fromEntity, this.toEntity});
}
