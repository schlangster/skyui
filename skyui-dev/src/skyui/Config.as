import gfx.events.EventDispatcher;
import skyui.Util;
import skyui.Defines;

dynamic class skyui.Config
{
	static var COL_TYPE_ITEM_ICON = 0;
	static var COL_TYPE_EQUIP_ICON = 1;
	static var COL_TYPE_TEXT = 2;
	static var COL_TYPE_NUMBER = 3;
	static var COL_TYPE_NAME = 4;
	
	static private var _instance:Config;
	
	static private var _initialized:Boolean = initialize();
	static private var _loaded:Boolean = false;
	
	static private var _constantTable:Object = {
		ASCENDING: 0,
		DESCENDING: Array.DESCENDING,
		CASEINSENSITIVE: Array.CASEINSENSITIVE,
		NUMERIC: Array.NUMERIC,
		ITEM_ICON: COL_TYPE_ITEM_ICON,
		EQUIP_ICON: COL_TYPE_EQUIP_ICON,
		NUMBER: COL_TYPE_NUMBER,
		NAME: COL_TYPE_NAME,
		TEXT: COL_TYPE_TEXT,
		CAT_ALL: Defines.FLAG_ITEM_ALL,
		CAT_WEAPONS: Defines.FLAG_ITEM_WEAPONS,
		CAT_ARMOR: Defines.FLAG_ITEM_ARMOR,
		CAT_SHOUTS: Defines.FLAG_MAGIC_SHOUTS,
		CAT_POWERS: Defines.FLAG_MAGIC_POWERS,
		CAT_ACTIVE_EFFECT: Defines.FLAG_MAGIC_ACTIVE_EFFECT
	};
	
	// Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;
	
	// Ok, this may not be the best solution but I can't think of anything else right now
	// Just hope that loading is done once you need the values :)
	public static function initialize():Boolean
	{
		if (_initialized) {
			return;
		}
			
		_instance = new Config();
		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load("skyui.cfg");
		
		return true;
	}
	
	static function get instance():Config
	{
		return _instance;
	}

	private function Config()
	{
		EventDispatcher.initialize(this);
	}
	
	function get loaded():Boolean
	{
		return _loaded;
	}

	static function parseData(a_data:Array)
	{
		var lines = a_data.split("\r\n");
		if (lines.length == 1) {
			lines = a_data.split("\n");
		}

		var section = undefined;

		for (var i = 0; i < lines.length; i++) {

			// Comment
			if (lines[i].charAt(0) == ";") {
				continue;
			}

			// Section start
			if (lines[i].charAt(0) == "[") {
				section = lines[i].slice(1, lines[i].lastIndexOf("]"));
//				trace("Section: [" + section + "]");
				
				if (_instance[section] == undefined) {
					_instance[section] = {};
				}
				continue;
			}

			if (lines[i].length < 3 || section == undefined) {
				continue;
			}
			
			// Get raw key string
			var key = Util.clean(lines[i].slice(0, lines[i].indexOf("=")));
			if (key == undefined) {
				continue;
			}
			// Prepare key subsections
			var a = key.split(".");
			var loc = _instance[section];
			for (var j=0; j<a.length-1; j++) {
				if (loc[a[j]] == undefined) {
					loc[a[j]] = {};
				}
				loc = loc[a[j]];
			}

			// Detect value type & extract
			var val = parseValueString(Util.clean(lines[i].slice(lines[i].indexOf("=") + 1)), _constantTable, _instance[section]);
			
			if (val == undefined) {
				continue;
			}
			
//			trace(key + "=" + val + "%");

			// Store val at config.section.a.b.c.d
			loc[a[a.length-1]] = val;
		}
		
		Config._loaded = true;
		_instance.dispatchEvent({type:"configLoad", config:_instance});
	}
	
	static function parseValueString(a_str:String, a_constantTable:Object, a_root:Object):Object
	{
		if (a_str == undefined) {
			return undefined;
		}

		// Number?
		if (!isNaN(a_str)) {
			return Number(a_str);
			
		// Bool true?
		} else if (a_str.toLowerCase() == "true") {
			return true;
			
		// Bool false?
		} else if (a_str.toLowerCase() == "false") {
			return false;
			
		// Explicit String?
		} else if (a_str.charAt(0) == "'") {
			return Util.extract(a_str, "'", "'");
			
		// Entry property? - substituted later
		} else if (a_str.charAt(0) == "@") {
			return a_str;
			
		// List?
		} else if (a_str.charAt(0) == "<") {
			var values = Util.extract(a_str, "<", ">").split(",");
			for (var i=0; i<values.length; i++) {
				values[i] = parseValueString(Util.clean(values[i]), a_constantTable, a_root);
			}
			return values;
			
		// Flags?
		} else if (a_str.charAt(0) == "{") {
			var values = Util.extract(a_str, "{", "}").split("|");
			var flags = 0;
			for (var i=0; i<values.length; i++) {
				var t = parseValueString(Util.clean(values[i]), a_constantTable, a_root);
				if (isNaN(t)) {
					return undefined;
				}
				flags = flags | t;
			}
			return flags;
		
		// Constant?
		} else if (a_constantTable[a_str] != undefined) {
			return a_constantTable[a_str];
			
		// Top-level property?
		} else if (a_root[a_str] != undefined) {
			return a_root[a_str];
		}
		
		// Default String
		return a_str;
	}
}