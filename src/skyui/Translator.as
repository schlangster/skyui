import gfx.events.EventDispatcher;

class skyui.Translator
{
	private static var _translator:TextField;
	private static var _initialized:Boolean = initialize();
	private static var _language:String;
	
	// The instance is only used for the EventDispatcher
	static private var _instance:Translator;

	// This is used to cache the native translated strings
	private static var _cache = {};
	
	// This holds custom translated strings from the config. Takes priority over native translations
	private static var _dict = {};
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	
	static function initialize():Boolean
	{
		_translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
		_translator._visible = false;


		// Can't think of a better non-SKSE way to determine the language.
		// Non-SKSE because the functions are not registerd in the static initializer yet.
		var testStr = translate("$VALUE");
		
		if (testStr == "CENA") {
			_language = "czech";
			
		} else if (testStr == "VALUE") {
			_language = "english";
			
		} else if (testStr == "VALEUR") {
			_language = "french";
			
		} else if (testStr == "WERT") {
			_language = "german";
			
		} else if (testStr == "VALORE") {
			_language = "italian";
			
		} else if (testStr == "WARTOŚĆ") {
			_language = "polish";
			
		} else if (testStr == "Стоимость") {
			_language = "russian";
			
		} else if (testStr == "VALOR") {
			_language = "spanish";
			
		} else {
			_language = "english";
		}

		_instance = new Translator();
		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load("skyui_translate.txt");
		
		return true;
	}
	
	static function get instance():Translator
	{
		return _instance;
	}

	private function Translator()
	{
		EventDispatcher.initialize(this);
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
		
		_instance.dispatchEvent({type:"translationLoad"});
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
		
		_translator.text = a_str;
		_cache[a_str] = _translator.text;
		
		return _translator.text;
	}
}