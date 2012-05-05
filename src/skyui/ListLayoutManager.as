import skyui.ConfigLoader;
import skyui.ListLayout;


/*
 *  Encapsulates the list layout configuration.
 */
class skyui.ListLayoutManager
{
	private var _layoutData: Object;
	
	// Store created layouts
	private var _layouts: Object;
	
	
	public function ListLayoutManager()
	{
		_layouts = {};
		ConfigLoader.registerCallback(this, "onConfigLoad");
	}
	
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
				_layouts[a_name] =
					ListLayout(_layoutData.layouts[i], _layoutData.defaults, _layoutData.list.entryWidth, _layoutData.list.entryHeight);
				return _layouts[a_name];
			}
		}
				
		return undefined;
	}

	private function getMatchingView(a_flag: Number): Number
	{
		var views = activeLayout.views;
		
		// Find a matching view, or use last index
		for (var i = 0; i < views.length; i++) {

			// Wrap in array for single category
			var categories = ((views[i].category) instanceof Array) ? views[i].category : [views[i].category];
			
			// Either found a matching category, or the last inded has to be used.
			if (categories.indexOf(a_flag) != undefined || i == views.length-1)
				return i;
		}
		
		return undefined;
	}

}