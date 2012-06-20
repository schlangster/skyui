class AnimatedLetter extends MovieClip {
	
	static var SpaceWidth: Number = 15;
	
	var AnimationBase_mc: MovieClip;
	var QuestName: String;
	var QuestNameIndex: Number = 0;
	var Start: Number = 0;
	var LetterSpacing: Number = 0;
	var OldWidth: Number = 0;
    var EndPosition: Number = 104;
	
	function AnimatedLetter() {
		super();
		Shared.GlobalFunc.MaintainTextFormat();
	}

	function ShowQuestUpdate(aQuestName: String, aQuestStatus: String): Void {
		if (aQuestName.length > 0 && aQuestStatus.length > 0) {
			var QuestStatus: Object = new TextField();
			QuestStatus.text = aQuestStatus + ": ";
			QuestName = QuestStatus.text + aQuestName;
		} else {
			QuestName = aQuestName;
		}
		
		Start = 0;
		
        for (var LetterIndex: Number = 0; LetterIndex < QuestName.length; LetterIndex++) {
			AnimationBase_mc.Letter_mc.LetterTextInstance.SetText(QuestName.substr(LetterIndex, 1));
			var LetterWidth: Number = AnimationBase_mc.Letter_mc.LetterTextInstance.getLineMetrics(0).width - 5;
			Start = Start + (LetterWidth <= 0 ? AnimatedLetter.SpaceWidth : LetterWidth);
		}
		
		Start = Start * -0.5;
		Start = Start - EndPosition;
		
		QuestNameIndex = 0;
		LetterSpacing = 0;
		OldWidth = 0;
		
		AnimationBase_mc.onEnterFrame = AnimationBase_mc.ShowLetter;
	}

	function ShowLetter(): Void {
		var LastLetterIndex: Number = QuestName.length;
		var LetterIndex: Number = QuestNameIndex++;
		
		if (LetterIndex < LastLetterIndex) {
			var Letter: String = QuestName.substr(LetterIndex, 1);
			var LetterInstance: MovieClip = AnimationBase_mc.duplicateMovieClip("letter" + LetterIndex, _parent.getNextHighestDepth());
			++QuestNotification.AnimationCount;
			LetterInstance.Letter_mc.LetterTextInstance.text = Letter;
			var LetterWidth: Number = LetterInstance.Letter_mc.LetterTextInstance.getLineMetrics(0).width;
			if (LetterWidth == 0) {
				LetterWidth = AnimatedLetter.SpaceWidth;
			} else {
				LetterWidth = LetterWidth - 5;
			}
			LetterInstance._x = Start + LetterSpacing + OldWidth / 2 + (LetterIndex < 0 ? 0 : LetterWidth / 2);
			LetterSpacing = LetterInstance._x - Start;
			OldWidth = LetterWidth;
			LetterInstance.gotoAndPlay("StartAnim");
			return;
		}
		delete onEnterFrame;
	}
}
