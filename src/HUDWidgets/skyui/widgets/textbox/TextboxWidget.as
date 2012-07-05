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
	private var _labelTextAlpha: Number;
	private var _labelTextSize: Number;
	private var _labelTextAlign: String;
	
	private var _valueText: String;
	private var _valueTextFont: String;
	private var _valueTextColor: Number;
	private var _valueTextAlpha: Number;
	private var _valueTextSize: Number;
	private var _valueTextAlign: String;
	
	private var _verticalAlign: String = "baseline";
	
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
	
	private var _initialized: Boolean = false;
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
		
		// For testing in flash
		
		setWidgetParams(500, 0xFF0000, 100, 5, 0xFFFF00, 100, 1, 100, 100, 100, 100);
		setWidgetTextFonts("$EverywhereFont", "$EverywhereFont");
		setWidgetTextFormats(0x00FF00, 20, 0x0000FF, 50);
		setWidgetTexts("label", "value");
		//setWidgetValueTextSize(50);
	}
	
  /* INTERFACE */
	
	public function getWidgetWidth(): Number			{ return _widgetWidth; }
	
	public function getWidgetBackgroundColor(): Number	{ return _backgroundColor; }
	public function getWidgetBackgroundAlpha(): Number	{ return _backgroundAlpha; }
	
	public function getWidgetBorderColor(): Number		{ return _borderColor; }
	public function getWidgetBorderWidth(): Number		{ return _borderWidth; }
	public function getWidgetBorderAlpha(): Number		{ return _borderAlpha; }
	public function getWidgetBorderRounded(): Number	{ return _borderRounded; }
	
	public function getWidgetLabelText(): String		{ return _labelText; }
	public function getWidgetLabelTextFont(): String	{ return _labelTextFont; }
	public function getWidgetLabelTextColor(): Number	{ return _labelTextColor; }
	public function getWidgetLabelTextAlpha(): Number	{ return _labelTextAlpha; }
	public function getWidgetLabelTextSize(): Number	{ return _labelTextSize; }
	public function getWidgetLabelTextAlign(): String	{ return _labelTextAlign; }
	
	public function getWidgetValueText(): String		{ return _valueText; }
	public function getWidgetValueTextFont(): String	{ return _valueTextFont; }
	public function getWidgetValueTextColor(): Number	{ return _valueTextColor; }
	public function getWidgetValueTextAlpha(): Number	{ return _valueTextAlpha; }
	public function getWidgetValueTextSize(): Number	{ return _valueTextSize; }
	public function getWidgetValueTextAlign(): String	{ return _valueTextAlign; }
	public function getWidgetVerticalAlign(): String	{ return _verticalAlign; }
	
	public function setWidgetWidth(a_val: Number)
	{
		if (_widgetWidth == a_val)
			return;
			
		_widgetWidth = a_val;
		
		if (_initialized) {
			// Check padding is ok
			setWidgetPadding(_paddingTop, _paddingRight, _paddingBottom, _paddingLeft);
			// Reset text positions
			doSetLabelText(true);
			doSetValueText(false);
		}
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
			
		if (_initialized) {
			var tf: Transform = new Transform(border);
			var colorTf: ColorTransform = new ColorTransform();
			colorTf.rgb = _backgroundColor;
			tf.colorTransform = colorTf;
		}
	}
	
	public function setWidgetBorderWidth(a_val: Number)
	{
		if (_borderWidth == a_val)
			return;
			
		_borderWidth = (a_val > 0) ? a_val : 0;
		
		if (_initialized)
			redrawBorder();
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
			
		if (_initialized)
			border._alpha = _backgroundAlpha;
	}
	

	public function setWidgetBorderRounded(a_val: Number)
	{
		if (_borderRounded == a_val)
			return;
		
		_borderRounded = (a_val <= 0) ? 0 : 1;
		
		if (_initialized)
			redrawBorder();
	}
	
	public function setWidgetPadding(a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number): Void
	{
		if (_paddingTop == a_paddingTop && _paddingRight == a_paddingRight && _paddingBottom == a_paddingBottom && _paddingLeft == a_paddingLeft)
			return;
			
		if (a_paddingTop > _widgetWidth/4)
			_paddingTop = _widgetWidth/4;
		else if (a_paddingTop < 0)
			_paddingTop = 0;
		else
			_paddingTop = a_paddingTop;
			
		if (a_paddingRight > _widgetWidth/4)
			_paddingRight = _widgetWidth/4;
		else if (a_paddingRight < 0)
			_paddingRight = 10;
		else
			_paddingRight = a_paddingRight + 10;
			
		if (a_paddingBottom > _widgetWidth/4)
			_paddingBottom = _widgetWidth/4;
		else if (a_paddingBottom < 0)
			_paddingBottom = 0;
		else
			_paddingBottom = a_paddingTop;
		
		if (a_paddingLeft > _widgetWidth/4)
			_paddingLeft = _widgetWidth/4;
		else if (a_paddingLeft < 0)
			_paddingLeft = 10;
		else
			_paddingLeft = a_paddingLeft + 10;
		
		if (_initialized)
			setWidgetTexts(_labelText, _valueText);
	}
	
	public function setWidgetLabelText(a_val: String)
	{
		if (_labelText == a_val)
			return
		
		_labelText = a_val;
		labelTextField.text = a_val;
		
		if (_initialized)
			doSetLabelText(false);
	}

	public function setWidgetLabelTextFont(a_val: String)
	{
		if (_labelTextFont == a_val)
			return;
			
		_labelTextFont = a_val;
		
		if (_initialized) {
			var tf: TextFormat = labelTextField.getNewTextFormat();
			tf.font = _labelTextFont;
			labelTextField.setTextFormat(tf);
			labelTextField.setNewTextFormat(tf);
			// Force an update of both textfields' positions.
			doSetLabelText(false);
		}
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
			
		if (_initialized) {
			var tf: TextFormat = labelTextField.getNewTextFormat();
			tf.color = _labelTextColor;
			labelTextField.setTextFormat(tf);
			labelTextField.setNewTextFormat(tf);
		}
	}
	
	public function setWidgetLabelTextSize(a_val: Number)
	{
		if(_labelTextSize == a_val)
			return;
		
		_labelTextSize = a_val;
		
		if (_initialized) {
			var tf: TextFormat = labelTextField.getNewTextFormat();
			tf.size = _labelTextSize;
			labelTextField.setTextFormat(tf);
			labelTextField.setNewTextFormat(tf);
			// Force an update of both textfields' positions.
			doSetLabelText(false);
		}
	}
	

	public function setWidgetValueText(a_val: String)
	{
		if(_valueText == a_val)
			return;
			
		_valueText = a_val;
		valueTextField.text = a_val;
		
		if (_initialized)
			doSetValueText(false);
	}

	public function setWidgetValueTextFont(a_val: String)
	{
		if(_valueTextFont == a_val)
			return;
			
		_valueTextFont = a_val;
		
		if (_initialized) {
			var tf: TextFormat = valueTextField.getNewTextFormat();
			tf.font = _valueTextFont;
			valueTextField.setTextFormat(tf);
			valueTextField.setNewTextFormat(tf);
		}
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
			
		if (_initialized) {
			var tf: TextFormat = valueTextField.getNewTextFormat();
			tf.color = _valueTextColor;
			valueTextField.setTextFormat(tf);
			valueTextField.setNewTextFormat(tf);
		}
	}
	
	public function setWidgetValueTextSize(a_val: Number)
	{
		if(_valueTextSize == a_val)
			return
			
		_valueTextSize = a_val;
		
		if (_initialized) {
			var tf: TextFormat = valueTextField.getNewTextFormat();
			tf.size = _valueTextSize;
			valueTextField.setTextFormat(tf);
			valueTextField.setNewTextFormat(tf);
			// Force an update of both textfields' positions.
			doSetValueText(false);
		}
	}

	public function setWidgetVerticalAlign(a_val: String)
	{
		if (_verticalAlign == a_val)
			return;
			
		_verticalAlign = a_val;
		
		if (_initialized)
			verticalAlignTextFields(_verticalAlign);
	}
	
	public function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number,
									a_borderAlpha: Number, a_borderRounded: Number, a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number,
									a_paddingLeft: Number)
	{
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
		
		doSetTextFormats();
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		setWidgetLabelText(a_labelText);
		setWidgetValueText(a_valueText);
		
		doSetLabelText(true); // No resize
		doSetValueText(false);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function doSetLabelText(a_noResize: Boolean): Void
	{
		labelTextField.autoSize = "left";
		labelTextField.textAutoSize = "none";
		
		labelTextField.border = true;
		labelTextField.borderColor = 0xFF00FF;
		
		labelTextField._x = _paddingLeft;
		labelTextField._y = _paddingTop;
		
		if (!a_noResize) {
			fixTextOverlap();
			verticalAlignTextFields(_verticalAlign);
			updateBackground();
		}
	}
	
	private function doSetValueText(a_noResize: Boolean): Void
	{
		valueTextField.autoSize = "left";
		valueTextField.textAutoSize = "none";
		
		valueTextField.border = true;
		valueTextField.borderColor = 0xFFFF00;
		
		valueTextField._x = _widgetWidth - _paddingRight - valueTextField._width;
		valueTextField._y = _paddingTop;
		
		if (!a_noResize) {
			fixTextOverlap();
			verticalAlignTextFields(_verticalAlign);
			updateBackground();
		}
	}
	
	private function doSetTextFormats() {
		// Updates all text formats so we don't have unnecessarry setNewTextFormats..
		var labelTf: TextFormat = new TextFormat();
		labelTf.color = _labelTextColor;
		labelTf.font = _labelTextFont;
		labelTf.size = _labelTextSize;
		labelTextField.setNewTextFormat(labelTf);
		
		var valueTf: TextFormat = new TextFormat();
		valueTf.color = _valueTextColor;
		valueTf.font = _valueTextFont;
		valueTf.size = _valueTextSize;
		valueTextField.setNewTextFormat(valueTf);
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
		labelTextField._height = labelTextField.textHeight;
		
		valueTextField._width = availableWidth * (valueTextField._width / textWidth);
		valueTextField._height = valueTextField.textHeight;
		
		labelTextField._x = _paddingLeft;
		labelTextField._y = _paddingTop;
		
		valueTextField._x = _widgetWidth - _paddingRight - valueTextField._width;
		valueTextField._y = _paddingTop;
	}
	
	private function redrawBorder(): Void
	{
		if (!_initialized) {
			_initialized = true;
		} else {
			if (border != undefined)
				border.removeMovieClip();
		}
		
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
	
	private function verticalAlignTextFields(a_align: String) {
		var offset = new Object({top: 0,
								 center: Math.abs(labelTextField._height - valueTextField._height)/2,
								 baseline: Math.abs((labelTextField._height - labelTextField.getLineMetrics(labelTextField.numLines - 1)["descent"]) - (valueTextField._height - valueTextField.getLineMetrics(valueTextField.numLines - 1)["descent"])),
								 bottom: Math.abs(labelTextField._height - valueTextField._height)});
		if(labelTextField._height > valueTextField._height) {
			if (offset[a_align] != undefined)
				valueTextField._y += offset[a_align]
		} else {
			if (offset[a_align] != undefined)
				labelTextField._y += offset[a_align]
		}
	}
}