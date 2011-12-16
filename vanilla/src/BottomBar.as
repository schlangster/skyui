import Components.Meter;

class BottomBar extends MovieClip
{
    var Buttons:Array;
    
    var PlayerInfoCard_mc;
    var iLastItemType;
    
    var HealthMeter:Meter;
    var MagickaMeter:Meter;
    var StaminaMeter:Meter;
    var LevelMeter:Meter;

    var iLeftOffset:Number;
    var PlayerInfoObj;
    
    function BottomBar()
    {
        super();
        
        PlayerInfoCard_mc = PlayerInfoCard_mc;
        iLastItemType = InventoryDefines.ICT_NONE;
        HealthMeter = new Meter(PlayerInfoCard_mc.HealthRect.MeterInstance.Meter_mc);
        MagickaMeter = new Meter(PlayerInfoCard_mc.MagickaRect.MeterInstance.Meter_mc);
        StaminaMeter = new Meter(PlayerInfoCard_mc.StaminaRect.MeterInstance.Meter_mc);
        LevelMeter = new Meter(PlayerInfoCard_mc.LevelMeterInstance.Meter_mc);
        
        var i = 0;
        Buttons = new Array();
        
        while (this["Button" + i] != undefined)
        {
            Buttons.push(this["Button" + i]);
            ++i;
        }
    }
    
    function PositionElements(aiLeftOffset:Number, aiRightOffset:Number)
    {
        iLeftOffset = aiLeftOffset;
        PositionButtons();
        PlayerInfoCard_mc._x = aiRightOffset - PlayerInfoCard_mc._width;
    }
    
    function ShowPlayerInfo()
    {
        PlayerInfoCard_mc._alpha = 100;
    }
    
    function HidePlayerInfo()
    {
        PlayerInfoCard_mc._alpha = 0;
    }
    
