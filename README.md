A shitty SS13 clone.

= NOTE

Not a serious effort. Just using it to explore Dart.

= TODO

* TMX parser
	* Base64 stuff: http://stackoverflow.com/questions/15957427/how-do-i-encode-a-dart-string-in-base64
	* Uncompressing gzip in the browser: http://japhr.blogspot.com/2013/05/bdding-dart-gzip-with-js-interop.html
	* Uncompressing zlib in the browser: https://github.com/imaya/zlib.js || https://github.com/dankogai/js-deflate (?)
	* Uncompressing zlib on the server (?): http://api.dartlang.org/docs/bleeding_edge/dart_io/ZLibDeflater.html

	* Port https://github.com/imaya/zlib.js ?
		* Really just need rawdeflate.js
		* MIT license, goddamn i hate dealing with licenses

	-- Alternatives
	* melonJS has built-in TMX parser: https://github.com/melonjs/melonJS/tree/master/src/level
	* TMXjs exists: https://github.com/cdmckay/tmxjs

	= Initial Plan
	* straight port of inflate.txt to Dart
	* parse TMX tilesets into raw xml
	* be able to deflate layer information
* Render TMX files on canvas


Assets in /assets/icon contributed by https://github.com/tgstation/-tg-station and inherit its CC BY-SA 3.0 license (http://creativecommons.org/licenses/by-sa/3.0/)