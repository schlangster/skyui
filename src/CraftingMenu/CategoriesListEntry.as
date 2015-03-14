import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


class CategoriesListEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */

	private var _iconLabel: String;
	private var _iconSize: Number;
	
	
  /* STAGE ELMENTS */
  
  	public var icon: MovieClip;

	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		super.initialize();

		_iconLabel = CategoriesList(a_state.list).iconArt[a_index];
		_iconSize = CategoriesList(a_state.list).iconSize;
		
		trace("GOTO " + _iconLabel);
		icon.gotoAndStop(_iconLabel);
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


  /* PRIVATE FUNCTIONS */
}