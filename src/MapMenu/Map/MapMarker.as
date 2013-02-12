import gfx.io.GameDelegate;
import com.greensock.TweenNano;

class Map.MapMarker extends gfx.controls.Button
{
  /* CONSTANTS */

	public static var ICON_TYPES: Array = [
		"EmptyMarker", "CityMarker", "TownMarker", "SettlementMarker", "CaveMarker",
		"CampMarker", "FortMarker", "NordicRuinMarker", "DwemerMarker", "ShipwreckMarker",
		"GroveMarker", "LandmarkMarker", "DragonlairMarker", "FarmMarker", "WoodMillMarker",
		"MineMarker", "ImperialCampMarker", "StormcloakCampMarker", "DoomstoneMarker", "WheatMillMarker",
		"SmelterMarker", "StableMarker", "ImperialTowerMarker", "ClearingMarker", "PassMarker",
		"AltarMarker", "RockMarker", "LighthouseMarker", "OrcStrongholdMarker", "GiantCampMarker",
		"ShackMarker", "NordicTowerMarker", "NordicDwellingMarker", "DocksMarker", "ShrineMarker",
		"RiftenCastleMarker", "RiftenCapitolMarker", "WindhelmCastleMarker", "WindhelmCapitolMarker", "WhiterunCastleMarker",
		"WhiterunCapitolMarker", "SolitudeCastleMarker", "SolitudeCapitolMarker", "MarkarthCastleMarker", "MarkarthCapitolMarker",
		"WinterholdCastleMarker", "WinterholdCapitolMarker", "MorthalCastleMarker", "MorthalCapitolMarker", "FalkreathCastleMarker",
		"FalkreathCapitolMarker", "DawnstarCastleMarker", "DawnstarCapitolMarker", "DLC02MiraakTempleMarker", "DLC02RavenRockMarker",
		"DLC02StandingStonesMarker", "DLC02TelvanniTowerMarker", "DLC02ToSkyrimMarker", "DLC02ToSolstheimMarker", "DLC02CastleKarstaagMarker",
		"", "DoorMarker", "QuestTargetMarker", "QuestTargetDoorMarker", "MultipleQuestTargetMarker",
		"PlayerSetMarker", "YouAreHereMarker"
	];
	
	
  /* STAGE ELEMENTS */
	
	public var HitAreaClip: MovieClip;
	public var TextClip: MovieClip;
	public var IconClip: MovieClip;


  /* STATIC VARIABLES */
  
	public static var topDepth: Number = 0;


  /* PROPERTIES */

	public var index: Number = -1;

	private var _fadingIn: Boolean = false;

	public function get FadingIn(): Boolean
	{
		return _fadingIn;
	}

	public function set FadingIn(value: Boolean): Void
	{
		if (value != _fadingIn) {
			_fadingIn = value;
			if (_fadingIn) {
				_visible = true;
				gotoAndPlay("fade_in");
			}
		}
	}
	
	private var _fadingOut: Boolean = false;

	public function get FadingOut(): Boolean
	{
		return _fadingOut;
	}
	
	public function set FadingOut(value: Boolean): Void
	{
		if (value != _fadingOut) {
			_fadingOut = value;
			if (_fadingOut) {
				gotoAndPlay("fade_out");
			}
		}
	}
	
	public var iconType: Number = 0;


  /* INITIALIZATION */

	public function MapMarker()
	{
		super();
		
		hitArea = HitAreaClip;
		
		textField = TextClip.MarkerNameField;
		textField.autoSize = "left";
		
		disableFocus = true;
		
		stateMap.release = ["up"];
	}

	public function configUI(): Void
	{
		super.configUI();
		
		onRollOver = function ()
		{
		};
		onRollOut = function ()
		{
		};
	}


  /* PUBLIC FUNCTIONS */
  
  	// @override gfx.controls.Button
	public function setState(a_state: String): Void
	{
		if (!_fadingOut && !_fadingIn)
			super.setState(a_state);
	}

	public function MarkerRollOver(): Boolean
	{
		if (IconClip.foundIcon)
			TweenNano.to(IconClip.foundIcon, 1, {_alpha: 0, onComplete: removeMovieClip, onCompleteScope: IconClip.foundIcon});
		
		var overState: Boolean = false;
		setState("over");
		overState = state == "over";
		if (overState) {
			var topInstance: MovieClip = _parent.getInstanceAtDepth(Map.MapMarker.topDepth);
			if (topInstance != null)
				topInstance.swapDepths(Map.MapMarker(topInstance).index);
			swapDepths(Map.MapMarker.topDepth);
			GameDelegate.call("PlaySound", ["UIMapRollover"]);
		}
		return overState;
	}

	public function MarkerRollOut(): Void
	{
		setState("out");
	}

	public function MarkerClick(): Void
	{
		GameDelegate.call("MarkerClick", [index]);
	}

}
