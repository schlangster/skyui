import skyui.components.list.BasicList;

class BarterDataExtender extends InventoryDataExtender
{
  /* PRIVATE VARIABLES */
	
	private var _barterBuyMult: Number;
	private var _barterSellMult: Number;
	
	
  /* INITIALIZATION */
	
	function BarterDataExtender(a_barterBuyMult: Number, a_barterSellMult: Number)
	{
		super();

		_barterBuyMult = (a_barterBuyMult == undefined)? 1.0 : a_barterBuyMult;
		_barterSellMult = (a_barterSellMult == undefined)? 1.0 : a_barterSellMult;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override InventoryDataExtender
	function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		super.processEntry(a_entryObject, a_itemInfo);
		
		if (a_entryObject.filterFlag < 1024) {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * _barterSellMult);
		} else {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * _barterBuyMult);
		}
	}
	
	

}