import flash.utils.*;
import mx.utils.Delegate;

import gfx.events.EventDispatcher;

import skyui.util.GlobalFunctions;


class DataLoader
{		
  /* INITIALIATZION */
  
	public function DataLoader()
	{
		GlobalFunctions.addArrayFunctions();
		
		EventDispatcher.initialize(this);
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	public function loadFile(a_path: String): Void
	{		
		var lv = new LoadVars();
		lv.onData = Delegate.create(this, parseData);
		lv.load(a_path);
	}
	
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;


  /* PRIVATE FUNCTIONS */
  
	private function parseData(a_data: Array): Void
	{
		var dataObj = {};
		
		var lines = a_data.split("\r\n");
		if (lines.length == 1)
			lines = a_data.split("\n");

		for (var i = 0; i < lines.length; i++) {

			// Comment
			if (lines[i].charAt(0) == ";")
				continue;

			if (lines[i].length < 3)
				continue;
			
			// Get raw key string
			var key = GlobalFunctions.clean(lines[i].slice(0, lines[i].indexOf("=")));
			if (key == undefined)
				continue;
				
			// Prepare key subsections
			var a = key.split(".");
			var loc = dataObj;
			for (var j=0; j<a.length-1; j++) {
				if (loc[a[j]] == undefined)
					loc[a[j]] = {};
				loc = loc[a[j]];
			}

			// Detect value type & extract
			var val = parseValueString(
				GlobalFunctions.clean(lines[i].slice(lines[i].indexOf("=") + 1)),
				dataObj,
				loc,
				a[a.length-1]);
			
			if (val == undefined)
				continue;

			// Store val at dataObj.a.b.c.d
			loc[a[a.length-1]] = val;
		}
	
		
		dispatchEvent({type: "dataLoaded", data: dataObj});
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

		// Null?
		} else if (a_str.toLowerCase() == "null") {
			return undefined;
			
		// Explicit String?
		} else if (a_str.charAt(0) == "'") {
			return GlobalFunctions.extract(a_str, "'", "'");

		// List?
		} else if (a_str.charAt(0) == "<") {
			if (a_str.charAt(1) == ">")
				return new Array();
			var values = GlobalFunctions.extract(a_str, "<", ">").split(",");
			for (var i=0; i<values.length; i++)
				values[i] = parseValueString(GlobalFunctions.clean(values[i]), a_root, values, i);
				
			return values;
		}
		
		// Default String
		return a_str;
	}
}