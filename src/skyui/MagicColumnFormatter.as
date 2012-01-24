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
		switch (a_entryObject.infoType) {
			
			// Spell
			case InventoryDefines.ICT_SPELL :
				switch (a_entryObject.subType) {
					case Defines.SPELL_TYPE_ALTERATION :
						a_entryField.gotoAndStop("default_alteration");
						break;
					case Defines.SPELL_TYPE_ILLUSION :
						a_entryField.gotoAndStop("default_illusion");
						break;
					case Defines.SPELL_TYPE_DESTRUCTION :
						a_entryField.gotoAndStop("default_destruction");
						break;
					case Defines.SPELL_TYPE_CONJURATION :
						a_entryField.gotoAndStop("default_conjuration");
						break;
					case Defines.SPELL_TYPE_RESTORATION :
						a_entryField.gotoAndStop("default_restoration");
						break;
					default:
						a_entryField.gotoAndStop("default_power");
				}
				break;
			
			// Power
			case InventoryDefines.ICT_SPELL_DEFAULT :
				a_entryField.gotoAndStop("default_power");
				break;
			
			// Shout
			case InventoryDefines.ICT_SHOUT :
				a_entryField.gotoAndStop("default_shout");
				break;
			
			// Active Effect
			case InventoryDefines.ICT_ACTIVE_EFFECT :
			default:
				a_entryField.gotoAndStop("default_effect");			
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
			a_entryField.SetText(text);

			formatColor(a_entryField, a_entryObject);

			// Fav icon
			if (a_entryObject.favorite == true) {
				a_entryClip.favoriteIcon._x = a_entryField._x + a_entryField._width + 5;
				a_entryClip.favoriteIcon.gotoAndStop("show");
			} else {
				a_entryClip.favoriteIcon.gotoAndStop("hide");
			}

		} else {
			a_entryField.SetText(" ");
		}
	}
}