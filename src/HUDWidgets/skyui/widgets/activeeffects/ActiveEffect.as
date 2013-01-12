import skyui.util.EffectIconMap;
import Shared.GlobalFunc;

import com.greensock.TweenLite;
import com.greensock.easing.Linear;


class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
  /* CONSTANTS */
  
	private static var METER_WIDTH: Number = 15;
	private static var METER_PADDING: Number = 5;
	
	
  /* PRIVATE VARIABLES */

	private var _meter: MovieClip;
	
	private var _meterEmptyIdx: Number;
	private var _meterFullIdx: Number;
	
	// Icon
	private var _iconLoader: MovieClipLoader;
	private var _icon: MovieClip;
	private var _iconHolder: MovieClip;
	
	private var _iconBaseLabel: String;
	private var _iconEmblemLabel: String;
	

  /* STAGE ELEMENTS */
  
	private var content: MovieClip;
	private var background: MovieClip;
	
	
  /* PUBLIC VARIABLES */
  
	public var marker: Number;

	// initObject
	public var index: Number;
	public var effectData: Object;
	public var iconLocation: String;
	public var effectBaseSize: Number;
	public var effectSpacing: Number;
	public var effectFadeInDuration: Number;
	public var effectFadeOutDuration: Number;
	public var effectMoveDuration: Number;

	public var hAnchor: String;
	public var vAnchor: String;
	public var orientation: String;
	
	
  /* INITIALIZATION */
	
	public function ActiveEffect()
	{
		super();
		
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		
		_iconHolder = content.iconContent;
		_icon = _iconHolder.createEmptyMovieClip("icon", getNextHighestDepth());

		_width = _height = effectBaseSize;

		// Force position
		var p = determinePosition(index);
		_x = p[0];
		_y = p[1];
		
		initEffect();
		_iconLoader.loadClip(iconLocation, _icon);
		
		updateEffect(effectData);
		
		background._alpha = 0;
		_iconHolder.iconBackground._alpha = 0;

		TweenLite.from(this, effectFadeInDuration, {_alpha: 0, overwrite: 0, easing: Linear.easeNone});
	}


  /* PUBLIC FUNCTIONS */

	public function updateEffect(a_effectData: Object): Void
	{
		if (_meter == undefined) // Constant effects, no timer (e.g. Healing)
			return;
		
		effectData = a_effectData;
		var newPercent: Number = (100 * (effectData.duration - effectData.elapsed)) / effectData.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_meterEmptyIdx, _meterFullIdx, 0, 100, newPercent));
		_meter.gotoAndStop(meterFrame);
	}

	public function updatePosition(a_newIndex: Number): Void
	{
		index = a_newIndex;
		var p = determinePosition(index);
		TweenLite.to(this, effectMoveDuration, {_x: p[0], _y: p[1], overwrite: 0, easing: Linear.easeNone});
	}

	public function remove(): Void
	{
		TweenLite.to(this, effectFadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onEffectRemoved, onCompleteParams: [this], overwrite: 0, easing: Linear.easeNone});
	}


  /* PRIVATE FUNCTIONS */
  
	private function initEffect(): Void
	{
		var iconData = EffectIconMap.lookupIconLabel(effectData);
		_iconBaseLabel = iconData.baseLabel;
		_iconEmblemLabel = iconData.emblemLabel;
		
		skyui.util.Debug.log("Found icon " + _iconBaseLabel + ", emblem " + _iconEmblemLabel);
 
		if (_iconBaseLabel == "default_effect" || _iconBaseLabel == undefined || _iconBaseLabel == "") {
			skyui.util.Debug.log("[SkyUI Active Effects]: Couldn't determine icon for")
			for (var s: String in effectData)
				skyui.util.Debug.log("                        " + s + ": " + effectData[s])
		}
		
		// TODO: make icons scale. All the icons we use are 128*128 so it doesn't matter
		_iconHolder._width = _iconHolder._height = (_iconHolder._width - METER_PADDING - METER_WIDTH);
		_iconHolder._y = (background._height - _iconHolder._height) / 2;

		if (effectData.duration - effectData.elapsed > 1) {
			// Effect with duration, e.g. Potion of Fortifty Health
			initMeter();
		} else {
			// Instantaneous effect, no timer (e.g. Healing)
			// Healing actually has a duration of 1, but it keeps reapplying itself after it's dispelled
			// No meter, just icon: center the icon
//			_iconHolder._x = (background._width - _iconHolder._width) / 2;
		}
	}

	private function initMeter(): Void
	{
		_meter = content.attachMovie("SimpleMeter", "meter", content.getNextHighestDepth(), {_x: (background._width - METER_WIDTH), _y: _iconHolder._y, _width: METER_WIDTH, _height: _iconHolder._height});
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
		_icon.baseIcon.gotoAndStop(_iconBaseLabel);
		_icon.emblemIcon.gotoAndStop(_iconEmblemLabel);
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

	private function determinePosition(a_index: Number): Array
	{
		var newX: Number = 0;
		var newY: Number = 0;

		// Orientation is the orientation of the EffectsGroups
		if (orientation == "vertical") { // Orientation vertical means that the ActiveEffect is in a column, so the next effect needs to be added either above, or below
			if (vAnchor == "bottom") {  // Widget is anchored vertically to the bottom of the stage, so need to add next ActiveEffect above
				newY = -(index * (effectBaseSize + effectSpacing));
			} else {
				newY = +(index * (effectBaseSize + effectSpacing));
			}
		} else { // Orientation horizontal means that the ActiveEffect is in a row, so the next effect needs to be added either to the left, or right
			if (hAnchor == "right") {  // Widget is anchored horizontally to the right of the stage, so need to add next ActiveEffect to the left
				newX = -(index * (effectBaseSize + effectSpacing));
			} else {
				newX = +(index * (effectBaseSize + effectSpacing));
			}
		}

		return [newX, newY];
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



