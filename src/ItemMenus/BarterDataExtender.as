import skyui.components.list.BasicList;

class BarterDataExtender extends InventoryDataExtender
{
  /* PROPERTIES */
  
	public var barterSellMult: Number;
	public var barterBuyMult: Number;
	
	
  /* INITIALIZATION */
	
	function BarterDataExtender()
	{
		super();
		barterSellMult = 1.0;
		barterBuyMult = 1.0;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override InventoryDataExtender
	function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		super.processEntry(a_entryObject, a_itemInfo);
		
		if (a_entryObject.filterFlag < 1024) {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * barterSellMult);
		} else {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * barterBuyMult);
		}
	}
	
	

}