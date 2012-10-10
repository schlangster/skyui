import gfx.ui.InputDetails;
import gfx.controls.Button;
import gfx.utils.Constraints;
import gfx.ui.NavigationCode;

class skyui.components.Slider extends gfx.controls.Slider
{
  /* STAGE ELEMENTS */
	
	public var leftArrow: Button;
	public var rightArrow: Button;


  /* INITIALIATZION */

	function Slider()
	{
		super();
	}


  /* PUBLIC FUNCTIONS */

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (super.handleInput(details, pathToFocus))
			return true;

		var keyPressed = (details.value == "keyDown" || details.value == "keyHold");

		switch (details.navEquivalent) {
			case NavigationCode.PAGE_DOWN:
			case NavigationCode.GAMEPAD_L1:
				if (keyPressed) {
					value -= Math.abs(maximum - minimum) / 10;
					dispatchEventAndSound({type:"change"});
				}
				return true;
			case NavigationCode.PAGE_UP:
			case NavigationCode.GAMEPAD_R1:
				if (keyPressed) {
					value += Math.abs(maximum - minimum) / 10;
					dispatchEventAndSound({type:"change"});
				}
				return true;
		}

		return false;
	}
	
	
  /* PRIVATE FUNCTIONS */

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