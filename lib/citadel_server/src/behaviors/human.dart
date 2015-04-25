part of behaviors;

class HumanUseBehavior extends Behavior {
  final triggers = ['use'];

  update(proxy, target) {
    var name = target.has([Name]) ? target[Name].text : 'something';
    world.emit('You recklessly fiddle with $name', fromEntity: proxy, toEntity: proxy);
    target.receive('use', proxy);
  }
}