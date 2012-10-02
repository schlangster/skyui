import gfx.io.GameDelegate;
import Components.Meter;

import skyui.components.ButtonPanel;


class BottomBar extends MovieClip
{
  /* PRIVATE VARIABLES */	
  
	private var _lastItemType: Number;
	
	private var _healthMeter: Meter;
	private var _magickaMeter: Meter;
	private var _staminaMeter: Meter;
	private var _levelMeter: Meter;

	private var _playerInfoObj: Object;
	
	
  /* STAGE ELEMENTS */

	public var playerInfoCard: MovieClip;
	
	
  /* PROPERTIES */
  
	public var buttonPanel: ButtonPanel;
	
	
  /* INITIALIZATION */

	public function BottomBar()
	{
		super();
		_lastItemType = InventoryDefines.ICT_NONE;
		_healthMeter = new Meter(playerInfoCard.HealthRect.MeterInstance.Meter_mc);
		_magickaMeter = new Meter(playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
		_staminaMeter = new Meter(playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
		_levelMeter = new Meter(playerInfoCard.LevelMeterInstance.Meter_mc);
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function positionElements(a_leftOffset: Number, a_rightOffset: Number): Void
	{
		buttonPanel._x = a_leftOffset;
		buttonPanel.positionButtons();
		playerInfoCard._x = a_rightOffset - playerInfoCard._width;
	}

	public function showPlayerInfo(): Void
	{
		playerInfoCard._alpha = 100;
	}

	public function hidePlayerInfo(): Void
	{
		playerInfoCard._alpha = 0;
	}

	public function updatePerItemInfo(a_itemUpdateObj: Object): Void
	{
		var infoCard = playerInfoCard;
		var itemType: Number = a_itemUpdateObj.type;
		var bHasWeightandValue = true;
		
		if (itemType == undefined) {
			itemType = _lastItemType;
			if (a_itemUpdateObj == undefined)
				a_itemUpdateObj = {type: _lastItemType};
		} else {
			_lastItemType = itemType;
		}
		if (_playerInfoObj != undefined && a_itemUpdateObj != undefined) {
			switch(itemType) {
				case InventoryDefines.ICT_ARMOR:
					infoCard.gotoAndStop("Armor");
					var strArmor: String = Math.floor(_playerInfoObj.armor).toString();
					if (a_itemUpdateObj.armorChange != undefined) {
						var iArmorDelta = Math.round(a_itemUpdateObj.armorChange);
						if (iArmorDelta > 0) 
							strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
						else if (iArmorDelta < 0) 
							strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
					}
					infoCard.ArmorRatingValue.textAutoSize = "shrink";
					infoCard.ArmorRatingValue.html = true;
					infoCard.ArmorRatingValue.SetText(strArmor, true);
					break;
					
				case InventoryDefines.ICT_WEAPON:
					infoCard.gotoAndStop("Weapon");
					var strDamage: String = Math.floor(_playerInfoObj.damage).toString();
					if (a_itemUpdateObj.damageChange != undefined) {
						var iDamageDelta = Math.round(a_itemUpdateObj.damageChange);
						if (iDamageDelta > 0) 
							strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
						else if (iDamageDelta < 0) 
							strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
					}
					infoCard.DamageValue.textAutoSize = "shrink";
					infoCard.DamageValue.html = true;
					infoCard.DamageValue.SetText(strDamage, true);
					break;
					
				case InventoryDefines.ICT_POTION:
				case InventoryDefines.ICT_FOOD:
					var EF_HEALTH: Number = 0;
					var EF_MAGICKA: Number = 1;
					var EF_STAMINA: Number = 2;
					if (a_itemUpdateObj.potionType == EF_MAGICKA) 
						infoCard.gotoAndStop("MagickaPotion");
					else if (a_itemUpdateObj.potionType == EF_STAMINA) 
						infoCard.gotoAndStop("StaminaPotion");
					else if (a_itemUpdateObj.potionType == EF_HEALTH) 
						infoCard.gotoAndStop("HealthPotion");
					break;
					
				case InventoryDefines.ICT_SPELL_DEFAULT:
				case InventoryDefines.ICT_ACTIVE_EFFECT:
					infoCard.gotoAndStop("Magic");
					bHasWeightandValue = false;
					break;
					
				case InventoryDefines.ICT_SPELL:
					infoCard.gotoAndStop("MagicSkill");
					if (a_itemUpdateObj.magicSchoolName != undefined) 
						updateSkillBar(a_itemUpdateObj.magicSchoolName, a_itemUpdateObj.magicSchoolLevel, a_itemUpdateObj.magicSchoolPct);
					bHasWeightandValue = false;
					break;
					
				case InventoryDefines.ICT_SHOUT:
					infoCard.gotoAndStop("Shout");
					infoCard.DragonSoulTextInstance.SetText(_playerInfoObj.dragonSoulText);
					bHasWeightandValue = false;
					break;
					
				case InventoryDefines.ICT_BOOK:
				case InventoryDefines.ICT_INGREDIENT:
				case InventoryDefines.ICT_MISC:
				case InventoryDefines.ICT_KEY:
				default:
					infoCard.gotoAndStop("Default");
			}
			
			if (bHasWeightandValue) {
				infoCard.CarryWeightValue.textAutoSize = "shrink";
				infoCard.CarryWeightValue.SetText(Math.ceil(_playerInfoObj.encumbrance) + "/" + Math.floor(_playerInfoObj.maxEncumbrance));
				infoCard.PlayerGoldValue.SetText(_playerInfoObj.gold.toString());
				infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
				infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
				infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;
				if (itemType === InventoryDefines.ICT_ARMOR) {
					infoCard.ArmorRatingValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.ArmorRatingValue._width - 5;
					infoCard.ArmorRatingLabel._x = infoCard.ArmorRatingValue._x + infoCard.ArmorRatingValue.getLineMetrics(0).x - infoCard.ArmorRatingLabel._width;
				} else if (itemType === InventoryDefines.ICT_WEAPON) {
					infoCard.DamageValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.DamageValue._width - 5;
					infoCard.DamageLabel._x = infoCard.DamageValue._x + infoCard.DamageValue.getLineMetrics(0).x - infoCard.DamageLabel._width;
				}
			}
			updateStatMeter(infoCard.HealthRect, _healthMeter, _playerInfoObj.health, _playerInfoObj.maxHealth, _playerInfoObj.healthColor);
			updateStatMeter(infoCard.MagickaRect, _magickaMeter, _playerInfoObj.magicka, _playerInfoObj.maxMagicka, _playerInfoObj.magickaColor);
			updateStatMeter(infoCard.StaminaRect, _staminaMeter, _playerInfoObj.stamina, _playerInfoObj.maxStamina, _playerInfoObj.staminaColor);
		}
	}

	public function updatePlayerInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object): Void
	{
		_playerInfoObj = a_playerUpdateObj;
		updatePerItemInfo(a_itemUpdateObj);
	}

	public function updateCraftingInfo(a_skillName: String, a_levelStart: Number, a_levelPercent: Number): Void
	{
		playerInfoCard.gotoAndStop("Crafting");
		updateSkillBar(a_skillName, a_levelStart, a_levelPercent);
	}

	public function setBarterInfo(a_playerGold: Number, a_vendorGold: Number, a_goldDelta: Number, a_vendorName: String): Void
	{
		var infoCard = playerInfoCard;
		
		if (infoCard._currentframe == 1) 
			infoCard.gotoAndStop("Barter");
		infoCard.PlayerGoldValue.textAutoSize = "shrink";
		infoCard.VendorGoldValue.textAutoSize = "shrink";
		if (a_goldDelta == undefined) 
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString(), true);
		else if (a_goldDelta >= 0) 
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>", true);
		else 
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>", true);
		infoCard.VendorGoldValue.SetText(a_vendorGold.toString());
		if (a_vendorName != undefined) {
			infoCard.VendorGoldLabel.SetText("$Gold");
			infoCard.VendorGoldLabel.SetText(a_vendorName + " " + infoCard.VendorGoldLabel.text);
		}
		infoCard.VendorGoldLabel._x = infoCard.VendorGoldValue._x + infoCard.VendorGoldValue.getLineMetrics(0).x - infoCard.VendorGoldLabel._width - 5;
		infoCard.PlayerGoldValue._x = infoCard.VendorGoldLabel._x + infoCard.VendorGoldLabel.getLineMetrics(0).x - infoCard.PlayerGoldValue._width - 20;
		infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width - 5;
	}

	public function setBarterPerItemInfo(a_itemUpdateObj: Object, a_playerInfoObj: Object): Void
	{
		var infoCard = playerInfoCard;
		
		if (a_itemUpdateObj != undefined) {
			var itemType: Number = a_itemUpdateObj.type;
			
			switch(itemType) {
				case InventoryDefines.ICT_ARMOR:
					infoCard.gotoAndStop("Barter_Armor");
					var strArmor: String = Math.floor(a_playerInfoObj.armor).toString();
					if (a_itemUpdateObj.armorChange != undefined) {
						var iArmorDelta: Number = Math.round(a_itemUpdateObj.armorChange);
						if (iArmorDelta > 0) 
							strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
						else if (iArmorDelta < 0) 
							strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
					}
					infoCard.ArmorRatingValue.textAutoSize = "shrink";
					infoCard.ArmorRatingValue.html = true;
					infoCard.ArmorRatingValue.SetText(strArmor, true);
					break;
					
				case InventoryDefines.ICT_WEAPON:
					infoCard.gotoAndStop("Barter_Weapon");
					var strDamage: String = Math.floor(a_playerInfoObj.damage).toString();
					if (a_itemUpdateObj.damageChange != undefined) {
						var iDamageDelta: Number = Math.round(a_itemUpdateObj.damageChange);
						if (iDamageDelta > 0) 
							strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
						else if (iDamageDelta < 0) 
							strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
					}
					infoCard.DamageValue.textAutoSize = "shrink";
					infoCard.DamageValue.html = true;
					infoCard.DamageValue.SetText(strDamage, true);
					break;
					
				default:
					infoCard.gotoAndStop("Barter");
			}
		}
	}

	public function setGiftInfo(a_favorPoints: Number): Void
	{
		playerInfoCard.gotoAndStop("Gift");
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}


  /* PRIVATE FUNCTIONS */
	
	private function updateStatMeter(a_meterRect: MovieClip, a_meterObj: Meter, a_currValue: Number, a_maxValue: Number, a_colorStr: String): Void
	{
		if (a_colorStr == undefined) 
			a_colorStr = "#FFFFFF";
		if (a_meterRect._alpha > 0) {
			if (a_meterRect.MeterText != undefined) {
				a_meterRect.MeterText.textAutoSize = "shrink";
				a_meterRect.MeterText.html = true;
				a_meterRect.MeterText.SetText("<font color=\'" + a_colorStr + "\'>" + Math.floor(a_currValue) + "/" + Math.floor(a_maxValue) + "</font>", true);
			}
			a_meterRect.MeterInstance.gotoAndStop("Pause");
			a_meterObj.SetPercent(a_currValue / a_maxValue * 100);
		}
	}
	
	private function updateSkillBar(a_skillName: String, a_levelStart: Number, a_levelPercent: Number): Void
	{
		var infoCard = playerInfoCard;
		
		infoCard.SkillLevelLabel.SetText(a_skillName);
		infoCard.SkillLevelCurrent.SetText(a_levelStart);
		infoCard.SkillLevelNext.SetText(a_levelStart + 1);
		infoCard.LevelMeterInstance.gotoAndStop("Pause");
		_levelMeter.SetPercent(a_levelPercent);
	}

}
