class HUDMenu extends Shared.PlatformChangeUser
{
	var SavedRolloverText: String = "";
	var ItemInfoArray: Array = new Array();
	var CompassMarkerList: Array = new Array();
	var METER_PAUSE_FRAME: Number = 40;
	
	
	var ActivateButton_tf: TextField;
	var ArrowInfoInstance: MovieClip;
	var BottomLeftLockInstance: MovieClip;
	var BottomRightLockInstance: MovieClip;
	var BottomRightRefInstance: MovieClip;
	var BottomRightRefX: Number;
	var BottomRightRefY: Number;
	var CompassMarkerEnemy: Number;
	var CompassMarkerLocations: Number;
	var CompassMarkerPlayerSet: Number;
	var CompassMarkerQuest: Number;
	var CompassMarkerQuestDoor: Number;
	var CompassMarkerUndiscovered: Number;
	var CompassRect: MovieClip;
	var CompassShoutMeterHolder: MovieClip;
	var CompassTargetDataA: Array;
	var CompassThreeSixtyX: Number;
	var CompassZeroX: Number;
	var Crosshair: MovieClip;
	var CrosshairAlert: MovieClip;
	var CrosshairInstance: MovieClip;
	var EnemyHealthMeter: Components.Meter;
	var EnemyHealth_mc: MovieClip;
	var FavorBackButtonBase: MovieClip;
	var FavorBackButton_mc: MovieClip;
	var FloatingQuestMarkerInstance: MovieClip;
	var FloatingQuestMarker_mc: MovieClip;
	var GrayBarInstance: MovieClip;
	var HUDModes: Array;
	var Health: MovieClip;
	var HealthMeterAnim: MovieClip;
	var HealthMeterLeft: Components.BlinkOnEmptyMeter;
	var HudElements: Array;
	var LeftChargeMeter: Components.Meter;
	var LeftChargeMeterAnim: MovieClip;
	var LocationLockBase: MovieClip;
	var Magica: MovieClip;
	var MagickaMeter: Components.BlinkOnDemandMeter;
	var MagickaMeterAnim: MovieClip;
	var MessagesBlock: MovieClip;
	var MessagesInstance: MovieClip;
	var QuestUpdateBaseInstance: MovieClip;
	var RightChargeMeter: Components.Meter;
	var RightChargeMeterAnim: MovieClip;
	var RolloverButton_tf: TextField;
	var RolloverGrayBar_mc: MovieClip;
	var RolloverInfoInstance: TextField;
	var RolloverInfoText: TextField;
	var RolloverNameInstance: TextField;
	var RolloverText: TextField;
	var ShoutMeter_mc: ShoutMeter;
	var Stamina: MovieClip;
	var StaminaMeter: Components.BlinkOnDemandMeter;
	var StaminaMeterAnim: MovieClip;
	var StealthMeterInstance: MovieClip;
	var SubtitleText: TextField;
	var SubtitleTextHolder: MovieClip;
	var TopLeftRefInstance: MovieClip;
	var TopLeftRefX: Number;
	var TopLeftRefY: Number;
	var TutorialHintsArtHolder: MovieClip;
	var TutorialHintsText: TextField;
	var TutorialLockInstance: MovieClip;
	var ValueTranslated: TextField;
	var WeightTranslated: TextField;
	var bCrosshairEnabled: Boolean;

