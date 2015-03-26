import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


class IconTabListEntry extends BasicListEntry
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

		_iconLabel = IconTabList(a_state.list).iconArt[a_index];
		_iconSize = IconTabList(a_state.list).iconSize;
		
		icon.gotoAndStop(_iconLabel);
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		enabled = a_entryObject.enabled;
		
		if (a_entryObject.divider == true) {
			_alpha = 100;
		} else if (!enabled) {
			_alpha = 15;
		} else if (a_entryObject == a_state.list.selectedEntry) {
			_alpha = 100;
		} else {
			_alpha = 50;
		}
	}


  /* PRIVATE FUNCTIONS */
}