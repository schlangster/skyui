class skyui.BarterDataFetcher extends skyui.InventoryDataFetcher
{
	private var _barterSellMult:Number;
	private var _barterBuyMult:Number;
	
	function BarterDataFetcher()
	{
		super();
		_barterSellMult = 1.0;
		_barterBuyMult = 1.0;
	}
	
	function set barterSellMult(a_mult:Number)
	{
		_barterSellMult = a_mult;
	}
	
	function get barterSellMult():Number
	{
		return _barterSellMult;
	}
	
	function set barterBuyMult(a_mult:Number)
	{
		_barterBuyMult = a_mult;
	}
	
	function get barterBuyMult():Number
	{
		return _barterBuyMult;
	}
	
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		super.processEntry(a_entryObject, a_itemInfo);
		
		if (a_entryObject.filterFlag < 1024) {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * _barterSellMult);
		} else {
			a_entryObject.infoValue = Math.round(a_itemInfo.value * _barterBuyMult);
		}
	}
}