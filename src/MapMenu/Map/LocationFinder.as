import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

class Map.LocationFinder extends MovieClip
{
  /* STAGE ELEMENTS */
	
	public var list: ScrollingList;
	
	
  /* INITIALIZATION */
  
	public function LocationFinder()
	{
		super();
	}
	
	// @override MovieClip
	private function onLoad(): Void
	{
		list.addEventListener("itemPress", this, "onMenuListPress");
		list.listEnumeration = new BasicEnumeration(list.entryList);
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function initContent(): Void
	{

	}
}