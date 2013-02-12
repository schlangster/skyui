﻿import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.managers.FocusHandler;
import gfx.managers.InputDelegate;

import Map.LocalMap;
import Map.LocationFinder;
import Shared.ButtonChange;
import Shared.GlobalFunc;

import skyui.components.ButtonPanel;
import skyui.components.MappedButton;
import skyui.defines.Input;

/*
	A few comments:
	* The map menu set up somewhat complicated. There's a lot of @API, so changing that was not an option.
	* The top-level clip contains 3 main components, and the bottombar.
		Root
		+-- MapMenu (aka WorldMap. this class)
		+-- LocalMap
		+-- LocationFinder (new)
		+-- BottomBar
	* To prevent WSAD etc from zooming while the location finder is active, we have to enter a fake local map mode.
	* LocalMap handles the overall state of the menu: worldmap(aka hidden), localmap, locationfinder
	* To open the LocationFinder, we send a request to localmap, which prepares the fake mode, then shows the location finder.
	* For handleInput, MapMenu acts as the root.
	* The bottombar changes happen in LocalMap when the mode is changed.
	* To detect E as NavEquivalent.ENTER, we have to enable a custom fixup in InputDelegate.
	* To receive mouse wheel input for the scrolling list, we need skse.EnableMapMenuMouseWheel(true).
	* Oh, and the localmap reuses this class somehow for its IconView...
 */

class Map.MapMenu
{
  /* CONSTANTS */
  
	static var REFRESH_SHOW: Number = 0;
	static var REFRESH_X: Number = 1;
	static var REFRESH_Y: Number = 2;
	static var REFRESH_ROTATION: Number = 3;
	static var REFRESH_STRIDE: Number = 4;
	static var CREATE_NAME: Number = 0;
	static var CREATE_ICONTYPE: Number = 1;
	static var CREATE_UNDISCOVERED: Number = 2;
	static var CREATE_STRIDE: Number = 3;
	static var MARKER_CREATE_PER_FRAME: Number = 10;
	
	
  /* PRIVATE VARIABLES */
  
	private var _markerList: Array;
	
	private var _bottomBar: MovieClip;

	private var _nextCreateIndex: Number = -1;
	private var _mapWidth: Number = 0;
	private var _mapHeight: Number = 0;
	
	private var _mapMovie: MovieClip;
	private var _markerDescriptionHolder: MovieClip;
	private var _markerContainer: MovieClip;
	
	private var _selectedMarker: MovieClip;
	
	private var _platform: Number;
	
	private var _localMapButton: MovieClip;
	private var _journalButton: MovieClip;
	private var _playerLocButton: MovieClip;
	private var _findLocButton: MovieClip;
	private var _searchButton: MovieClip;
	
	private var _locationFinder: LocationFinder;
	
	
  /* STAGE ELEMENTS */
  
  	public var locationFinderFader: MovieClip;
	public var localMapFader: MovieClip;
	

  /* PROPERTIES */

	// @API
	public var LocalMapMenu: MovieClip;

	// @API
	public var MarkerDescriptionObj: MovieClip;
	
	// @API
	public var PlayerLocationMarkerType: String;
	
	// @API
	public var MarkerData: Array;
	
	// @API
	public var YouAreHereMarker: MovieClip;
	
	// @GFx
	public var bPCControlsReady: Boolean = true;


  /* INITIALIZATION */

	public function MapMenu(a_mapMovie: MovieClip)
	{
		_mapMovie = a_mapMovie == undefined ? _root : a_mapMovie;
		_markerContainer = _mapMovie.createEmptyMovieClip("MarkerClips", 1);
		
		_markerList = new Array();
		_nextCreateIndex = -1;
		
		LocalMapMenu = _mapMovie.localMapFader.MapClip;
		
		_locationFinder = _mapMovie.locationFinderFader.locationFinder;
		
		_bottomBar = _root.bottomBar;
		
		if (LocalMapMenu != undefined) {
			LocalMapMenu.setBottomBar(_bottomBar);
			LocalMapMenu.setLocationFinder(_locationFinder);
			
			Mouse.addListener(this);
			FocusHandler.instance.setFocus(this,0);
		}
		
		_markerDescriptionHolder = _mapMovie.attachMovie("DescriptionHolder", "markerDescriptionHolder", _mapMovie.getNextHighestDepth());
		_markerDescriptionHolder._visible = false;
		_markerDescriptionHolder.hitTestDisable = true;
		
		MarkerDescriptionObj = _markerDescriptionHolder.Description;
		
		Stage.addListener(this);
		
		initialize();
	}
	
	public function InitExtensions(): Void
	{
		skse.EnableMapMenuMouseWheel(true);
	}
	
