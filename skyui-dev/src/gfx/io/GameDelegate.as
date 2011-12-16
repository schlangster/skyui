//****************************************************************************
//  Best guess from GFX documentation.
//  https://developer.scaleform.com/doc/gfx/3.0/clik/gfx_io_GameDelegate.html
//****************************************************************************

import flash.external.ExternalInterface;

class gfx.io.GameDelegate {

	static var responseHash:Object = {};
	static var callBackHash:Object = {};
	static var nextID:Number = 0;
	static var initialized:Boolean = false;
	
	function GameDelegate() {}
	
	static function call(methodName:String, params:Array, scope:Object, callBack:String):Void {
		if (!initialized) { initialize(); }
		nextID = ++nextID;
		var thisID = nextID;
		responseHash[thisID] = [scope, callBack];
		params.unshift(methodName, thisID);
		flash.external.ExternalInterface.call.apply(null, params);
		delete responseHash[thisID];
	}
	
	static function receiveResponse(uid:Number):Void {
		var thisResponse = responseHash[uid];
		if (thisResponse == null) { return; }
		var scope = thisResponse[0];
		var callBack = thisResponse[1];
		scope[callBack].apply(scope, arguments.slice(1));
	}
	
	static function addCallBack(methodName:String, scope:Object, callBack:String):Void {
		if (!initialized) { initialize(); }
		callBackHash[methodName] = [scope, callBack];
	}
	
	static function removeCallBack(methodName:String):Void {
		callBackHash[methodName] = null;
	}
	
	static function receiveCall(methodName:String):Void {
		var thisCallBackHash = callBackHash[methodName];
		if (thisCallBackHash == null) { return; }
		var scope = thisCallBackHash[0];
		var callBack = thisCallBackHash[1];
		scope[callBack].apply(scope, arguments.slice(1));
	}
	
	static function initialize():Void {
		initialized = true;
		ExternalInterface.addCallback("call", GameDelegate, receiveCall);
		ExternalInterface.addCallback("respond", GameDelegate, receiveResponse);
	}
}
