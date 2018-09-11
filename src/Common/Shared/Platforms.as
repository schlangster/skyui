class Shared.Platforms
{
   static var CONTROLLER_PC = 0;
   static var CONTROLLER_PCGAMEPAD = 1;
   static var CONTROLLER_DURANGO = 2;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_VIVE = 4;
   static var CONTROLLER_ORBIS_MOVE = 5;
   static var CONTROLLER_OCULUS = 6;
   static var CONTROLLER_VIVE_KNUCKLES = 7;
   static var CONTROLLER_WINDOWS_MR = 8;
   function Platforms()
   {
   }
   static function IsUsingWands(aiPlatform)
   {
      return 	aiPlatform == CONTROLLER_VIVE ||
      				aiPlatform == CONTROLLER_VIVE_KNUCKLES ||
      				aiPlatform == CONTROLLER_ORBIS_MOVE ||
      				aiPlatform == CONTROLLER_OCULUS ||
      				aiPlatform == CONTROLLER_WINDOWS_MR;
   }
   static function IsUsingController(aiPlatform)
   {
      return aiPlatform == Shared.Platforms.CONTROLLER_PCGAMEPAD || aiPlatform == Shared.Platforms.CONTROLLER_ORBIS;
   }
}
