import skyui.util.ConfigManager;
import skyui.components.list.ListLayout;


class skyui.components.list.ListLayoutManager
{
  /* SINGLETON */
  
  	static private var _initialized = initialize();
	
	static private function initialize(): Boolean
	{
		ConfigManager.setConstant("ITEM_ICON", ListLayout.COL_TYPE_ITEM_ICON);
		ConfigManager.setConstant("EQUIP_ICON", ListLayout.COL_TYPE_EQUIP_ICON);
		ConfigManager.setConstant("NAME", ListLayout.COL_TYPE_NAME);
		ConfigManager.setConstant("TEXT", ListLayout.COL_TYPE_TEXT);
		
		_instance = new ListLayoutManager;
		return true;
	}
	
	static private var _instance: ListLayoutManager;
	
	static public function get instance()
	{
		return _instance;
	}
	
	
  /* PRIVATE VARIABLES */
	
	private var _sectionData: Object;
	private var _viewData: Object;
	private var _columnData: Object;
	private var _defaultsData: Object;
	
	// Store created layouts
	private var _layouts: Object;
	
	
  /* CONSTRUCTORS */
	
	public function ListLayoutManager()
	{
		_layouts = {};
		
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function onConfigLoad(event: Object): Void
	{
		if (event.config == undefined)
			return;
			
		_sectionData = event.config["ListLayout"];
		_viewData = _sectionData.views;
		_columnData = _sectionData.columns;
		_defaultsData = _sectionData.defaults;
	}
	
	public function onConfigUpdate(event: Object): Void
	{
		for (var k in _layouts)
			_layouts[k].refresh();
	}
	
	// Create on-demand and cache
	public function getLayoutByName(a_name: String)
	{
		// Exists?
		if (_layouts[a_name] != undefined)
			return _layouts[a_name];
		
		// Otherwise create
		for (var t in _sectionData.layouts) {
			var layoutData = _sectionData.layouts[t];
			if (layoutData.name == a_name) {
				_layouts[a_name] = new ListLayout(layoutData, _viewData, _columnData, _defaultsData);
				return _layouts[a_name];
			}
		}
				
		return undefined;
	}
}