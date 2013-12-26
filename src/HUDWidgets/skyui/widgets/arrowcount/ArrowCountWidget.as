import skyui.widgets.WidgetBase;

class skyui.widgets.arrowcount.ArrowCountWidget extends WidgetBase
{	
  /* STAGE ELEMENTS */
	
	public var countText: TextField;
  
  
  /* INITIALIZATION */

	public function ArrowCountWidget()
	{
		super();
		
		_visible = false;
		countText.text = "0";
	}


  /* PUBLIC FUNCTIONS */
  
	// @overrides WidgetBase
	public function getWidth(): Number
	{
		return _width;
	}

	// @overrides WidgetBase
	public function getHeight(): Number
	{
		return _height;
	}

	// @Papyrus
	public function setVisible(a_visible: Boolean): Void
	{
		_visible = a_visible;
	}
	
	// @Papyrus
	public function setCount(a_count: Number): Void
	{
		countText.text = String(a_count);
	}
}