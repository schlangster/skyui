dynamic class gfx.data.DataProvider extends Array
{
	var isDataProvider: Boolean = true;
	var cleanUpEvents;
	var dispatchEvent;
	var length;
	var slice;
	var splice;

	function DataProvider(total)
	{
		super();
		gfx.events.EventDispatcher.initialize(this);
	}

	static function initialize(data)
	{
		if (gfx.data.DataProvider.instance == undefined) 
		{
			gfx.data.DataProvider.instance = new gfx.data.DataProvider();
		}
		var __reg3 = ["indexOf", "requestItemAt", "requestItemRange", "invalidate", "toString", "cleanUp", "isDataProvider"];
		var __reg2 = 0;
		while (__reg2 < __reg3.length) 
		{
			data[__reg3[__reg2]] = gfx.data.DataProvider.instance[__reg3[__reg2]];
			++__reg2;
		}
		gfx.events.EventDispatcher.initialize(data);
		_global.ASSetPropFlags(data, __reg3, 1);
		_global.ASSetPropFlags(data, "addEventListener,removeEventListener,hasEventListener,removeAllEventListeners,dispatchEvent,dispatchQueue,cleanUpEvents", 1);
	}

	function indexOf(value, scope, callBack)
	{
		var __reg2 = 0;
		__reg2 = 0;
		while (__reg2 < this.length) 
		{
			if (this[__reg2] == value) 
			{
				break;
			}
			++__reg2;
		}
		var __reg4 = __reg2 == this.length ? -1 : __reg2;
		if (callBack) 
		{
			scope[callBack].call(scope, __reg4);
		}
		return __reg4;
	}

	function requestItemAt(index, scope, callBack)
	{
		var __reg2 = this[index];
		if (callBack) 
		{
			scope[callBack].call(scope, __reg2);
		}
		return __reg2;
	}

	function requestItemRange(startIndex, endIndex, scope, callBack)
	{
		var __reg2 = this.slice(startIndex, endIndex + 1);
		if (callBack) 
		{
			scope[callBack].call(scope, __reg2);
		}
		return __reg2;
	}

	function invalidate(length)
	{
		this.dispatchEvent({type: "change"});
	}

	function cleanUp()
	{
		this.splice(0, this.length);
		this.cleanUpEvents();
	}

	function toString()
	{
		return "[DataProvider (" + this.length + ")]";
	}

}
