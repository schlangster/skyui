// For now this is a just a simple associative array of required values
class skyui.props.ItemFilter
{	
	var reqs:Object;
	
	function ItemFilter(requirementsObj:Object)
	{
		setFromObject(requirementsObj);
	}
	
	function addRequirement(requiredProperty:String, requiredVal)
	{
		reqs[requiredProperty] = requiredVal;
	}
	
	function setFromArray(a:Array)
	{
		reqs = new Object();
		// Unzip ("a", "b", "c", "d") to {a:"b", c:"d"}
		for (var i:Number = 0; i + 1 < a.length; i = i + 2) {
			reqs[a[i]] = a[i + 1];
		}
	}

	function setFromObject(requirements:Object)
	{
		if (requirements instanceof Array) {
			setFromArray(Array(requirements));
		}
		else if (requirements instanceof Object) {
			reqs = requirements;
		}
		else {
			reqs = new Object();
		}
	}

	function passesFilter(objectToCheck:Object):Boolean
	{
		// Check if this object passes all the filter criteria
		for(var filterProperty:String in reqs) {
			if (objectToCheck[filterProperty] != reqs[filterProperty]) {
				return false;
			}
		}
		
		return true;
	}
}
