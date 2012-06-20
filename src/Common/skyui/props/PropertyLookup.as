import skyui.props.ItemFilter;

class skyui.props.PropertyLookup
{
	private static var dataMemberLimit = 200;
	private static var _delimiter = ";;";
	
	var propertiesToSet:Array;
	var itemFilter:ItemFilter;
	var defaultValues;
	var overwrite:Boolean;

	private var lastValue:Number = -1;
	private var keywords:Object;
	private var dataMembers:Object;

	// Expects an object set by reading the config file with the following information provided
	// propertiesToSet the property names that may be set
	// itemFilter will determine which objects should try to match against this list
	// defaultValues: if defined then if no data match this value will be set on the propertyToSet
	// overwrite: if true then set propertyToSet even if it already has a known value set
	// keywords: keyword to match against and the values to set if matched.
	// dataMember#: Filter to specify what to match and set object for properties to set when matched
	function PropertyLookup(configObject:Object)
	{
		this.propertiesToSet = configObject.propertiesToSet; //TODO: eventually determine this automatically?
		this.itemFilter = new ItemFilter(configObject.filter);
		this.defaultValues = configObject.defaultValues;
		this.overwrite = configObject.overwrite;
		this.keywords = configObject.keywords;
		this._parseDataMemberList(configObject);
		
		this.lastValue = -1;
	}
	
	private function _getPropertyValFromFilter(filter:Object):Array
	{		
		var numDataMembers:Number = 0;
		var dataMembers:Array = new Array();
		for (var dataMember:String in filter) {
			dataMembers.push(dataMember);
			numDataMembers++;
		}
		
		if (numDataMembers <= 0) {
			return new Array("extended", 'true');
		}
		else if (numDataMembers == 1) {
			return new Array(dataMembers[0], filter[dataMembers[0]]);
		}

		// else numDataMembers > 1
		dataMembers.sort();
		var dataMember:String = dataMembers.join(PropertyLookup._delimiter);
		var valueArray:Array = new Array();
		for (var i:Number = 0; i < numDataMembers; i++) {
			valueArray.push(filter[dataMembers[i]]);
		}
		var matchVal:String = valueArray.join(PropertyLookup._delimiter);
		
		return new Array(dataMember, matchVal);
		
	}
	
	private function _parseDataMemberList(configObject:Object)
	{
		dataMembers = new Object();
		
		var dataMemberGroupObj:Object;
		for (var i:Number = 1; i < PropertyLookup.dataMemberLimit; i++) {
			var dataMemberGroup:String = "dataMember" + i;
			
			if (configObject[dataMemberGroup] == undefined) {
				// No more dataMember# to go through (they must be sequential)
				break;
			}

			dataMemberGroupObj = configObject[dataMemberGroup];  //dataMember1 etc
			
			var filter:Object = dataMemberGroupObj["filter"];
			
			// get keyValue for formId, subType etc in dataMember#
			var keyValue:Array = _getPropertyValFromFilter(filter);
			
			var dataMember:String = keyValue[0];
			var matchVal = keyValue[1];
			
			// create object for this dataMember (formId etc) if it does not exist.
			if (this.dataMembers[dataMember] == undefined) {
				this.dataMembers[dataMember] = new Object();
			}
			
			this.dataMembers[dataMember][matchVal] = dataMemberGroupObj["set"];
		}
	}

	function getKeywordValues(keyword:String)
	{
		return keywords[keyword];
	}

	function getDataMemberValues(dataMember:String, sourceValue)
	{
		return dataMembers[dataMember][sourceValue];
	}
	
	function keywordMatches(keyword:String)
	{
		return (keywords[keyword] != undefined);
	}
	
	function dataMemberMatches(keyword:String, sourceValue)
	{
		return (dataMembers[keyword][sourceValue] != undefined);
	}
	
