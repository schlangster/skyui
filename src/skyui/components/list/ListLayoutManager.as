import skyui.util.ConfigLoader;
import skyui.components.list.ListLayout;


class skyui.components.list.ListLayoutManager
{
  /* SINGLETON */
  
  	static private var _initialized = initialize();
	
	static private function initialize(): Boolean
	{
		_instance = new ListLayoutManager;
		return true;
	}
	
	static private var _instance: ListLayoutManager;
	
	static public function get instance()
	{
		return _instance;
	}
	
	
  /* PRIVATE VARIABLES */
	
	private var _layoutData: Object;
	
	// Store created layouts
	private var _layouts: Object;
	
	
  /* CONSTRUCTORS */
	
	public function ListLayoutManager()
	{
		_layouts = {};
		ConfigLoader.registerCallback(this, "onConfigLoad");
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function onConfigLoad(event)
	{
		if (event.config == undefined)
			return;
			
		_layoutData = event.config["ListLayout"];
	}
	
	public function getLayoutByName(a_name: String)
	{
		// Exists?
		if (_layouts[a_name] != undefined)
			return _layouts[a_name];
		
		// Otherwise create
		for (var i = 0; i < _layoutData.layouts.length; i++) {
			if (_layoutData.layouts[i].name == a_name) {
				_layouts[a_name] = new ListLayout(_layoutData.layouts[i],
												  _layoutData.defaults,
												  _layoutData.list.entryWidth);
				return _layouts[a_name];
			}
		}
				
		return undefined;
	}
}