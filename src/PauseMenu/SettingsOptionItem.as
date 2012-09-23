import gfx.controls.OptionStepper;
import gfx.controls.ScrollBar;
import Shared.GlobalFunc;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;

class SettingsOptionItem extends MovieClip
{
	var CheckBox_mc: MovieClip;
	var OptionStepper_mc: MovieClip;
	var ScrollBar_mc: MovieClip;
	var bSendChangeEvent: Boolean;
	var checkBox: MovieClip;
	var iID: Number;
	var iMovieType: Number;
	var optionStepper: OptionStepper;
	var scrollBar: ScrollBar;
	var textField: TextField;

	function SettingsOptionItem()
	{
		super();
		Mouse.addListener(this);
		ScrollBar_mc = scrollBar;
		OptionStepper_mc = optionStepper;
		CheckBox_mc = checkBox;
		bSendChangeEvent = true;
		textField.textAutoSize = "shrink";
	}

	function onLoad(): Void
	{
		ScrollBar_mc.setScrollProperties(0.7, 0, 20);
		ScrollBar_mc.addEventListener("scroll", this, "onScroll");
		OptionStepper_mc.addEventListener("change", this, "onStepperChange");
		bSendChangeEvent = true;
	}

	function get movieType(): Number
	{
		return iMovieType;
	}

	function set movieType(aiMovieType: Number): Void
	{
		iMovieType = aiMovieType;
		
		ScrollBar_mc.disabled = true;
		ScrollBar_mc.visible = false;
		
		OptionStepper_mc.disabled = true;
		OptionStepper_mc.visible = false;
		
		CheckBox_mc._visible = false;
		
		switch (iMovieType) {
			case 0:
				ScrollBar_mc.disabled = false;
				ScrollBar_mc.visible = true;
				break;
				
			case 1:
				OptionStepper_mc.disabled = false;
				OptionStepper_mc.visible = true;
				break;
				
			case 2:
				CheckBox_mc._visible = true;
				break;
		}
	}

	function get ID(): Number
	{
		return iID;
	}

	function set ID(aiNewValue: Number): Void
	{
		iID = aiNewValue;
	}

	function get value(): Number
	{
		var iFrameValue: Number = undefined;
		
		switch (iMovieType) {
			case 0:
				iFrameValue = ScrollBar_mc.position / 20;
				break;
				
			case 1:
				iFrameValue = OptionStepper_mc.selectedIndex;
				break;
				
			case 2:
				iFrameValue = CheckBox_mc._currentframe - 1;
				break;
		}
		return iFrameValue;
	}

	function set value(afNewValue: Number): Void
	{
		switch (iMovieType) {
			case 0:
				bSendChangeEvent = false;
				ScrollBar_mc.position = afNewValue * 20;
				bSendChangeEvent = true;
				break;
				
			case 1:
				bSendChangeEvent = false;
				OptionStepper_mc.selectedIndex = afNewValue;
				bSendChangeEvent = true;
				break;
				
			case 2:
				CheckBox_mc.gotoAndStop(afNewValue + 1);
				break;
		}
	}

	function get text(): String
	{
		return textField.text;
	}

	function set text(astrNew: String): Void
	{
		textField.SetText(astrNew);
	}

	function get selected(): Boolean
	{
		return textField._alpha == 100;
	}

