dynamic class SettingsOptionItem extends MovieClip
{
	var CheckBox_mc;
	var OptionStepper_mc;
	var ScrollBar_mc;
	var _parent;
	var bSendChangeEvent;
	var checkBox;
	var iID;
	var iMovieType;
	var optionStepper;
	var scrollBar;
	var textField;

	function SettingsOptionItem()
	{
		super();
		Mouse.addListener(this);
		this.ScrollBar_mc = this.scrollBar;
		this.OptionStepper_mc = this.optionStepper;
		this.CheckBox_mc = this.checkBox;
		this.bSendChangeEvent = true;
		this.textField.textAutoSize = "shrink";
	}

	function onLoad()
	{
		this.ScrollBar_mc.setScrollProperties(0.7, 0, 20);
		this.ScrollBar_mc.addEventListener("scroll", this, "onScroll");
		this.OptionStepper_mc.addEventListener("change", this, "onStepperChange");
		this.bSendChangeEvent = true;
	}

	function get movieType()
	{
		return this.iMovieType;
	}

	function set movieType(aiMovieType)
	{
		this.iMovieType = aiMovieType;
		this.ScrollBar_mc.disabled = true;
		this.ScrollBar_mc.visible = false;
		this.OptionStepper_mc.disabled = true;
		this.OptionStepper_mc.visible = false;
		this.CheckBox_mc._visible = false;
		if ((__reg0 = this.iMovieType) === 0) 
		{
			this.ScrollBar_mc.disabled = false;
			this.ScrollBar_mc.visible = true;
		}
		else if (__reg0 === 1) 
		{
			this.OptionStepper_mc.disabled = false;
			this.OptionStepper_mc.visible = true;
		}
		else if (__reg0 === 2) 
		{
			this.CheckBox_mc._visible = true;
		}
	}

	function get ID()
	{
		return this.iID;
	}

	function set ID(aiNewValue)
	{
		this.iID = aiNewValue;
	}

	function get value()
	{
		var __reg2 = undefined;
		if ((__reg0 = this.iMovieType) === 0) 
		{
			__reg2 = this.ScrollBar_mc.position / 20;
		}
		else if (__reg0 === 1) 
		{
			__reg2 = this.OptionStepper_mc.selectedIndex;
		}
		else if (__reg0 === 2) 
		{
			__reg2 = this.CheckBox_mc._currentframe - 1;
		}
		return __reg2;
	}

	function set value(afNewValue)
	{
		if ((__reg0 = this.iMovieType) === 0) 
		{
			this.bSendChangeEvent = false;
			this.ScrollBar_mc.position = afNewValue * 20;
			this.bSendChangeEvent = true;
		}
		else if (__reg0 === 1) 
		{
			this.bSendChangeEvent = false;
			this.OptionStepper_mc.selectedIndex = afNewValue;
			this.bSendChangeEvent = true;
		}
		else if (__reg0 === 2) 
		{
			this.CheckBox_mc.gotoAndStop(afNewValue + 1);
		}
	}

	function get text()
	{
		return this.textField.text;
	}

	function set text(astrNew)
	{
		this.textField.SetText(astrNew);
	}

	function get selected()
	{
		return this.textField._alpha == 100;
	}

	function set selected(abSelected)
	{
		this.textField._alpha = abSelected ? 100 : 30;
		this.ScrollBar_mc._alpha = abSelected ? 100 : 30;
		this.OptionStepper_mc._alpha = abSelected ? 100 : 30;
		this.CheckBox_mc._alpha = abSelected ? 100 : 30;
	}

	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		var __reg3 = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) 
		{
			if ((__reg0 = this.iMovieType) === 0) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.LEFT) 
				{
					this.ScrollBar_mc.position = this.ScrollBar_mc.position - 1;
					__reg3 = true;
				}
				else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT) 
				{
					this.ScrollBar_mc.position = this.ScrollBar_mc.position + 1;
					__reg3 = true;
				}
			}
			else if (__reg0 === 1) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.navEquivalent == gfx.ui.NavigationCode.RIGHT) 
				{
					__reg3 = this.OptionStepper_mc.handleInput(details, pathToFocus);
				}
			}
			else if (__reg0 === 2) 
			{
				if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) 
				{
					this.ToggleCheckbox();
					__reg3 = true;
				}
			}
		}
		return __reg3;
	}

	function SetOptionStepperOptions(aOptions)
	{
		this.bSendChangeEvent = false;
		this.OptionStepper_mc.dataProvider = aOptions;
		this.bSendChangeEvent = true;
	}

	function onMousePress()
	{
		var __reg2 = Mouse.getTopMostEntity();
		if ((__reg0 = this.iMovieType) === 0) 
		{
			if (__reg2 == this.ScrollBar_mc.thumb) 
			{
				this.ScrollBar_mc.thumb.onPress();
			}
			else if (__reg2._parent == this.ScrollBar_mc.upArrow) 
			{
				this.ScrollBar_mc.upArrow.onPress();
			}
			else if (__reg2._parent == this.ScrollBar_mc.downArrow) 
			{
				this.ScrollBar_mc.downArrow.onPress();
			}
			else if (__reg2 == this.ScrollBar_mc.track) 
			{
				this.ScrollBar_mc.track.onPress();
			}
			return;
		}
		else if (__reg0 === 1) 
		{
			if (__reg2 == this.OptionStepper_mc.nextBtn || __reg2 == this.OptionStepper_mc.textField) 
			{
				this.OptionStepper_mc.nextBtn.onPress();
			}
			else if (__reg2 == this.OptionStepper_mc.prevBtn) 
			{
				this.OptionStepper_mc.prevBtn.onPress();
			}
			return;
		}
		else if (__reg0 !== 2) 
		{
			return;
		}
		return;
	}

	function onRelease()
	{
		var __reg2 = Mouse.getTopMostEntity();
		if ((__reg0 = this.iMovieType) === 0) 
		{
			if (__reg2 == this.ScrollBar_mc.thumb) 
			{
				this.ScrollBar_mc.thumb.onRelease();
			}
			else if (__reg2._parent == this.ScrollBar_mc.upArrow) 
			{
				this.ScrollBar_mc.upArrow.onRelease();
			}
			else if (__reg2._parent == this.ScrollBar_mc.downArrow) 
			{
				this.ScrollBar_mc.downArrow.onRelease();
			}
			else if (__reg2 == this.ScrollBar_mc.track) 
			{
				this.ScrollBar_mc.track.onRelease();
			}
			return;
		}
		else if (__reg0 === 1) 
		{
			if (__reg2 == this.OptionStepper_mc.nextBtn || __reg2 == this.OptionStepper_mc.textField) 
			{
				this.OptionStepper_mc.nextBtn.onRelease();
			}
			else if (__reg2 == this.OptionStepper_mc.prevBtn) 
			{
				this.OptionStepper_mc.prevBtn.onRelease();
			}
			return;
		}
		else if (__reg0 !== 2) 
		{
			return;
		}
		if (__reg2._parent == this.CheckBox_mc) 
		{
			this.ToggleCheckbox();
		}
		return;
	}

	function ToggleCheckbox()
	{
		if (this.CheckBox_mc._currentframe == 1) 
		{
			this.CheckBox_mc.gotoAndStop(2);
		}
		else if (this.CheckBox_mc._currentframe == 2) 
		{
			this.CheckBox_mc.gotoAndStop(1);
		}
		this.DoOptionChange();
	}

	function onStepperChange(event)
	{
		if (this.bSendChangeEvent) 
		{
			this.DoOptionChange();
		}
	}

	function onScroll(event)
	{
		if (this.bSendChangeEvent) 
		{
			this.DoOptionChange();
		}
	}

	function DoOptionChange()
	{
		gfx.io.GameDelegate.call("OptionChange", [this.ID, this.value]);
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
		this._parent.onValueChange(MovieClip(this).itemIndex, this.value);
	}

}
