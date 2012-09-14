import skse;
import Date;

class skyui.util.Debug
{
  /* PRIVATE VARIABLES */
  
	private static var _buffer: Array = [];
	
	
	public static function log(a_text: String)
	{
		var date: Date = new Date;
		var hh: String = String(date.getHours());
		var mm: String = String(date.getMinutes());
		var ss: String = String(date.getSeconds());
		
		var dateTime: String = "[" + ((hh.length < 2) ? "0" + hh : hh);
		dateTime += ":" + ((mm.length < 2) ? "0" + mm : mm);
		dateTime += ":" + ((ss.length < 2) ? "0" + ss : ss);
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
}