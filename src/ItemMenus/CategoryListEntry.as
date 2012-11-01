import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


class CategoryListEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */

	private var _iconLoader: MovieClipLoader;
	private var _iconLoaded: Boolean = false;
	private var _iconLabel: String;
	
  /* STAGE ELMENTS */
  
  	public var icon: MovieClip;

	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		super.initialize();
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);

		_iconLabel = CategoryList(a_state.list).iconArt[a_index];

		_iconLoader.loadClip(a_state.iconSource, icon);
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

	// @implements MovieClipLoader
	private function onLoadInit(a_mc: MovieClip): Void
	{
		_iconLoaded = true;
		a_mc.gotoAndStop(_iconLabel);
	}

	// @implements MovieClipLoader
	private function onLoadError(a_mc: MovieClip, a_errorCode: String): Void
	{
		//skyui.util.Debug.log("onLoadError", a_mc, a_errorCode);
	}
}