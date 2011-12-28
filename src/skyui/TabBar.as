import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;

class skyui.TabBar extends MovieClip
{
	static var LEFT_TAB = 1;
	static var RIGHT_TAB = 2;
	
	private var _columns:Array;
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
		
		_activeTab = LEFT_TAB;
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
	}
	
	function onLoad()
	{
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
		
		rightButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.columnPress(RIGHT_TAB);
		};

		rightButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
		{
			_parent.columnPress(RIGHT_TAB);
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