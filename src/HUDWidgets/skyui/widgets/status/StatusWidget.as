import skyui.widgets.WidgetBase;
import Shared.GlobalFunc;
import flash.geom.Transform;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

class skyui.widgets.status.StatusWidget extends WidgetBase
{
  /* CONSTANTS */

  	public static var ALIGN_LEFT: String = "left";
  	public static var ALIGN_RIGHT: String = "right";
  	public static var ALIGN_CENTER: String = "center";
	public static var ALIGN_BORDER: String = "border";
	
	public static var FILL_LEFT: String = "left";
	public static var FILL_RIGHT: String = "right";
	public static var FILL_CENTER: String = "center";
	
	
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
	
	private var _iconLoader: MovieClipLoader;
	
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
	private var _borderRounded: Boolean;
	private var _borderWidth: Number;
	
	private var _backgroundColor: Number;
	private var _backgroundAlpha: Number;

	private var _iconSource: String;
	private var _iconName: String;
	private var _iconSize: Number;
	private var _iconColor: Number;
	private var _iconAlpha: Number;
	private var _iconSpacing: Number;
	
	private var _textAlign: String;
	private var _iconAlign: String;
	
	private var _meterCurrentPercent: Number;
	private var _meterTargetPercent: Number;
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	private var _meterSpacing: Number;
	private var _meterScale: Number;
	private var _meterFillMode: String;
	private var _meterFillSpeed: Number;
	private var _meterEmptySpeed: Number;
	private var _meterColorA: Number;
	private var _meterColorB: Number;
	private var _meterAlpha: Number;
	private var _meterFlashColor: Number;
	
	private var _iconLoaded: Boolean;
	

  /* STAGE ELEMENTS */
	
	public var border: MovieClip;
	public var background: MovieClip;
	public var content: MovieClip;
	

  /* INITIALIZATION */
	
