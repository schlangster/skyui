class BottomBar extends MovieClip
{
    var PlayerInfoCard_mc;
	var iLastItemType;
	var HealthMeter;
	var MagickaMeter;
	var StaminaMeter;
	var LevelMeter;
	var Buttons;
	var iLeftOffset;
	var PlayerInfoObj;
	
    function BottomBar()
    {
        super();
        PlayerInfoCard_mc = PlayerInfoCard_mc;
        iLastItemType = InventoryDefines.ICT_NONE;
        HealthMeter = new Components.Meter(PlayerInfoCard_mc.HealthRect.MeterInstance.Meter_mc);
        MagickaMeter = new Components.Meter(PlayerInfoCard_mc.MagickaRect.MeterInstance.Meter_mc);
        StaminaMeter = new Components.Meter(PlayerInfoCard_mc.StaminaRect.MeterInstance.Meter_mc);
        LevelMeter = new Components.Meter(PlayerInfoCard_mc.LevelMeterInstance.Meter_mc);
        var _loc3 = 0;
        Buttons = new Array();
        while (this["Button" + _loc3] != undefined)
        {
            Buttons.push(this["Button" + _loc3]);
            ++_loc3;
        }
    }
	
    function PositionElements(aiLeftOffset, aiRightOffset)
    {
        iLeftOffset = aiLeftOffset;
        this.PositionButtons();
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
        var _loc3 = aItemUpdateObj.type;
        var _loc5 = true;
        if (_loc3 != undefined)
        {
            iLastItemType = _loc3;
        }
        else
        {
            _loc3 = iLastItemType;
            if (aItemUpdateObj == undefined)
            {
                aItemUpdateObj = {type: iLastItemType};
            } // end if
        } // end else if
        if (PlayerInfoObj != undefined && aItemUpdateObj != undefined)
        {
            switch (_loc3)
            {
                case InventoryDefines.ICT_ARMOR:
                {
                    PlayerInfoCard_mc.gotoAndStop("Armor");
                    var _loc4 = Math.floor(PlayerInfoObj.armor).toString();
                    if (aItemUpdateObj.armorChange != undefined)
                    {
                        var _loc7 = Math.round(aItemUpdateObj.armorChange);
                        if (_loc7 > 0)
                        {
                            _loc4 = _loc4 + " <font color=\'#189515\'>(+" + _loc7.toString() + ")</font>";
                        }
                        else if (_loc7 < 0)
                        {
                            _loc4 = _loc4 + " <font color=\'#FF0000\'>(" + _loc7.toString() + ")</font>";
                        } // end if
                    } // end else if
                    PlayerInfoCard_mc.ArmorRatingValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.ArmorRatingValue.html = true;
                    PlayerInfoCard_mc.ArmorRatingValue.SetText(_loc4, true);
                    break;
                } 
                case InventoryDefines.ICT_WEAPON:
                {
                    PlayerInfoCard_mc.gotoAndStop("Weapon");
                    _loc4 = Math.floor(PlayerInfoObj.damage).toString();
                    if (aItemUpdateObj.damageChange != undefined)
                    {
                        var _loc6 = Math.round(aItemUpdateObj.damageChange);
                        if (_loc6 > 0)
                        {
                            _loc4 = _loc4 + " <font color=\'#189515\'>(+" + _loc6.toString() + ")</font>";
                        }
                        else if (_loc6 < 0)
                        {
                            _loc4 = _loc4 + " <font color=\'#FF0000\'>(" + _loc6.toString() + ")</font>";
                        } // end if
                    } // end else if
                    PlayerInfoCard_mc.DamageValue.textAutoSize = "shrink";
                    PlayerInfoCard_mc.DamageValue.html = true;
                    PlayerInfoCard_mc.DamageValue.SetText(_loc4, true);
                    break;
                } 
                case InventoryDefines.ICT_POTION:
                case InventoryDefines.ICT_FOOD:
                {
                    var _loc9 = 0;
                    var _loc8 = 1;
                    var _loc10 = 2;
                    if (aItemUpdateObj.potionType == _loc8)
                    {
                        PlayerInfoCard_mc.gotoAndStop("MagickaPotion");
                    }
                    else if (aItemUpdateObj.potionType == _loc10)
                    {
                        PlayerInfoCard_mc.gotoAndStop("StaminaPotion");
                    }
                    else if (aItemUpdateObj.potionType == _loc9)
                    {
                        PlayerInfoCard_mc.gotoAndStop("HealthPotion");
                    } // end else if
                    break;
                } 
                case InventoryDefines.ICT_BOOK:
                case InventoryDefines.ICT_INGREDIENT:
                case InventoryDefines.ICT_MISC:
                case InventoryDefines.ICT_KEY:
                case InventoryDefines.ICT_SPELL_DEFAULT:
                {
                    PlayerInfoCard_mc.gotoAndStop("Default");
                    break;
                } 
                case InventoryDefines.ICT_ACTIVE_EFFECT:
                case InventoryDefines.ICT_SPELL:
                {
                    PlayerInfoCard_mc.gotoAndStop("Magic");
                    _loc5 = false;
                    break;
                } 
                case InventoryDefines.ICT_SHOUT:
                {
                    PlayerInfoCard_mc.gotoAndStop("MagicSkill");
                    if (aItemUpdateObj.magicSchoolName != undefined)
                    {
                        this.UpdateSkillBar(aItemUpdateObj.magicSchoolName, aItemUpdateObj.magicSchoolLevel, aItemUpdateObj.magicSchoolPct);
                    } // end if
                    _loc5 = false;
                    break;
                } 
                default:
                {
                    PlayerInfoCard_mc.gotoAndStop("Shout");
                    PlayerInfoCard_mc.DragonSoulTextInstance.SetText(PlayerInfoObj.dragonSoulText);
                    _loc5 = false;
                    break;
                } 
            } // End of switch
            if (_loc5)
            {
                PlayerInfoCard_mc.CarryWeightValue.textAutoSize = "shrink";
                PlayerInfoCard_mc.CarryWeightValue.SetText(Math.ceil(PlayerInfoObj.encumbrance) + "/" + Math.floor(PlayerInfoObj.maxEncumbrance));
                PlayerInfoCard_mc.PlayerGoldValue.SetText(PlayerInfoObj.gold.toString());
                PlayerInfoCard_mc.PlayerGoldLabel._x = PlayerInfoCard_mc.PlayerGoldValue._x + PlayerInfoCard_mc.PlayerGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldLabel._width;
                PlayerInfoCard_mc.CarryWeightValue._x = PlayerInfoCard_mc.PlayerGoldLabel._x + PlayerInfoCard_mc.PlayerGoldLabel.getLineMetrics(0).x - PlayerInfoCard_mc.CarryWeightValue._width - 5;
                PlayerInfoCard_mc.CarryWeightLabel._x = PlayerInfoCard_mc.CarryWeightValue._x + PlayerInfoCard_mc.CarryWeightValue.getLineMetrics(0).x - PlayerInfoCard_mc.CarryWeightLabel._width;
                switch (_loc3)
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
                } // End of switch
            } // end if
            this.UpdateStatMeter(PlayerInfoCard_mc.HealthRect, HealthMeter, PlayerInfoObj.health, PlayerInfoObj.maxHealth, PlayerInfoObj.healthColor);
            this.UpdateStatMeter(PlayerInfoCard_mc.MagickaRect, MagickaMeter, PlayerInfoObj.magicka, PlayerInfoObj.maxMagicka, PlayerInfoObj.magickaColor);
            this.UpdateStatMeter(PlayerInfoCard_mc.StaminaRect, StaminaMeter, PlayerInfoObj.stamina, PlayerInfoObj.maxStamina, PlayerInfoObj.staminaColor);
        } // end if
    } // End of the function
    function UpdatePlayerInfo(aPlayerUpdateObj, aItemUpdateObj)
    {
        PlayerInfoObj = aPlayerUpdateObj;
        this.UpdatePerItemInfo(aItemUpdateObj);
    } // End of the function
    function UpdateSkillBar(aSkillName, aiLevelStart, afLevelPercent)
    {
        PlayerInfoCard_mc.SkillLevelLabel.SetText(aSkillName);
        PlayerInfoCard_mc.SkillLevelCurrent.SetText(aiLevelStart);
        PlayerInfoCard_mc.SkillLevelNext.SetText(aiLevelStart + 1);
        PlayerInfoCard_mc.LevelMeterInstance.gotoAndStop("Pause");
        LevelMeter.SetPercent(afLevelPercent);
    } // End of the function
    function UpdateCraftingInfo(aSkillName, aiLevelStart, afLevelPercent)
    {
        PlayerInfoCard_mc.gotoAndStop("Crafting");
        this.UpdateSkillBar(aSkillName, aiLevelStart, afLevelPercent);
    } // End of the function
    function UpdateStatMeter(aMeterRect, aMeterObj, aiCurrValue, aiMaxValue, aColor)
    {
        if (aColor == undefined)
        {
            aColor = "#FFFFFF";
        } // end if
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
        } // end if
    } // End of the function
    function SetBarterInfo(aiPlayerGold, aiVendorGold, aiGoldDelta, astrVendorName)
    {
        if (PlayerInfoCard_mc._currentframe == 1)
        {
            PlayerInfoCard_mc.gotoAndStop("Barter");
        } // end if
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
        } // end else if
        PlayerInfoCard_mc.VendorGoldValue.SetText(aiVendorGold.toString());
        if (astrVendorName != undefined)
        {
            PlayerInfoCard_mc.VendorGoldLabel.SetText("$Gold");
            PlayerInfoCard_mc.VendorGoldLabel.SetText(astrVendorName + " " + PlayerInfoCard_mc.VendorGoldLabel.text);
        } // end if
        PlayerInfoCard_mc.VendorGoldLabel._x = PlayerInfoCard_mc.VendorGoldValue._x + PlayerInfoCard_mc.VendorGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.VendorGoldLabel._width - 5;
        PlayerInfoCard_mc.PlayerGoldValue._x = PlayerInfoCard_mc.VendorGoldLabel._x + PlayerInfoCard_mc.VendorGoldLabel.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldValue._width - 20;
        PlayerInfoCard_mc.PlayerGoldLabel._x = PlayerInfoCard_mc.PlayerGoldValue._x + PlayerInfoCard_mc.PlayerGoldValue.getLineMetrics(0).x - PlayerInfoCard_mc.PlayerGoldLabel._width - 5;
    } // End of the function
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
                    } // end else if
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
            } // End of switch
        } // end if
    } // End of the function
    function SetGiftInfo(aiFavorPoints)
    {
        PlayerInfoCard_mc.gotoAndStop("Gift");
    } // End of the function
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        for (var _loc2 = 0; _loc2 < Buttons.length; ++_loc2)
        {
            Buttons[_loc2].SetPlatform(aiPlatform, abPS3Switch);
        } // end of for
    } // End of the function
    function ShowButtons()
    {
        for (var _loc2 = 0; _loc2 < Buttons.length; ++_loc2)
        {
            Buttons[_loc2]._visible = Buttons[_loc2].label.length > 0;
        } // end of for
    } // End of the function
    function HideButtons()
    {
        for (var _loc2 = 0; _loc2 < Buttons.length; ++_loc2)
        {
            Buttons[_loc2]._visible = false;
        } // end of for
    } // End of the function
    function SetButtonsText()
    {
        for (var _loc3 = 0; _loc3 < Buttons.length; ++_loc3)
        {
            Buttons[_loc3].label = _loc3 < arguments.length ? (arguments[_loc3]) : ("");
            Buttons[_loc3]._visible = Buttons[_loc3].label.length > 0;
        } // end of for
        this.PositionButtons();
    } // End of the function
    function SetButtonText(aText, aIndex)
    {
        if (aIndex < Buttons.length)
        {
            Buttons[aIndex].label = aText;
            Buttons[aIndex]._visible = aText.length > 0;
            this.PositionButtons();
        } // end if
    }
	
    function SetButtonsArt(aButtonArt)
    {
        for (var _loc2 = 0; _loc2 < aButtonArt.length; ++_loc2)
        {
            this.SetButtonArt(aButtonArt[_loc2], _loc2);
        } // end of for
    }
	
    function GetButtonsArt()
    {
        var _loc3 = new Array(Buttons.length);
        for (var _loc2 = 0; _loc2 < Buttons.length; ++_loc2)
        {
            _loc3[_loc2] = Buttons[_loc2].GetArt();
        } // end of for
        return (_loc3);
    }
	
    function SetButtonArt(aPlatformArt, aIndex)
    {
        if (aIndex < Buttons.length)
        {
            var _loc2 = Buttons[aIndex];
            _loc2.PCArt = aPlatformArt.PCArt;
            _loc2.XBoxArt = aPlatformArt.XBoxArt;
            _loc2.PS3Art = aPlatformArt.PS3Art;
            _loc2.RefreshArt();
        } // end if
    }
	
    function PositionButtons()
    {
        var _loc4 = 10;
        var _loc3 = iLeftOffset;
        for (var _loc2 = 0; _loc2 < Buttons.length; ++_loc2)
        {
            if (Buttons[_loc2].label.length > 0)
            {
                Buttons[_loc2]._x = _loc3 + Buttons[_loc2].ButtonArt._width;
                _loc3 = Buttons[_loc2]._x + Buttons[_loc2].textField.getLineMetrics(0).width + _loc4;
            } // end if
        } // end of for
    } // End of the function
} // End of Class
