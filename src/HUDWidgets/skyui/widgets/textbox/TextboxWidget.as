import skyui.widgets.WidgetBase;
import flash.geom.Transform;
import flash.geom.ColorTransform;

class skyui.widgets.textbox.TextboxWidget extends WidgetBase
{
  /* CONSTANTS */

	public static var ALIGN_BORDER = 0;
	public static var ALIGN_LEFT = 1;
	public static var ALIGN_RIGHT = 2;
	public static var ALIGN_CENTER = 3;
	
	
  /* PRIVATE VARIABLES */
  
	public var _labelTextField: TextField;
	public var _valueTextField: TextField;
	
	// Widget data
	private var _widgetWidth: Number;
	
	private var _labelText: String;
	private var _labelTextFont: String;
	private var _labelTextColor: Number;
	private var _labelTextAlpha: Number;
	private var _labelTextSize: Number;
	
	private var _valueText: String;
	private var _valueTextFont: String;
	private var _valueTextColor: Number;
	private var _valueTextAlpha: Number;
	private var _valueTextSize: Number;
	
	private var _textAlign: Number;
	
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
	

  /* STAGE ELEMENTS */
	
	public var border: MovieClip;
	public var background: MovieClip;
	
	public var content: MovieClip;
	

  /* INITIALIZATION */
	
	public function TextboxWidget()
	{
		super();
		
		_labelTextField = content.labelTextField;
		_valueTextField = content.valueTextField;
	}
	
	// @override WidgetBase
	function onLoad()
	{
		super.onLoad();
		
		// For testing in flash
		initWidgetNumbers(200, 0x0099000, 100, 5, 0xFF00FF, 100, 1, 5, 5, 5, 5, 0x00FFFF, 22, 0x00FFFF, 22, ALIGN_CENTER);
		initWidgetStrings("$EverywhereFont", "$EverywhereFont", "label", "value");
		initWidgetCommit();
		
//		setInterval(this, "testFunc", 1000);
	}
	
	var st = 0;
	
