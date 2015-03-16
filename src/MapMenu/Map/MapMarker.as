import gfx.io.GameDelegate;

import mx.utils.Delegate;
import skyui.util.Tween;

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

	private static var UNDISCOVERED_OFFSET: Number = 80;

	private static var MARKER_BASE_SIZE: Number = 30;
	private static var MARKER_SCALE_MAX: Number = 150;
	private static var MARKER_ALPHA_MIN: Number = 60;
	private static var TWEEN_TIME: Number = 0.2;
	
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


  /* PRIVATE VARIABLES */

	private var _iconName: String = "";

	private var _markerSize: Number;


  /* INITIALIZATION */

	public function MapMarker()
	{
		super();

		hitArea = HitArea;
		
		disableFocus = true;
		_markerSize = MARKER_BASE_SIZE;
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

		IconClip._alpha = MARKER_ALPHA_MIN;

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
				_markerSize -= _markerSize/3;
				break;

			case "DoorMarker":
				IconClip._alpha = 100;
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
				_markerSize += _markerSize/3;
				break;

			case "QuestTargetDoorMarker":
				IconClip.gotoAndPlay("StartBlink");
				_markerSize += 2*_markerSize/3;
				break;

			case "EmptyMarker":
				IconClip._alpha = 0;
				break;
		}

		// Scale the icons to fit _markerSize square without overflow
		if (icon._width > icon._height) {
			icon._height *= _markerSize / icon._width;
			icon._width = _markerSize;
		} else {
			icon._width *= _markerSize / icon._height;
			icon._height = _markerSize;
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
			case "QuestTargetMarker":
			case "QuestTargetDoorMarker":
			case "MultipleQuestTargetMarker":
			case "YouAreHereMarker":
				break;

			case "PlayerSetMarker":
			case "DoorMarker":
			default:
				if (_iconName != "PlayerSetMarker")
				{
					if (a_state == "over")
					{
						Tween.LinearTween(IconClip, "_xscale", 100, MARKER_SCALE_MAX, TWEEN_TIME, null);
						Tween.LinearTween(IconClip, "_yscale", 100, MARKER_SCALE_MAX, TWEEN_TIME, null);
					} else {
						Tween.LinearTween(IconClip, "_xscale", MARKER_SCALE_MAX, 100, TWEEN_TIME, null);
						Tween.LinearTween(IconClip, "_yscale", MARKER_SCALE_MAX, 100, TWEEN_TIME, null);
					}
				}


				if (_iconName != "DoorMarker")
				{
					if (a_state == "over")
					{
						Tween.LinearTween(IconClip, "_alpha", MARKER_ALPHA_MIN, 100, TWEEN_TIME, null);
					} else {
						Tween.LinearTween(IconClip, "_alpha", 100, MARKER_ALPHA_MIN, TWEEN_TIME, null);
					}
				}
		}
	}

	public function MarkerRollOver(): Boolean
	{
		if (IconClip.foundIcon)
		{
			Tween.LinearTween(IconClip.foundIcon, "_alpha", 100, 0, TWEEN_TIME, Delegate.create(IconClip.foundIcon, removeMovieClip));
		}
		
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
