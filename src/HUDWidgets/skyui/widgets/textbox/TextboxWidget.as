import skyui.widgets.WidgetBase;

class skyui.widgets.textbox.TextboxWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */
	
	private var _labelText: String = "";
	private var _labelColor: Number = 0xFF00FF;
	private var _labelFont: String = "$SkyrimBooks";
	
	private var _valueText: String = "";
	private var _valueColor: Number = 0x00FFFF;
	private var _valueFont: String = "$SkyrimBooks";
	
	private var _verticalAlign: String = "center";
	
	private var _paddingTop: Number = 0;
	private var _paddingBottom: Number = 0;
	private var _paddingLeft: Number = 10;
	private var _paddingRight: Number = 10;
	
	private var _borderColor: Number;
	private var _borderAlpha: Number;
	private var _borderRounded: Number;
	private var _borderWidth: Number;
	
	private var _backgroundColor: Number;
	private var _backgroundAlpha: Number;
	
	private var _widgetWidth: Number;
	
	
  /* STAGE ELEMENTS */
	
	public var border: MovieClip;
	public var background: MovieClip;
	public var labelTextField: TextField;
	public var valueTextField: TextField;
	

  /* INITIALIZATION */
	
	public function TextboxWidget()
	{
		super();
		
		// For testing...
		setWidgetParams(200, 0xCCCCCC, 100, 3, 0xFFFF00, 100, 1);
		//setWidgetTextParams();
		/*labelTextField.border = valueTextField.border = true;
		labelTextField.borderColor = valueTextField.borderColor = 0xFFFFFF;*/
	}
	
	// @override WidgetBase
	function onLoad()
	{
		super.onLoad();
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
			backgroundAlpha = 0;
		} else if (c == 200) {
			setWidgetTexts("keyeeeeeeeeeee\nOMG A NEW LINE!", "valueeee\neeeeeeee");
			backgroundColor = 0x123456;
			borderColor = 0xFFFF00;
			borderWidth = 10;
			borderAlpha = 100;
			borderRounded = 0;
			backgroundAlpha = 100;
		} else if (c == 300) {
			setWidgetTexts("keyeeeeeeeeeee", "valueeeeeeeeeeee");
			backgroundColor = 0x789ABC;
		} else if (c == 400) {
			setWidgetTexts("Health", "val");
			verticalAlign = "bottom";
			backgroundColor = 0xDE0014;
		} else if (c == 500) {
			setWidgetTexts("key", "valueeeeeeeeeeeeeeeeee");
			backgroundColor = 0xFFFFFF;
			c = 0;
		}
		
		c++;
	}
	
	
  /* PROPERTIES */
	
	// TODO
	public var labelAlign: String;
	public var valueAlign: String;
	
	public function get widgetWidth(): Number
	{
		return _widgetWidth;
	}
	public function set widgetWidth(a_width: Number)
	{
		if (_widgetWidth != undefined) {
			// Reset text
		}
		
		_widgetWidth = a_width;
	}
	
	public function get backgroundColor(): Number
	{
		return _backgroundColor;
	}
	public function set backgroundColor(a_color: Number)
	{
		_backgroundColor = (a_color >= 0x000000 && a_color <= 0xFFFFFF) ? a_color : 0x000000;
		var t = new Color(background); 
		t.setRGB(_backgroundColor);
	}
	
	public function get backgroundAlpha(): Number
	{
		return _backgroundAlpha;
	}
	public function set backgroundAlpha(a_alpha: Number)
	{
		if (a_alpha <= 0)
			_backgroundAlpha = 0;
		else if (a_alpha >= 100)
			_backgroundAlpha = 100;
			
		background._alpha = _backgroundAlpha; 
	}
	
	public function get borderColor(): Number
	{
		return _borderColor;
	}
	public function set borderColor(a_color: Number)
	{
		_borderColor = (a_color >= 0x000000 && a_color <= 0xFFFFFF) ? a_color : 0xFFFFFF;
		if (border != undefined) {
			var t = new Color(border); 
			t.setRGB(_borderColor);
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
		if (a_alpha <= 0)
			_backgroundAlpha = 0;
		else if (a_alpha >= 100)
			_backgroundAlpha = 100;
			
		if (border != undefined)
			border._alpha = _backgroundAlpha;
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
		_labelColor = (a_color >= 0x000000 && a_color <= 0xFFFFFF) ? a_color : 0xFFFFFF;
		updateLabelText();
	}
	
	public function get valueColor(): Number
	{
		return _labelColor;
	}
	public function set valueColor(a_color: Number)
	{
		_valueColor = (a_color >= 0x000000 && a_color <= 0xFFFFFF) ? a_color : 0xFFFFFF;
		updateValueText();
	}
	
	public function get verticalAlign(): String
	{
		return _verticalAlign;
	}
	public function set verticalAlign(a_align: String)
	{
		
		_verticalAlign = (a_align == "top" || a_align == "bottom") ? a_align : "center";
		relativeVerticalAlign(labelTextField, valueTextField, _verticalAlign);
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number)
	{
		background._width = a_widgetWidth;
		backgroundColor = background._color; // = a_backgroundColor;
		backgroundAlpha = background._alpha; // = a_backgroundAlpha;
		borderWidth = a_borderWidth;
		borderColor = a_borderColor;
		borderAlpha = a_borderAlpha;
		borderRounded = a_borderRounded;
	}
	
	public function setWidgetTextParams(/* Strings */) {
		//labelFontColor, labelFontFace, labelFontSize etc..
		//verticalAlign
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		doSetLabelText(a_labelText, true);
		doSetValueText(a_valueText, false);
	}
	
	public function setTextPadding(a_top: Number, a_right: Number, a_bottom: Number, a_left: Number): Void
	{
		_paddingTop = a_top;
		_paddingRight = a_right;
		_paddingBottom = a_bottom;
		_paddingLeft = a_left;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
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
			relativeVerticalAlign(labelTextField, valueTextField, verticalAlign);
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
			relativeVerticalAlign(labelTextField, valueTextField, verticalAlign);
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
		
		var _borderLimits = new Object();
		_borderLimits["left"] = 0 - borderWidth/2;
		_borderLimits["top"] = 0 - borderWidth/2;
		_borderLimits["right"] = background._width + borderWidth/2;
		_borderLimits["bottom"] = background._height + borderWidth/2;
		
		border.lineStyle(borderWidth, borderColor, 100, true, "normal", (borderRounded) ? "round" : "square", (borderRounded) ? "round" : "miter");
		border.moveTo(_borderLimits.left, _borderLimits.top);
		border.lineTo(_borderLimits.right, _borderLimits.top);
		border.lineTo(_borderLimits.right, _borderLimits.bottom);
		border.lineTo(_borderLimits.left, _borderLimits.bottom);
		border.lineTo(_borderLimits.left, _borderLimits.top);
		
		border._alpha = borderAlpha;
	}
	
	private function relativeVerticalAlign(textFieldA: TextField, textFieldB: TextField, mode: String): Void
	{
		// Will only work if _y is same for both text fields, in this case, they are.
		
		textFieldA._y = _paddingTop;
		textFieldB._y = _paddingTop;
		
		var difference: Number;
		switch (mode) {
			case "top":
				// difference = top of textFieldA boundry box - top of textFieldB boundry box
				difference = Math.abs((textFieldA._height - textFieldA.textHeight) - (textFieldB._height - textFieldB.textHeight))/2;
				difference += Math.abs(textFieldA.getLineMetrics(0)["height"] - textFieldB.getLineMetrics(0)["height"]);
				difference -= Math.abs(textFieldA.getLineMetrics(0)["descent"] - textFieldB.getLineMetrics(0)["descent"]);
				break;
			case "bottom":
				// difference = bottom of textFieldA boundry box - bottom of textFieldB boundry box
				difference = Math.abs((textFieldA._height + textFieldA.textHeight) - (textFieldB._height + textFieldB.textHeight))/2;
				difference -= Math.abs(textFieldA.getLineMetrics(textFieldA.numLines - 1)["descent"] - textFieldB.getLineMetrics(textFieldB.numLines - 1)["descent"]);
				break;
			case "center":
			default:
				difference = Math.abs(textFieldA._height - textFieldB._height)/2;
		}
		if(textFieldA.textHeight > textFieldB.textHeight)
			textFieldB._y += difference;
		else
			textFieldA._y += difference;
			
	}
}