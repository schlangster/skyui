import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.controls.Button;
import gfx.utils.Constraints;

class skyui.components.Slider extends gfx.controls.Slider
{
	var leftArrow: Button;
	var rightArrow: Button;

	function Slider()
	{
		super();
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (super.handleInput(details, pathToFocus))
			return true;
		
		var keyPress: Boolean = (details.value == "keyDown" || details.value == "keyHold");
		
		switch (details.navEquivalent) {
			case NavigationCode.PAGE_DOWN:
			case NavigationCode.GAMEPAD_L1:
				if (keyPress) {
					value -= maximum / 4;
					dispatchEventAndSound({type:"change"});
				}
				break;
			case NavigationCode.PAGE_UP:
			case NavigationCode.GAMEPAD_R1:
				if (keyPress) {
					value += maximum / 4;
					dispatchEventAndSound({type:"change"});
				}
				break;
			default:
				return false;	
		}

		return true; // Only reaches here when the key press is handled.
	}

	private function configUI(): Void
	{
		super.configUI();
		leftArrow.addEventListener("click", this, "scrollLeft");
		rightArrow.addEventListener("click", this, "scrollRight");
		leftArrow.autoRepeat = true;
		rightArrow.autoRepeat = true;
		leftArrow.focusTarget = this;
		rightArrow.focusTarget = this;

		var r:Number = _rotation;
		_rotation = 0;
		constraints.addElement(rightArrow, Constraints.RIGHT);
		constraints.addElement(track, Constraints.LEFT | Constraints.RIGHT);
		_rotation = r;

		offsetLeft += leftArrow._width + thumb._width/2;
		offsetRight += rightArrow._width + thumb._width/2;
	}
	
	private function scrollLeft(event: Object): Void
	{
		value -= _snapInterval;
		dispatchEventAndSound({type: "change"});
	}

	private function scrollRight(event: Object): Void
	{
		value += _snapInterval;
		dispatchEventAndSound({type: "change"});
	}
}