    function UpdatePerItemInfo(aItemUpdateObj)
    {
        var type = aItemUpdateObj.type;
        var isEquip = true;
        
        if (type != undefined)
        {
            iLastItemType = type;
        }
        else
        {
            type = iLastItemType;
            if (aItemUpdateObj == undefined)
            {
                aItemUpdateObj = {type: iLastItemType};
            }
        }
        
        if (PlayerInfoObj != undefined && aItemUpdateObj != undefined)
        {
            switch (type)
            {
                case InventoryDefines.ICT_ARMOR:
                {
                    PlayerInfoCard_mc.gotoAndStop("Armor");
                    var armorStr = Math.floor(PlayerInfoObj.armor).toString();
                    
                    if (aItemUpdateObj.armorChange != undefined)
                    {
                        var armorChange = Math.round(aItemUpdateObj.armorChange);
                        if (armorChange > 0)
                        {
                            armorStr = armorStr + " <font color=\'#189515\'>(+" + armorChange.toString() + ")</font>";
                        }
                        else if (armorChange < 0)
                        {
                            armorStr = armorStr + " <font color=\'#FF0000\'>(" + armorChange.toString() + ")</font>";
                        }
                    }
                    
                    PlayerInfoCard_mc.ArmorRatingValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.ArmorRatingValue.html = true;
                    PlayerInfoCard_mc.ArmorRatingValue.SetText(armorStr, true);
                    break;
                } 
                case InventoryDefines.ICT_WEAPON:
                {
                    PlayerInfoCard_mc.gotoAndStop("Weapon");
                    var dmgStr = Math.floor(PlayerInfoObj.damage).toString();
                    
                    if (aItemUpdateObj.damageChange != undefined)
                    {
                        var _loc6 = Math.round(aItemUpdateObj.damageChange);
                        if (_loc6 > 0)
                        {
                            dmgStr = dmgStr + " <font color=\'#189515\'>(+" + _loc6.toString() + ")</font>";
                        }
                        else if (_loc6 < 0)
                        {
                            dmgStr = dmgStr + " <font color=\'#FF0000\'>(" + _loc6.toString() + ")</font>";
                        }
                    }
                    
                    PlayerInfoCard_mc.DamageValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.DamageValue.html = true;
                    PlayerInfoCard_mc.DamageValue.SetText(dmgStr, true);
                    break;
                } 
                case InventoryDefines.ICT_POTION:
                case InventoryDefines.ICT_FOOD:
                {
                    if (aItemUpdateObj.potionType == 1)
                    {
                        PlayerInfoCard_mc.gotoAndStop("MagickaPotion");
                    }
                    else if (aItemUpdateObj.potionType == 2)
                    {
                        PlayerInfoCard_mc.gotoAndStop("StaminaPotion");
                    }
                    else if (aItemUpdateObj.potionType == 0)
                    {
                        PlayerInfoCard_mc.gotoAndStop("HealthPotion");
                    }
                    
                    break;
                } 
                case InventoryDefines.ICT_BOOK:
                case InventoryDefines.ICT_INGREDIENT:
                case InventoryDefines.ICT_MISC:
                case InventoryDefines.ICT_KEY:
                {
                    PlayerInfoCard_mc.gotoAndStop("Default");
                    break;
                } 
                case InventoryDefines.ICT_SPELL_DEFAULT:
                case InventoryDefines.ICT_ACTIVE_EFFECT:
                {
                    PlayerInfoCard_mc.gotoAndStop("Magic");
                    isEquip = false;
                    break;
                }
                case InventoryDefines.ICT_SPELL:
                {
                    PlayerInfoCard_mc.gotoAndStop("MagicSkill");
                    if (aItemUpdateObj.magicSchoolName != undefined)
                    {
                        UpdateSkillBar(aItemUpdateObj.magicSchoolName, aItemUpdateObj.magicSchoolLevel, aItemUpdateObj.magicSchoolPct);
                    }
                    isEquip = false;
                    break;
                } 
                case InventoryDefines.ICT_SHOUT:
                {
                    PlayerInfoCard_mc.gotoAndStop("Shout");
                    PlayerInfoCard_mc.DragonSoulTextInstance.SetText(PlayerInfoObj.dragonSoulText);
                    isEquip = false;
                    break;
                }
                default:
                {
                    PlayerInfoCard_mc.gotoAndStop("Default");
                } 
            }
            
            if (isEquip)
            {
                PlayerInfoCard_mc.CarryWeightValue.textAutoSize = "shrink";
                PlayerInfoCard_mc.CarryWeightValue.SetText(Math.ceil(PlayerInfoObj.encumbrance) + "/" + Math.floor(PlayerInfoObj.maxEncumbrance));
                PlayerInfoCard_mc.PlayerGoldValue.SetText(PlayerInfoObj.gold.toString());
                PlayerInfoCard_mc.PlayerGoldLabel._x = PlayerInfoCard_mc.PlayerGoldValue._x + PlayerInfoCard_mc.PlayerGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldLabel._width;
                PlayerInfoCard_mc.CarryWeightValue._x = PlayerInfoCard_mc.PlayerGoldLabel._x + PlayerInfoCard_mc.PlayerGoldLabel.getLineMetrics(0).x - PlayerInfoCard_mc.CarryWeightValue._width - 5;
                PlayerInfoCard_mc.CarryWeightLabel._x = PlayerInfoCard_mc.CarryWeightValue._x + PlayerInfoCard_mc.CarryWeightValue.getLineMetrics(0).x - PlayerInfoCard_mc.CarryWeightLabel._width;
                
                switch (type)
                {
                    case InventoryDefines.ICT_ARMOR:
                    {
                        PlayerInfoCard_mc.ArmorRatingValue._x = PlayerInfoCard_mc.CarryWeightLabel._x + PlayerInfoCard_mc.CarryWeightLabel.getLineMetrics(0).x - PlayerInfoCard_mc.ArmorRatingValue._width - 5;
                        PlayerInfoCard_mc.ArmorRatingLabel._x = PlayerInfoCard_mc.ArmorRatingValue._x + PlayerInfoCard_mc.ArmorRatingValue.getLineMetrics(0).x - PlayerInfoCard_mc.ArmorRatingLabel._width;
                        break;
                    } 
                    case InventoryDefines.ICT_WEAPON:
                    {
                        PlayerInfoCard_mc.DamageValue._x = PlayerInfoCard_mc.CarryWeightLabel._x + PlayerInfoCard_mc.CarryWeightLabel.getLineMetrics(0).x - PlayerInfoCard_mc.DamageValue._width - 5;
                        PlayerInfoCard_mc.DamageLabel._x = PlayerInfoCard_mc.DamageValue._x + PlayerInfoCard_mc.DamageValue.getLineMetrics(0).x - PlayerInfoCard_mc.DamageLabel._width;
                        break;
                    } 
                }
            }
            
            UpdateStatMeter(PlayerInfoCard_mc.HealthRect, HealthMeter, PlayerInfoObj.health, PlayerInfoObj.maxHealth, PlayerInfoObj.healthColor);
            UpdateStatMeter(PlayerInfoCard_mc.MagickaRect, MagickaMeter, PlayerInfoObj.magicka, PlayerInfoObj.maxMagicka, PlayerInfoObj.magickaColor);
            UpdateStatMeter(PlayerInfoCard_mc.StaminaRect, StaminaMeter, PlayerInfoObj.stamina, PlayerInfoObj.maxStamina, PlayerInfoObj.staminaColor);
        }
    }
    
