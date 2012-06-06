import skyui.props.ItemFilter;

// Combine multiple properties into one property (used for flexible sorting)
class skyui.props.CompoundProperty
{	
	var propertyToSet:String;
	var itemFilter:ItemFilter;
	var defaultValues:Array;
	var padString:String;
	var numPadding:Number;
	var overwrite:Boolean;

	var propertyList:Array;
	
	function CompoundProperty(configObject:Object)
	{
		propertyToSet = configObject.propertyToSet;
		itemFilter = new ItemFilter(configObject.filter);
		defaultValues = configObject.defaultValues;

		padString = configObject.padString;
		if (padString == undefined) {
			padString = "0";
		}
		numPadding = configObject.numPadding;
		if (numPadding == undefined) {
			numPadding = 3;
		}
		overwrite = configObject.overwrite;
		if (overwrite == undefined) {
			overwrite = false;
		}

		propertyList = configObject.concatenateList;
	}

	private function _padString(_str:String, _n:Number, _pStr:String)
	{
		var _rtn:String = _str;
		if ((_pStr == undefined) || (_pStr == null) || (_pStr.length < 1))
		{
			_pStr = " ";
		}
		
		if (_str.length < _n)
		{
			var _s:String = "";
			for (var i:Number = 0 ; i < (_n - _str.length) ; i++)
			{
				_s += _pStr;
			}
			_rtn = _s + _str;
		}
		
		return _rtn;
	}
	
	
	function processCompoundProperty(obj:Object):Boolean
	{
		if(!itemFilter.passesFilter(obj)) {
			return false;
		}

		// Unless this.overwrite is true
		// return if this object already has the property set to a known value
		if ((!this.overwrite && obj[this.propertyToSet] != undefined && 
			 obj[propertyToSet] != this.defaultValues[propertyToSet])) {
			return false;
		}
		
		var compoundValue:String = "";
		for(var i:Number = 0; i < this.propertyList.length; i++)
		{
			var currProp:String = propertyList[i];
			var currVal:String = String(this.defaultValues[currProp]);
			if (obj.hasOwnProperty(currProp) && obj[currProp] != undefined && obj[currProp] != "") {
				currVal = String(obj[currProp]);
			}
			compoundValue += this._padString(currVal, this.numPadding, this.padString);
		}
		
		if (compoundValue == "" && this.defaultValues[this.propertyToSet]) {
			compoundValue = this.defaultValues[this.propertyToSet];
		}
		
		obj[this.propertyToSet] = compoundValue;
		return true;
	}
}
