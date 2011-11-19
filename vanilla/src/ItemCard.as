import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

class ItemCard extends MovieClip
{
    var QuantitySlider_mc;
	var ButtonRect; 
	var ButtonRect_mc;
	var CardList_mc;
	var ItemList;
	var bFadedIn;
	var InputHandler;
	var bEditNameMode;
	var ItemName;
	var ItemText;
	
	var ItemCardMeters;
	var LastUpdateObj;
	var ApparelArmorValue;
	var ApparelEnchantedLabel;
	var SkillTextInstance;
	var WeaponChargeMeter;
	var PoisonInstance;
	var WeaponDamageValue;
	var WeaponEnchantedLabel;
	var BookDescriptionLabel;
	var PotionsLabel;
	var MagicEffectsLabel;
	var MagicCostValue; 
	var MagicCostTimeValue;
	var MagicCostLabel;
	var MagicCostTimeLabel;
	var MagicCostPerSec;
	var SkillLevelText;
	var ShoutEffectsLabel;
	var ShoutCostValue;
	var ActiveEffectTimeValue;
	var SecsText; SoulLevel;
	var ListChargeMeter;
	var ChargeMeter_Default;
	var TotalChargesValue;
	var ChargeMeter_Weapon;
	var ChargeMeter_SoulGem;
	var ChargeMeter_Enchantment;
	var EnchantmentLabel;
	var Enchanting_Background;
	var Enchanting_Slim_Background;
	var ItemValueText;
	var ItemWeightText;
	var StolenTextInstance;
	var EnchantingSlider_mc;
	var PrevFocus;
	var dispatchEvent;
	var SliderValueText;
	var MessageText;
	
    function ItemCard()
    {
        super();
        GlobalFunc.MaintainTextFormat();
        GlobalFunc.AddReverseFunctions();
        EventDispatcher.initialize(this);
        QuantitySlider_mc = QuantitySlider_mc;
        ButtonRect_mc = ButtonRect;
        ItemList = CardList_mc.List_mc;
        SetupItemName();
        bFadedIn = false;
        InputHandler = undefined;
        bEditNameMode = false;
    }
	
    function GetItemName()
    {
        return ItemName;
    }
	
    function SetupItemName(aPrevName)
    {
        ItemName = ItemText.ItemTextField;
        if (ItemName != undefined)
        {
            ItemName.textAutoSize = "shrink";
            ItemName.htmlText = aPrevName;
            ItemName.selectable = false;
        }
    }
	
    function onLoad()
    {
        QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
        ButtonRect_mc.AcceptMouseButton.addEventListener("click", this, "onAcceptMouseClick");
        ButtonRect_mc.CancelMouseButton.addEventListener("click", this, "onCancelMouseClick");
        ButtonRect_mc.AcceptMouseButton.SetPlatform(0, false);
        ButtonRect_mc.CancelMouseButton.SetPlatform(0, false);
    }
	
    function SetPlatform(aiPlatform, abPS3Switch)
    {
        ButtonRect_mc.AcceptGamepadButton._visible = aiPlatform != 0;
        ButtonRect_mc.CancelGamepadButton._visible = aiPlatform != 0;
        ButtonRect_mc.AcceptMouseButton._visible = aiPlatform == 0;
        ButtonRect_mc.CancelMouseButton._visible = aiPlatform == 0;
		
        if (aiPlatform != 0)
        {
            ButtonRect_mc.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
            ButtonRect_mc.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
        }
        ItemList.SetPlatform(aiPlatform, abPS3Switch);
    }
	
    function onAcceptMouseClick()
    {
        if (ButtonRect_mc._alpha == 100 && ButtonRect_mc.AcceptMouseButton._visible == true && InputHandler != undefined)
        {
            var _loc2 = {value: "keyDown", navEquivalent: NavigationCode.ENTER};
            InputHandler(_loc2);
        }
    }
	
    function onCancelMouseClick()
    {
        if (ButtonRect_mc._alpha == 100 && ButtonRect_mc.CancelMouseButton._visible == true && InputHandler != undefined)
        {
            var _loc2 = {value: "keyDown", navEquivalent: NavigationCode.TAB};
            InputHandler(_loc2);
        } // end if
    }
	
