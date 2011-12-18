dynamic class gfx.controls.TextArea extends gfx.controls.TextInput
{
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", textChange: "textChange", scroll: "scroll"};
	var _scrollPolicy: String = "auto";
	var _position: Number = 1;
	var maxscroll: Number = 1;
	var autoScrollBar: Boolean = false;
	var resetScrollPosition: Boolean = false;
	var __height;
	var __width;
	var _disabled;
	var _editable;
	var _name;
	var _parent;
	var _scrollBar;
	var _xscale;
	var _yscale;
	var changeLock;
	var constraints;
	var container;
	var createEmptyMovieClip;
	var dispatchEventAndSound;
	var initialized;
	var inspectableScrollBar;
	var textField;

	function TextArea()
	{
		super();
	}

	function get position()
	{
		return this._position;
	}

	function set position(value)
	{
		this._position = value;
		this.textField.scroll = this._position;
	}

	function get scrollPolicy()
	{
		return this._scrollPolicy;
	}

	function set scrollPolicy(value)
	{
		this._scrollPolicy = value;
		this.updateScrollBar();
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
		if (this._scrollBar != value) 
		{
			if (this._scrollBar != null) 
			{
				this._scrollBar.scrollTarget = null;
				this._scrollBar.focusTarget = null;
				this._scrollBar.removeEventListener("scroll", this, "handleScroll");
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
					this._scrollBar = this.container.attachMovie(value.toString(), "_scrollBar", 1000, {_visible: false});
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
			if (this._scrollBar != null) 
			{
				this._scrollBar.focusTarget = this;
				this._scrollBar.scrollTarget = this.textField;
				this.maxscroll = this.textField.maxscroll;
				this.updateScrollBar();
				this.changeLock = true;
				this.onChanged();
				this.changeLock = false;
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
		this.updateScrollBar();
	}

	function toString()
	{
		return "[Scaleform TextArea " + this._name + "]";
	}

	function handleInput(details, pathToFocus)
	{
		if (details.value != "keyDown" && details.value != "keyHold") 
		{
			return false;
		}
		var __reg2 = details.controllerIdx;
		if (Selection.getFocus(__reg2) == null) 
		{
			Selection.setFocus(this.textField, __reg2);
			return true;
		}
		if (this._editable) 
		{
			return false;
		}
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.UP) 
		{
			if (this.position == 1) 
			{
				return false;
			}
			this.position = Math.max(1, this.position - 1);
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.DOWN) 
		{
			if (this.position == this.maxscroll) 
			{
				return false;
			}
			this.position = Math.min(this.maxscroll, this.position + 1);
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.END) 
		{
			this.position = this.maxscroll;
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.HOME) 
		{
			this.position = 1;
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.PAGE_UP) 
		{
			var __reg4 = this.textField.bottomScroll - this.textField.scroll;
			this.position = Math.max(1, this.position - __reg4);
			return true;
		}
		else if (__reg0 === gfx.ui.NavigationCode.PAGE_DOWN) 
		{
			__reg4 = this.textField.bottomScroll - this.textField.scroll;
			this.position = Math.min(this.maxscroll, this.position + __reg4);
			return true;
		}
		return false;
	}

	function configUI()
	{
		super.configUI();
		Mouse.addListener(this);
		this.container = this.createEmptyMovieClip("container", 1);
		this.container.scale9Grid = new flash.geom.Rectangle(20, 20, 1, 1);
		if (this.inspectableScrollBar != "") 
		{
			this.scrollBar = this.inspectableScrollBar;
			this.inspectableScrollBar = null;
		}
	}

	function draw()
	{
		super.draw();
		this.container._xscale = 10000 / this._xscale;
		this.container._yscale = 10000 / this._yscale;
		if (this.autoScrollBar) 
		{
			this._scrollBar._x = this.__width - this._scrollBar._width;
			this._scrollBar.height = this.__height - 1;
		}
	}

	function updateText()
	{
		super.updateText();
		this.updateScrollBar();
	}

	function updateTextField()
	{
		this.resetScrollPosition = true;
		super.updateTextField();
		if (this.textField != null) 
		{
			if (this._scrollBar != null) 
			{
				this._scrollBar.scrollTarget = this.textField;
			}
		}
	}

	function updateScrollBar()
	{
		this.maxscroll = this.textField.maxscroll;
		if (this._scrollBar != undefined) 
		{
			var __reg2 = this.constraints.getElement(this.textField);
			if (this._scrollPolicy == "on" || (this._scrollPolicy == "auto" && this.textField.maxscroll > 1)) 
			{
				if (this.autoScrollBar && !this._scrollBar.visible) 
				{
					if (__reg2 != null) 
					{
						__reg2.metrics.right = __reg2.metrics.right + this._scrollBar._width;
						this.constraints.update(this.__width, this.__height);
					}
					this.maxscroll = this.textField.maxscroll;
				}
				this._scrollBar.visible = true;
			}
			if (this._scrollPolicy == "off" || (this._scrollPolicy == "auto" && this.textField.maxscroll == 1)) 
			{
				if (this.autoScrollBar && this._scrollBar.visible) 
				{
					if (__reg2 != null) 
					{
						__reg2.metrics.right = __reg2.metrics.right - this._scrollBar._width;
						this.constraints.update(this.__width, this.__height);
					}
				}
				this._scrollBar.visible = false;
			}
			if (this._scrollBar.disabled != this._disabled) 
			{
				this._scrollBar.disabled = this._disabled;
			}
		}
	}

	function onChanged(target)
	{
		if (this.maxscroll != this.textField.maxscroll) 
		{
			this.updateScrollBar();
		}
		super.onChanged(target);
	}

	function onScroller()
	{
		if (this.resetScrollPosition) 
		{
			this.textField.scroll = this._position;
		}
		else 
		{
			this._position = this.textField.scroll;
		}
		this.resetScrollPosition = false;
		this.dispatchEventAndSound({type: "scroll"});
	}

	function scrollWheel(delta)
	{
		this.position = Math.max(1, Math.min(this.maxscroll, this._position - delta));
	}

}
