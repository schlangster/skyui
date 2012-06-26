import flash.filters.DropShadowFilter;

class skyui.widgets.WidgetLabel extends MovieClip
{
	// Variables
	var widgetWidth: Number;	// Absolute width of the widget excluding the border
	
	var labelWidth: Number;		// Relative width of the label textfield
	var valueWidth: Number;		// Relative width of the value textfield
	
	var backgroundColor: Number	// Color of the background, 0x000000 Black to 0xFFFFFF White
	var backgroundAlpha: Number	// Alpha value of the background, 0 transparent to 100 opaque
	
	var borderWidth: Number;	// Width of the border
	var borderColor: Number;	// Color of the border
	var borderAlpha: Number;	// Alpha value of the border
	var borderRounded: Number;	// Boolean, 1 gives the border round corners, 0 gives straight corners
	
	var textPadding: Object;	// Padding beween the border and the text fields: top, right, middle and bottom
	
	var defaultFontColor: Number;	// Default font colour used if one is not defined in the htmlText
	var defaultFontFace: String;	// Default font face used if one is not defined in the htmlText
	
	
	// Private Vars
	
	
	private var _textContainer: MovieClip;
	private var _labelTextField: TextField;
	private var _valueTextField: TextField;
	private var _textFieldShadow: DropShadowFilter;
	
	private var _backgroundHeight: Number;
	private var _background: MovieClip;
	private var _border: MovieClip;
	
	
	private var _borderBackground: MovieClip;
	private var _widgetBorder: MovieClip;
	private var _widgetBackground: MovieClip;
	
	
	
	// Public Vars
	

	
	
	function WidgetLabel()
	{
		_textContainer = _parent.createEmptyMovieClip("_textContainer", _parent.getNextHighestDepth());

		var textFieldFormat: TextFormat = new TextFormat();
		textFieldFormat.color = 0xFFFFFF;
		textFieldFormat.font = "$SkyrimBooks";
		textFieldFormat.size = 24;
		
		_textFieldShadow = new DropShadowFilter();
		_textFieldShadow.blurX = 2;
		_textFieldShadow.blurY = 2;
		_textFieldShadow.strength = 1.5;
		_textFieldShadow.quality = 2;
		_textFieldShadow.angle = 40;
		_textFieldShadow.distance = 2;
		_textFieldShadow.color = 0x000000;
		
		var filtersArray:Array = new Array();
		filtersArray.push(_textFieldShadow);
		
		_labelTextField = _textContainer.createTextField("_labelTextField", _textContainer.getNextHighestDepth(), 0, 0, 1, 1);
		_labelTextField.html = true;
		//_labelTextField.autoSize = "left";
		_labelTextField.verticalAutoSize = "top";
		_labelTextField.verticalAlign = "center";
		_labelTextField.setTextFormat(textFieldFormat);
		_labelTextField.multiline = true;
		_labelTextField.filters = filtersArray;
		

		
		_valueTextField = _textContainer.createTextField("_valueTextField", _textContainer.getNextHighestDepth(), 0, 0, 1, 1);
		_valueTextField.html = true;
		//_valueTextField.autoSize = "right";
		_valueTextField.verticalAutoSize = "top";
		_valueTextField.verticalAlign = "center";
		_valueTextField.setTextFormat(textFieldFormat);
		_valueTextField.multiline = true;
		_valueTextField.filters = filtersArray;
		
		textPadding = new Object({top: 0, right: 4, bottom: 0, left: 4});
		
		defaultFontColor = 0xFFFFFF;
		defaultFontFace = "$SkyrimBooks";
		
		// For testing...
		setWidgetParams(200, 0xCCCCCC, 50, 2, 0xFF0000, 50, 1);
		//setTextPadding(10, 10, 10, 10);
		
		//_labelTextField.border = _valueTextField.border = true;
		trace("");
		trace("=== Calling setWidgetText for the 1st");
		trace("");
		setWidgetText("<p align=\"center\"><font size=\"20\">Delicious Pi: </font></p>", "<font size=\"50\">3.14159265358979323846264338327...</font>");
		trace("");
		trace("=== Calling setWidgetText for the 2nd");
		trace("");
		setWidgetText("<p align=\"center\"><font size=\"20\">Pi:</font></p>", "<font size=\"50\">3</font>");

	}
	
	function setWidgetParams(a_widgetWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number)
	{
		debugTrace("setWidgetParams");
		
		widgetWidth = a_widgetWidth;
		backgroundColor = a_backgroundColor;
		backgroundAlpha = a_backgroundAlpha;
		borderWidth = a_borderWidth;
		borderColor = a_borderColor;
		borderAlpha = a_borderAlpha;
		borderRounded = a_borderRounded;		
	}	
	
