import skse;
import Date;

class skyui.util.Debug
{
	static function trace(/* arguments */)
	{
		
		var date: Date = new Date;
		
		var MM: String = String(date.getMonth() + 1);
		var DD: String = String(date.getDate());
		var YYYY: String = String(date.getFullYear());
		var hours: Number = date.getHours();
		var hh: String;
		var mm: String = String(date.getMinutes());
		var ss: String = String(date.getSeconds());
		var ap: String;
		
		if (hours > 12) {
			hh = String(hours - 12);
			ap = "PM"
		} else {
			hh = String(hours);
			ap = "AM"
		}
		
		var dateTime: String = "[" + ((MM.length < 2) ? "0" + MM : MM);
		dateTime += "/" + ((DD.length < 2) ? "0" + DD : DD);
		dateTime += "/" + YYYY;
		dateTime += " - " + ((hh.length < 2) ? "0" + hh : hh);
		dateTime += ":" + ((mm.length < 2) ? "0" + mm : mm);
		dateTime += ":" + ((ss.length < 2) ? "0" + ss : ss);
		dateTime += ap + "]";
		
		for(var i: Number = 0; i < arguments.length; i++)
			skse.Log(dateTime + " " + String(arguments[i]));
	}
}