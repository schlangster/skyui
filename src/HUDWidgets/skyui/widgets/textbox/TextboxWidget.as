import skyui.widgets.WidgetBase;
import flash.geom.Transform;
import flash.geom.ColorTransform;

class skyui.widgets.textbox.TextboxWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */
	
	private var _labelText: String = "";
	private var _labelTextFont: String = "$EverywhereFont";
	private var _labelTextColor: Number = 0xFFFFFF;
	private var _labelTextSize: Number = 20;
	
	private var _valueText: String = "";
	private var _valueTextFont: String = "$EverywhereFont";
	private var _valueTextColor: Number = 0xFFFFFF;
	private var _valueTextSize: Number = 20;
	
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
	
	public function get widgetWidth(): Number
	{
		return _widgetWidth;
	}
	public function set widgetWidth(a_val: Number)
	{
		if (_widgetWidth != undefined) {
			// Reset text
		}
		
		_widgetWidth = a_val;
	}
	
	public function getWidgetBackgroundColor(): Number
	{
		return _backgroundColor;
	}
	public function setWidgetBackgroundColor(a_val: Number)
	{
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
		_borderRounded = (a_val <= 0) ? 0 : 1;
		if (border != undefined)
			redrawBorder();
	}
	
	public function getWidgetLabelText(): String
	{
		return _labelText;
	}
	public function setWidgetLabelText(a_val: String)
	{
		_labelText = a_val;
		doSetLabelText(a_val, false);
	}
	
	public function getWidgetLabelTextFont(): String
	{
		return _labelTextFont;
	}
	public function setWidgetLabelTextFont(a_val: String)
	{
		_labelTextFont = a_val;
		if(_labelTextSize != a_val)
			doSetLabelText(_labelText, false);
	}
	
	public function getWidgetLabelTextColor(): Number
	{
		return _labelTextColor;
	}
	public function setWidgetLabelTextColor(a_val: Number)
	{
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
		_labelTextSize = a_val;
		if(_labelTextSize != a_val)
			doSetLabelText(_labelText, false);
	}
	
	public function getWidgetValueText(): String
	{
		return _valueText;
	}
	public function setWidgetValueText(a_val: String)
	{
		_valueText = a_val;
		doSetValueText(a_val, false);
	}
	
	public function getWidgetValueTextFont(): String
	{
		return _valueTextFont;
	}
	public function setWidgetValueTextFont(a_val: String)
	{
		_valueTextFont = a_val;
		if(_valueTextFont != a_val)
			doSetValueText(_valueText, false);
	}
	
	public function getWidgetValueTextColor(): Number
	{
		return _valueTextColor;
	}
	public function setWidgetValueTextColor(a_val: Number)
	{
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
		_valueTextSize = a_val;
		if(_valueTextSize != a_val)
			doSetValueText(_valueText, false);
	}
	
	public function getWidgetVerticalAlign(): String
	{
		return _verticalAlign;
	}
	public function setWidgetVerticalAlign(a_val: String)
	{
		_verticalAlign = (a_val == "top" || a_val == "bottom") ? a_val : "center";
		relativeVerticalAlign(labelTextField, valueTextField, _verticalAlign);
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number)
	{
		background._width = a_widgetWidth;
		setWidgetBackgroundColor(a_backgroundColor);
		setWidgetBackgroundAlpha(a_backgroundAlpha);
		setWidgetBorderWidth(a_borderWidth);
		setWidgetBorderColor(a_borderColor);
		setWidgetBorderAlpha(a_borderAlpha);
		setWidgetBorderRounded(a_borderRounded);
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
		
		valueTextField._x = background._width - _paddingRight - valueTextField._width;
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
		_borderLimits["left"] = 0 - _borderWidth/2;
		_borderLimits["top"] = 0 - _borderWidth/2;
		_borderLimits["right"] = background._width + _borderWidth/2;
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