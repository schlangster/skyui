import skyui.components.list.BasicList;

class BarterDataFetcher extends InventoryDataFetcher
{
  /* PROPERTIES */
  
	public var barterSellMult: Number;
	
	public var barterBuyMult: Number;
	
	
  /* CONSTRUCTORS */
	
	function BarterDataFetcher(a_list: BasicList)
	{
		super(a_list);
		barterSellMult = 1.0;
		barterBuyMult = 1.0;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	
  	// @override InventoryDataFetcher
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