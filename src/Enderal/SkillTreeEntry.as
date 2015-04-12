class SkillTreeEntry extends MovieClip
{
  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var icon: MovieClip;
	public var textField: TextField;
	
	
  /* PROPERTIES */
	

	public var isEnabled: Boolean = true;
	public var data: Object  = null;
	
	
  /* PRIVATE VARIABLES */
	
  /* PUBLIC FUNCTIONS */
	
	// @override MovieClip
	public function onRollOver(): Void
	{
		var view = this._parent._parent;
		
		if (isEnabled)
			view.onSkillRollOver(this);
	}
		
	// @override MovieClip
	public function onRollOut(): Void
	{
		var view = this._parent._parent;
		
		if (isEnabled)
			view.onSkillRollOut(this);
	}
		
	// @override MovieClip
	public function onPress(a_mouseIndex: Number, a_keyboardOrMouse: Number): Void
	{
		var view = this._parent._parent;
			
		if ( isEnabled)
			view.onSkillPress(this, a_keyboardOrMouse);
	}
		
	// @override MovieClip
	public function onPressAux(a_mouseIndex: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		var view = this._parent._parent;
			
		if (isEnabled)
			view.onSkillPressAux(this, a_keyboardOrMouse, a_buttonIndex);
	}
	
	public function clearData(): Void
	{
		data = null;
	}
	
	public function setData(a_data: Object): Void
	{
		data = a_data;
		invalidate();
	}
	
	public function invalidate(): Void
	{		
		var view = this._parent._parent;
		
		var isSelected = view.selectedClip == this;
		
		gotoAndStop(isSelected ? "normal" : "selected");

		icon.gotoAndStop(data.iconLabel);
		textField.SetText(data.name);
	}
}