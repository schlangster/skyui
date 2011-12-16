class skyui.Util
{
	static function extract(a_str:String, a_startChar:String, a_endChar:String):String
	{
		return a_str.slice(a_str.indexOf(a_startChar)+1, a_str.lastIndexOf(a_endChar));
	}
	
	// Remove comments and leading/trailing white space
	static function clean(a_str:String):String
	{
		if (a_str.indexOf(";") > 0) {
			a_str = a_str.slice(0, a_str.indexOf(";"));
		}
		
		var i = 0;
		while (a_str.charAt(i) == " " || a_str.charAt(i) == "\t") {i++; }
		
		var j = a_str.length-1;
		while (a_str.charAt(j) == " " || a_str.charAt(j) == "\t") { j--; }
		
		return a_str.slice(i,j+1);
	}
	
	static function addArrayFunctions()
	{
		Array.prototype.indexOf = function (a_element):Number
		{
			for (var i=0; i<this.length; i++) { 
				if (this[i] == a_element) { 
					return i;
				}
			}
			return undefined;
		};
	}
}