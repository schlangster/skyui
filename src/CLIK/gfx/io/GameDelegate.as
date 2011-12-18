dynamic class gfx.io.GameDelegate
{
	static var responseHash = {};
	static var callBackHash = {};
	static var nextID: Number = 0;
	static var initialized: Boolean = false;

	function GameDelegate()
	{
	}

	static function call(methodName, params, scope, callBack)
	{
		if (!gfx.io.GameDelegate.initialized) 
		{
			gfx.io.GameDelegate.initialize();
		}
		var __reg1 = gfx.io.GameDelegate.nextID++;
		gfx.io.GameDelegate.responseHash[__reg1] = [scope, callBack];
		params.unshift(methodName, __reg1);
		flash.external.ExternalInterface.call.apply(null, params);
		delete gfx.io.GameDelegate.responseHash[__reg1];
	}

	static function receiveResponse(uid)
	{
		var __reg2 = gfx.io.GameDelegate.responseHash[uid];
		if (__reg2 != null) 
		{
			var __reg3 = __reg2[0];
			var __reg4 = __reg2[1];
			__reg3[__reg4].apply(__reg3, arguments.slice(1));
		}
	}

	static function addCallBack(methodName, scope, callBack)
	{
		if (!gfx.io.GameDelegate.initialized) 
		{
			gfx.io.GameDelegate.initialize();
		}
		gfx.io.GameDelegate.callBackHash[methodName] = [scope, callBack];
	}

	static function removeCallBack(methodName)
	{
		gfx.io.GameDelegate.callBackHash[methodName] = null;
	}

	static function receiveCall(methodName)
	{
		var __reg2 = gfx.io.GameDelegate.callBackHash[methodName];
		if (__reg2 != null) 
		{
			var __reg3 = __reg2[0];
			var __reg4 = __reg2[1];
			__reg3[__reg4].apply(__reg3, arguments.slice(1));
		}
	}

	static function initialize()
	{
		gfx.io.GameDelegate.initialized = true;
		flash.external.ExternalInterface.addCallback("call", gfx.io.GameDelegate, gfx.io.GameDelegate.receiveCall);
		flash.external.ExternalInterface.addCallback("respond", gfx.io.GameDelegate, gfx.io.GameDelegate.receiveResponse);
	}

}
