class skyui.components.ButtonPanel extends MovieClip
{
  /* PRIVATE VARIABLES */	
	
	// Number of buttons that are actually in use
	private var _buttonCount: Number = 0;
	
	
  /* PROPERTIES */
  
	public var buttons: Array;
	
	public var isReversed: Boolean = false;
	

  /* INITIALIZATION */
  
 	public function ButtonPanel()
	{
		buttons = [];
		for (var i = 0; this["button" + i] != undefined; i++)
			buttons.push(this["button" + i]);
	}
	

  /* PUBLIC FUNCTIONS */
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		for (var i=0; i < buttons.length; i++)
			buttons[i].setPlatform(a_platform, a_bPS3Switch);
	}
	
	public function showButtons(): Void
	{
		for (var i=0; i < buttons.length; i++)
			buttons[i]._visible = buttons[i].label.length > 0;
	}

	public function hideButtons(): Void
	{
		for (var i=0; i < buttons.length; i++)
			buttons[i]._visible = false;
	}
	
	public function clearButtons(): Void
	{
		_buttonCount = 0;
		for (var i=0; i < buttons.length; i++) {
			var btn = buttons[i];
			btn._visible = false;
			btn.label = "";
		}
	}
	
	public function addButton(a_buttonData: Object): MovieClip
	{
		if (_buttonCount >= buttons.length)
			return;
		
		var btn = buttons[_buttonCount];
		btn.setButtonData(a_buttonData);
		btn._visible = true;
		_buttonCount++;
		
		return btn;
	}
	
	public function positionButtons(): Void
	{
		var offset = 0;
		for (var i=0; i < buttons.length; i++) {
			var btn = buttons[i];
			if (btn.label.length > 0) {
				if (isReversed) {
					offset -= btn.width + 10;
					btn._x = offset;
				} else {
					btn._x = offset;
					offset += btn.width + 10;
				}
			}
		}
	}
}