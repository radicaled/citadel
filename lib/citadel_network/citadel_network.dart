library citadel_network;

import 'dart:async';
import 'dart:convert';

part 'network_hub.dart';
part 'stream_transformers.dart';

class NetworkMessage {
  String name;
  Map payload;

  NetworkMessage.fromJson(Map json) {
    name = json['type'];
    payload = json['payload'];
  }

  toString() {
    return "GameEvent($name: $payload)";
  }
}


abstract class NetworkConnection {
  Stream get incoming;
  void send(String message);
}
