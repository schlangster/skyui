class skyui.BarterDataFetcher extends skyui.InventoryDataFetcher
{
	private var _barterMult:Number;
	
	function BarterDataFetcher()
	{
		super();
		_barterMult = 1.0;
	}
	
	function set barterMult(a_mult:Number)
	{
		_barterMult = a_mult;
	}
	
	function get barterMult():Number
	{
		return _barterMult;
	}
	
	function processEntry(a_entryObject:Object, a_itemInfo:Object)
	{
		super.processEntry(a_entryObject, a_itemInfo);
		a_entryObject.infoValue = Math.round(a_itemInfo.value * _barterMult);
	}
}