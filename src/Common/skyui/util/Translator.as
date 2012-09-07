import gfx.events.EventDispatcher;


class skyui.util.Translator
{
  /* PRIVATE VARIABLES */
	
	private static var _translator:TextField;

	// This is used to cache the native translated strings
	private static var _cache = {};
	
	// This holds custom translated strings from the config. Takes priority over native translations
	private static var _dict = {};
	
	
  /* PUBLIC FUNCTIONS */
  
	public static function translate(a_str:String):String
	{
		if (_translator == undefined) {
			_translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
			_translator._visible = false;
		}
		
		if (a_str.charAt(0) != "$")
			return a_str;
		
		if (_cache[a_str])
			return _cache[a_str];
		
		_translator.text = a_str;
		_cache[a_str] = _translator.text;
		
		return _translator.text;
	}
}