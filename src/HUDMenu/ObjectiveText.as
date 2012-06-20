class ObjectiveText extends MovieClip
{
	static var ClipCount: Number = 0;
	static var ArraySize: Number = 0;
	static var ObjectiveLine_mc;
	var MovieClipsA: Array;

	function ObjectiveText()
	{
		super();
		MovieClipsA = new Array();
	}

	function UpdateObjectives(aObjectiveArrayA: Array): Boolean
	{
		if (ObjectiveText.ArraySize > 0) {
			delete eval(MovieClipsA.shift());
			DuplicateObjective(aObjectiveArrayA);
			MovieClipsA[2].gotoAndPlay("OutToPositionThreeNoPause");
			return true;
		}
		return false;
	}

	function DuplicateObjective(aObjectiveArrayA: Array): Void
	{
		var aPrimaryObjective: String = String(aObjectiveArrayA.shift());
		var aSecondaryObjective: String = String(aObjectiveArrayA.shift());
		var aObjectiveText: String = undefined;
		if (aPrimaryObjective != "undefined") {
			if (aSecondaryObjective.length > 0) {
				var aTextField: TextField = new TextField();
				aTextField.SetText(aSecondaryObjective);
				aObjectiveText = aTextField.text + ": " + aPrimaryObjective;
			} else {
				aObjectiveText = aPrimaryObjective;
			}
			ObjectiveText.ObjectiveLine_mc = _parent.ObjectiveLineInstance;
			var aObjectiveLine_mc: MovieClip = ObjectiveText.ObjectiveLine_mc.duplicateMovieClip("objective" + ObjectiveText.ClipCount++, _parent.GetDepth());
			++QuestNotification.AnimationCount;
			aObjectiveLine_mc.ObjectiveTextFieldInstance.TextFieldInstance.SetText(aObjectiveText);
			MovieClipsA.push(aObjectiveLine_mc);
		}
		--ObjectiveText.ArraySize;
		if (ObjectiveText.ArraySize == 0)
			QuestNotification.RestartAnimations();
	}

	function ShowObjectives(aCount: Number, aObjectiveArrayA: Array): Void
	{
		if (aObjectiveArrayA.length > 0) 
			gfx.io.GameDelegate.call("PlaySound", ["UIObjectiveNew"]);
		while (MovieClipsA.length) {
			delete(eval(MovieClipsA.shift()));
		}
		var aMaxObjectives: Number = Math.min(aObjectiveArrayA.length, Math.min(aCount, 3)); // Shows a max of 3 objectives
		ObjectiveText.ArraySize = aCount;
		var aObjectivesShown: Number = 0;
		while (aObjectivesShown < aMaxObjectives) {
			DuplicateObjective(aObjectiveArrayA);
			++aObjectivesShown;
		}
		MovieClipsA[0].gotoAndPlay("OutToPositionOne");
		MovieClipsA[1].gotoAndPlay("OutToPositionTwo");
		MovieClipsA[2].gotoAndPlay("OutToPositionThree");
	}
}
