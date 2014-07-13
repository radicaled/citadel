library citadel_client;

// Dependencies
import 'dart:async';
import 'package:stagexl/stagexl.dart';
import 'package:citadel/game_ui/game_ui.dart';
// Graphics
part 'src/sprites/game_sprite.dart';

// UI
part 'src/ui/context_menu.dart';
part 'src/ui/context_menu_item.dart';

void constructGui(DisplayObjectContainer layer) {
  var vbox = new Vbox(100, 100);
  vbox.x = 200;
  vbox.y = 400;

  vbox.addChild(new Button('Use'));
  vbox.addChild(new Button('Pickup'));
  vbox.addChild(new Button('Attack'));

  layer.addChild(vbox);
}