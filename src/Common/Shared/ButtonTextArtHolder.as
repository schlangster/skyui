import gfx.io.GameDelegate;
import flash.display.BitmapData;

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

	function CreateButtonArt(aInputText: TextField): String
	{
		var iReplacerStart: Number = aInputText.text.indexOf("[");
		var iReplacerEnd: Number = iReplacerStart == -1 ? -1 : aInputText.text.indexOf("]", iReplacerStart);
		var strTextWithButtons = undefined;
		if (iReplacerStart != -1 && iReplacerEnd != -1) {
			strTextWithButtons = aInputText.text.substr(0, iReplacerStart);
			while (iReplacerStart != -1 && iReplacerEnd != -1) {
				var strButtonReplacer: String = aInputText.text.substring(iReplacerStart + 1, iReplacerEnd);
				GameDelegate.call("GetButtonFromUserEvent", [strButtonReplacer], this, "SetButtonName");
				
				if (strButtonName == undefined) {
					strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerStart, iReplacerEnd + 1);
				} else {
					var ButtonImage: BitmapData = BitmapData.loadBitmap(strButtonName + ".png");
					if (ButtonImage != undefined && ButtonImage.height > 0) {
						var iMaxHeight: Number = 26;
						var iScaledWidth: Number = Math.floor(iMaxHeight / ButtonImage.height * ButtonImage.width);
						strTextWithButtons = strTextWithButtons + ("<img src=\'" + strButtonName + ".png\' vspace=\'-5\' height=\'" + iMaxHeight + "\' width=\'" + iScaledWidth + "\'>");
					} else 	{
						strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerStart, iReplacerEnd + 1);
					}
				}
				
				var iReplacerStartNext: Number = aInputText.text.indexOf("[", iReplacerEnd);
				var iReplacerEndNext: Number = iReplacerStartNext == -1 ? -1 : aInputText.text.indexOf("]", iReplacerStartNext);
				
				if (iReplacerStartNext != -1 && iReplacerEndNext != -1)
					strTextWithButtons = strTextWithButtons + aInputText.text.substring(iReplacerEnd + 1, iReplacerStartNext);
				else 
					strTextWithButtons = strTextWithButtons + aInputText.text.substr(iReplacerEnd + 1);
					
				iReplacerStart = iReplacerStartNext;
				iReplacerEnd = iReplacerEndNext;
			}
		}
		return strTextWithButtons;
	}

}
