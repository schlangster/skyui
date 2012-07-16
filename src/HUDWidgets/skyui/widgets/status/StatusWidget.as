import skyui.widgets.WidgetBase;
import Shared.GlobalFunc;
import flash.geom.Transform;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

class skyui.widgets.status.StatusWidget extends WidgetBase
{
  /* CONSTANTS */

	public static var ALIGN_BORDER = 0;
	public static var ALIGN_LEFT = 1;
	public static var ALIGN_RIGHT = 2;
	public static var ALIGN_CENTER = 3;
	
	
  /* PRIVATE VARIABLES */
  
	public var _labelTextField: TextField;
	public var _valueTextField: TextField;
	public var _icon: MovieClip;
	
	public var _meter: MovieClip;
	public var _meterFrameContent: MovieClip;
	public var _meterFillContent: MovieClip;
	public var _meterFlashAnim: MovieClip;
	public var _meterBarAnim: MovieClip;
	public var _meterBar: MovieClip;
	
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

	private var _iconSource: String;
	private var _iconName: String;
	private var _iconSize: Number;
	private var _iconColor: Number;
	private var _iconSpacing: Number;
	
	private var _textAlign: Number;
	private var _iconAlign: Number;
	
	private var _meterCurrentPercent: Number;
	private var _meterTargetPercent: Number;
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	private var _meterPadding: Number;
	private var _meterScale: Number;
	private var _meterFillMode: String;
	private var _meterFillSpeed: Number;
	private var _meterEmptySpeed: Number;
	private var _meterColorA: Number;
	private var _meterColorB: Number;
	private var _meterFlashColor: Number;
	

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
		_icon = content.icon;
		
		_meter = content.meterContent;
		_meterFrameContent = _meter.meterFrameHolder.meterFrameContent
		_meterFillContent = _meter.meterFillHolder.meterFillContent;
		_meterFlashAnim = _meterFrameContent.meterFlashAnim;
		_meterBarAnim = _meterFillContent.meterBarAnim;
		_meterBar = _meterBarAnim.meterBar;
		
