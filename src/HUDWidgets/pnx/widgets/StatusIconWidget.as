import skyui.widgets.WidgetBase;

import gfx.events.EventDispatcher;
import Shared.GlobalFunc;


class pnx.widgets.StatusIconWidget extends WidgetBase
{
  /* PRIVATE VARIABLES */

	private var _enabled: Boolean = false;
	private var _iconSize: Number = 32;
	private var _orientation: String = "vertical";
	
	// Alpha
	private var _hungerPerc: Number = 0;
	private var _thirstPerc: Number = 0;
	private var _fatiguePerc: Number = 0;
	
	// Color
	private var _hungerLevel: Number = 0;
	private var _thirstLevel: Number = 0;
	private var _fatigueLevel: Number = 0;
	
	private var _hungerIcon: MovieClip;
	private var _thirstIcon: MovieClip;
	private var _fatigueIcon: MovieClip;
	
	private var _visibleIconCount: Number;
	
	
  /* STAGE ELEMENTS */
	
	public var iconHolder: MovieClip;
  
  
  /* INITIALIZATION */

	public function StatusIconWidget()
	{
		super();
		
		_hungerIcon = iconHolder.hungerIcon;
		_thirstIcon = iconHolder.thirstIcon;
		_fatigueIcon = iconHolder.fatigueIcon;

		EventDispatcher.initialize(this);
	}


  /* PUBLIC FUNCTIONS */
	
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
  
	// @overrides WidgetBase
	public function getWidth(): Number
	{
		return _iconSize * (_orientation == "vertical" ? 1 : _visibleIconCount);
	}

	// @overrides WidgetBase
	public function getHeight(): Number
	{
		return _iconSize * (_orientation == "vertical" ? _visibleIconCount : 1);
	}
	
	// @Papyrus
	public function initNumbers(a_enabled: Boolean, a_iconSize: Number): Void
	{
		_enabled = a_enabled;
		_iconSize = a_iconSize;
	}

	// @Papyrus
	public function initStrings(a_orientation: String): Void
	{
		_orientation = a_orientation.toLowerCase();
	}

	// @Papyrus
	public function initCommit(): Void
	{
		invalidateIcons();
	}

	// @Papyrus
	public function setIconSize(a_iconSize: Number): Void
	{
		_iconSize = a_iconSize;
		invalidateIcons();
	}

	// @Papyrus
	public function setEnabled(a_enabled: Boolean): Void
	{
		_enabled = a_enabled;
		
		iconHolder._visible = a_enabled;
		
		invalidateIcons();
	}

	// @Papyrus
	public function setOrientation(a_orientation: String): Void
	{
		_orientation = a_orientation.toLowerCase();

		invalidateIcons();
	}
	
	// @Papyrus
	public function setStatus(a_hungerPerc: Number, a_thirstPerc: Number, a_fatiguePerc: Number, 
							  a_hungerLevel: Number, a_thirstLevel: Number, a_fatigueLevel: Number): Void
	{
		_hungerPerc = a_hungerPerc;
		_thirstPerc = a_thirstPerc;
		_fatiguePerc = a_fatiguePerc;
		
		_hungerLevel = a_hungerLevel;
		_thirstLevel = a_thirstLevel;
		_fatigueLevel = a_fatigueLevel;
		
		invalidateIcons();
	}
	

  /* PRIVATE FUNCTIONS */

	private function invalidateIcons(): Void
	{
		if (!_enabled)
			return;
		
		var hungerAlpha = _hungerPerc > 0 ? GlobalFunc.Lerp(25, 75, 0, 100, _hungerPerc) : 0;
		var thirstAlpha = _thirstPerc > 0 ? GlobalFunc.Lerp(25, 75, 0, 100, _thirstPerc) : 0;
		var fatigueAlpha = _fatiguePerc > 0 ? GlobalFunc.Lerp(25, 75, 0, 100, _fatiguePerc) : 0;
		
		var axis1 = _orientation == "vertical" ? "_x" : "_y";
		var axis2 = _orientation != "vertical" ? "_x" : "_y";
		
		// 1. position icons
		
		_hungerIcon[axis1] = 0;
		_thirstIcon[axis1] = 0;
		_fatigueIcon[axis1] = 0;
			
		var offset = 0;
		_visibleIconCount = 0;
			
		if (hungerAlpha > 0) {
			_hungerIcon[axis2] = offset;
			offset += _iconSize;
			_hungerIcon.gotoAndStop(_hungerLevel+1);
			_visibleIconCount++;
		} else {
			_hungerIcon[axis2] = 0;
		}
		_hungerIcon._alpha = hungerAlpha;
		
		if (thirstAlpha > 0) {
			_thirstIcon[axis2] = offset;
			offset += _iconSize;
			_thirstIcon.gotoAndStop(_thirstLevel+1);
			_visibleIconCount++;
		} else {
			_thirstIcon[axis2] = 0;
		}
		_thirstIcon._alpha = thirstAlpha;
		
		if (fatigueAlpha > 0) {
			_fatigueIcon[axis2] = offset;
			offset += _iconSize;
			_fatigueIcon.gotoAndStop(_fatigueLevel+1);
			_visibleIconCount++;
		} else {
			_fatigueIcon[axis2] = 0;
		}
		_fatigueIcon._alpha = fatigueAlpha;
		
		invalidateSize();
	}
}