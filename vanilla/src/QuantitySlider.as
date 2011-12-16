import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class QuantitySlider extends gfx.controls.Slider
{
    function QuantitySlider()
    {
        super();
    }
    
    function handleInput(details, pathToFocus)
    {
        var _loc4 = super.handleInput(details, pathToFocus);
        
        if (!_loc4)
        {
            if (GlobalFunc.IsKeyPressed(details))
            {
                if (details.navEquivalent == NavigationCode.PAGE_DOWN || details.navEquivalent == NavigationCode.GAMEPAD_L1)
                {
                    value = Math.floor(value - maximum / 4);
                    dispatchEvent({type: "change"});
                    _loc4 = true;
                }
                else if (details.navEquivalent == NavigationCode.PAGE_UP || details.navEquivalent == NavigationCode.GAMEPAD_R1)
                {
                    value = Math.ceil(value + maximum / 4);
                    dispatchEvent({type: "change"});
                    _loc4 = true;
                }
            }
        }
        return (_loc4);
    }
} 
