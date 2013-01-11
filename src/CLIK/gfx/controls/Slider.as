dynamic class gfx.controls.Slider extends gfx.core.UIComponent
{
	var liveDragging: Boolean = false;
	var state: String = "default";
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", change: "change"};
	var _minimum: Number = 0;
	var _maximum: Number = 10;
	var _value: Number = 0;
	var _snapInterval: Number = 1;
	var _snapping: Boolean = false;
	var trackPressed: Boolean = false;
	var thumbPressed: Boolean = false;
	var offsetLeft: Number = 0;
	var offsetRight: Number = 0;
	var __height;
	var __width;
	var _disabled;
	var _focused;
	var _name;
	var _xmouse;
	var constraints;
	var dispatchEventAndSound;
	var dragOffset;
	var focusEnabled;
	var gotoAndPlay;
	var initSize;
	var initialized;
	var invalidate;
	var onMouseMove;
	var onMouseUp;
	var tabChildren;
	var tabEnabled;
	var thumb;
	var track;
	var trackDragMouseIndex;

	function Slider()
	{
		super();
		this.tabChildren = false;
		this.focusEnabled = this.tabEnabled = !this._disabled;
	}

	function get maximum()
	{
		return this._maximum;
	}

	function set maximum(value)
	{
		this._maximum = value;
		this.invalidate();
	}

	function get minimum()
	{
		return this._minimum;
	}

	function set minimum(value)
	{
		this._minimum = value;
		this.invalidate();
	}

	function get value()
	{
		return this._value;
	}

	function set value(value)
	{
		this._value = this.lockValue(value);
		this.invalidate();
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
			if (this.initialized) 
			{
				this.thumb.disabled = this.track.disabled = this._disabled;
				this.invalidate();
				return;
			}
		}
	}

	function get position()
	{
		return this._value;
	}

	function set position(value)
	{
		this.value = value;
	}

	function get snapping()
	{
		return this._snapping;
	}

	function set snapping(value)
	{
		this._snapping = value;
		this.invalidate();
	}

	function get snapInterval()
	{
		return this._snapInterval;
	}

	function set snapInterval(value)
	{
		this._snapInterval = value;
		this.invalidate();
	}

	function handleInput(details, pathToFocus)
	{
		var __reg2 = details.value == "keyDown" || details.value == "keyHold";
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.RIGHT) 
		{
			if (__reg2) 
			{
				this.value = this.value + this._snapInterval;
				this.dispatchEventAndSound({type: "change"});
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.LEFT) 
		{
			if (__reg2) 
			{
				this.value = this.value - this._snapInterval;
				this.dispatchEventAndSound({type: "change"});
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.HOME) 
		{
			if (!__reg2) 
			{
				this.value = this.minimum;
				this.dispatchEventAndSound({type: "change"});
			}
		}
		else if (__reg0 === gfx.ui.NavigationCode.END) 
		{
			if (!__reg2) 
			{
				this.value = this.maximum;
				this.dispatchEventAndSound({type: "change"});
			}
		}
		else 
		{
			return false;
		}
		return true;
	}

	function toString()
	{
		return "[Scaleform Slider " + this._name + "]";
	}

	function configUI()
	{
		this.thumb.addEventListener("press", this, "beginDrag");
		this.track.addEventListener("press", this, "trackPress");
		this.thumb.focusTarget = this.track.focusTarget = this;
		this.thumb.disabled = this.track.disabled = this._disabled;
		this.thumb.lockDragStateChange = true;
		this.initSize();
		this.constraints = new gfx.utils.Constraints(this);
		this.constraints.addElement(this.track, gfx.utils.Constraints.LEFT | gfx.utils.Constraints.RIGHT);
		Mouse.addListener(this);
	}

	function draw()
	{
		this.gotoAndPlay(this._disabled ? "disabled" : (this._focused ? "focused" : "default"));
		if (!this._disabled) 
		{
			if (!this.thumbPressed) 
			{
				this.thumb.displayFocus = this._focused != 0;
			}
			if (!this.trackPressed) 
			{
				this.track.displayFocus = this._focused != 0;
			}
		}
		this.constraints.update(this.__width, this.__height);
		this.updateThumb();
	}

	function changeFocus()
	{
		this.invalidate();
	}

	function updateThumb()
	{
		if (this._disabled) 
		{
			return undefined;
		}
		var __reg2 = this.__width - this.offsetLeft - this.offsetRight;
		this.thumb._x = (this._value - this._minimum) / (this._maximum - this._minimum) * __reg2 - this.thumb._width / 2 + this.offsetLeft;
	}

	function beginDrag(event)
	{
		this.thumbPressed = true;
		Selection.setFocus(this.thumb, event.controllerIdx);
		this.dragOffset = {x: this._xmouse - this.thumb._x - this.thumb._width / 2};
		this.onMouseMove = this.doDrag;
		this.onMouseUp = this.endDrag;
	}

	function doDrag()
	{
		var __reg3 = this._xmouse - this.dragOffset.x;
		var __reg4 = this.__width - this.offsetLeft - this.offsetRight;
		var __reg2 = this.lockValue((__reg3 - this.offsetLeft) / __reg4 * (this._maximum - this._minimum) + this._minimum);
		this.updateThumb();
		if (this.value != __reg2) 
		{
			this._value = __reg2;
			if (this.liveDragging) 
			{
				this.dispatchEventAndSound({type: "change"});
			}
		}
	}

	function endDrag()
	{
		delete this.onMouseUp;
		delete this.onMouseMove;
		if (!this.liveDragging) 
		{
			this.dispatchEventAndSound({type: "change"});
		}
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
		this.thumbPressed = false;
		this.trackPressed = false;
		this.invalidate();
	}

	function trackPress(e)
	{
		this.trackPressed = true;
		Selection.setFocus(this.track, e.controllerIdx);
		var __reg3 = this.__width - this.offsetLeft - this.offsetRight;
		var __reg2 = this.lockValue((this._xmouse - this.offsetLeft) / __reg3 * (this._maximum - this._minimum) + this._minimum);
		if (this.value != __reg2) 
		{
			this.value = __reg2;
			if (this.liveDragging) 
			{
				this.dispatchEventAndSound({type: "change"});
			}
			this.trackDragMouseIndex = e.controllerIdx;
			this.thumb.onPress(this.trackDragMouseIndex);
			this.dragOffset = {x: 0};
		}
	}

	function lockValue(value)
	{
		value = Math.max(this._minimum, Math.min(this._maximum, value));
		if (!this.snapping) 
		{
			return value;
		}
		return Math.round(value / this.snapInterval) * this.snapInterval;
	}

	function scrollWheel(delta)
	{
		if (this._focused) 
		{
			this.value = this.value - delta * this._snapInterval;
			this.dispatchEventAndSound({type: "change"});
		}
	}

}
