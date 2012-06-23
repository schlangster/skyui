class skyui.widgets.WidgetLabel extends MovieClip {
	
	// Stage Elements
	var labelText: TextField;
	var valueText: TextField;
	
	// Public Variables
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
	
	var labelBorder: MovieClip;
	var labelBackground: MovieClip;
	
	// Private vars
	
	var _textFieldWidths: Number;
	var _labelTextRelativeWidth: Number;
	var _valueTextRelativeWidth: Number;
	var _backgroundHeight: Number;
	var _maxTextHeight: Number;
	
	function WidgetLabel() {
		textPadding = new Object({top: 0, right: 0, bottom: 0, left: 0});
		
		setWidgetParams(500, 200, 100, 0xCCCCCC, 100, 5, 0x000000, 100, 1);
		setWidgetTexts("<p align=\"center\"><font size=\"20\">Something really long that should line break, but it won't<br />is at a value of</font></p>", "<font size=\"50\">9001</font>");
		//setWidgetTexts("asdsa", "asds");
	}
	
	function setWidgetParams(a_widgetWidth: Number, a_labelWidth: Number, a_valueWidth: Number, a_backgroundColor: Number, a_backgroundAlpha: Number, a_borderWidth: Number, a_borderColor: Number, a_borderAlpha: Number, a_borderRounded: Number) {
		widgetWidth = a_widgetWidth;
		labelWidth = a_labelWidth;
		valueWidth = a_valueWidth;
		backgroundColor = a_backgroundColor;
		backgroundAlpha = a_backgroundAlpha;
		borderWidth = a_borderWidth;
		borderColor = a_borderColor;
		borderAlpha = a_borderAlpha;
		borderRounded = a_borderRounded;
		
		//
		_textFieldWidths = a_labelWidth + a_valueWidth;
		_labelTextRelativeWidth = a_labelWidth/_textFieldWidths;
		labelText._width = widgetWidth * (_labelTextRelativeWidth) - textPadding.left;
		
		_valueTextRelativeWidth = a_valueWidth/_textFieldWidths;
		valueText._width = widgetWidth * (_valueTextRelativeWidth) - textPadding.right;
	}
	
	function setWidgetLabel(a_label: String) {
		labelText.textAutoSize = "shrink";
		labelText.verticalAutoSize = "center";
		labelText.verticalAlign = "center";
		labelText.htmlText = a_label;
		labelText.setTextFormat();
		
		// Update the text positions
		updateTextPositions()
	}
	
	function setWidgetValue(a_value: String) {
		valueText.textAutoSize = "shrink";
		valueText.verticalAutoSize = "center";
		valueText.verticalAlign = "center";
		valueText.htmlText = a_value;
		valueText.setTextFormat();
		
		// Update the text positions
		updateTextPositions();
	}
	
	function setWidgetTexts(a_label: String, a_value: String) {
		labelText.textAutoSize = "shrink";
		labelText.verticalAutoSize = "center";
		labelText.verticalAlign = "top";
		labelText.htmlText = a_label;
		labelText.setTextFormat();
		
		valueText.textAutoSize = "shrink";
		valueText.verticalAutoSize = "center";
		valueText.verticalAlign = "top";
		valueText.htmlText = a_value;
		valueText.setTextFormat();
		
		// Update the text positions
		updateTextPositions();
	}
	
	function updateTextPositions() {
		// Move labelText and valueText to the appropriate position, so (0,0) is background TL
		labelText._x = textPadding.left;
		labelText._y = textPadding.top;

		valueText._x = widgetWidth - textPadding.right - valueText._width;
		valueText._y = textPadding.top;
		
		// Align the two textfields on the stage vertically w.r.t. y = height/2
		relativeVerticalAlign(labelText, valueText);
		
		_maxTextHeight = Math.max(labelText.textHeight, valueText.textHeight);
		
		drawBorder();
		drawBackground();
	}
	
	function drawBorder() {
		_backgroundHeight = textPadding.top + _maxTextHeight + textPadding.bottom;
		if (labelBorder != undefined)
			delete(labelBorder);
		labelBorder = _root.createEmptyMovieClip("labelBorder", _root.getNextHighestDepth());
		labelBorder.moveTo(0 - borderWidth/2 , 0 - borderWidth/2); // Start at TL
		labelBorder.lineStyle(borderWidth, borderColor, borderAlpha, true, "normal", (borderRounded) ? "round" : "square", (borderRounded) ? "round" : "miter");
		labelBorder.lineTo(widgetWidth + borderWidth/2, 0 - borderWidth/2); // TR
		labelBorder.lineTo(widgetWidth + borderWidth/2, _backgroundHeight + borderWidth/2); // BR
		labelBorder.lineTo(0 - borderWidth/2, _backgroundHeight + borderWidth/2); // BL
		labelBorder.lineTo(0 - borderWidth/2 , 0 - borderWidth/2); // TL
		moveToFront(this);
	}
	
	function drawBackground() {
		_backgroundHeight = textPadding.top + _maxTextHeight + textPadding.bottom;
		if(labelBackground != undefined)
			delete(labelBackground);
		labelBackground = _root.createEmptyMovieClip("labelBackground", _root.getNextHighestDepth());
		labelBackground.beginFill(backgroundColor, backgroundAlpha);
		labelBackground.moveTo(0, 0); // Start at TL
		labelBackground.lineTo(widgetWidth, 0); // TR
		labelBackground.lineTo(widgetWidth, _backgroundHeight); // BR
		labelBackground.lineTo(0, _backgroundHeight); // BL
		labelBackground.lineTo(0, 0); // TL
		labelBackground.endFill();
		moveToFront(this);
	}
	
	
	function moveToFront(mc: MovieClip) {
		if(mc.getDepth() - 1 != _root.getNextHighestDepth())
			mc.swapDepths(_root.getNextHighestDepth());
	}
	
	
	function setTextPadding(a_top: Number, a_right: Number, a_bottom: Number, a_left: Number) {
		textPadding.top = a_top;
		textPadding.right = a_right;
		textPadding.bottom = a_bottom;
		textPadding.left = a_left;
	}
	
	
	
	function relativeVerticalAlign(textFieldA: TextField, textFieldB: TextField) {
		var	midpointA: Number = textFieldA._y + textFieldA.textHeight/2;
		var	midpointB: Number = textFieldB._y + textFieldB.textHeight/2;
		var difference: Number = Math.abs(midpointA - midpointB);
		
		if(midpointA > midpointB) {
			textFieldB._y += difference;
		} else {
			textFieldA._y += difference;
		}
		
		textFieldA._y -= 2; // 2px Gutter
		textFieldB._y -= 2;
	}
	
}