	private function initialize(): Void
	{
		onResize();
		
		if (_bottomBar != undefined)
			_bottomBar.swapDepths(4);
		
		if (_mapMovie.localMapFader != undefined) {
			_mapMovie.localMapFader.swapDepths(3);
			_mapMovie.localMapFader.gotoAndStop("hide");
		}
		
		if (_mapMovie.locationFinderFader != undefined) {
			_mapMovie.locationFinderFader.swapDepths(6);
		}
		
		GameDelegate.addCallBack("RefreshMarkers", this, "RefreshMarkers");
		GameDelegate.addCallBack("SetSelectedMarker", this, "SetSelectedMarker");
		GameDelegate.addCallBack("ClickSelectedMarker", this, "ClickSelectedMarker");
		GameDelegate.addCallBack("SetDateString", this, "SetDateString");
		GameDelegate.addCallBack("ShowJournal", this, "ShowJournal");
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @API
	public function SetNumMarkers(a_numMarkers: Number): Void
	{
		if (_markerContainer != null)
		{
			_markerContainer.removeMovieClip();
			_markerContainer = _mapMovie.createEmptyMovieClip("MarkerClips", 1);
			onResize();
		}
		
		delete _markerList;
		_markerList = new Array(a_numMarkers);
		
		Map.MapMarker.topDepth = a_numMarkers;

		_nextCreateIndex = 0;
		SetSelectedMarker(-1);
		
		_locationFinder.list.clearList();
		_locationFinder.setLoading(true);
	}

	// @API
	public function GetCreatingMarkers(): Boolean
	{
		return _nextCreateIndex != -1;
	}

	// @API
	public function CreateMarkers(): Void
	{
		if (_nextCreateIndex == -1 || _markerContainer == null)
			return;
			
		var i = 0;
		var j = _nextCreateIndex * Map.MapMenu.CREATE_STRIDE;
		
		var markersLen = _markerList.length;
		var dataLen = MarkerData.length;
			
		while (_nextCreateIndex < markersLen && j < dataLen && i < Map.MapMenu.MARKER_CREATE_PER_FRAME) {
			var markerType = MarkerData[j + Map.MapMenu.CREATE_ICONTYPE];
			var markerName = MarkerData[j + Map.MapMenu.CREATE_NAME];
			var isUndiscovered = MarkerData[j + Map.MapMenu.CREATE_UNDISCOVERED];
			
			var mapMarker: MovieClip = _markerContainer.attachMovie(Map.MapMarker.ICON_TYPES[markerType], "Marker" + _nextCreateIndex, _nextCreateIndex);
			_markerList[_nextCreateIndex] = mapMarker;
			
			if (markerType == PlayerLocationMarkerType) {
				YouAreHereMarker = mapMarker.Icon;
			}
			mapMarker.index = _nextCreateIndex;
			mapMarker.label = markerName;				
			mapMarker.textField._visible = false;
			mapMarker.visible = false;
			mapMarker.iconType = markerType;
			
			// Adding the markers directly so we don't have to create data objects.
			// NOTE: Make sure internal entry properties (mappedIndex etc) dont conflict with marker properties
			if (0 < markerType && markerType < Map.LocationFinder.TYPE_RANGE) {
				_locationFinder.list.entryList.push(mapMarker);
			}
			
			if (isUndiscovered && mapMarker.IconClip != undefined) {
				var depth: Number = mapMarker.IconClip.getNextHighestDepth();
				mapMarker.IconClip.attachMovie(Map.MapMarker.ICON_TYPES[markerType] + "Undiscovered", "UndiscoveredIcon", depth);
			}
			
			++i;
			++_nextCreateIndex;
			
			j = j + Map.MapMenu.CREATE_STRIDE;
		}
		
		_locationFinder.list.InvalidateData();
		
		if (_nextCreateIndex >= markersLen) {
			_locationFinder.setLoading(false);
			_nextCreateIndex = -1;
		}
	}

	// @API
	public function RefreshMarkers(): Void
	{
		var i: Number = 0;
		var j: Number = 0;
		var markersLen: Number = _markerList.length;
		var dataLen: Number = MarkerData.length;
		
		while (i < markersLen && j < dataLen) {
			var marker: MovieClip = _markerList[i];
			marker._visible = MarkerData[j + Map.MapMenu.REFRESH_SHOW];
			if (marker._visible) {
				marker._x = MarkerData[j + Map.MapMenu.REFRESH_X] * _mapWidth;
				marker._y = MarkerData[j + Map.MapMenu.REFRESH_Y] * _mapHeight;
				marker._rotation = MarkerData[j + Map.MapMenu.REFRESH_ROTATION];
			}
			++i;
			j = j + Map.MapMenu.REFRESH_STRIDE;
		}
		if (_selectedMarker != undefined) {
			_markerDescriptionHolder._x = _selectedMarker._x + _markerContainer._x;
			_markerDescriptionHolder._y = _selectedMarker._y + _markerContainer._y;
		}
	}

	// @API
	public function SetSelectedMarker(a_selectedMarkerIndex: Number): Void
	{
		var marker: MovieClip = a_selectedMarkerIndex < 0 ? null : _markerList[a_selectedMarkerIndex];
		
		if (marker == _selectedMarker)
			return;
			
		if (_selectedMarker != null) {
			_selectedMarker.MarkerRollOut();
			_selectedMarker = null;
			_markerDescriptionHolder.gotoAndPlay("Hide");
		}
		
		if (marker != null && !_bottomBar.hitTest(_root._xmouse, _root._ymouse) && marker.visible && marker.MarkerRollOver()) {
			_selectedMarker = marker;
			_markerDescriptionHolder._visible = true;
			_markerDescriptionHolder.gotoAndPlay("Show");
			return;
		}
		_selectedMarker = null;
	}

	// @API
	public function ClickSelectedMarker(): Void
	{
		if (_selectedMarker != undefined) {
			_selectedMarker.MarkerClick();
		}
	}

	// @API
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		if (_bottomBar != undefined) {
			
			_bottomBar.buttonPanel.setPlatform(a_platform, a_bPS3Switch);

			createButtons();

			_localMapButton.disabled = a_platform != ButtonChange.PLATFORM_PC;
			_journalButton.disabled = a_platform != ButtonChange.PLATFORM_PC;
			_playerLocButton.disabled = a_platform != ButtonChange.PLATFORM_PC;
			_findLocButton.disabled = a_platform != ButtonChange.PLATFORM_PC;
		}
		
		InputDelegate.instance.isGamepad = a_platform != ButtonChange.PLATFORM_PC;
		InputDelegate.instance.enableControlFixup(true);
		
		_platform = a_platform;
	}

