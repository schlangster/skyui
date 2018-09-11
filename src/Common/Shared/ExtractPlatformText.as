class Shared.ExtractPlatformText
{
   function ExtractPlatformText()
   {
   }
   static function IsWhitespace(str)
   {
      return str == " " || str == "\n" || str == "\r";
   }
   static function Trim(str)
   {
      var i = undefined;
      var j = undefined;
      i = 0;
      j = str.length - 1;
      while(i < str.length)
      {
         if(Shared.ExtractPlatformText.IsWhitespace(str.charAt(i) == false))
         {
            break;
         }
         i++;
      }
      j = str.length - 1;
      while(j >= 0)
      {
         if(Shared.ExtractPlatformText.IsWhitespace(str.charAt(j)) == false)
         {
            break;
         }
         j--;
      }
      return str.substr(i, j - i + 1);
   }

   // This looks to be processing a long string that looks like:
   // <<PlatformName <<string>>>> <<PlatformName <<string>>>>
   // The function takes this string and returns string text associated with 'aiPlatform'
   static function Extract(asText, aiPlatform)
   {
      if(asText.indexOf("<<") < 0)
      {
         return asText;
      }
      var platformName = undefined;
      switch(aiPlatform)
      {
         case Shared.Platforms.CONTROLLER_PCGAMEPAD:
            platformName = "PCGAMEPAD";
            break;
         case Shared.Platforms.CONTROLLER_VIVE:
            platformName = "VIVE";
            break;
         case Shared.Platforms.CONTROLLER_OCULUS:
            platformName = "OCULUS";
            break;
         case Shared.Platforms.CONTROLLER_WINDOWS_MR:
            platformName = "WINDOWS_MR";
            break;
         case Shared.Platforms.CONTROLLER_ORBIS_MOVE:
            platformName = "ORBIS_MOVE";
            break;
         case Shared.Platforms.CONTROLLER_ORBIS:
            platformName = "ORBIS";
            break;
         default:
            return asText;
      }
      var remainingText = asText;
      while(remainingText.length > 0)
      {
         var startMarker = remainingText.indexOf("<<");
         var endMarker = remainingText.indexOf(">>");
         if(startMarker >= 0 && endMarker >= 0)
         {
            var enclosedText = remainingText.substr(startMarker + 2,endMarker - startMarker - 2);
            remainingText = remainingText.substr(endMarker + 2);
            if(enclosedText == platformName)
            {
               var keepProcessing = true;
               while(keepProcessing)
               {
                  var nextStartMarker = remainingText.indexOf("<<");
                  if(nextStartMarker < 0)
                  {
                     break;
                  }
                  var i = 0;
                  while(i < nextStartMarker)
                  {
                     if(Shared.ExtractPlatformText.IsWhitespace(remainingText.charAt(i)) == false)
                     {
                        keepProcessing = false;
                        break;
                     }
                     i++;
                  }
                  if(keepProcessing)
                  {
                     var nextEndMarker = remainingText.indexOf(">>");
                     remainingText = remainingText.substr(nextEndMarker + 2);
                  }
               }
               return Shared.ExtractPlatformText.Trim(remainingText);
            }
            endMarker = remainingText.indexOf("<<");
            if(endMarker < 0)
            {
               return asText;
            }
            remainingText = remainingText.substr(endMarker);
            continue;
         }
         return asText;
      }
   }
}
