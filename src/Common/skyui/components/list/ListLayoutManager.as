import skyui.util.ConfigManager;
import skyui.components.list.ListLayout;
import skyui.components.list.IListLayoutSubscriber;

/*
 * Connect layout data provided by ConfigManager and clients that need to access it.
 * Allows objects to subscribe for layout events while ignoring any timing details
 * associated with delayed config loading.
 */
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
		
		ConfigManager.addConstantTable("skyui.util.Defines");
		ConfigManager.addConstantTable("InventoryDefines");
		
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
			if (layoutData.name == a_name) {
				skyui.util.Debug.log("Creating layout: " + layoutData + " " + viewData);
				return new ListLayout(layoutData, viewData, columnData, defaultsData);
			}
		}
				
		return undefined;
	}
}