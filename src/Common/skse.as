intrinsic class skse
{
	static var kDevice_Keyboard: Number = 0;
	static var kDevice_Mouse: Number = 1;
	static var kDevice_Gamepad: Number = 2;
	
	static var kContext_Gameplay = 0;
	static var kContext_MenuMode = 1;
	static var kContext_Console = 2;
	static var kContext_ItemMenu = 3;
	static var kContext_Inventory = 4;
	static var kContext_DebugText = 5;
	static var kContext_Favorites = 6;
	static var kContext_Map = 7;
	static var kContext_Stats = 8;
	static var kContext_Cursor = 9;
	static var kContext_Book = 10;
	static var kContext_DebugOverlay = 11;
	static var kContext_Journal = 12;
	static var kContext_TFCMode = 13;
	static var kContext_MapDebug = 14;
	static var kContext_Lockpicking = 15;
	static var kContext_Favor = 16;
	
	static function Log(a_string:String):Void;
	static function AllowTextInput(a_flag:Boolean):Void;
	static function GetMappedKey(a_name:String, a_deviceType: Number, a_context: Number):Number;
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