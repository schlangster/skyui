dynamic class gfx.controls.RadioButton extends gfx.controls.Button
{
	var _group;
	var _name;

	function RadioButton()
	{
		super();
		if (this._group == null) 
		{
			this.group = "buttonGroup";
		}
	}

	function toString()
	{
		return "[Scaleform RadioButton " + this._name + "]";
	}

	function configUI()
	{
		super.configUI();
	}

}
