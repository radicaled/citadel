A shitty SS13 clone.

= TODO

* TMX parser
	* Base64 stuff: http://stackoverflow.com/questions/15957427/how-do-i-encode-a-dart-string-in-base64
	* Uncompressing gzip in the browser: http://japhr.blogspot.com/2013/05/bdding-dart-gzip-with-js-interop.html
	* Uncompressing zlib in the browser: https://github.com/imaya/zlib.js || https://github.com/dankogai/js-deflate (?)
	* Uncompressing zlib on the server (?): http://api.dartlang.org/docs/bleeding_edge/dart_io/ZLibDeflater.html
	
	* Port https://github.com/dankogai/js-deflate ?
		* js-deflate being a port of http://www.onicos.com/staff/iz/amuse/javascript/expert/inflate.txt
		* js-inflate being an almost copy of the source: https://github.com/augustl/js-inflate
	-- Alternatives
	* melonJS has built-in TMX parser: https://github.com/melonjs/melonJS/tree/master/src/level
	* TMXjs exists: https://github.com/cdmckay/tmxjs
* Render TMX files on canvas


Assets in /assets/icon contributed by https://github.com/tgstation/-tg-station and inherit its CC BY-SA 3.0 license (http://creativecommons.org/licenses/by-sa/3.0/)