	function HUDMenu()
	{
		super();
		Shared.GlobalFunc.MaintainTextFormat();
		Shared.GlobalFunc.AddReverseFunctions();
		Key.addListener(this);
		MagickaMeter = new Components.BlinkOnDemandMeter(Magica.MagickaMeter_mc, Magica.MagickaFlashInstance);
		HealthMeterLeft = new Components.BlinkOnEmptyMeter(Health.HealthMeter_mc.HealthLeft);
		StaminaMeter = new Components.BlinkOnDemandMeter(Stamina.StaminaMeter_mc, Stamina.StaminaFlashInstance);
		ShoutMeter_mc = new ShoutMeter(CompassShoutMeterHolder.ShoutMeterInstance, CompassShoutMeterHolder.ShoutWarningInstance);
		LeftChargeMeter = new Components.Meter(BottomLeftLockInstance.LeftHandChargeMeterInstance.ChargeMeter_mc);
		RightChargeMeter = new Components.Meter(BottomRightLockInstance.RightHandChargeMeterInstance.ChargeMeter_mc);
		MagickaMeterAnim = Magica;
		HealthMeterAnim = Health;
		StaminaMeterAnim = Stamina;
		LeftChargeMeterAnim = BottomLeftLockInstance.LeftHandChargeMeterInstance;
		RightChargeMeterAnim = BottomRightLockInstance.RightHandChargeMeterInstance;
		LeftChargeMeterAnim.gotoAndStop(1);
		RightChargeMeterAnim.gotoAndStop(1);
		MagickaMeterAnim.gotoAndStop(1);
		HealthMeterAnim.gotoAndStop(1);
		StaminaMeterAnim.gotoAndStop(1);
		ArrowInfoInstance.gotoAndStop(1);
		EnemyHealthMeter = new Components.Meter(EnemyHealth_mc);
		EnemyHealth_mc.BracketsInstance.RolloverNameInstance.textAutoSize = "shrink";
		EnemyHealthMeter.SetPercent(0);
		gotoAndStop("Alert");
		CrosshairAlert = Crosshair;
		CrosshairAlert.gotoAndStop("NoTarget");
		gotoAndStop("Normal");
		CrosshairInstance = Crosshair;
		CrosshairInstance.gotoAndStop("NoTarget");
		RolloverText = RolloverNameInstance;
		RolloverButton_tf = ActivateButton_tf;
		RolloverInfoText = RolloverInfoInstance;
		RolloverGrayBar_mc = GrayBarInstance;
		RolloverGrayBar_mc._alpha = 0;
		RolloverInfoText.html = true;
		FavorBackButton_mc = FavorBackButtonBase;
		CompassRect = CompassShoutMeterHolder.Compass.DirectionRect;
		InitCompass();
		FloatingQuestMarker_mc = FloatingQuestMarkerInstance;
		MessagesInstance = MessagesBlock;
		SetCrosshairTarget(false, "");
		bCrosshairEnabled = true;
		SubtitleText = SubtitleTextHolder.textField;
		TutorialHintsText = TutorialLockInstance.TutorialHintsInstance.FadeHolder.TutorialHintsTextInstance;
		TutorialHintsArtHolder = TutorialLockInstance.TutorialHintsInstance.FadeHolder.TutorialHintsArtInstance;
		TutorialLockInstance.TutorialHintsInstance.gotoAndStop("FadeIn");
		CompassTargetDataA = new Array();
		SetModes();
		StealthMeterInstance.gotoAndStop("FadedOut");
	}

	function RegisterComponents(): Void
	{
		gfx.io.GameDelegate.call("RegisterHUDComponents", [this, HudElements, QuestUpdateBaseInstance, EnemyHealthMeter, StealthMeterInstance, StealthMeterInstance.SneakAnimInstance, EnemyHealth_mc.BracketsInstance, EnemyHealth_mc.BracketsInstance.RolloverNameInstance, StealthMeterInstance.SneakTextHolder, StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance]);
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		FavorBackButton_mc.FavorBackButtonInstance.SetPlatform(aiPlatform, abPS3Switch);
	}

