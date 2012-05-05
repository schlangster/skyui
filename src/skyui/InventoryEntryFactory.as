import skyui.ScrollingList;

class skyui.InventoryEntryFactory extends skyui.BasicEntryFactory
{
  /* PRIVATE VARIABLES */
	
	// @override skyui.BasicEntryFactory
	private var _list: ScrollingList;
	
	
  /* CONSTRUCTORS */

	public function InventoryEntryFactory(a_list: ScrollingList, a_iconThemeName: String)
	{
		super(a_list, "ItemsListEntry", "skyui_icons_celtic.swf");
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// @override skyui.BasicEntryFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = super.createEntryClip(a_index);
		
		entryClip.itemIcon.loadMovie("skyui_icons_celtic.swf");
		
		for (var i = 0; entryClip["textField" + i] != undefined; i++)
			entryClip["textField" + i]._visible = false;
		
		entryClip.itemIcon._visible = false;
		entryClip.equipIcon._visible = false;
		
		entryClip.viewIndex = -1;
		
		return entryClip;
	}
}