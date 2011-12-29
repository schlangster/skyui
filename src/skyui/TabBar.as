import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.TabBar extends MovieClip
{
	static var LEFT_TAB = 1;
	static var RIGHT_TAB = 2;
	
	private var _activeTab:Number;
	
	// Children
	var backimage:MovieClip;
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
		
		_activeTab = undefined;
	}
	
	function tabPress(a_tabIndex:Number)
	{
		dispatchEvent({type:"tabPress", index: a_tabIndex});
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
		} else {
			leftIcon._alpha = 50;
			leftLabel._alpha = 50;
			rightIcon._alpha = 100;
			rightLabel._alpha = 100;
		}
	}
	
	function onLoad()
	{
		activeTab = LEFT_TAB;
		
		// TODO - doesn't seem to be working
		leftLabel.autoSize = "left";
		rightLabel.autoSize = "left";
		
		leftLabel.SetText("BUY");
		rightLabel.SetText("SELL");
		
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
		
		positionElements();
	}
	
	function onEnterFrame()
	{
		positionElements();
	}
	
	function positionElements()
	{
		// Left
		var leftPos = leftButton._x + (leftButton._width - 5 - leftLabel._width - leftIcon._width) / 2;
		leftIcon._x = leftPos;
		
		leftPos += leftIcon._width + 5;
		leftLabel._x = leftPos;
		
		// Right
		var rightPos = rightButton._x + (rightButton._width - 5 - rightLabel._width - rightIcon._width) / 2;
		rightIcon._x = rightPos;
		
		rightPos += rightIcon._width + 5;
		rightLabel._x = rightPos;
	}
}