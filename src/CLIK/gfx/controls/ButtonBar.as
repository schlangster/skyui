dynamic class gfx.controls.ButtonBar extends gfx.core.UIComponent
{
	var _itemRenderer: String = "Button";
	var _spacing: Number = 0;
	var _direction: String = "horizontal";
	var _selectedIndex: Number = -1;
	var _autoSize: String = "none";
	var _buttonWidth: Number = 0;
	var _labelField: String = "label";
	var reflowing: Boolean = false;
	var _dataProvider;
	var _disabled;
	var _focused;
	var _labelFunction;
	var _name;
	var attachMovie;
	var dispatchEventAndSound;
	var focusEnabled;
	var getNextHighestDepth;
	var initialized;
	var invalidate;
	var renderers;
	var tabChildren;
	var tabEnabled;

	function ButtonBar()
	{
		super();
		this.renderers = [];
		this.focusEnabled = this.tabEnabled = !this._disabled;
		this.tabChildren = false;
	}

	function get disabled()
	{
		return this._disabled;
	}

	function set disabled(value)
	{
		super.disabled = value;
		this.focusEnabled = this.tabEnabled = !this._disabled;
		if (this.initialized) 
		{
			var __reg3 = 0;
			while (__reg3 < this.renderers.length) 
			{
				this.renderers[__reg3].disabled = this._disabled;
				++__reg3;
			}
			return;
		}
	}

	function get dataProvider()
	{
		return this._dataProvider;
	}

	function set dataProvider(value)
	{
		if (this._dataProvider != value) 
		{
			if (this._dataProvider != null) 
			{
				this._dataProvider.removeEventListener("change", this, "onDataChange");
			}
			this._dataProvider = value;
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
				this.selectedIndex = 0;
				this.tabEnabled = this.focusEnabled = !this._disabled && this._dataProvider.length > 0;
				this.reflowing = false;
				this.invalidate();
				return;
			}
		}
	}

	function invalidateData()
	{
		this.selectedIndex = Math.min(this._dataProvider.length - 1, this._selectedIndex);
		this.populateData();
		this.invalidate();
	}

	function get itemRenderer()
	{
		return this._itemRenderer;
	}

	function set itemRenderer(value)
	{
		this._itemRenderer = value;
		while (this.renderers.length > 0) 
		{
			this.renderers.pop().removeMovieClip();
		}
		this.invalidate();
	}

	function get spacing()
	{
		return this._spacing;
	}

	function set spacing(value)
	{
		this._spacing = value;
		this.invalidate();
	}

	function get direction()
	{
		return this._direction;
	}

	function set direction(value)
	{
		this._direction = value;
		this.invalidate();
	}

	function get autoSize()
	{
		return this._autoSize;
	}

	function set autoSize(value)
	{
		if (value != this._autoSize) 
		{
			this._autoSize = value;
			var __reg2 = 0;
			while (__reg2 < this.renderers.length) 
			{
				this.renderers[__reg2].autoSize = this._autoSize;
				++__reg2;
			}
			this.invalidate();
			return;
		}
	}

	function get buttonWidth()
	{
		return this._buttonWidth;
	}

	function set buttonWidth(value)
	{
		this._buttonWidth = value;
		this.invalidate();
	}

	function get selectedIndex()
	{
		return this._selectedIndex;
	}

	function set selectedIndex(value)
	{
		if (this._selectedIndex != value) 
		{
			this._selectedIndex = value;
			this.selectItem(this._selectedIndex);
			this.dispatchEventAndSound({type: "change", index: this._selectedIndex, renderer: this.renderers[this._selectedIndex], item: this.selectedItem, data: this.selectedItem.data});
			return;
		}
	}

	function get selectedItem()
	{
		return this._dataProvider.requestItemAt(this._selectedIndex);
	}

	function get data()
	{
		return this.selectedItem.data;
	}

	function get labelField()
	{
		return this._labelField;
	}

	function set labelField(value)
	{
		this._labelField = value;
		this.invalidate();
	}

	function get labelFunction()
	{
		return this._labelFunction;
	}

	function set labelFunction(value)
	{
		this._labelFunction = value;
		this.invalidate();
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

	function handleInput(details, pathToFocus)
	{
		var __reg4 = details.value == "keyDown" || details.value == "keyHold";
		var __reg2 = undefined;
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.LEFT) 
		{
			if (this._direction == "horizontal") 
			{
				__reg2 = this._selectedIndex - 1;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.RIGHT) 
		{
			if (this._direction == "horizontal") 
			{
				__reg2 = this._selectedIndex + 1;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.UP) 
		{
			if (this._direction == "vertical") 
			{
				__reg2 = this._selectedIndex - 1;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.DOWN) 
		{
			if (this._direction == "vertical") 
			{
				__reg2 = this._selectedIndex + 1;
			}
		}
		if (__reg2 != null) 
		{
			__reg2 = Math.max(0, Math.min(this._dataProvider.length - 1, __reg2));
			if (__reg2 != this._selectedIndex) 
			{
				if (!__reg4) 
				{
					return true;
				}
				this.selectedIndex = __reg2;
				return true;
			}
		}
		return false;
	}

	function toString()
	{
		return "[Scaleform ButtonBar " + this._name + "]";
	}

	function draw()
	{
		if (!this.reflowing) 
		{
			var __reg3 = this._dataProvider.length;
			while (this.renderers.length > __reg3) 
			{
				var __reg2 = MovieClip(this.renderers.pop());
				__reg2.group.removeButton(__reg2);
				__reg2.removeMovieClip();
			}
			while (this.renderers.length < __reg3) 
			{
				this.renderers.push(this.createRenderer(this.renderers.length));
			}
			this.populateData();
			this.reflowing = true;
			this.invalidate();
			return undefined;
		}
		if (this.drawLayout() && this._selectedIndex != -1) 
		{
			this.selectItem(this._selectedIndex);
		}
	}

	function drawLayout()
	{
		if (this.renderers.length > 0 && !this.renderers[this.renderers.length - 1].initialized) 
		{
			this.reflowing = true;
			this.invalidate();
			return false;
		}
		this.reflowing = false;
		var __reg5 = 0;
		var __reg4 = 0;
		var __reg3 = 0;
		while (__reg3 < this.renderers.length) 
		{
			var __reg2 = this.renderers[__reg3];
			if (this._autoSize == "none" && this._buttonWidth > 0) 
			{
				__reg2.width = this._buttonWidth;
			}
			if (this._direction == "horizontal") 
			{
				__reg2._y = 0;
				__reg2._x = __reg5;
				__reg5 = __reg5 + (__reg2.width + this._spacing);
			}
			else 
			{
				__reg2._x = 0;
				__reg2._y = __reg4;
				__reg4 = __reg4 + (__reg2.height + this._spacing);
			}
			++__reg3;
		}
		return true;
	}

	function createRenderer(index)
	{
		var __reg2 = this.attachMovie(this.itemRenderer, "clip" + index, this.getNextHighestDepth(), {toggle: true, focusTarget: this, tabEnabled: false, autoSize: this._autoSize});
		if (__reg2 == null) 
		{
			return null;
		}
		__reg2.addEventListener("click", this, "handleItemClick");
		__reg2.index = index;
		__reg2.groupName = this._name + "ButtonGroup";
		return __reg2;
	}

	function handleItemClick(event)
	{
		var __reg2 = event.target;
		var __reg5 = __reg2.index;
		this.selectedIndex = __reg5;
		this.dispatchEventAndSound({type: "itemClick", data: this.selectedItem.data, item: this.selectedItem, index: __reg5, controllerIdx: event.controllerIdx});
	}

	function selectItem(index)
	{
		if (this.renderers.length >= 1) 
		{
			var __reg6 = this.renderers[index];
			if (!__reg6.selected) 
			{
				__reg6.selected = true;
			}
			var __reg4 = this.renderers.length;
			var __reg2 = 0;
			while (__reg2 < __reg4) 
			{
				if (__reg2 != index) 
				{
					var __reg3 = 100 + __reg4 - __reg2;
					this.renderers[__reg2].swapDepths(__reg3);
					this.renderers[__reg2].displayFocus = false;
				}
				++__reg2;
			}
			__reg6.swapDepths(1000);
			__reg6.displayFocus = this._focused;
		}
	}

	function changeFocus()
	{
		var __reg2 = this.renderers[this._selectedIndex];
		if (__reg2 != null) 
		{
			__reg2.displayFocus = this._focused;
		}
	}

	function onDataChange(event)
	{
		this.invalidateData();
	}

	function populateData()
	{
		var __reg2 = 0;
		for (;;) 
		{
			if (__reg2 >= this.renderers.length) 
			{
				return;
			}
			var __reg3 = this.renderers[__reg2];
			__reg3.label = this.itemToLabel(this._dataProvider.requestItemAt(__reg2));
			__reg3.data = this._dataProvider.requestItemAt(__reg2);
			__reg3.disabled = this._disabled;
			++__reg2;
		}
	}

}
