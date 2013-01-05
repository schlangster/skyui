import skyui.props.ItemFilter;

class skyui.props.PropertyLookup
{
	private static var dataMemberLimit = 200;
	private static var _delimiter = ";;";
	
	var propertiesToSet:Array;
	var itemFilter:ItemFilter;
	var defaultValues;

	private var lastValue:Number = -1;
	private var keywords:Object;
	private var dataMembers:Object;

	// Expects an object set by reading the config file with the following information provided
	// propertiesToSet the property names that may be set
	// itemFilter will determine which objects should try to match against this list
	// defaultValues: if defined then if no data match this value will be set on the propertyToSet
	// keywords: keyword to match against and the values to set if matched.
	// dataMember#: Filter to specify what to match and set object for properties to set when matched
	function PropertyLookup(a_configObject: Object)
	{
		propertiesToSet = a_configObject.propertiesToSet; //TODO: eventually determine this automatically?
		itemFilter = new ItemFilter(a_configObject.filter);
		defaultValues = a_configObject.defaultValues;
		keywords = a_configObject.keywords;
		_parseDataMemberList(a_configObject);
		
		lastValue = -1;
	}
	
	private function _getPropertyValFromFilter(a_filter: Object):Array
	{		
		var numDataMembers:Number = 0;
		var dataMembers:Array = new Array();
		for (var dataMember:String in a_filter) {
			dataMembers.push(dataMember);
			numDataMembers++;
		}
		
		if (numDataMembers <= 0) {
			return new Array("extended", "true");
		} else if (numDataMembers == 1) {
			return new Array(dataMembers[0], a_filter[dataMembers[0]]);
		}

		// else numDataMembers > 1
		dataMembers.sort();
		var dataMember:String = dataMembers.join(PropertyLookup._delimiter);
		var valueArray:Array = new Array();
		for (var i:Number = 0; i < numDataMembers; i++) {
			valueArray.push(a_filter[dataMembers[i]]);
		}
		var matchVal:String = valueArray.join(PropertyLookup._delimiter);
		
		return new Array(dataMember, matchVal);
		
	}
	
	private function _parseDataMemberList(a_configObject: Object): Void
	{
		dataMembers = new Object();
		
		var dataMemberGroupObj:Object;
		for (var i:Number = 1; i < PropertyLookup.dataMemberLimit; i++) {
			var dataMemberGroup:String = "dataMember" + i;
			
			if (a_configObject[dataMemberGroup] == undefined) {
				// No more dataMember# to go through (they must be sequential)
				break;
			}

			dataMemberGroupObj = a_configObject[dataMemberGroup];  //dataMember1 etc
			
			var filter:Object = dataMemberGroupObj["filter"];
			
			// get keyValue for formId, subType etc in dataMember#
			var keyValue:Array = _getPropertyValFromFilter(filter);
			
			var dataMember:String = keyValue[0];
			var matchVal = keyValue[1];
			
			// create object for this dataMember (formId etc) if it does not exist.
			if (dataMembers[dataMember] == undefined) {
				dataMembers[dataMember] = new Object();
			}
			
			dataMembers[dataMember][matchVal] = dataMemberGroupObj["set"];
		}
	}

	function getKeywordValues(a_keyword: String)
	{
		return keywords[a_keyword];
	}

	function getDataMemberValues(a_dataMember: String, a_sourceValue)
	{
		return dataMembers[a_dataMember][a_sourceValue];
	}
	
	function keywordMatches(a_keyword: String)
	{
		return (keywords[a_keyword] != undefined);
	}
	
	function dataMemberMatches(keyword:String, sourceValue)
	{
		return (dataMembers[keyword][sourceValue] != undefined);
	}
	
	private function _getMultSourceVal(a_object: Object, a_dataMember: String)
	{
		var dataMembers:Array = a_dataMember.split(PropertyLookup._delimiter);
		if (dataMembers.length <= 0) {
			// Shouldn't occur, just return undefined
			return;
		}
		else if (dataMembers.length == 1) {
			// only a single dataMember, simply try to get the value of it on a_object
			return a_object[a_dataMember] ;
		}
		
		// else dataMembers.length > 1
		var valueArray:Array = new Array();
		for (var i:Number = 0; i < dataMembers.length; i++) {
			if (a_object.hasOwnProperty(dataMembers[i])) {
				valueArray.push(a_object[dataMembers[i]]);
			}
			else {
				// Missing a dataMember, return undefined
				return;
			}
		}
		return valueArray.join(PropertyLookup._delimiter);
		
	}
	
	function processProperty(a_obj: Object): Void
	{
		// Check if this object passes the filter for this keyword search
		if (!itemFilter.passesFilter(a_obj))
			return;

		// Set defaults
		for (var propertyToDefault:String in defaultValues) {
			if (defaultValues[propertyToDefault] != undefined) {
				a_obj[propertyToDefault] = defaultValues[propertyToDefault];
			}
		}

		var valToSet;

		// Check for keywords
		for(var keyword in a_obj.keywords) {
			var keywordValues: Object = getKeywordValues(keyword);
			if (keywordValues != undefined) {
				// keyword match found
				for (var propertyToSet:String in keywordValues) {
					valToSet = keywordValues[propertyToSet];
					// Don't bother setting if default value is already set
					if (valToSet != undefined && valToSet != defaultValues[propertyToSet]) {
						a_obj[propertyToSet] = valToSet;
					}
				}
				break;
			}
		}

		// Check data members last, they take precedence (for example, matching baseID)
		for(var dataMember in dataMembers) {
			//var sourceValue = a_obj[dataMember];
			var sourceValue = _getMultSourceVal(a_obj, dataMember);
			if (sourceValue == undefined)
				continue;
			
			var setValues: Object = getDataMemberValues(dataMember, sourceValue);
			if (setValues != undefined) {
				// we have a match
				for (var propertyToSet:String in setValues){
					var valToSet = setValues[propertyToSet];
					if (valToSet != undefined && valToSet != defaultValues[propertyToSet]) {
						a_obj[propertyToSet] = valToSet;
					}
		
				}

				break;
			}
		}
	}
}