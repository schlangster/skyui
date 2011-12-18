//****************************************************************************
// ActionScript Standard Library
// Selection control
//****************************************************************************

intrinsic class Selection
{
	static function addListener(listener:Object):Void;
	static function getBeginIndex():Number;
	static function getCaretIndex():Number;
	static function getEndIndex():Number;
	static function getFocus():String;
	static function removeListener(listener:Object):Boolean;
	static function setFocus(newFocus:Object):Boolean; // newFocus can be string path or Object itself
	static function setSelection(beginIndex:Number, endIndex:Number):Void;
	
	// scaleform extensions
	
	static var alwaysEnableArrowKeys:Boolean;
	static var disableFocusAutoRelease:Boolean;
	static var disableFocusKeys:Boolean;
	static var disableFocusRolloverEvent:Boolean;
	static var numFocusGroups:Number;
	static var alwaysEnableKeyboardPress:Boolean;
	static function getControllerMaskByFocusGroup(arg1:Number):Number;
	static function getControllerFocusGroup(arg1:Number):Number;
	static function findFocus(arg1:String, arg2:Object, arg3:Boolean, arg4:Object, arg5:Boolean, arg6:Number):Object;
	static function getFocusBitmask(arg1:Object):Number;
}