	private function _getMultSourceVal(obj:Object, dataMember:String)
	{
		var dataMembers:Array = dataMember.split(PropertyLookup._delimiter);
		if (dataMembers.length <= 0) {
			// Shouldn't occur, just return undefined
			return;
		}
		else if (dataMembers.length == 1) {
			// only a single dataMember, simply try to get the value of it on obj
			return obj[dataMember];
		}
		
		// else dataMembers.length > 1
		var valueArray:Array = new Array();
		for (var i:Number = 0; i < dataMembers.length; i++) {
			if (obj.hasOwnProperty(dataMembers[i])) {
				valueArray.push(obj[dataMembers[i]]);
			}
			else {
				// Missing a dataMember, return undefined
				return;
			}
		}
		return valueArray.join(PropertyLookup._delimiter);
		
	}
	
	function processProperty(obj:Object):Boolean
	{
		// Check if this object passes the filter for this keyword search
		if (!itemFilter.passesFilter(obj)) {
			return false;
		}
		
		// Overwrite is handled below anyway and without this we won't need propertiesToSet
		// Otherwise we should detemine propertiesToSet ourself
		/*
		// Unless this.overwrite is true
		// return if this object already has the all properties set to a known value
		if (!this.overwrite) {
			var allPropertiesSet:Boolean = true;
			for (var propertyToSet:String in this.propertiesToSet) {
				if (obj[propertyToSet] == undefined ||
					obj[propertyToSet] == this.defaultValues[propertyToSet]) {
					allPropertiesSet = false;
				}
			}
			if (allPropertiesSet) {
				// Nothing needs to be set and we haven't set a value, return false
				return false;
			}
		}
		*/
		
		var isValueSet:Boolean = false;
		
		// search for each keyword on the object (rather than each keyword to search against which is likely more)
		// if found then set the propertyToSet property to the corresponding destination value
		var val;
		for(var keyword in obj.keywords) {
			var keywordValues:Object = this.getKeywordValues(keyword);
			if (keywordValues != undefined) {
				// keyword match found
				for (var propertyToSet:String in keywordValues) {
					val = keywordValues[propertyToSet];
					if (val != undefined && (this.overwrite || obj[propertyToSet] == undefined ||
											 obj[propertyToSet] == this.defaultValues[propertyToSet])) {
						obj[propertyToSet] = val;
						isValueSet = true;
					}
				}
				// NOTE: Right now we will continue on to see if there is a data member match
				//       but keywords take priority
				// NOTE: Right now we don't check any other keywords once we find a match,
				//       even if we didn't set a value.
				break;
			}
		}	
		
		// For each dataMember such as 'subType' that we need to check
		// Check if we have stored a dataMember with a matching required value and if so use
		// setVal from it to set propertyToSet
		
		for(var dataMember in this.dataMembers) {
			//var sourceValue = obj[dataMember];
			var sourceValue = _getMultSourceVal(obj, dataMember);
			if (sourceValue == undefined) {
				continue;
			}
			
			var setValues:Object = this.getDataMemberValues(dataMember, sourceValue);
			if (setValues != undefined) {
				// we have a match
				for (var propertyToSet:String in setValues){
					var val = setValues[propertyToSet];
					if (val != undefined && (this.overwrite || obj[propertyToSet] == undefined ||
											 obj[propertyToSet] == this.defaultValues[propertyToSet])) {
						obj[propertyToSet] = val;
						isValueSet = true;
					}
		
				}
				// NOTE: Right now we continue on to set any remaining defaults.
				// NOTE: Right now we don't continue on to any other data members once we find a match.
				break;
			}
		}

		// Set defaults
		var valueSet:Boolean = false;
		for (var propertyToDefault:String in this.defaultValues) {
			if (obj[propertyToDefault] == undefined && this.defaultValues[propertyToDefault] != undefined) {
				obj[propertyToDefault] = this.defaultValues[propertyToDefault];
				valueSet = true;
			}
		}

		return valueSet;
	}
}