    function UpdatePlayerInfo(aPlayerUpdateObj, aItemUpdateObj)
    {
        PlayerInfoObj = aPlayerUpdateObj;
        UpdatePerItemInfo(aItemUpdateObj);
    }
    
    function UpdateSkillBar(aSkillName, aiLevelStart:Number, afLevelPercent:Number)
    {
        PlayerInfoCard_mc.SkillLevelLabel.SetText(aSkillName);
        PlayerInfoCard_mc.SkillLevelCurrent.SetText(aiLevelStart);
        PlayerInfoCard_mc.SkillLevelNext.SetText(aiLevelStart + 1);
        PlayerInfoCard_mc.LevelMeterInstance.gotoAndStop("Pause");
        LevelMeter.SetPercent(afLevelPercent);
    }
    
    function UpdateCraftingInfo(aSkillName, aiLevelStart:Number, afLevelPercent:Number)
    {
        PlayerInfoCard_mc.gotoAndStop("Crafting");
        UpdateSkillBar(aSkillName, aiLevelStart, afLevelPercent);
    }
    
    function UpdateStatMeter(aMeterRect, aMeterObj, aiCurrValue:Number, aiMaxValue:Number, aColor)
    {
        if (aColor == undefined)
        {
            aColor = "#FFFFFF";
        }
        
        if (aMeterRect._alpha > 0)
        {
            if (aMeterRect.MeterText != undefined)
            {
                aMeterRect.MeterText.textAutoSize = "shrink";
                aMeterRect.MeterText.html = true;
                aMeterRect.MeterText.SetText("<font color=\'" + aColor + "\'>" + Math.floor(aiCurrValue) + "/" + Math.floor(aiMaxValue) + "</font>", true);
            } // end if
            aMeterRect.MeterInstance.gotoAndStop("Pause");
            aMeterObj.SetPercent(aiCurrValue / aiMaxValue * 100);
        }
    }
    
    function SetBarterInfo(aiPlayerGold:Number, aiVendorGold:Number, aiGoldDelta:Number, astrVendorName:String)
    {
        if (PlayerInfoCard_mc._currentframe == 1)
        {
            PlayerInfoCard_mc.gotoAndStop("Barter");
        }
        
        PlayerInfoCard_mc.PlayerGoldValue.textAutoSize = "shrink";
        PlayerInfoCard_mc.VendorGoldValue.textAutoSize = "shrink";
        
        if (aiGoldDelta == undefined)
        {
            PlayerInfoCard_mc.PlayerGoldValue.SetText(aiPlayerGold.toString(), true);
        }
        else if (aiGoldDelta >= 0)
        {
            PlayerInfoCard_mc.PlayerGoldValue.SetText(aiPlayerGold.toString() + " <font color=\'#189515\'>(+" + aiGoldDelta.toString() + ")</font>", true);
        }
        else
        {
            PlayerInfoCard_mc.PlayerGoldValue.SetText(aiPlayerGold.toString() + " <font color=\'#FF0000\'>(" + aiGoldDelta.toString() + ")</font>", true);
        }
        
        PlayerInfoCard_mc.VendorGoldValue.SetText(aiVendorGold.toString());
        
        if (astrVendorName != undefined)
        {
            PlayerInfoCard_mc.VendorGoldLabel.SetText("$Gold");
            PlayerInfoCard_mc.VendorGoldLabel.SetText(astrVendorName + " " + PlayerInfoCard_mc.VendorGoldLabel.text);
        }
        
        PlayerInfoCard_mc.VendorGoldLabel._x = PlayerInfoCard_mc.VendorGoldValue._x + PlayerInfoCard_mc.VendorGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.VendorGoldLabel._width - 5;
        PlayerInfoCard_mc.PlayerGoldValue._x = PlayerInfoCard_mc.VendorGoldLabel._x + PlayerInfoCard_mc.VendorGoldLabel.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldValue._width - 20;
        PlayerInfoCard_mc.PlayerGoldLabel._x = PlayerInfoCard_mc.PlayerGoldValue._x + PlayerInfoCard_mc.PlayerGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldLabel._width - 5;
    }
    
