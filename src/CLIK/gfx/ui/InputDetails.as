class gfx.ui.InputDetails
{
  /* PROPERTIES */
  
	public var code: Number;
	public var controllerIdx: Number;
	public var navEquivalent: String;
	public var type: String;			// "key"
	public var value: String;			// "keyDown"/"keyUp"
	public var control: String;			//  "Jump"
	

  /* INITIALIZATION */

	public function InputDetails(a_type: String, a_code: Number, a_value, a_navEquivalent: String, a_controllerIdx: Number, a_control: String)
	{
		type = a_type;
		code = a_code;
		value = a_value;
		navEquivalent = a_navEquivalent;
		controllerIdx = a_controllerIdx;
		control = a_control;
	}


  /* PUBLIC FUNCTIONS */

	public function toString(): String
	{
		return ["[InputDelegate", "code=" + code, "type=" + type, "value=" + value, "navEquivalent=" + navEquivalent, "controllerIdx=" + controllerIdx + "]"].toString();
	}
}
