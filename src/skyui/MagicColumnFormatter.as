import skyui.IColumnFormatter;
import skyui.InventoryColumnFormatter;
import skyui.Defines;


class skyui.MagicColumnFormatter extends InventoryColumnFormatter
{
	function MagicColumnFormatter()
	{
		super();
	}

	function formatItemIcon(a_entryField:Object, a_entryObject:Object)
	{
		if (a_entryObject.extended == undefined) {

			// Default without script extender
			switch (a_entryObject.infoType) {
				case Defines.MAGIC_ALTERATION :
					a_entryField.gotoAndStop("category_alteration");
					break;
				case Defines.MAGIC_ILLUSION :
					a_entryField.gotoAndStop("category_illusion");
					break;
				case Defines.MAGIC_DESTRUCTION :
					a_entryField.gotoAndStop("category_destruction");
					break;
				case Defines.MAGIC_CONJURATION :
					a_entryField.gotoAndStop("category_conjuration");
					break;
				case Defines.MAGIC_RESTORATION :
					a_entryField.gotoAndStop("category_restoration");
					break;
				case InventoryDefines.ICT_SHOUT :
					a_entryField.gotoAndStop("category_shouts");
					break;
				case InventoryDefines.ICT_ACTIVE_EFFECT :
					a_entryField.gotoAndStop("category_activeeffects");
					break;
				case InventoryDefines.ICT_SPELL_DEFAULT :// Powers
					a_entryField.gotoAndStop("category_powers");
					break;
				default :
					a_entryField.gotoAndStop("category_misc");
					break;
			}
		} else {
			// Default without script extender
			// unused for now
		}
	}

	function formatName(a_entryField:Object, a_entryObject:Object, a_entryClip:MovieClip)
	{
		if (a_entryObject.text != undefined) {

			// Text
			var text = a_entryObject.text;

			if (text.length > _maxTextLength) {
				text = text.substr(0, _maxTextLength - 3) + "...";
			}

			a_entryField.autoSize = "left";
			a_entryField.textAutoSize = "shrink";
			a_entryField.SetText(text);

			if (a_entryObject.negativeEffect == true || a_entryObject.isStealing == true) {
				a_entryField.textColor = a_entryObject.enabled == false ? 0x800000 : 0xFF0000;
			} else {
				a_entryField.textColor = a_entryObject.enabled == false ? 0x4C4C4C : 0xFFFFFF;
			}

			// Fav icon
			if (a_entryObject.favorite == true) {
				a_entryClip.favoriteIcon._x = a_entryField._x + a_entryField._width + 5;
				a_entryClip.favoriteIcon.gotoAndStop("show");
			} else {
				a_entryClip.favoriteIcon.gotoAndStop("hide");
			}
			
			a_entryClip.bestIcon.gotoAndStop("hide");
			a_entryClip.poisonIcon.gotoAndStop("hide");
			a_entryClip.stolenIcon.gotoAndStop("hide");
			a_entryClip.enchIcon.gotoAndStop("hide");

		} else {
			a_entryField.SetText(" ");
		}
	}
}