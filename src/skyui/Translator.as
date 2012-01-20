class skyui.Translator
{
	private static var _translator:TextField;
	
	private static var _cache = {};
	
	static function translate(a_str:String):String
	{
		if (_cache[a_str]) {
			return _cache[a_str];
		}
		
		if (_translator == undefined) {
			_translator = _root.createTextField("_translator", _root.getNextHighestDepth(), 0, 0, 1, 1);
			_translator._visible = false;
		}
		
		_translator.SetText(a_str);
		_cache[a_str] = _translator.text;
		
		return _translator.text;
	}
}