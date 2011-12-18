dynamic class gfx.controls.Button extends gfx.core.UIComponent
{
	var state: String = "up";
	var toggle: Boolean = false;
	var doubleClickEnabled: Boolean = false;
	var autoRepeat: Boolean = false;
	var lockDragStateChange: Boolean = false;
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", select: "select", rollOver: "rollOver", rollOut: "rollOut", press: "press", doubleClick: "doubleClick", click: "click"};
	var _selected: Boolean = false;
	var _autoSize: String = "none";
	var _disableFocus: Boolean = false;
	var _disableConstraints: Boolean = false;
	var doubleClickDuration: Number = 250;
	var buttonRepeatDuration: Number = 100;
	var buttonRepeatDelay: Number = 100;
	var pressedByKeyboard: Boolean = false;
	var stateMap = {up: ["up"], over: ["over"], down: ["down"], release: ["release", "over"], out: ["out", "up"], disabled: ["disabled"], selecting: ["selecting", "over"], kb_selecting: ["kb_selecting", "up"], kb_release: ["kb_release", "out", "up"], kb_down: ["kb_down", "down"]};
	var __height;
	var __width;
	var _disabled;
	var _displayFocus;
	var _focused;
	var _group;
	var _height;
	var _label;
	var _name;
	var _parent;
	var _width;
	var _x;
	var buttonRepeatInterval;
	var constraints;
	var dispatchEvent;
	var dispatchEventAndSound;
	var doubleClickInterval;
	var focusEnabled;
	var focusIndicator;
	var gotoAndPlay;
	var initialized;
	var inspectableGroupName;
	var invalidate;
	var onDragOut;
	var onDragOver;
	var onPress;
	var onRelease;
	var onReleaseOutside;
	var onRollOut;
	var onRollOver;
	var sizeIsInvalid;
	var tabEnabled;
	var textField;
	var validateNow;

	function Button()
	{
		super();
		this.focusEnabled = this.tabEnabled = this._disableFocus ? false : !this._disabled;
		if (this.inspectableGroupName != null && this.inspectableGroupName != "") 
		{
			this.group = this.inspectableGroupName;
		}
	}

	function get labelID()
	{
		return null;
	}

	function set labelID(value)
	{
		if (value != "") 
		{
			this.label = gfx.utils.Locale.getTranslatedString(value);
		}
	}

	function get label()
	{
		return this._label;
	}

	function set label(value)
	{
		this._label = value;
		if (this.initialized) 
		{
			if (this.textField != null) 
			{
				this.textField.text = this._label;
			}
			if (this.autoSize != "none") 
			{
				this.sizeIsInvalid = true;
			}
			this.updateAfterStateChange();
		}
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
			this.clearRepeatInterval();
			this.focusEnabled = this.tabEnabled = this._disableFocus ? false : !this._disabled;
			this.setState(this._disabled ? "disabled" : "up");
			return;
		}
	}

	function get selected()
	{
		return this._selected;
	}

	function set selected(value)
	{
		if (this._selected != value) 
		{
			this._selected = value;
			if (this._disabled) 
			{
				this.setState("disabled");
			}
			else if (this._focused) 
			{
				if (this.pressedByKeyboard && this.focusIndicator != null) 
				{
					this.setState("kb_selecting");
				}
				else 
				{
					this.setState("selecting");
				}
			}
			else 
			{
				this.setState(this.displayFocus && this.focusIndicator == null ? "over" : "up");
			}
			if (this.dispatchEvent != null) 
			{
				this.dispatchEventAndSound({type: "select", selected: this._selected});
			}
			return;
		}
	}

	function get groupName()
	{
		return this._group == null ? null : this._group.name;
	}

	function set groupName(value)
	{
		this.group = value;
	}

	function get group()
	{
		return this._group;
	}

	function set group(value)
	{
		var __reg2 = gfx.controls.ButtonGroup(value);
		if (typeof value == "string") 
		{
			__reg2 = this._parent["_buttonGroup_" + value];
			if (__reg2 == null) 
			{
				this._parent["_buttonGroup_" + value] = __reg2 = new gfx.controls.ButtonGroup(value.toString(), this._parent);
			}
		}
		if (this._group != __reg2) 
		{
			if (this._group != null) 
			{
				this._group.removeButton(this);
			}
			this._group = __reg2;
			if (this._group != null) 
			{
				__reg2.addButton(this);
			}
			return;
		}
	}

	function get disableFocus()
	{
		return this._disableFocus;
	}

	function set disableFocus(value)
	{
		this._disableFocus = value;
		this.focusEnabled = this.tabEnabled = this._disableFocus ? false : !this._disabled;
	}

	function get disableConstraints()
	{
		return this._disableConstraints;
	}

	function set disableConstraints(value)
	{
		this._disableConstraints = value;
	}

	function get autoSize()
	{
		return this._autoSize;
	}

	function set autoSize(value)
	{
		if (this._autoSize != value) 
		{
			this._autoSize = value;
			if (this.initialized) 
			{
				this.sizeIsInvalid = true;
				this.validateNow();
			}
			return;
		}
	}

	function setSize(width, height)
	{
		super.setSize(width, height);
	}

	function handleInput(details, pathToFocus)
	{
		if ((__reg0 = details.navEquivalent) === gfx.ui.NavigationCode.ENTER) 
		{
			var __reg2 = details.controllerIdx;
			if (details.value == "keyDown" || details.value == "keyHold") 
			{
				if (!this.pressedByKeyboard) 
				{
					this.handlePress(__reg2);
				}
			}
			else 
			{
				this.handleRelease(__reg2);
			}
			return true;
		}
		return false;
	}

	function toString()
	{
		return "[Scaleform Button " + this._name + "]";
	}

	function configUI()
	{
		this.constraints = new gfx.utils.Constraints(this, true);
		if (!this._disableConstraints) 
		{
			this.constraints.addElement(this.textField, gfx.utils.Constraints.ALL);
		}
		super.configUI();
		if (this._autoSize != "none") 
		{
			this.sizeIsInvalid = true;
		}
		this.onRollOver = this.handleMouseRollOver;
		this.onRollOut = this.handleMouseRollOut;
		this.onPress = this.handleMousePress;
		this.onRelease = this.handleMouseRelease;
		this.onReleaseOutside = this.handleReleaseOutside;
		this.onDragOver = this.handleDragOver;
		this.onDragOut = this.handleDragOut;
		if (this.focusIndicator != null && !this._focused && this.focusIndicator._totalFrames == 1) 
		{
			this.focusIndicator._visible = false;
		}
		this.updateAfterStateChange();
	}

	function draw()
	{
		if (this.sizeIsInvalid) 
		{
			this.alignForAutoSize();
			this._width = this.__width;
			this._height = this.__height;
		}
		if (this.initialized) 
		{
			this.constraints.update(this.__width, this.__height);
		}
	}

	function updateAfterStateChange()
	{
		if (this.initialized) 
		{
			if (this.textField != null && this._label != null) 
			{
				this.textField.text = this._label;
			}
			this.validateNow();
			if (this.constraints != null) 
			{
				this.constraints.update(this.width, this.height);
			}
			this.dispatchEvent({type: "stateChange", state: this.state});
		}
	}

	function calculateWidth()
	{
		if (this.constraints == null) 
		{
			this.invalidate();
			return 0;
		}
		var __reg2 = this.constraints.getElement(this.textField).metrics;
		var __reg3 = this.textField.textWidth + __reg2.left + __reg2.right + 5;
		return __reg3;
	}

	function alignForAutoSize()
	{
		if (!this.initialized || this._autoSize == "none" || this.textField == null) 
		{
			return undefined;
		}
		var __reg2 = this.__width;
		this.width = this.calculateWidth();
		if ((__reg0 = this._autoSize) === "right") 
		{
			var __reg3 = this._x + __reg2;
			this._x = __reg3 - this.__width;
			return;
		}
		else if (__reg0 !== "center") 
		{
			return;
		}
		var __reg4 = this._x + __reg2 / 2;
		this._x = __reg4 - this.__width / 2;
		return;
	}

	function setState(state)
	{
		this.state = state;
		var __reg5 = this.getStatePrefixes();
		var __reg3 = this.stateMap[state];
		if (__reg3 == null || __reg3.length == 0) 
		{
			return undefined;
		}
		do 
		{
			var __reg4 = __reg5.pop().toString();
			var __reg2 = __reg3.length - 1;
			while (__reg2 >= 0) 
			{
				this.gotoAndPlay(__reg4 + __reg3[__reg2]);
				--__reg2;
			}
		}
		while (__reg5.length > 0);
		this.updateAfterStateChange();
	}

	function getStatePrefixes()
	{
		return this._selected ? ["selected_", ""] : [""];
	}

	function changeFocus()
	{
		if (this._disabled) 
		{
			return undefined;
		}
		if (this.focusIndicator == null) 
		{
			this.setState(this._focused || this._displayFocus ? "over" : "out");
			if (this.pressedByKeyboard && !this._focused) 
			{
				this.pressedByKeyboard = false;
			}
		}
		if (this.focusIndicator != null) 
		{
			if (this.focusIndicator._totalframes == 1) 
			{
				this.focusIndicator._visible = this._focused != 0;
			}
			else 
			{
				this.focusIndicator.gotoAndPlay(this._focused ? "show" : "hide");
				this.focusIndicator.gotoAndPlay("state" + this._focused);
			}
			if (this.pressedByKeyboard && !this._focused) 
			{
				this.setState("kb_release");
				this.pressedByKeyboard = false;
			}
		}
	}

	function handleMouseRollOver(controllerIdx)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		if ((!this._focused && !this._displayFocus) || this.focusIndicator != null) 
		{
			this.setState("over");
		}
		this.dispatchEventAndSound({type: "rollOver", controllerIdx: controllerIdx});
	}

	function handleMouseRollOut(controllerIdx)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		if ((!this._focused && !this._displayFocus) || this.focusIndicator != null) 
		{
			this.setState("out");
		}
		this.dispatchEventAndSound({type: "rollOut", controllerIdx: controllerIdx});
	}

	function handleMousePress(controllerIdx, keyboardOrMouse, button)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		if (!this._disableFocus) 
		{
			Selection.setFocus(this, controllerIdx);
		}
		this.setState("down");
		this.dispatchEventAndSound({type: "press", controllerIdx: controllerIdx, button: button});
		if (this.autoRepeat) 
		{
			this.buttonRepeatInterval = setInterval(this, "beginButtonRepeat", this.buttonRepeatDelay, controllerIdx, button);
		}
	}

	function handlePress(controllerIdx)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		this.pressedByKeyboard = true;
		this.setState(this.focusIndicator == null ? "down" : "kb_down");
		this.dispatchEventAndSound({type: "press", controllerIdx: controllerIdx});
	}

	function handleMouseRelease(controllerIdx, keyboardOrMouse, button)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		clearInterval(this.buttonRepeatInterval);
		delete this.buttonRepeatInterval;
		if (this.doubleClickEnabled) 
		{
			if (this.doubleClickInterval == null) 
			{
				this.doubleClickInterval = setInterval(this, "doubleClickExpired", this.doubleClickDuration);
			}
			else 
			{
				this.doubleClickExpired();
				this.dispatchEventAndSound({type: "doubleClick", controllerIdx: controllerIdx, button: button});
				this.setState("release");
				return undefined;
			}
		}
		this.setState("release");
		this.handleClick(controllerIdx, button);
	}

	function handleRelease(controllerIdx)
	{
		if (this._disabled) 
		{
			return undefined;
		}
		this.setState(this.focusIndicator == null ? "release" : "kb_release");
		this.handleClick(controllerIdx);
		this.pressedByKeyboard = false;
	}

	function handleClick(controllerIdx, button)
	{
		if (this.toggle) 
		{
			this.selected = !this._selected;
		}
		this.dispatchEventAndSound({type: "click", controllerIdx: controllerIdx, button: button});
	}

	function handleDragOver(controllerIdx, button)
	{
		if (this._disabled || this.lockDragStateChange) 
		{
			return undefined;
		}
		if (this._focused || this._displayFocus) 
		{
			this.setState(this.focusIndicator == null ? "down" : "kb_down");
		}
		else 
		{
			this.setState("over");
		}
		this.dispatchEvent({type: "dragOver", controllerIdx: controllerIdx, button: button});
	}

	function handleDragOut(controllerIdx, button)
	{
		if (this._disabled || this.lockDragStateChange) 
		{
			return undefined;
		}
		if (this._focused || this._displayFocus) 
		{
			this.setState(this.focusIndicator == null ? "release" : "kb_release");
		}
		else 
		{
			this.setState("out");
		}
		this.dispatchEvent({type: "dragOut", controllerIdx: controllerIdx, button: button});
	}

	function handleReleaseOutside(controllerIdx, button)
	{
		this.clearRepeatInterval();
		if (this._disabled) 
		{
			return undefined;
		}
		if (this.lockDragStateChange) 
		{
			if (this._focused || this._displayFocus) 
			{
				this.setState(this.focusIndicator == null ? "release" : "kb_release");
			}
			else 
			{
				this.setState("kb_release");
			}
		}
		this.dispatchEvent({type: "releaseOutside", state: this.state, button: button});
	}

	function doubleClickExpired()
	{
		clearInterval(this.doubleClickInterval);
		delete this.doubleClickInterval;
	}

	function beginButtonRepeat(controllerIdx, button)
	{
		this.clearRepeatInterval();
		this.buttonRepeatInterval = setInterval(this, "handleButtonRepeat", this.buttonRepeatDuration, controllerIdx, button);
	}

	function handleButtonRepeat(controllerIdx, button)
	{
		this.dispatchEventAndSound({type: "click", controllerIdx: controllerIdx, button: button});
	}

	function clearRepeatInterval()
	{
		clearInterval(this.buttonRepeatInterval);
		delete this.buttonRepeatInterval;
	}

}
