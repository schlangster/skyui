dynamic class gfx.ui.InputDetails
{
	var code;
	var controllerIdx;
	var navEquivalent;
	var type;
	var value;

	function InputDetails(type, code, value, navEquivalent, controllerIdx)
	{
		this.type = type;
		this.code = code;
		this.value = value;
		this.navEquivalent = navEquivalent;
		this.controllerIdx = controllerIdx;
	}

	function toString()
	{
		return ["[InputDelegate", "code=" + this.code, "type=" + this.type, "value=" + this.value, "navEquivalent=" + this.navEquivalent, "controllerIdx=" + this.controllerIdx + "]"].toString();
	}

}
