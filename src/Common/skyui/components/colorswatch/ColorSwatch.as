import gfx.controls.ButtonGroup;
import Shared.GlobalFunc;
import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode
import skyui.util.GlobalFunctions;
import skyui.components.colorswatch.ColorSquare;


class skyui.components.colorswatch.ColorSwatch extends MovieClip
{
  /* STAGE ELEMENTS */
  
	public var background: MovieClip;
	

  /* PRIVATE VARIABLES */
  
	private var _buttonGroup: ButtonGroup;
	private var _highestColorDepth: Number;
	private var _colorCols: Number; //Calculated from colorList.length and colorRows
	private var _selectedColor: Number;


  /* INITIALIZATION */

	public function ColorSwatch()
	{
		super();
		
		if (colorList == null) {
			colorList = [0x990033, 0xAD0073, 0xA17700, 0x803D0D, 0xBD4F19, 0x007A87, 0x162274, 0x4F2D7F, 0x56364D, 0x618E02, 0x008542, 0x5C4836, 0x999999, 0x000000,
						 0xCC0033, 0xE86BA5, 0xEAAB00, 0xB88454, 0xE37222, 0x99FFFF, 0x4060AF, 0x8C6CD0, 0x8F6678, 0x9EAB05, 0x19B271, 0xAA9C8F, 0xCCCCCC, 0xFFFFFF];
		}

		GlobalFunctions.addArrayFunctions();

		_colorCols = Math.floor(colorList.length/colorRows);

		_buttonGroup = new ButtonGroup();
		_buttonGroup.name = "colorButtons";

		var row, col: Number;
		var colorClip: MovieClip;
		for (var i: Number = 0; i < colorList.length; i++) {
			col = i % _colorCols;
			row = Math.floor(i/_colorCols);
			colorClip = attachMovie("ColorSquare", "ColorSquare" + i, getNextHighestDepth())
			colorClip._x = (col * colorSize) - col;
			colorClip._y = (row * colorSize) - row;
			colorClip._width = colorClip._height = colorSize;
			colorClip.color = colorList[i];
			colorClip.addEventListener("select", this, "onColorClipSelect");

			_buttonGroup.addButton(ColorSquare(colorClip));
		}

		background._width = _width;
		background._height = _height;

		_highestColorDepth = ((colorClip != undefined && colorList.length > 0)? colorClip.getDepth(): getNextHighestDepth());
	}


  /* PROPERTIES */
  
	public var colorRows: Number = 2;
	public var colorSize: Number = 25;
	public var colorList: Array;
  
	public function set selectedColor(a_color: Number): Void
	{
		_selectedColor = a_color;
		attemptSelectColor(_selectedColor);
	}
	
	public function get selectedColor(): Number
	{
		return _selectedColor;
	}
	

  /* PUBLIC FUNCTIONS */
  
	public function handleInput(a_details: InputDetails, a_pathToFocus: Array): Boolean
	{
		var handledInput: Boolean = false;

		if (GlobalFunc.IsKeyPressed(a_details, false)) {
			var currentButtonIdx: Number  = _buttonGroup.indexOf(_buttonGroup.selectedButton);

			var maxIndex: Number = _buttonGroup.length - 1;
			var newIndex: Number = currentButtonIdx;

			var row: Number = Math.floor(currentButtonIdx/_colorCols);
			var col: Number = currentButtonIdx % _colorCols;
			

			if (newIndex == -1) {
				switch (a_details.navEquivalent) {
					case NavigationCode.RIGHT:
					case NavigationCode.DOWN:
						newIndex = 0;
						handledInput = true;
						break;
					case NavigationCode.LEFT:
					case NavigationCode.UP:
						newIndex = maxIndex;
						handledInput = true;
						break;
				}

			} else {
				switch (a_details.navEquivalent) {
					case NavigationCode.UP:
						if (row > 0)
							newIndex -= _colorCols;
						else
							newIndex += _colorCols;
						handledInput = true;
						break;
					case NavigationCode.DOWN:
						if (row < (colorRows - 1))
							newIndex += _colorCols;
						else
							newIndex -= _colorCols;
						handledInput = true;
						break;
					// L/R doesn't wrap
					/*
					case NavigationCode.LEFT:
						if (newIndex != 0)
							newIndex -= 1;
						else
							newIndex += maxIndex;
						handledInput = true;
						break;
					case NavigationCode.RIGHT:
						if (newIndex!= maxIndex)
							newIndex += 1
						else
							newIndex -= maxIndex;
						handledInput = true;
						break;
					*/
					case NavigationCode.LEFT:
						if (col > 0)
							newIndex -= 1;
						else
							newIndex += _colorCols - 1;
						handledInput = true;
						break;
					case NavigationCode.RIGHT:
						if (col < (_colorCols - 1))
							newIndex += 1
						else
							newIndex -= _colorCols - 1;
						handledInput = true;
						break;
				}
			}

			if (newIndex != currentButtonIdx)
				_buttonGroup.setSelectedButton(_buttonGroup.getButtonAt(newIndex));
		}

		return handledInput;
	}


  /* PRIVATE FUNCTIONS */
  
	private function onColorClipSelect(event: Object): Void
	{
		var colorClip: ColorSquare = event.target;

		if (colorClip.selected) {
			_selectedColor = colorClip.color;

			colorClip._x -= (colorSize * 0.5/2);
			colorClip._y -= (colorSize * 0.5/2);
			colorClip._width = colorClip._height = colorSize * 1.5;
			colorClip.swapDepths(_highestColorDepth);
			colorClip.selector._alpha = 100;
		} else {
			colorClip._x += (colorSize * 0.5/2);
			colorClip._y += (colorSize * 0.5/2);
			colorClip._width = colorClip._height = colorSize;
			colorClip.selector._alpha = 0;
		}
	}

	private function attemptSelectColor(a_color: Number): Void
	{
		var buttonIndex: Number = colorList.indexOf(a_color);

		var colorClip: ColorSquare;
		if (buttonIndex == undefined) {
			colorClip = ColorSquare(_buttonGroup.getButtonAt(0));
		} else {
			colorClip = ColorSquare(_buttonGroup.getButtonAt(buttonIndex));
			_buttonGroup.setSelectedButton(colorClip);
		}
		
		FocusHandler.instance.setFocus(colorClip, 0);
	}
}