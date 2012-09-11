import gfx.events.EventDispatcher;

import skyui.filter.ItemSortingFilter;


class skyui.components.TabBar extends MovieClip
{
  /* CONSTANTS */
  
	public static var LEFT_TAB = 0;
	public static var RIGHT_TAB = 1;


  /* STAGE ELEMENTS */
  
	public var image: MovieClip;
	public var leftLabel: TextField;
	public var rightLabel: TextField;
	public var leftIcon: MovieClip;
	public var rightIcon: MovieClip;
	public var leftButton: MovieClip;
	public var rightButton: MovieClip;
	

  /* PROPERTIES */

	private var _activeTab: Number;

	public function get activeTab(): Number
	{
		return _activeTab;
	}

	public function set activeTab(a_index: Number)
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
	
	
  /* INITIALIZATION */

	public function TabBar()
	{
		super();
		EventDispatcher.initialize(this);

		activeTab = LEFT_TAB;
	}
	
	// @override MovieClip
	public function onLoad(): Void
	{
		leftLabel.textAutoSize = "shrink";
		rightLabel.textAutoSize = "shrink";
		
		
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


  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function setIcons(a_leftName: String, a_rightName: String): Void
	{
		leftIcon.gotoAndStop(a_leftName);
		rightIcon.gotoAndStop(a_rightName);
	}

	public function setLabelText(a_leftText: String, a_rightText: String): Void
	{
		leftLabel.SetText(a_leftText.toUpperCase());
		rightLabel.SetText(a_rightText.toUpperCase());
	}

	public function tabPress(a_tabIndex: Number): Void
	{
		
		dispatchEvent({type:"tabPress", index:a_tabIndex});
	}
	
	public function tabToggle(): Void
	{
		tabPress(_activeTab == LEFT_TAB ? RIGHT_TAB : LEFT_TAB);
	}
}