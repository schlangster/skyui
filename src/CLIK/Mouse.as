//****************************************************************************
// ActionScript Standard Library
// Mouse object
//****************************************************************************

intrinsic class Mouse
{
	static function addListener(listener:Object):Void;
	static function hide():Number;
	static function removeListener(listener:Object):Boolean;
	static function show():Number;
	
	// scaleform extensions
	static function getTopMostEntity(arg1:Object,arg2:Number,arg3:Boolean):Object;
}