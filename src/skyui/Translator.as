import gfx.events.EventDispatcher;

// TODO: Overall this class is not pretty. Don't know how to do it better at the moment.

class skyui.Translator
{
	private static var _translator:TextField;
	private static var _initialized:Boolean = initialize();
	private static var _cache = {};
	
	static var _instance:Translator;
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	
	static function initialize():Boolean
	{
		_instance = new Translator();
		_translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
		_translator._visible = false;
		
		return true;
	}
	
	static function get instance():Translator
	{
		return _instance;
	}
	
	static function loadLanguage(a_str:String)
	{
		if (!a_str) {
			a_str = "english";
		} else {
			a_str = a_str.toLowerCase();			
		}
		
		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load("skyui/translations/" + a_str + ".txt");
	}
	
	static function parseData(a_data:String)
	{
		var lines = a_data.split("\r\n");
		if (lines.length == 1) {
			lines = a_data.split("\n");
		}

		for (var i = 0; i < lines.length; i++) {
			
			var a = lines[i].split("\t");
			
			if (a[0] != undefined && a[1] != undefined) {
				_cache[a[0]] = a[1];
			}
		}
		
		_instance.dispatchEvent({type:"translatorLoad"});
	}
	
	private function Translator()
	{
		EventDispatcher.initialize(this);
	}
	
	static function translate(a_str:String):String
	{
		if (a_str.charAt(0) != "$") {
			return a_str;
		}
		
		if (_cache[a_str]) {
			return _cache[a_str];
		}
		
		_translator.SetText(a_str);
		_cache[a_str] = _translator.text;
		
		return _translator.text;
	}
}