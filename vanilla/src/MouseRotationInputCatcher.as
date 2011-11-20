class MouseRotationInputCatcher extends MovieClip
{
	static var PROCESS_ROTATION_DELAY = 150;
	
	var iProcessRotationDelayTimerID;
	
    function MouseRotationInputCatcher()
    {
        super();
    }
	
    function onMouseDown()
    {
        var _loc2 = Mouse.getTopMostEntity() == this;
        if (_loc2 || _parent.bFadedIn == false)
        {
            _parent.onMouseRotationStart();
        } // end if
        if (_loc2 && iProcessRotationDelayTimerID == undefined)
        {
            iProcessRotationDelayTimerID = setInterval(this, "onProcessDelayElapsed", PROCESS_ROTATION_DELAY);
        } // end if
    }
	
    function onProcessDelayElapsed()
    {
        clearInterval(iProcessRotationDelayTimerID);
        iProcessRotationDelayTimerID = undefined;
    }
	
    function onMouseUp()
    {
        _parent.onMouseRotationStop();
        clearInterval(iProcessRotationDelayTimerID);
        if (iProcessRotationDelayTimerID != undefined && _parent.bFadedIn != false)
        {
            _parent.onMouseRotationFastClick(0);
        } // end if
        iProcessRotationDelayTimerID = undefined;
    }
	
    function onPressAux()
    {
        _parent.onMouseRotationFastClick(1);
    }
} // End of Class
