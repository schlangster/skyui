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
	
	private var _xOffset: Number;
	private var _contentWidth: Number;
	private var _totalWidth: Number;
	
	private var _selectorPos: Number;
	private var _targetSelectorPos: Number;
	private var _bFastSwitch: Boolean;
	
	private var _buttonGroup: ButtonGroup;


  /* PROPERTIES */
	
	// Distance from border to start icon.
	public var iconIndent: Number;
	
	public var selectedIndex: Number = 0;
	
	public var disableInput: Boolean = false;
	public var disableSelection: Boolean = false;
	
	
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
	}
	
	private function positionButtons()
	{
		formatTextButton(btnItem);
		formatTextButton(btnEnchantment);
		formatTextButton(btnSoul);
		
		vertSeparator._x = 120;
		
		var borderOffset = (vertSeparator._x / 2) - (btnDisenchant._width / 2);
		
		btnDisenchant._x = borderOffset;
		
		var leftStart = vertSeparator._x + 3;
		var leftEnd   = background._width;
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
	
	// @override BasicList
/*	public function UpdateList(): Void
	{		
		setClipCount(_segmentLength);

		var cw = 0;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);

			entryClip.setEntry(listEnumeration.at(i + _segmentOffset), listState);

			entryClip.background._width = entryClip.background._height = iconSize;

			listEnumeration.at(i + _segmentOffset).clipIndex = i;
			entryClip.itemIndex = i + _segmentOffset;

			cw = cw + iconSize;
		}

		_contentWidth = cw;
		_totalWidth = background._width;

		var spacing = (_totalWidth - _contentWidth) / (_segmentLength + 1);

		var xPos = background._x + spacing;

		for (var i = 0; i < _segmentLength; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;

			xPos = xPos + iconSize + spacing;
			entryClip._visible = true;
		}
		
		updateSelector();
	}*/
	
	// Moves the selection left to the next element. Wraps around.
	public function moveSelectionLeft(): Void
	{
		selectedIndex--;
		
		if (selectedIndex < 0) {
			_bFastSwitch = true;
			selectedIndex = _buttonGroup.length - 1;
		}
			
		_buttonGroup.setSelectedButton(_buttonGroup.getButtonAt(selectedIndex));
	}

	// Moves the selection right to the next element. Wraps around.
	public function moveSelectionRight(): Void
	{			
		var newIndex = selectedIndex;
		
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
	
	// @override BasicList
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
	
	private function onButtonSelect(a_event: Object): Void
	{		
		var btn = a_event.item;
		if (btn == null)
			return;
			

			
		selectedIndex = _buttonGroup.indexOf(btn);
	}


  /* PRIVATE FUNCTIONS */
	
/*	private function updateSelector(): Void
	{
		if (selectedIndex == -1) {
			selectorCenter._visible = false;

			if (selectorLeft != undefined)
				selectorLeft._visible = false;
				
			if (selectorRight != undefined)
				selectorRight._visible = false;

			return;
		}

//		var selectedClip = _entryClipManager.getClip(_selectedIndex - _segmentOffset);

		_targetSelectorPos = selectedClip._x + (selectedClip.background._width - selectorCenter._width) / 2;
		
		selectorCenter._visible = true;
		selectorCenter._y = selectedClip._y + selectedClip.background._height;
		
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
	}*/

	private function refreshSelector(): Void
	{
		selectorCenter._visible = true;
//		var selectedClip = _entryClipManager.getClip(_selectedIndex - _segmentOffset);

		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined)
			selectorLeft._width = selectorCenter._x;

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}
}