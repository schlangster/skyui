import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class QuantitySlider extends gfx.controls.Slider
{
	var dispatchEvent: Function;

	function QuantitySlider()
	{
		super();
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = super.handleInput(details, pathToFocus);
		if (!bHandledInput) {
			if (GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.PAGE_DOWN || details.navEquivalent == NavigationCode.GAMEPAD_L1) {
					value = Math.floor(value - maximum / 4);
					dispatchEvent({type: "change"});
					bHandledInput = true;
				} else if (details.navEquivalent == NavigationCode.PAGE_UP || details.navEquivalent == NavigationCode.GAMEPAD_R1) {
					value = Math.ceil(value + maximum / 4);
					dispatchEvent({type: "change"});
					bHandledInput = true;
				}
			}
		}
		return bHandledInput;
	}

}
