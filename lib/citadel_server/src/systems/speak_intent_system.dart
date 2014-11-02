part of citadel_server;

void speakIntentSystem(Intent intent) {
  var speaker = findEntity(intent.invokingEntityId);
  var text = intent.details['text'];
  if (text == null) { return; }
  speaker.use(Name, (name) => world.emit('${name.text}: $text', nearEntity: speaker));
}
