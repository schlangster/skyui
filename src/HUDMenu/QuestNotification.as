class QuestNotification extends MovieClip
{
	static var QuestNotificationIntervalIndex: Number = 0;
	static var AnimationCount: Number = 0;
	static var QUEST_UPDATE: Number = 0;
	static var SKILL_LEVEL_UPDATE: Number = 1;
	static var PLAYER_LEVEL_UPDATE: Number = 2;
	static var SHOUT_UPDATE: Number = 3;
	static var bPlayerLeveled: Boolean = false;
	static var PlayerLevel: Number = 0;
	
	var ShowNotifications: Boolean = true;
	
	var AnimatedLetter_mc: AnimatedLetter;
	var LevelMeterBaseInstance: MovieClip;
	var LevelUpMeter: Components.UniformTimeMeter;
	var ObjText: ObjectiveText;
	var ObjectiveLineInstance: ObjectiveText;
	var ObjectivesA: Array;
	var ObjectivesCount: Number;
	var ShoutAnimatedLetter: AnimatedLetter;
	static var Instance: Object;
	static var AnimLetter: AnimatedLetter;
	static var ShoutLetter: AnimatedLetter;
	static var LevelUpMeterIntervalIndex: Number;
	static var LevelUpMeterKillIntervalIndex: Number;

	function QuestNotification()
	{
		super();
		QuestNotification.Instance = this;
		ObjectivesA = new Array();
		QuestNotification.AnimLetter = AnimatedLetter_mc;
		QuestNotification.AnimLetter.AnimationBase_mc = AnimatedLetter_mc;
		QuestNotification.ShoutLetter = ShoutAnimatedLetter;
		QuestNotification.ShoutLetter.AnimationBase_mc = ShoutAnimatedLetter;
		ObjText = ObjectiveLineInstance;
		LevelUpMeter = new Components.UniformTimeMeter(LevelMeterBaseInstance.LevelUpMeterInstance, "UILevelUp", LevelMeterBaseInstance.LevelUpMeterInstance.FlashInstance, "StartFlash");
		LevelUpMeter.FillSpeed = 0.2;
		LevelMeterBaseInstance.gotoAndStop("FadeIn");
		QuestNotification.LevelUpMeterIntervalIndex = 0;
		QuestNotification.LevelUpMeterKillIntervalIndex = 0;
	}

	static function Update(): Void
	{
		QuestNotification.Instance.ObjText.UpdateObjectives(QuestNotification.Instance.ObjectivesA);
	}

	function EvaluateNotifications(): Void
	{
		if (QuestNotification.AnimationCount == 0 || QuestNotification.AnimationCount == QuestNotification.AnimLetter.QuestName.length) {
			QuestNotification.RestartAnimations();
			clearInterval(QuestNotification.QuestNotificationIntervalIndex);
			QuestNotification.QuestNotificationIntervalIndex = 0;
		}
	}

	static function DecAnimCount(): Void
	{
		--QuestNotification.AnimationCount;
		if (QuestNotification.AnimationCount == 0) 
			QuestNotification.Instance.ShowObjectives(QuestNotification.Instance.ObjectivesCount);
	}

	static function CheckContinue(): Boolean
	{
		QuestNotification.Instance.EvaluateNotifications();
		return true;
	}

	function CanShowNotification(): Boolean
	{
		return ShowNotifications && QuestNotification.AnimationCount == 0;
	}

	function ShowNotification(aNotificationText: String, aStatus: String, aSoundID: String, aObjectiveCount: Number, aNotificationType: Number, aLevel: Number, aStartPercent: Number, aEndPercent: Number, aDragonText: String): Void
	{
		ShowNotifications = false;
		if (aSoundID.length > 0)
			gfx.io.GameDelegate.call("PlaySound", [aSoundID]);
		EvaluateNotifications();
		QuestNotification.QuestNotificationIntervalIndex = setInterval(mx.utils.Delegate.create(this, EvaluateNotifications), 30);
		if (aNotificationType == QuestNotification.QUEST_UPDATE || aNotificationType == undefined) {
			LevelMeterBaseInstance.gotoAndStop("FadeIn");
			if (aNotificationText.length == 0) {
				ShowObjectives(aObjectiveCount);
			} else {
				QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase(), aStatus.toUpperCase());
				ObjectivesCount = aObjectiveCount;
			}
			return;
		}
		QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase());
		if (aDragonText && aNotificationType == QuestNotification.SHOUT_UPDATE) {
			QuestNotification.ShoutLetter.EndPosition = 128;
			QuestNotification.ShoutLetter.ShowQuestUpdate(aDragonText.toUpperCase());
			return;
		}
		QuestNotification.bPlayerLeveled = aStartPercent < 1 && aEndPercent >= 1;
		LevelMeterBaseInstance.gotoAndPlay("FadeIn");
		LevelUpMeter.SetPercent(aStartPercent * 100);
		LevelUpMeter.SetTargetPercent(aEndPercent * 100);
		LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(aLevel || 101);
		QuestNotification.PlayerLevel = aLevel;
		clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
		clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
		QuestNotification.LevelUpMeterKillIntervalIndex = setInterval(QuestNotification.KillLevelUpMeter, 1000);
	}

	static function UpdateLevelUpMeter(): Void
	{
		QuestNotification.Instance.LevelUpMeter.Update();
	}

	static function KillLevelUpMeter(): Void
	{
		if (QuestNotification.AnimationCount == 0) {
			if (QuestNotification.bPlayerLeveled) {
				QuestNotification.bPlayerLeveled = false;
				QuestNotification.AnimLetter.ShowQuestUpdate(QuestNotification.Instance.LevelUpTextInstance.text);
				QuestNotification.Instance.LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(QuestNotification.PlayerLevel + 1);
				return;
			}
			clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
			clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
			QuestNotification.Instance.LevelMeterBaseInstance.gotoAndPlay("FadeOut");
		}
	}

	function ShowObjectives(aObjectiveCount: Number): Void
	{
		ObjText.ShowObjectives(aObjectiveCount, ObjectivesA);
		ShowNotifications = true;
	}

	function GetDepth(): Number
	{
		return getNextHighestDepth();
	}

	static function RestartAnimations(): Void
	{
		var aQuestUpdateBase: MovieClip = QuestNotification.Instance.AnimLetter._parent;
		for (var i: String in aQuestUpdateBase) {
			if (aQuestUpdateBase[i] instanceof AnimatedLetter && aQuestUpdateBase[i] != QuestNotification.Instance.AnimLetter) {
				aQuestUpdateBase[i].gotoAndPlay(aQuestUpdateBase[i]._currentFrame);
			}
		}
	}

}