	function setWidgetText(a_labelHTMLText: String, a_valueHTMLText: String): Void
	{
		debugTrace("setWidgetText");
		
		updateWidgetLabel(a_labelHTMLText);
			
		if (a_valueHTMLText != undefined)
			updateWidgetValue(a_valueHTMLText);
			
		updateTextPositions();
	}
	
	
	function updateWidgetLabel(a_labelHTMLText: String): Void
	{
		// 1) reset position to 0,0
		_labelTextField._x = 0;
		_labelTextField._y = 0;
		// 2) Set autoSize to left
		_labelTextField.autoSize = "left";
		_labelTextField.textAutoSize = "none";
		// 3) Set width to max
		_labelTextField._width = widgetWidth - (textPadding.left + textPadding.right);

		_labelTextField.htmlText = '<FONT COLOR="#' + toHexString(defaultFontColor) + '" FACE="' + defaultFontFace + '">' + a_labelHTMLText + '</FONT>';
		_labelTextField.setTextFormat();
		
		updateTextPositions();
		
		debugTrace("updateWidgetLabel", true);
	}
	
	function updateWidgetValue(a_valueHTMLText: String): Void
	{
		debugTrace("updateWidgetValue");
		// 1) reset position to 0,0
		_valueTextField._x = 0;
		_valueTextField._y = 0;
		// 2) Set autoSize to none
		_valueTextField.autoSize = "right";
		_valueTextField.textAutoSize = "none";
		// 3) Set width to max
		_valueTextField._width = widgetWidth - (textPadding.left + textPadding.right);
		
		_valueTextField.htmlText = '<FONT COLOR="#' + toHexString(defaultFontColor) + '" FACE="' + defaultFontFace + '">' + a_valueHTMLText + '</FONT>';
		_valueTextField.setTextFormat();
		
		updateTextPositions();

		debugTrace("updateWidgetValue", true);
	}
	
	private function updateTextPositions(): Void
	{
		var maxContainerWidth: Number = widgetWidth - (textPadding.left + textPadding.right);
	
		// Set _textContainer position to (0, 0) and set to max height and width of textFields
		_textContainer._x = 0;
		_textContainer._y = 0;
		_textContainer._width = Math.abs(Math.min(_labelTextField._x, _valueTextField._x) - Math.max(_labelTextField._x + _labelTextField._width, _valueTextField._x + _valueTextField._width));
		_textContainer._height = Math.abs(Math.min(_labelTextField._y, _valueTextField._y) - Math.max(_labelTextField.y + _labelTextField._height, _valueTextField._y + _valueTextField._height));
	
		// Allow resizing of textFields
		_labelTextField.autoSize = "none";
		_valueTextField.autoSize = "none";
		
		_labelTextField._x = 0;
		_valueTextField._x = _valueTextField._x;
		
		if(_textContainer._width > maxContainerWidth) {
			_valueTextField._x = (_labelTextField.text == "") ? 0 : _labelTextField._width;
			
			_labelTextField.textAutoSize = "shrink";
			_valueTextField.textAutoSize = "shrink";
			
			// Don't switch these around
			_textContainer._height = _textContainer._height/_textContainer._width * maxContainerWidth;
			_textContainer._width = maxContainerWidth;
			
			_labelTextField.autoSize = _labelTextField.getTextFormat()["align"] ? _labelTextField.getTextFormat()["align"] : "left";
			_valueTextField.autoSize = _valueTextField.getTextFormat()["align"] ? _valueTextField.getTextFormat()["align"] : "right";
		} else if (_valueTextField.text == "") {
			_labelTextField._width = maxContainerWidth;
			_labelTextField.autoSize = _labelTextField.getTextFormat()["align"] ? _labelTextField.getTextFormat()["align"] : "center";
		} else if (_labelTextField.text == "") {
			_valueTextField._x = 0;
			_valueTextField._width = maxContainerWidth;
			_valueTextField.autoSize = _valueTextField.getTextFormat()["align"] ? _valueTextField.getTextFormat()["align"] : "center";
		} else {
			_labelTextField._width = _valueTextField._x;
			_labelTextField.autoSize = _labelTextField.getTextFormat()["align"] ? _labelTextField.getTextFormat()["align"] : "left";
			_valueTextField.autoSize = _valueTextField.getTextFormat()["align"] ? _valueTextField.getTextFormat()["align"] : "right";
		}
		_backgroundHeight = textPadding.top + _textContainer._height + textPadding.bottom;
		
		_textContainer._x = textPadding.left;
		_textContainer._y = _textContainer._height/2 + textPadding.top - 1;
		
		relativeVerticalAlign(_labelTextField, _valueTextField)
		
		// (re)draw the border and background
		drawBorder();
		drawBackground();
		
		debugTrace("updateTextPositions", true);
		
	}
	
