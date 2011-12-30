import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class skyui.TabBar extends MovieClip
{
	static var LEFT_TAB = 0;
	static var RIGHT_TAB = 1;

	private var _activeTab:Number;

	// Children
	var image:MovieClip;
	var leftLabel:TextField;
	var rightLabel:TextField;
	var leftIcon:MovieClip;
	var rightIcon:MovieClip;
	var leftButton:MovieClip;
	var rightButton:MovieClip;

	//Mixin
	var dispatchEvent:Function;
	var addEventListener:Function;


	function TabBar()
	{
		super();
		EventDispatcher.initialize(this);

		activeTab = LEFT_TAB;
	}

	function setLabelText(leftText:String, rightText:String)
	{
		leftLabel.SetText(leftText.toUpperCase());
		rightLabel.SetText(rightText.toUpperCase());
	}

	function tabPress(a_tabIndex:Number)
	{
		
		dispatchEvent({type:"tabPress", index:a_tabIndex});
	}

	function get activeTab():Number
	{
		return _activeTab;
	}

	function set activeTab(a_index:Number)
	{
		_activeTab = a_index;

		if (a_index == LEFT_TAB) {
			leftIcon._alpha = 100;
			leftLabel._alpha = 100;
			rightIcon._alpha = 50;
			rightLabel._alpha = 50;
			image.gotoAndStop("left");
		} else {
			leftIcon._alpha = 50;
			leftLabel._alpha = 50;
			rightIcon._alpha = 100;
			rightLabel._alpha = 100;
			image.gotoAndStop("right");
		}
	}

	function onLoad()
	{
		leftButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.tabPress(LEFT_TAB);
		};

		leftButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.tabPress(LEFT_TAB);
		};

		leftButton.onRollOver = function()
		{
			if (_parent._activeTab != LEFT_TAB) {
				_parent.leftIcon._alpha = 75;
				_parent.leftLabel._alpha = 75;
			}
		};

		leftButton.onRollOut = function()
		{
			if (_parent._activeTab != LEFT_TAB) {
				_parent.leftIcon._alpha = 50;
				_parent.leftLabel._alpha = 50;
			}
		};

		rightButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.tabPress(RIGHT_TAB);
		};

		rightButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.tabPress(RIGHT_TAB);
		};

		rightButton.onRollOver = function()
		{
			if (_parent._activeTab != RIGHT_TAB) {
				_parent.rightIcon._alpha = 75;
				_parent.rightLabel._alpha = 75;
			}
		};

		rightButton.onRollOut = function()
		{
			if (_parent._activeTab != RIGHT_TAB) {
				_parent.rightIcon._alpha = 50;
				_parent.rightLabel._alpha = 50;
			}
		};
	}
	
	function handleInput(details, pathToFocus)
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
			
			if (details.navEquivalent == NavigationCode.SHIFT_TAB) {
				tabPress(_activeTab == LEFT_TAB ? RIGHT_TAB : LEFT_TAB);
				bCaught = true;
			}

			if (!bCaught) {
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
			}
		}
		
		return bCaught;
	}
}