	// @API
	public function SetDateString(a_strDate: String): Void
	{
		_bottomBar.DateText.SetText(a_strDate);
	}

	// @API
	public function ShowJournal(a_bShow: Boolean): Void
	{
		if (_bottomBar != undefined) {
			_bottomBar._visible = !a_bShow;
		}
	}

	// @API
	public function SetCurrentLocationEnabled(a_bEnabled: Boolean): Void
	{
		if (_bottomBar != undefined && _platform == ButtonChange.PLATFORM_PC) {
			_bottomBar.PlayerLocButton.disabled = !a_bEnabled;
		}
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{			
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		// F
		if (GlobalFunc.IsKeyPressed(details) && (details.skseKeycode == 33)) {
			LocalMapMenu.showLocationFinder();
		}

		return false;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function OnLocalButtonClick(): Void
	{
		GameDelegate.call("ToggleMapCallback", []);
	}

	private function OnJournalButtonClick(): Void
	{
		GameDelegate.call("OpenJournalCallback", []);
	}

	private function OnPlayerLocButtonClick(): Void
	{
		GameDelegate.call("CurrentLocationCallback", []);
	}
	
	private function OnFindLocButtonClick(): Void
	{
		LocalMapMenu.showLocationFinder();
	}
	
	private function onMouseDown(): Void
	{
		if (_bottomBar.hitTest(_root._xmouse, _root._ymouse))
			return;
		GameDelegate.call("ClickCallback", []);
	}
	
	private function onResize(): Void
	{
		_mapWidth = Stage.visibleRect.right - Stage.visibleRect.left;
		_mapHeight = Stage.visibleRect.bottom - Stage.visibleRect.top;
		
		if (_mapMovie == _root) {
			_markerContainer._x = Stage.visibleRect.left;
			_markerContainer._y = Stage.visibleRect.top;
		} else {
			var localMap: LocalMap = LocalMap(_mapMovie);
			if (localMap != undefined) {
				_mapWidth = localMap.TextureWidth;
				_mapHeight = localMap.TextureHeight;
			}
		
		}
		GlobalFunc.SetLockFunction();
		_bottomBar.Lock("B");
	}
	
	private function createButtons(): Void
	{
		var buttonPanel: ButtonPanel = _bottomBar.buttonPanel;
		buttonPanel.clearButtons();

		_localMapButton = buttonPanel.addButton({text: "$Local Map", controls: {keyCode: 38}}); // 0 - L
		_journalButton = buttonPanel.addButton({text: "$Journal", controls: {name: "Journal", context: Input.CONTEXT_GAMEPLAY}}); // 1
		
		buttonPanel.addButton({text: "$Zoom", controls: {keyCode: 283}}); // 2 - special: mouse wheel
		
		_playerLocButton = buttonPanel.addButton({text: "$Current Location", controls: {keyCode: 18}}); // 3 - E
		_findLocButton = buttonPanel.addButton({text: "$Find Location", controls: {keyCode: 33}}); // 4 - F
		
		buttonPanel.addButton({text: "$Set Destination", controls: {keyCode: 256}}); // 5 - M1
		
		_searchButton = buttonPanel.addButton({text: "$Search", controls: Input.Space}); // 6 - F
		_searchButton._visible = false;
		
		_localMapButton.addEventListener("click", this, "OnLocalButtonClick");
		_journalButton.addEventListener("click", this, "OnJournalButtonClick");
		_playerLocButton.addEventListener("click", this, "OnPlayerLocButtonClick");
		_findLocButton.addEventListener("click", this, "OnFindLocButtonClick");
		
		buttonPanel.updateButtons(true);
	}
}