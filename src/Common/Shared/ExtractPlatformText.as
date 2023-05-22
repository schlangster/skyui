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
		var i = 0; 					// Start at the beginning of the string
		var j = str.length - 1; 	// Start at the end of the string
		while(i < str.length)
		{
			if(Shared.ExtractPlatformText.IsWhitespace(str.charAt(i)) == false)
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
		// If there are no platform markers, all platforms will share the same text
		if(asText.indexOf("<<") < 0)
		{
			return asText;
		}

		// Determine the name of the platform we're looking for
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

		// Attempt to extract the text marked by the platformName
		var remainingText = asText;
		while(remainingText.length > 0)
		{
			// Look for the next platform marker
			var startMarker = remainingText.indexOf("<<");
			var endMarker = remainingText.indexOf(">>");

			// If ther are no platform markers, then we use the text for all platforms
			if(startMarker < 0 || endMarker < 0) {
				return remainingText;
			}

			// We located a platform marker...
			// What is the name of the platform we've located?
			var enclosedText = remainingText.substr(startMarker + 2,endMarker - startMarker - 2);
			remainingText = remainingText.substr(endMarker + 2);

			// Did we find the platform we're looking for?
			if(enclosedText == platformName)
			{
				var text = "";

				// Grab all the text up to the next platform marker
				var nextStartMarker = remainingText.indexOf("<<");

				if(nextStartMarker < 0)
					text = remainingText;
				else
					text = remainingText.substr(0, nextStartMarker);

				return Shared.ExtractPlatformText.Trim(text);
			}

			// We didn't find the platform we're looking for...
			// Does it look like there is another platform marker?
			// If not, whatever remaining text will be used as the text.
			// This means the very last piece of text is the default text
			var nextStartMarker = remainingText.indexOf("<<");
			if(nextStartMarker < 0)
			{
				return remainingText;
			}

			// There is more platform text left...
			// Prep for the next iteration by moving to the beginning of the next
			// platform marker
			remainingText = remainingText.substr(nextStartMarker);
			continue;
		}
	}
}
