dynamic class gfx.controls.ScrollBar extends gfx.controls.ScrollIndicator
{
	var trackScrollPageSize: Number = 1;
	var _trackMode: String = "scrollPage";
	var trackScrollPosition: Number = -1;
	var __height;
	var __width;
	var _disabled;
	var _name;
	var _position;
	var _rotation;
	var _scrollTarget;
	var _ymouse;
	var constraints;
	var direction;
	var downArrow;
	var dragOffset;
	var gotoAndPlay;
	var initialized;
	var invalidate;
	var isDragging;
	var maxPosition;
	var minPosition;
	var offsetBottom;
	var offsetTop;
	var onMouseMove;
	var onMouseUp;
	var onRelease;
	var pageScrollSize;
	var pageSize;
	var setScrollProperties;
	var thumb;
	var track;
	var trackDragMouseIndex;
	var upArrow;

	function ScrollBar()
	{
		super();
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
			this.gotoAndPlay(this._disabled ? "disabled" : "default");
			if (this.initialized) 
			{
				this.upArrow.disabled = this._disabled;
				this.downArrow.disabled = this._disabled;
				this.track.disabled = this._disabled;
			}
			return;
		}
	}

	function get position()
	{
		return super.position;
	}

	function set position(value)
	{
		value = Math.round(value);
		if (value != this.position) 
		{
			super.position = value;
			this.updateScrollTarget();
			return;
		}
	}

	function get trackMode()
	{
		return this._trackMode;
	}

	function set trackMode(value)
	{
		if (value != this._trackMode) 
		{
			this._trackMode = value;
			if (this.initialized) 
			{
				this.track.autoRepeat = this.trackMode == "scrollPage";
			}
			return;
		}
	}

	function get availableHeight()
	{
		return this.track.height - this.thumb.height + this.offsetBottom + this.offsetTop;
	}

	function toString()
	{
		return "[Scaleform ScrollBar " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		delete this.onRelease;
		if (this.upArrow) 
		{
			this.upArrow.addEventListener("click", this, "scrollUp");
			this.upArrow.useHandCursor = !this._disabled;
			this.upArrow.disabled = this._disabled;
			this.upArrow.focusTarget = this;
			this.upArrow.autoRepeat = true;
		}
		if (this.downArrow) 
		{
			this.downArrow.addEventListener("click", this, "scrollDown");
			this.downArrow.useHandCursor = !this._disabled;
			this.downArrow.disabled = this._disabled;
			this.downArrow.focusTarget = this;
			this.downArrow.autoRepeat = true;
		}
		this.thumb.addEventListener("press", this, "beginDrag");
		this.thumb.useHandCursor = !this._disabled;
		this.thumb.lockDragStateChange = true;
		this.track.addEventListener("press", this, "beginTrackScroll");
		this.track.addEventListener("click", this, "trackScroll");
		this.track.disabled = this._disabled;
		this.track.autoRepeat = this.trackMode == "scrollPage";
		Mouse.addListener(this);
		var __reg3 = this._rotation;
		this._rotation = 0;
		this.constraints = new gfx.utils.Constraints(this);
		if (this.downArrow) 
		{
			this.constraints.addElement(this.downArrow, gfx.utils.Constraints.BOTTOM);
		}
		this.constraints.addElement(this.track, gfx.utils.Constraints.TOP | gfx.utils.Constraints.BOTTOM);
		this._rotation = __reg3;
	}

	function draw()
	{
		if (this.direction == "horizontal") 
		{
			this.constraints.update(this.__height, this.__width);
		}
		else 
		{
			this.constraints.update(this.__width, this.__height);
		}
		if (this._scrollTarget instanceof TextField) 
		{
			this.setScrollProperties(this._scrollTarget.bottomScroll - this._scrollTarget.scroll, 1, this._scrollTarget.maxscroll);
			return;
		}
		this.updateThumb();
	}

	function updateThumb()
	{
		if (!this.initialized) 
		{
			this.invalidate();
			return undefined;
		}
		if (this._disabled) 
		{
			return undefined;
		}
		var __reg5 = Math.max(1, this.maxPosition - this.minPosition + this.pageSize);
		var __reg4 = this.track.height + this.offsetTop + this.offsetBottom;
		var __reg6 = __reg4;
		this.thumb.height = Math.max(10, Math.min(__reg4, this.pageSize / __reg5 * __reg6));
		var __reg2 = (this._position - this.minPosition) / (this.maxPosition - this.minPosition);
		var __reg3 = this.track._y - this.offsetTop;
		var __reg7 = __reg2 * this.availableHeight + __reg3;
		this.thumb._y = Math.max(__reg3, Math.min(this.track._y + this.track.height - this.thumb.height + this.offsetBottom, __reg7));
		this.thumb.visible = !(isNaN(__reg2) || this.maxPosition <= 0 || this.maxPosition == Infinity);
		if (this.thumb.visible) 
		{
			this.track.disabled = false;
			if (this.upArrow) 
			{
				if (this._position == this.minPosition) 
				{
					this.upArrow.disabled = true;
				}
				else 
				{
					this.upArrow.disabled = false;
				}
			}
			if (this.downArrow) 
			{
				if (this._position == this.maxPosition) 
				{
					this.downArrow.disabled = true;
				}
				else 
				{
					this.downArrow.disabled = false;
				}
			}
			return;
		}
		if (this.upArrow) 
		{
			this.upArrow.disabled = true;
		}
		if (this.downArrow) 
		{
			this.downArrow.disabled = true;
		}
		this.track.disabled = true;
	}

	function scrollUp()
	{
		this.position = this.position - this.pageScrollSize;
	}

	function scrollDown()
	{
		this.position = this.position + this.pageScrollSize;
	}

	function beginDrag()
	{
		if (this.isDragging != true) 
		{
			this.isDragging = true;
			this.onMouseMove = this.doDrag;
			this.onMouseUp = this.endDrag;
			this.dragOffset = {y: this._ymouse - this.thumb._y};
		}
	}

	function doDrag()
	{
		var __reg2 = (this._ymouse - this.dragOffset.y - this.track._y) / this.availableHeight;
		this.position = this.minPosition + __reg2 * (this.maxPosition - this.minPosition);
	}

	function endDrag()
	{
		delete this.onMouseUp;
		delete this.onMouseMove;
		this.isDragging = false;
		if (this.trackDragMouseIndex != undefined) 
		{
			if (this.thumb.hitTest(_root._xmouse, _root._ymouse)) 
			{
				this.thumb.onRelease(this.trackDragMouseIndex);
			}
			else 
			{
				this.thumb.onReleaseOutside(this.trackDragMouseIndex);
			}
		}
		delete this.trackDragMouseIndex;
	}

	function beginTrackScroll(e)
	{
		var __reg2 = (this._ymouse - this.thumb.height / 2 - this.track._y) / this.availableHeight;
		this.trackScrollPosition = Math.round(__reg2 * (this.maxPosition - this.minPosition) + this.minPosition);
		if (Key.isDown(16) || this.trackMode == "scrollToCursor") 
		{
			this.position = this.trackScrollPosition;
			this.trackDragMouseIndex = e.controllerIdx;
			this.thumb.onPress(this.trackDragMouseIndex);
			this.dragOffset = {y: this.thumb.height / 2};
		}
	}

	function trackScroll()
	{
		if (this.isDragging || this.position == this.trackScrollPosition) 
		{
			return undefined;
		}
		var __reg3 = this.position >= this.trackScrollPosition ? 0 - this.trackScrollPageSize : this.trackScrollPageSize;
		var __reg2 = this.position + __reg3;
		this.position = __reg3 >= 0 ? Math.min(__reg2, this.trackScrollPosition) : Math.max(__reg2, this.trackScrollPosition);
	}

	function updateScrollTarget()
	{
		if (this._scrollTarget != null) 
		{
			if (this._scrollTarget && !this._disabled) 
			{
				this._scrollTarget.scroll = this._position;
			}
		}
	}

	function scrollWheel(delta)
	{
		this.position = this.position - delta * this.pageScrollSize;
	}

}
