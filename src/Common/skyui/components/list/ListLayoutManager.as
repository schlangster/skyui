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
  /* SINGLETON */
  
  	static private var _initialized = initialize();
	
	static private function initialize(): Boolean
	{
		ConfigManager.setConstant("ITEM_ICON", ListLayout.COL_TYPE_ITEM_ICON);
		ConfigManager.setConstant("EQUIP_ICON", ListLayout.COL_TYPE_EQUIP_ICON);
		ConfigManager.setConstant("NAME", ListLayout.COL_TYPE_NAME);
		ConfigManager.setConstant("TEXT", ListLayout.COL_TYPE_TEXT);

//		trace("ListLayoutManager: " + skyui.util.Defines);
		
		ConfigManager.addConstantTable("skyui.util.Defines");
		ConfigManager.addConstantTable("InventoryDefines");
		
		_instance = new ListLayoutManager();
		return true;
	}
	
	static private var _instance: ListLayoutManager;
	
	static public function get instance()
	{
		return _instance;
	}
	
	
  /* PRIVATE VARIABLES */
	
	private var _loaded: Boolean = false;
	
	private var _sectionData: Object;
	private var _viewData: Object;
	private var _columnData: Object;
	private var _defaultsData: Object;
	
	// Store created layouts
	private var _layouts: Object;

	// Keep requests received pre-load
	private var _reqBuffer: Array;
	
	
  /* CONSTRUCTORS */
	
	public function ListLayoutManager()
	{
		_layouts = {};
		_reqBuffer = [];
		
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
		ConfigManager.registerUpdateCallback(this, "onConfigUpdate");
	}
	
	
  /* PUBLIC FUNCTIONS */


  
	public function bind(a_scope: IListLayoutSubscriber, a_layoutName: String): Void
	{
		if (!_loaded) {
			_reqBuffer.push({scope: a_scope, layoutName: a_layoutName});
			return;
		}
		
		a_scope.setLayout(getLayout(a_layoutName));
	}
  
	public function onConfigLoad(event: Object): Void
	{
		if (event.config == undefined)
			return;
			
		_loaded = true;
			
		_sectionData = event.config["ListLayout"];
		_viewData = _sectionData.views;
		_columnData = _sectionData.columns;
		_defaultsData = _sectionData.defaults;
		
		for (var i=0; i<_reqBuffer.length; i++) {
			var req = _reqBuffer[i];
			req.scope.setLayout(getLayout(req.layoutName));
		}
		
		delete _reqBuffer;
		
		for (var k in _layouts)
			_layouts[k].refresh();
	}
	
	public function onConfigUpdate(event: Object): Void
	{
		for (var k in _layouts)
			_layouts[k].refresh();
	}
	
	// Create on-demand and cache
	private function getLayout(a_name: String)
	{
		// Exists?
		if (_layouts[a_name] != undefined)
			return _layouts[a_name];
		
		// Otherwise create
		for (var t in _sectionData.layouts) {
			var layoutData = _sectionData.layouts[t];
			if (layoutData.name == a_name) {
				skyui.util.Debug.log("Creating layout: " + layoutData + " " + _viewData);
				_layouts[a_name] = new ListLayout(layoutData, _viewData, _columnData, _defaultsData);
				return _layouts[a_name];
			}
		}
				
		return undefined;
	}
}