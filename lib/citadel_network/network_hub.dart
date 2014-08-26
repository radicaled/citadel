part of citadel_network;

class NetworkHub {
  Stream stream;

  NetworkHub(Stream stream) {
    this.stream = stream.transform(_jsonTransformer)
      .transform(_setGamestateTransformer);
  }

  Stream on(String messageType) {
    return stream.where((msg) => msg.name == messageType);
  }
}