	function SetModes(): Void
	{
		HudElements = new Array();
		HUDModes = new Array();
		HudElements.push(Health);
		HudElements.push(Magica);
		HudElements.push(Stamina);
		HudElements.push(LeftChargeMeterAnim);
		HudElements.push(RightChargeMeterAnim);
		HudElements.push(CrosshairInstance);
		HudElements.push(CrosshairAlert);
		HudElements.push(RolloverText);
		HudElements.push(RolloverInfoText);
		HudElements.push(RolloverGrayBar_mc);
		HudElements.push(RolloverButton_tf);
		HudElements.push(CompassShoutMeterHolder);
		HudElements.push(MessagesBlock);
		HudElements.push(SubtitleTextHolder);
		HudElements.push(QuestUpdateBaseInstance);
		HudElements.push(EnemyHealth_mc);
		HudElements.push(StealthMeterInstance);
		HudElements.push(StealthMeterInstance.SneakTextHolder.SneakTextClip);
		HudElements.push(StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance);
		HudElements.push(ArrowInfoInstance);
		HudElements.push(FavorBackButton_mc);
		HudElements.push(FloatingQuestMarker_mc);
		HudElements.push(LocationLockBase);
		HudElements.push(TutorialLockInstance);
		
		Health.All = true;
		Magica.All = true;
		Stamina.All = true;
		LeftChargeMeterAnim.All = true;
		RightChargeMeterAnim.All = true;
		CrosshairInstance.All = true;
		CrosshairAlert.All = true;
		RolloverText.All = true;
		RolloverInfoText.All = true;
		RolloverGrayBar_mc.All = true;
		RolloverButton_tf.All = true;
		CompassShoutMeterHolder.All = true;
		MessagesBlock.All = true;
		SubtitleTextHolder.All = true;
		QuestUpdateBaseInstance.All = true;
		EnemyHealth_mc.All = true;
		StealthMeterInstance.All = true;
		ArrowInfoInstance.All = true;
		FloatingQuestMarker_mc.All = true;
		StealthMeterInstance.SneakTextHolder.SneakTextClip.All = true;
		StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance.All = true;
		LocationLockBase.All = true;
		TutorialLockInstance.All = true;
		
		CrosshairInstance.Favor = true;
		RolloverText.Favor = true;
		RolloverInfoText.Favor = true;
		RolloverGrayBar_mc.Favor = true;
		RolloverButton_tf.Favor = true;
		CompassShoutMeterHolder.Favor = true;
		MessagesBlock.Favor = true;
		SubtitleTextHolder.Favor = true;
		QuestUpdateBaseInstance.Favor = true;
		EnemyHealth_mc.Favor = true;
		StealthMeterInstance.Favor = true;
		FavorBackButton_mc.Favor = true;
		FavorBackButton_mc._visible = false;
		FloatingQuestMarker_mc.Favor = true;
		LocationLockBase.Favor = true;
		TutorialLockInstance.Favor = true;
		
		MessagesBlock.InventoryMode = true;
		QuestUpdateBaseInstance.InventoryMode = true;
		
		MessagesBlock.TweenMode = true;
		QuestUpdateBaseInstance.TweenMode = true;
		
		MessagesBlock.BookMode = true;
		QuestUpdateBaseInstance.BookMode = true;
		
		QuestUpdateBaseInstance.DialogueMode = true;
		CompassShoutMeterHolder.DialogueMode = true;
		MessagesBlock.DialogueMode = true;
		
		QuestUpdateBaseInstance.BarterMode = true;
		MessagesBlock.BarterMode = true;
		
		MessagesBlock.WorldMapMode = true;
		
		MessagesBlock.MovementDisabled = true;
		QuestUpdateBaseInstance.MovementDisabled = true;
		SubtitleTextHolder.MovementDisabled = true;
		TutorialLockInstance.MovementDisabled = true;
		
		Health.StealthMode = true;
		Magica.StealthMode = true;
		Stamina.StealthMode = true;
		LeftChargeMeterAnim.StealthMode = true;
		RightChargeMeterAnim.StealthMode = true;
		RolloverText.StealthMode = true;
		RolloverButton_tf.StealthMode = true;
		RolloverInfoText.StealthMode = true;
		RolloverGrayBar_mc.StealthMode = true;
		CompassShoutMeterHolder.StealthMode = true;
		MessagesBlock.StealthMode = true;
		SubtitleTextHolder.StealthMode = true;
		QuestUpdateBaseInstance.StealthMode = true;
		EnemyHealth_mc.StealthMode = true;
		StealthMeterInstance.StealthMode = true;
		StealthMeterInstance.SneakTextHolder.SneakTextClip.StealthMode = true;
		StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance.StealthMode = true;
		ArrowInfoInstance.StealthMode = true;
		FloatingQuestMarker_mc.StealthMode = true;
		LocationLockBase.StealthMode = true;
		TutorialLockInstance.StealthMode = true;
		
		Health.Swimming = true;
		Magica.Swimming = true;
		Stamina.Swimming = true;
		LeftChargeMeterAnim.Swimming = true;
		RightChargeMeterAnim.Swimming = true;
		CrosshairInstance.Swimming = true;
		RolloverText.Swimming = true;
		RolloverInfoText.Swimming = true;
		RolloverGrayBar_mc.Swimming = true;
		RolloverButton_tf.Swimming = true;
		CompassShoutMeterHolder.Swimming = true;
		MessagesBlock.Swimming = true;
		SubtitleTextHolder.Swimming = true;
		QuestUpdateBaseInstance.Swimming = true;
		EnemyHealth_mc.Swimming = true;
		ArrowInfoInstance.Swimming = true;
		FloatingQuestMarker_mc.Swimming = true;
		LocationLockBase.Swimming = true;
		TutorialLockInstance.Swimming = true;
		
		Health.HorseMode = true;
		CompassShoutMeterHolder.HorseMode = true;
		MessagesBlock.HorseMode = true;
		SubtitleTextHolder.HorseMode = true;
		QuestUpdateBaseInstance.HorseMode = true;
		EnemyHealth_mc.HorseMode = true;
		FloatingQuestMarker_mc.HorseMode = true;
		LocationLockBase.HorseMode = true;
		TutorialLockInstance.HorseMode = true;
		
		Health.WarHorseMode = true;
		CompassShoutMeterHolder.WarHorseMode = true;
		MessagesBlock.WarHorseMode = true;
		SubtitleTextHolder.WarHorseMode = true;
		QuestUpdateBaseInstance.WarHorseMode = true;
		EnemyHealth_mc.WarHorseMode = true;
		FloatingQuestMarker_mc.WarHorseMode = true;
		LocationLockBase.WarHorseMode = true;
		TutorialLockInstance.WarHorseMode = true;
		CrosshairInstance.WarHorseMode = true;
		Stamina.WarHorseMode = true;
		RightChargeMeterAnim.WarHorseMode = true;
		ArrowInfoInstance.WarHorseMode = true;
		
		MessagesBlock.CartMode = true;
		SubtitleTextHolder.CartMode = true;
		TutorialLockInstance.CartMode = true;
		
		//JournalMode
	}

