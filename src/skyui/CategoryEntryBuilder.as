import skyui.CategoryList;

class skyui.CategoryEntryBuilder extends skyui.BasicEntryBuilder
{
  /* PRIVATE VARIABLES */
  
   	// override skyui.BasicEntryFactory
	private var _list: CategoryList;
	
	
  /* CONSTRUCTORS */	

	public function CategoryEntryBuilder(a_list: CategoryList, a_iconThemeName: String)
	{
		super(a_list, "CategoryListEntry", "skyui_icons_celtic.swf");
		_list = a_list;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// override skyui.BasicEntryFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = super.createEntryClip(a_index);
		
		if (_list.iconArt[a_index] != undefined) {
			entryClip.iconLabel = _list.iconArt[a_index];
			entryClip.icon.loadMovie(_iconThemeName);
		}
		
		return entryClip;
	}
}