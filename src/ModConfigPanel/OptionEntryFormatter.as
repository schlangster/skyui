import skyui.components.list.BasicList;
import skyui.components.list.IEntryFormatter;

class OptionEntryFormatter implements IEntryFormatter
{
  /* CONSTANTS */
	
	public static var STATES: Array = [
		"empty",	// 0
		"toggle",	// 1
		"text",		// 2
		"menu",		// 3
		"slider",	// 4
		"header"	// 5
	];
	
	
  /* PRIVATE VARIABLES */
  
	private var _list: BasicList;
	
	
  /* CONSTRUCTORS */
	
	public function OptionEntryFormatter(a_list: BasicList)
	{
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setEntry(a_entryClip: MovieClip, a_entryObject: Object): Void
	{
		if (a_entryClip == undefined)
			return;
			
		a_entryClip.gotoAndStop(STATES[a_entryObject.type]);
	}
}