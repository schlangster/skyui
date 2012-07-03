class MouseRotationInputCatcher extends MovieClip
{
	static var PROCESS_ROTATION_DELAY: Number = 150;
	
	var iProcessRotationDelayTimerID: Number;

	function MouseRotationInputCatcher()
	{
		super();
	}

	function onMouseDown(): Void
	{
		var topMostEntity: Boolean = Mouse.getTopMostEntity() == this;
		if (topMostEntity || _parent.bFadedIn == false) 
			_parent.onMouseRotationStart();
		if (topMostEntity && iProcessRotationDelayTimerID == undefined) 
			iProcessRotationDelayTimerID = setInterval(this, "onProcessDelayElapsed", MouseRotationInputCatcher.PROCESS_ROTATION_DELAY);
	}

	function onProcessDelayElapsed(): Void
	{
		clearInterval(iProcessRotationDelayTimerID);
		iProcessRotationDelayTimerID = undefined;
	}

	function onMouseUp(): Void
	{
		_parent.onMouseRotationStop();
		clearInterval(iProcessRotationDelayTimerID);
		if (iProcessRotationDelayTimerID != undefined && _parent.bFadedIn != false) 
			_parent.onMouseRotationFastClick(0);
		iProcessRotationDelayTimerID = undefined;
	}

	function onPressAux(): Void
	{
		_parent.onMouseRotationFastClick(1);
	}

}
