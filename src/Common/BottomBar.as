import gfx.io.GameDelegate;
import Components.Meter;

class BottomBar extends MovieClip
{
  /* PRIVATE VARIABLES */	
  
	private var _lastItemType: Number;
	private var _leftOffset: Number;
	

	
	private var _healthMeter: Meter;
	private var _magickaMeter: Meter;
	private var _staminaMeter: Meter;
	private var _levelMeter: Meter;

	private var _playerInfoObj: Object;
	
	
  /* STAGE ELEMENTS */

	public var playerInfoCard: MovieClip;
	
	
  /* PROPERTIES */
  
	public var buttons: Array;
	
	
  /* INITIALIZATION */

	public function BottomBar()
	{
		super();
		_lastItemType = InventoryDefines.ICT_NONE;
		_healthMeter = new Meter(playerInfoCard.HealthRect.MeterInstance.Meter_mc);
		_magickaMeter = new Meter(playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
		_staminaMeter = new Meter(playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
		_levelMeter = new Meter(playerInfoCard.LevelMeterInstance.Meter_mc);
		buttons = [];
		
		for (var i: Number = 0; this["button" + i] != undefined; i++)
			buttons.push(this["button" + i]);
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function positionElements(a_leftOffset: Number, a_rightOffset: Number): Void
	{
		_leftOffset = a_leftOffset;
		positionButtons();
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

	public function updateCraftingInfo(aSkillName: String, aiLevelStart: Number, afLevelPercent: Number): Void
	{
		playerInfoCard.gotoAndStop("Crafting");
		updateSkillBar(aSkillName, aiLevelStart, afLevelPercent);
	}

	public function setBarterInfo(aiPlayerGold: Number, aiVendorGold: Number, aiGoldDelta: Number, astrVendorName: String): Void
	{
		var infoCard = playerInfoCard;
		
		if (infoCard._currentframe == 1) 
			infoCard.gotoAndStop("Barter");
		infoCard.PlayerGoldValue.textAutoSize = "shrink";
		infoCard.VendorGoldValue.textAutoSize = "shrink";
		if (aiGoldDelta == undefined) 
			infoCard.PlayerGoldValue.SetText(aiPlayerGold.toString(), true);
		else if (aiGoldDelta >= 0) 
			infoCard.PlayerGoldValue.SetText(aiPlayerGold.toString() + " <font color=\'#189515\'>(+" + aiGoldDelta.toString() + ")</font>", true);
		else 
			infoCard.PlayerGoldValue.SetText(aiPlayerGold.toString() + " <font color=\'#FF0000\'>(" + aiGoldDelta.toString() + ")</font>", true);
		infoCard.VendorGoldValue.SetText(aiVendorGold.toString());
		if (astrVendorName != undefined) {
			infoCard.VendorGoldLabel.SetText("$Gold");
			infoCard.VendorGoldLabel.SetText(astrVendorName + " " + infoCard.VendorGoldLabel.text);
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

	public function setGiftInfo(aiFavorPoints: Number): Void
	{
		playerInfoCard.gotoAndStop("Gift");
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		for (var i: Number = 0; i < buttons.length; i++)
			buttons[i].SetPlatform(a_platform, a_bPS3Switch);
	}

	public function showButtons(): Void
	{
		for (var i: Number = 0; i < buttons.length; i++)
			buttons[i]._visible = buttons[i].label.length > 0;
	}

	public function hideButtons(): Void
	{
		for (var i: Number = 0; i < buttons.length; i++)
			buttons[i]._visible = false;
	}

	public function setButtonsText(): Void
	{
		for (var i: Number = 0; i < buttons.length; i++) {
			buttons[i].label = i >= arguments.length ? "" : arguments[i];
			buttons[i]._visible = buttons[i].label.length > 0;
		}
		positionButtons();
	}

	public function setButtonText(a_text: String, a_index: Number): Void
	{
		if (a_index < buttons.length) {
			buttons[a_index].label = a_text;
			buttons[a_index]._visible = a_text.length > 0;
			positionButtons();
		}
	}

	public function setButtonsArt(a_buttonArt: Object): Void
	{
		for (var i: Number = 0; i < a_buttonArt.length; i++)
			setButtonArt(a_buttonArt[i], i);
	}

	public function getButtonsArt(): Array
	{
		var ButtonsArt = new Array(buttons.length);
		for (var i: Number = 0; i < buttons.length; i++)
			ButtonsArt[i] = buttons[i].GetArt();
		return ButtonsArt;
	}

	function getButtonArt(a_index: Number): Object
	{
		if (a_index < buttons.length) 
			return buttons[a_index].GetArt();
		return undefined;
	}

	function setButtonArt(a_platformArt: Object, a_index: Number): Void
	{
		if (a_index < buttons.length) {
			var aButton = buttons[a_index];
			aButton.PCArt = a_platformArt.PCArt;
			aButton.XBoxArt = a_platformArt.XBoxArt;
			aButton.PS3Art = a_platformArt.PS3Art;
			aButton.RefreshArt();
		}
	}


  /* PRIVATE FUNCTIONS */

	private function positionButtons(): Void
	{
		var rightOffset: Number = 10;
		var LeftOffset: Number = _leftOffset;
		
		for (var i: Number = 0; i < buttons.length; i++) {
			if (buttons[i].label.length > 0) {
				buttons[i]._x = LeftOffset + buttons[i].ButtonArt._width;
				if (buttons[i].ButtonArt2 != undefined) 
					buttons[i]._x = buttons[i]._x + buttons[i].ButtonArt2._width;
				LeftOffset = buttons[i]._x + buttons[i].textField.getLineMetrics(0).width + rightOffset;
			}
		}
	}
	
	private function updateStatMeter(aMeterRect: MovieClip, aMeterObj: Components.Meter, aiCurrValue: Number, aiMaxValue: Number, aColor: String): Void
	{
		if (aColor == undefined) 
			aColor = "#FFFFFF";
		if (aMeterRect._alpha > 0) {
			if (aMeterRect.MeterText != undefined) {
				aMeterRect.MeterText.textAutoSize = "shrink";
				aMeterRect.MeterText.html = true;
				aMeterRect.MeterText.SetText("<font color=\'" + aColor + "\'>" + Math.floor(aiCurrValue) + "/" + Math.floor(aiMaxValue) + "</font>", true);
			}
			aMeterRect.MeterInstance.gotoAndStop("Pause");
			aMeterObj.SetPercent(aiCurrValue / aiMaxValue * 100);
		}
	}
	
	private function updateSkillBar(aSkillName: String, aiLevelStart: Number, afLevelPercent: Number): Void
	{
		var infoCard = playerInfoCard;
		
		infoCard.SkillLevelLabel.SetText(aSkillName);
		infoCard.SkillLevelCurrent.SetText(aiLevelStart);
		infoCard.SkillLevelNext.SetText(aiLevelStart + 1);
		infoCard.LevelMeterInstance.gotoAndStop("Pause");
		_levelMeter.SetPercent(afLevelPercent);
	}

}