	function ShowElements(aMode: String, abShow: Boolean): Void
	{
		var HUDMode: String = "All";
		var aHUDMode = HUDModes.length - 1;

		if (abShow) {
			while (aHUDMode >= 0) {
				if (HUDModes[aHUDMode] == aMode)
					HUDModes.splice(aHUDMode, 1);
				--aHUDMode;
			}
			HUDModes.push(aMode);
			HUDMode = aMode;
		} else {
			if (aMode.length > 0) {
				var ModeFound = false;
				
				while (aHUDMode >= 0 && !ModeFound) {
					if (HUDModes[aHUDMode] == aMode) {
						HUDModes.splice(aHUDMode, 1);
						ModeFound = true;
					}
					--aHUDMode;
				}
			} else {
				HUDModes.pop();
			}
			if (HUDModes.length > 0) {
				HUDMode = String(HUDModes[HUDModes.length - 1]);
			}
		}
		
		for(var i: Number = 0; i < HudElements.length; i++) {
			if (HudElements[i] != undefined) {
				HudElements[i]._visible = HudElements[i].hasOwnProperty(HUDMode);
				if (HudElements[i].onModeChange != undefined)
					HudElements[i].onModeChange(HUDMode);
			}
		}
	}

	function SetLocationName(aLocation: String): Void
	{
		LocationLockBase.LocationNameBase.LocationTextBase.LocationTextInstance.SetText(aLocation);
		LocationLockBase.LocationNameBase.gotoAndPlay(1);
	}

	function CheckAgainstHudMode(aObj: Object): Boolean
	{
		var HUDMode: String = "All";
		if (HUDModes.length > 0) {
			HUDMode = String(HUDModes[HUDModes.length - 1]);
		}
		return HUDMode == "All" || (aObj != undefined && aObj.hasOwnProperty(HUDMode));
	}

