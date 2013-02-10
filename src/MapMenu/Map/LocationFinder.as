import flash.geom.ColorTransform;
import flash.geom.Transform;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;


class Map.LocationFinder extends MovieClip
{
  /* CONSTANTS */
  
	public static var TYPE_RANGE: Number = 60;
	
	
  /* PRIVATE VARIABLES */
  
	private var _foundMarker: MovieClip;


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
		list.listEnumeration = new BasicEnumeration(list.entryList);
		list.addEventListener("itemPress", this, "onLocationListPress");
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function show(): Void
	{
		_parent.gotoAndPlay("fadeIn");
		list.selectedIndex = -1;
		list.disableInput = list.disableSelection = false;
		
		clearFoundMarker();
	}
	
	public function hide(): Void
	{
		_parent.gotoAndPlay("fadeOut");
		list.disableInput = list.disableSelection = true;
	}
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onLocationListPress(a_event: Object): Void
	{
		var entry = a_event.entry;
		if (entry == null)
			return;
			
		setFoundMarker(entry);
		
		skse.ShowOnMap(entry.index);
		// hide will be called from local map menu as soon as its state changes
	}
	
	private function clearFoundMarker(): Void
	{
		if (_foundMarker) {
			_foundMarker.removeMovieClip();
			_foundMarker = null;
		}
	}
	
	private function setFoundMarker(a_marker: MovieClip): Void
	{
		clearFoundMarker();
		
		if (a_marker.IconClip != null) {
			var depth = a_marker.IconClip.getNextHighestDepth();
			_foundMarker = a_marker.IconClip.attachMovie("FoundMarker", "foundIcon", depth);
		}
	}
}