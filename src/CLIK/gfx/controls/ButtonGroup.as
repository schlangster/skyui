dynamic class gfx.controls.ButtonGroup extends gfx.events.EventDispatcher
{
	var name: String = "buttonGroup";
	var children;
	var dispatchEvent;
	var scope;
	var selectedButton;

	function ButtonGroup(name, scope)
	{
		super();
		this.name = name;
		this.scope = scope;
		this.children = [];
	}

	function get length()
	{
		return this.children.length;
	}

	function addButton(button)
	{
		this.removeButton(button);
		this.children.push(button);
		if (button.selected) 
		{
			this.setSelectedButton(button);
		}
		button.addEventListener("select", this, "handleSelect");
		button.addEventListener("click", this, "handleClick");
	}

	function removeButton(button)
	{
		var __reg2 = this.indexOf(button);
		if (__reg2 > -1) 
		{
			this.children.splice(__reg2, 1);
			button.removeEventListener("select", this, "handleSelect");
			button.removeEventListener("click", this, "handleClick");
		}
		if (this.selectedButton == button) 
		{
			this.selectedButton = null;
		}
	}

	function indexOf(button)
	{
		var __reg4 = this.length;
		if (__reg4 == 0) 
		{
			return -1;
		}
		var __reg2 = 0;
		while (__reg2 < this.length) 
		{
			if (this.children[__reg2] == button) 
			{
				return __reg2;
			}
			++__reg2;
		}
		return -1;
	}

	function getButtonAt(index)
	{
		return this.children[index];
	}

	function get data()
	{
		return this.selectedButton.data;
	}

	function setSelectedButton(button)
	{
		if (this.selectedButton == button || (this.indexOf(button) == -1 && button != null)) 
		{
			return undefined;
		}
		if (this.selectedButton != null && this.selectedButton._name != null) 
		{
			this.selectedButton.selected = false;
		}
		this.selectedButton = button;
		if (this.selectedButton != null) 
		{
			this.selectedButton.selected = true;
			this.dispatchEvent({type: "change", item: this.selectedButton, data: this.selectedButton.data});
		}
	}

	function toString()
	{
		return "[Scaleform RadioButtonGroup " + this.name + "]";
	}

	function handleSelect(event)
	{
		if (event.target.selected) 
		{
			this.setSelectedButton(event.target);
			return;
		}
		this.setSelectedButton(null);
	}

	function handleClick(event)
	{
		this.dispatchEvent({type: "itemClick", item: event.target});
		this.setSelectedButton(event.target);
	}

}
