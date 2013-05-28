class skyui.components.ButtonPanel extends MovieClip
{
  /* PRIVATE VARIABLES */	
	
	// Number of buttons that are actually in use
	private var _buttonCount: Number = 0;
	
	private var _updateID: Number;
	
	
  /* PROPERTIES */
  
	public var buttons: Array;
	
	public var isReversed: Boolean = false;
	
	public var buttonRenderer: String;
	
	public var maxButtons: Number = 0;
	
	public var buttonInitializer: Object;
	
	public var spacing: Number = 10;
	

  /* INITIALIZATION */
  
 	public function ButtonPanel(a_buttonRenderer: String, a_maxButtons: Number, a_buttonInitializer: Object)
	{
		buttons = [];
		
		if (a_buttonRenderer != undefined)
			buttonRenderer = a_buttonRenderer;
			
		if (a_maxButtons != undefined)
			maxButtons = a_maxButtons;
			
		if (a_buttonInitializer != undefined)
			buttonInitializer = a_buttonInitializer;
		
		for (var i=0; i<maxButtons; i++) {
			var btn = attachMovie(buttonRenderer, "button" + i, getNextHighestDepth(), buttonInitializer);
			btn._visible = false;
			buttons.push(btn);
		}
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
			btn._x = 0;
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
	
	public function updateButtons(a_bInstant: Boolean): Void
	{
		if (a_bInstant)
			doUpdateButtons();
		else if (!_updateID)
			_updateID = setInterval(this, "doUpdateButtons", 1);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function doUpdateButtons(): Void
	{
		clearInterval(_updateID);
		delete _updateID;
		
		var offset = 0;
		for (var i=0; i < buttons.length; i++) {
			var btn = buttons[i];
			
			if (btn.label.length > 0 && btn._visible) {
				btn.update();
				
				if (isReversed) {
					offset -= btn.width;
					btn._x = offset;
					offset -= spacing;
				} else {
					btn._x = offset;
					offset += btn.width + spacing;
				}
			}
		}
	}
}