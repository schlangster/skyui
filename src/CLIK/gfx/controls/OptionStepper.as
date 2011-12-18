dynamic class gfx.controls.OptionStepper extends gfx.core.UIComponent
{
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", change: "change"};
	var _selectedIndex: Number = 0;
	var _labelField: String = "label";
	var __height;
	var __width;
	var _dataProvider;
	var _disabled;
	var _focused;
	var _height;
	var _labelFunction;
	var _name;
	var _width;
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
		this.tabChildren = false;
		this.focusEnabled = this.tabEnabled = !this._disabled;
		this.dataProvider = [];
	}

	function get disabled()
	{
		return this._disabled;
	}

	function set disabled(value)
	{
		if (this._disabled != value) 
		{
			super.disabled = value;
			this.focusEnabled = this.tabEnabled = !this._disabled;
			this.gotoAndPlay(this._disabled ? "disabled" : (this._focused ? "focused" : "default"));
			if (this.initialized) 
			{
				this.updateAfterStateChange();
				this.prevBtn.disabled = this.nextBtn.__set__disabled(this._disabled);
				return;
			}
		}
	}

	function get dataProvider()
	{
		return this._dataProvider;
	}

	function set dataProvider(value)
	{
		if (value != this._dataProvider) 
		{
			if (this._dataProvider != null) 
			{
				this._dataProvider.removeEventListener("change", this, "onDataChange");
			}
			this._dataProvider = value;
			this.selectedItem = null;
			if (this._dataProvider != null) 
			{
				if (value instanceof Array && !value.isDataProvider) 
				{
					gfx.data.DataProvider.initialize(this._dataProvider);
				}
				else if (this._dataProvider.initialize != null) 
				{
					this._dataProvider.initialize(this);
				}
				this._dataProvider.addEventListener("change", this, "onDataChange");
				this.updateSelectedItem();
				return;
			}
		}
	}

	function get selectedIndex()
	{
		return this._selectedIndex;
	}

	function set selectedIndex(value)
	{
		var __reg2 = Math.max(0, Math.min(this._dataProvider.length - 1, value));
		if (__reg2 != this._selectedIndex) 
		{
			this._selectedIndex = __reg2;
			this.updateSelectedItem();
			return;
		}
	}

	function get labelField()
	{
		return this._labelField;
	}

	function set labelField(value)
	{
		this._labelField = value;
		this.updateLabel();
	}

	function get labelFunction()
	{
		return this._labelFunction;
	}

	function set labelFunction(value)
	{
		this._labelFunction = value;
		this.updateLabel();
	}

	function itemToLabel(item)
	{
		if (item == null) 
		{
			return "";
		}
		if (this._labelFunction == null) 
		{
			if (this._labelField != null && item[this._labelField] != null) 
			{
				return item[this._labelField];
			}
		}
		else 
		{
			return this._labelFunction(item);
		}
		return item.toString();
	}

	function invalidateData()
	{
		this._dataProvider.requestItemAt(this._selectedIndex, this, "populateText");
	}

	function handleInput(details, pathToFocus)
	{
		var __reg2 = details.value == "keyDown" || details.value == "keyHold";
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.RIGHT) 
		{
			if (this._selectedIndex < this._dataProvider.length - 1) 
			{
				if (__reg2) 
				{
					this.onNext();
				}
				return true;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.LEFT) 
		{
			if (this._selectedIndex > 0) 
			{
				if (__reg2) 
				{
					this.onPrev();
				}
				return true;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.HOME) 
		{
			if (!__reg2) 
			{
				this.selectedIndex = 0;
			}
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.END) 
		{
			if (!__reg2) 
			{
				this.selectedIndex = this._dataProvider.length - 1;
			}
			return true;
		}
		return false;
	}

	function toString()
	{
		return "[Scaleform OptionStepper " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		this.nextBtn.addEventListener("click", this, "onNext");
		this.prevBtn.addEventListener("click", this, "onPrev");
		this.prevBtn.focusTarget = this.nextBtn.focusTarget = this;
		this.prevBtn.tabEnabled = this.nextBtn.tabEnabled = false;
		this.prevBtn.autoRepeat = this.nextBtn.autoRepeat = true;
		this.prevBtn.disabled = this.nextBtn.__set__disabled(this._disabled);
		this.constraints = new gfx.utils.Constraints(this, true);
		this.constraints.addElement(this.textField, gfx.utils.Constraints.ALL);
		this.updateAfterStateChange();
	}

	function draw()
	{
		if (this.sizeIsInvalid) 
		{
			this._width = this.__width;
			this._height = this.__height;
		}
		super.draw();
		if (this.constraints != null) 
		{
			this.constraints.update(this.__width, this.__height);
		}
	}

	function changeFocus()
	{
		this.gotoAndPlay(this._disabled ? "disabled" : (this._focused ? "focused" : "default"));
		this.updateAfterStateChange();
		this.prevBtn.displayFocus = this.nextBtn.__set__displayFocus(this._focused != 0);
	}

	function updateAfterStateChange()
	{
		this.validateNow();
		this.updateLabel();
		if (this.constraints != null) 
		{
			this.constraints.update(this.__width, this.__height);
		}
		this.dispatchEvent({type: "stateChange", state: this._disabled ? "disabled" : (this._focused ? "focused" : "default")});
	}

	function updateLabel()
	{
		if (this.selectedItem != null) 
		{
			if (this.textField != null) 
			{
				this.textField.text = this.itemToLabel(this.selectedItem);
			}
		}
	}

	function updateSelectedItem()
	{
		this.invalidateData();
	}

	function populateText(item)
	{
		this.selectedItem = item;
		this.updateLabel();
		this.dispatchEvent({type: "change"});
	}

	function onNext(evtObj)
	{
		this.selectedIndex = this.selectedIndex + 1;
	}

	function onPrev(evtObj)
	{
		this.selectedIndex = this.selectedIndex - 1;
	}

	function onDataChange(event)
	{
		this.invalidateData();
	}

}
