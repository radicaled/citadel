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

// Good lord forgive me.
GuiContainer gui;

void constructGui(DisplayObjectContainer layer) {
  gui = new GuiContainer(layer);
  gui.build();
}

// Good lord forgive me!!!!
class GuiContainer {
  Button useButton;
  Button pickupButton;
  Button attackButton;

  Vbox actionContainer;

  DisplayObjectContainer container;

  GuiContainer(this.container);

  void build() {
    GameGui.construct((dsl) {
      useButton = dsl.button('Use');
      attackButton = dsl.button('Attack');
      pickupButton = dsl.button('Pickup');

      actionContainer = dsl.vbox(100, 100, (vbox) {
        vbox.x = 200;
        vbox.y = 400;
        vbox.addAll([useButton, attackButton, pickupButton]);
      });
    });

    container.addChild(actionContainer);
  }
}
