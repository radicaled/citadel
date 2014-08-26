library citadel_network;

import 'dart:async';
import 'dart:convert';

part 'network_hub.dart';
part 'stream_transformers.dart';

class Message {
  String name;
  Map payload;

  Message.fromJson(Map json) {
    name = json['type'];
    payload = json['payload'];
  }

  toString() {
    return "GameEvent($name: $payload)";
  }
}