	function drawBorder(): Void
	{
		var depth: Number;
		
		if (borderWidth <= 0 || borderWidth == undefined)
			return;
			
		if (_parent.labelBorder != undefined) {
			depth = _parent.labelBorder.getDepth();
			_parent.labelBorder.removeMovieClip()
		} else {
			depth = _parent.getNextHighestDepth();
		}
		
		_border = _parent.createEmptyMovieClip("labelBorder", depth);
		_border.moveTo(0 - borderWidth/2 , 0 - borderWidth/2); // Start at TL
		_border.lineStyle(borderWidth, borderColor, borderAlpha, true, "normal", (borderRounded) ? "round" : "square", (borderRounded) ? "round" : "miter");
		_border.lineTo(widgetWidth + borderWidth/2, 0 - borderWidth/2); // TR
		_border.lineTo(widgetWidth + borderWidth/2, _backgroundHeight + borderWidth/2); // BR
		_border.lineTo(0 - borderWidth/2, _backgroundHeight + borderWidth/2); // BL
		_border.lineTo(0 - borderWidth/2 , 0 - borderWidth/2); // TL
		
		if (depth > _textContainer.getDepth())
			_textContainer.swapDepths(_border);
	}
	
	function drawBackground(): Void
	{
		var depth: Number;
		
		if (backgroundColor == undefined)
			return;
			
		if (_parent.labelBackground != undefined) {
			depth = _parent.labelBackground.getDepth();
			_parent.labelBackground.removeMovieClip()
		} else {
			depth = _parent.getNextHighestDepth();
		}
		
		_background = _parent.createEmptyMovieClip("labelBackground", depth);
		_background.beginFill(backgroundColor, backgroundAlpha);
		_background.moveTo(0, 0); // Start at TL
		_background.lineTo(widgetWidth, 0); // TR
		_background.lineTo(widgetWidth, _backgroundHeight); // BR
		_background.lineTo(0, _backgroundHeight); // BL
		_background.lineTo(0, 0); // TL
		_background.endFill();
		
		if (depth > _textContainer.getDepth())
			_textContainer.swapDepths(_background);
	}
	
	
	function setTextPadding(a_top: Number, a_right: Number, a_bottom: Number, a_left: Number): Void
	{
		var top: Number = Math.abs(a_top);
		var right: Number = Math.abs(a_right);
		var bottom: Number = Math.abs(a_bottom);
		var left: Number = Math.abs(a_left);
		
		if (widgetWidth && widgetWidth/2 < left + right) {
			var total: Number = right + left;
			left = left/total * widgetWidth/2
			right = right/total * widgetWidth/2
		}
		
		textPadding.top = top;
		textPadding.right = right;
		textPadding.bottom = bottom;
		textPadding.left = left;
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
	
	function toHexString(a_Number: Number, prefix: Boolean): String
	{
		var hex: String = "";
		var dec: Number = a_Number;
		var hexarr: Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
		
		while (dec > 0) {
			var bit: Number = dec % 16;
			hex = hexarr[bit] + hex;
			dec = Math.floor(dec / 16);
		}
		
		hex = ((prefix) ? "0x" : "") + hex;
		return hex;
	}
	
	
	function debugTrace(funcName: String, end: Boolean) {	
		return;
		trace("");
		trace("---");
		trace(funcName + "()" + ((end) ? " (end)" : ""));
		trace("");
		trace("_labelTextField");
		trace("_labelTextField._x: " + _labelTextField._x + ", _labelTextField._y: " + _labelTextField._y);
		trace("_labelTextField._width: " + _labelTextField._width + ", _labelTextField._height: " + _labelTextField._height);
		trace("_labelTextField.textWidth: " + _labelTextField.textWidth + ", _labelTextField.textHeight: " + _labelTextField.textHeight);
		trace("");
		trace("_valueTextField");
		trace("_valueTextField._x: " + _valueTextField._x + ", _valueTextField._y: " + _valueTextField._y);
		trace("_valueTextField._width: " + _valueTextField._width + ", _valueTextField._height: " + _valueTextField._height);
		trace("_valueTextField.textWidth: " + _valueTextField.textWidth + ", _valueTextField.textHeight: " + _valueTextField.textHeight);
		trace("");
		trace("_textContainer");
		trace("_textContainer._x: " + _textContainer._x + ", _textContainer._y: " + _textContainer._y);
		trace("_textContainer._width: " + _textContainer._width + ", _textContainer._height: " + _textContainer._height);
		trace("");
		trace("_background");
		trace("_background._width: " + _background._width + ", _background._height: " + _background._height);
		trace("---");
		trace("");
	}
	
	
};