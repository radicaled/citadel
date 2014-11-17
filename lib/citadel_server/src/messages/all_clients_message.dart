part of citadel_server;

class AllClientsMessage extends SystemMessage {
  String type;
  Map payload;

  AllClientsMessage(this.type, this.payload) : super('ALL_CLIENTS_MESSAGE');
}
