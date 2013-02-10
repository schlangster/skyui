import gfx.io.GameDelegate;

class Map.MarkerDescription extends MovieClip
{
	var DescriptionList: Array;
	var LineItem0: MovieClip;
	var Title: TextField;


  /* INITIALIZATION */

	public function MarkerDescription()
	{
		super();
		Title = Title;
		Title.autoSize = "left";
		DescriptionList = new Array();
		DescriptionList.push(LineItem0);
		DescriptionList[0]._visible = false;
	}

	function SetDescription(aTitle: String, aLineItems: Array): Void
	{
		Title.text = aTitle == undefined ? "" : aTitle;
		var totalHeight: Number = Title.text.length <= 0 ? 0 : Title._height;
		
		for (var i: Number = 0; i < aLineItems.length; i++) {
			if (i >= DescriptionList.length) {
				DescriptionList.push(attachMovie("DescriptionLineItem", "LineItem" + i, getNextHighestDepth()));
				DescriptionList[i]._x = DescriptionList[0]._x;
				DescriptionList[i]._y = DescriptionList[0]._y;
			}
			
			DescriptionList[i]._visible = true;
			var item: TextField = DescriptionList[i].Item;
			var value: TextField = DescriptionList[i].Value;
			var itemString: String = aLineItems[i].Item;
			item.autoSize = "left";
			item.text = itemString != undefined && itemString.length > 0 ? itemString + ": " : "";
			value.autoSize = "left";
			value.text = aLineItems[i].Value == undefined ? "" : aLineItems[i].Value;
			value._x = item._x + item._width;
			totalHeight = totalHeight + DescriptionList[i]._height;
		}
		for (var i: Number = aLineItems.length; i < DescriptionList.length; i++) {
			DescriptionList[i]._visible = false;
		}
		
		var yOffset: Number = (0 - totalHeight) / 2;
		Title._y = yOffset;
		yOffset = yOffset + (Title.text.length <= 0 ? 0 : Title._height);
		
		for (var i: Number = 0; i < DescriptionList.length; i++) {
			DescriptionList[i]._y = yOffset;
			yOffset = yOffset + DescriptionList[i]._height;
		}
	}

	function OnShowFinish()
	{
		GameDelegate.call("PlaySound", ["UIMapRolloverFlyout"]);
	}

}
