import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


class CategoryListEntry extends BasicListEntry
{
  /* PROPERTIES */
	
	public var iconLabel: String;
	
	
  /* STAGE ELMENTS */
  
  	public var icon: MovieClip;

	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		var iconArt: String = CategoryList(a_state.list).iconArt[a_index];
		
		if (iconArt != undefined) {
			iconLabel = iconArt;
			icon.loadMovie(a_state.iconSource);
		}
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
			_alpha = 15;
			enabled = false;
		} else if (a_entryObject == a_state.list.selectedEntry) {
			_alpha = 100;
			enabled = true;
		} else {
			_alpha = 50;
			enabled = true;
		}
	}
}