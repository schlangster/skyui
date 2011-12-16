class QuestNotification extends MovieClip
{
	var ObjectivesA:Array;
	var AnimatedLetter_mc;
	var ShoutAnimatedLetter;
	var ObjectiveLineInstance;
	var ObjText;
	var LevelMeterBaseInstance;
	var LevelUpMeter;
	var ObjectivesCount;
	var getNextHighestDepth;
	var ShowNotifications = true;
	
	static var Instance;
	static var AnimLetter;
	static var ShoutLetter;
	static var LevelUpMeterIntervalIndex;
	static var LevelUpMeterKillIntervalIndex;
	static var QuestNotificationIntervalIndex = 0;
	static var AnimationCount = 0;
	static var QUEST_UPDATE = 0;
	static var SKILL_LEVEL_UPDATE = 1;
	static var PLAYER_LEVEL_UPDATE = 2;
	static var SHOUT_UPDATE = 3;
	static var bPlayerLeveled = false;
	static var PlayerLevel = 0;
	
	function QuestNotification()
	{
		super();
		Instance = this;
		ObjectivesA = new Array();
		AnimLetter = AnimatedLetter_mc;
		QuestNotification.AnimLetter.AnimationBase_mc = AnimatedLetter_mc;
		ShoutLetter = ShoutAnimatedLetter;
		QuestNotification.ShoutLetter.AnimationBase_mc = ShoutAnimatedLetter;
		ObjText = ObjectiveLineInstance;
		LevelUpMeter = new Components.UniformTimeMeter(LevelMeterBaseInstance.LevelUpMeterInstance, "UILevelUp", LevelMeterBaseInstance.LevelUpMeterInstance.FlashInstance, "StartFlash");
		LevelUpMeter.FillSpeed = 0.200000;
		LevelMeterBaseInstance.gotoAndStop("FadeIn");
		LevelUpMeterIntervalIndex = 0;
		LevelUpMeterKillIntervalIndex = 0;
	}
	
	static function Update()
	{
		QuestNotification.Instance.ObjText.UpdateObjectives(QuestNotification.Instance.ObjectivesA);
	}
	
	function EvaluateNotifications()
	{
		if (QuestNotification.AnimationCount == 0 || QuestNotification.AnimationCount == QuestNotification.AnimLetter.QuestName.length)
		{
			QuestNotification.RestartAnimations();
			clearInterval(QuestNotification.QuestNotificationIntervalIndex);
			QuestNotificationIntervalIndex = 0;
		}
	}
	
	static function DecAnimCount()
	{
		AnimationCount = --QuestNotification.AnimationCount;
		if (QuestNotification.AnimationCount == 0)
		{
			QuestNotification.Instance.ShowObjectives(QuestNotification.Instance.ObjectivesCount);
		}
	}
	
	static function CheckContinue()
	{
		QuestNotification.Instance.EvaluateNotifications();
		return true;
	}
	
	function CanShowNotification()
	{
		return (ShowNotifications && QuestNotification.AnimationCount == 0);
	}
	
	function ShowNotification(aNotificationText, aStatus, aSoundID, aObjectiveCount, aNotificationType, aLevel, aStartPercent, aEndPercent, aDragonText)
	{
		ShowNotifications = false;
		if (aSoundID.length > 0)
		{
			gfx.io.GameDelegate.call("PlaySound", [aSoundID]);
		}
		this.EvaluateNotifications();
		QuestNotificationIntervalIndex = setInterval(mx.utils.Delegate.create(this, EvaluateNotifications), 30);
		if (aNotificationType == QuestNotification.QUEST_UPDATE || aNotificationType == undefined)
		{
			LevelMeterBaseInstance.gotoAndStop("FadeIn");
			if (aNotificationText.length == 0)
			{
				this.ShowObjectives(aObjectiveCount);
			}
			else
			{
				QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase(), aStatus.toUpperCase());
				ObjectivesCount = aObjectiveCount;
			}
		}
		else
		{
			QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase());
			if (aDragonText && aNotificationType == QuestNotification.SHOUT_UPDATE)
			{
				QuestNotification.ShoutLetter.EndPosition = 128;
				QuestNotification.ShoutLetter.ShowQuestUpdate(aDragonText.toUpperCase());
			}
			else
			{
				bPlayerLeveled = aStartPercent < 1 && aEndPercent >= 1;
				LevelMeterBaseInstance.gotoAndPlay("FadeIn");
				LevelUpMeter.SetPercent(aStartPercent * 100);
				LevelUpMeter.SetTargetPercent(aEndPercent * 100);
				LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(aLevel ? (aLevel) : (101));
				PlayerLevel = aLevel;
				clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
				clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
				LevelUpMeterKillIntervalIndex = setInterval(QuestNotification.KillLevelUpMeter, 1000);
			}
		}
	}
	
	static function UpdateLevelUpMeter()
	{
		QuestNotification.Instance.LevelUpMeter.Update();
	}
	
	static function KillLevelUpMeter()
	{
		if (QuestNotification.AnimationCount == 0)
		{
			if (QuestNotification.bPlayerLeveled)
			{
				bPlayerLeveled = false;
				QuestNotification.AnimLetter.ShowQuestUpdate(QuestNotification.Instance.LevelUpTextInstance.text);
				QuestNotification.Instance.LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(QuestNotification.PlayerLevel + 1);
			}
			else
			{
				clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
				clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
				QuestNotification.Instance.LevelMeterBaseInstance.gotoAndPlay("FadeOut");
			}
		}
	}
	
	function ShowObjectives(aObjectiveCount)
	{
		ObjText.ShowObjectives(aObjectiveCount, ObjectivesA);
		ShowNotifications = true;
	}
	
	function GetDepth()
	{
		return getNextHighestDepth();
	}
	
	static function RestartAnimations()
	{
		var _loc1 = QuestNotification.Instance.AnimLetter._parent;
		for (var _loc2 in _loc1)
		{
			if (_loc1[_loc2] instanceof AnimatedLetter && _loc1[_loc2] != QuestNotification.Instance.AnimLetter)
			{
				_loc1[_loc2].gotoAndPlay(_loc1[_loc2]._currentFrame);
			}
		}
	}
}
