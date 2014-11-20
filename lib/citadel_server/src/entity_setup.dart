part of citadel_server;


void setupEntities(World world) {
  world.registerEntity('wall', new Wall()..world = world);
  world.registerEntity('human', new Human()..world = world);
  world.registerEntity('placeholder', new Placeholder()..world = world);
  world.registerEntity('floor', new Floor()..world = world);
  world.registerEntity('hvac', new Hvac()..world = world);
  world.registerEntity('multi_tool', new MultiTool()..world = world);
  world.registerEntity('command_door', new CommandDoor()..world = world);
  world.registerEntity('locker', new Locker()..world = world);
  world.registerEntity('gray_locker', new Locker()..world = world);
  world.registerEntity('arcade_machine', new ArcadeMachine()..world = world);
  world.registerEntity('plain_donut', new Donut()..world = world);
}
