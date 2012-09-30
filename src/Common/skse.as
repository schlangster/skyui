intrinsic class skse
{
	static function Log(a_string:String):Void;
	static function AllowTextInput(a_flag:Boolean):Void;
	static function GetMappedKey(a_name:String, a_deviceType: Number, a_context: Number):Number;
	static function StartRemapMode(a_scope:Object):Void;
	static function SetINISetting(a_key:String, a_value:Number):Void;
	static function GetINISetting(a_key:String):Number;
	static function OpenMenu(a_menu:String):Void;
	static function CloseMenu(a_menu:String):Void;
	static function ExtendData(enable:Boolean):Void;
	static function ForceContainerCategorization(enable:Boolean):Void;	
	static function SendModEvent(a_eventName:String, a_strArg:String, a_numArg:Number):Void;
	static function RequestActivePlayerEffects(a_list:Array):Void;
	static function ExtendForm(a_formid:Number, a_object:Object, a_extraData:Boolean, a_recursive:Boolean):Void;
}