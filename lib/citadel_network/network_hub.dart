part of citadel_network;

class NetworkHub {
  Stream stream;

  NetworkHub(Stream stream) {
    var transformer = new StreamTransformer.fromHandlers(handleData: (value, sink) {
      var json = JSON.decode(value);
      // TODO: hack >:(
      if (json['type'] == 'set_gamestate') {
        json['payload']['messages'].forEach((submessage) {
          sink.add(new Message.fromJson(submessage));
        });
      } else {
        sink.add(new Message.fromJson(json));
      }
    });

    this.stream = stream.transform(transformer);
  }

  Stream on(String messageType) {
    return stream.where((msg) => msg.name == messageType);
  }
}
