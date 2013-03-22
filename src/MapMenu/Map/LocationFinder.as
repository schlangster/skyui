import flash.geom.ColorTransform;
import flash.geom.Transform;

import skyui.components.list.FilteredEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.SearchWidget;

import skyui.filter.NameFilter;
import skyui.filter.SortFilter;
import skyui.defines.Input;

import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.managers.FocusHandler;
import gfx.managers.InputDelegate;


class Map.LocationFinder extends MovieClip
{
  /* CONSTANTS */
  
	public static var TYPE_RANGE: Number = 60;
	
	
  /* PRIVATE VARIABLES */
  
	private var _foundMarker: MovieClip;
	
	private var _nameFilter: NameFilter;
	private var _sortFilter: SortFilter;
	
	private var _bShown: Boolean = false;
	


  /* STAGE ELEMENTS */
	
	public var list: ScrollingList;
	
	public var searchWidget: SearchWidget;
	
	public var loadIcon: MovieClip;
	
	
  /* INITIALIZATION */
  
	public function LocationFinder()
	{
		super();
		
		_nameFilter = new NameFilter();
		_nameFilter.nameAttribute = "_label";
		
		_sortFilter = new SortFilter();
		_sortFilter.setSortBy(["_label"], [Array.CASEINSENSITIVE]);
	}
	
	// @override MovieClip
	private function onLoad(): Void
	{
		var e = new FilteredEnumeration(list.entryList);
		e.addFilter(_nameFilter);
		e.addFilter(_sortFilter);
		list.listEnumeration = e;
		
		_nameFilter.addEventListener("filterChange", this, "onNameFilterChange");
		
		list.addEventListener("itemPress", this, "onLocationListPress");
		
		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		
		setLoading(false);
		hide(true);
	}
	
	private function onNameFilterChange(a_event: Object): Void
	{
		list.requestInvalidate();
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function setLoading(a_bLoading: Boolean): Void
	{
		if (a_bLoading) {
			loadIcon._visible = true;
			loadIcon.gotoAndPlay(0);
			list._visible = false;
			
		} else {
			loadIcon._visible = false;
			loadIcon.stop();
			list._visible = true;
		}
	}

	public function show(): Void
	{
		FocusHandler.instance.setFocus(list,0);
		
		_bShown = true;
		_parent.gotoAndPlay("fadeIn");
		searchWidget.isDisabled = false;
		list.disableInput = list.disableSelection = false;
		list.selectedIndex = -1;
		
		clearFoundMarker();
	}
	
	public function hide(a_bInstant: Boolean): Void
	{
		_bShown = false;
		if (a_bInstant)
			_parent.gotoAndStop("hide");
		else
			_parent.gotoAndPlay("fadeOut");

		searchWidget.isDisabled = true;
		list.disableInput = list.disableSelection = true;
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (_bShown) {
			if (GlobalFunc.IsKeyPressed(details)) {
				// Search hotkey (default space)
				if (details.skseKeycode == 57) {
					searchWidget.startInput();
					return true;
				}
			}
		}
	
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
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
	
	private function onSearchInputStart(event: Object): Void
	{
		list.disableInput = list.disableSelection = true;
		InputDelegate.instance.enableControlFixup(false);
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		list.disableInput = list.disableSelection = false;
		InputDelegate.instance.enableControlFixup(true);
		_nameFilter.filterText = event.data;
	}
}