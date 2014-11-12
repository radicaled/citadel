part of citadel_server;

void speakIntentSystem(Intent intent) {
  var speaker = findEntity(intent.invokingEntityId);
  String text = intent.details['text'];
  if (text == null || text.isEmpty) { return; }
  var _speak = () =>
    speaker.use(Name, (name) => world.emit('${name.text}: $text', nearEntity: speaker));

  var _command = () {
    switch(text) {
      case '/help':
        world.emit('Commands: none available yet', toEntity: speaker);
      break;
      default:
        world.emit('Unrecognized command; try /help', toEntity: speaker);
      break;
    }
  };

  if (text[0] == '/' && text.length > 2) {
    _command();
  } else {
    _speak();
  }

}
