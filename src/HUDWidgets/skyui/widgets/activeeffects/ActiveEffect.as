import skyui.util.Defines;
import Shared.GlobalFunc;
import flash.geom.Matrix;

class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
  /* STAGE ELEMENTS */
	private var content: MovieClip;
	private var background: MovieClip;
	
  /* PUBLIC VARIABLES */
	public var marker: Number;
	public var index: Number; // index in the _clipArray
	public var iconLocation: String;
	public var finished: Boolean; // Effect has finished, it's fading out
	public var effect: Object;
	
  /* PRIVATE VARIABLES */
	//Meter
	private var _meter: MovieClip;
	
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	private var _meterWidth: Number = 10;
	private var _meterPadding: Number = 5;
	
	// Icon
	private var _iconLoader: MovieClipLoader;
	private var _icon: MovieClip;
	private var _iconHolder: MovieClip;
	
	private var _iconLabel: String;
	
	public function ActiveEffect()
	{
		super();
		
		/*	Data from initObject:
			{marker: marker,
			index: _clipArray.length,
			iconLocation: iconLocation,
			finished: false,
			effect: effect,
			_alpha: 0,
			_xscale: effectScale,
			_yscale: effectScale}; /*
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		
		_iconHolder = content.iconContent;
		_icon = _iconHolder.createEmptyMovieClip("icon", getNextHighestDepth());
		_iconLoader.loadClip(iconLocation, _icon);
		
		initEffect();
		
		updateActiveEffect();
		
		background._alpha = 0;
		_iconHolder.iconBackground._alpha = 0;
	}
	
	public function updateActiveEffect(a_effect: Object)
	{
		if (_meter == undefined)
			return;
		
		effect = a_effect;
		var newPercent: Number = (100 * (effect.duration - effect.elapsed)) / effect.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, newPercent));
		_meter.gotoAndStop(meterFrame);
	}
	
	private function initMeter(): Void
	{
		_meter = content.attachMovie("SimpleMeter", "meter", content.getNextHighestDepth(), {_x: (_iconHolder._width - _meterWidth), _y: 0, _width: _meterWidth, _height: background._height});
		_meter.gotoAndStop("Empty");
		_meterEmptyIdx = _meter._currentframe;
		_meter.gotoAndStop("Full");
		_meterFullIdx = _meter._currentframe;
	}
	
	private function initEffect(): Void
	{
		_iconLabel = determineIconLabel();
		if (effect.duration - effect.elapsed > 1) {
			// Effect over time
			initMeter();
			// TODO, make it scale. All the icons we use are 128*128 so it doesn't matter
			_iconHolder._width = _iconHolder._height = (_iconHolder._width - _meterPadding - _meterWidth);
			_iconHolder._y = (background._height - _iconHolder._height) / 2
		} else {
			// single effect..
			_icon._width;
		}
	}
	
	private function onLoadInit(a_mc: MovieClip): Void
	{
		_icon._x = 0;
		_icon._y = 0;
		// TODO, make it scale. All the icons we use are 128*128 so it doesn't matter
		_icon._width = _icon._height = _iconHolder.iconBackground._width;
		//_icon.gotoAndStop(iconLabel);
		_icon.gotoAndStop(Math.floor(Math.random() * 127));
	}
	
	
	
	private function determineIconLabel(): String
	{
		if (!effect.actorValue)
			return "default_effect";
		
		switch(effect.actorValue) {
			case Defines.ACTORVALUE_HEALTH:
			case Defines.ACTORVALUE_MAGICKA:
			case Defines.ACTORVALUE_STAMINA:
			case Defines.ACTORVALUE_HEALRATE:
			case Defines.ACTORVALUE_MAGICKARATE:
			case Defines.ACTORVALUE_STAMINARATE:
				return "default_power";
			default:
				return "default_effect";
		}
	}

		
	private function parseTime(a_s: Number): String
	{
		var s: Number = Math.floor(a_s);
		var m: Number = 0;
		var h: Number = 0;
		var d: Number = 0;

		if (s >= 60) {
			m = Math.floor(s / 60);
			s = s % 60;
		}
		if  (m >= 60) {
			h = Math.floor(m / 60);
			m = m % 60;
		}
		if  (h >= 24) {
			d = Math.floor(h / 24);
			h = h % 24;
		}
		
		return ((d != 0 ? (d + "d ") : "") +
				(h != 0 || d ? (h + "h ") : "") +
				(m != 0 || d || h ? (m + "m ") : "") +
				(s + "s"));
	}
	}
