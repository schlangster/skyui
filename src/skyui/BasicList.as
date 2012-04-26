import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import skyui.Config;
import skyui.EntryClipManager;
import skyui.BasicEntryFactory;
import skyui.BasicEnumeration;


class skyui.BasicList extends skyui.BSList
{
  /* CONSTANTS */
	public static var PLATFORM_PC = 0;

	public static var SELECT_MOUSE = 0;
	public static var SELECT_KEYBOARD = 1;

	
	
  /* STAGE ELEMENTS */

	public var anchorEntriesBegin:MovieClip;
	public var anchorEntriesEnd:MovieClip;
	
	
  /* PRIVATE VARIABLES */

	private var _entryClipManager: EntryClipManager;
	
	private var _listEnumeration: BasicEnumeration;
	

  /* PROPERTIES */
  
	private var _platform: Number;
	
	public function get platform(): Number
	{
		return _platform;
	}
  
	public function set platform(a_platform: Number)
	{
		_platform = a_platform;
		_bMouseDrivenNav = _platform == PLATFORM_PC;
	}
	
	private var _bMouseDrivenNav: Boolean;
	
	function get isMouseDrivenNav(): Boolean
	{
		return _bMouseDrivenNav;
	}

	function set isMouseDrivenNav(a_bFlag: Boolean)
	{
		_bMouseDrivenNav = a_bFlag;
	}
	
	private var _bListAnimating: Boolean;
	
	function get listAnimating(): Boolean
	{
		return _bListAnimating;
	}

	function set listAnimating(a_bFlag: Boolean)
	{
		_bListAnimating = a_bFlag;
	}

	private var _bDisableInput: Boolean;

	function get disableInput()
	{
		return _bDisableInput;
	}

	function set disableInput(a_bFlag: Boolean)
	{
		_bDisableInput = a_bFlag;
	}
	
	private var _bDisableSelection: Boolean;
	
	function get disableSelection(): Boolean
	{
		return _bDisableSelection;
	}
	
	function set disableSelection(a_bFlag: Boolean)
	{
		_bDisableSelection = a_bFlag;
	}

	// @override skyui.BSList
	public function get selectedIndex(): Number
	{
		return _selectedIndex;
	}
	
	// @override skyui.BSList
	function set selectedIndex(a_newIndex: Number)
	{
		doSetSelectedIndex(a_newIndex, SELECT_MOUSE);
	}
	
	
  /* CONSTRUCTORS */
  
	public function BasicList()
	{
		super();

		_bDisableSelection = false;
		_bDisableInput = false;
		_bMouseDrivenNav = false;
		_platform = PLATFORM_PC;

		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		
		initComponents();
	}

	
  /* PUBLIC FUNCTIONS */
  
	// mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
	// mixin by gfx.events.EventDispatcher
	public var addEventListener: Function;
	
	// @override skyui.BSList
	public function InvalidateData(): Void
	{
		_listEnumeration.invalidate();
		
		if (_selectedIndex >= _listEnumeration.size())
			_selectedIndex = _listEnumeration.size() - 1;

		UpdateList();
	}

	// @override skyui.BSList
	public function UpdateList(): Void
	{
		// abstract
	}
	
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		// abstract
	}

	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		// abstract
	}
	
	public function onItemRollOver(a_index: Number): Void
	{
		// abstract
	}
	
	public function onItemRollOut(a_index: Number): Void
	{
		// abstract
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function initComponents(): Void
	{
		_entryClipManager = new EntryClipManager(new BasicEntryFactory(this));
		_listEnumeration = new BasicEnumeration(_entryList);
	}

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number)
	{
		// abstract
	}
	
	// Helper
	private function getClipByIndex(a_index: Number): MovieClip
	{
		return _entryClipManager.getClipByIndex(a_index);
	}
}