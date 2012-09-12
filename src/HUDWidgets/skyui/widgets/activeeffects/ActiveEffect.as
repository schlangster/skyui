import skyui.util.Defines;
import Shared.GlobalFunc;

// Only used in remove();
/*
import com.greensock.TweenLite;
import com.greensock.easing.Linear;
*/

class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
  /* STAGE ELEMENTS */
	private var content: MovieClip;
	private var background: MovieClip;
	
  /* PUBLIC VARIABLES */
	public var marker: Number;

	// initObject
	public var index: Number;
	public var iconLocation: String;
	public var effectData: Object;
	
  /* PRIVATE VARIABLES */
  	// Meter
	private var _meter: MovieClip;
	
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	private var _meterWidth: Number = 15;
	private var _meterPadding: Number = 5;
	
	// Icon
	private var _iconLoader: MovieClipLoader;
	private var _icon: MovieClip;
	private var _iconHolder: MovieClip;
	
	private var _iconLabel: String;
	
	public function ActiveEffect()
	{
		super();
		
		/*	initObject data from ActiveEffectsColumns attachMovie():
			var initObject: Object = {index: _effectsArray.length,
									iconLocation: ICON_LOCATION,
									effectData: a_effectData,
									_y: effectIdx * (128+10)}; */
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		
		_iconHolder = content.iconContent;
		_icon = _iconHolder.createEmptyMovieClip("icon", getNextHighestDepth());
		_iconLoader.loadClip(iconLocation, _icon);
		
		initEffect();
		
		update(effectData);
		
		background._alpha = 0;
		_iconHolder.iconBackground._alpha = 0;
	}

  /* PUBLIC FUNCTIONS */
	
	public function update(a_effectData: Object): Void
	{
		if (_meter == undefined) {
			// Constant effects, no timer (e.g. Healing)
			return;
		}
		
		
		effectData = a_effectData;
		var newPercent: Number = (100 * (effectData.duration - effectData.elapsed)) / effectData.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, newPercent));
		_meter.gotoAndStop(meterFrame);
	}

	// Now uses effectsColumn.removeEffect(effectClip); to be more consistent with effectsColumn.addEffect(effectData);
	/*
	public function remove(): Void
	{
		TweenLite.to(this, 1, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onEffectRemoved, onCompleteParams: [this], overwrite: "AUTO", easing: Linear.easeNone});
	}
	*/

  /* PRIVATE FUNCTIONS */
	
	private function initEffect(): Void
	{
		_iconLabel = determineIconLabel();
		if (effectData.duration - effectData.elapsed > 1) {
			// Effect with duration, e.g. Potion of Fortifty Health
			// TODO, make it scale. All the icons we use are 128*128 so it doesn't matter
			_iconHolder._width = _iconHolder._height = (_iconHolder._width - _meterPadding - _meterWidth);
			_iconHolder._y = (background._height - _iconHolder._height) / 2;

			initMeter();
		} else {
			// Instantaneous effect, no timer (e.g. Healing)
			// No meter, just icon: do nothing
			// This branch is here just in case you wanted to do something with it
		}
	}

	private function initMeter(): Void
	{
		_meter = content.attachMovie("SimpleMeter", "meter", content.getNextHighestDepth(), {_x: (background._width - _meterWidth), _y: _iconHolder._y, _width: _meterWidth, _height: _iconHolder._height});
		_meter.background._alpha = 50;
		_meter.gotoAndStop("Empty");
		_meterEmptyIdx = _meter._currentframe;
		_meter.gotoAndStop("Full");
		_meterFullIdx = _meter._currentframe;
	}
	
	private function onLoadInit(a_mc: MovieClip): Void
	{
		_icon._x = 0;
		_icon._y = 0;

		// TODO, make it scale w/ icon size. All the icons we use are 128*128 so it doesn't matter
		_icon._width = _icon._height = _iconHolder.iconBackground._width;
		//_icon.gotoAndStop(determineIconLabel());
		_icon.gotoAndStop(Math.floor(1 + Math.random() * 126));
	}

	private function onLoadError(a_mc: MovieClip, a_errorCode: String): Void
	{
		var errorTextField: TextField = _iconHolder.createTextField("ErrorTextField", _iconHolder.getNextHighestDepth(), 0, 0, _iconHolder.iconBackground._width, _iconHolder.iconBackground._height);
		errorTextField.verticalAlign = "center";
		errorTextField.textAutoSize = "fit";
		errorTextField.multiLine = true;

		var tf: TextFormat = new TextFormat();
		tf.align = "center";
		tf.color = 0xFFFFFF;
		tf.indent = 20;
		tf.font = "$EverywhereBoldFont";
		errorTextField.setNewTextFormat(tf);

		errorTextField.text = "No Icon\nSource";
	}
	
	
	
	private function determineIconLabel(): String
	{
		if (!effectData.actorValue)
			return "default_effect";
		
		switch(effectData.actorValue) {
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
