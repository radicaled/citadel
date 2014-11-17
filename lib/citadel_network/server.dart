library citadel_network.server;

import 'dart:async';
import 'dart:convert';
import 'package:citadel/citadel_network/citadel_network.dart';

class ServerNetworkHub {
  List<NetworkConnection> _connections = [];
  Map<NetworkConnection, StreamSubscription> _subscriptions = {};
  Iterable<NetworkConnection> get connections => _connections;
  StreamController<ClientMessage> _sc = new StreamController.broadcast();
  Stream<ClientMessage> masterStream;

  ServerNetworkHub() {
    masterStream    = _sc.stream;
    onLogin         = on('login');
    onIntent        = on('intent');
  }

  // Connection handling

  void addConnection(NetworkConnection connection) {
    var ss = connection.incoming
      .map((msg) => JSON.decode(msg))
      .map((json) => new ClientMessage.fromJson(json, connection))
      .listen((cm) => _sc.add(cm));

    _subscriptions[connection] = ss;
    _connections.add(connection);
  }

  void removeConnection(NetworkConnection connection) {
    var ss = _subscriptions[connection];
    if (ss != null) { ss.cancel(); }
    _connections.remove(connection);
  }

  // Code to send messages to client

  void send(String type, Map payload, NetworkConnection connection) {
    var message = JSON.encode({ 'type': type, 'payload': payload });
    connection.send(message);
  }

  void broadcast(String type, Map payload) {
    var message = JSON.encode({ 'type': type, 'payload': payload });
    connections.forEach((c) => c.send(message));
  }

  // Event-related code

  Stream<ClientMessage> on(String name) =>
    masterStream.where((cm) => cm.name == name);

  Stream<ClientMessage> onLogin;
  Stream<ClientMessage> onIntent;
}

class ClientMessage extends NetworkMessage {
  NetworkConnection connection;
  ClientMessage.fromJson(Map json, this.connection) : super.fromJson(json);

  String toString() =>
    "ClientMessage($name: $payload)";
}
