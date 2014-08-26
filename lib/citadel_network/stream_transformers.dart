part of citadel_network;

StreamTransformer _jsonTransformer = new StreamTransformer.fromHandlers(handleData: (value, sink) {
  var json = JSON.decode(value);
  sink.add(new Message.fromJson(json));
});

StreamTransformer _setGamestateTransformer = new StreamTransformer.fromHandlers(handleData: (message, sink) {
  if(message.name == 'set_gamestate') {
    message.payload['messages'].forEach((submsg) => sink.add(new Message.fromJson(submsg)));
  } else {
    sink.add(message);
  }
});
