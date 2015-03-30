import skyui.components.list.BasicList;
import skyui.components.list.ListState;


class skyui.components.list.BasicListEntry extends MovieClip
{
  /* STAGE ELEMENTS */

	public var background: MovieClip;
	
	
  /* PROPERTIES */
	
	public var itemIndex: Number;
	public var isEnabled: Boolean = true;
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override MovieClip
	public function onRollOver(): Void
	{
		var list = this._parent;
		
		if (itemIndex != undefined && (isEnabled || list.canSelectDisabled))
			list.onItemRollOver(itemIndex);
	}
		
	// @override MovieClip
	public function onRollOut(): Void
	{
		var list = this._parent;
		
		if (itemIndex != undefined && (isEnabled || list.canSelectDisabled))
			list.onItemRollOut(itemIndex);
	}
		
	// @override MovieClip
	public function onPress(a_mouseIndex: Number, a_keyboardOrMouse: Number): Void
	{
		var list = this._parent;
			
		if (itemIndex != undefined && (isEnabled || list.canSelectDisabled))
			list.onItemPress(itemIndex, a_keyboardOrMouse);
	}
		
	// @override MovieClip
	public function onPressAux(a_mouseIndex: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		var list = this._parent;
			
		if (itemIndex != undefined && (isEnabled || list.canSelectDisabled))
			list.onItemPressAux(itemIndex, a_keyboardOrMouse, a_buttonIndex);
	}
	
	// This is called after the object is added to the stage since the constructor does not accept any parameters.
	public function initialize(a_index: Number, a_list: BasicList): Void
	{
		// Do nothing.
	}
	
	// @abstract
	public function setEntry(a_entryObject: Object, a_state: ListState): Void {}
}