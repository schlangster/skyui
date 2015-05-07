import skyui.defines.Input;

class skyui.util.GlobalFunctions
{
  /* PUBLIC FUNCTIONS */
	
	public static function extract(a_str: String, a_startChar: String, a_endChar: String): String
	{
		return a_str.slice(a_str.indexOf(a_startChar) + 1,a_str.lastIndexOf(a_endChar));
	}

	// Remove comments and leading/trailing white space
	public static function clean(a_str: String): String
	{
		if (a_str.indexOf(";") > 0)
			a_str = a_str.slice(0,a_str.indexOf(";"));

		var i = 0;
		while (a_str.charAt(i) == " " || a_str.charAt(i) == "\t")
			i++;

		var j = a_str.length - 1;
		while (a_str.charAt(j) == " " || a_str.charAt(j) == "\t")
			j--;

		return a_str.slice(i,j + 1);
	}

	public static function unescape(a_str: String): String 
	{
		a_str = a_str.split("\\n").join("\n");
		a_str = a_str.split("\\t").join("\t");
		return a_str;
	}

	private static var _arrayExtended = false;

	public static function addArrayFunctions(): Void
	{
		if (_arrayExtended)
			return;
			
		_arrayExtended = true;
		
		Array.prototype.indexOf = function (a_element): Number
		{
			for (var i=0; i<this.length; i++)
				if (this[i] == a_element)
					return i;
					
			return undefined;
		};
		
		Array.prototype.equals = function (a: Array): Boolean 
		{
			if (a == undefined)
				return false;
			
	    	if (this.length != a.length)
	        	return false;
			
	    	for (var i = 0; i < a.length; i++)
	        	if (a[i] !== this[i])
					return false;
					
	    	return true;
    	};
		
		Array.prototype.contains = function (a_element): Boolean 
		{
			for (var i=0; i<this.length; i++)
				if (this[i] == a_element)
					return true;
					
	    	return false;
    	};

    	_global.ASSetPropFlags(Array.prototype, ["indexOf", "equals", "contains"], 0x01, 0x00);
	}

	// Maps Unicode inputted character code to its CP819/CP1251 character code
	public static function mapUnicodeChar(a_charCode: Number): Number
	{
		//NUMERO SIGN
		if (a_charCode == 0x2116)
			return 0xB9;
			
		else if (0x0401 <= a_charCode && a_charCode <= 0x0491) {
			switch (a_charCode) {
				//CYRILLIC CAPITAL LETTER IO
				case 0x0401 :
					return 0xA8;
				//CYRILLIC CAPITAL LETTER UKRAINIAN IE
				case 0x0404 :
					return 0xAA;
				//CYRILLIC CAPITAL LETTER DZE
				case 0x0405 :
					return 0xBD;
				//CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
				case 0x0406 :
					return 0xB2;
				//CYRILLIC CAPITAL LETTER YI
				case 0x0407 :
					return 0xAF;
				//CYRILLIC CAPITAL LETTER JE
				case 0x0408 :
					return 0xA3;
				//CYRILLIC CAPITAL LETTER SHORT U
				case 0x040E :
					return 0xA1;
				//CYRILLIC SMALL LETTER IO
				case 0x0451 :
					return 0xB8;
				//CYRILLIC SMALL LETTER UKRAINIAN IE
				case 0x0454 :
					return 0xBA;
				//CYRILLIC SMALL LETTER DZE
				case 0x0455 :
					return 0xBE;
				//CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
				case 0x0456 :
					return 0xB3;
				//CYRILLIC SMALL LETTER YI
				case 0x0457 :
					return 0xBF;
				//CYRILLIC SMALL LETTER JE
				case 0x0458 :
					return 0xBC;
				//CYRILLIC SMALL LETTER SHORT U
				case 0x045E :
					return 0xA2;
				//CYRILLIC CAPITAL LETTER GHE WITH UPTURN
				case 0x0490 :
					return 0xA5;
				//CYRILLIC SMALL LETTER GHE WITH UPTURN
				case 0x0491 :
					return 0xA4;
				//Standard Cyrillic characters
				default :
					if (0x040F <= a_charCode && a_charCode <= 0x044F)
						return a_charCode - 0x0350;
			}
		}
		return a_charCode;
	}
	
	// Ex: format("Last {2}% longer", 100.66666)
	public static function formatString(a_str: String /*, ... */): String
	{
		if (arguments.length < 2)
			return a_str;
		
		var buf: String = "";
		var pos: Number = 0;
		for (var i: Number = 1; i < arguments.length; i++) {
			var start: Number = a_str.indexOf("{", pos);
			if (start == -1)
				return a_str;
				
			var end: Number = a_str.indexOf("}", pos);
			if (end == -1)
				return a_str;
				
			buf += a_str.slice(pos, start);
			var decimal: Number = Number(a_str.slice(start+1, end));
			var mult: Number = Math.pow(10, decimal);
			var valStr: String = (Math.round(arguments[i] * mult) / mult).toString();
			if (decimal > 0) {
				if (valStr.indexOf(".") == -1)
					valStr += ".";
				var t: Array = valStr.split(".");
				var fractLen: Number = t[1].length;
				while (fractLen++ < decimal)
					valStr += "0";
			}
			buf += valStr;
			pos = end+1;
		}
		
		buf += a_str.slice(pos);
		
		return buf;
	}
	
	public static function formatNumber(a_number: Number, a_decimal: Number): String
	{
		var valStr: String = a_number.toString().toLowerCase();
		var floatComponents: Array = valStr.split("e", 2);
		var mult = Math.pow(10, a_decimal);

		valStr = String((Math.round(parseFloat(floatComponents[0]) * mult) / mult));
		
		
		if (a_decimal > 0) {
				var dotIdx: Number = valStr.indexOf(".")
				if (dotIdx == -1) {
					dotIdx = valStr.length
					valStr += ".";
				}
		
				var decLen: Number = valStr.length - (dotIdx + 1);
				for (var i: Number = 0; decLen + i < a_decimal; i++)
					valStr += "0";
		}
			
		if (floatComponents[1] != undefined)
			valStr += "E" + floatComponents[1]
		
		return valStr;
	}
	
	public static function getMappedKey(a_control: String, a_context: Number, a_bGamepad: Boolean): Number
	{
		if (_global.skse == undefined)
			return -1;
		
		if (a_bGamepad == true) {
			return skse.GetMappedKey(a_control, Input.DEVICE_GAMEPAD, a_context);
		} else {
			var keyCode = skse.GetMappedKey(a_control, Input.DEVICE_KEYBOARD, a_context);
			if (keyCode == -1)
				keyCode = skse.GetMappedKey(a_control, Input.DEVICE_MOUSE, a_context);
			return keyCode;
		}
	}

	public static function hookFunction(a_scope: Object, a_memberFn: String, a_hookScope: Object, a_hookFn: String): Boolean
	{
		var memberFn: Function = a_scope[a_memberFn];
		if (memberFn == null || a_scope[a_memberFn] == null)
			return false;

		a_scope[a_memberFn] = function () {memberFn.apply(a_scope, arguments); a_hookScope[a_hookFn].apply(a_hookScope, arguments);}
		return true;
	}
	
	public static function getDistance(a: MovieClip, b: MovieClip): Number
	{
		var dx = b._x - a._x;
		var dy = b._y - a._y;
		return Math.sqrt(dx*dx + dy*dy);
	}
	
	public static function getAngle(a: MovieClip, b: MovieClip): Number
	{
		var dx = b._x - a._x;
		var dy = b._y - a._y;		
		return Math.atan2(dy, dx) * (180 / Math.PI);
	}
}