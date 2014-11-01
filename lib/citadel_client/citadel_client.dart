library citadel_client;

// Dependencies
import 'dart:html';
import 'dart:async';
import 'package:stagexl/stagexl.dart';
import 'package:citadel/game_ui/game_ui.dart';
// Graphics
part 'src/sprites/game_sprite.dart';

// UI
part 'src/ui/context_menu.dart';
part 'src/ui/context_menu_item.dart';

// Good lord forgive me.
GuiContainer gui;

void constructGui(DisplayObjectContainer layer) {
  gui = new GuiContainer(layer);
  gui.build();
}

void constructHtmlGui() {
//  Element temp = query('#action_template');
//  Element actual = new Element.html(temp.innerHtml);
//  query('#container').append(actual);
}
