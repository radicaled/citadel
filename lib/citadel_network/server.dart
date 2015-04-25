library citadel_network.server;

import 'dart:async';
import 'dart:convert';
import 'package:citadel/citadel_network/citadel_network.dart';

/**
 * Server Network Hub sends messages to client.
 *
 * Messages are not sent until [send] or [broadcast] are called.
 */
class ServerNetworkHub {
  final List<Map> _queuedMessages = [];
  bool get hasQueuedMessages => _queuedMessages.isNotEmpty;
  bool get shouldBatchMessages => _queuedMessages.length > batchingThreshhold;
  static const int batchingThreshhold = 2;
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

  void custom(String type, Map payload) {
    _queue(type, payload);
  }

  /// Drains the message queue, sending all queued messages to [connection]
  void send(NetworkConnection connection) {
    List messages = shouldBatchMessages ? [_batch(_queuedMessages)] : _queuedMessages;
    messages.map(JSON.encode).forEach(connection.send);
    _queuedMessages.clear();
  }

  /// Drains the message queue, sending all queued messages to all [connections].
  void broadcast() {
    List messages = shouldBatchMessages ? [_batch(_queuedMessages)] : _queuedMessages;
    messages.map(JSON.encode).forEach((m) => connections.forEach((c) => c.send(m)));
    _queuedMessages.clear();
  }

  // High level API for sending messages to clients

  void loadAssets({List<String> animationUrls}) {
    _queue('load_assets', { 'animation_urls': animationUrls});
  }

  void animate(int entityId, String animationName, {elapsed: 0}) {
    _queue('animate', { 'entity_id': entityId, 'animation_name': animationName, 'elapsed': elapsed });
  }

  void createEntity(int entityId, {int x, int y, int z, List tilePhrases, String name}) {
    _queue('create_entity', {
        'x': x,
        'y': y,
        'z': z,
        'tile_phrases': tilePhrases,
        'entity_id': entityId,
        'name': name
    });
  }

  void followEntity(int entityId) {
    _queue('follow_entity', {
      'entity_id': entityId
    });
  }

  // Event-related code

  Stream<ClientMessage> on(String name) =>
    masterStream.where((cm) => cm.name == name);

  Stream<ClientMessage> onLogin;
  Stream<ClientMessage> onIntent;

  void _queue(String type, Map payload) =>
    _queuedMessages.add({ 'type': type, 'payload': payload });

  Map _batch(Iterable<Map> messages) {
    return {
      'type': 'batched',
      'payload': {
        'messages': messages.toList()
      }
    };
  }
}

class ClientMessage extends NetworkMessage {
  NetworkConnection connection;
  ClientMessage.fromJson(Map json, this.connection) : super.fromJson(json);

  String toString() =>
    "ClientMessage($name: $payload)";
}
