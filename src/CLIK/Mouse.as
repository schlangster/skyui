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
	// static function getTopMostEntity(obj1:Object,obj2:Number,obj3:Boolean):Object;
	static function getTopMostEntity():Object;
}