	function set selected(abSelected: Boolean): Void
	{
		textField._alpha = abSelected ? 100 : 30;
		ScrollBar_mc._alpha = abSelected ? 100 : 30;
		OptionStepper_mc._alpha = abSelected ? 100 : 30;
		CheckBox_mc._alpha = abSelected ? 100 : 30;
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bhandledInput: Boolean = false;
		
		if (GlobalFunc.IsKeyPressed(details)) {
			switch (iMovieType) {
				case 0:
					if (details.navEquivalent == NavigationCode.LEFT) {
						ScrollBar_mc.position = ScrollBar_mc.position - 1;
						bhandledInput = true;
					} else if (details.navEquivalent == NavigationCode.RIGHT) {
						ScrollBar_mc.position = ScrollBar_mc.position + 1;
						bhandledInput = true;
					}
					break;
					
				case 1:
					if (details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT) {
						bhandledInput = OptionStepper_mc.handleInput(details, pathToFocus);
					}
					break;
					
				case 2:
					if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
						ToggleCheckbox();
						bhandledInput = true;
					}
					break;
			}
		}
		return bhandledInput;
	}

	function SetOptionStepperOptions(aOptions: Object): Void
	{
		bSendChangeEvent = false;
		OptionStepper_mc.dataProvider = aOptions;
		bSendChangeEvent = true;
	}

	function onMousePress(): Void
	{
		var TopMostEntity_mc: Object = Mouse.getTopMostEntity();
		
		switch (iMovieType) {
			case 0:
				if (TopMostEntity_mc == ScrollBar_mc.thumb) {
					ScrollBar_mc.thumb.onPress();
				} else if (TopMostEntity_mc._parent == ScrollBar_mc.upArrow) {
					ScrollBar_mc.upArrow.onPress();
				} else if (TopMostEntity_mc._parent == ScrollBar_mc.downArrow) {
					ScrollBar_mc.downArrow.onPress();
				} else if (TopMostEntity_mc == ScrollBar_mc.track) {
					ScrollBar_mc.track.onPress();
				}
				break;
				
			case 1:
				if (TopMostEntity_mc == OptionStepper_mc.nextBtn || TopMostEntity_mc == OptionStepper_mc.textField) {
					OptionStepper_mc.nextBtn.onPress();
				} else if (TopMostEntity_mc == OptionStepper_mc.prevBtn) {
					OptionStepper_mc.prevBtn.onPress();
				}
				break;
		}
	}

	function onRelease(): Void
	{
	
		var TopMostEntity_mc: Object = Mouse.getTopMostEntity();
	
		switch (iMovieType) {
			case 0:
				if (TopMostEntity_mc == ScrollBar_mc.thumb) {
					ScrollBar_mc.thumb.onRelease();
				} else if (TopMostEntity_mc._parent == ScrollBar_mc.upArrow) {
					ScrollBar_mc.upArrow.onRelease();
				} else if (TopMostEntity_mc._parent == ScrollBar_mc.downArrow) {
					ScrollBar_mc.downArrow.onRelease();
				} else if (TopMostEntity_mc == ScrollBar_mc.track) {
					ScrollBar_mc.track.onRelease();
				}
				break;
				
			case 1:
				if (TopMostEntity_mc == OptionStepper_mc.nextBtn || TopMostEntity_mc == OptionStepper_mc.textField) {
					OptionStepper_mc.nextBtn.onRelease();
				} else if (TopMostEntity_mc == OptionStepper_mc.prevBtn) {
					OptionStepper_mc.prevBtn.onRelease();
				}
				break;
				
			case 2:
				if (TopMostEntity_mc._parent == CheckBox_mc) {
					ToggleCheckbox();
				}
				break;
		}
	}

	function ToggleCheckbox(): Void
	{
		if (CheckBox_mc._currentframe == 1) {
			CheckBox_mc.gotoAndStop(2);
		} else if (CheckBox_mc._currentframe == 2) {
			CheckBox_mc.gotoAndStop(1);
		}
		DoOptionChange();
	}

	function onStepperChange(event: Object): Void
	{
		if (bSendChangeEvent) {
			DoOptionChange();
		}
	}

	function onScroll(event: Object): Void
	{
		if (bSendChangeEvent) {
			DoOptionChange();
		}
	}

	function DoOptionChange(): Void
	{
		GameDelegate.call("OptionChange", [ID, value]);
		GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
		_parent.onValueChange(MovieClip(this).itemIndex, value);
	}

}
