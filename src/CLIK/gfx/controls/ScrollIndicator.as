dynamic class gfx.controls.ScrollIndicator extends gfx.core.UIComponent
{
	var direction: String = "vertical";
	var soundMap = {theme: "default", scroll: "scroll"};
	var pageScrollSize: Number = 1;
	var minPosition: Number = 0;
	var maxPosition: Number = 10;
	var _position: Number = 5;
	var offsetTop: Number = 0;
	var offsetBottom: Number = 0;
	var isDragging: Boolean = false;
	var __height;
	var __width;
	var _disabled;
	var _name;
	var _parent;
	var _rotation;
	var _scrollTarget;
	var dispatchEventAndSound;
	var focusEnabled;
	var focusTarget;
	var initSize;
	var initialized;
	var inspectableScrollTarget;
	var invalidate;
	var lastVScrollPos;
	var onRelease;
	var pageSize;
	var scrollerIntervalID;
	var tabChildren;
	var tabEnabled;
	var thumb;
	var track;
	var useHandCursor;

	function ScrollIndicator()
	{
		super();
		this.tabChildren = false;
		this.focusEnabled = this.tabEnabled = !this._disabled;
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
			if (this._scrollTarget) 
			{
				this.tabEnabled = false;
			}
			if (this.initialized) 
			{
				this.thumb.disabled = this._disabled;
			}
			return;
		}
	}

	function setScrollProperties(pageSize, minPosition, maxPosition, pageScrollSize)
	{
		this.pageSize = pageSize;
		if (pageScrollSize != undefined) 
		{
			this.pageScrollSize = pageScrollSize;
		}
		this.minPosition = minPosition;
		this.maxPosition = maxPosition;
		this.updateThumb();
	}

	function get position()
	{
		return this._position;
	}

	function set position(value)
	{
		if (value != this._position) 
		{
			this._position = Math.max(this.minPosition, Math.min(this.maxPosition, value));
			this.dispatchEventAndSound({type: "scroll", position: this._position});
			this.invalidate();
			return;
		}
	}

	function update()
	{
	}

	function get scrollTarget()
	{
		return this._scrollTarget;
	}

	function set scrollTarget(value)
	{
		var __reg2 = this._scrollTarget;
		this._scrollTarget = value;
		if (__reg2 && value._parent != __reg2) 
		{
			__reg2.removeListener(this);
			if (__reg2.scrollBar != null) 
			{
				__reg2.scrollBar = null;
			}
			this.focusTarget = null;
			__reg2.noAutoSelection = false;
		}
		if (value instanceof gfx.core.UIComponent && value.scrollBar !== null) 
		{
			value.scrollBar = this;
			return;
		}
		if (this._scrollTarget == null) 
		{
			this.tabEnabled = true;
			return;
		}
		this._scrollTarget.addListener(this);
		this._scrollTarget.noAutoSelection = true;
		this.focusTarget = this._scrollTarget;
		this.tabEnabled = false;
		this.onScroller();
	}

	function get availableHeight()
	{
		return (this.direction == "horizontal" ? this.__width : this.__height) - this.thumb.height + this.offsetBottom + this.offsetTop;
	}

	function toString()
	{
		return "[Scaleform ScrollIndicator " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		if (this.track == null) 
		{
			this.track = new gfx.controls.Button();
		}
		this.thumb.focusTarget = this;
		this.track.focusTarget = this;
		this.thumb.disabled = this._disabled;
		this.onRelease = function ()
		{
		}
		;
		this.useHandCursor = false;
		this.initSize();
		this.direction = this._rotation == 0 ? "vertical" : "horizontal";
		if (this.inspectableScrollTarget != null) 
		{
			var __reg3 = this._parent[this.inspectableScrollTarget];
			if (__reg3 != null) 
			{
				this.scrollTarget = __reg3;
			}
			this.inspectableScrollTarget = null;
		}
	}

	function draw()
	{
		this.track._height = this.direction == "horizontal" ? this.__width : this.__height;
		if (this._scrollTarget instanceof TextField) 
		{
			this.setScrollProperties(this._scrollTarget.bottomScroll - this._scrollTarget.scroll, 1, this._scrollTarget.maxscroll);
			return;
		}
		this.updateThumb();
	}

	function updateThumb()
	{
		if (!this.thumb.initialized) 
		{
			this.invalidate();
			return undefined;
		}
		if (this._disabled) 
		{
			return undefined;
		}
		var __reg5 = Math.max(1, this.maxPosition - this.minPosition + this.pageSize);
		var __reg4 = (this.direction == "horizontal" ? this.__width : this.__height) + this.offsetTop + this.offsetBottom;
		this.thumb.height = Math.max(10, this.pageSize / __reg5 * __reg4);
		var __reg2 = (this.position - this.minPosition) / (this.maxPosition - this.minPosition);
		var __reg3 = 0 - this.offsetTop;
		var __reg6 = __reg2 * this.availableHeight + __reg3;
		this.thumb._y = Math.max(__reg3, Math.min(__reg4 - this.offsetTop, __reg6));
		this.thumb.visible = !(isNaN(__reg2) || this.maxPosition == 0);
	}

	function onScroller()
	{
		if (this.isDragging) 
		{
			return undefined;
		}
		if (this.lastVScrollPos == this._scrollTarget.scroll) 
		{
			delete this.lastVScrollPos;
			return undefined;
		}
		this.setScrollProperties(this._scrollTarget.bottomScroll - this._scrollTarget.scroll, 1, this._scrollTarget.maxscroll);
		this.position = this._scrollTarget.scroll;
		this.lastVScrollPos = this._scrollTarget.scroll;
		if (this.scrollerIntervalID == undefined) 
		{
			this.scrollerIntervalID = setInterval(this, "scrollerDelayUpdate", 10);
		}
	}

	function scrollerDelayUpdate()
	{
		this.onScroller();
		clearInterval(this.scrollerIntervalID);
		delete this.scrollerIntervalID;
	}

}
