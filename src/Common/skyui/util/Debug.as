import Date;

class skyui.util.Debug
{
  /* PRIVATE VARIABLES */
	private static var _buffer: Array = [];

  /* STATIC PUBLIC FUNCTIONS */
	static public function log(a_text: String): Void
	{
		var date: Date = new Date;
		var hh: String = String(date.getHours());
		var mm: String = String(date.getMinutes());
		var ss: String = String(date.getSeconds());
		var ff: String = String(date.getMilliseconds());

		var dateTime: String = "[" + ((hh.length < 2) ? "0" + hh : hh);
		dateTime += ":" + ((mm.length < 2) ? "0" + mm : mm);
		dateTime += ":" + ((ss.length < 2) ? "0" + ss : ss);
		dateTime += ":" + ((ff.length < 2) ? "00" + ff : (ff.length < 3) ? "0" + ff : ff);
		dateTime += "]";

		// Flush buffer
		if (_global.skse && _buffer.length > 0) {
			for(var i = 0; i < _buffer.length; i++)
				skse.Log(_buffer[i]);			
			_buffer.splice(0);
		}

		for(var i = 0; i < arguments.length; i++) {
			var str = dateTime + " " + a_text;

			if (_global.skse)
				skse.Log(str);
			else
				_buffer.push(str);
		}
	}

	static public function getFunctionName(a_func: Function): String
	{
		var name: String = getFunctionNameRecursive(a_func, _global);
		//if (!name) name = getFunctionNameRecursive(a_func, _root);
		return name;
	}

	static public function getFunctionNameRecursive(a_func: Function, a_root: Object): String
	{
		var func: Function = a_func;
		var root: Object = a_root;

		if (!root)
			return null;

		// Iterate over classes
		// Classes are function instances with a prototype
		for (var s: String in root) {
			if (root[s] instanceof Function && root[s].prototype != null) {
				// Found a class.
				// Iterate over class static members to see if there's a match
				for (var t: String in root[s])
					if(root[s][t] == func)
						return (s + "." + t);
				// Loop over the class' prototype to look for instance methods
				var instance:Object = root[s].prototype;
				/*
				_global.ASSetPropFlags (target: Object, propList, ft: Number, ff: Number): Void

				PARAMETERS:

				target, the target object to be set prop flags. propList, list of property names, Array of Strings or a comma delimited String, null for all properties. ft, flag bits to be added to the target properties. ff, flag bits to be removed from target properties.

				RETURN:

				Nothing.

				DESCRIPTION:

				Flag is a 3-bits binary, bit 0x01, enumeration-protected; bit 0x02, deletion-protected; bit 0x04, write-protected.

				ASSetPropFlags uses the following formula to calculate the new flag from the old one: fn=fo & (~ff) | ft, where fo is the original flag, ff and ft from the parameters.
				*/
				_global.ASSetPropFlags(instance, null, 0x00, 0x01);
				for (var t: String in instance)
					if(instance[t] == func)
						return (s + "." + t);
				_global.ASSetPropFlags(instance, null, 0x01, 0x00);
			}
		}

		// Iterate over this package's sub packages.
		// Sub packages have are Object types
		for (var s: String in root) {
			if (typeof(root[s]) == "object") {
				var name: String = getFunctionNameRecursive(func, root[s]);

				if (name)
					return (s + "." + name);
			}
		}

		return null;
	}

}


