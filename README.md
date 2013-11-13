A shitty SS13 clone.

= NOTE

Not a serious effort. Just using it to explore Dart.

= Notes

* TMX parser
    * Dealing with zlib:
        * make it the consumer's problem: accept a function that decompresses content
        * https://github.com/imaya/zlib.js on client
        * dart:convert on server

= TODO

* Deal with spritesheets -- stagexl pushes textureatlas like its crack, but that
  doesn't help with pre-existing spritesheets, does it?
  Ultimately, here's how the textureatlas frames are broken down and converted into
  seperate bitmap images for each sprite in the textureatlas:
  https://github.com/bp74/StageXL/blob/master/lib/src/display/BitmapData.dart#L83
  
* Render TMX files on canvas




Assets in /assets/icon contributed by https://github.com/tgstation/-tg-station and inherit its CC BY-SA 3.0 license (http://creativecommons.org/licenses/by-sa/3.0/)

* inflate.js license: MIT
  * originating repo: https://github.com/imaya/zlib.js / https://github.com/imaya/zlib.js/blob/9c5b4d981529db0f5db3d55f512b25a98ee2dede/bin/inflate.min.js
  * license file: https://github.com/imaya/zlib.js/blob/afa7c8dac3a561d8b0c1b5f91c59a131d1fb3550/LICENSE