    function FadeInCard()
    {
        if (!bFadedIn)
        {
            _visible = true;
            _parent.gotoAndPlay("fadeIn");
            bFadedIn = true;
        }
    }
	
    function FadeOutCard()
    {
        if (bFadedIn)
        {
            _parent.gotoAndPlay("fadeOut");
            bFadedIn = false;
        }
    }
	
    function get quantitySlider()
    {
        return (QuantitySlider_mc);
    }
	
    function get weaponChargeMeter()
    {
        return (ItemCardMeters[InventoryDefines.ICT_WEAPON]);
    }
	
    function get itemInfo()
    {
        return (LastUpdateObj);
    }
	
    function set itemInfo(aUpdateObj)
    {
        ItemCardMeters = new Array();
        var _loc12 = ItemName != undefined ? (ItemName.htmlText) : ("");
        switch (aUpdateObj.type)
        {
            case InventoryDefines.ICT_ARMOR:
            {
                if (aUpdateObj.effects.length == 0)
                {
                    gotoAndStop("Apparel_reg");
                }
                else
                {
                    gotoAndStop("Apparel_Enchanted");
                }
                ApparelArmorValue.textAutoSize = "shrink";
                ApparelArmorValue.SetText(aUpdateObj.armor);
                ApparelEnchantedLabel.htmlText = aUpdateObj.effects;
                SkillTextInstance.text = aUpdateObj.skillText;
                break;
            } 
            case InventoryDefines.ICT_WEAPON:
            {
                if (aUpdateObj.effects.length == 0)
                {
                    gotoAndStop("Weapons_reg");
                }
                else
                {
                    gotoAndStop("Weapons_Enchanted");
                    if (ItemCardMeters[InventoryDefines.ICT_WEAPON] == undefined)
                    {
                        ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(WeaponChargeMeter.MeterInstance);
                    }
                    ItemCardMeters[InventoryDefines.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                    ItemCardMeters[InventoryDefines.ICT_WEAPON].SetDeltaPercent(aUpdateObj.charge);
                }
                var _loc13 = aUpdateObj.poisoned == true ? ("On") : ("Off");
                PoisonInstance.gotoAndStop(_loc13);
                WeaponDamageValue.SetText(aUpdateObj.damage);
                WeaponEnchantedLabel.textAutoSize = "shrink";
                WeaponEnchantedLabel.htmlText = aUpdateObj.effects;
                break;
            } 
            case InventoryDefines.ICT_BOOK:
            {
                if (aUpdateObj.description != undefined && aUpdateObj.description != "")
                {
                    gotoAndStop("Books_Description");
                    BookDescriptionLabel.SetText(aUpdateObj.description);
                }
                else
                {
                    gotoAndStop("Books_reg");
                }
                break;
            } 
            case InventoryDefines.ICT_POTION:
            case InventoryDefines.ICT_FOOD:
            {
                gotoAndStop("Potions_reg");
                PotionsLabel.textAutoSize = "shrink";
                PotionsLabel.htmlText = aUpdateObj.effects;
                SkillTextInstance.text = aUpdateObj.skillName != undefined ? (aUpdateObj.skillName) : ("");
                break;
            } 
            case InventoryDefines.ICT_SPELL_DEFAULT:
            {
                var _loc11 = aUpdateObj.castTime == 0;
				
                if (!_loc11)
                {
                    gotoAndStop("Power_reg");
                }
                else
                {
                    gotoAndStop("Power_time_label");
                }
                MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                MagicEffectsLabel.textAutoSize = "shrink";
				
                if (aUpdateObj.spellCost <= 0)
                {
                    MagicCostValue._alpha = 0;
                    MagicCostTimeValue._alpha = 0;
                    MagicCostLabel._alpha = 0;
                    MagicCostTimeLabel._alpha = 0;
                    MagicCostPerSec._alpha = 0;
                }
                else if (!_loc11)
                {
                    MagicCostValue._alpha = 100;
                    MagicCostLabel._alpha = 100;
                    MagicCostValue.text = aUpdateObj.spellCost.toString();
                }
                else
                {
                    MagicCostTimeValue._alpha = 100;
                    MagicCostTimeLabel._alpha = 100;
                    MagicCostPerSec._alpha = 100;
                    MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
                }
                break;
            } 
            case InventoryDefines.ICT_SPELL:
            {
                _loc11 = aUpdateObj.castTime == 0;
                if (!_loc11)
                {
                    gotoAndStop("Magic_reg");
                }
                else
                {
                    gotoAndStop("Magic_time_label");
                }
                SkillLevelText.text = aUpdateObj.castLevel.toString();
                MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                MagicEffectsLabel.textAutoSize = "shrink";
                MagicCostValue.textAutoSize = "shrink";
                MagicCostTimeValue.textAutoSize = "shrink";
                if (!_loc11)
                {
                    MagicCostValue.text = aUpdateObj.spellCost.toString();
                }
                else
                {
                    MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
                }
                break;
            } 
            case InventoryDefines.ICT_INGREDIENT:
            {
                gotoAndStop("Ingredients_reg");
                for (var _loc4 = 0; _loc4 < 4; ++_loc4)
                {
                    this["EffectLabel" + _loc4].textAutoSize = "shrink";
                    if (aUpdateObj["itemEffect" + _loc4] != undefined && aUpdateObj["itemEffect" + _loc4] != "")
                    {
                        this["EffectLabel" + _loc4].textColor = 16777215;
                        this["EffectLabel" + _loc4].SetText(aUpdateObj["itemEffect" + _loc4]);
                        continue;
                    } // end if
                    if (_loc4 < aUpdateObj.numItemEffects)
                    {
                        this["EffectLabel" + _loc4].textColor = 10066329;
                        this["EffectLabel" + _loc4].SetText("$UNKNOWN");
                        continue;
                    } // end if
                    this["EffectLabel" + _loc4].SetText("");
                }
                break;
            } 
            case InventoryDefines.ICT_MISC:
            {
                gotoAndStop("Misc_reg");
                break;
            } 
            case InventoryDefines.ICT_SHOUT:
            {
                gotoAndStop("Shouts_reg");
                var _loc9 = 0;
                for (var _loc3 = 0; _loc3 < 3; ++_loc3)
                {
                    if (aUpdateObj["word" + _loc3] != undefined && aUpdateObj["word" + _loc3] != "" && aUpdateObj["unlocked" + _loc3] == true)
                    {
                        _loc9 = _loc3;
                    }
                }
                for (var _loc3 = 0; _loc3 < 3; ++_loc3)
                {
                    var _loc7 = aUpdateObj["dragonWord" + _loc3] == undefined ? ("") : (aUpdateObj["dragonWord" + _loc3]);
                    var _loc6 = aUpdateObj["word" + _loc3] == undefined ? ("") : (aUpdateObj["word" + _loc3]);
                    var _loc5 = aUpdateObj["unlocked" + _loc3] == true;
                    this["ShoutTextInstance" + _loc3].DragonShoutLabelInstance.ShoutWordsLabel.textAutoSize = "shrink";
                    this["ShoutTextInstance" + _loc3].ShoutLabelInstance.ShoutWordsLabelTranslation.textAutoSize = "shrink";
                    this["ShoutTextInstance" + _loc3].DragonShoutLabelInstance.ShoutWordsLabel.SetText(_loc7.toUpperCase());
                    this["ShoutTextInstance" + _loc3].ShoutLabelInstance.ShoutWordsLabelTranslation.SetText(_loc6);
                    if (_loc5 && _loc3 == _loc9 && LastUpdateObj.soulSpent == true)
                    {
                        this["ShoutTextInstance" + _loc3].gotoAndPlay("Learn");
                        continue;
                    }
					
                    if (_loc5)
                    {
                        this["ShoutTextInstance" + _loc3].gotoAndStop("Known");
                        this["ShoutTextInstance" + _loc3].gotoAndStop("Known");
                        continue;
                    } // end if
                    this["ShoutTextInstance" + _loc3].gotoAndStop("Unlocked");
                    this["ShoutTextInstance" + _loc3].gotoAndStop("Unlocked");
                }
                ShoutEffectsLabel.htmlText = aUpdateObj.effects;
                ShoutCostValue.text = aUpdateObj.spellCost.toString();
                break;
            } 
            case InventoryDefines.ICT_ACTIVE_EFFECT:
            {
                gotoAndStop("ActiveEffects");
                MagicEffectsLabel.html = true;
                MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                MagicEffectsLabel.textAutoSize = "shrink";
                if (aUpdateObj.timeRemaining > 0)
                {
                    var _loc8 = Math.floor(aUpdateObj.timeRemaining);
                    ActiveEffectTimeValue._alpha = 100;
                    SecsText._alpha = 100;
                    if (_loc8 >= 3600)
                    {
                        _loc8 = Math.floor(_loc8 / 3600);
                        ActiveEffectTimeValue.text = _loc8.toString();
                        if (_loc8 == 1)
                        {
                            SecsText.text = "$hour";
                        }
                        else
                        {
                            SecsText.text = "$hours";
                        }
                    }
                    else if (_loc8 >= 60)
                    {
                        _loc8 = Math.floor(_loc8 / 60);
                        ActiveEffectTimeValue.text = _loc8.toString();
                        if (_loc8 == 1)
                        {
                            SecsText.text = "$min";
                        }
                        else
                        {
                            SecsText.text = "$mins";
                        }
                    }
                    else
                    {
                        ActiveEffectTimeValue.text = _loc8.toString();
                        if (_loc8 == 1)
                        {
                            SecsText.text = "$sec";
                        }
                        else
                        {
                            SecsText.text = "$secs";
                        }
                    }
                }
                else
                {
                    ActiveEffectTimeValue._alpha = 0;
                    SecsText._alpha = 0;
                }
                break;
            } 
            case InventoryDefines.ICT_SOUL_GEMS:
            {
                gotoAndStop("SoulGem");
                SoulLevel.text = aUpdateObj.soulLVL;
                break;
            } 
            case InventoryDefines.ICT_LIST:
            {
                gotoAndStop("Item_list");
                if (aUpdateObj.listItems != undefined)
                {
                    ItemList.entryList = aUpdateObj.listItems;
                    ItemList.InvalidateData();
                    ItemCardMeters[InventoryDefines.ICT_LIST] = new Components.DeltaMeter(ListChargeMeter.MeterInstance);
                    ItemCardMeters[InventoryDefines.ICT_LIST].SetPercent(aUpdateObj.currentCharge);
                    ItemCardMeters[InventoryDefines.ICT_LIST].SetDeltaPercent(aUpdateObj.currentCharge + ItemList.selectedEntry.chargeAdded);
                    OpenListMenu();
                }
                break;
            } 
            case InventoryDefines.ICT_CRAFT_ENCHANTING:
            {
                if (aUpdateObj.sliderShown == true)
                {
                    gotoAndStop("Craft_Enchanting");
                    ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Default.MeterInstance);
                    if (aUpdateObj.totalCharges != undefined && aUpdateObj.totalCharges != 0)
                    {
                        TotalChargesValue.text = aUpdateObj.totalCharges;
                    }
                }
                else if (aUpdateObj.damage != undefined)
                {
                    gotoAndStop("Craft_Enchanting_Weapon");
                    ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Weapon.MeterInstance);
                    WeaponDamageValue.SetText(aUpdateObj.damage);
                }
                else if (aUpdateObj.armor != undefined)
                {
                    gotoAndStop("Craft_Enchanting_Armor");
                    ApparelArmorValue.SetText(aUpdateObj.armor);
                    SkillTextInstance.text = aUpdateObj.skillText;
                }
                else if (aUpdateObj.soulLVL != undefined)
                {
                    gotoAndStop("Craft_Enchanting_SoulGem");
                    ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_SoulGem.MeterInstance);
                    SoulLevel.text = aUpdateObj.soulLVL;
                }
                else if (QuantitySlider_mc._alpha == 0)
                {
                    gotoAndStop("Craft_Enchanting_Enchantment");
                    ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(ChargeMeter_Enchantment.MeterInstance);
                }
                if (aUpdateObj.usedCharge == 0 && aUpdateObj.totalCharges == 0)
                {
                    ItemCardMeters[InventoryDefines.ICT_WEAPON].DeltaMeterMovieClip._parent._parent._alpha = 0;
                }
                else if (aUpdateObj.usedCharge != undefined)
                {
                    ItemCardMeters[InventoryDefines.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                }
                if (aUpdateObj.effects != undefined && aUpdateObj.effects.length > 0)
                {
                    if (EnchantmentLabel != undefined)
                    {
                        EnchantmentLabel.SetText(aUpdateObj.effects, true);
                    }
                    EnchantmentLabel.textAutoSize = "shrink";
                    WeaponChargeMeter._alpha = 100;
                    Enchanting_Background._alpha = 60;
                    Enchanting_Slim_Background._alpha = 0;
                }
                else
                {
                    if (EnchantmentLabel != undefined)
                    {
                        EnchantmentLabel.SetText("", true);
                    }
                    WeaponChargeMeter._alpha = 0;
                    Enchanting_Slim_Background._alpha = 60;
                    Enchanting_Background._alpha = 0;
                }
                break;
            } 
            case InventoryDefines.ICT_KEY:
            case InventoryDefines.ICT_NONE:
            default:
            {
                gotoAndStop("Empty");
                break;
            } 
        }
        SetupItemName(_loc12);
        if (aUpdateObj.name != undefined)
        {
            var _loc10 = aUpdateObj.count != undefined && aUpdateObj.count > 1 ? (aUpdateObj.name + " (" + aUpdateObj.count + ")") : (aUpdateObj.name);
            ItemText.ItemTextField.SetText(bEditNameMode || aUpdateObj.upperCaseName == false ? (_loc10) : (_loc10.toUpperCase()), false);
            ItemText.ItemTextField.textColor = aUpdateObj.negativeEffect == true ? (16711680) : (16777215);
        }
        ItemValueText.textAutoSize = "shrink";
        ItemWeightText.textAutoSize = "shrink";
        if (aUpdateObj.value != undefined && ItemValueText != undefined)
        {
            ItemValueText.SetText(aUpdateObj.value.toString());
        }
        if (aUpdateObj.weight != undefined && ItemWeightText != undefined)
        {
            ItemWeightText.SetText(RoundDecimal(aUpdateObj.weight, 1).toString());
        }
        StolenTextInstance._visible = aUpdateObj.stolen == true;
        LastUpdateObj = aUpdateObj;
    }
	
    function RoundDecimal(aNumber, aPrecision)
    {
        var _loc1 = Math.pow(10, aPrecision);
        return (Math.round(_loc1 * aNumber) / _loc1);
    }
	
    function PrepareInputElements(aActiveClip)
    {
        var _loc4 = 92;
        var _loc6 = 98;
        var _loc5 = 147.300000;
        var _loc2 = 130;
        var _loc7 = 166;
		
        if (aActiveClip == EnchantingSlider_mc)
        {
            QuantitySlider_mc._y = -100;
            ButtonRect._y = _loc7;
            EnchantingSlider_mc._y = _loc5;
            CardList_mc._y = -100;
            QuantitySlider_mc._alpha = 0;
            ButtonRect._alpha = 100;
            EnchantingSlider_mc._alpha = 100;
            CardList_mc._alpha = 0;
        }
        else if (aActiveClip == QuantitySlider_mc)
        {
            QuantitySlider_mc._y = _loc4;
            ButtonRect._y = _loc2;
            EnchantingSlider_mc._y = -100;
            CardList_mc._y = -100;
            QuantitySlider_mc._alpha = 100;
            ButtonRect._alpha = 100;
            EnchantingSlider_mc._alpha = 0;
            CardList_mc._alpha = 0;
        }
        else if (aActiveClip == CardList_mc)
        {
            QuantitySlider_mc._y = -100;
            ButtonRect._y = -100;
            EnchantingSlider_mc._y = -100;
            CardList_mc._y = _loc6;
            QuantitySlider_mc._alpha = 0;
            ButtonRect._alpha = 0;
            EnchantingSlider_mc._alpha = 0;
            CardList_mc._alpha = 100;
        }
        else if (aActiveClip == ButtonRect)
        {
            QuantitySlider_mc._y = -100;
            ButtonRect._y = _loc2;
            EnchantingSlider_mc._y = -100;
            CardList_mc._y = -100;
            QuantitySlider_mc._alpha = 0;
            ButtonRect._alpha = 100;
            EnchantingSlider_mc._alpha = 0;
            CardList_mc._alpha = 0;
        }
    }
	
    function ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue)
    {
        gotoAndStop("Craft_Enchanting");
        QuantitySlider_mc = EnchantingSlider_mc;
        QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
        PrepareInputElements(EnchantingSlider_mc);
        QuantitySlider_mc.maximum = aiMaxValue;
        QuantitySlider_mc.minimum = aiMinValue;
        QuantitySlider_mc.value = aiCurrentValue;
        PrevFocus = FocusHandler.instance.getFocus(0);
        FocusHandler.instance.setFocus(QuantitySlider_mc, 0);
        InputHandler = HandleQuantityMenuInput;
        dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
    }
	
    function ShowQuantityMenu(aiMaxAmount)
    {
        gotoAndStop("Quantity");
        PrepareInputElements(QuantitySlider_mc);
        QuantitySlider_mc.maximum = aiMaxAmount;
        QuantitySlider_mc.value = aiMaxAmount;
        SliderValueText.textAutoSize = "shrink";
        SliderValueText.SetText(Math.floor(QuantitySlider_mc.value).toString());
        PrevFocus = FocusHandler.instance.getFocus(0);
        FocusHandler.instance.setFocus(QuantitySlider_mc, 0);
        InputHandler = HandleQuantityMenuInput;
        dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
    }
	
    function HideQuantityMenu(aCanceled)
    {
        FocusHandler.instance.setFocus(PrevFocus, 0);
        QuantitySlider_mc._alpha = 0;
        ButtonRect_mc._alpha = 0;
        InputHandler = undefined;
        dispatchEvent({type: "subMenuAction", opening: false, canceled: aCanceled, menu: "quantity"});
    }
	
    function OpenListMenu()
    {
        PrevFocus = FocusHandler.instance.getFocus(0);
        FocusHandler.instance.setFocus(ItemList, 0);
        ItemList.addEventListener("itemPress", this, "onListItemPress");
        ItemList.addEventListener("listMovedUp", this, "onListSelectionChange");
        ItemList.addEventListener("listMovedDown", this, "onListSelectionChange");
        ItemList.addEventListener("selectionChange", this, "onListMouseSelectionChange");
        PrepareInputElements(CardList_mc);
        ListChargeMeter._alpha = 100;
        InputHandler = HandleListMenuInput;
        dispatchEvent({type: "subMenuAction", opening: true, menu: "list"});
    }
	
    function HideListMenu()
    {
        FocusHandler.instance.setFocus(PrevFocus, 0);
        ListChargeMeter._alpha = 0;
        CardList_mc._alpha = 0;
        ItemCardMeters[InventoryDefines.ICT_LIST] = undefined;
        InputHandler = undefined;
        dispatchEvent({type: "subMenuAction", opening: false, menu: "list"});
    }
	
    function ShowConfirmMessage(strMessage)
    {
        gotoAndStop("ConfirmMessage");
        PrepareInputElements(ButtonRect_mc);
        var _loc2 = strMessage.split("\r\n");
        var _loc3 = _loc2.join("\n");
        MessageText.SetText(_loc3);
        PrevFocus = FocusHandler.instance.getFocus(0);
        FocusHandler.instance.setFocus(this, 0);
        InputHandler = HandleConfirmMessageInput;
        dispatchEvent({type: "subMenuAction", opening: true, menu: "message"});
    }
	
    function HideConfirmMessage()
    {
        FocusHandler.instance.setFocus(PrevFocus, 0);
        ButtonRect_mc._alpha = 0;
        InputHandler = undefined;
        dispatchEvent({type: "subMenuAction", opening: false, menu: "message"});
    }
	
    function StartEditName(aInitialText, aMaxChars)
    {
        if (Selection.getFocus() != ItemName)
        {
            PrevFocus = FocusHandler.instance.getFocus(0);
            if (aInitialText != undefined)
            {
                ItemName.text = aInitialText;
            }
			
            ItemName.type = "input";
            ItemName.noTranslate = true;
            ItemName.selectable = true;
            ItemName.maxChars = aMaxChars != undefined ? (aMaxChars) : (null);
            Selection.setFocus(ItemName, 0);
            Selection.setSelection(0, 0);
            InputHandler = HandleEditNameInput;
            bEditNameMode = true;
        }
    }
	
    function EndEditName()
    {
        ItemName.type = "dynamic";
        ItemName.noTranslate = false;
        ItemName.selectable = false;
        ItemName.maxChars = null;
        var _loc2 = PrevFocus.focusEnabled;
        PrevFocus.focusEnabled = true;
        Selection.setFocus(PrevFocus, 0);
        PrevFocus.focusEnabled = _loc2;
        InputHandler = undefined;
        bEditNameMode = false;
    }
	
    function handleInput(details, pathToFocus)
    {
        var _loc2 = false;
        if (pathToFocus.length > 0 && pathToFocus[0].handleInput != undefined)
        {
            pathToFocus[0].handleInput(details, pathToFocus.slice(1));
        }
        if (!_loc2 && InputHandler != undefined)
        {
            _loc2 = InputHandler(details);
        }
        return (_loc2);
    }
	
    function HandleQuantityMenuInput(details)
    {
        var _loc2 = false;
        if (GlobalFunc.IsKeyPressed(details))
        {
            if (details.navEquivalent == NavigationCode.ENTER)
            {
                HideQuantityMenu(false);
                if (QuantitySlider_mc.value > 0)
                {
                    dispatchEvent({type: "quantitySelect", amount: Math.floor(QuantitySlider_mc.value)});
                }
                else
                {
                    itemInfo = LastUpdateObj;
                }
                _loc2 = true;
            }
            else if (details.navEquivalent == NavigationCode.TAB)
            {
                HideQuantityMenu(true);
                itemInfo = LastUpdateObj;
                _loc2 = true;
            }
        }
        return (_loc2);
    }
	
    function HandleListMenuInput(details)
    {
        var _loc2 = false;
        if (GlobalFunc.IsKeyPressed(details) && details.navEquivalent == NavigationCode.TAB)
        {
            HideListMenu();
            _loc2 = true;
        }
        return (_loc2);
    }
	
    function HandleConfirmMessageInput(details)
    {
        var _loc2 = false;
        if (GlobalFunc.IsKeyPressed(details))
        {
            if (details.navEquivalent == NavigationCode.ENTER)
            {
                HideConfirmMessage();
                dispatchEvent({type: "messageConfirm"});
                _loc2 = true;
            }
            else if (details.navEquivalent == NavigationCode.TAB)
            {
                HideConfirmMessage();
                dispatchEvent({type: "messageCancel"});
                itemInfo = LastUpdateObj;
                _loc2 = true;
            }
        }
        return (_loc2);
    }
	
    function HandleEditNameInput(details)
    {
        Selection.setFocus(ItemName, 0);
        if (GlobalFunc.IsKeyPressed(details))
        {
            if (details.navEquivalent == NavigationCode.ENTER && details.code != 32)
            {
                dispatchEvent({type: "endEditItemName", useNewName: true, newName: ItemName.text});
            }
            else if (details.navEquivalent == NavigationCode.TAB)
            {
                dispatchEvent({type: "endEditItemName", useNewName: false, newName: ""});
            }
        }
        return (true);
    }
	
    function onSliderChange()
    {
        var _loc3 = EnchantingSlider_mc._alpha > 0 ? (TotalChargesValue) : (SliderValueText);
        var _loc4 = Number(_loc3.text);
        var _loc2 = Math.floor(QuantitySlider_mc.value);
		
        if (_loc4 != _loc2)
        {
            _loc3.SetText(_loc2.toString());
            GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
            dispatchEvent({type: "sliderChange", value: _loc2});
        }
    }
	
    function onListItemPress(event)
    {
        dispatchEvent(event);
        HideListMenu();
    }
	
    function onListMouseSelectionChange(event)
    {
        if (event.keyboardOrMouse == 0)
        {
            onListSelectionChange(event);
        }
    }
	
    function onListSelectionChange(event)
    {
        ItemCardMeters[InventoryDefines.ICT_LIST].SetDeltaPercent(ItemList.selectedEntry.chargeAdded + LastUpdateObj.currentCharge);
    }
}
