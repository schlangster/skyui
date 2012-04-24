import skyui.BSList;

class InventoryEntryFactory implements skyui.IEntryClipFactory
{
  /* CONSTANTS */
	
	public static var ENTRY_CLASS_NAME = "InventoryListEntry";
	
	
  /* PRIVATE VARIABLES */
	
	private var _inventoryList: BSList;
	
  /* CONSTRUCTORS */
  
	public function CategoryEntryFactory(a_list: CategoryList)
	{
		_categoryList = a_list;
	}
	
	
	// override skyui.DynamicList
	function createEntryClip(a_index:Number):MovieClip
	{
		var entryClip = this.createEntryClip(a_index);

		for (var i = 0; entryClip["textField" + i] != undefined; i++) {
			entryClip["textField" + i]._visible = false;
		}
		
		entryClip.itemIcon.loadMovie("skyui_icons_celtic.swf");
		
		entryClip.itemIcon._visible = false;
		entryClip.equipIcon._visible = false;
		
		entryClip.viewIndex = -1;

		return entryClip;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
   	// override skyui.IEntryClipFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = _inventoryList.attachMovie(ENTRY_CLASS_NAME, ENTRY_CLASS_NAME + a_index, _inventoryList.getNextHighestDepth());
		
		entryClip.onRollOver = function()
		{
			var inventoryList = this._parent;
			if (this.itemIndex != undefined)
				inventoryList.onItemRollOver(this.itemIndex, a_keyboardOrMouse);
			
			if (!inventoryList.listAnimating && !inventoryList.disableInput && this.itemIndex != undefined) {
				inventoryList.selectedIndex = this.itemIndex;
				inventoryList.isMouseDrivenNav = true;
			}
		};
		
		entryClip.onRollOut = function()
		{
			var categoryList = this._parent;
			
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined && this.enabled) {
				if (this.itemIndex != categoryList.selectedIndex)
					this._alpha = 50;
				
				categoryList.isMouseDrivenNav = true;
			}
		};

		entryClip.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			var inventoryList = this._parent;
			if (this.itemIndex != undefined)
				inventoryList.onItemPress(this.itemIndex, a_keyboardOrMouse);
		};

		entryClip.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			var inventoryList = this._parent;
			
			if (this.itemIndex != undefined)
				inventoryList.onItemPressAux(a_keyboardOrMouse,a_buttonIndex);
		};
		
		return entryClip;
	}
}