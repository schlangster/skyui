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
	public var finished: Boolean; // Effect has finished, it's fading out
	public var effect: Object;
	
  /* PRIVATE VARIABLES */
	//Meter
	private var _meter: MovieClip;
	
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	// Icon
	private var _iconLoader: MovieClipLoader;
	private var _icon: MovieClip;
	
	private var _iconLabel: String;
	
	public function ActiveEffect()
	{
		super();
		
		_meter = content.meter;
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		_icon = content.createEmptyMovieClip("icon", getNextHighestDepth());
		_iconLoader.loadClip("./skyui/skyui_icons_psychosteve.swf", _icon);
		_iconLabel = determineIconLabel();
		
		initMeter();
		
		updateActiveEffect();
		
		background._alpha = 0;
		content.background._alpha = 0;
	}
	
	public function updateActiveEffect(a_effect: Object)
	{
		effect = a_effect;
		
		var newPercent: Number = (100 * (effect.duration - effect.elapsed)) / effect.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, newPercent));
		_meter.gotoAndStop(meterFrame);
	}
	
	private function initMeter(): Void
	{
		_meter.gotoAndStop("Empty");
		_meterEmptyIdx = _meter._currentframe;
		_meter.gotoAndStop("Full");
		_meterFullIdx = _meter._currentframe;
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
	
	private function onLoadInit(a_mc: MovieClip): Void
	{
		if (a_mc == _icon) {
			_icon._x = 0;
			_icon._y = 0;
			_icon._width = _icon._height = 128;
			//_icon.gotoAndStop(iconLabel);
			_icon.gotoAndStop(Math.floor(Math.random() * 127));
		}
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
}