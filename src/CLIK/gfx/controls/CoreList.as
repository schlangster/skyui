dynamic class gfx.controls.CoreList extends gfx.core.UIComponent
{
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", select: "select", change: "change", rollOver: "rollOver", rollOut: "rollOut", itemClick: "itemClick", itemDoubleClick: "itemDoubleClick", itemPress: "itemPress", itemRollOver: "itemRollOver", itemRollOut: "itemRollOut"};
	var _itemRenderer: String = "ListItemRenderer";
	var _selectedIndex: Number = -1;
	var _labelField: String = "label";
	var externalRenderers: Boolean = false;
	var deferredScrollIndex: Number = -1;
	var __height;
	var __width;
	var _dataProvider;
	var _labelFunction;
	var _name;
	var _parent;
	var container;
	var createEmptyMovieClip;
	var dispatchEventAndSound;
	var focusEnabled;
	var inspectableRendererInstanceName;
	var invalidate;
	var owner;
	var renderers;
	var tabEnabled;

	function CoreList()
	{
		super();
		this.renderers = [];
		this.dataProvider = [];
		if (this.container == undefined) 
		{
			this.container = this.createEmptyMovieClip("container", 1);
		}
		this.container.scale9Grid = new flash.geom.Rectangle(0, 0, 1, 1);
		this.tabEnabled = this.focusEnabled = true;
	}

	function get itemRenderer()
	{
		return this._itemRenderer;
	}

	function set itemRenderer(value)
	{
		if (value == this._itemRenderer || value == "") 
		{
			return;
		}
		this._itemRenderer = value;
		this.resetRenderers();
		this.invalidate();
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
				this.invalidate();
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
		var __reg3 = this._selectedIndex;
		this._selectedIndex = value;
		this.dispatchEventAndSound({type: "change", index: this._selectedIndex, lastIndex: __reg3});
	}

	function scrollToIndex(index)
	{
	}

	function get labelField()
	{
		return this._labelField;
	}

	function set labelField(value)
	{
		this._labelField = value;
		this.invalidateData();
	}

	function get labelFunction()
	{
		return this._labelFunction;
	}

	function set labelFunction(value)
	{
		this._labelFunction = value;
		this.invalidateData();
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
	}

	function get availableWidth()
	{
		return this.__width;
	}

	function get availableHeight()
	{
		return this.__height;
	}

	function setRendererList(value)
	{
		if (this.externalRenderers) 
		{
			var __reg3 = 0;
			while (__reg3 < this.renderers.length) 
			{
				var __reg2 = this.renderers[__reg3];
				__reg2.owner = null;
				__reg2.removeEventListener("click", this, "handleItemClick");
				__reg2.removeEventListener("rollOver", this, "dispatchItemEvent");
				__reg2.removeEventListener("rollOut", this, "dispatchItemEvent");
				__reg2.removeEventListener("press", this, "dispatchItemEvent");
				__reg2.removeEventListener("doubleClick", this, "dispatchItemEvent");
				Mouse.removeListener(__reg2);
				++__reg3;
			}
		}
		else 
		{
			this.resetRenderers();
		}
		this.externalRenderers = value != null;
		if (this.externalRenderers) 
		{
			this.renderers = value;
		}
		this.invalidate();
	}

	function get rendererInstanceName()
	{
		return null;
	}

	function set rendererInstanceName(value)
	{
		if (value == null || value == "") 
		{
			return;
		}
		var __reg3 = 0;
		var __reg4 = [];
		while (!false) 
		{
			++__reg3;
			var __reg2 = this._parent[value + __reg3];
			if (__reg2 == null && __reg3 > 0) 
			{
				break;
			}
			if (__reg2 != null) 
			{
				this.setUpRenderer(__reg2);
				Mouse.addListener(__reg2);
				__reg2.scrollWheel = function (delta)
				{
					this.owner.scrollWheel(delta);
				}
				;
				__reg4.push(__reg2);
			}
		}
		if (__reg4.length == 0) 
		{
			__reg4 = null;
		}
		this.setRendererList(__reg4);
	}

	function toString()
	{
		return "[Scaleform CoreList " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		if (this._selectedIndex > -1) 
		{
			this.deferredScrollIndex = this._selectedIndex;
		}
		if (this.inspectableRendererInstanceName != "") 
		{
			this.rendererInstanceName = this.inspectableRendererInstanceName;
		}
		Mouse.addListener(this);
	}

	function createItemRenderer(index)
	{
		var __reg2 = this.container.attachMovie(this._itemRenderer, "renderer" + index, index);
		if (__reg2 == null) 
		{
			return null;
		}
		this.setUpRenderer(__reg2);
		return __reg2;
	}

	function setUpRenderer(clip)
	{
		clip.owner = this;
		clip.tabEnabled = false;
		clip.doubleClickEnabled = true;
		clip.addEventListener("press", this, "dispatchItemEvent");
		clip.addEventListener("click", this, "handleItemClick");
		clip.addEventListener("doubleClick", this, "dispatchItemEvent");
		clip.addEventListener("rollOver", this, "dispatchItemEvent");
		clip.addEventListener("rollOut", this, "dispatchItemEvent");
	}

	function createItemRenderers(startIndex, endIndex)
	{
		var __reg3 = [];
		var __reg2 = startIndex;
		while (__reg2 <= endIndex) 
		{
			__reg3.push(this.createItemRenderer[__reg2]);
			++__reg2;
		}
		return __reg3;
	}

	function draw()
	{
		if (this.deferredScrollIndex != -1) 
		{
			this.scrollToIndex(this.deferredScrollIndex);
			this.deferredScrollIndex = -1;
		}
	}

	function drawRenderers(totalRenderers)
	{
		while (this.renderers.length > totalRenderers) 
		{
			this.renderers.pop().removeMovieClip();
		}
		for (;;) 
		{
			if (this.renderers.length >= totalRenderers) 
			{
				return;
			}
			this.renderers.push(this.createItemRenderer(this.renderers.length));
		}
	}

	function getRendererAt(index)
	{
		return this.renderers[index];
	}

	function resetRenderers()
	{
		for (;;) 
		{
			if (this.renderers.length <= 0) 
			{
				return;
			}
			this.renderers.pop().removeMovieClip();
		}
	}

	function drawLayout(rendererWidth, rendererHeight)
	{
	}

	function onDataChange(event)
	{
		this.invalidateData();
	}

	function dispatchItemEvent(event)
	{
		var __reg9 = undefined;
		if ((__reg0 = event.type) === "press") 
		{
			__reg9 = "itemPress";
		}
		else if (__reg0 === "click") 
		{
			__reg9 = "itemClick";
		}
		else if (__reg0 === "rollOver") 
		{
			__reg9 = "itemRollOver";
		}
		else if (__reg0 === "rollOut") 
		{
			__reg9 = "itemRollOut";
		}
		else if (__reg0 === "doubleClick") 
		{
			__reg9 = "itemDoubleClick";
		}
		else 
		{
			return undefined;
		}
		var __reg3 = {target: this, type: __reg9, item: event.target.data, renderer: event.target, index: event.target.index, controllerIdx: event.controllerIdx};
		this.dispatchEventAndSound(__reg3);
	}

	function handleItemClick(event)
	{
		var __reg2 = event.target.index;
		if (isNaN(__reg2)) 
		{
			return undefined;
		}
		this.selectedIndex = __reg2;
		this.dispatchItemEvent(event);
	}

}
