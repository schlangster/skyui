dynamic class gfx.core.UIComponent extends MovieClip
{
	var initialized: Boolean = false;
	var enableInitCallback: Boolean = true;
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut"};
	var __width: Number = Number.NaN;
	var __height: Number = Number.NaN;
	var _disabled: Boolean = false;
	var _focused: Number = 0;
	var _displayFocus: Boolean = false;
	var sizeIsInvalid: Boolean = false;
	var _height;
	var _name;
	var _visible;
	var _width;
	var _xscale;
	var _yscale;
	var dispatchEvent;
	var hitTest;
	var invalidationIntervalID;
	var useHandCursor;

	function UIComponent()
	{
		super();
		gfx.events.EventDispatcher.initialize(this);
	}

	function onLoad()
	{
		this.onLoadImpl();
	}

	function onLoadImpl()
	{
		if (this.initialized) 
		{
			return undefined;
		}
		if (isNaN(this.__width)) 
		{
			this.__width = this._width;
		}
		if (isNaN(this.__height)) 
		{
			this.__height = this._height;
		}
		this.initialized = true;
		this.configUI();
		this.validateNow();
		if (this.enableInitCallback && _global.CLIK_loadCallback) 
		{
			_global.CLIK_loadCallback(this._name, targetPath(this), this);
		}
		if (this._focused != 0 && Selection.getFocusBitmask(this) == 0) 
		{
			var __reg4 = 0;
			for (;;) 
			{
				if (__reg4 >= Selection.numFocusGroups) 
				{
					return;
				}
				var __reg6 = (this._focused >> __reg4 & 1) != 0;
				if (__reg6) 
				{
					var __reg5 = Selection.getControllerMaskByFocusGroup(__reg4);
					var __reg3 = 0;
					while (__reg3 < System.capabilities.numControllers) 
					{
						if (__reg5 >> __reg3 & true) 
						{
							gfx.managers.FocusHandler.instance.onSetFocus(null, this, __reg3);
						}
						++__reg3;
					}
				}
				++__reg4;
			}
		}
	}

	function onUnload()
	{
		if (this.enableInitCallback && _global.CLIK_unloadCallback) 
		{
			_global.CLIK_unloadCallback(this._name, targetPath(this), this);
		}
	}

	function get disabled()
	{
		return this._disabled;
	}

	function set disabled(value)
	{
		this._disabled = value;
		super.enabled = !value;
		this.useHandCursor = !value;
		this.invalidate();
	}

	function get visible()
	{
		return this._visible;
	}

	function set visible(value)
	{
		if (this._visible != value) 
		{
			this._visible = value;
			if (this.initialized) 
			{
				var __reg3 = value ? "show" : "hide";
				this.dispatchEvent({type: __reg3});
				return;
			}
		}
	}

	function get width()
	{
		return this.__width;
	}

	function set width(value)
	{
		this.setSize(value, this.__height || this._height);
	}

	function get height()
	{
		return this.__height;
	}

	function set height(value)
	{
		this.setSize(this.__width || this._width, value);
	}

	function setSize(width, height)
	{
		if (this.__width == width && this.__height == height) 
		{
			return undefined;
		}
		this.__width = width;
		this.__height = height;
		this.sizeIsInvalid = true;
		this.invalidate();
	}

	function get focused()
	{
		return this._focused;
	}

	function set focused(value)
	{
		if (value != this._focused) 
		{
			this._focused = value;
			var __reg3 = 0;
			while (__reg3 < Selection.numFocusGroups) 
			{
				var __reg6 = (this._focused >> __reg3 & 1) != 0;
				if (__reg6) 
				{
					__reg5 = Selection.getControllerMaskByFocusGroup(__reg3);
					__reg2 = 0;
					while (__reg2 < System.capabilities.numControllers) 
					{
						__reg4 = (__reg5 >> __reg2 & 1) != 0;
						if (__reg4 && Selection.getFocus(__reg2) != targetPath(this)) 
						{
							Selection.setFocus(this, __reg2);
						}
						++__reg2;
					}
				}
				else 
				{
					var __reg5 = Selection.getControllerMaskByFocusGroup(__reg3);
					var __reg2 = 0;
					while (__reg2 < System.capabilities.numControllers) 
					{
						var __reg4 = (__reg5 >> __reg2 & 1) != 0;
						if (__reg4 && Selection.getFocus(__reg2) == targetPath(this)) 
						{
							Selection.setFocus(null, __reg2);
						}
						++__reg2;
					}
				}
				++__reg3;
			}
			this.changeFocus();
			var __reg8 = value ? "focusIn" : "focusOut";
			this.dispatchEventAndSound({type: __reg8});
			return;
		}
	}

	function get displayFocus()
	{
		return this._displayFocus;
	}

	function set displayFocus(value)
	{
		if (value != this._displayFocus) 
		{
			this._displayFocus = value;
			this.changeFocus();
			return;
		}
	}

	function handleInput(details, pathToFocus)
	{
		if (pathToFocus && pathToFocus.length > 0) 
		{
			var __reg2 = pathToFocus[0];
			if (__reg2.handleInput) 
			{
				var __reg3 = __reg2.handleInput(details, pathToFocus.slice(1));
				if (__reg3) 
				{
					return __reg3;
				}
			}
		}
		return false;
	}

	function invalidate()
	{
		if (this.invalidationIntervalID) 
		{
			return undefined;
		}
		this.invalidationIntervalID = setInterval(this, "validateNow", 1);
	}

	function validateNow()
	{
		clearInterval(this.invalidationIntervalID);
		delete this.invalidationIntervalID;
		this.draw();
		this.sizeIsInvalid = false;
	}

	function toString()
	{
		return "[Scaleform UIComponent " + this._name + "]";
	}

	function dispatchEventToGame(event)
	{
		flash.external.ExternalInterface.call("__handleEvent", this._name, event);
	}

	function configUI()
	{
	}

	function initSize()
	{
		var __reg3 = this.__width == 0 ? this._width : this.__width;
		var __reg2 = this.__height == 0 ? this._height : this.__height;
		this._xscale = this._yscale = 100;
		this.setSize(__reg3, __reg2);
	}

	function draw()
	{
	}

	function changeFocus()
	{
	}

	function onMouseWheel(delta, target)
	{
		if (this.visible && this.hitTest(_root._xmouse, _root._ymouse, true)) 
		{
			var __reg3 = Mouse.getTopMostEntity();
			for (;;) 
			{
				if (!__reg3) 
				{
					return;
				}
				if (__reg3 == this) 
				{
					this.scrollWheel(delta <= 0 ? -1 : 1);
					return;
				}
				__reg3 = __reg3._parent;
			}
		}
	}

	function scrollWheel(delta)
	{
	}

	function dispatchEventAndSound(event)
	{
		this.dispatchEvent(event);
		this.dispatchSound(event);
	}

	function dispatchSound(event)
	{
		var __reg2 = this.soundMap.theme;
		var __reg3 = this.soundMap[event.type];
		if (__reg2 && __reg3) 
		{
			this.playSound(__reg3, __reg2);
		}
	}

	function playSound(soundEventName, soundTheme)
	{
		if (_global.gfxProcessSound) 
		{
			if (soundTheme == undefined) 
			{
				soundTheme = "default";
			}
			_global.gfxProcessSound(this, soundTheme, soundEventName);
		}
	}

}
