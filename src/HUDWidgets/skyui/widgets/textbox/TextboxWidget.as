import skyui.widgets.WidgetBase;
import flash.geom.Transform;
import flash.geom.ColorTransform;

class skyui.widgets.textbox.TextboxWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */
	
	private var _widgetWidth: Number;
	
	private var _labelText: String;
	private var _labelTextFont: String;
	private var _labelTextColor: Number;
	private var _labelTextSize: Number;
	
	private var _valueText: String;
	private var _valueTextFont: String;
	private var _valueTextColor: Number;
	private var _valueTextSize: Number;
	
	private var _verticalAlign: String = "center";
	
	private var _paddingTop: Number;
	private var _paddingRight: Number;
	private var _paddingBottom: Number;
	private var _paddingLeft: Number;
	
	private var _borderColor: Number;
	private var _borderAlpha: Number;
	private var _borderRounded: Number;
	private var _borderWidth: Number;
	
	private var _backgroundColor: Number;
	private var _backgroundAlpha: Number;
	
	// private var _initialized: Boolean = false;
	// Maybe used this instead of checking if border is defined or not?
	

  /* STAGE ELEMENTS */
	
	public var border: MovieClip;
	public var background: MovieClip;
	public var labelTextField: TextField;
	public var valueTextField: TextField;
	

  /* INITIALIZATION */
	
	public function TextboxWidget()
	{
		super();
	}
	
	// @override WidgetBase
	function onLoad()
	{
		super.onLoad();
	}
	
  /* PROPERTIES */
	
	// TODO
	public var labelAlign: String;
	public var valueAlign: String;
	
	public function getWidgetWidth(): Number
	{
		return _widgetWidth;
	}
	public function setWidgetWidth(a_val: Number)
	{
		if (_widgetWidth == a_val)
			return;
			
		_widgetWidth = a_val;
		
		if (border != undefined)
			setWidgetTexts(_labelText, _valueText);
	}
	
	public function getWidgetBackgroundColor(): Number
	{
		return _backgroundColor;
	}
	public function setWidgetBackgroundColor(a_val: Number)
	{
		if (_backgroundColor == a_val)
			return;
		
		if (a_val < 0x000000)
			_backgroundColor = 0x000000;
		else if (a_val > 0xFFFFFF)
			_backgroundColor = 0xFFFFFF;
		else
			_backgroundColor = a_val;
			
		var tf: Transform = new Transform(background);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _backgroundColor;
		tf.colorTransform = colorTf;
	}
	
	public function getWidgetBackgroundAlpha(): Number
	{
		return _backgroundAlpha;
	}
	public function setWidgetBackgroundAlpha(a_val: Number)
	{
		if (_backgroundAlpha == a_val)
			return;
			
		if (a_val <= 0)
			_backgroundAlpha = 0;
		else if (a_val >= 100)
			_backgroundAlpha = 100;
		else
			_backgroundAlpha = a_val;
		
		background._alpha = _backgroundAlpha; 
	}
	
	public function getWidgetBorderColor(): Number
	{
		return _borderColor;
	}
	public function setWidgetBorderColor(a_val: Number)
	{
		if (_borderColor == a_val)
			return;
			
		if (a_val < 0x000000)
			_borderColor = 0x000000;
		else if (a_val > 0xFFFFFF)
			_borderColor = 0xFFFFFF;
		else
			_borderColor = a_val;
			
		if (border != undefined) {
			var tf: Transform = new Transform(border);
			var colorTf: ColorTransform = new ColorTransform();
			colorTf.rgb = _backgroundColor;
			tf.colorTransform = colorTf;
		}
	}
	
	public function getWidgetBorderWidth(): Number
	{
		return _borderWidth;
	}
	public function setWidgetBorderWidth(a_val: Number)
	{
		if (_borderWidth == a_val)
			return;
			
		_borderWidth = (a_val > 0) ? a_val : 0;
		
		if (border != undefined)
			redrawBorder();
	}
	
	public function getWidgetBorderAlpha(): Number
	{
		return _borderAlpha;
	}
	public function setWidgetBorderAlpha(a_val: Number)
	{
		if (_borderAlpha == a_val)
			return;
		
		if (a_val < 0)
			_borderAlpha = 0;
		else if (a_val > 100)
			_borderAlpha = 100;
		else
			_borderAlpha = a_val;
			
		if (border != undefined)
			border._alpha = _backgroundAlpha;
	}
	
	public function getWidgetBorderRounded(): Number
	{
		return _borderRounded;
	}
	public function setWidgetBorderRounded(a_val: Number)
	{
		if (_borderRounded == a_val)
			return;
		
		_borderRounded = (a_val <= 0) ? 0 : 1;
		
		if (border != undefined)
			redrawBorder();
	}
	
	public function setWidgetPadding(a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number): Void
	{
		if (_paddingTop == a_paddingTop && _paddingRight == a_paddingRight && _paddingBottom == a_paddingBottom && _paddingLeft == a_paddingLeft)
			return;
		
		_paddingTop = (a_paddingTop > 0) ? a_paddingTop : 0;
		_paddingRight = (a_paddingRight > 0) ? a_paddingRight : 10;
		_paddingBottom = (a_paddingBottom > 0) ? a_paddingBottom : 0;
		_paddingLeft = (a_paddingLeft > 0) ? a_paddingLeft : 10;
		
		if (border != undefined)
			setWidgetTexts(_labelText, _valueText);
	}
	
	public function getWidgetLabelText(): String
	{
		return _labelText;
	}
	public function setWidgetLabelText(a_val: String)
	{
		if (_labelText == a_val)
			return
		
		_labelText = a_val;
		
		doSetLabelText(a_val, false);
	}
	
	public function getWidgetLabelTextFont(): String
	{
		return _labelTextFont;
	}
	public function setWidgetLabelTextFont(a_val: String)
	{
		if (_labelTextFont == a_val)
			return;
			
		_labelTextFont = a_val;
		
		doSetLabelText(_labelText, false);
	}
	
	public function getWidgetLabelTextColor(): Number
	{
		return _labelTextColor;
	}
	public function setWidgetLabelTextColor(a_val: Number)
	{
		if (_labelTextColor == a_val)
			return;
		
		if (a_val < 0x000000)
			_labelTextColor = 0x000000;
		else if (a_val > 0xFFFFFF)
			_labelTextColor = 0xFFFFFF;
		else
			_labelTextColor = a_val;
			
		updateLabelTextFormat();
	}
	
	public function getWidgetLabelTextSize(): Number
	{
		return _labelTextSize;
	}
	public function setWidgetLabelTextSize(a_val: Number)
	{
		if(_labelTextSize == a_val)
			return;
		
		_labelTextSize = a_val;
		
		doSetLabelText(_labelText, false);
	}
	
	public function getWidgetValueText(): String
	{
		return _valueText;
	}
	public function setWidgetValueText(a_val: String)
	{
		if(_valueText == a_val)
			return;
			
		_valueText = a_val;
		
		doSetValueText(a_val, false);
	}
	
	public function getWidgetValueTextFont(): String
	{
		return _valueTextFont;
	}
	public function setWidgetValueTextFont(a_val: String)
	{
		if(_valueTextFont == a_val)
			return;
			
		_valueTextFont = a_val;
		
		doSetValueText(_valueText, false);
	}
	
	public function getWidgetValueTextColor(): Number
	{
		return _valueTextColor;
	}
	public function setWidgetValueTextColor(a_val: Number)
	{
		if(_valueTextColor == a_val)
			return;
			
		if (a_val < 0x000000)
			_valueTextColor = 0x000000;
		else if (a_val > 0xFFFFFF)
			_valueTextColor = 0xFFFFFF;
		else
			_valueTextColor = a_val;
			
		updateValueTextFormat();
	}
	
	public function getWidgetValueTextSize(): Number
	{
		return _valueTextSize;
	}
	public function setWidgetValueTextSize(a_val: Number)
	{
		if(_valueTextSize == a_val)
			return
			
		_valueTextSize = a_val;
		
		doSetValueText(_valueText, false);
	}
	
	public function getWidgetVerticalAlign(): String
	{
		return _verticalAlign;
	}
	public function setWidgetVerticalAlign(a_val: String)
	{
		if (_verticalAlign == a_val)
			return;
			
		_verticalAlign = (a_val == "top" || a_val == "bottom") ? a_val : "center";
		
		relativeVerticalAlign(labelTextField, valueTextField, _verticalAlign);
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setWidgetParams(a_widgetWidth: Number,
									a_backgroundColor: Number,
									a_backgroundAlpha: Number,
									a_borderWidth: Number,
									a_borderColor: Number,
									a_borderAlpha: Number,
									a_borderRounded: Number,
									a_paddingTop: Number,
									a_paddingRight: Number,
									a_paddingBottom: Number,
									a_paddingLeft: Number)
	{
		//background._width = a_widgetWidth;
		setWidgetWidth(a_widgetWidth);
		setWidgetBackgroundColor(a_backgroundColor);
		setWidgetBackgroundAlpha(a_backgroundAlpha);
		setWidgetBorderWidth(a_borderWidth);
		setWidgetBorderColor(a_borderColor);
		setWidgetBorderAlpha(a_borderAlpha);
		setWidgetBorderRounded(a_borderRounded);
		setWidgetPadding(a_paddingTop, a_paddingRight, a_paddingBottom, a_paddingLeft);
	}
	
	public function setWidgetTextFonts(a_labelTextFont: String, a_valueTextFont: String) {
		setWidgetLabelTextFont(a_labelTextFont);
		setWidgetValueTextFont(a_valueTextFont);
	}
	
	public function setWidgetTextFormats(a_labelTextColor: Number, a_labelTextSize: Number, a_valueTextColor: Number, a_valueTextSize: Number) {
		setWidgetLabelTextColor(a_labelTextColor);
		setWidgetLabelTextSize(a_labelTextSize);
		setWidgetValueTextColor(a_valueTextColor);
		setWidgetValueTextSize(a_valueTextSize);
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		doSetLabelText(a_labelText, true);
		doSetValueText(a_valueText, false);
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
			relativeVerticalAlign(labelTextField, valueTextField, _verticalAlign);
			updateBackground();
		}
	}
	
	private function doSetValueText(a_text: String, a_noResize: Boolean): Void
	{
		_valueText = a_text;
		updateValueText();

		valueTextField.autoSize = "left";
		valueTextField.textAutoSize = "none";
		
		valueTextField._x = _widgetWidth - _paddingRight - valueTextField._width;
		valueTextField._y = _paddingTop;
		
		if (!a_noResize) {
			fixTextOverlap();
			relativeVerticalAlign(labelTextField, valueTextField, _verticalAlign);
			updateBackground();
		}
	}
	
	private function updateLabelText()
	{
		labelTextField.text = _labelText;
		updateLabelTextFormat();
	}
	
	private function updateLabelTextFormat() {
		var tf: TextFormat = labelTextField.getTextFormat();
		tf.color = _labelTextColor;
		tf.font = _labelTextFont;
		tf.size = _labelTextSize;
		labelTextField.setTextFormat(tf);
	}
	
	private function updateValueText()
	{
		valueTextField.text = _valueText;
		updateValueTextFormat();
	}
	
	private function updateValueTextFormat() {
		var tf: TextFormat  = valueTextField.getTextFormat();
		tf.color = _valueTextColor;
		tf.font = _valueTextFont;
		tf.size = _valueTextSize;
		valueTextField.setTextFormat(tf);
	}
	
	private function updateBackground()
	{
		var h = _paddingTop + _paddingBottom + Math.max(labelTextField._height, valueTextField._height);
		if (h == background._height && _widgetWidth == background._width && border != undefined)
			return;
			
		background._height = h;
		background._width = _widgetWidth;
		redrawBorder();
	}
	
	private function fixTextOverlap(): Void
	{
		var availableWidth = _widgetWidth - _paddingLeft - _paddingRight;
		var textWidth = labelTextField._width + valueTextField._width;
		if (availableWidth > textWidth)
			return;
			
		labelTextField.autoSize = "none";
		labelTextField.textAutoSize = "shrink";
		
		valueTextField.autoSize = "none";
		valueTextField.textAutoSize = "shrink";

		labelTextField._width = availableWidth * (labelTextField._width / textWidth);
		valueTextField._width = availableWidth * (valueTextField._width / textWidth);
		
		valueTextField._x = _widgetWidth - _paddingRight - valueTextField._width;
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
		_borderLimits["left"] = 0 - _borderWidth/2;
		_borderLimits["top"] = 0 - _borderWidth/2;
		_borderLimits["right"] = _widgetWidth + _borderWidth/2;
		_borderLimits["bottom"] = background._height + _borderWidth/2;
		
		border.lineStyle(_borderWidth, _borderColor, 100, true, "normal", (_borderRounded) ? "round" : "square", (_borderRounded) ? "round" : "miter");
		border.moveTo(_borderLimits.left, _borderLimits.top);
		border.lineTo(_borderLimits.right, _borderLimits.top);
		border.lineTo(_borderLimits.right, _borderLimits.bottom);
		border.lineTo(_borderLimits.left, _borderLimits.bottom);
		border.lineTo(_borderLimits.left, _borderLimits.top);
		
		border._alpha = _borderAlpha;
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