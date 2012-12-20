import skyui.util.ConfigManager;
import skyui.components.list.ListLayout;

class skyui.components.list.ListLayoutManager
{
  /* INITIALIZATION */
  
  	static private var _initialized = initialize();
	
	static private function initialize(): Boolean
	{
		ConfigManager.setConstant("ITEM_ICON", ListLayout.COL_TYPE_ITEM_ICON);
		ConfigManager.setConstant("EQUIP_ICON", ListLayout.COL_TYPE_EQUIP_ICON);
		ConfigManager.setConstant("NAME", ListLayout.COL_TYPE_NAME);
		ConfigManager.setConstant("TEXT", ListLayout.COL_TYPE_TEXT);
		
		ConfigManager.addConstantTable("skyui.defines.Actor", skyui.defines.Actor);
		ConfigManager.addConstantTable("skyui.defines.Armor", skyui.defines.Armor);
		ConfigManager.addConstantTable("skyui.defines.Form", skyui.defines.Form);
		ConfigManager.addConstantTable("skyui.defines.Input", skyui.defines.Input);
		ConfigManager.addConstantTable("skyui.defines.Inventory", skyui.defines.Inventory);
		ConfigManager.addConstantTable("skyui.defines.Item", skyui.defines.Item);
		ConfigManager.addConstantTable("skyui.defines.Magic", skyui.defines.Magic);
		ConfigManager.addConstantTable("skyui.defines.Material", skyui.defines.Material);
		ConfigManager.addConstantTable("skyui.defines.Weapon", skyui.defines.Weapon);
		
		return true;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public static function createLayout(a_sectionData: Object, a_name: String): ListLayout
	{
		var viewData = a_sectionData.views;
		var columnData = a_sectionData.columns;
		var defaultsData = a_sectionData.defaults;
		
		// Otherwise create
		for (var t in a_sectionData.layouts) {
			var layoutData = a_sectionData.layouts[t];
			if (layoutData.name == a_name)
				return new ListLayout(layoutData, viewData, columnData, defaultsData);
		}
				
		return null;
	}
}