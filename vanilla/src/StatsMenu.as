dynamic class StatsMenu extends MovieClip
{
	static var StatsMenuInstance = null;
	static var MAGICKA_METER: Number = 0;
	static var HEALTH_METER: Number = 1;
	static var STAMINA_METER: Number = 2;
	static var CURRENT_METER_TEXT: Number = 0;
	static var MAX_METER_TEXT: Number = 1;
	static var ALTERATION: Number = 0;
	static var CONJURATION: Number = 1;
	static var DESTRUCTION: Number = 2;
	static var MYSTICISM: Number = 3;
	static var RESTORATION: Number = 4;
	static var ENCHANTING: Number = 5;
	static var LIGHT_ARMOR: Number = 6;
	static var PICKPOCKET: Number = 7;
	static var LOCKPICKING: Number = 8;
	static var SNEAK: Number = 9;
	static var ALCHEMY: Number = 10;
	static var SPEECHCRAFT: Number = 11;
	static var ONE_HANDED_WEAPONS: Number = 12;
	static var TWO_HANDED_WEAPONS: Number = 13;
	static var MARKSMAN: Number = 14;
	static var BLOCK: Number = 15;
	static var SMITHING: Number = 16;
	static var HEAVY_ARMOR: Number = 17;
	static var SkillStatsA = new Array();
	static var PerkNamesA = new Array();
	static var BeginAnimation: Number = 0;
	static var EndAnimation: Number = 1000;
	static var STATS: Number = 0;
	static var LEVEL_UP: Number = 1;
	static var MaxPerkNameHeight: Number = 115;
	static var MaxPerkNameHeightLevelMode: Number = 175;
	static var MaxPerkNamesDisplayed: Number = 64;
	var CameraUpdateInterval: Number = 0;
	var AddPerkButtonInstance;
	var AddPerkTextInstance;
	var BottomBarInstance;
	var CameraMovementInstance;
	var CurrentPerkFrame;
	var DescriptionCardMeter;
	var LevelMeter;
	var PerkEndFrame;
	var PerkName0;
	var PerksLeft;
	var Platform;
	var SkillsListInstance;
	var State;
	var TopPlayerInfo;


	function StatsMenu()
	{
		super();
		StatsMenu.StatsMenuInstance = this;
		this.DescriptionCardMeter = new Components.Meter(StatsMenu.StatsMenuInstance.DescriptionCardInstance.animate);
		StatsMenu.SkillsA = new Array();
		StatsMenu.SkillRing_mc = this.SkillsListInstance;
		this.SetDirection(0);
		var __reg5 = this.BottomBarInstance.BottomBarPlayerInfoInstance.PlayerInfoCardInstance;
		StatsMenu.MagickaMeterBase = __reg5.MagickaMeterInstance;
		StatsMenu.HealthMeterBase = __reg5.HealthMeterInstance;
		StatsMenu.StaminaMeterBase = __reg5.StaminaMeterInstance;
		StatsMenu.MagickaMeter = new Components.Meter(StatsMenu.MagickaMeterBase.MagickaMeter_mc);
		StatsMenu.HealthMeter = new Components.Meter(StatsMenu.HealthMeterBase.HealthMeter_mc);
		StatsMenu.StaminaMeter = new Components.Meter(StatsMenu.StaminaMeterBase.StaminaMeter_mc);
		StatsMenu.MagickaMeterBase.Magicka.gotoAndStop("Pause");
		StatsMenu.HealthMeterBase.Health.gotoAndStop("Pause");
		StatsMenu.StaminaMeterBase.Stamina.gotoAndStop("Pause");
		StatsMenu.MeterText = [__reg5.magicValue, __reg5.healthValue, __reg5.enduranceValue];
		this.SetMeter(StatsMenu.MAGICKA_METER, 50, 100);
		this.SetMeter(StatsMenu.HEALTH_METER, 75, 100);
		this.SetMeter(StatsMenu.STAMINA_METER, 25, 100);
		this.Platform = Shared.ButtonChange.PLATFORM_PC;
		this.AddPerkButtonInstance._alpha = 0;
		var __reg3 = 0;
		while (__reg3 < StatsMenu.MaxPerkNamesDisplayed) 
		{
			var __reg4 = this.attachMovie("PerkName", "PerkName" + __reg3, this.getNextHighestDepth());
			__reg4._x = -100 - this._x;
			++__reg3;
		}
		this.TopPlayerInfo.swapDepths(this.getNextHighestDepth());
		this.SetStatsMode(true, 0);
		this.CurrentPerkFrame = 0;
		this.PerkName0.gotoAndStop("Visible");
		this.PerkEndFrame = this.PerkName0._currentFrame;
		this.PerkName0.gotoAndStop("Invisible");
	}

	function GetSkillClip(aSkillName)
	{
		return this.SkillsListInstance.BaseRingInstance[aSkillName].Val.ValText;
	}

	function UpdatePerkText(abShow)
	{
		var __reg2 = 0;
		if (abShow == true || abShow == undefined) 
		{
			var __reg3 = 0;
			while (__reg3 < StatsMenu.PerkNamesA.length) 
			{
				var __reg4 = false;
				if (StatsMenu.PerkNamesA[__reg3] == undefined) 
				{
					if (!__reg4 && this["PerkName" + __reg2] != undefined) 
					{
						this["PerkName" + __reg2].gotoAndStop("Invisible");
					}
				}
				else if (Shared.GlobalFunc.Lerp(0, 720, 0, 1, StatsMenu.PerkNamesA[__reg3 + 2]) > (this.State == StatsMenu.LEVEL_UP ? StatsMenu.MaxPerkNameHeightLevelMode : StatsMenu.MaxPerkNameHeight)) 
				{
					this["PerkName" + __reg2].PerkNameClipInstance.NameText.html = true;
					this["PerkName" + __reg2].PerkNameClipInstance.NameText.SetText(StatsMenu.PerkNamesA[__reg3], true);
					this["PerkName" + __reg2]._xscale = StatsMenu.PerkNamesA[__reg3 + 2] * 165 + 10;
					this["PerkName" + __reg2]._yscale = StatsMenu.PerkNamesA[__reg3 + 2] * 165 + 10;
					this["PerkName" + __reg2]._x = Shared.GlobalFunc.Lerp(0, 1280, 0, 1, StatsMenu.PerkNamesA[__reg3 + 1]) - this._x;
					this["PerkName" + __reg2]._y = Shared.GlobalFunc.Lerp(0, 720, 0, 1, StatsMenu.PerkNamesA[__reg3 + 2]) - this._y;
					this["PerkName" + __reg2].bPlaying = true;
					if (this["PerkName" + __reg2] != undefined) 
					{
						this["PerkName" + __reg2].gotoAndStop(this.CurrentPerkFrame);
					}
					++__reg2;
					__reg4 = true;
				}
				__reg3 = __reg3 + 3;
			}
			__reg3 = __reg2;
			while (__reg3 <= StatsMenu.MaxPerkNamesDisplayed) 
			{
				if (this["PerkName" + __reg3] != undefined) 
				{
					this["PerkName" + __reg3].gotoAndStop("Invisible");
				}
				++__reg3;
			}
			if (this.CurrentPerkFrame <= this.PerkEndFrame) 
			{
				++this.CurrentPerkFrame;
			}
			return;
		}
		if (abShow == false) 
		{
			this.CurrentPerkFrame = 0;
			__reg3 = 0;
			for (;;) 
			{
				if (__reg3 >= StatsMenu.MaxPerkNamesDisplayed) 
				{
					return;
				}
				if (this["PerkName" + __reg3] != undefined) 
				{
					this["PerkName" + __reg3].gotoAndStop("Invisible");
				}
				++__reg3;
			}
		}
	}

	function InitExtensions()
	{
		Shared.GlobalFunc.SetLockFunction();
		Shared.GlobalFunc.MaintainTextFormat();
		gfx.io.GameDelegate.addCallBack("SetDescriptionCard", this, "SetDescriptionCard");
		gfx.io.GameDelegate.addCallBack("SetPlayerInfo", this, "SetPlayerInfo");
		gfx.io.GameDelegate.addCallBack("UpdateSkillList", this, "UpdateSkillList");
		gfx.io.GameDelegate.addCallBack("SetDirection", this, "SetDirection");
		gfx.io.GameDelegate.addCallBack("HideRing", this, "HideRing");
		gfx.io.GameDelegate.addCallBack("SetStatsMode", this, "SetStatsMode");
		gfx.io.GameDelegate.addCallBack("SetPerkCount", this, "SetPerkCount");
	}

	function SetStatsMode(abStats, aPerkCount)
	{
		this.State = abStats ? StatsMenu.STATS : StatsMenu.LEVEL_UP;
		this.PerksLeft = aPerkCount;
		if (aPerkCount != undefined) 
		{
			this.SetPerkCount(aPerkCount);
		}
	}

	function SetPerkCount(aPerkCount)
	{
		if (aPerkCount > 0) 
		{
			this.AddPerkTextInstance._alpha = 100;
			this.AddPerkTextInstance.AddPerkTextField.text = _root.PerksInstance.text + " " + aPerkCount;
			return;
		}
		this.AddPerkTextInstance._alpha = 0;
	}

	static function SetPlatform(aiPlatformIndex, abPS3Switch)
	{
		StatsMenu.StatsMenuInstance.AddPerkButtonInstance.SetPlatform(aiPlatformIndex, abPS3Switch);
		StatsMenu.StatsMenuInstance.Platform = aiPlatformIndex;
	}

	function UpdateCamera()
	{
		if (StatsMenu.StatsMenuInstance.CameraMovementInstance._currentFrame < 100) 
		{
			var __reg2 = StatsMenu.StatsMenuInstance.CameraMovementInstance._currentFrame + 8;
			if (__reg2 > 100) 
			{
				__reg2 = 100;
			}
			gfx.io.GameDelegate.call("MoveCamera", [this.CameraMovementInstance.CameraPositionAlpha._alpha / 100]);
			return;
		}
		clearInterval(this.CameraUpdateInterval);
		this.CameraUpdateInterval = 0;
	}

	static function StartCameraAnimation()
	{
		clearInterval(StatsMenu.StatsMenuInstance.CameraUpdateInterval);
		gfx.io.GameDelegate.call("MoveCamera", [0]);
		StatsMenu.StatsMenuInstance.CameraUpdateInterval = setInterval(mx.utils.Delegate.create(StatsMenu.StatsMenuInstance, StatsMenu.StatsMenuInstance.UpdateCamera), 41);
	}

	function UpdateSkillList()
	{
		StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.InitAnimatedSkillText(StatsMenu.SkillStatsA);
	}

	function HideRing()
	{
		StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.HideRing();
	}

	function SetDirection(aAngle)
	{
		StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.SetAngle(aAngle);
	}

	function SetPlayerInfo()
	{
		StatsMenu.StatsMenuInstance.TopPlayerInfo.FirstLastLabel.textAutoSize = "shrink";
		StatsMenu.StatsMenuInstance.TopPlayerInfo.FirstLastLabel.SetText(arguments[0]);
		StatsMenu.StatsMenuInstance.TopPlayerInfo.LevelNumberLabel.SetText(arguments[1]);
		if (this.LevelMeter == undefined) 
		{
			this.LevelMeter = new Components.Meter(StatsMenu.StatsMenuInstance.TopPlayerInfo.animate);
		}
		this.LevelMeter.SetPercent(arguments[2]);
		StatsMenu.StatsMenuInstance.TopPlayerInfo.RacevalueLabel.SetText(arguments[3]);
		this.SetMeter(0, arguments[4], arguments[5], arguments[6]);
		this.SetMeter(1, arguments[7], arguments[8], arguments[9]);
		this.SetMeter(2, arguments[10], arguments[11], arguments[12]);
	}

	function SetMeter(aMeter, aCurrentValue, aMaxValue, aColor)
	{
		if (aMeter >= StatsMenu.MAGICKA_METER && aMeter <= StatsMenu.STAMINA_METER) 
		{
			var __reg2 = 100 * (Math.max(0, Math.min(aCurrentValue, aMaxValue)) / aMaxValue);
			if ((__reg0 = aMeter) === StatsMenu.MAGICKA_METER) 
			{
				StatsMenu.MagickaMeter.SetPercent(__reg2);
			}
			else if (__reg0 === StatsMenu.HEALTH_METER) 
			{
				StatsMenu.HealthMeter.SetPercent(__reg2);
			}
			else if (__reg0 === StatsMenu.STAMINA_METER) 
			{
				StatsMenu.StaminaMeter.SetPercent(__reg2);
			}
			StatsMenu.MeterText[aMeter].html = true;
			if (aColor == undefined) 
			{
				StatsMenu.MeterText[aMeter].SetText(aCurrentValue + "/" + aMaxValue, true);
			}
			else 
			{
				StatsMenu.MeterText[aMeter].SetText("<font color=\'" + aColor + "\'>" + aCurrentValue + "/" + aMaxValue + "</font>", true);
			}
			StatsMenu.MagickaMeter.Update();
			StatsMenu.HealthMeter.Update();
			StatsMenu.StaminaMeter.Update();
		}
	}

	function SetDescriptionCard(abPerkMode, aName, aMeterPercent, aDescription, aRequirements, aSkillLevel, aSkill)
	{
		if (StatsMenu.StatsMenuInstance != undefined) 
		{
			StatsMenu.StatsMenuInstance.gotoAndStop(abPerkMode ? "Perks" : "Skills");
		}
		var __reg2 = StatsMenu.StatsMenuInstance.DescriptionCardInstance;
		__reg2.CardDescriptionTextInstance.SetText(aDescription);
		this.AddPerkButtonInstance._alpha = this.State == StatsMenu.LEVEL_UP && abPerkMode && this.Platform != Shared.ButtonChange.PLATFORM_PC ? 100 : 0;
		if (!abPerkMode) 
		{
			__reg2.CardNameTextInstance.html = true;
			__reg2.CardNameTextInstance.htmlText = aName.toUpperCase() + " <font face=\'$EverywhereBoldFont\' size=\'32\' color=\'#FFFFFF\'>" + aSkillLevel + "</font>";
			StatsMenu.StatsMenuInstance.DescriptionCardMeter.SetPercent(aMeterPercent);
			return;
		}
		__reg2.CardNameTextInstance.SetText("");
		__reg2.SkillRequirementText.html = true;
		__reg2.SkillRequirementText.htmlText = aSkill.toUpperCase() + "		  " + aRequirements.toUpperCase();
		if (this.PerksLeft != undefined) 
		{
			this.SetPerkCount(this.PerksLeft);
		}
		__reg2.Perktype.SetText(aSkill);
	}

}
