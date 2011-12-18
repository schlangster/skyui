dynamic class gfx.controls.TextInput extends gfx.core.UIComponent
{
	var defaultText: String = "";
	var soundMap = {theme: "default", focusIn: "focusIn", focusOut: "focusOut", textChange: "textChange"};
	var _text: String = "";
	var _maxChars: Number = 0;
	var _editable: Boolean = true;
	var actAsButton: Boolean = false;
	var hscroll: Number = 0;
	var changeLock: Boolean = false;
	var __height;
	var __width;
	var _disabled;
	var _focused;
	var _height;
	var _name;
	var _password;
	var _selectable;
	var _width;
	var constraints;
	var defaultTextFormat;
	var dispatchEvent;
	var dispatchEventAndSound;
	var focusEnabled;
	var gotoAndPlay;
	var initialized;
	var isHtml;
	var onPress;
	var onRollOut;
	var onRollOver;
	var sizeIsInvalid;
	var tabEnabled;
	var textField;

	function TextInput()
	{
		super();
		this.tabEnabled = !this._disabled;
		this.focusEnabled = !this._disabled;
		this.defaultTextFormat = this.textField.getNewTextFormat();
		this.defaultTextFormat.italic = true;
		this.defaultTextFormat.color = 11184810;
	}

	function get textID()
	{
		return null;
	}

	function set textID(value)
	{
		if (value != "") 
		{
			this.text = gfx.utils.Locale.getTranslatedString(value);
		}
	}

	function get text()
	{
		return this._text;
	}

	function set text(value)
	{
		this._text = value;
		this.isHtml = false;
		this.updateText();
	}

	function get htmlText()
	{
		return this._text;
	}

	function set htmlText(value)
	{
		this._text = value;
		this.isHtml = true;
		this.updateText();
	}

	function get editable()
	{
		return this._editable;
	}

	function set editable(value)
	{
		this._editable = value;
		this.tabEnabled = !this._disabled && !this._editable;
		this.updateTextField();
	}

	function get password()
	{
		return this.textField.password;
	}

	function set password(value)
	{
		this._password = this.textField.password = value;
	}

	function get maxChars()
	{
		return this._maxChars;
	}

	function set maxChars(value)
	{
		this._maxChars = this.textField.maxChars = value;
	}

	function get disabled()
	{
		return this._disabled;
	}

	function set disabled(value)
	{
		super.disabled = value;
		this.tabEnabled = !this._disabled;
		this.focusEnabled = !this._disabled;
		if (this.initialized) 
		{
			this.setMouseHandlers();
			this.setState();
			this.updateTextField();
		}
	}

	function appendText(text)
	{
		this._text = this._text + text;
		if (this.isHtml) 
		{
			this.textField.html = false;
		}
		this.isHtml = false;
		this.textField.appendText(text);
	}

	function appendHtml(text)
	{
		this._text = this._text + text;
		if (!this.isHtml) 
		{
			this.textField.html = true;
		}
		this.isHtml = true;
		this.textField.appendHtml(text);
	}

	function get length()
	{
		return this.textField.length;
	}

	function handleInput(details, pathToFocus)
	{
		if (details.value != "keyDown" && details.value != "keyHold") 
		{
			return false;
		}
		var __reg2 = details.controllerIdx;
		if (Selection.getFocus(__reg2) != null) 
		{
			return false;
		}
		Selection.setFocus(this.textField, __reg2);
		return true;
	}

	function toString()
	{
		return "[Scaleform TextInput " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
		this.constraints = new gfx.utils.Constraints(this, true);
		this.constraints.addElement(this.textField, gfx.utils.Constraints.ALL);
		this.setState();
		this.updateTextField();
		this.setMouseHandlers();
	}

	function setState()
	{
		this.gotoAndPlay(this._disabled ? "disabled" : (this._focused ? "focused" : "default"));
	}

	function setMouseHandlers()
	{
		if (this.actAsButton != false) 
		{
			if (this._disabled || this._focused) 
			{
				delete this.onRollOver;
				delete this.onRollOut;
				delete this.onPress;
				return;
			}
			if (this._editable) 
			{
				this.onRollOver = this.handleMouseRollOver;
				this.onRollOut = this.handleMouseRollOut;
				this.onPress = this.handleMousePress;
			}
		}
	}

	function handleMousePress(controllerIdx, keyboardOrMouse, button)
	{
		this.dispatchEvent({type: "press", controllerIdx: controllerIdx, button: button});
		Selection.setFocus(this.textField, controllerIdx);
	}

	function handleMouseRollOver(controllerIdx)
	{
		this.gotoAndPlay("default");
		this.gotoAndPlay("over");
		if (this.constraints) 
		{
			this.constraints.update(this.__width, this.__height);
		}
		this.updateTextField();
		this.dispatchEvent({type: "rollOver", controllerIdx: controllerIdx});
	}

	function handleMouseRollOut(controllerIdx)
	{
		this.gotoAndPlay("default");
		this.gotoAndPlay("out");
		if (this.constraints) 
		{
			this.constraints.update(this.__width, this.__height);
		}
		this.updateTextField();
		this.dispatchEvent({type: "rollOut", controllerIdx: controllerIdx});
	}

	function draw()
	{
		if (this.sizeIsInvalid) 
		{
			this._width = this.__width;
			this._height = this.__height;
		}
		super.draw();
		this.constraints.update(this.__width, this.__height);
	}

	function changeFocus()
	{
		this.tabEnabled = !this._disabled;
		if (!this._focused) 
		{
			this.hscroll = this.textField.hscroll;
		}
		this.setState();
		if (this.constraints) 
		{
			this.constraints.update(this.__width, this.__height);
		}
		this.updateTextField();
		if (this._focused && this.textField.type == "input") 
		{
			this.tabEnabled = false;
			var __reg3 = Selection.getFocusBitmask(this);
			var __reg2 = 0;
			while (__reg2 < System.capabilities.numControllers) 
			{
				if ((__reg3 >> __reg2 & 1) != 0) 
				{
					Selection.setFocus(this.textField, __reg2);
					if (this.textField.noAutoSelection) 
					{
						Selection.setSelection(this.textField.htmlText.length, this.textField.htmlText.length, __reg2);
					}
					else 
					{
						Selection.setSelection(0, this.textField.htmlText.length, __reg2);
					}
				}
				++__reg2;
			}
		}
		this.setMouseHandlers();
		this.textField.hscroll = this.hscroll;
	}

	function updateText()
	{
		if (this._text != "") 
		{
			if (this.isHtml) 
			{
				this.textField.html = true;
				this.textField.htmlText = this._text;
			}
			else 
			{
				this.textField.html = false;
				this.textField.text = this._text;
			}
			return;
		}
		this.textField.text = "";
		if (!this._focused && this.defaultText != "") 
		{
			this.textField.text = this.defaultText;
			this.textField.setTextFormat(this.defaultTextFormat);
		}
	}

	function updateTextField()
	{
		if (this.textField != null) 
		{
			if (!this._selectable) 
			{
				this._selectable = this.textField.selectable;
			}
			this.updateText();
			this.textField.maxChars = this._maxChars;
			this.textField.noAutoSelection = true;
			this.textField.password = this._password;
			this.textField.selectable = this._disabled ? false : this._selectable || this._editable;
			this.textField.type = this._editable && !this._disabled ? "input" : "dynamic";
			this.textField.focusTarget = this;
			this.textField.hscroll = this.hscroll;
			this.textField.addListener(this);
		}
	}

	function onChanged(target)
	{
		if (this.changeLock) 
		{
			return;
		}
		this._text = this.isHtml ? this.textField.htmlText : this.textField.text;
		this.dispatchEventAndSound({type: "textChange"});
	}

}
