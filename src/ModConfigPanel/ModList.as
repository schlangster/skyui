import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.ScrollingList;


class ModList extends ScrollingList
{
  /* CONSTANTS */
	
  /* PRIVATE VARIABLES */

	private var _activeModIndex = -1;
	

  /* PROPERTIES */
	
	
	
	
  /* CONSTRUCTORS */
	
	public function ModList()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override ScrollingList
	public function onLoad(): Void
	{
		super.onLoad();
	}
	
	// @override ScrollingList
	public function UpdateList(): Void
	{
		super.UpdateList();
	}
	
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1 || a_buttonIndex != 1)
			return;
		
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	public function onItemRollOver(a_index: Number): Void
	{
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(a_index, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}

	public function onItemRollOut(a_index: Number): Void
	{
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		doSetSelectedIndex(-1, SELECT_MOUSE);
		isMouseDrivenNav = true;
	}
}