import gfx.io.GameDelegate;

class Shared.ButtonTextArtHolder extends MovieClip
{
	var strButtonName: String;

	function ButtonTextArtHolder()
	{
		super();
	}

	function SetButtonName(aText: String): Void
	{
		strButtonName = aText;
	}

	function CreateButtonArt(aInputText): String
	{
		var iReplacerStart = aInputText.text.indexOf("[");
		var iReplacerEnd = iReplacerStart == -1 ? -1 : aInputText.text.indexOf("]", iReplacerStart);
		var strTextWithButtons = undefined;
		if (iReplacerStart != -1 && iReplacerEnd != -1) 
		{
			strTextWithButtons = aInputText.text.substr(0, iReplacerStart);
			while (iReplacerStart != -1 && iReplacerEnd != -1) 
			{
				var strButtonReplacer = aInputText.text.substring(iReplacerStart + 1, iReplacerEnd);
				GameDelegate.call("GetButtonFromUserEvent", [strButtonReplacer], this, "SetButtonName");
				if (strButtonName == undefined) 
				{
					strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerStart, iReplacerEnd + 1);
				}
				else 
				{
					var ButtonImage: flash.display.BitmapData = flash.display.BitmapData.loadBitmap(strButtonName + ".png");
					if (ButtonImage != undefined && ButtonImage.height > 0) 
					{
						var iMaxHeight: Number = 26;
						var iScaledWidth: Number = Math.floor(iMaxHeight / ButtonImage.height * ButtonImage.width);
						strTextWithButtons = strTextWithButtons + ("<img src=\'" + strButtonName + ".png\' vspace=\'-5\' height=\'" + iMaxHeight + "\' width=\'" + iScaledWidth + "\'>");
					}
					else 
					{
						strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerStart, iReplacerEnd + 1);
					}
				}
				var iReplacerStartNext = aInputText.text.indexOf("[", iReplacerEnd);
				var iReplacerEndNext = iReplacerStartNext == -1 ? -1 : aInputText.text.indexOf("]", iReplacerStartNext);
				if (iReplacerStartNext != -1 && iReplacerEndNext != -1) 
				{
					strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerEnd + 1, iReplacerStartNext);
				}
				else 
				{
					strTextWithButtons = strTextWithButtons + aInputText.text.substr(iReplacerEnd + 1);
				}
				iReplacerStart = iReplacerStartNext;
				iReplacerEnd = iReplacerEndNext;
			}
		}
		return strTextWithButtons;
	}

}
