import skyui.util.Translator;

import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Material;
import skyui.defines.Weapon;
import skyui.defines.Inventory;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


class CustomConstructDataSetter implements IListProcessor
{
  /* INITIALIZATION */
  
	public function CustomConstructDataSetter()
	{
		super();
	}
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.oldFilterFlag != undefined || e.filterFlag == 0)
				continue;
				
			e.oldFilterFlag = e.filterFlag;

			processEntry(e);			
		}
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function processEntry(a_entryObject: Object): Void
	{
		var bDone = false;
		
		// We can map these categories 1:1
		switch (a_entryObject.oldFilterFlag) {
			case Inventory.FILTERFLAG_CRAFT_JEWELRY:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY;
				bDone = true;
				break;
			case Inventory.FILTERFLAG_CRAFT_FOOD:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				bDone = true;
				break;
		}
		
		if (bDone)
			return;
		
		switch (a_entryObject.formType) {
			case Form.TYPE_ARMOR:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_ARMOR;
				break;

			case Form.TYPE_INGREDIENT:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				break;

			case Form.TYPE_WEAPON:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS;
				break;

			case Form.TYPE_AMMO:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_AMMO;
				break;

			case Form.TYPE_POTION:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				break;

			default:
				a_entryObject.filterFlag = Inventory.FILTERFLAG_CUST_CRAFT_MISC;
				break;
		}
	}
}