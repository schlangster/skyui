import gfx.io.GameDelegate;
import com.greensock.TweenNano;

class Map.MapMarker extends gfx.controls.Button
{
  /* CONSTANTS */

	private static var ICON_MAP: Array = [
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
	
	private static var ICONHOLDER_SIZE: Number = 50;
	private static var UNDISCOVERED_OFFSET: Number = 80;
	
	
  /* STAGE ELEMENTS */
	public var IconClip: MovieClip;
	public var HitArea: MovieClip;


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

	public var iconFrame: Number = 1;
	
	// initObject
	public var markerType: Number;
	public var isUndiscovered: Boolean;
	public var markerSize: Number;


  /* PRIVATE VARIABLES */
	private var _iconName: String = "";


  /* INITIALIZATION */

	public function MapMarker()
	{
		super();

		hitArea = HitArea;
		
		disableFocus = true;
		_iconName = ICON_MAP[markerType];
		iconFrame = (_iconName == null) ? 0 : markerType;
		iconFrame += ((isUndiscovered == true) ? UNDISCOVERED_OFFSET : 0) + 1; // Frame numbers start at 1
	}

	public function configUI(): Void
	{
		super.configUI();

		onRollOver = function () {};
		onRollOut = function () {};

		var iconHolder: MovieClip = IconClip.iconHolder;
		var icon: MovieClip = iconHolder.icon;

		iconHolder.background._visible = false;
		icon.gotoAndStop(iconFrame);

		switch (_iconName) {
			case "MineMarker":
			case "SmelterMarker":
			case "StableMarker":
			case "CampMarker":
			case "CaveMarker":
			case "GiantCampMarker":
			case "GroveMarker":
			case "SettlementMarker":
			case "ShackMarker":
			case "AltarMarker":
			case "ClearingMarker":
			case "FarmMarker":
			case "NordicDwellingMarker":
			case "WheatMillMarker":
			case "WoodMillMarker":
				markerSize -= markerSize/3;
				break;

			case "DoorMarker":
				iconHolder._alpha = 100;
				break;

			case "YouAreHereMarker":
			case "QuestTargetMarker":
			case "MultipleQuestTargetMarker":
				IconClip.gotoAndPlay("StartBlink");
			case "CityMarker":
			case "TownMarker":
			case "RiftenCapitolMarker":
			case "WindhelmCapitolMarker":
			case "WhiterunCapitolMarker":
			case "SolitudeCapitolMarker":
			case "MarkarthCapitolMarker":
			case "WinterholdCapitolMarker":
			case "MorthalCapitolMarker":
			case "FalkreathCapitolMarker":
			case "DawnstarCapitolMarker":
			case "PlayerSetMarker":
				markerSize += markerSize/3;
				break;

			case "QuestTargetDoorMarker":
				IconClip.gotoAndPlay("StartBlink");
				markerSize += 2*markerSize/3;
				break;

			case "EmptyMarker":
				IconClip._alpha = 0;
				break;
		}

		// Scale the icons to fit markerSize square without overflow
		if (icon._width > icon._height) {
			icon._height *= markerSize / icon._width;
			icon._width = markerSize;
		} else {
			icon._width *= markerSize / icon._height;
			icon._height = markerSize;
		}
	}

  /* PUBLIC FUNCTIONS */
  
  	// @override gfx.controls.Button
	public function setState(a_state: String): Void
	{
		if (_fadingOut || _fadingIn)
			return;

		super.setState(a_state);

		switch (_iconName) {
			case "DoorMarker":
				if (a_state == "over")
					TweenNano.to(IconClip.iconHolder, 10, {_width: ICONHOLDER_SIZE * 1.5, _height: ICONHOLDER_SIZE * 1.5, useFrames: true});
				else
					TweenNano.to(IconClip.iconHolder, 10, {_width: ICONHOLDER_SIZE, _height: ICONHOLDER_SIZE, useFrames: true});
				break;

			case "QuestTargetMarker":
			case "QuestTargetDoorMarker":
			case "MultipleQuestTargetMarker":
			case "YouAreHereMarker":
				break;

			case "PlayerSetMarker":
				if (a_state == "over")
					TweenNano.to(IconClip.iconHolder, 10, {_alpha: 100, useFrames: true});
				else
					TweenNano.to(IconClip.iconHolder, 10, {_alpha: 60, useFrames: true});
				break;

			default:
				if (a_state == "over")
					TweenNano.to(IconClip.iconHolder, 10, {_width: ICONHOLDER_SIZE * 1.5, _height: ICONHOLDER_SIZE * 1.5, _alpha: 100, useFrames: true});
				else
					TweenNano.to(IconClip.iconHolder, 10, {_width: ICONHOLDER_SIZE, _height: ICONHOLDER_SIZE, _alpha: 60, useFrames: true});
		}
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