    function SetBarterPerItemInfo(aItemUpdateObj, aPlayerInfoObj)
    {
        if (aItemUpdateObj != undefined)
        {
            switch (aItemUpdateObj.type)
            {
                case InventoryDefines.ICT_ARMOR:
                {
                    PlayerInfoCard_mc.gotoAndStop("Barter_Armor");
                    var _loc2 = Math.floor(aPlayerInfoObj.armor).toString();
                    if (aItemUpdateObj.armorChange != undefined)
                    {
                        var _loc4 = Math.round(aItemUpdateObj.armorChange);
                        if (_loc4 > 0)
                        {
                            _loc2 = _loc2 + " <font color=\'#189515\'>(+" + _loc4.toString() + ")</font>";
                        }
                        else if (_loc4 < 0)
                        {
                            _loc2 = _loc2 + " <font color=\'#FF0000\'>(" + _loc4.toString() + ")</font>";
                        } // end if
                    }
                    
                    PlayerInfoCard_mc.ArmorRatingValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.ArmorRatingValue.html = true;
                    PlayerInfoCard_mc.ArmorRatingValue.SetText(_loc2, true);
                    break;
                } 
                case InventoryDefines.ICT_WEAPON:
                {
                    PlayerInfoCard_mc.gotoAndStop("Barter_Weapon");
                    _loc2 = Math.floor(aPlayerInfoObj.damage).toString();
                    if (aItemUpdateObj.damageChange != undefined)
                    {
                        var _loc3 = Math.round(aItemUpdateObj.damageChange);
                        if (_loc3 > 0)
                        {
                            _loc2 = _loc2 + " <font color=\'#189515\'>(+" + _loc3.toString() + ")</font>";
                        }
                        else if (_loc3 < 0)
                        {
                            _loc2 = _loc2 + " <font color=\'#FF0000\'>(" + _loc3.toString() + ")</font>";
                        } // end if
                    } // end else if
                    PlayerInfoCard_mc.DamageValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.DamageValue.html = true;
                    PlayerInfoCard_mc.DamageValue.SetText(_loc2, true);
                    break;
                } 
                default:
                {
                    PlayerInfoCard_mc.gotoAndStop("Barter");
                    break;
                } 
            }
        }
    }
    
    function SetGiftInfo(aiFavorPoints:Number)
    {
        PlayerInfoCard_mc.gotoAndStop("Gift");
    }
    
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        for (var i = 0; i < Buttons.length; ++i)
        {
            Buttons[i].SetPlatform(aiPlatform, abPS3Switch);
        }
    }
    
    function ShowButtons()
    {
        for (var i = 0; i < Buttons.length; ++i)
        {
            Buttons[i]._visible = Buttons[i].label.length > 0;
        }
    }
    
    function HideButtons()
    {
        for (var i = 0; i < Buttons.length; ++i)
        {
            Buttons[i]._visible = false;
        }
    }
    
    function SetButtonsText()
    {
        for (var i = 0; i < Buttons.length; ++i)
        {
            Buttons[i].label = i < arguments.length ? (arguments[i]) : ("");
            Buttons[i]._visible = Buttons[i].label.length > 0;
        }
        
        PositionButtons();
    }
    
    function SetButtonText(aText, aIndex)
    {
        if (aIndex < Buttons.length)
        {
            Buttons[aIndex].label = aText;
            Buttons[aIndex]._visible = aText.length > 0;
            PositionButtons();
        }
    }
    
    function SetButtonsArt(aButtonArt)
    {
        for (var i = 0; i < aButtonArt.length; ++i)
        {
            SetButtonArt(aButtonArt[i], i);
        }
    }
    
    function GetButtonsArt()
    {
        var a = new Array(Buttons.length);
        for (var i = 0; i < Buttons.length; ++i)
        {
            a[i] = Buttons[i].GetArt();
        }
        
        return a;
    }
    
    function SetButtonArt(aPlatformArt, aIndex:Number)
    {
        if (aIndex < Buttons.length)
        {
            var button = Buttons[aIndex];
            button.PCArt = aPlatformArt.PCArt;
            button.XBoxArt = aPlatformArt.XBoxArt;
            button.PS3Art = aPlatformArt.PS3Art;
            button.RefreshArt();
        }
    }
    
    function PositionButtons()
    {
        var spacing = 10;
        var curPos = iLeftOffset;
        
        for (var i = 0; i < Buttons.length; ++i)
        {
            if (Buttons[i].label.length > 0)
            {
                Buttons[i]._x = curPos + Buttons[i].ButtonArt._width;
                curPos = Buttons[i]._x + Buttons[i].textField.getLineMetrics(0).width + spacing;
            }
        }
    }
}
