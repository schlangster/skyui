import Shared.GlobalFunc;

class AnimatedLetter extends MovieClip
{
	static var SpaceWidth:Number = 15;
	
    var QuestName:String;
	var AnimationBase_mc;
	var LetterSpacing:Number = 0;
    var OldWidth:Number = 0;
    var QuestNameIndex:Number = 0;
    var Start:Number = 0;
    var EndPosition:Number = 104;
    
	
    function AnimatedLetter()
    {
        super();
        GlobalFunc.MaintainTextFormat();
    }
	
    function ShowQuestUpdate(aQuestName, aQuestStatus)
    {
        if (aQuestName.length > 0 && aQuestStatus.length > 0)
        {
            var _loc4 = new TextField();
            _loc4.text = aQuestStatus + ": ";
            QuestName = _loc4.text + aQuestName;
        }
        else
        {
            QuestName = aQuestName;
        }
		
        Start = 0;
        for (var _loc2 = 0; _loc2 < QuestName.length; ++_loc2)
        {
            AnimationBase_mc.Letter_mc.LetterTextInstance.SetText(QuestName.substr(_loc2, 1));
            var _loc3 = AnimationBase_mc.Letter_mc.LetterTextInstance.getLineMetrics(0).width - 5;
            Start = Start + (_loc3 > 0 ? (_loc3) : (AnimatedLetter.SpaceWidth));
        }
		
        Start = Start * -0.500000;
        Start = Start - EndPosition;
        QuestNameIndex = 0;
        LetterSpacing = 0;
        OldWidth = 0;
        AnimationBase_mc.onEnterFrame = AnimationBase_mc.ShowLetter;
    }
	
    function ShowLetter()
    {
        var _loc6 = QuestName.length;
        var _loc4 = QuestNameIndex++;
        if (_loc4 < _loc6)
        {
            var _loc5 = QuestName.substr(_loc4, 1);
            var _loc3 = AnimationBase_mc.duplicateMovieClip("letter" + _loc4, _parent.getNextHighestDepth());
            ++QuestNotification.AnimationCount;
            _loc3.Letter_mc.LetterTextInstance.text = _loc5;
            var _loc2 = _loc3.Letter_mc.LetterTextInstance.getLineMetrics(0).width;
            if (_loc2 == 0)
            {
                _loc2 = AnimatedLetter.SpaceWidth;
            }
            else
            {
                _loc2 = _loc2 - 5;
            } // end else if
            _loc3._x = Start + LetterSpacing + OldWidth / 2 + (_loc4 >= 0 ? (_loc2 / 2) : (0));
            LetterSpacing = _loc3._x - Start;
            OldWidth = _loc2;
            _loc3.gotoAndPlay("StartAnim");
        }
        else
        {
            delete onEnterFrame;
        }
    }
}
