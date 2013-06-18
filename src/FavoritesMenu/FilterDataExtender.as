import skyui.defines.Form;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;
import skyui.util.Hash;


class FilterDataExtender implements IListProcessor
{
  /* CONSTANTS */
  
	public static var FILTERFLAG_ALL		= 0x0000000F;
	public static var FILTERFLAG_DEFAULT	= 0x00000001;
	public static var FILTERFLAG_GEAR		= 0x00000002;
	public static var FILTERFLAG_AID		= 0x00000004;
	public static var FILTERFLAG_MAGIC		= 0x00000008;

	public static var FILTERFLAG_GROUP_ADD	= 0x00000010;
	public static var FILTERFLAG_GROUP_0	= 0x00000020;
	// Group N+1 = (GROUP_N << 1) | GROUP_ADD
	
	
  /* PRIVATE VARIABLES */
  
  /* PROPERTIES */
	
  /* INITIALIZATION */
	
	public function FilterDataExtender()
	{
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.skyui_itemDataProcessed)
				continue;
				
			e.skyui_itemDataProcessed = true;
		
			processEntry(e);
		}
	}

  /* PRIVATE FUNCTIONS */
  
	private function processEntry(a_entryObject: Object): Void
	{
		// ItemID
		a_entryObject.itemId &= 0xFFFFFFFF; // better safe than sorry
	
		var formType = a_entryObject.formType;

		switch(formType) {
			case Form.TYPE_ARMOR:
			case Form.TYPE_AMMO:
			case Form.TYPE_WEAPON:
			case Form.TYPE_LIGHT:
				a_entryObject.filterFlag = FILTERFLAG_GEAR;
				break;
				
			case Form.TYPE_INGREDIENT:
			case Form.TYPE_POTION:
				a_entryObject.filterFlag = FILTERFLAG_AID;
				break;
				
			case Form.TYPE_SPELL:
			case Form.TYPE_SHOUT:
			case Form.TYPE_SCROLLITEM:
				a_entryObject.filterFlag = FILTERFLAG_MAGIC;
				break;
			
			case Form.TYPE_BOOK:
			case Form.TYPE_EFFECTSETTING:
			default:
				// This is a default flag to make sure ALL includes everything
				a_entryObject.filterFlag = FILTERFLAG_DEFAULT;
				break;
		}
	}
}