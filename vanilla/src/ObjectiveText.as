class ObjectiveText extends MovieClip
{
	static var ClipCount:Number = 0;
	static var ArraySize:Number = 0;
	
	var MovieClipsA:Array;
	
	static var ObjectiveLine_mc;
	
	function ObjectiveText()
	{
		super();
		MovieClipsA = new Array();
	}
	
	function UpdateObjectives(aObjectiveArrayA:Array)
	{
		if (ObjectiveText.ArraySize > 0)
		{
			delete MovieClipsA.shift();
			this.DuplicateObjective(aObjectiveArrayA);
			MovieClipsA[2].gotoAndPlay("OutToPositionThreeNoPause");
			return (true);
		}
		else
		{
			return (false);
		}
	}
	
	function DuplicateObjective(aObjectiveArrayA:Array)
	{
		var _loc2 = String(aObjectiveArrayA.shift());
		var _loc4 = String(aObjectiveArrayA.shift());
		var _loc5;
		if (_loc2 != "undefined")
		{
			if (_loc4.length > 0)
			{
				var _loc6 = new TextField();
				_loc6.SetText(_loc4);
				_loc5 = _loc6.text + ": " + _loc2;
			}
			else
			{
				_loc5 = _loc2;
			}
			
			ObjectiveLine_mc = _parent.ObjectiveLineInstance;
			ClipCount = ++ObjectiveText.ClipCount;
			var _loc3 = ObjectiveText.ObjectiveLine_mc.duplicateMovieClip("objective" + ObjectiveText.ClipCount, _parent.GetDepth());
			++QuestNotification.AnimationCount;
			_loc3.ObjectiveTextFieldInstance.TextFieldInstance.SetText(_loc5);
			MovieClipsA.push(_loc3);
		}
		
		ArraySize = --ObjectiveText.ArraySize;
		if (ObjectiveText.ArraySize == 0)
		{
			QuestNotification.RestartAnimations();
		}
	}
	
	function ShowObjectives(aCount, aObjectiveArrayA)
	{
		if (aObjectiveArrayA.length > 0)
		{
			gfx.io.GameDelegate.call("PlaySound", ["UIObjectiveNew"]);
		}
		
		while (MovieClipsA.length)
		{
			delete MovieClipsA.shift();
		}
		
		var _loc3 = Math.min(aObjectiveArrayA.length, Math.min(aCount, 3));
		ArraySize = aCount;
		for (var _loc2 = 0; _loc2 < _loc3; ++_loc2)
		{
			this.DuplicateObjective(aObjectiveArrayA);
		}
		
		MovieClipsA[0].gotoAndPlay("OutToPositionOne");
		MovieClipsA[1].gotoAndPlay("OutToPositionTwo");
		MovieClipsA[2].gotoAndPlay("OutToPositionThree");
	}
}
