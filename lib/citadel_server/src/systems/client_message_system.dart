part of citadel_server;

class ClientMessageSystem extends MessageSystem {
  ServerNetworkHub hub;
  ClientMessageSystem(this.hub);

  Iterable<SystemMessage> filter(Iterable<SystemMessage> messages) =>
    messages.where((m) => m is AllClientsMessage);

  void process(SystemMessage message) {
    if (message is AllClientsMessage) { _processAllClients(message); }
  }

  void _processAllClients(AllClientsMessage msg) {
    hub
      ..custom(msg.type, msg.payload)
      ..broadcast();

  }
}
