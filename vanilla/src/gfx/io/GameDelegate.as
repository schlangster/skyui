

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
        if (!gfx.io.GameDelegate.initialized)
        {
            gfx.io.GameDelegate.initialize();
        } // end if
        nextID = ++gfx.io.GameDelegate.nextID;
        var _loc1 = gfx.io.GameDelegate.nextID;
        gfx.io.GameDelegate.responseHash[_loc1] = [scope, callBack];
        params.unshift(methodName, _loc1);
        flash.external.ExternalInterface.call.apply(null, params);
        delete gfx.io.GameDelegate.responseHash[_loc1];
    }
	
    static function receiveResponse(uid)
    {
        var _loc2 = gfx.io.GameDelegate.responseHash[uid];
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
        if (!gfx.io.GameDelegate.initialized)
        {
            gfx.io.GameDelegate.initialize();
        } // end if
        gfx.io.GameDelegate.callBackHash[methodName] = [scope, callBack];
    }
	
    static function removeCallBack(methodName)
    {
        gfx.io.GameDelegate.callBackHash[methodName] = null;
    }
	
    static function receiveCall(methodName)
    {
        var _loc2 = gfx.io.GameDelegate.callBackHash[methodName];
        if (_loc2 == null)
        {
            return;
        } // end if
        var _loc3 = _loc2[0];
        var _loc4 = _loc2[1];
        _loc3[_loc4].apply(_loc3, arguments.slice(1));
    }
	
    static function initialize()
    {
        initialized = true;
        flash.external.ExternalInterface.addCallback("call", gfx.io.GameDelegate, gfx.io.GameDelegate.receiveCall);
        flash.external.ExternalInterface.addCallback("respond", gfx.io.GameDelegate, gfx.io.GameDelegate.receiveResponse);
    }
}
