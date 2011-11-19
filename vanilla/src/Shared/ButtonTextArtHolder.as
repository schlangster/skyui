class Shared.ButtonTextArtHolder extends MovieClip
{
    var strButtonName:String;
	
    function ButtonTextArtHolder()
    {
        super();
    }
	
    function SetButtonName(aText)
    {
        strButtonName = aText;
    }
	
    function CreateButtonArt(aInputText)
    {
        var startIndex = aInputText.text.indexOf("[");
        var len = startIndex != -1 ? (aInputText.text.indexOf("]", startIndex)) : (-1);
        var _loc7;
        if (startIndex != -1 && len != -1)
        {
            _loc7 = aInputText.text.substr(0, startIndex);
            while (startIndex != -1 && len != -1)
            {
                var _loc10 = aInputText.text.substring(startIndex + 1, len);
                gfx.io.GameDelegate.call("GetButtonFromUserEvent", [_loc10], this, "SetButtonName");
                if (strButtonName != undefined)
                {
                    var _loc6 = flash.display.BitmapData.loadBitmap(strButtonName + ".png");
                    if (_loc6 != undefined && _loc6.height > 0)
                    {
                        var _loc8 = 26;
                        var _loc11 = Math.floor(_loc8 / _loc6.height * _loc6.width);
                        _loc7 = _loc7 + ("<img src=\'" + strButtonName + ".png\' vspace=\'-5\' height=\'" + _loc8 + "\' width=\'" + _loc11 + "\'>");
                    }
                    else
                    {
                        _loc7 = _loc7 + " " + strButtonName + " " + aInputText.text.substring(startIndex, len + 1);
                    }
                }
                else
                {
                    _loc7 = _loc7 + aInputText.text.substring(startIndex, len + 1);
                }
				
                var _loc4 = aInputText.text.indexOf("[", len);
                var _loc9 = _loc4 != -1 ? (aInputText.text.indexOf("]", _loc4)) : (-1);
				
                if (_loc4 != -1 && _loc9 != -1)
                {
                    _loc7 = _loc7 + aInputText.text.substring(len + 1, _loc4);
                }
                else
                {
                    _loc7 = _loc7 + aInputText.text.substr(len + 1);
                }
				
                startIndex = _loc4;
                len = _loc9;
            }
        }
        return (_loc7);
    }
}
