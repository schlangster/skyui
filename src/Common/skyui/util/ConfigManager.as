import gfx.events.EventDispatcher;

import skyui.components.list.ListLayout;
import skyui.util.GlobalFunctions;


class skyui.util.ConfigManager
{
  /* CONSTANTS */
  
	private static var CONFIG_PATH = "skyui/config.txt";
	
	
  /* PRIVATE VARIABLES */
  
	private static var _constantTable: Object = {
		
		ASCENDING: 0,
		DESCENDING: Array.DESCENDING,
		CASEINSENSITIVE: Array.CASEINSENSITIVE,
		NUMERIC: Array.NUMERIC
	};
	
	private static var _extConstantTables = [];
	
	private static var _eventDummy: Object;
	
	private static var _loaded: Boolean;
	
	private static var _config: Object;
	
	
  /* INITIALIATZION */
  
  	private static var _initialized:Boolean = initialize();
  
	private static function initialize(): Boolean
	{
		if (_initialized)
			return;
			
		GlobalFunctions.addArrayFunctions();
		
		_eventDummy = {};
		EventDispatcher.initialize(_eventDummy);
		
		var lv = new LoadVars();
		lv.onData = parseData;
		lv.load(CONFIG_PATH);
		
		return true;
	}
	
	
  /* PAPYRUS INTERFACE */
  
  	// Key/value pairs "Section$k§e§y§" / "value"
	public static var out_overrides = {};
	public static var in_overrideKeys = [];
	
	public static function setExternalOverrideKeys()
	{
		in_overrideKeys.splice(0);
		skse.Log("Called setExternalOverrideKeys");
		
		for (var i = 0; i < arguments.length; i++)
			in_overrideKeys[i] = arguments[i];
	}
	