	function testFunc()
	{
		st++;
		
		if (st == 1) {
			setWidgetWidth(100);
			
		} else if (st == 2) {
			setWidgetWidth(300);
			
		} else if (st == 3) {
			setWidgetBackgroundColor(0xFF0000);
			setWidgetValueTextColor(0x00FFFF);
			setWidgetLabelTextColor(0xFF00FF);
			
		} else if (st == 4) {
			setWidgetBackgroundAlpha(25);
			
		} else if (st == 5) {
			setWidgetBorderColor(0xFFFF00);
			
		} else if (st == 6) {
			setWidgetBorderWidth(10);
			
		} else if (st == 7) {
			setWidgetBorderAlpha(25);
			
		} else if (st == 8) {
			setWidgetBorderRounded(0);
			
		} else if (st == 9) {
			setWidgetLabelText("Test Label");
			
		} else if (st == 10) {
			setWidgetValueText("Test Value");
			
		} else if (st == 11) {
			setWidgetLabelTextFont("$EverywhereMediumFont");
			setWidgetValueTextFont("$EverywhereMediumFont");
			setWidgetLabelTextSize(26);
			setWidgetValueTextSize(36);
			
		} else if (st == 12) {
			setWidgetValueTextColor(0x00FF00);
			setWidgetLabelTextColor(0x00FFFF);
			
		} else if (st == 13) {
			setWidgetTextAlign(ALIGN_LEFT);
			
		} else if (st == 14) {
			setWidgetTextAlign(ALIGN_RIGHT);
			
		} else if (st == 15) {
			setWidgetTextAlign(ALIGN_CENTER);
			
		} else if (st == 16) {
			setWidgetTextAlign(ALIGN_BORDER);
			
		} else if (st == 17) {
			setWidgetTexts("Test Labelsss", "Tost");
			st =  12;
		}
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
	
	public function getWidgetValueText(): String		{ return _valueText; }
	public function getWidgetValueTextFont(): String	{ return _valueTextFont; }
	public function getWidgetValueTextColor(): Number	{ return _valueTextColor; }
	public function getWidgetValueTextAlpha(): Number	{ return _valueTextAlpha; }
	public function getWidgetValueTextSize(): Number	{ return _valueTextSize; }
	
	public function getWidgetTextAlign(): Number		{ return _textAlign; }
	
	public function initWidgetNumbers(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number,
									  a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number,
									  a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number,
									  a_labelTextColor: Number, a_labelTextSize: Number, a_valueTextColor: Number, a_valueTextSize: Number,
									  a_textAlign: Number)
	{
		_widgetWidth = a_widgetWidth;
		setWidgetBackgroundColor(a_backgroundColor);
		setWidgetBackgroundAlpha(a_backgroundAlpha);
		
		_borderWidth = a_borderWidth;
		_borderColor = a_borderColor;
		_borderAlpha = a_borderAlpha;
		_borderRounded = a_borderRounded;
		
		_paddingTop = a_paddingTop;
		_paddingRight = a_paddingRight;
		_paddingBottom = a_paddingBottom;
		_paddingLeft = a_paddingLeft;
		
		setWidgetLabelTextColor(a_labelTextColor);
		_labelTextSize = a_labelTextSize;
		setWidgetValueTextColor(a_valueTextColor);
		_valueTextSize = a_valueTextSize;
		
		_textAlign = a_textAlign;
	}
	
	public function initWidgetStrings(a_labelTextFont: String, a_valueTextFont: String,
									  a_labelText: String, a_valueText: String): Void
	{
		_labelTextFont = a_labelTextFont;
		_valueTextFont = a_valueTextFont;
		
		_labelText = a_labelText;
		_valueText = a_valueText;
	}
	
	public function initWidgetCommit(): Void
	{
		updateLabelText(true);
		updateValueText();
	}
	
	public function setWidgetWidth(a_val: Number): Void
	{
		if (_widgetWidth == a_val)
			return;
			
		_widgetWidth = a_val;
		
		// Reset both text positions
		updateLabelText(true);
		updateValueText();
	}

	public function setWidgetBackgroundColor(a_val: Number): Void
	{
		if (_backgroundColor == a_val)
			return;
			
		_backgroundColor = a_val;
			
		var tf: Transform = new Transform(background);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _backgroundColor;
		tf.colorTransform = colorTf;
	}

	public function setWidgetBackgroundAlpha(a_val: Number): Void
	{
		if (_backgroundAlpha == a_val)
			return;
		
		background._alpha = _backgroundAlpha = a_val;
	}	

	public function setWidgetBorderColor(a_val: Number): Void
	{
		if (_borderColor == a_val && border)
			return;
			
		_borderColor = a_val;
		
		if (border) {
			var tf: Transform = new Transform(border);
			var colorTf: ColorTransform = new ColorTransform();
			colorTf.rgb = _borderColor;
			tf.colorTransform = colorTf;
		} else {
			redrawBorder();
		}
	}
	
	public function setWidgetBorderWidth(a_val: Number): Void
	{
		if (_borderWidth == a_val)
			return;
			
		_borderWidth = a_val;
		redrawBorder();
	}
	
	public function setWidgetBorderAlpha(a_val: Number): Void
	{
		if (_borderAlpha == a_val)
			return;
			
		_borderAlpha = a_val;
		if (border)
			border._alpha = a_val;
		else
			redrawBorder();
	}

	public function setWidgetBorderRounded(a_val: Number): Void
	{
		if (_borderRounded == a_val)
			return;
		
		_borderRounded = a_val;
		redrawBorder();
	}
	
	public function setWidgetPadding(a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number): Void
	{
		if (_paddingTop == a_paddingTop && _paddingRight == a_paddingRight && _paddingBottom == a_paddingBottom && _paddingLeft == a_paddingLeft)
			return;
			
		_paddingTop = a_paddingTop;
		_paddingBottom = a_paddingTop;
		_paddingRight = a_paddingRight;
		_paddingLeft = a_paddingLeft;

		updateLabelText(true);
		updateLabelText();
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		_labelText = a_labelText;
		_valueText = a_valueText;
		
		updateLabelText(true);
		updateValueText();
	}
	
	public function setWidgetLabelText(a_val: String)
	{
		if (_labelText == a_val)
			return
			
		_labelText = a_val;
		
		updateLabelText();
	}

	public function setWidgetLabelTextFont(a_val: String)
	{
		if (_labelTextFont == a_val)
			return;
			
		_labelTextFont = a_val;
		
		updateLabelTextFormat();
		updateLabelText();
	}
	
	public function setWidgetLabelTextColor(a_val: Number)
	{
		if (_labelTextColor == a_val)
			return;
			
		_labelTextField.textColor = _labelTextColor = a_val;
	}
	
	public function setWidgetLabelTextSize(a_val: Number)
	{
		if(_labelTextSize == a_val)
			return;
		
		_labelTextSize = a_val;
		
		updateLabelTextFormat();
		updateLabelText();
	}
	
	public function setWidgetValueText(a_val: String): Void
	{
		if(_valueText == a_val)
			return;
			
		_valueText = a_val;
		
		updateValueText();
	}

	public function setWidgetValueTextFont(a_val: String)
	{
		if(_valueTextFont == a_val)
			return;
			
		_valueTextFont = a_val;
		
		updateValueTextFormat();
		updateValueText();
	}

	public function setWidgetValueTextColor(a_val: Number)
	{
		if(_valueTextColor == a_val)
			return;
			
		_valueTextColor = _valueTextField.textColor = a_val;
	}
	
	public function setWidgetValueTextSize(a_val: Number)
	{
		if(_valueTextSize == a_val)
			return
			
		_valueTextSize = a_val;
		
		updateValueTextFormat();
		updateValueText();
	}
	
	public function setWidgetTextAlign(a_val: Number)
	{
		if (_textAlign == a_val)
			return;
			
		_textAlign = a_val;
		
		updateTextPositions();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function updateLabelText(a_noResize: Boolean): Void
	{
		if (a_noResize == undefined)
			a_noResize = false;
			
		_labelTextField.text = _labelText;
		
		if (!a_noResize) {
			updateBackgroundSize();
			updateTextPositions();
		}
	}
	
	private function updateValueText( a_noResize: Boolean): Void
	{
		if (a_noResize == undefined)
			a_noResize = false;
			
		_valueTextField.text = _valueText;
		
		if (!a_noResize) {
			updateBackgroundSize();
			updateTextPositions();
		}
	}
	
	private function updateLabelTextFormat(): Void
	{
		var tf: TextFormat = _labelTextField.getTextFormat();
		tf.size = _labelTextSize;
		tf.font = _labelTextFont;
		_labelTextField.setTextFormat(tf);
		_labelTextField.setNewTextFormat(tf);
	}
	
	private function updateValueTextFormat(): Void
	{
		var tf: TextFormat = _valueTextField.getTextFormat();
		tf.size = _valueTextSize;
		tf.font = _valueTextFont;
		_valueTextField.setTextFormat(tf);
		_valueTextField.setNewTextFormat(tf);
	}
	
	private function updateBackgroundSize()
	{
		var h = _paddingTop + _paddingBottom + Math.max(_labelTextField._height, _valueTextField._height);
		if (h == background._height && _widgetWidth == background._width && border != undefined)
			return;
			
		background._height = h;
		background._width = _widgetWidth;
		
		redrawBorder();
	}
	
	private function updateTextPositions(): Void
	{
		_labelTextField.autoSize = "left";
		_labelTextField.textAutoSize = "none";
		_valueTextField.autoSize = "left";
		_valueTextField.textAutoSize = "none";
		
		var availableWidth = _widgetWidth - _paddingLeft - _paddingRight;
		var textWidth = _labelTextField._width + _valueTextField._width;
		
		// Case 1: There's more available than required space
		if (availableWidth >= textWidth) {
			
			if (_textAlign == ALIGN_LEFT) {
				_labelTextField._x = _paddingLeft;
				_valueTextField._x = _labelTextField._x + _labelTextField._width;
				
			} else if (_textAlign == ALIGN_RIGHT) {
				_valueTextField._x = _widgetWidth - _paddingRight - _valueTextField._width;
				_labelTextField._x = _valueTextField._x - _labelTextField._width;
				
			} else if (_textAlign == ALIGN_CENTER) {
				_labelTextField._x = _paddingLeft + ((availableWidth - textWidth) / 2);
				_valueTextField._x = _labelTextField._x + _labelTextField._width;
				
			} else {
				_labelTextField._x = _paddingLeft;
				_valueTextField._x = _widgetWidth - _paddingRight - _valueTextField._width;
			}
			
		// Case 2: Text fields have to be shrunk to fit in available space.
		// No need for alignment because there's no free space.
		} else {
			_labelTextField.autoSize = "none";
			_labelTextField.textAutoSize = "shrink";
			
			_valueTextField.autoSize = "none";
			_valueTextField.textAutoSize = "shrink";
			
			_labelTextField._width = availableWidth * (_labelTextField._width / textWidth);
			_valueTextField._width = availableWidth * (_valueTextField._width / textWidth);
			
			_labelTextField._x = _paddingLeft;
			_valueTextField._x = _widgetWidth - _paddingRight - _valueTextField._width;
		}

		_labelTextField._y = _valueTextField._y = _paddingTop;

		if(_labelTextField._height > _valueTextField._height) {
			_valueTextField._y += (_labelTextField._height - _valueTextField._height)/2
		} else if (_valueTextField._height > _labelTextField._height) {
			_labelTextField._y += (_valueTextField._height - _labelTextField._height)/2
		}
	}
	
	private function redrawBorder(): Void
	{
		if (border != undefined)
			border.removeMovieClip();
		
		createEmptyMovieClip("border", getNextHighestDepth());
		
		if (_borderWidth == 0)
			return;
		
		var d = _borderWidth / 2;
		var left = background._x - d;
		var top = background._y - d;
		var right =  background._width + d;
		var bottom = background._height + d;
		
		border.lineStyle(_borderWidth, _borderColor, 100, true, "normal", _borderRounded ? "round" : "square", _borderRounded ? "round" : "miter");
		border.moveTo(left, top);
		border.lineTo(right, top);
		border.lineTo(right, bottom);
		border.lineTo(left, bottom);
		border.lineTo(left, top);
		
		border._alpha = _borderAlpha;
	}
}