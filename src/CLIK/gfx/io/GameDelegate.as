import flash.external.ExternalInterface;

class gfx.io.GameDelegate
{
	static var responseHash = {};
	static var callBackHash = {};
	static var nextID = 0;
	static var initialized = false;
	
	function GameDelegate()
	{
	}
	
	static function call(methodName, params, scope, callBack)
	{
		if (!initialized)
		{
			initialize();
		}
		
		nextID = ++nextID;
		var _loc1 = nextID;
		responseHash[_loc1] = [scope, callBack];
		params.unshift(methodName, _loc1);
		ExternalInterface.call.apply(null, params);
		delete responseHash[_loc1];
	}
	
	static function receiveResponse(uid)
	{
		var _loc2 = responseHash[uid];
		if (_loc2 == null)
		{
			return;
		} // end if
		var _loc3 = _loc2[0];
		var _loc4 = _loc2[1];
		_loc3[_loc4].apply(_loc3, arguments.slice(1));
	}
	
	static function addCallBack(methodName, scope, callBack)
	{
		if (!initialized)
		{
			initialize();
		} // end if
		callBackHash[methodName] = [scope, callBack];
	}
	
	static function removeCallBack(methodName)
	{
		callBackHash[methodName] = null;
	}
	
	static function receiveCall(methodName)
	{
		var _loc2 = callBackHash[methodName];
		if (_loc2 == null)
		{
			return;
		}
		var _loc3 = _loc2[0];
		var _loc4 = _loc2[1];
		_loc3[_loc4].apply(_loc3, arguments.slice(1));
	}
	
	static function initialize()
	{
		initialized = true;
		ExternalInterface.addCallback("call", GameDelegate, receiveCall);
		ExternalInterface.addCallback("respond", GameDelegate, receiveResponse);
	}
}
