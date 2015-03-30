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


class CustomAlchemyDataSetter implements IListProcessor
{
  /* INITIALIZATION */
  
	public function CustomAlchemyDataSetter()
	{
		super();
		
		partitionData = [];
	}
	

  /* PROPERTIES */
	
	public var partitionData: Array;
	
	
  /* PUBLIC FUNCTIONS */
  
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		// First save old filterflag and clear it
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			
			// customFilterFlag not set yet or filterFlag changed by the game?
			if (e.customFilterFlag == e.filterFlag)
				continue;
				
			processEntry(e)
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function processEntry(a_entryObject: Object): Void
	{
		// Reset data
		a_entryObject.goodEffects = null;
		a_entryObject.badEffects = null;
		a_entryObject.otherEffects = null;
		
		// All entries should be in there
		a_entryObject.customFilterFlag = Inventory.FILTERFLAG_CUST_ALCH_INGREDIENTS;
		
		for (var i = 0; i < partitionData.length; i++) {
			var partition = partitionData[i];
			var partitionIndex = partition.index;
			
			if (! isEntryInPartition(a_entryObject.filterFlag, partitionIndex))
				continue;
				
			a_entryObject.customFilterFlag |= partition.flag;
		
			switch (partition.flag) {
				case Inventory.FILTERFLAG_CUST_ALCH_GOOD:
					if (a_entryObject.goodEffects == null)
						a_entryObject.goodEffects = partition.text;
					else {
						a_entryObject.goodEffects += "  |  " + partition.text;
					}
					break;
				case Inventory.FILTERFLAG_CUST_ALCH_BAD:
					if (a_entryObject.badEffects == null)
						a_entryObject.badEffects = partition.text;
					else
						a_entryObject.badEffects += ", " + partition.text;
					break;
				case Inventory.FILTERFLAG_CUST_ALCH_OTHER:
					if (a_entryObject.otherEffects == null)
						a_entryObject.otherEffects = partition.text;
					else
						a_entryObject.otherEffects += ", " + partition.text;
					break;
			}
		}
		
		// Apply custom flag as new flag
		a_entryObject.filterFlag = a_entryObject.customFilterFlag;
	}
	
	private static function isEntryInPartition(a_filterFlag: Number, a_index: Boolean): Boolean
	{
		// Each entry can be in at most 4 partitions.
		// Parition indices are encoded in bytes of filterFlag.
		var byte0: Number = (a_filterFlag & 0x000000FF);
		var byte1: Number = (a_filterFlag & 0x0000FF00) >>> 8;
		var byte2: Number = (a_filterFlag & 0x00FF0000) >>> 16;
		var byte3: Number = (a_filterFlag & 0xFF000000) >>> 24;
		
		return byte0 == a_index || byte1 == a_index || byte2 == a_index || byte3 == a_index;
	}
}