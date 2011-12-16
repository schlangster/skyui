//Sprite 791
//  InitClip
import Components.BlinkOnDemandMeter;
import Components.BlinkOnEmptyMeter;
import Components.Meter;
import gfx.io.GameDelegate;

dynamic class HUDMenu extends Shared.PlatformChangeUser
{
	var SavedRolloverText:String = "";
	var ItemInfoArray:Array = new Array();
	var CompassMarkerList:Array = new Array();
	var METER_PAUSE_FRAME:Number = 40;
	
	var HudElements:Array;
	var HUDModes:Array;
	
	var ArrowInfoInstance;
	
	var BottomLeftLockInstance;
	var BottomRightLockInstance;
	
	var BottomRightRefInstance;
	var BottomRightRefX;
	var BottomRightRefY;
	var TopLeftRefInstance;
	var TopLeftRefX;
	var TopLeftRefY;
	
	var CompassMarkerEnemy;
	var CompassMarkerLocations;
	var CompassMarkerPlayerSet;
	var CompassMarkerQuest;
	var CompassMarkerQuestDoor;
	var CompassMarkerUndiscovered;
	var CompassRect;
	var CompassShoutMeterHolder;
	var CompassTargetDataA;
	var CompassThreeSixtyX;
	var CompassZeroX;
	
	var bCrosshairEnabled:Boolean;
	var Crosshair;
	var CrosshairAlert;
	var CrosshairInstance;
	
	var EnemyHealthMeter;
	var EnemyHealth_mc;
	
	var FavorBackButtonBase;
	var FavorBackButton_mc;
	var FloatingQuestMarkerInstance;
	var FloatingQuestMarker_mc;
	
	var GrayBarInstance;
	
	
	
	
	var LocationLockBase;
	
	
	
	var MessagesBlock;
	var MessagesInstance;
	var QuestUpdateBaseInstance;
	
	
	var ActivateButton_tf:TextField;
	var RolloverButton_tf:TextField;
	var RolloverGrayBar_mc;
	var RolloverInfoInstance;
	var RolloverInfoText;
	var RolloverNameInstance:TextField;
	var RolloverText:TextField;
	
	var Health:MovieClip;
	var HealthMeterAnim:MovieClip;
	var Magica:MovieClip;
	var MagickaMeterAnim:MovieClip;
	var Stamina:MovieClip;
	var StaminaMeterAnim:MovieClip;
	
	var HealthMeterLeft:BlinkOnEmptyMeter;
	var MagickaMeter:BlinkOnDemandMeter;
	var StaminaMeter:BlinkOnDemandMeter;
	
	var ShoutMeter_mc:ShoutMeter;
	
	var LeftChargeMeter:Meter;
	var LeftChargeMeterAnim;
	
	var RightChargeMeter:Meter;
	var RightChargeMeterAnim;
	
	
	var StealthMeterInstance;
	var SubtitleText;
	var SubtitleTextHolder;
	
	var TutorialHintsArtHolder;
	var TutorialHintsText;
	var TutorialLockInstance;
	var ValueTranslated:TextField;
	var WeightTranslated:TextField;
	

	function HUDMenu()
	{
		super();
		Shared.GlobalFunc.MaintainTextFormat();
		Shared.GlobalFunc.AddReverseFunctions();
		Key.addListener(this);
		MagickaMeter = new BlinkOnDemandMeter(Magica.MagickaMeter_mc, Magica.MagickaFlashInstance);
		HealthMeterLeft = new BlinkOnEmptyMeter(Health.HealthMeter_mc.HealthLeft);
		StaminaMeter = new BlinkOnDemandMeter(Stamina.StaminaMeter_mc, Stamina.StaminaFlashInstance);
		ShoutMeter_mc = new ShoutMeter(CompassShoutMeterHolder.ShoutMeterInstance, CompassShoutMeterHolder.ShoutWarningInstance);
		
		LeftChargeMeter = new Meter(BottomLeftLockInstance.LeftHandChargeMeterInstance.ChargeMeter_mc);
		RightChargeMeter = new Meter(BottomRightLockInstance.RightHandChargeMeterInstance.ChargeMeter_mc);
		
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
		
		EnemyHealthMeter = new Meter(EnemyHealth_mc);
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

	function RegisterComponents()
	{
		GameDelegate.call("RegisterHUDComponents", [this, HudElements, QuestUpdateBaseInstance, EnemyHealthMeter, StealthMeterInstance, StealthMeterInstance.SneakAnimInstance, EnemyHealth_mc.BracketsInstance, EnemyHealth_mc.BracketsInstance.RolloverNameInstance, StealthMeterInstance.SneakTextHolder, StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance]);
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		FavorBackButton_mc.FavorBackButtonInstance.SetPlatform(aiPlatform, abPS3Switch);
	}

	function SetModes()
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
		MessagesBlock.CartMode = true;
		SubtitleTextHolder.CartMode = true;
		TutorialLockInstance.CartMode = true;
	}

	function ShowElements(aMode, abShow)
	{
		var __reg4 = "All";
		if (abShow) 
		{
			__reg3 = HUDModes.length - 1;
			while (__reg3 >= 0) 
			{
				if (HUDModes[__reg3] == aMode) 
				{
					HUDModes.splice(__reg3, 1);
				}
				--__reg3;
			}
			HUDModes.push(aMode);
			__reg4 = aMode;
		}
		else 
		{
			if (aMode.length > 0) 
			{
				var __reg6 = false;
				var __reg3 = HUDModes.length - 1;
				while (__reg3 >= 0 && !__reg6) 
				{
					if (HUDModes[__reg3] == aMode) 
					{
						HUDModes.splice(__reg3, 1);
						__reg6 = true;
					}
					--__reg3;
				}
			}
			else 
			{
				HUDModes.pop();
			}
			if (HUDModes.length > 0) 
			{
				__reg4 = String(HUDModes[HUDModes.length - 1]);
			}
		}
		var __reg2 = 0;
		for (;;) 
		{
			if (__reg2 >= HudElements.length) 
			{
				return;
			}
			if (HudElements[__reg2] != undefined) 
			{
				HudElements[__reg2]._visible = HudElements[__reg2].hasOwnProperty(__reg4);
				if (HudElements[__reg2].onModeChange != undefined) 
				{
					HudElements[__reg2].onModeChange(__reg4);
				}
			}
			++__reg2;
		}
	}

	function SetLocationName(aLocation)
	{
		LocationLockBase.LocationNameBase.LocationTextBase.LocationTextInstance.SetText(aLocation);
		LocationLockBase.LocationNameBase.gotoAndPlay(1);
	}

	function CheckAgainstHudMode(aObj)
	{
		var __reg2 = "All";
		
		if (HUDModes.length > 0) 
		{
			__reg2 = String(HUDModes[HUDModes.length - 1]);
		}
		return __reg2 == "All" || (aObj != undefined && aObj.hasOwnProperty(__reg2));
	}

	function InitExtensions()
	{
		var __reg4 = QuestUpdateBaseInstance._y - CompassShoutMeterHolder._y;
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
		
		var __reg2 = {x: TopLeftRefInstance.LocationRefInstance._x, y: TopLeftRefInstance.LocationRefInstance._y};
		TopLeftRefInstance.localToGlobal(__reg2);
		TopLeftRefX = __reg2.x;
		TopLeftRefY = __reg2.y;
		
		var __reg3 = {x: BottomRightRefInstance.LocationRefInstance._x, y: BottomRightRefInstance.LocationRefInstance._y};
		BottomRightRefInstance.localToGlobal(__reg3);
		BottomRightRefX = __reg3.x;
		BottomRightRefY = __reg3.y;
		
		CompassShoutMeterHolder.Lock("T");
		EnemyHealth_mc.Lock("T");
		MessagesBlock.Lock("TL");
		QuestUpdateBaseInstance._y = CompassShoutMeterHolder._y + __reg4;
		SubtitleTextHolder.Lock("B");
		SubtitleText._visible = false;
		SubtitleText.enabled = true;
		SubtitleText.verticalAutoSize = "bottom";
		SubtitleText.SetText(" ", true);
		RolloverText.verticalAutoSize = "top";
		RolloverText.html = true;
		
		GameDelegate.addCallBack("SetCrosshairTarget", this, "SetCrosshairTarget");
		GameDelegate.addCallBack("SetLoadDoorInfo", this, "SetLoadDoorInfo");
		GameDelegate.addCallBack("ShowMessage", this, "ShowMessage");
		GameDelegate.addCallBack("ShowSubtitle", this, "ShowSubtitle");
		GameDelegate.addCallBack("HideSubtitle", this, "HideSubtitle");
		GameDelegate.addCallBack("SetCrosshairEnabled", this, "SetCrosshairEnabled");
		GameDelegate.addCallBack("SetSubtitlesEnabled", this, "SetSubtitlesEnabled");
		GameDelegate.addCallBack("SetHealthMeterPercent", this, "SetHealthMeterPercent");
		GameDelegate.addCallBack("SetMagickaMeterPercent", this, "SetMagickaMeterPercent");
		GameDelegate.addCallBack("SetStaminaMeterPercent", this, "SetStaminaMeterPercent");
		GameDelegate.addCallBack("SetShoutMeterPercent", this, "SetShoutMeterPercent");
		GameDelegate.addCallBack("FlashShoutMeter", this, "FlashShoutMeter");
		GameDelegate.addCallBack("SetChargeMeterPercent", this, "SetChargeMeterPercent");
		GameDelegate.addCallBack("StartMagickaMeterBlinking", this, "StartMagickaBlinking");
		GameDelegate.addCallBack("StartStaminaMeterBlinking", this, "StartStaminaBlinking");
		GameDelegate.addCallBack("FadeOutStamina", this, "FadeOutStamina");
		GameDelegate.addCallBack("FadeOutChargeMeters", this, "FadeOutChargeMeters");
		GameDelegate.addCallBack("SetCompassAngle", this, "SetCompassAngle");
		GameDelegate.addCallBack("SetCompassMarkers", this, "SetCompassMarkers");
		GameDelegate.addCallBack("SetEnemyHealthPercent", EnemyHealthMeter, "SetPercent");
		GameDelegate.addCallBack("SetEnemyHealthTargetPercent", EnemyHealthMeter, "SetTargetPercent");
		GameDelegate.addCallBack("ShowNotification", QuestUpdateBaseInstance, "ShowNotification");
		GameDelegate.addCallBack("ShowElements", this, "ShowElements");
		GameDelegate.addCallBack("SetLocationName", this, "SetLocationName");
		GameDelegate.addCallBack("ShowTutorialHintText", this, "ShowTutorialHintText");
		GameDelegate.addCallBack("ValidateCrosshair", this, "ValidateCrosshair");
	}

	function InitCompass()
	{
		CompassShoutMeterHolder.Compass.gotoAndStop("ThreeSixty");
		CompassThreeSixtyX = CompassRect._x;
		CompassShoutMeterHolder.Compass.gotoAndStop("Zero");
		CompassZeroX = CompassRect._x;
		var __reg2 = CompassRect.attachMovie("Compass Marker", "temp", CompassRect.getNextHighestDepth());
		__reg2.gotoAndStop("Quest");
		CompassMarkerQuest = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.gotoAndStop("QuestDoor");
		CompassMarkerQuestDoor = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.gotoAndStop("PlayerSet");
		CompassMarkerPlayerSet = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.gotoAndStop("Enemy");
		CompassMarkerEnemy = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.gotoAndStop("LocationMarkers");
		CompassMarkerLocations = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.gotoAndStop("UndiscoveredMarkers");
		CompassMarkerUndiscovered = __reg2._currentframe == undefined ? 0 : __reg2._currentframe;
		__reg2.removeMovieClip();
	}

	function RunMeterAnim(aMeter)
	{
		aMeter.PlayForward(aMeter._currentframe);
	}

	function FadeOutMeter(aMeter)
	{
		if (aMeter._currentframe > METER_PAUSE_FRAME) 
		{
			aMeter.gotoAndStop("Pause");
		}
		aMeter.PlayReverse();
	}

	function FadeOutStamina(aPercent)
	{
		FadeOutMeter(Stamina);
		StaminaMeter.CurrentPercent = aPercent;
		StaminaMeter.TargetPercent = aPercent;
	}

	function FadeOutChargeMeters()
	{
		FadeOutMeter(LeftChargeMeterAnim);
		FadeOutMeter(RightChargeMeterAnim);
	}

	function SetChargeMeterPercent(aPercent, abForce, abLeftHand, abShow)
	{
		var __reg2 = abLeftHand ? LeftChargeMeter : RightChargeMeter;
		var __reg3 = abLeftHand ? LeftChargeMeterAnim : RightChargeMeterAnim;
		if (!abShow) 
		{
			__reg3.gotoAndStop(1);
			return;
		}
		if (abForce) 
		{
			RunMeterAnim(__reg3);
			__reg2.SetPercent(aPercent);
			__reg2.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(__reg3);
		__reg2.SetTargetPercent(aPercent);
		__reg2.SetTargetPercent(aPercent);
	}

	function SetHealthMeterPercent(aPercent, abForce)
	{
		if (abForce) 
		{
			HealthMeterLeft.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(HealthMeterAnim);
		HealthMeterLeft.SetTargetPercent(aPercent);
	}

	function SetMagickaMeterPercent(aPercent, abForce)
	{
		if (abForce) 
		{
			MagickaMeter.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(MagickaMeterAnim);
		MagickaMeter.SetTargetPercent(aPercent);
	}

	function SetStaminaMeterPercent(aPercent, abForce)
	{
		if (abForce) 
		{
			StaminaMeter.SetPercent(aPercent);
			return;
		}
		RunMeterAnim(StaminaMeterAnim);
		StaminaMeter.SetTargetPercent(aPercent);
	}

	function SetShoutMeterPercent(aPercent, abForce)
	{
		ShoutMeter_mc.SetPercent(aPercent);
	}

	function FlashShoutMeter()
	{
		ShoutMeter_mc.FlashMeter();
	}

	function StartMagickaBlinking()
	{
		MagickaMeter.StartBlinking();
	}

	function StartStaminaBlinking()
	{
		StaminaMeter.StartBlinking();
	}

	function SetCompassAngle(aPlayerAngle, aCompassAngle, abShowCompass)
	{
		CompassRect._parent._visible = abShowCompass;
		if (abShowCompass) 
		{
			var __reg2 = Shared.GlobalFunc.Lerp(CompassZeroX, CompassThreeSixtyX, 0, 360, aCompassAngle);
			CompassRect._x = __reg2;
			UpdateCompassMarkers(aPlayerAngle);
		}
	}

	function SetCrosshairTarget(abActivate:Boolean, aName:String, abShowButton:Boolean, abTextOnly:Boolean, abFavorMode:Boolean, abShowCrosshair:Boolean, aWeight:Number, aCost:Number, aFieldValue, aFieldText)
	{
		var favorNoTargetLabel = abFavorMode ? "Favor" : "NoTarget";
		var favorTargetLabel = abFavorMode ? "Favor" : "Target";
		
		var currentCrosshair = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		
		currentCrosshair._visible = CheckAgainstHudMode(currentCrosshair) && abShowCrosshair != false;
		currentCrosshair._alpha = bCrosshairEnabled ? 100 : 0;
		
		if (!abActivate && SavedRolloverText.length > 0) {
			currentCrosshair.gotoAndStop(favorNoTargetLabel);
			RolloverText.SetText(SavedRolloverText, true);
			RolloverText._alpha = 100;
			RolloverButton_tf._alpha = 0;
		} else if (abTextOnly || abActivate) {
			if (!abTextOnly) 
			{
				currentCrosshair.gotoAndStop(favorTargetLabel);
			}
			RolloverText.SetText(aName, true);
			RolloverText._alpha = 100;
			RolloverButton_tf._alpha = abShowButton ? 100 : 0;
			RolloverButton_tf._x = RolloverText._x + RolloverText.getLineMetrics(0).x - 103;
		}
		else 
		{
			currentCrosshair.gotoAndStop(favorNoTargetLabel);
			RolloverText.SetText(" ", true);
			RolloverText._alpha = 0;
			RolloverButton_tf._alpha = 0;
		}
		var newText = "";
		
		if (aCost != undefined) 
		{
			newText = ValueTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aCost) + "</font>" + newText;
		}
		if (aWeight != undefined) 
		{
			newText = WeightTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Shared.GlobalFunc.RoundDecimal(aWeight, 1) + "</font>	  " + newText;
		}
		if (aFieldValue != undefined) 
		{
			var tf = new TextField();
			tf.text = aFieldText.toString();
			newText = tf.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aFieldValue) + "</font>	  " + newText;
		}
		if (newText.length > 0) 
		{
			RolloverGrayBar_mc._alpha = 100;
		}
		else 
		{
			RolloverGrayBar_mc._alpha = 0;
		}
		RolloverInfoText.htmlText = newText;
	}

	function RefreshActivateButtonArt(astrButtonName)
	{
		if (astrButtonName == undefined) 
		{
			RolloverButton_tf.SetText(" ", true);
			return;
		}
		
		var bitmap = flash.display.BitmapData.loadBitmap(astrButtonName + ".png");
		if (bitmap != undefined && bitmap.height > 0) 
		{
			var h = 26;
			var w = Math.floor(h / bitmap.height * bitmap.width);
			RolloverButton_tf.SetText("<img src=\'" + astrButtonName + ".png\' height=\'" + h + "\' width=\'" + w + "\'>", true);
			return;
		}
		RolloverButton_tf.SetText(" ", true);
	}

	function SetLoadDoorInfo(abShow, aDoorName)
	{
		if (abShow) 
		{
			SavedRolloverText = aDoorName;
			SetCrosshairTarget(true, SavedRolloverText, false, true, false);
			return;
		}
		SavedRolloverText = "";
		SetCrosshairTarget(false, SavedRolloverText, false, false, false);
	}

	function SetSubtitlesEnabled(abEnable)
	{
		SubtitleText.enabled = abEnable;
		if (!abEnable) 
		{
			SubtitleText._visible = false;
			return;
		}
		if (SubtitleText.htmlText != " ") 
		{
			SubtitleText._visible = true;
		}
	}

	function ShowMessage(asMessage)
	{
		MessagesInstance.MessageArray.push(asMessage);
	}

	function ShowSubtitle(astrText)
	{
		SubtitleText.SetText(astrText, true);
		if (SubtitleText.enabled) 
		{
			SubtitleText._visible = true;
		}
	}

	function HideSubtitle()
	{
		SubtitleText.SetText(" ", true);
		SubtitleText._visible = false;
	}

	function ShowArrowCount(aCount, abHide, aArrows)
	{
		var frame = 15;
		if (abHide) 
		{
			if (ArrowInfoInstance._currentframe > frame) 
			{
				ArrowInfoInstance.gotoAndStop(frame);
			}
			ArrowInfoInstance.PlayReverse();
			return;
		}
		ArrowInfoInstance.PlayForward(ArrowInfoInstance._currentframe);
		ArrowInfoInstance.ArrowCountInstance.ArrowNumInstance.SetText(aArrows + " (" + aCount.toString() + ")");
	}

	function onEnterFrame()
	{
		MagickaMeter.Update();
		HealthMeterLeft.Update();
		StaminaMeter.Update();
		EnemyHealthMeter.Update();
		LeftChargeMeter.Update();
		RightChargeMeter.Update();
		MessagesInstance.Update();
	}

	function SetCompassMarkers()
	{
		var __reg12 = 0;
		var __reg13 = 1;
		var __reg7 = 2;
		var __reg9 = 3;
		var __reg6 = 4;
		while (CompassMarkerList.length > CompassTargetDataA.length / __reg6) 
		{
			CompassMarkerList.pop().movie.removeMovieClip();
		}
		var __reg2 = 0;
		for (;;) 
		{
			if (__reg2 >= CompassTargetDataA.length / __reg6) 
			{
				return;
			}
			var __reg3 = __reg2 * __reg6;
			if (CompassMarkerList[__reg2].movie == undefined) 
			{
				__reg5 = {movie: undefined, heading: 0};
				if (CompassTargetDataA[__reg3 + __reg7] == CompassMarkerQuest || CompassTargetDataA[__reg3 + __reg7] == CompassMarkerQuestDoor) 
				{
					__reg5.movie = CompassRect.QuestHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.QuestHolder.getNextHighestDepth());
				}
				else 
				{
					__reg5.movie = CompassRect.MarkerHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.MarkerHolder.getNextHighestDepth());
				}
				CompassMarkerList.push(__reg5);
			}
			else 
			{
				var __reg4 = CompassMarkerList[__reg2].movie._currentframe;
				if (__reg4 == CompassMarkerQuest || __reg4 == CompassMarkerQuestDoor) 
				{
					if (CompassMarkerList[__reg2].movie._parent == CompassRect.MarkerHolder) 
					{
						__reg5 = {movie: undefined, heading: 0};
						__reg5.movie = CompassRect.QuestHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.QuestHolder.getNextHighestDepth());
						__reg8 = CompassMarkerList.splice(__reg2, 1, __reg5);
						__reg8[0].movie.removeMovieClip();
					}
				}
				else if (CompassMarkerList[__reg2].movie._parent == CompassRect.QuestHolder) 
				{
					var __reg5 = {movie: undefined, heading: 0};
					__reg5.movie = CompassRect.MarkerHolder.attachMovie("Compass Marker", "CompassMarker" + CompassMarkerList.length, CompassRect.MarkerHolder.getNextHighestDepth());
					var __reg8 = CompassMarkerList.splice(__reg2, 1, __reg5);
					__reg8[0].movie.removeMovieClip();
				}
			}
			CompassMarkerList[__reg2].heading = CompassTargetDataA[__reg3 + __reg12];
			CompassMarkerList[__reg2].movie._alpha = CompassTargetDataA[__reg3 + __reg13];
			CompassMarkerList[__reg2].movie.gotoAndStop(CompassTargetDataA[__reg3 + __reg7]);
			CompassMarkerList[__reg2].movie._xscale = CompassTargetDataA[__reg3 + __reg9];
			CompassMarkerList[__reg2].movie._yscale = CompassTargetDataA[__reg3 + __reg9];
			++__reg2;
		}
	}

	function UpdateCompassMarkers(aiCenterAngle)
	{
		var __reg12 = CompassShoutMeterHolder.Compass.CompassMask_mc._width;
		var __reg9 = __reg12 * 180 / Math.abs(CompassThreeSixtyX - CompassZeroX);
		var __reg5 = aiCenterAngle - __reg9;
		var __reg7 = aiCenterAngle + __reg9;
		var __reg10 = 0 - CompassRect._x - __reg12 / 2;
		var __reg11 = 0 - CompassRect._x + __reg12 / 2;
		var __reg3 = 0;
		for (;;) 
		{
			if (__reg3 >= CompassMarkerList.length) 
			{
				return;
			}
			var __reg2 = CompassMarkerList[__reg3].heading;
			if (__reg5 < 0 && __reg2 > 360 - aiCenterAngle - __reg9) 
			{
				__reg2 = __reg2 - 360;
			}
			if (__reg7 > 360 && __reg2 < __reg9 - (360 - aiCenterAngle)) 
			{
				__reg2 = __reg2 + 360;
			}
			if (__reg2 > __reg5 && __reg2 < __reg7) 
			{
				CompassMarkerList[__reg3].movie._x = Shared.GlobalFunc.Lerp(__reg10, __reg11, __reg5, __reg7, __reg2);
			}
			else 
			{
				var __reg4 = CompassMarkerList[__reg3].movie._currentframe;
				if (__reg4 == CompassMarkerQuest || __reg4 == CompassMarkerQuestDoor) 
				{
					var __reg8 = Math.sin((__reg2 - aiCenterAngle) * 3.14159265359 / 180);
					CompassMarkerList[__reg3].movie._x = __reg8 <= 0 ? __reg10 + 2 : __reg11;
				}
				else 
				{
					CompassMarkerList[__reg3].movie._x = 0;
				}
			}
			++__reg3;
		}
	}

	function ShowTutorialHintText(astrHint, abShow)
	{
		if (abShow) 
		{
			TutorialHintsText.text = astrHint;
			var __reg2 = TutorialHintsArtHolder.CreateButtonArt(TutorialHintsText);
			if (__reg2 != undefined) 
			{
				TutorialHintsText.html = true;
				TutorialHintsText.htmlText = __reg2;
			}
		}
		if (abShow) 
		{
			TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeIn");
			return;
		}
		TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeOut");
	}

	function SetCrosshairEnabled(abFlag)
	{
		bCrosshairEnabled = abFlag;
		var __reg2 = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		__reg2._alpha = bCrosshairEnabled ? 100 : 0;
	}

	function ValidateCrosshair()
	{
		var __reg2 = _currentframe == 1 ? CrosshairInstance : CrosshairAlert;
		__reg2._visible = CheckAgainstHudMode(__reg2);
		StealthMeterInstance._visible = CheckAgainstHudMode(StealthMeterInstance);
	}

}

