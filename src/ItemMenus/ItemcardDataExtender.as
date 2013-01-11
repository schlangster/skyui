import gfx.io.GameDelegate;

import skyui.defines.Form;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;


// @abstract
class ItemcardDataExtender implements IListProcessor
{
  /* PRIVATE VARIABLES */
  
	private var _itemInfo: Object;
	private var _requestItemInfo: Function;
	
	
  /* INITIALIZATION */
	
	public function ItemcardDataExtender()
	{
		_requestItemInfo = function(a_target: Object, a_index: Number): Void
		{
			var oldIndex = this._selectedIndex;
			this._selectedIndex = a_index;
			GameDelegate.call("RequestItemCardInfo", [], a_target, "updateItemInfo");
			this._selectedIndex = oldIndex;
		};
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function updateItemInfo(a_updateObj: Object): Void
	{
		_itemInfo = a_updateObj;
	}
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i = 0; i < entryList.length; i++) {
			var e = entryList[i];
			if (e.skyui_itemDataProcessed || e.filterFlag == 0)
				continue;
				
			e.skyui_itemDataProcessed = true;
			
			// Fix wrong property names
			fixSKSEExtendedObject(e);

			// Hack to retrieve itemcard info
			_requestItemInfo.apply(a_list, [this, i]);
			processEntry(e, _itemInfo);
		}
	}

  /* PRIVATE FUNCTIONS */
	
	// @abstract
	private function processEntry(a_entryObject: Object, a_itemInfo: Object): Void {}

	private function fixSKSEExtendedObject(a_extendedObject: Object): Void
	{
		if (a_extendedObject.formType == undefined)
			return;

		switch(a_extendedObject.formType) {
			case Form.TYPE_SPELL:
			case Form.TYPE_SCROLLITEM:
			case Form.TYPE_INGREDIENT:
			case Form.TYPE_POTION:
			case Form.TYPE_EFFECTSETTING:

				// school is sent as subType
				if (a_extendedObject.school == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.school = a_extendedObject.subType;
					delete(a_extendedObject.subType);
				}

				// resistance is sent as magicType
				if (a_extendedObject.resistance == undefined && a_extendedObject.magicType != undefined) {
					a_extendedObject.resistance = a_extendedObject.magicType;
					delete(a_extendedObject.magicType);
				}

				// primaryValue is sent as actorValue
				/* // Ignore
				if (a_extendedObject.primaryValue == undefined && a_extendedObject.actorValue != undefined) {
					a_extendedObject.primaryValue = a_extendedObject.actorValue;
					delete(a_extendedObject.actorValue);
				}
				*/
				break;

			case Form.TYPE_WEAPON:
				// weaponType is sent as subType
				if (a_extendedObject.weaponType == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.weaponType = a_extendedObject.subType;
					delete(a_extendedObject.subType);
				}
				break;

			case Form.TYPE_BOOK:
				// (SKSE < 1.6.6) flags and bookType (and some padding) are sent as one UInt32 bookType
				if (a_extendedObject.flags == undefined && a_extendedObject.bookType != undefined) {
					var oldBookType: Number = a_extendedObject.bookType;
					a_extendedObject.bookType	= (oldBookType & 0xFF00) >>> 8;
					a_extendedObject.flags		= (oldBookType & 0x00FF);
				}
				break;

			default:
				break;
		}

	}
}