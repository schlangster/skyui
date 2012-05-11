import skyui.components.list.BasicListEntry;
import skyui.CategoryList;


class skyui.CategoryListEntry extends BasicListEntry
{
  /* PROPERTIES */
	
	public var iconLabel: String;
	
	
  /* STAGE ELMENTS */
  
  	public var icon: MovieClip;
	
	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_list: CategoryList): Void
	{
		if (a_list.iconArt[a_index] != undefined) {
			iconLabel = a_list.iconArt[a_index];
			icon.loadMovie("skyui_icons_celtic.swf");
		}
	}
}