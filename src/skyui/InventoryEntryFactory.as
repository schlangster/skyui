import skyui.BSList;

class InventoryEntryFactory implements skyui.IEntryClipFactory
{
  /* CONSTANTS */
	
	public static var ENTRY_CLASS_NAME = "InventoryListEntry";
	
	private var _inventoryList: BSList;
	
  /* CONSTRUCTORS */
	
	
  /* PUBLIC FUNCTIONS */
  
   	// override skyui.IEntryClipFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = _inventoryList.attachMovie(ENTRY_CLASS_NAME, ENTRY_CLASS_NAME + a_index, _inventoryList.getNextHighestDepth());
		
		entryClip.onRollOver = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined) {
				_parent.doSetSelectedIndex(this.itemIndex, 0);
				_parent._bMouseDrivenNav = true;
			}
		};

		entryClip.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (this.itemIndex != undefined) {
				_parent.onItemPress(a_keyboardOrMouse);
				
				if (!_parent._bDisableInput && this.onMousePress != undefined) {
					this.onMousePress();
				}
			}
		};

		entryClip.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (this.itemIndex != undefined) {
				_parent.onItemPressAux(a_keyboardOrMouse,a_buttonIndex);
			}
		};
		
		return entryClip;
	}
}