		_labelTextField.autoSize = "left";
		_labelTextField.textAutoSize = "none";
		_valueTextField.autoSize = "left";
		_valueTextField.textAutoSize = "none";
	}
	
	// @override WidgetBase
	function onLoad()
	{
		super.onLoad();
		
		// For testing in flash
		/*initWidgetNumbers(200, 0x0099000, 100,
						  5, 0xFF00FF, 100, 1,
						  5, 5, 5, 5,
						  0x00FFFF, 48, 0x00FFFF, 22,
						  32, 0x0F55F0, 5,
						  ALIGN_BORDER, ALIGN_RIGHT, 5, 50, 0x003300, 0x339966, 0x009900);
		initWidgetStrings("$EverywhereFont", "$EverywhereFont",
						  "label", "value",
						  "../skyui/skyui_icons_psychosteve.swf", "weapon_sword", "right");
		initWidgetCommit();
		
		setInterval(this, "testFunc", 1000);*/
	}
	
	public function onLoadInit(a_icon: MovieClip)
	{
	skse.Log("onLoadInit")
		updateIcon();
		updateElementPositions();
	}
	
	public function onLoadError(a_icon:MovieClip, a_errorCode: String)
	{
	skse.Log("onLoadError: " + a_errorCode)
		skse.SendModEvent("widgetWarning", "WidgetID: " + _widgetID + " Invalid widget mode: " + a_errorCode);
	}
	
	var st: Number = 0;
	
	function testFunc()
	{
		st++;
		trace(st)
		if (st == 1) {
			setMeterPercent(0)
			setWidgetWidth(100);
			setWidgetLabelText("");
		} else if (st == 2) {
			setWidgetWidth(300);
			startMeterFlash();
			setWidgetMeterFillMode("center");
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
			setWidgetIconName("weapon_bow");
			setWidgetLabelTextSize(22);
			setWidgetValueTextSize(22);
			
		} else if (st == 18) {
			setWidgetIconSize(64);
			
		} else if (st == 19) {
			setWidgetIconAlign(ALIGN_LEFT);
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
	
	public function getWidgetIconSize(): Number			{return _iconSize;}
	public function getWidgetIconColor(): Number			{return _iconColor;}
	public function getWidgetIconSpacing(): Number		{return _iconSpacing;}
	public function getWidgetIconAlign(): Number			{return _iconAlign;}
	public function getWidgetIconSource(): String			{return _iconSource;}
	public function getWidgetIconName(): String			{return _iconName;}
	
	public function getWidgetMeterScale(): Number		{ return _meterScale; }
	public function getWidgetMeterFillMode(): String	{ return _meterFillMode; }
	public function getWidgetMeterFlashColor(): Number	{ return _meterFlashColor; }
	public function getMeterPercent(): Number			{ return _meterTargetPercent; } //Returns the target percent
	
	
	
	
	public function initWidgetNumbers(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number,
									  a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number,
									  a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number,
									  a_labelTextColor: Number, a_labelTextSize: Number, a_valueTextColor: Number, a_valueTextSize: Number,
									  a_iconSize: Number, a_iconColor: Number, a_iconSpacing: Number,
  									  a_textAlign: Number, a_iconAlign: Number, a_meterPadding: Number, a_meterScale: Number,
									  a_meterColorA: Number, a_meterColorB: Number, a_meterFlashColor: Number): Void
	{
	skse.Log("initWidgetNumbers");
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

		_iconSize = a_iconSize;
		_iconColor = a_iconColor;
		_iconSpacing = a_iconSpacing;
		
		_textAlign = a_textAlign;
		_iconAlign = a_iconAlign;
		
		_meterPadding = a_meterPadding;
		_meterScale = a_meterScale;
		
		_meterColorA = a_meterColorA;
		_meterColorB = a_meterColorB;
		_meterFlashColor = a_meterFlashColor;
	}
	
	public function initWidgetStrings(a_labelTextFont: String, a_valueTextFont: String,
									  a_labelText: String, a_valueText: String,
									  a_iconSource: String, a_iconName: String,
									  a_meterFillMode: String): Void
	{
		_labelTextFont = a_labelTextFont;
		_valueTextFont = a_valueTextFont;
		
		_labelTextField.text = _labelText = a_labelText;
		_valueTextField.text = _valueText = a_valueText;
		
		_iconSource = a_iconSource;
		_iconName = a_iconName;
		
		_meterFillMode = a_meterFillMode;
	}
	
	public function initWidgetCommit(): Void
	{
		loadIcon();
		updateLabelTextFormat();
		updateValueTextFormat();
		
		updateMeterFillMode();
		updateMeterFlashColor();
		
		updateBackgroundSize();
		updateElementPositions();
		
		onEnterFrame = updateMeter;
	}
	
	public function setWidgetWidth(a_val: Number): Void
	{
		if (_widgetWidth == a_val)
			return;
			
		_widgetWidth = a_val;
		
		// Reset both text positions
		updateBackgroundSize();
		updateElementPositions();
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
		_paddingBottom = a_paddingBottom;
		_paddingRight = a_paddingRight;
		_paddingLeft = a_paddingLeft;

		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetTexts(a_labelText: String, a_valueText: String): Void
	{
		_labelTextField.text = _labelText = a_labelText;
		_valueTextField.text = _valueText = a_valueText;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetLabelText(a_val: String): Void
	{
		if (_labelText == a_val)
			return
			
		_labelTextField.text = _labelText = a_val;
		
		updateBackgroundSize();
		updateElementPositions();
	}

	public function setWidgetLabelTextFont(a_val: String): Void
	{
		if (_labelTextFont == a_val)
			return;
			
		_labelTextFont = a_val;
		
		updateLabelTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetLabelTextColor(a_val: Number): Void
	{
		if (_labelTextColor == a_val)
			return;
			
		_labelTextField.textColor = _labelTextColor = a_val;
	}
	
	public function setWidgetLabelTextSize(a_val: Number): Void
	{
		if(_labelTextSize == a_val)
			return;
		
		_labelTextSize = a_val;
		
		updateLabelTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetValueText(a_val: String): Void
	{
		if(_valueText == a_val)
			return;
			
		_valueTextField.text = _valueText = a_val;
		
		updateBackgroundSize();
		updateElementPositions();
	}

	public function setWidgetValueTextFont(a_val: String): Void
	{
		if(_valueTextFont == a_val)
			return;
			
		_valueTextFont = a_val;
		
		updateValueTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}

	public function setWidgetValueTextColor(a_val: Number): Void
	{
		if(_valueTextColor == a_val)
			return;
			
		_valueTextColor = _valueTextField.textColor = a_val;
	}
	
	public function setWidgetValueTextSize(a_val: Number): Void
	{
		if(_valueTextSize == a_val)
			return
			
		_valueTextSize = a_val;
		
		updateValueTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetTextAlign(a_val: Number): Void
	{
		if (_textAlign == a_val)
			return;
			
		_textAlign = a_val;
		
		updateElementPositions();
	}
	
	public function setWidgetIconSize(a_val: Number): Void
	{
		if (_iconSize == a_val)
			return;
			
		_iconSize = a_val;
		
		updateIcon();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetIconColor(a_val: Number): Void
	{
		if (_iconColor == a_val)
			return;
			
		_iconColor = a_val;
		
		updateIcon();
	}
	
	public function setWidgetIconSpacing(a_val: Number): Void
	{
		if (_iconSpacing == a_val)
			return;
			
		_iconSpacing = a_val;
		
		updateElementPositions();
	}
	
	public function setWidgetIconAlign(a_val: Number): Void
	{
		if (_iconAlign == a_val)
			return;
			
		_iconAlign = a_val;
		
		updateElementPositions();
	}
	
	public function setWidgetIconSource(a_iconSource: String, a_initIconName: String): Void
	{
		if (_iconSource == a_iconSource)
			return;
			
		_iconSource = a_iconSource;
		_iconName = a_initIconName;
		
		loadIcon();
	}
	
	public function setWidgetIconName(a_iconName: String): Void
	{
		if (_iconName == a_iconName)
			return;
			
		_iconName = a_iconName;
		
		updateIcon();
	}
	
	public function setWidgetMeterScale(a_meterScale: Number): Void
	{
		if (_meterScale == a_meterScale)
			return;
			
		_meterScale = a_meterScale;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	public function setWidgetMeterFillMode(a_meterFillMode: String): Void
	{
		if (_meterFillMode == a_meterFillMode)
			return;
			
		_meterFillMode = a_meterFillMode;
		
		updateMeterFillMode();
	}
	
	public function setWidgetMeterFlashColor(a_meterFlashColor: Number): Void
	{
		if (_meterFlashColor == a_meterFlashColor)
			return;
			
		_meterFlashColor = a_meterFlashColor;
			
		updateMeterFlashColor();
	}
	
	public function startMeterFlash(): Void
	{
		if (_meterFlashAnim.meterFlashing) // Set on the timeline
			return;
		_meterFlashAnim.gotoAndPlay("StartFlash");
	}
	
	public function setMeterPercent(a_percent: Number, a_force: Boolean): Void
	{
		setMeterTargetPercent(a_percent);
		
		if (a_force)
			setMeterCurrentPercent(_meterTargetPercent);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function loadIcon(): Void
	{
		var iconLoader: MovieClipLoader = new MovieClipLoader();
		iconLoader.addListener(this);
		iconLoader.loadClip(_iconSource, _icon);
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
	
	private function updateBackgroundSize(): Void
	{
		var meterHeight: Number = _meterFrameContent._height * _meterScale/100;
		var h: Number = _paddingTop + _paddingBottom + Math.max(_labelTextField._height,  Math.max(_valueTextField._height, _iconSize)) + _meterPadding + meterHeight;
		
		if (h == background._height && _widgetWidth == background._width && border != undefined)
			return;

		background._height = h;
		background._width = _widgetWidth;
		
		redrawBorder();
	}
	
	private function updateIcon(): Void
	{
		var tf: Transform = new Transform(_icon);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _iconColor;
		tf.colorTransform = colorTf;
		
		_icon._width = _icon._height = _iconSize;
		_icon.gotoAndStop(_iconName);
	}
	
	private function updateElementPositions(): Void
	{
		_labelTextField.autoSize = "left";
		_labelTextField.textAutoSize = "none";
		_valueTextField.autoSize = "left";
		_valueTextField.textAutoSize = "none";
		
		var availableWidth: Number = _widgetWidth - _paddingLeft - _paddingRight - _iconSize - _iconSpacing;
		var meterHeight: Number = _meterFrameContent._height * _meterScale/100;
		var availableHeight: Number = background._height - _paddingTop - _paddingBottom - _meterPadding - meterHeight;
		var meterWidth: Number = _widgetWidth - _paddingLeft - _paddingRight;
		
		var textWidth: Number = _labelTextField._width + _valueTextField._width;
		var textStart: Number = (_iconAlign == ALIGN_RIGHT) ? _paddingLeft : (_paddingLeft + _iconSize + _iconSpacing);
		var textEnd: Number = (_iconAlign == ALIGN_RIGHT) ? (_widgetWidth - _paddingRight - _iconSize - _iconSpacing) : (_widgetWidth - _paddingRight);
		
		// Case 1: There's more available than required space
		if (availableWidth >= textWidth) {
			
			if (_textAlign == ALIGN_LEFT) {
				_labelTextField._x = textStart;
				_valueTextField._x = _labelTextField._x + _labelTextField._width;
				
			} else if (_textAlign == ALIGN_RIGHT) {
				_valueTextField._x = textEnd - _valueTextField._width;
				_labelTextField._x = _valueTextField._x - _labelTextField._width;
				
			} else if (_textAlign == ALIGN_CENTER) {
				_labelTextField._x = textStart + ((availableWidth - textWidth) / 2);
				_valueTextField._x = _labelTextField._x + _labelTextField._width;
				
			} else {
				_labelTextField._x = textStart;
				_valueTextField._x = textEnd - _paddingRight - _valueTextField._width;
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
			
			_labelTextField._x = textStart;
			_valueTextField._x = _labelTextField._x + _labelTextField._width;
		}

		_labelTextField._y = _paddingTop + (availableHeight - _labelTextField._height)/2
		_valueTextField._y = _paddingTop + (availableHeight - _valueTextField._height)/2
		
		_icon._x = (_iconAlign == ALIGN_RIGHT) ? (textEnd + _iconSpacing) : _paddingLeft;
		_icon._y = _paddingTop + (availableHeight - _iconSize)/2
		
		_meter._x = _paddingLeft;
		_meter._y = background._height - meterHeight - _paddingBottom;
		_meter._xscale = _meter._yscale = _meterScale;
		
		var newWidth: Number = meterWidth * 100/_meterScale;
		_meterFrameContent._width = newWidth;
		_meterFillContent._xscale = (newWidth - (33.25 + 33.25)) /  366.4 * 100;
	}
	
	private function redrawBorder(): Void
	{
		if (border != undefined)
			border.removeMovieClip();
		
		createEmptyMovieClip("border", getNextHighestDepth());
		
		if (_borderWidth == 0)
			return;
		
		var d: Number = _borderWidth / 2;
		var left: Number = background._x - d;
		var top: Number = background._y - d;
		var right: Number =  background._width + d;
		var bottom: Number = background._height + d;
		
		border.lineStyle(_borderWidth, _borderColor, 100, true, "normal", _borderRounded ? "round" : "square", _borderRounded ? "round" : "miter");
		border.moveTo(left, top);
		border.lineTo(right, top);
		border.lineTo(right, bottom);
		border.lineTo(left, bottom);
		border.lineTo(left, top);
		
		border._alpha = _borderAlpha;
	}
	
	private function initMeter(): Void
	{
		// Draws the meter
		var w: Number = _meterBar._width;
		var h: Number = _meterBar._height;
		var meterBevel: MovieClip = _meterBar.meterBevel;
		var meterShine: MovieClip = _meterBar.meterShine;
		
		var colors: Array = [0xCCCCCC, 0xFFFFFF, 0x000000, 0x000000, 0x000000];
		var alphas: Array = [10,       60,       0,        10,       30];
		//var ratios: Array = [0,        25,       25,       140,      153,      153,      255];
		var ratios: Array = [0,       115,      128,      128,      255];
		var matrix: Matrix = new Matrix();
		
		if (meterShine != undefined)
			return;
			
		meterShine = _meterBar.createEmptyMovieClip("meterShine", 2);
		
		meterBevel.swapDepths(1);
		matrix.createGradientBox(w, h, Math.PI/2);
		meterShine.beginGradientFill("linear", colors, alphas, ratios, matrix);
		meterShine.moveTo(0,0);
		meterShine.lineTo(w, 0);
		meterShine.lineTo(w, h);
		meterShine.lineTo(0, h);
		meterShine.lineTo(0, 0);
		meterShine.endFill();
	}
	
	private function updateMeterFillMode(): Void
	{
		switch(_meterFillMode) {
			case "left":
			case "center":
			case "right":
				break;
			default:
				_meterFillMode = "right"
		}
		
		_meterFillContent.gotoAndStop(_meterFillMode);
		
		initMeter();
		
		_meterCurrentPercent = 100;
		_meterTargetPercent = 100;
		_meterBarAnim.gotoAndStop("Empty");
		_meterEmptyIdx = _meterBarAnim._currentframe;
		_meterBarAnim.gotoAndStop("Full");
		_meterFullIdx = _meterBarAnim._currentframe;
		_meterFillSpeed = 2;
		_meterEmptySpeed = 3;
		
		drawMeterGradient();
	}
	
	private function drawMeterGradient(): Void
	{
		var colors: Array;
		var alphas: Array;
		var ratios: Array;
		var w: Number = _meterBar._width;
		var h: Number = _meterBar._height;
		var meterGradient: MovieClip = _meterBar.meterGradient;
		var matrix: Matrix = new Matrix();
		
		if (meterGradient != undefined)
			meterGradient.removeMovieClip();
			
		meterGradient = _meterBar.createEmptyMovieClip("meterGradient", 0);
		
		switch(_meterFillMode) {
			case "left":
				colors = [_meterColorB, _meterColorA];
				alphas = [100, 100];
				ratios = [0, 255];
				break;
			case "center":
				colors = [_meterColorA, _meterColorB, _meterColorA];
				alphas = [100, 100, 100];
				ratios = [0, 127, 255];
				break;
			case "right":
			default:
				colors = [_meterColorA, _meterColorB];
				alphas = [100, 100];
				ratios = [0, 255];
		}
		
		matrix.createGradientBox(w, h);
		meterGradient.beginGradientFill("linear", colors, alphas, ratios, matrix);
		meterGradient.moveTo(0,0);
		meterGradient.lineTo(w, 0);
		meterGradient.lineTo(w, h);
		meterGradient.lineTo(0, h);
		meterGradient.lineTo(0, 0);
		meterGradient.endFill();
	}
	
	private function updateMeterFlashColor(): Void
	{
		var tf: Transform = new Transform(_meterFlashAnim);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _meterFlashColor;
		tf.colorTransform = colorTf;
	}
	
	private function setMeterCurrentPercent(a_percent: Number): Void
	{
		_meterCurrentPercent = Math.min(100, Math.max(a_percent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, _meterCurrentPercent));
		_meterBarAnim.gotoAndStop(meterFrame);
	}
	
	private function setMeterTargetPercent(a_targetPercent: Number): Void
	{
		_meterTargetPercent = Math.min(100, Math.max(a_targetPercent, 0));
	}
	
	private function updateMeter(): Void
	{
		if (_meterTargetPercent == _meterCurrentPercent)
			return;
			
		if (_meterCurrentPercent < _meterTargetPercent) {
			_meterCurrentPercent = _meterCurrentPercent + _meterFillSpeed;
			if (_meterCurrentPercent > _meterTargetPercent)
				_meterCurrentPercent = _meterTargetPercent;
		} else {
			_meterCurrentPercent = _meterCurrentPercent - _meterEmptySpeed;
			if (_meterCurrentPercent < _meterTargetPercent)
				_meterCurrentPercent = _meterTargetPercent;
		}
		
		setMeterCurrentPercent(_meterCurrentPercent);
	}
}