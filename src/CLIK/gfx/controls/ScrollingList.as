dynamic class gfx.controls.ScrollingList extends gfx.controls.CoreList
{
	var wrapping: String = "normal";
	var autoRowCount: Boolean = false;
	var _scrollPosition: Number = 0;
	var totalRenderers: Number = 0;
	var autoScrollBar: Boolean = false;
	var margin: Number = 1;
	var paddingTop: Number = 0;
	var paddingBottom: Number = 0;
	var paddingLeft: Number = 0;
	var paddingRight: Number = 0;
	var thumbOffsetTop: Number = 0;
	var thumbOffsetBottom: Number = 0;
	var thumbSizeFactor: Number = 1;
	var __height;
	var __width;
	var _dataProvider;
	var _disabled;
	var _focused;
	var _height;
	var _name;
	var _parent;
	var _rowHeight;
	var _scrollBar;
	var _selectedIndex;
	var _width;
	var _xscale;
	var _yscale;
	var container;
	var createItemRenderer;
	var drawRenderers;
	var externalRenderers;
	var focusEnabled;
	var gotoAndPlay;
	var initialized;
	var inspectableScrollBar;
	var invalidate;
	var itemToLabel;
	var renderers;
	var sizeIsInvalid;
	var tabEnabled;

	function ScrollingList()
	{
		super();
	}

	function get scrollBar()
	{
		return this._scrollBar;
	}

	function set scrollBar(value)
	{
		if (!this.initialized) 
		{
			this.inspectableScrollBar = value;
			return;
		}
		if (this._scrollBar != null) 
		{
			this._scrollBar.removeEventListener("scroll", this, "handleScroll");
			this._scrollBar.removeEventListener("change", this, "handleScroll");
			this._scrollBar.focusTarget = null;
			if (this.autoScrollBar) 
			{
				this._scrollBar.removeMovieClip();
			}
		}
		this.autoScrollBar = false;
		if (typeof value == "string") 
		{
			this._scrollBar = MovieClip(this._parent[value.toString()]);
			if (this._scrollBar == null) 
			{
				this._scrollBar = this.container.attachMovie(value.toString(), "_scrollBar", 1000, {offsetTop: this.thumbOffsetTop, offsetBottom: this.thumbOffsetBottom});
				if (this._scrollBar != null) 
				{
					this.autoScrollBar = true;
				}
			}
		}
		else 
		{
			this._scrollBar = MovieClip(value);
		}
		this.invalidate();
		if (this._scrollBar != null) 
		{
			if (this._scrollBar.setScrollProperties == null) 
			{
				this._scrollBar.addEventListener("change", this, "handleScroll");
			}
			else 
			{
				this._scrollBar.addEventListener("scroll", this, "handleScroll");
			}
			this._scrollBar.focusTarget = this;
			this._scrollBar.tabEnabled = false;
			this.updateScrollBar();
			return;
		}
	}

	function get rowHeight()
	{
		return this._rowHeight;
	}

	function set rowHeight(value)
	{
		if (value == 0) 
		{
			value = null;
		}
		this._rowHeight = value;
		this.invalidate();
	}

	function get scrollPosition()
	{
		return this._scrollPosition;
	}

	function set scrollPosition(value)
	{
		value = Math.max(0, Math.min(this._dataProvider.length - this.totalRenderers, Math.round(value)));
		if (this._scrollPosition != value) 
		{
			this._scrollPosition = value;
			this.invalidateData();
			this.updateScrollBar();
			return;
		}
	}

	function get selectedIndex()
	{
		return this._selectedIndex;
	}

	function set selectedIndex(value)
	{
		if (value != this._selectedIndex) 
		{
			var __reg3 = this.getRendererAt(this._selectedIndex);
			if (__reg3 != null) 
			{
				__reg3.selected = false;
			}
			super.selectedIndex = value;
			if (this.totalRenderers != 0) 
			{
				__reg3 = this.getRendererAt(this._selectedIndex);
				if (__reg3 == null) 
				{
					this.scrollToIndex(this._selectedIndex);
					this.getRendererAt(this._selectedIndex).displayFocus = true;
				}
				else 
				{
					__reg3.selected = true;
				}
				return;
			}
		}
	}

	function get disabled()
	{
		return this._disabled;
	}

	function set disabled(value)
	{
		super.disabled = value;
		if (this.initialized) 
		{
			this.setState();
		}
	}

	function scrollToIndex(index)
	{
		if (this.totalRenderers != 0) 
		{
			if (index >= this._scrollPosition && index < this._scrollPosition + this.totalRenderers) 
			{
				return undefined;
			}
			if (index < this._scrollPosition) 
			{
				this.scrollPosition = index;
				return;
			}
			this.scrollPosition = index - (this.totalRenderers - 1);
		}
	}

	function get rowCount()
	{
		return this.totalRenderers;
	}

	function set rowCount(value)
	{
		var __reg3 = this._rowHeight;
		if (__reg3 == null) 
		{
			var __reg2 = this.renderers[0];
			if (__reg2 == null) 
			{
				__reg2 = this.createItemRenderer(0);
				if (__reg2 == null) 
				{
					return;
				}
				__reg3 = __reg2._height;
				__reg2.removeMovieClip();
			}
			else 
			{
				__reg3 = __reg2.height;
			}
			if (__reg3 == null || __reg3 == 0) 
			{
				return;
			}
		}
		this.height = __reg3 * value + this.margin * 2 + this.paddingTop + this.paddingBottom;
	}

	function invalidateData()
	{
		this._scrollPosition = Math.min(Math.max(0, this._dataProvider.length - this.totalRenderers), this._scrollPosition);
		this.selectedIndex = Math.min(this._dataProvider.length - 1, this._selectedIndex);
		this._dataProvider.requestItemRange(this._scrollPosition, Math.min(this._dataProvider.length - 1, this._scrollPosition + this.totalRenderers - 1), this, "populateData");
	}

	function handleInput(details, pathToFocus)
	{
		if (pathToFocus == null) 
		{
			pathToFocus = [];
		}
		var __reg3 = this.getRendererAt(this._selectedIndex);
		if (__reg3 != null && __reg3.handleInput != null) 
		{
			var __reg6 = __reg3.handleInput(details, pathToFocus.slice(1));
			if (__reg6) 
			{
				return true;
			}
		}
		var __reg2 = details.value == "keyDown" || details.value == "keyHold";
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.UP) 
		{
			if (this._selectedIndex > 0) 
			{
				if (__reg2) 
				{
					this.selectedIndex = (this.selectedIndex - 1);
				}
				return true;
			}
			else if (this.wrapping == "stick") 
			{
				return true;
			}
			else if (this.wrapping == "wrap") 
			{
				if (__reg2) 
				{
					this.selectedIndex = this._dataProvider.length - 1;
				}
				return true;
			}
			else 
			{
				return false;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.DOWN) 
		{
			if (this._selectedIndex < this._dataProvider.length - 1) 
			{
				if (__reg2) 
				{
					this.selectedIndex = (this.selectedIndex + 1);
				}
				return true;
			}
			else if (this.wrapping == "stick") 
			{
				return true;
			}
			else if (this.wrapping == "wrap") 
			{
				if (__reg2) 
				{
					this.selectedIndex = 0;
				}
				return true;
			}
			else 
			{
				return false;
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.END) 
		{
			if (!__reg2) 
			{
				this.selectedIndex = this._dataProvider.length - 1;
			}
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.HOME) 
		{
			if (!__reg2) 
			{
				this.selectedIndex = 0;
			}
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.PAGE_UP) 
		{
			if (__reg2) 
			{
				this.selectedIndex = Math.max(0, this._selectedIndex - this.totalRenderers);
			}
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.PAGE_DOWN) 
		{
			if (__reg2) 
			{
				this.selectedIndex = Math.min(this._dataProvider.length - 1, this._selectedIndex + this.totalRenderers);
			}
			return true;
		}
		return false;
	}

	function get availableWidth()
	{
		return this.autoScrollBar ? this.__width - this._scrollBar._width : this.__width;
	}

	function toString()
	{
		return "[Scaleform ScrollingList " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		if (this.inspectableScrollBar != "" && this.inspectableScrollBar != null) 
		{
			this.scrollBar = this.inspectableScrollBar;
			this.inspectableScrollBar = null;
		}
	}

	function draw()
	{
		if (this.sizeIsInvalid) 
		{
			this._width = this.__width;
			this._height = this.__height;
		}
		if (this.externalRenderers) 
		{
			this.totalRenderers = this.renderers.length;
		}
		else 
		{
			this.container._xscale = 10000 / this._xscale;
			this.container._yscale = 10000 / this._yscale;
			var __reg3 = this._rowHeight;
			if (__reg3 == null) 
			{
				var __reg4 = this.createItemRenderer(99);
				__reg4.enableInitCallback = false;
				__reg3 = __reg4._height;
				__reg4.removeMovieClip();
			}
			var __reg5 = this.margin * 2 + this.paddingTop + this.paddingBottom;
			this.totalRenderers = Math.max(0, (this.__height - __reg5 + 0.05) / __reg3 >> 0);
			this.drawRenderers(this.totalRenderers);
			this.drawLayout(this.availableWidth, __reg3);
		}
		this.updateScrollBar();
		this.invalidateData();
		this.setState();
		super.draw();
	}

	function drawLayout(rendererWidth, rendererHeight)
	{
		var __reg5 = this.paddingLeft + this.paddingRight + this.margin * 2;
		rendererWidth = rendererWidth - __reg5;
		var __reg2 = 0;
		while (__reg2 < this.renderers.length) 
		{
			this.renderers[__reg2]._x = this.margin + this.paddingLeft;
			this.renderers[__reg2]._y = __reg2 * rendererHeight + this.margin + this.paddingTop;
			this.renderers[__reg2].setSize(rendererWidth, rendererHeight);
			++__reg2;
		}
		this.drawScrollBar();
	}

	function drawScrollBar()
	{
		if (this.autoScrollBar) 
		{
			this._scrollBar._x = this.__width - this._scrollBar._width - this.margin;
			this._scrollBar._y = this.margin;
			this._scrollBar.height = this.__height - this.margin * 2;
		}
	}

	function changeFocus()
	{
		super.changeFocus();
		this.setState();
		var __reg3 = this.getRendererAt(this._selectedIndex);
		if (__reg3 != null) 
		{
			__reg3.displayFocus = this._focused;
		}
	}

	function populateData(data)
	{
		var __reg2 = 0;
		while (__reg2 < this.renderers.length) 
		{
			var __reg4 = this.renderers[__reg2];
			var __reg3 = this._scrollPosition + __reg2;
			this.renderers[__reg2].setListData(__reg3, this.itemToLabel(data[__reg2]), this._selectedIndex == __reg3);
			__reg4.setData(data[__reg2]);
			++__reg2;
		}
		this.updateScrollBar();
	}

	function handleScroll(event)
	{
		var __reg2 = event.target.position;
		if (isNaN(__reg2)) 
		{
			return undefined;
		}
		this.scrollPosition = __reg2;
	}

	function updateScrollBar()
	{
		var __reg2 = Math.max(0, this.dataProvider.length - this.totalRenderers);
		if (this._scrollBar.setScrollProperties == null) 
		{
			this._scrollBar.minimum = 0;
			this._scrollBar.maximum = __reg2;
		}
		else 
		{
			this._scrollBar.setScrollProperties(this.totalRenderers * this.thumbSizeFactor, 0, __reg2);
		}
		this._scrollBar.position = this._scrollPosition;
		this._scrollBar.trackScrollPageSize = Math.max(1, this.totalRenderers);
	}

	function getRendererAt(index)
	{
		return this.renderers[index - this._scrollPosition];
	}

	function scrollWheel(delta)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		var __reg2 = this._scrollBar != undefined && this._scrollBar.pageScrollSize != undefined ? this._scrollBar.pageScrollSize : 1;
		// Version 1.9.26 uses, which seems less safe
		// var __reg2 = this._scrollBar == undefined ? 1 : this._scrollBar.pageScrollSize;
		this.scrollPosition = this._scrollPosition - delta * __reg2;
	}

	function setState()
	{
		this.tabEnabled = this.focusEnabled = !this._disabled;
		this.gotoAndPlay(this._disabled ? "disabled" : (this._focused ? "focused" : "default"));
		if (this._scrollBar) 
		{
			this._scrollBar.disabled = this._disabled;
			this._scrollBar.tabEnabled = false;
		}
		var __reg2 = 0;
		for (;;) 
		{
			if (__reg2 >= this.renderers.length) 
			{
				return;
			}
			this.renderers[__reg2].disabled = this._disabled;
			this.renderers[__reg2].tabEnabled = false;
			++__reg2;
		}
	}

}