	function InitExtensions(): Void
	{
		var _yDelta: Number = QuestUpdateBaseInstance._y - CompassShoutMeterHolder._y;
		Shared.GlobalFunc.SetLockFunction();
		HealthMeterAnim.Lock("B");
		MagickaMeterAnim.Lock("BL");
		StaminaMeterAnim.Lock("BR");
		TopLeftRefInstance.Lock("TL");
		BottomRightRefInstance.Lock("BR");
		BottomLeftLockInstance.Lock("BL");
		BottomRightLockInstance.Lock("BR");
		ArrowInfoInstance.Lock("BR");
		FavorBackButton_mc.Lock("BR");
		LocationLockBase.Lock("TR");
		LocationLockBase.LocationNameBase.gotoAndStop(1);
		var TopLeftRefCoords: Object = {x: TopLeftRefInstance.LocationRefInstance._x, y: TopLeftRefInstance.LocationRefInstance._y};
		TopLeftRefInstance.localToGlobal(TopLeftRefCoords);
		TopLeftRefX = TopLeftRefCoords.x;
		TopLeftRefY = TopLeftRefCoords.y;
		var LocationRefCoords: Object = {x: BottomRightRefInstance.LocationRefInstance._x, y: BottomRightRefInstance.LocationRefInstance._y};
		BottomRightRefInstance.localToGlobal(LocationRefCoords);
		BottomRightRefX = LocationRefCoords.x;
		BottomRightRefY = LocationRefCoords.y;
		CompassShoutMeterHolder.Lock("T");
		EnemyHealth_mc.Lock("T");
		MessagesBlock.Lock("TL");
		QuestUpdateBaseInstance._y = CompassShoutMeterHolder._y + _yDelta;
		SubtitleTextHolder.Lock("B");
		SubtitleText._visible = false;
		SubtitleText.enabled = true;
		SubtitleText.verticalAutoSize = "bottom";
		SubtitleText.SetText(" ", true);
		RolloverText.verticalAutoSize = "top";
		RolloverText.html = true;
		gfx.io.GameDelegate.addCallBack("SetCrosshairTarget", this, "SetCrosshairTarget");
		gfx.io.GameDelegate.addCallBack("SetLoadDoorInfo", this, "SetLoadDoorInfo");
		gfx.io.GameDelegate.addCallBack("ShowMessage", this, "ShowMessage");
		gfx.io.GameDelegate.addCallBack("ShowSubtitle", this, "ShowSubtitle");
		gfx.io.GameDelegate.addCallBack("HideSubtitle", this, "HideSubtitle");
		gfx.io.GameDelegate.addCallBack("SetCrosshairEnabled", this, "SetCrosshairEnabled");
		gfx.io.GameDelegate.addCallBack("SetSubtitlesEnabled", this, "SetSubtitlesEnabled");
		gfx.io.GameDelegate.addCallBack("SetHealthMeterPercent", this, "SetHealthMeterPercent");
		gfx.io.GameDelegate.addCallBack("SetMagickaMeterPercent", this, "SetMagickaMeterPercent");
		gfx.io.GameDelegate.addCallBack("SetStaminaMeterPercent", this, "SetStaminaMeterPercent");
		gfx.io.GameDelegate.addCallBack("SetShoutMeterPercent", this, "SetShoutMeterPercent");
		gfx.io.GameDelegate.addCallBack("FlashShoutMeter", this, "FlashShoutMeter");
		gfx.io.GameDelegate.addCallBack("SetChargeMeterPercent", this, "SetChargeMeterPercent");
		gfx.io.GameDelegate.addCallBack("StartMagickaMeterBlinking", this, "StartMagickaBlinking");
		gfx.io.GameDelegate.addCallBack("StartStaminaMeterBlinking", this, "StartStaminaBlinking");
		gfx.io.GameDelegate.addCallBack("FadeOutStamina", this, "FadeOutStamina");
		gfx.io.GameDelegate.addCallBack("FadeOutChargeMeters", this, "FadeOutChargeMeters");
		gfx.io.GameDelegate.addCallBack("SetCompassAngle", this, "SetCompassAngle");
		gfx.io.GameDelegate.addCallBack("SetCompassMarkers", this, "SetCompassMarkers");
		gfx.io.GameDelegate.addCallBack("SetEnemyHealthPercent", EnemyHealthMeter, "SetPercent");
		gfx.io.GameDelegate.addCallBack("SetEnemyHealthTargetPercent", EnemyHealthMeter, "SetTargetPercent");
		gfx.io.GameDelegate.addCallBack("ShowNotification", QuestUpdateBaseInstance, "ShowNotification");
		gfx.io.GameDelegate.addCallBack("ShowElements", this, "ShowElements");
		gfx.io.GameDelegate.addCallBack("SetLocationName", this, "SetLocationName");
		gfx.io.GameDelegate.addCallBack("ShowTutorialHintText", this, "ShowTutorialHintText");
		gfx.io.GameDelegate.addCallBack("ValidateCrosshair", this, "ValidateCrosshair");
	}

	function InitCompass(): Void
	{
		CompassShoutMeterHolder.Compass.gotoAndStop("ThreeSixty");
		CompassThreeSixtyX = CompassRect._x;
		CompassShoutMeterHolder.Compass.gotoAndStop("Zero");
		CompassZeroX = CompassRect._x;
		var CompassMarkerTemp: MovieClip = CompassRect.attachMovie("Compass Marker", "temp", CompassRect.getNextHighestDepth());
		CompassMarkerTemp.gotoAndStop("Quest");
		CompassMarkerQuest = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.gotoAndStop("QuestDoor");
		CompassMarkerQuestDoor = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.gotoAndStop("PlayerSet");
		CompassMarkerPlayerSet = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.gotoAndStop("Enemy");
		CompassMarkerEnemy = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.gotoAndStop("LocationMarkers");
		CompassMarkerLocations = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.gotoAndStop("UndiscoveredMarkers");
		CompassMarkerUndiscovered = CompassMarkerTemp._currentframe == undefined ? 0 : CompassMarkerTemp._currentframe;
		CompassMarkerTemp.removeMovieClip();
	}

	function RunMeterAnim(aMeter: MovieClip): Void
	{
		aMeter.PlayForward(aMeter._currentframe);
	}

	function FadeOutMeter(aMeter: MovieClip): Void
	{
		if (aMeter._currentframe > METER_PAUSE_FRAME)
			aMeter.gotoAndStop("Pause");
		aMeter.PlayReverse();
	}

	function FadeOutStamina(aPercent: Number): Void
	{
		FadeOutMeter(Stamina);
		StaminaMeter.CurrentPercent = aPercent;
		StaminaMeter.TargetPercent = aPercent;
	}

