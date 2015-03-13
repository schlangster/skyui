import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.controls.Button;
import gfx.controls.ButtonGroup;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.BasicList;


class EnchantingBar extends MovieClip
{
  /* CONSTANTS */
	
	
  /* STAGE ELEMENTS */

	public var btnDisenchant: Button;
	public var btnItem: Button;
	public var btnEnchantment: Button;
	public var btnSoul: Button;
	
	public var vertSeparator: MovieClip;
	
	public var selectorCenter: MovieClip;
	public var selectorLeft: MovieClip;
	public var selectorRight: MovieClip;
	public var background: MovieClip;
	
	
  /* PRIVATE VARIABLES */
	
	private var _totalWidth: Number;
	
	private var _selectorPos: Number;
	private var _targetSelectorPos: Number;
	private var _bFastSwitch: Boolean;
	
	private var _buttonGroup: ButtonGroup;


  /* PROPERTIES */
	
	public var selectedIndex: Number = 0;
	
	public var disableInput: Boolean = false;
	
	
  /* INITIALIZATION */
	
	public function EnchantingBar()
	{
		super();
		
		_selectorPos = 0;
		_targetSelectorPos = 0;
		_bFastSwitch = false;
		
		_buttonGroup = new ButtonGroup("MainButtonGroup");
	}
	
	public function onLoad()
	{
		btnDisenchant.group  = _buttonGroup;
		btnItem.group        = _buttonGroup;
		btnEnchantment.group = _buttonGroup;
		btnSoul.group        = _buttonGroup;

		_buttonGroup.addEventListener("change", this, "onButtonSelect");
		
		positionButtons();
		
		_buttonGroup.setSelectedButton(btnDisenchant);
	}
	
	private function positionButtons()
	{
		_totalWidth = background._width;
		
		formatTextButton(btnItem);
		formatTextButton(btnEnchantment);
		formatTextButton(btnSoul);
		
		vertSeparator._x = 120;
		
		var borderOffset = (vertSeparator._x / 2) - (btnDisenchant._width / 2);
		
		btnDisenchant._x = borderOffset;
		
		var leftStart = vertSeparator._x + 3;
		var leftEnd   = _totalWidth;
		var leftWidth = leftEnd - leftStart;
		
		var totalBtnWidth = btnItem._width + btnEnchantment._width + btnSoul._width;
		var spacing = (leftWidth - totalBtnWidth - (2* borderOffset)) / 2;
		
		var pos = leftStart + borderOffset;
		
		btnItem._x = pos;
		pos += btnItem._width + spacing;
		
		btnEnchantment._x = pos;
		pos += btnEnchantment._width + spacing;
		
		btnSoul._x = pos;
	}
	
	private static function formatTextButton(a_button: MovieClip): Void
	{
		// its not autosizing. why? :(
		var tf = a_button.textField;
		tf.autoSize = "left";
		
		// ha.
		tf._width = tf.getLineMetrics(0).width + 10;
		
		a_button.background._width = tf._x + tf._width;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// Moves the selection left to the next element. Wraps around.
	public function moveSelectionLeft(): Void
	{
		var newIndex = selectedIndex - 1;
		
		if (newIndex < 0) {
			_bFastSwitch = true;
			newIndex = _buttonGroup.length - 1;
		}
			
		_buttonGroup.setSelectedButton(_buttonGroup.getButtonAt(newIndex));
	}

	// Moves the selection right to the next element. Wraps around.
	public function moveSelectionRight(): Void
	{			
		var newIndex = selectedIndex + 1;
		
		if (newIndex >= _buttonGroup.length) {
			_bFastSwitch = true;
			newIndex = 0;
		}
			
		_buttonGroup.setSelectedButton(_buttonGroup.getButtonAt(newIndex));
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.LEFT) {
				moveSelectionLeft();
				return true;
			} else if (details.navEquivalent == NavigationCode.RIGHT) {
				moveSelectionRight();
				return true;
			}
		}
		return false;
	}
	
	// @override MovieClip
	public function onEnterFrame(): Void
	{
		super.onEnterFrame();
		
		if (_bFastSwitch && _selectorPos != _targetSelectorPos) {
			_selectorPos = _targetSelectorPos;
			_bFastSwitch = false;
			refreshSelector();
			
		} else  if (_selectorPos < _targetSelectorPos) {
			_selectorPos = _selectorPos + (_targetSelectorPos - _selectorPos) * 0.2 + 1;
			
			refreshSelector();
			
			if (_selectorPos > _targetSelectorPos)
				_selectorPos = _targetSelectorPos;
			
		} else if (_selectorPos > _targetSelectorPos) {
			_selectorPos = _selectorPos - (_selectorPos - _targetSelectorPos) * 0.2 - 1;
			
			refreshSelector();
			
			if (_selectorPos < _targetSelectorPos)
				_selectorPos = _targetSelectorPos;
		}
	}
	

  /* PRIVATE FUNCTIONS */
  
	private function onButtonSelect(a_event: Object): Void
	{
		var btn = a_event.item;
		if (btn == null)
			return;
			

			
		selectedIndex = _buttonGroup.indexOf(btn);
		
		updateSelector();
	}
	
	// Note: Copy&paste from categorymenu. Could use some refactoring, but as long as it works
	// identically to the item menus its fine for now.
	
	private function updateSelector(): Void
	{
		if (selectedIndex == -1) {
			selectorCenter._visible = false;

			if (selectorLeft != undefined)
				selectorLeft._visible = false;
				
			if (selectorRight != undefined)
				selectorRight._visible = false;

			return;
		}

		var selectedButton = _buttonGroup.getButtonAt(selectedIndex)

		_targetSelectorPos = selectedButton._x + (selectedButton.icon._width - selectorCenter._width) / 2;
		
		selectorCenter._visible = true;
		selectorCenter._y = selectedButton._y + selectedButton.background._height;
		
		if (selectorLeft != undefined) {
			selectorLeft._visible = true;
			selectorLeft._x = 0;
			selectorLeft._y = selectorCenter._y;
		}

		if (selectorRight != undefined) {
			selectorRight._visible = true;
			selectorRight._y = selectorCenter._y;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}

	private function refreshSelector(): Void
	{
		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined)
			selectorLeft._width = selectorCenter._x;

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}
}