import skyui.components.list.ScrollingList;
import skyui.components.list.BasicListEntry;
import skyui.util.ConfigManager;


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
		itemIcon.loadMovie(ConfigManager.getValue("Appearance", "icons.source").toString());
		
		itemIcon._visible = false;
		equipIcon._visible = false;
		
		for (var i = 0; this["textField" + i] != undefined; i++)
			this["textField" + i]._visible = false;
	}
}