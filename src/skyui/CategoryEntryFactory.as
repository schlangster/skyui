import skyui.CategoryList;

class skyui.CategoryEntryFactory implements skyui.IEntryClipFactory
{
  /* CONSTANTS */
	
	public static var ENTRY_CLASS_NAME = "CategoryListEntry";
	
	
  /* PRIVATE VARIABLES */
  
	private var _categoryList: CategoryList;
	
	
  /* CONSTRUCTORS */
	
	public function CategoryEntryFactory(a_list: CategoryList)
	{
		_categoryList = a_list;
		trace(_categoryList.selectedIndex);
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// override skyui.IEntryClipFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = _categoryList.attachMovie(ENTRY_CLASS_NAME, ENTRY_CLASS_NAME + a_index, _categoryList.getNextHighestDepth());
		
		if (_categoryList.iconArt[a_index] != undefined) {
			entryClip.iconLabel = _categoryList.iconArt[a_index];
			entryClip.icon.loadMovie("skyui_icons_celtic.swf");
		}
		
		entryClip.onRollOver = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined && this.enabled) {
				skse.Log(this.itemIndex + " vs " + _parent.selectedIndex);
				if (this.itemIndex != _parent.selectedIndex)
					this._alpha = 75;
					
				_parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.onRollOut = function()
		{
			if (!_parent.listAnimating && !_parent._bDisableInput && this.itemIndex != undefined && this.enabled) {
				if (this.itemIndex != _parent.selectedIndex)
					this._alpha = 50;
				
				_parent._bMouseDrivenNav = true;
			}
		};
		
		entryClip.onPress = function(a_mouseIndex, a_keyboardOrMouse)
		{
			if (this.itemIndex != undefined && !_parent.listAnimating && !_parent._bDisableInput && this.enabled) {
				_parent.selectedIndex = this.itemIndex;
				_parent.onItemPress(a_keyboardOrMouse);
			}
		};
		
		entryClip.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			if (this.itemIndex != undefined && this.enabled)
				_parent.onItemPressAux(a_keyboardOrMouse, a_buttonIndex);
		};
		
		return entryClip;
	}
}