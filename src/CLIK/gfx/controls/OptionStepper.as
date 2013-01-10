class gfx.controls.OptionStepper extends gfx.core.UIComponent
{
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", change: "change"};
	
	var _selectedIndex:Number = 0;
	var _labelField:String = "label";
	
	var __height:Number;
	var __width:Number;

	var _dataProvider;
	var _disabled;
	var _focused;

	var _labelFunction;
	var _name;

	var constraints;
	var dispatchEvent;
	var focusEnabled;
	var gotoAndPlay;
	var initialized;
	var nextBtn;
	var prevBtn;
	var selectedItem;
	var sizeIsInvalid;
	var tabChildren;
	var tabEnabled;
	var textField;
	var validateNow;

	function OptionStepper()
	{
		super();
		tabChildren = false;
		focusEnabled = tabEnabled = !_disabled;
		dataProvider = [];
	}

	function get disabled()
	{
		return _disabled;
	}

	function set disabled(value)
	{
		if (_disabled != value) 
		{
			super.disabled = value;
			focusEnabled = tabEnabled = !_disabled;
			gotoAndPlay(_disabled ? "disabled" : (_focused ? "focused" : "default"));
			if (initialized) 
			{
				updateAfterStateChange();
				prevBtn.disabled = nextBtn.disabled = _disabled;
				return;
			}
		}
	}

	function get dataProvider()
	{
		return _dataProvider;
	}

	function set dataProvider(value)
	{
		if (value != _dataProvider) 
		{
			if (_dataProvider != null) 
			{
				_dataProvider.removeEventListener("change", this, "onDataChange");
			}
			_dataProvider = value;
			selectedItem = null;
			if (_dataProvider != null) 
			{
				if (value instanceof Array && !value.isDataProvider) 
				{
					gfx.data.DataProvider.initialize(_dataProvider);
				}
				else if (_dataProvider.initialize != null) 
				{
					_dataProvider.initialize(this);
				}
				_dataProvider.addEventListener("change", this, "onDataChange");
				updateSelectedItem();
				return;
			}
		}
	}

	function get selectedIndex()
	{
		return _selectedIndex;
	}

	function set selectedIndex(value)
	{
		var __reg2 = Math.max(0, Math.min(_dataProvider.length - 1, value));
		if (__reg2 != _selectedIndex) 
		{
			_selectedIndex = __reg2;
			updateSelectedItem();
			return;
		}
	}

	function get labelField()
	{
		return _labelField;
	}

	function set labelField(value)
	{
		_labelField = value;
		updateLabel();
	}

	function get labelFunction()
	{
		return _labelFunction;
	}

	function set labelFunction(value)
	{
		_labelFunction = value;
		updateLabel();
	}

	function itemToLabel(item)
	{
		if (item == null) 
		{
			return "";
		}
		if (_labelFunction == null) 
		{
			if (_labelField != null && item[_labelField] != null) 
			{
				return item[_labelField];
			}
		}
		else 
		{
			return _labelFunction(item);
		}
		return item.toString();
	}

	function invalidateData()
	{
		_dataProvider.requestItemAt(_selectedIndex, this, "populateText");
	}

	function handleInput(details, pathToFocus)
	{
		var __reg2 = details.value == "keyDown" || details.value == "keyHold";
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.RIGHT) 
		{
			if (_selectedIndex < _dataProvider.length - 1) 
			{
				if (__reg2) 
				{
					onNext();
				}
				return true;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.LEFT) 
		{
			if (_selectedIndex > 0) 
			{
				if (__reg2) 
				{
					onPrev();
				}
				return true;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.HOME) 
		{
			if (!__reg2) 
			{
				selectedIndex = 0;
			}
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.END) 
		{
			if (!__reg2) 
			{
				selectedIndex = _dataProvider.length - 1;
			}
			return true;
		}
		return false;
	}

	function toString()
	{
		return "[Scaleform OptionStepper " + _name + "]";
	}

	function configUI()
	{
		super.configUI();
		nextBtn.addEventListener("click", this, "onNext");
		prevBtn.addEventListener("click", this, "onPrev");
		prevBtn.focusTarget = nextBtn.focusTarget = this;
		prevBtn.tabEnabled = nextBtn.tabEnabled = false;
		prevBtn.autoRepeat = nextBtn.autoRepeat = true;
		prevBtn.disabled = nextBtn.disabled = _disabled;
		constraints = new gfx.utils.Constraints(this, true);
		constraints.addElement(textField, gfx.utils.Constraints.ALL);
		updateAfterStateChange();
	}

	function draw()
	{
		if (sizeIsInvalid) 
		{
			_width = __width;
			_height = __height;
		}
		super.draw();
		if (constraints != null) 
		{
			constraints.update(__width, __height);
		}
	}

	function changeFocus()
	{
		gotoAndPlay(_disabled ? "disabled" : (_focused ? "focused" : "default"));
		updateAfterStateChange();
		prevBtn.displayFocus = nextBtn.displayFocus = _focused != 0;
	}

	function updateAfterStateChange()
	{
		validateNow();
		updateLabel();
		if (constraints != null) 
		{
			constraints.update(__width, __height);
		}
		dispatchEvent({type: "stateChange", state: _disabled ? "disabled" : (_focused ? "focused" : "default")});
	}

	function updateLabel()
	{
		if (selectedItem != null) 
		{
			if (textField != null) 
			{
				textField.text = itemToLabel(selectedItem);
			}
		}
	}

	function updateSelectedItem()
	{
		invalidateData();
	}

	function populateText(item)
	{
		selectedItem = item;
		updateLabel();
		dispatchEvent({type: "change"});
	}

	function onNext(evtObj)
	{
		selectedIndex = selectedIndex + 1;
	}

	function onPrev(evtObj)
	{
		selectedIndex = selectedIndex - 1;
	}

	function onDataChange(event)
	{
		invalidateData();
	}

}
