library citadel_network.client;

import 'dart:async';
import 'dart:convert';
import 'package:citadel/citadel_network/citadel_network.dart';

class ClientNetworkHub extends NetworkHub {
  Function sender;

  ClientNetworkHub(Stream stream, this.sender) : super(stream);

  void send(String type, Map payload) {
    sender(JSON.encode({ 'type': type, 'payload': payload }));
  }

  void login(String name) {
    send('login', { 'name': name });
  }
}