	public static function setExternalOverrideValues()
	{
		skse.Log("Called setExternalOverrideValues");
		
		// Update happens in 2 phases.
		// First the keys are sent and stored, then the values are sent and immediately processed.
		for (var i = 0; i < arguments.length; i++)
			if (in_overrideKeys[i])
				parseExternalOverride(in_overrideKeys[i], arguments[i]);
		
		_eventDummy.dispatchEvent({type: "configUpdate", config: _config});				
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public static function registerLoadCallback(a_scope: Object, a_callBack: String): Void
	{
		// Not loaded yet
		if (!_loaded) {
			_eventDummy.addEventListener("configLoad", a_scope, a_callBack);
			return;
		}
		
		// Already loaded, generate event instantly.
		a_scope[a_callBack]({type: "configLoad", config: _config});
	}
	
	public static function registerUpdateCallback(a_scope: Object, a_callBack: String): Void
	{
		_eventDummy.addEventListener("configUpdate", a_scope, a_callBack);
	}
	
	public static function setConstant(a_name: String, a_value): Void
	{
		var type = typeof(a_value);
		if (type != "number" && type != "boolean" && type != "string")
			return;
		
		_constantTable[a_name] = a_value;
	}
	
	
	public static function addConstantTable(a_tbl: Object): Void
	{
		_extConstantTables.push(a_tbl);
	}
	
	public static function getConstant(a_name: String)
	{
		if (_constantTable[a_name] != undefined)
			return _constantTable[a_name];
			
		for (var i=0; i<_extConstantTables.length; i++)
			if (_extConstantTables[i][a_name] != undefined)
				return _extConstantTables[i][a_name];
				
		return undefined;
	}
	
	public static function setOverride(a_section: String, a_key: String, a_value, a_valueStr: String): Void
	{
		skse.Log("settingOverride " + a_section + " " + a_key + " " + a_value);
		
		// Allow to add new sections
		if (_config[a_section] == undefined)
			_config[a_section] = {};
		
		var a = a_key.split(".");

		// Prepare key subsections
		var loc = _config[a_section];

		var varContainer = null;
		if (a[0] == "vars")
			var varContainer = loc.vars[a[1]];
		
		for (var j=0; j<a.length-1; j++) {
			if (loc[a[j]] == undefined)
				loc[a[j]] = {};
			loc = loc[a[j]];
		}

		// Store value in config
		loc[a[a.length-1]] = a_value;
		
		// Running out of special characters soon... :)
		// Background: UI functions would try to look up keys.a.b.c, instead of keys["a.b.c"].
		// So we use a different delimiter, and keys.a§b§c works fine.
		var replacer = a_key.split(".");
		a_key = replacer.join("§");
		
		var ovrKey = a_section + "$" + a_key;
		out_overrides[ovrKey] = a_valueStr;
		skse.SendModEvent("SKI_setConfigOverride", ovrKey);
		
		// If we changed the value of a var, update all recorded references.
		if (varContainer) {
			for (var i=0; i<varContainer._refLocs.length; i++) {
				var varLoc = varContainer._refLocs[i];
				var varKey = varContainer._refKeys[i];
				varLoc[varKey] = a_value;
			}
		}
		
		_eventDummy.dispatchEvent({type: "configUpdate", config: _config});
	}
	
	private static function parseExternalOverride(a_key: String, a_valueStr: String)
	{
		var section = GlobalFunctions.clean(a_key.slice(0, a_key.indexOf("$")));
		var key = GlobalFunctions.clean(a_key.slice(a_key.indexOf("$") + 1));
		var val = parseValueString(GlobalFunctions.clean(a_valueStr), null);

		// Prepare key subsections - external keys use § as separator
		var a = key.split("§");
		var loc = _config[section];
		
		var varContainer = null;
		if (a[0] == "vars")
			var varContainer = loc.vars[a[1]];
		
		for (var j=0; j<a.length-1; j++) {
			if (loc[a[j]] == undefined)
				loc[a[j]] = {};
			loc = loc[a[j]];
		}
		
		loc[a[a.length-1]] = val;
		
		// If we changed the value of a var, update all recorded references.
		if (varContainer) {
			for (var i=0; i<varContainer._refLocs.length; i++) {
				var varLoc = varContainer._refLocs[i];
				var varKey = varContainer._refKeys[i];
				varLoc[varKey] = val;
			}
		}
		
		skse.Log("Received external override. section: " + section + " key: " + key + " val: " + val);
	}
	
	// Provide static accessor to the config to retrieve trivial values
	public static function getValue(a_section: String, a_key: String): Object
	{
		var a = a_key.split(".");
		var loc = _config[a_section];
		for (var j=0; j<a.length; j++) {
			if (loc[a[j]] == undefined)
				return null;
			loc = loc[a[j]];
		}
		
		return loc;
	}


  /* PRIVATE FUNCTIONS */

	private static function parseData(a_data:Array)
	{
		_config = {};
		
		var lines = a_data.split("\r\n");
		if (lines.length == 1)
			lines = a_data.split("\n");

		var section = undefined;

		for (var i = 0; i < lines.length; i++) {

			// Comment
			if (lines[i].charAt(0) == ";")
				continue;

			// Section start
			if (lines[i].charAt(0) == "[") {
				section = lines[i].slice(1, lines[i].lastIndexOf("]"));
//				trace("Section: [" + section + "]");
				
				if (_config[section] == undefined)
					_config[section] = {};
					
				continue;
			}

			if (lines[i].length < 3 || section == undefined)
				continue;
			
			// Get raw key string
			var key = GlobalFunctions.clean(lines[i].slice(0, lines[i].indexOf("=")));
			if (key == undefined)
				continue;
				
			// Prepare key subsections
			var a = key.split(".");
			var loc = _config[section];
			for (var j=0; j<a.length-1; j++) {
				if (loc[a[j]] == undefined)
					loc[a[j]] = {};
				loc = loc[a[j]];
			}

			// Detect value type & extract
			var val = parseValueString(GlobalFunctions.clean(lines[i].slice(lines[i].indexOf("=") + 1)), _config[section], loc, a[a.length-1]);
			
			if (val == undefined)
				continue;
			
//			trace(key + "=" + val + "%");

			// Store val at config.section.a.b.c.d
			loc[a[a.length-1]] = val;
		}
		
		_loaded = true;
		
		_eventDummy.dispatchEvent({type: "configLoad", config: _config});
	}
	
	private static function parseValueString(a_str: String, a_root: Object, a_loc: Object, a_key: String): Object
	{
		if (a_str == undefined)
			return undefined;
			
		var t = undefined;

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
			return GlobalFunctions.extract(a_str, "'", "'");
			
		// Entry property? - substituted later
		} else if (a_str.charAt(0) == "@") {
			return a_str;

		// Associative array?
		//TODO: This should properly check if [:,] is within a string
		//      As should the List parsing below
		} else if (a_str.charAt(0) == "<" && a_str.indexOf(":") != -1) {
			var assocArray = new Object();
			var pairs =  GlobalFunctions.extract(a_str, "<", ">").split(",");
			for (var i=0; i<pairs.length; i++) {
				var keyValue = pairs[i].split(":");
				if (keyValue.length != 2) {
					// If we don't have a pair we just ignore it
					continue;
				}
				var key = parseValueString(GlobalFunctions.clean(keyValue[0]), a_root, null, null);
				var val = parseValueString(GlobalFunctions.clean(keyValue[1]), a_root, assocArray, key);
				assocArray[key] = val;
			}
			return assocArray;

		// List?
		} else if (a_str.charAt(0) == "<") {
			if (a_str.charAt(1) == ">")
				return new Array();
			var values = GlobalFunctions.extract(a_str, "<", ">").split(",");
			for (var i=0; i<values.length; i++)
				values[i] = parseValueString(GlobalFunctions.clean(values[i]), a_root, values, i);
				
			return values;
			
		// Flags?
		} else if (a_str.charAt(0) == "{") {
			var values = GlobalFunctions.extract(a_str, "{", "}").split("|");
			var flags = 0;
			for (var i=0; i<values.length; i++) {
				var t = parseValueString(GlobalFunctions.clean(values[i]), a_root, a_loc, a_key);
				if (isNaN(t))
					return undefined;
					
				flags = flags | t;
			}
			return flags;
		
		// Constant?
		} else if ((t = getConstant(a_str)) != undefined) {
			return t;
			
		// Var?
		} else if (a_root.vars[a_str] != undefined) {
			// A variable might be updated later via overrides, in which case we'd have to re-evaluate previous
			// expressions that used it. To make that efficient, each variable stores it's references.
			// Because we can't store pointers, this has to be the object/key pair (aka loc/name).
			// Only works for scalar values so far.
			if (a_loc && a_key) {
				if (a_root.vars[a_str]._refLocs == undefined) {
					a_root.vars[a_str]._refLocs = [];
					a_root.vars[a_str]._refKeys = [];
				}
				
				// Can be either object+string or array+index
				a_root.vars[a_str]._refLocs.push(a_loc);
				a_root.vars[a_str]._refKeys.push(a_key);
			}
			
			return a_root.vars[a_str].value;
		}
		
		// Default String
		return a_str;
	}
}