	public function StatusWidget()
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
		_labelTextField.text = "";
		_valueTextField.autoSize = "left";
		_valueTextField.textAutoSize = "none";
		_valueTextField.text = "";
		_meter._visible = false;
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		_iconLoaded = false;
	}
	
	// @override WidgetBase
	public function onLoad(): Void
	{
		super.onLoad();
		
		// For testing in flash
		/*initNumbers(200, 0x0099000, 100,
						  5, 0xFF00FF, 100, 1,
						  5, 5, 5, 5,
						  0x00FFFF, 48, 0x00FFFF, 22,
						  20, 0x0F55F0, 100, 5,
						  5, 50, 0x003300, 0x339966, 50, 0x009900);
		initStrings("$EverywhereFont", "$EverywhereFont",
						  "Lab", "Val", ALIGN_BORDER,
						  "../skyui/skyui_icons_psychosteve.swf", "weapon_sword", ALIGN_RIGHT, FILL_CENTER);
		initCommit();
		
		setInterval(this, "testFunc", 1000);//*/
	}
	
	// @override MovieClipLoader
	public function onLoadInit(a_icon: MovieClip): Void
	{
		_iconLoaded = true;
		updateIcon();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @override MovieClipLoader
	public function onLoadError(a_icon:MovieClip, a_errorCode: String): Void
	{
		// TODO
		skse.SendModEvent("SKIWF_widgetError", "IconLoadFailure", Number(_widgetID)); //"WidgetID: " + _widgetID + " IconLoadError: " + a_errorCode + " (" + _iconSource + ")");
		
		unloadIcon();
	}
	
	var st: Number = 0;
	
	private function testFunc()
	{
		st++;
		trace(st)
		if (st == 1) {
			setMeterPercent(0)
			setWidth(100);
			setLabelText("");
		} else if (st == 2) {
			setWidth(300);
			startMeterFlash();
			setMeterFillMode("center");
			setIconSource("")
		} else if (st == 3) {
			setBackgroundColor(0xFF0000);
			setValueTextColor(0x00FFFF);
			setLabelTextColor(0xFF00FF);
			
		} else if (st == 4) {
			setBackgroundAlpha(25);
			setIconSource("../skyui/skyui_icons_psychosteve.swf");
			
		} else if (st == 5) {
			setBorderColor(0xFFFF00);
			
		} else if (st == 6) {
			setBorderWidth(10);
			
		} else if (st == 7) {
			setBorderAlpha(25);
			
		} else if (st == 8) {
			setBorderRounded(false);
			
		} else if (st == 9) {
			setLabelText("Test Label");
			
		} else if (st == 10) {
			setValueText("Test Value");
			
		} else if (st == 11) {
			setLabelTextFont("$EverywhereMediumFont");
			setValueTextFont("$EverywhereMediumFont");
			setLabelTextSize(26);
			setValueTextSize(36);
			
		} else if (st == 12) {
			setValueTextColor(0x00FF00);
			setLabelTextColor(0x00FFFF);
			
		} else if (st == 13) {
			setTextAlign(ALIGN_LEFT);
			
		} else if (st == 14) {
			setTextAlign(ALIGN_RIGHT);
			
		} else if (st == 15) {
			setTextAlign(ALIGN_CENTER);
			
		} else if (st == 16) {
			setTextAlign(ALIGN_BORDER);
			
		} else if (st == 17) {
			setTexts("Test Labelsss", "Tost");
			setIconName("weapon_bow");
			setLabelTextSize(22);
			setValueTextSize(22);
			
		} else if (st == 18) {
			setIconSize(64);
			
		} else if (st == 19) {
			setIconAlign(ALIGN_LEFT);
			st =  12;
		}
	}
	
  /* PAPYRUS INTERFACE */
	
	// @Papyrus
	public function initNumbers(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number,
								a_borderAlpha: Number, a_borderRounded: Boolean, a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number,
								a_paddingLeft: Number, a_labelTextColor: Number, a_labelTextSize: Number, a_valueTextColor: Number, a_valueTextSize: Number,
								a_iconSize: Number, a_iconColor: Number, a_iconAlpha: Number, a_iconSpacing: Number, a_meterScale: Number,
								a_meterColorA: Number, a_meterColorB: Number, a_meterAlpha: Number, a_meterSpacing: Number, a_meterFlashColor: Number): Void
	{
		_widgetWidth = a_widgetWidth;
		setBackgroundColor(a_backgroundColor);
		setBackgroundAlpha(a_backgroundAlpha);
		
		_borderWidth = a_borderWidth;
		_borderColor = a_borderColor;
		_borderAlpha = a_borderAlpha;
		_borderRounded = a_borderRounded;
		
		_paddingTop = a_paddingTop;
		_paddingRight = a_paddingRight;
		_paddingBottom = a_paddingBottom;
		_paddingLeft = a_paddingLeft;
		
		setLabelTextColor(a_labelTextColor);
		_labelTextSize = a_labelTextSize;
		setValueTextColor(a_valueTextColor);
		_valueTextSize = a_valueTextSize;

		_iconSize = a_iconSize;
		_iconColor = a_iconColor;
		_iconAlpha = a_iconAlpha;
		_iconSpacing = a_iconSpacing;
		
		_meterScale = a_meterScale;
		_meterColorA = a_meterColorA;
		_meterColorB = a_meterColorB;
		_meterAlpha = a_meterAlpha;
		_meterSpacing = a_meterSpacing;
		
		_meterFlashColor = a_meterFlashColor;
	}
	
	// @Papyrus
	public function initStrings(a_labelText: String, a_labelTextFont: String, a_valueText: String, a_valueTextFont: String, a_textAlign: String,
								a_iconSource: String, a_iconName: String, a_iconAlign: String, a_meterFillMode: String): Void
	{
		_labelTextField.text = _labelText = a_labelText;
		_labelTextFont = a_labelTextFont;
		
		_valueTextField.text = _valueText = a_valueText;
		_valueTextFont = a_valueTextFont;
		
		_textAlign = a_textAlign.toLowerCase();
		
		_iconSource = a_iconSource;
		_iconName = a_iconName;
		_iconAlign = a_iconAlign.toLowerCase();
		
		_meterFillMode = a_meterFillMode.toLowerCase();
	}
	
	// @Papyrus
	public function initCommit(): Void
	{
		loadIcon();
		updateLabelTextFormat();
		updateValueTextFormat();
		
		updateMeterFillMode();
		
		updateBackgroundSize();
		updateElementPositions();
		
		onEnterFrame = updateMeter;
	}
	
	// @Papyrus
	public function setWidth(a_val: Number): Void
	{
		if (_widgetWidth == a_val)
			return;
			
		_widgetWidth = a_val;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setBackgroundColor(a_val: Number): Void
	{
		if (_backgroundColor == a_val)
			return;
			
		_backgroundColor = a_val;
			
		var tf: Transform = new Transform(background);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _backgroundColor;
		tf.colorTransform = colorTf;
	}
	
	// @Papyrus
	public function setBackgroundAlpha(a_val: Number): Void
	{
		if (_backgroundAlpha == a_val)
			return;
		
		background._alpha = _backgroundAlpha = a_val;
	}
	
	// @Papyrus
	public function setBorderWidth(a_val: Number): Void
	{
		if (_borderWidth == a_val && border)
			return;
			
		_borderWidth = a_val;
		redrawBorder();
	}
	
	// @Papyrus
	public function setBorderColor(a_val: Number): Void
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
	
	// @Papyrus
	public function setBorderAlpha(a_val: Number): Void
	{
		if (_borderAlpha == a_val && border)
			return;
			
		_borderAlpha = a_val;
		if (border)
			border._alpha = a_val;
		else
			redrawBorder();
	}
	
	// @Papyrus
	public function setBorderRounded(a_val: Boolean): Void
	{
		if (_borderRounded == a_val && border)
			return;
		
		_borderRounded = a_val;
		redrawBorder();
	}
	
	// @Papyrus
	public function setLabelTextColor(a_val: Number): Void
	{
		if (_labelTextColor == a_val)
			return;
			
		_labelTextColor = _valueTextField.textColor = a_val;
	}
	
	// @Papyrus
	public function setLabelTextSize(a_val: Number): Void
	{
		if(_labelTextSize == a_val)
			return;
		
		_labelTextSize = a_val;
		
		updateLabelTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setValueTextColor(a_val: Number): Void
	{
		if(_valueTextColor == a_val)
			return;
			
		_valueTextColor = _valueTextField.textColor = a_val;
		
		updateValueTextFormat();
	}
	
	// @Papyrus
	public function setValueTextSize(a_val: Number): Void
	{
		if(_valueTextSize == a_val)
			return
			
		_valueTextSize = a_val;
		
		updateValueTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setIconSize(a_val: Number): Void
	{
		if (_iconSize == a_val)
			return;
			
		_iconSize = a_val;
		
		updateIcon();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setIconColor(a_val: Number): Void
	{
		if (_iconColor == a_val)
			return;
			
		_iconColor = a_val;
		
		updateIcon();
	}
	
	// @Papyrus
	public function setIconAlpha(a_val: Number): Void
	{
		if (_iconAlpha == a_val)
			return;
			
		_iconAlpha = a_val;
		
		updateIcon();
	}
	
	// @Papyrus
	public function setIconSpacing(a_val: Number): Void
	{
		if (_iconSpacing == a_val)
			return;
			
		_iconSpacing = a_val;
		
		updateElementPositions();
	}
	
	// @Papyrus
	public function setMeterScale(a_meterScale: Number): Void
	{
		if (_meterScale == a_meterScale)
			return;
			
		_meterScale = a_meterScale;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setMeterAlpha(a_meterAlpha: Number): Void
	{
		if (_meterAlpha == a_meterAlpha)
			return;
			
		_meter._alpha = _meterAlpha = a_meterAlpha;
	}
	
	// @Papyrus
	public function setMeterSpacing(a_meterSpacing: Number): Void
	{
		if (_meterSpacing == a_meterSpacing)
			return;
			
		_meterSpacing = a_meterSpacing;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setMeterFlashColor(a_meterFlashColor: Number): Void
	{
		if (_meterFlashColor == a_meterFlashColor)
			return;
			
		_meterFlashColor = a_meterFlashColor;
			
		updateMeterFlashColor();
	}
	
	// @Papyrus
	public function setLabelText(a_val: String): Void
	{
		if (_labelText == a_val)
			return
			
		_labelTextField.text = _labelText = a_val;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setLabelTextFont(a_val: String): Void
	{
		if (_labelTextFont == a_val)
			return;
			
		_labelTextFont = a_val;
		
		updateLabelTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setValueText(a_val: String): Void
	{
		if(_valueText == a_val)
			return;
			
		_valueTextField.text = _valueText = a_val;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setValueTextFont(a_val: String): Void
	{
		if(_valueTextFont == a_val)
			return;
			
		_valueTextFont = a_val;
		
		updateValueTextFormat();
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setTextAlign(a_val: String): Void
	{
		if (_textAlign == a_val.toLowerCase())
			return;
			
		_textAlign = a_val.toLowerCase();
		
		updateElementPositions();
	}
	
	// @Papyrus
	public function setIconSource(a_iconSource: String, a_initIconName: String): Void
	{
		if (_iconSource == a_iconSource)
			return;
			
		_iconSource = a_iconSource;
		if (a_initIconName)
			_iconName = a_initIconName;
		
		if (_iconSource == "")
			unloadIcon();
		else
			loadIcon();
	}
	
	// @Papyrus
	public function setIconName(a_iconName: String): Void
	{
		if (_iconName == a_iconName)
			return;
			
		_iconName = a_iconName;
		
		updateIcon();
	}
	
	// @Papyrus
	public function setIconAlign(a_val: String): Void
	{
		if (_iconAlign == a_val.toLowerCase())
			return;
			
		_iconAlign =  a_val.toLowerCase();
		
		updateElementPositions();
	}
	
	// @Papyrus
	public function setMeterFillMode(a_meterFillMode: String): Void
	{
		if (_meterFillMode == a_meterFillMode.toLowerCase())
			return;
			
		_meterFillMode = a_meterFillMode.toLowerCase();
		
		updateMeterFillMode();
	}
	
	// @Papyrus
	public function setPadding(a_paddingTop: Number, a_paddingRight: Number, a_paddingBottom: Number, a_paddingLeft: Number): Void
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
	
	// @Papyrus
	public function setTexts(a_labelText: String, a_valueText: String): Void
	{
		if(_labelText == a_labelText && _valueText == a_valueText)
			return;
			
		_labelTextField.text = _labelText = a_labelText;
		_valueTextField.text = _valueText = a_valueText;
		
		updateBackgroundSize();
		updateElementPositions();
	}
	
	// @Papyrus
	public function setMeterColors(a_meterColorA: Number, a_meterColorB: Number): Void
	{
		if (_meterColorA == a_meterColorA && _meterColorB == a_meterColorB)
			return;
			
		_meterColorA = a_meterColorA;
		_meterColorB = a_meterColorB;
		
		drawMeterGradient();
	}
	
	// @Papyrus
	public function setMeterPercent(a_percent: Number, a_force: Boolean): Void
	{
		_meterTargetPercent = Math.min(100, Math.max(a_percent, 0));
		
		if (a_force) {
			_meterCurrentPercent = _meterTargetPercent;
			var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, _meterCurrentPercent));
			_meterBarAnim.gotoAndStop(meterFrame);
		}
	}
	
	// @Papyrus
	public function startMeterFlash(a_force: Boolean): Void
	{
		if (_meterFlashAnim.meterFlashing && !a_force) // Set on the timeline
			return;
		
		_meterFlashAnim.gotoAndPlay("StartFlash");
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	
	private function updateLabelTextFormat(): Void
	{
		var tf: TextFormat = _labelTextField.getTextFormat();
		tf.font = _labelTextFont;
		tf.size = _labelTextSize;
		_labelTextField.setTextFormat(tf);
		_labelTextField.setNewTextFormat(tf);
	}
	
	private function updateValueTextFormat(): Void
	{
		var tf: TextFormat = _valueTextField.getTextFormat();
		tf.font = _valueTextFont;
		tf.size = _valueTextSize;
		_valueTextField.setTextFormat(tf);
		_valueTextField.setNewTextFormat(tf);
	}
	
	private function updateBackgroundSize(): Void
	{
		var labelTextFieldHeight: Number = (_labelText != "") ? _labelTextField._height : 0;
		var valueTextFieldHeight: Number = (_valueText != "") ? _valueTextField._height : 0;
		var iconSize: Number = (_iconLoaded) ? _iconSize : 0;
		
		var maxIconTextHeight: Number = Math.max(labelTextFieldHeight, Math.max(valueTextFieldHeight, iconSize));
		
		var meterHeight: Number = (_meterScale > 0) ? (_meterFrameContent._height * _meterScale/100) : 0;
		var meterSpacing: Number  = (_meterScale > 0 && maxIconTextHeight > 0) ? _meterSpacing : 0;
		
		var h: Number = _paddingTop + _paddingBottom + maxIconTextHeight + meterSpacing + meterHeight;
		
		if (h == background._height && _widgetWidth == background._width && border != undefined)
			return;

		background._height = h;
		background._width = _widgetWidth;
		
		redrawBorder();
	}
	
	private function loadIcon(): Void
	{
		_iconLoader.loadClip(_iconSource, _icon);
	}
	
	private function unloadIcon(): Void
	{
		_iconLoader.unloadClip(_icon);
		_iconLoaded = false;
		updateBackgroundSize();
		updateElementPositions();
	}
	
	private function updateIcon(): Void
	{
		var tf: Transform = new Transform(_icon);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _iconColor;
		tf.colorTransform = colorTf;
		
		_icon._alpha = _iconAlpha;
		
		_icon._width = _icon._height = _iconSize;
		if (_iconName == "")
			_icon.gotoAndStop(0);
		else
			_icon.gotoAndStop(_iconName);
	}
	
	private function updateElementPositions(): Void
	{
		_labelTextField.autoSize = "left";
		_labelTextField.textAutoSize = "none";
		_valueTextField.autoSize = "left";
		_valueTextField.textAutoSize = "none";
		
		var iconSize: Number = (_iconLoaded) ? _iconSize : 0;
		var iconSpacing: Number = (_iconLoaded) ? _iconSpacing : 0;
		
		var meterSpacing: Number = (_meterScale > 0) ? _meterSpacing : 0;
		var meterHeight: Number = (_meterScale > 0) ? (_meterFrameContent._height * _meterScale/100) : 0;
		var meterWidth: Number = _widgetWidth - _paddingLeft - _paddingRight;
		
		var availableHeight: Number = background._height - _paddingTop - _paddingBottom - meterSpacing - meterHeight;
		var availableWidth: Number = _widgetWidth - _paddingLeft - _paddingRight - iconSize - iconSpacing;
		
		var textWidth: Number = _labelTextField._width + _valueTextField._width;
		var textStart: Number = (_iconAlign == ALIGN_RIGHT) ? _paddingLeft : (_paddingLeft + iconSize + iconSpacing);
		var textEnd: Number = (_iconAlign == ALIGN_RIGHT) ? (_widgetWidth - _paddingRight - iconSize - iconSpacing) : (_widgetWidth - _paddingRight);
		
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

		_labelTextField._y = _paddingTop + (availableHeight - _labelTextField._height - 4)/2
		_valueTextField._y = _paddingTop + (availableHeight - _valueTextField._height - 4)/2
		
		_icon._x = (_iconAlign == ALIGN_RIGHT) ? (textEnd + iconSpacing) : _paddingLeft;
		_icon._y = _paddingTop + (availableHeight - iconSize)/2
		
		if (_meterScale <= 0) {
			_meter._visible = false
			return;
		}
		
		_meter._visible = true;
		_meter._x = _paddingLeft;
		_meter._y = background._height - meterHeight - _paddingBottom;
		_meter._xscale = _meter._yscale = _meterScale;
		
		var newMeterWidth: Number = meterWidth * 100/_meterScale;
		_meterFrameContent._width = newMeterWidth;
		_meterFillContent._xscale = (newMeterWidth - (33.25 + 33.25)) /  366.4 * 100;
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
		
		_meter._alpha = _meterAlpha;
		updateMeterFlashColor();
	}
	
	private function updateMeterFillMode(): Void
	{
		switch(_meterFillMode) {
			case FILL_LEFT:
			case FILL_CENTER:
			case FILL_RIGHT:
				break;
			default:
				_meterFillMode = FILL_RIGHT;
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
			case FILL_LEFT:
				colors = [_meterColorB, _meterColorA];
				alphas = [100, 100];
				ratios = [0, 255];
				break;
			case FILL_CENTER:
				colors = [_meterColorA, _meterColorB, _meterColorA];
				alphas = [100, 100, 100];
				ratios = [0, 127, 255];
				break;
			case FILL_RIGHT:
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
		
		_meterCurrentPercent = Math.min(100, Math.max(_meterCurrentPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, _meterCurrentPercent));
		_meterBarAnim.gotoAndStop(meterFrame);
	}
}