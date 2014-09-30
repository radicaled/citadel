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
  Button lookButton;
  Button useButton;
  Button pickupButton;
  Button attackButton;

  Button heldItem;

  Label targetLabel;

  Vbox actionContainer;
  Vbox statusContainer;

  DisplayObjectContainer container;

  GuiContainer(this.container);

  void build() {
    GameGui.construct((dsl) {
      lookButton = dsl.button('Look');
      useButton = dsl.button('Use');
      attackButton = dsl.button('Attack');
      pickupButton = dsl.button('Pickup');
      heldItem = dsl.button('Held Item');

      targetLabel = dsl.label('');

      actionContainer = dsl.vbox(100, 100, (vbox) {
        vbox.x = 200;
        vbox.y = 400;
        vbox.addAll([lookButton, useButton, attackButton, pickupButton]);
        // TODO: move somewhere else
        vbox.add(targetLabel);
      });

      statusContainer = dsl.vbox(100, 100, (vbox) {
        vbox.x = 710;
        vbox.y = 50;
        vbox.add(heldItem);
        vbox.backgroundColor = Color.Red;
      });
    });

    container.addChild(actionContainer);
    container.addChild(statusContainer);
  }
}
