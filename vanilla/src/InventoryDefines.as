class InventoryDefines
{
	static var ICT_NONE = 0;
	static var ICT_ARMOR = 1;
	static var ICT_WEAPON = 2;
	static var ICT_MISC = 3;
	static var ICT_BOOK = 4;
	static var ICT_FOOD = 5;
	static var ICT_POTION = 6;
	static var ICT_SPELL = 7;
	static var ICT_INGREDIENT = 8;
	static var ICT_KEY = 9;
	static var ICT_SHOUT = 10;
	static var ICT_ACTIVE_EFFECT = 11;
	static var ICT_SOUL_GEMS = 12;
	static var ICT_SPELL_DEFAULT = 13;
	static var ICT_LIST = 14;
	static var ICT_CRAFT_ENCHANTING = 15;

	static var ES_NONE = 0;
	static var ES_EQUIPPED = 1;
	static var ES_LEFT_EQUIPPED = 2;
	static var ES_RIGHT_EQUIPPED = 3;
	static var ES_BOTH_EQUIPPED = 4;
	static var QUANTITY_MENU_COUNT_LIMIT = 5;

	function InventoryDefines()
	{
	}

	static function GetEquipText(aiItemType)
	{
		switch (aiItemType) {
			case ICT_ARMOR :
				return ("$Equip");
				break;

			case ICT_BOOK :
				return ("$Read");
				break;

			case ICT_POTION :
				return ("$Use");
				break;

			case ICT_FOOD :
			case ICT_INGREDIENT :
				return ("$Eat");
				break;

			default :
				return ("$Equip");
				break;
		}
	}
}