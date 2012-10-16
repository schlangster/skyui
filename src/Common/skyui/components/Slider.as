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
	
	
  /* PROPERTIES */
	
	function get disabled(): Boolean
	{
		return super.disabled;
	}

	public function set disabled(a_val: Boolean): Void
	{
		leftArrow.disabled =  _disabled;
		rightArrow.disabled = _disabled;
		
		super.disabled = a_val;
	}
	

  /* PUBLIC FUNCTIONS */

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (super.handleInput(details, pathToFocus))
			return true;

		if (details.value == "keyDown" || details.value == "keyHold") {
			switch (details.navEquivalent) {
				case NavigationCode.PAGE_DOWN:
				case NavigationCode.GAMEPAD_L1:
					value -= Math.abs(maximum - minimum) / 10;
					dispatchEventAndSound({type:"change"});
					return true;
				case NavigationCode.PAGE_UP:
				case NavigationCode.GAMEPAD_R1:
					value += Math.abs(maximum - minimum) / 10;
					dispatchEventAndSound({type:"change"});
					return true;
			}
		}

		return false;
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function configUI(): Void
	{
		super.configUI();
		leftArrow.addEventListener("click", this, "scrollLeft");
		rightArrow.addEventListener("click", this, "scrollRight");
		leftArrow.autoRepeat = rightArrow.autoRepeat = true;
		leftArrow.focusTarget = rightArrow.focusTarget = this;

		var r:Number = _rotation;
		_rotation = 0;
		constraints.addElement(rightArrow, Constraints.RIGHT);
		constraints.addElement(track, Constraints.LEFT | Constraints.RIGHT);
		_rotation = r;

		// Override left and right offsets
		offsetLeft = leftArrow._width + thumb._width/2;
		offsetRight = rightArrow._width + thumb._width/2;
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