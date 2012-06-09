import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.ScrollingList;


class ModList extends ScrollingList
{
  /* CONSTANTS */
	
	
	
	
  /* STAGE ELEMENTS */
	
	public var selectorCenter: MovieClip;
	public var selectorTop: MovieClip;
	public var selectorBottom: MovieClip;
	
	
  /* PRIVATE VARIABLES */

	
	

  /* PROPERTIES */
	
	
	
	
  /* CONSTRUCTORS */
	
	public function ModList()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoad(): Void
	{
		trace("loaded");
	}

  /* PRIVATE FUNCTIONS */

}