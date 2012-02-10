class skyui.Translator
{
	private static var _translator:TextField;
	private static var _initialized:Boolean = initialize();
	private static var _language = "english";

	// This is used to cache the native translated strings
	private static var _cache = {};
	
	// This holds custom translated strings from the config. Takes priority over native translations
	private static var _dict = {};
	
	
	static function initialize():Boolean
	{
		_translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
		_translator._visible = false;

		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load("skyui_translate.txt");
		
		return true;
	}
	
	static function parseData(a_data:String)
	{
		var lines = a_data.split("\r\n");
		if (lines.length == 1) {
			lines = a_data.split("\n");
		}
		
		var lang = undefined;

		for (var i = 0; i < lines.length; i++) {
			// Section start
			if (lines[i].charAt(0) == "[") {
				lang = lines[i].slice(1, lines[i].lastIndexOf("]"));
//				trace("Language: [" + section + "]");
				
				if (_dict[lang] == undefined) {
					_dict[lang] = {};
				}
				continue;
			}

			if (lines[i].length < 3 || lang == undefined) {
				continue;
			}
			
			var a = lines[i].split("\t");
			
			if (a[0] != undefined && a[1] != undefined) {
				_dict[lang][a[0]] = a[1];
			}
		}
	}
	
	static function translate(a_str:String):String
	{
		if (a_str.charAt(0) != "$") {
			return a_str;
		}
		
		if (_dict[_language][a_str]) {
			return _dict[_language][a_str];
		}
		
		if (_cache[a_str]) {
			return _cache[a_str];
		}
		
		_translator.SetText(a_str);
		_cache[a_str] = _translator.text;
		
		return _translator.text;
	}
}