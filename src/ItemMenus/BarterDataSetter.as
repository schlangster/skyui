class BarterDataSetter extends InventoryDataSetter
{
  /* PRIVATE VARIABLES */
	
	private var _barterBuyMult: Number;
	private var _barterSellMult: Number;
	
	
  /* INITIALIZATION */
	
	public function BarterDataSetter(a_barterBuyMult: Number, a_barterSellMult: Number)
	{
		super();

		_barterBuyMult = (a_barterBuyMult == undefined) ? 1.0 : a_barterBuyMult;
		_barterSellMult = (a_barterSellMult == undefined) ? 1.0 : a_barterSellMult;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override InventoryDataSetter
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		// Apply multipliers to itemInfo value, then process the entry
		if (a_entryObject.filterFlag < 1024) {
			a_itemInfo.value = a_itemInfo.value * _barterSellMult;
		} else {
			a_itemInfo.value = Math.max((a_itemInfo.value * _barterBuyMult), 1);
		}
		a_itemInfo.value = Math.floor(a_itemInfo.value + 0.5);

		super.processEntry(a_entryObject, a_itemInfo);
	}

	public function updateBarterMultipliers(a_barterBuyMult: Number, a_barterSellMult: Number): Void
	{
		// Not used (yet/ever)
		// see BarterMenu.doTransaction
		_barterBuyMult = (a_barterBuyMult == undefined) ? 1.0 : a_barterBuyMult;
		_barterSellMult = (a_barterSellMult == undefined) ? 1.0 : a_barterSellMult;
	}

}