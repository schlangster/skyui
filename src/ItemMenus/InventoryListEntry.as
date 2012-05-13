import skyui.components.list.ScrollingList;
import skyui.components.list.BasicListEntry;


class InventoryListEntry extends BasicListEntry
{
  /* PROPERTIES */
	
	public var layoutUpdateCount: Number = -1;
	
	
  /* STAGE ELMENTS */
  
  	public var itemIcon: MovieClip;
  	public var equipIcon: MovieClip;
	
	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_list: ScrollingList): Void
	{
		itemIcon.loadMovie("skyui_icons_celtic.swf");
		
		itemIcon._visible = false;
		equipIcon._visible = false;
		
		for (var i = 0; this["textField" + i] != undefined; i++)
			this["textField" + i]._visible = false;
	}
	
	public function reset(): Void
	{
		// Do nothing.
	}
	
	
}