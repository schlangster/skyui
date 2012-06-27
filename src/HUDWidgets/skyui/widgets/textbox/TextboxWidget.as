class skyui.widgets.textbox.TextboxWidget extends MovieClip
{
	// Private Vars
	
	private var _labelText: String = "";
	private var _labelColor: Number = 0xFF00FF;
	private var _labelFont: String = "$SkyrimBooks";
	
	private var _valueText: String = "";
	private var _valueColor: Number = 0x00FFFF;
	private var _valueFont: String = "$SkyrimBooks";
	
	private var _paddingTop: Number = 0;
	private var _paddingBottom: Number = 0;
	private var _paddingLeft: Number = 10;
	private var _paddingRight: Number = 10;
	
	private var _borderColor: Number;
	private var _borderAlpha: Number;
	private var _borderWidth: Number;
	private var _borderRounded: Number;
	
	private var _backgroundColor: Number;
	
	// Stage elements
	
	public var border: MovieClip;
	public var background: MovieClip;
	public var labelTextField: TextField;
	public var valueTextField: TextField;
	

	// Initialization
	
	public function TextboxWidget()
	{
		// For testing...
		setWidgetParams(200, 0xCCCCCC, 100, 0, 0xFFFF00, 100, 1);
	}
	
	
	// Debug
	function onLoad()
	{
		setWidgetTexts("keyeeeeeeeeeee", "valueeeeeeeeeeee");
	}
	
	var c = 0;
	
	function onEnterFrame()
	{
		if (c == 100) {
			setWidgetTexts("key", "value");
			borderColor = 0xFF0000;
			borderAlpha = 50;
			borderWidth = 5;
			borderRounded = 1;
		} else if (c == 200) {
			setWidgetTexts("keyeeeeeeeeeee", "valueeeeeeeeeeee");
			//backgroundColor = 0x123456;
			borderColor = 0xFFFF00;
			borderWidth = 10;
			borderAlpha = 100;
			borderRounded = 0;
		} else if (c == 300) {
			setWidgetTexts("keyeeeeeeeeeee", "valueeeeeeeeeeee");
			backgroundColor = 0x789ABC;
		} else if (c == 400) {
			setWidgetTexts("keyeeeeeeeeeeeeeeeeeee", "val");
			backgroundColor = 0xDEF012;
		} else if (c == 500) {
			setWidgetTexts("key", "valueeeeeeeeeeeeeeeeee");
			backgroundColor = 0xFFFFFF;
			c = 0;
		}
		
		c++;
	}
	
	
	// Properties
	
	// TODO
	public var labelAlign: String;
	public var valueAlign: String;
	
	
	public function get backgroundColor(): Number
	{
		return _backgroundColor;
	}
	public function set backgroundColor(a_color: Number)
	{
		_backgroundColor = a_color;
		var t = new Color(background); 
		t.setRGB(a_color);
	}
	
	public function get borderColor(): Number
	{
		return _borderColor;
	}
	public function set borderColor(a_color: Number)
	{
		_borderColor = a_color;
		if (border != undefined) {
			var t = new Color(border); 
			t.setRGB(a_color);
		}
	}
	
	public function get borderWidth(): Number
	{
		return _borderWidth;
	}
	public function set borderWidth(a_width: Number)
	{
		_borderWidth = (a_width != undefined && a_width > 0) ? a_width : 0;
		
		if (border != undefined)
			redrawBorder();
	}
	
	public function get borderAlpha(): Number
	{
		return _borderAlpha;
	}
	public function set borderAlpha(a_alpha: Number)
	{
		_borderAlpha = a_alpha;
		if (border != undefined)
			border._alpha = a_alpha;
	}
	
	public function get borderRounded(): Number
	{
		return _borderRounded;
	}
	public function set borderRounded(a_rounded: Number)
	{
		_borderRounded = (a_rounded <= 0) ? 0 : 1;
		if (border != undefined)
			redrawBorder();
	}
	
	public function get labelText(): String
	{
		return _labelText;
	}
	public function set labelText(a_text: String)
	{
		doSetLabelText(a_text, false);
	}
	
	public function get valueText(): String
	{
		return _valueText;
	}
	public function set valueText(a_text: String)
	{
		doSetValueText(a_text, false);
	}
	
	public function get labelColor(): Number
	{
		return _labelColor;
	}
	public function set labelColor(a_color: Number)
	{
		_labelColor = a_color;
		updateLabelText();
	}
	
	public function get valueColor(): Number
	{
		return _labelColor;
	}
	public function set valueColor(a_color: Number)
	{
		_valueColor = a_color;
		updateValueText();
	}
	
	
	// Public functions
	
	public function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number)
	{
		background._width = a_widgetWidth;
		background._color = a_backgroundColor;
		background._alpha = a_backgroundAlpha;
		borderWidth = a_borderWidth;
		borderColor = a_borderColor;
		borderAlpha = a_borderAlpha;
		borderRounded = a_borderRounded;		
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		doSetLabelText(a_labelText, true);
		doSetValueText(a_valueText);
	}
	
	public function setTextPadding(a_top: Number, a_right: Number, a_bottom: Number, a_left: Number): Void
	{
		_paddingTop = a_top;
		_paddingRight = a_right;
		_paddingBottom = a_bottom;
		_paddingLeft = a_left;
	}
	
	
	// Private functions
	
	private function doSetLabelText(a_text: String, a_noResize: Boolean): Void
	{
		_labelText = a_text;
		updateLabelText();
		
		labelTextField.autoSize = "left";
		labelTextField.textAutoSize = "none";
		
		labelTextField._x = _paddingLeft;
		labelTextField._y = _paddingTop;
		
		if (!a_noResize) {
			fixTextOverlap();
			updateBackground();
		}
	}
	
	private function doSetValueText(a_text: String, a_noResize: Boolean): Void
	{
		_valueText = a_text;
		updateValueText();

		valueTextField.autoSize = "left";
		valueTextField.textAutoSize = "none";
		
		valueTextField._x = background._width - _paddingRight - valueTextField._width;
		valueTextField._y = _paddingTop;
		
		if (!a_noResize) {
			fixTextOverlap();
			updateBackground();
		}
	}
	
	private function updateLabelText()
	{
		labelTextField.text = _labelText;
		var tf = labelTextField.getTextFormat();
		tf.color = _labelColor;
		tf.font = _labelFont;
		labelTextField.setTextFormat(tf);
	}
	
	private function updateValueText()
	{
		valueTextField.text = _valueText;
		var tf = valueTextField.getTextFormat();
		tf.color = _valueColor;
		tf.font = _valueFont;
		valueTextField.setTextFormat(tf);
	}
	
	private function updateBackground()
	{
		var h = _paddingTop + _paddingBottom + Math.max(labelTextField._height, valueTextField._height);
		if (h == background._height)
			return;
			
		background._height = h;
		redrawBorder();
	}
	
	private function fixTextOverlap(): Void
	{
		var availableWidth = background._width - _paddingLeft - _paddingRight;
		var textWidth = labelTextField._width + valueTextField._width;
		if (availableWidth > textWidth)
			return;
			
		labelTextField.autoSize = "none";
		labelTextField.textAutoSize = "shrink";
		
		valueTextField.autoSize = "none";
		valueTextField.textAutoSize = "shrink";

		labelTextField._width = availableWidth * (labelTextField._width / textWidth);
		valueTextField._width = availableWidth * (valueTextField._width / textWidth);
		
		valueTextField._x = background._width - _paddingRight - valueTextField._width;
		valueTextField._y = _paddingTop;
	}
	
	private function redrawBorder(): Void
	{
		if (border != undefined)
			border.removeMovieClip();
			
		// We create the borderMC anyway 
		createEmptyMovieClip("border", getNextHighestDepth());
		if (_borderWidth == 0)
			return;
		border.moveTo(0 - borderWidth/2 , 0 - borderWidth/2); // Start at TL
		border.lineStyle(borderWidth, borderColor, 100, true, "normal", (borderRounded) ? "round" : "square", (borderRounded) ? "round" : "miter");
		border.lineTo(background._width + borderWidth/2, 0 - borderWidth/2); // TR
		border.lineTo(background._width + borderWidth/2, background._height + borderWidth/2); // BR
		border.lineTo(0 - borderWidth/2, background._height + borderWidth/2); // BL
		border.lineTo(0 - borderWidth/2 , 0 - borderWidth/2); // TL
		
		border._alpha = borderAlpha;
	}
	
	function relativeVerticalAlign(textFieldA: TextField, textFieldB: TextField): Void
	{
		var	midpointA: Number = textFieldA._y + textFieldA.textHeight/2;
		var	midpointB: Number = textFieldB._y + textFieldB.textHeight/2;
		var difference: Number = Math.abs(midpointA - midpointB);
		
		if(midpointA > midpointB)
			textFieldB._y += difference;
		else
			textFieldA._y += difference;
	}
}