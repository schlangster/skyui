import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import skyui.Config;
import skyui.EntryClipManager;


class skyui.BasicList extends skyui.BSList
{
  /* CONSTANTS */
	
	
  /* STAGE ELEMENTS */

	public var anchorEntriesBegin:MovieClip;
	public var anchorEntriesEnd:MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
	private var _bMouseDrivenNav: Boolean;

	private var _entryClipManager: EntryClipManager;


  /* PROPERTIES */
  
	private var _platform: Number;
	
	public function get platform(): Number
	{
		return _platform;
	}
  
	public function set platform(a_platform: Number)
	{
		_platform = a_platform;
		_bMouseDrivenNav = _platform == 0;
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

	// override skyui.BSList
	public function get selectedIndex(): Number
	{
		return _selectedIndex;
	}
	
	// override skyui.BSList
	function set selectedIndex(a_newIndex: Number)
	{
		doSetSelectedIndex(a_newIndex, 0);
	}
	
	
  /* CONSTRUCTORS */
  
	public function BasicList()
	{
		super();

		_bDisableSelection = false;
		_bDisableInput = false;
		_bMouseDrivenNav = false;
		_platform = 1;

		EventDispatcher.initialize(this);
		Mouse.addListener(this);
	}

	
  /* PUBLIC FUNCTIONS */
  
     // mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	
    // mixin by gfx.events.EventDispatcher
	public var addEventListener: Function;
	
	// override skyui.BSList
	public function InvalidateData(): Void
	{
		if (_selectedIndex >= _entryList.length)
			_selectedIndex = _entryList.length - 1;

		UpdateList();
	}

	// override skyui.BSList
	public function UpdateList(): Void
	{
		var xStart = anchorEntriesBegin._x;
		var yStart = anchorEntriesBegin._y;

		var yOffset = 0;

		for (var i = 0; i < _entryList.length; ++i) {
			var entryClip = _entryClipManager.getClipByIndex(i);

			setEntry(entryClip,_entryList[i]);
			_entryList[i].clipIndex = i;
			entryClip.itemIndex = i;

			entryClip._x = xStart;
			entryClip._y = yStart + yOffset;
			entryClip._visible = true;

			yOffset = yOffset + entryClip._height;
		}
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number)
	{
		if (!_bDisableSelection && a_newIndex != _selectedIndex) {
			var oldIndex = _selectedIndex;
			_selectedIndex = a_newIndex;

			if (oldIndex != -1)
				setEntry(_entryClipManager.getClipByIndex(_entryList[oldIndex].clipIndex),_entryList[oldIndex]);

			if (_selectedIndex != -1)
				setEntry(_entryClipManager.getClipByIndex(_entryList[_selectedIndex].clipIndex),_entryList[_selectedIndex]);

			dispatchEvent({type: "selectionChange", index: _selectedIndex, keyboardOrMouse: a_keyboardOrMouse});
		}
	}

	private function onItemPress(a_keyboardOrMouse: Number)
	{
		if (!_bDisableInput && !_bDisableSelection && _selectedIndex != -1)
			dispatchEvent({type: "itemPress", index: _selectedIndex, entry: _entryList[_selectedIndex], keyboardOrMouse: a_keyboardOrMouse});
	}

	private function onItemPressAux(a_keyboardOrMouse, a_buttonIndex)
	{
		if (!_bDisableInput && !_bDisableSelection && _selectedIndex != -1 && a_buttonIndex == 1)
			dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: _entryList[_selectedIndex], keyboardOrMouse: a_keyboardOrMouse});
	}

	private function setEntry(a_entryClip: MovieClip, a_entryObject: Object)
	{
		if (a_entryClip != undefined) {
			a_entryClip.selectArea._alpha = a_entryObject == selectedEntry ? 40 : 0;
			setEntryText(a_entryClip,a_entryObject);
		}
	}

	private function setEntryText(a_entryClip: MovieClip, a_entryObject: Object)
	{
		if (a_entryClip.textField != undefined) {
			a_entryClip.textField.textAutoSize = "shrink";

			if (a_entryObject.text != undefined)
				a_entryClip.textField.SetText(a_entryObject.text);
			else
				a_entryClip.textField.SetText(" ");

			if (a_entryObject.enabled != undefined)
				a_entryClip.textField.textColor = a_entryObject.enabled == false ? 0x606060 : 0xFFFFFF;

			if (a_entryObject.disabled != undefined)
				a_entryClip.textField.textColor = a_entryObject.disabled == true ? 0x606060 : 0xFFFFFF;
		}
	}
}