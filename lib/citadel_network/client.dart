library citadel_network.client;

import 'dart:async';
import 'dart:convert';
import 'package:citadel/citadel_network/citadel_network.dart';

class ClientNetworkHub extends NetworkHub {
  Function sender;

  ClientNetworkHub(Stream stream, this.sender) : super(stream) {
    onLoadAssets    = on('load_assets');
    onAnimate       = on('animate');
    onFollowEntity  = on('follow_entity');
  }

  void send(String type, Map payload) {
    sender(JSON.encode({ 'type': type, 'payload': payload }));
  }

  void sendIntent(String intentName, {int targetEntityId, int withEntityId, String actionName, Map details}) {
    var payload = {
        'intent_name': intentName.toUpperCase(),
        'target_entity_id': targetEntityId,
        'with_entity_id': withEntityId,
        'action_name': actionName,
        'details': details
    };
    send('intent', payload);
  }

  // Connection commands

  void login(String name) {
    send('login', { 'name': name });
  }

  // Character commands

  void speak(String text) {
    sendIntent('speak', details: { 'text': text });
  }

  void look(int entityId) {
    sendIntent('look', targetEntityId: entityId);
  }

  void pickup(int entityId) {
    sendIntent('pickup', targetEntityId: entityId);
  }

  void attack(int entityId, {int withEntityId}) {
    sendIntent('attack', targetEntityId: entityId, withEntityId: withEntityId);
  }

  void move(String directionCommand) {
    sendIntent(directionCommand);
  }

  void interactWith(entityId, actionName, {int withEntityId}) {
    sendIntent('interact', targetEntityId: entityId, withEntityId: withEntityId, actionName: actionName);
  }

  // Utility commands

  void getActions(int entityId) {
    send('get_actions', { 'entity_id': entityId });
  }

  // Events

  Stream onLoadAssets;
  Stream onAnimate;
  Stream onFollowEntity;
}