	function FadeOutChargeMeters(): Void
	{
		FadeOutMeter(LeftChargeMeterAnim);
		FadeOutMeter(RightChargeMeterAnim);
	}

	function SetChargeMeterPercent(aPercent: Number, abForce: Boolean, abLeftHand: Boolean, abShow: Boolean): Void
	{
		var ChargeMeter: Components.Meter = abLeftHand ? LeftChargeMeter : RightChargeMeter;
		var ChargeMeterAnim: MovieClip = abLeftHand ? LeftChargeMeterAnim : RightChargeMeterAnim;
		if (!abShow) {
			ChargeMeterAnim.gotoAndStop(1);
			return;
		}
		if (abForce) {
			RunMeterAnim(ChargeMeterAnim);
			ChargeMeter.SetPercent(aPercent);
			ChargeMeter.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(ChargeMeterAnim);
		ChargeMeter.SetTargetPercent(aPercent);
		ChargeMeter.SetTargetPercent(aPercent);
	}

	function SetHealthMeterPercent(aPercent: Number, abForce: Boolean): Void
	{
		if (abForce) {
			HealthMeterLeft.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(HealthMeterAnim);
		HealthMeterLeft.SetTargetPercent(aPercent);
	}

	function SetMagickaMeterPercent(aPercent: Number, abForce: Boolean): Void
	{
		if (abForce) {
			MagickaMeter.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(MagickaMeterAnim);
		MagickaMeter.SetTargetPercent(aPercent);
	}

	function SetStaminaMeterPercent(aPercent: Number, abForce: Boolean): Void
	{
		if (abForce) {
			StaminaMeter.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(StaminaMeterAnim);
		StaminaMeter.SetTargetPercent(aPercent);
	}

	function SetShoutMeterPercent(aPercent: Number, abForce: Boolean): Void
	{
		ShoutMeter_mc.SetPercent(aPercent);
	}

	function FlashShoutMeter(): Void
	{
		ShoutMeter_mc.FlashMeter();
	}

	function StartMagickaBlinking(): Void
	{
		MagickaMeter.StartBlinking();
	}

	function StartStaminaBlinking(): Void
	{
		StaminaMeter.StartBlinking();
	}

	function SetCompassAngle(aPlayerAngle: Number, aCompassAngle: Number, abShowCompass: Boolean)
	{
		CompassRect._parent._visible = abShowCompass;
		if (abShowCompass) {
			var Compass_x: Number = Shared.GlobalFunc.Lerp(CompassZeroX, CompassThreeSixtyX, 0, 360, aCompassAngle);
			CompassRect._x = Compass_x;
			UpdateCompassMarkers(aPlayerAngle);
		}
	}

	function SetCrosshairTarget(abActivate: Boolean, aName: String, abShowButton: Boolean, abTextOnly: Boolean, abFavorMode: Boolean, abShowCrosshair: Boolean, aWeight: Number, aCost: Number, aFieldValue: Number, aFieldText): Void // Unknown type aFieldText, possibly Number
	{
		var FavorModeNoTarget: String = abFavorMode ? "Favor" : "NoTarget";
		var FavorModeTarget: String = abFavorMode ? "Favor" : "Target";
		var Crosshair_mc: MovieClip = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		Crosshair_mc._visible = CheckAgainstHudMode(Crosshair_mc) && abShowCrosshair != false;
		Crosshair_mc._alpha = bCrosshairEnabled ? 100 : 0;
		if (!abActivate && SavedRolloverText.length > 0) {
			Crosshair_mc.gotoAndStop(FavorModeNoTarget);
			RolloverText.SetText(SavedRolloverText, true);
			RolloverText._alpha = 100;
			RolloverButton_tf._alpha = 0;
		} else if (abTextOnly || abActivate) {
			if (!abTextOnly) {
				Crosshair_mc.gotoAndStop(FavorModeTarget);
			}
			RolloverText.SetText(aName, true);
			RolloverText._alpha = 100;
			RolloverButton_tf._alpha = abShowButton ? 100 : 0;
			RolloverButton_tf._x = RolloverText._x + RolloverText.getLineMetrics(0).x - 103;
		} else 	{
			Crosshair_mc.gotoAndStop(FavorModeNoTarget);
			RolloverText.SetText(" ", true);
			RolloverText._alpha = 0;
			RolloverButton_tf._alpha = 0;
		}
		
		var TranslateText: String = "";
		if (aCost != undefined) {
			TranslateText = ValueTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aCost) + "</font>" + TranslateText;
		}
		if (aWeight != undefined) {
			TranslateText = WeightTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Shared.GlobalFunc.RoundDecimal(aWeight, 1) + "</font>	  " + TranslateText;
		}
		if (aFieldValue != undefined) {
			var aTextField: TextField = new TextField();
			aTextField.text = aFieldText.toString();
			TranslateText = aTextField.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aFieldValue) + "</font>	  " + TranslateText;
		}
		if (TranslateText.length > 0) {
			RolloverGrayBar_mc._alpha = 100;
		} else {
			RolloverGrayBar_mc._alpha = 0;
		}
		
		RolloverInfoText.htmlText = TranslateText;
	}

	function RefreshActivateButtonArt(astrButtonName: String): Void
	{
		if (astrButtonName == undefined) {
			RolloverButton_tf.SetText(" ", true);
			return;
		}
		
		var ButtonImage: flash.display.BitmapData = flash.display.BitmapData.loadBitmap(astrButtonName + ".png");
		if (ButtonImage != undefined && ButtonImage.height > 0) {
			var MaxHeight: Number = 26;
			var ScaledWidth: Number = Math.floor(MaxHeight / ButtonImage.height * ButtonImage.width);
			RolloverButton_tf.SetText("<img src=\'" + astrButtonName + ".png\' height=\'" + MaxHeight + "\' width=\'" + ScaledWidth + "\'>", true);
			return;
		}
		RolloverButton_tf.SetText(" ", true);
	}

	function SetLoadDoorInfo(abShow: Boolean, aDoorName: String): Void
	{
		if (abShow) {
			SavedRolloverText = aDoorName;
			SetCrosshairTarget(true, SavedRolloverText, false, true, false);
			return;
		}
		SavedRolloverText = "";
		SetCrosshairTarget(false, SavedRolloverText, false, false, false);
	}

	function SetSubtitlesEnabled(abEnable: Boolean): Void
	{
		SubtitleText.enabled = abEnable;
		if (!abEnable) 	{
			SubtitleText._visible = false;
			return;
		}
		
		if (SubtitleText.htmlText != " ")
			SubtitleText._visible = true;
	}

	function ShowMessage(asMessage): Void //Unknown what type asMessage is
	{
		MessagesInstance.MessageArray.push(asMessage);
	}

	function ShowSubtitle(astrText: String): Void
	{
		SubtitleText.SetText(astrText, true);
		if (SubtitleText.enabled) 
			SubtitleText._visible = true;
	}

	function HideSubtitle(): Void
	{
		SubtitleText.SetText(" ", true);
		SubtitleText._visible = false;
	}

	function ShowArrowCount(aCount: Number, abHide: Boolean, aArrows: Number): Void
	{
		var HideFrame: Number = 15;
		if (abHide) {
			if (ArrowInfoInstance._currentframe > HideFrame) 
				ArrowInfoInstance.gotoAndStop(HideFrame);
			ArrowInfoInstance.PlayReverse();
			return;
		}
		ArrowInfoInstance.PlayForward(ArrowInfoInstance._currentframe);
		ArrowInfoInstance.ArrowCountInstance.ArrowNumInstance.SetText(aArrows + " (" + aCount.toString() + ")");
	}

	function onEnterFrame(): Void
	{
		MagickaMeter.Update();
		HealthMeterLeft.Update();
		StaminaMeter.Update();
		EnemyHealthMeter.Update();
		LeftChargeMeter.Update();
		RightChargeMeter.Update();
		MessagesInstance.Update();
	}

	function SetCompassMarkers(): Void
	{
		var COMPASS_HEADING: Number = 0;
		var COMPASS_ALPHA: Number = 1;
		var COMPASS_GOTOANDSTOP: Number = 2;
		var COMPASS_SCALE: Number = 3;
		var COMPASS_STRIDE: Number = 4;
		
		while (CompassMarkerList.length > CompassTargetDataA.length / COMPASS_STRIDE) {
			CompassMarkerList.pop().movie.removeMovieClip();
		}
		
		for (var i: Number = 0; i < CompassTargetDataA.length / COMPASS_STRIDE; i++) {
			var j: Number = i * COMPASS_STRIDE;
			if (CompassMarkerList[i].movie == undefined) {
				markerData = {movie: undefined, heading: 0};
				if (CompassTargetDataA[j + COMPASS_GOTOANDSTOP] == CompassMarkerQuest || CompassTargetDataA[j + COMPASS_GOTOANDSTOP] == CompassMarkerQuestDoor) {
					markerData.movie = CompassRect.QuestHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.QuestHolder.getNextHighestDepth());
				} else {
					markerData.movie = CompassRect.MarkerHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.MarkerHolder.getNextHighestDepth());
				}
				CompassMarkerList.push(markerData);
			} else {
				var compassMarkerFrame: Number = CompassMarkerList[i].movie._currentframe;
				if (compassMarkerFrame == CompassMarkerQuest || compassMarkerFrame == CompassMarkerQuestDoor) {
					if (CompassMarkerList[i].movie._parent == CompassRect.MarkerHolder) {
						markerData = {movie: undefined, heading: 0};
						markerData.movie = CompassRect.QuestHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.QuestHolder.getNextHighestDepth());
						aCompassMarkerList = CompassMarkerList.splice(i, 1, markerData);
						aCompassMarkerList[0].movie.removeMovieClip();
					}
				} else if (CompassMarkerList[i].movie._parent == CompassRect.QuestHolder) {
					var markerData: Object = {movie: undefined, heading: 0};
					markerData.movie = CompassRect.MarkerHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.MarkerHolder.getNextHighestDepth());
					var aCompassMarkerList: Array = CompassMarkerList.splice(i, 1, markerData);
					aCompassMarkerList[0].movie.removeMovieClip();
				}
			}
			CompassMarkerList[i].heading = CompassTargetDataA[j + COMPASS_HEADING];
			CompassMarkerList[i].movie._alpha = CompassTargetDataA[j + COMPASS_ALPHA];
			CompassMarkerList[i].movie.gotoAndStop(CompassTargetDataA[j + COMPASS_GOTOANDSTOP]);
			CompassMarkerList[i].movie._xscale = CompassTargetDataA[j + COMPASS_SCALE];
			CompassMarkerList[i].movie._yscale = CompassTargetDataA[j + COMPASS_SCALE];
		}
	}

	function UpdateCompassMarkers(aiCenterAngle: Number): Void
	{
		var compassMarkerWidth: Number = CompassShoutMeterHolder.Compass.CompassMask_mc._width;
		var angleDelta: Number = compassMarkerWidth * 180 / Math.abs(CompassThreeSixtyX - CompassZeroX);
		var angleDeltaLeft: Number = aiCenterAngle - angleDelta;
		var angleDeltaRight: Number = aiCenterAngle + angleDelta;
		var widthDeltaLeft: Number = 0 - CompassRect._x - compassMarkerWidth / 2;
		var widthDeltaRight: Number = 0 - CompassRect._x + compassMarkerWidth / 2;
		
		for (var i: Number = 0; i < CompassMarkerList.length; i++) {
			var heading: Number = CompassMarkerList[i].heading;
			if (angleDeltaLeft < 0 && heading > 360 - aiCenterAngle - angleDelta) {
				heading = heading - 360;
			}
			if (angleDeltaRight > 360 && heading < angleDelta - (360 - aiCenterAngle)) {
				heading = heading + 360;
			}
			if (heading > angleDeltaLeft && heading < angleDeltaRight) {
				CompassMarkerList[i].movie._x = Shared.GlobalFunc.Lerp(widthDeltaLeft, widthDeltaRight, angleDeltaLeft, angleDeltaRight, heading);
			} else {
				var markerFrame: Number = CompassMarkerList[i].movie._currentframe;
				if (markerFrame == CompassMarkerQuest || markerFrame == CompassMarkerQuestDoor) {
					var angleRadians = Math.sin((heading - aiCenterAngle) * Math.PI / 180);
					CompassMarkerList[i].movie._x = angleRadians <= 0 ? widthDeltaLeft + 2 : widthDeltaRight;
				} else {
					CompassMarkerList[i].movie._x = 0;
				}
			}
		}
	}

	function ShowTutorialHintText(astrHint: String, abShow: Boolean): Void
	{
		if (abShow) {
			TutorialHintsText.text = astrHint;
			var buttonHtmlText: String = TutorialHintsArtHolder.CreateButtonArt(TutorialHintsText);
			if (buttonHtmlText != undefined) {
				TutorialHintsText.html = true;
				TutorialHintsText.htmlText = buttonHtmlText;
			}
		}
		if (abShow) {
			TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeIn");
			return;
		}
		TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeOut");
	}

	function SetCrosshairEnabled(abFlag: Boolean): Void
	{
		bCrosshairEnabled = abFlag;
		var crosshairMode: MovieClip = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		crosshairMode._alpha = bCrosshairEnabled ? 100 : 0;
	}

	function ValidateCrosshair(): Void
	{
		var crosshairMode: MovieClip = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		crosshairMode._visible = CheckAgainstHudMode(crosshairMode);
		StealthMeterInstance._visible = CheckAgainstHudMode(StealthMeterInstance);
	}

}
