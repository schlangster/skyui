import skyui.util.ColorFunctions;
import Shared.GlobalFunc;
import flash.geom.Transform;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

class skyui.components.Meter extends MovieClip
{
  /* CONSTANTS */

	public static var FILL_DIRECTION_LEFT: String = "left";
	public static var FILL_DIRECTION_RIGHT: String = "right";
	public static var FILL_DIRECTION_BOTH: String = "both";

  /* PRIVATE VARIABLES */
	
	private var _originalWidth: Number;
	private var _originalHeight: Number;
	private var _originalCapWidth: Number;
	private var _originalCapHeight: Number;
	private var _originalMeterFillHolderWidth: Number;

	private var _meterFrameContent: MovieClip;
	private var _meterFillHolder: MovieClip;
	private var _meterFillContent: MovieClip;
	private var _meterFlashAnim: MovieClip;
	private var _meterBarAnim: MovieClip;
	private var _meterBar: MovieClip;

	private var _currentPercent: Number;
	private var _targetPercent: Number;
	private var _fillDelta: Number = 0.02;
	private var _emptyDelta: Number = 0.03;
	private var _emptyIdx: Number;
	private var _fullIdx: Number;
	
	private var _fillDirection: String;
	private var _secondaryColor: Number;
	private var _primaryColor: Number;
	private var _flashColor: Number;
	private var _flashColorAuto: Boolean = false;

	private var __width: Number;
	private var __height: Number;

	private var _initialized: Boolean = false;

  /* STAGE ELEMENTS */
	
	public var meterContent: MovieClip;
	public var background: MovieClip;

  /* INITIALIZATION */

	public function Meter()
	{
		super();

		background._visible = meterContent.capBackground._visible = false;

		// Set internal dimensions to stage dimensions
		__width = _width;
		__height = _height;

		_meterFrameContent = meterContent.meterFrameHolder.meterFrameContent;
		_meterFillHolder = meterContent.meterFillHolder;
		_meterFillContent = _meterFillHolder.meterFillContent;
		_meterFlashAnim = _meterFrameContent.meterFlashAnim;
		_meterBarAnim = _meterFillContent.meterBarAnim;
		_meterBar = _meterBarAnim.meterBar;

		_originalWidth = background._width;
		_originalHeight = background._height;
		_originalCapWidth = meterContent.capBackground._width;
		_originalCapHeight = meterContent.capBackground._height;
		_originalMeterFillHolderWidth = _meterFillHolder._width;

		_meterFillHolder._x = _originalCapWidth;

		// Set stage dimensions to original dimensions and invalidate size
		_width = _originalWidth;
		_height = _originalHeight;
	}

	public function onLoad(): Void
	{
		invalidateSize();
		invalidateFillDirection();

		onEnterFrame = enterFrameHandler;

		_initialized = true;
	}

  /* PROPERTIES */

	public function get width(): Number 
	{
		return __width;
	}
	public function set width(a_width: Number): Void
	{
		if (__width == a_width)
			return;
		__width = a_width;

		if (_initialized)
			invalidateSize();
	}

	public function get height(): Number 
	{
		return background._height;
	}
	public function set height(a_height: Number): Void
	{
		if (__height == a_height)
			return;
		__height = a_height;

		if (_initialized)
			invalidateSize();
	}

	public function setSize(a_width: Number, a_height: Number): Void
	{
		if (__width == a_width && __height == a_height)
			return;
		
		__width = a_width;
		__height = a_height;

		if (_initialized)
			invalidateSize();
	}

	public function get color(): Number 
	{
		return _primaryColor;
	}
	public function set color(a_primaryColor: Number): Void
	{
		var lightColor: Number = (a_primaryColor == undefined)? 0xFFFFFF: ColorFunctions.validHex(a_primaryColor);
		if (lightColor == _primaryColor)
			return;
		_primaryColor = lightColor;

		var darkColorHSV: Array = ColorFunctions.hexToHsv(lightColor);
		darkColorHSV[2] -= 40;

		_secondaryColor = ColorFunctions.hsvToHex(darkColorHSV);

		if (_initialized)
			invalidateColor();
	}

	public function setColors(a_primaryColor: Number, a_secondaryColor: Number, a_flashColor: Number): Void
	{
		// Wasteful checking..
		//if (a_primaryColor != undefined && _primaryColor == a_primaryColor && _secondaryColor == a_secondaryColor)
		//	return;
		flashColor = a_flashColor;

		if (a_secondaryColor == undefined || a_secondaryColor < 0x000000) {
			color = a_primaryColor;
			return;
		}

		_primaryColor = (a_primaryColor == undefined)? 0xFFFFFF: ColorFunctions.validHex(a_primaryColor);
		_secondaryColor = ColorFunctions.validHex(a_secondaryColor);

		if (_initialized)
			invalidateColor();
	}

	public function get flashColor(): Number
	{
		return _flashColor;
	}
	public function set flashColor(a_flashColor: Number): Void
	{	
		var RRGGBB: Number;
		_flashColorAuto = false;


		if ((a_flashColor < 0x000000 || a_flashColor == undefined) && _primaryColor != undefined) {
			RRGGBB = _primaryColor;
			_flashColorAuto = true;
		} else if (a_flashColor == undefined) {
			RRGGBB = 0xFFFFFF;
		} else {
			RRGGBB = ColorFunctions.validHex(a_flashColor);
		}
		
		if (_flashColor == RRGGBB)
			return;
		_flashColor = RRGGBB;

		if (_initialized)
			invalidateFlashColor();
	}

	public function get fillDirection(): String 
	{
		return _fillDirection;
	}
	public function set fillDirection(a_fillDirection: String): Void
	{
		setFillDirection(a_fillDirection)
	}

	public function setFillDirection(a_fillDirection, a_restorePercent: Boolean): Void
	{
		var fillDirection: String = a_fillDirection.toLowerCase();
		if (_fillDirection == fillDirection && !a_restorePercent)
			return;
		_fillDirection = fillDirection;

		if (_initialized)
			invalidateFillDirection(a_restorePercent);
	}

	public function get percent(): Number 
	{
		return _targetPercent;
	}
	public function set percent(a_percent: Number): Void
	{
		setPercent(a_percent);
	}

	public function setPercent(a_percent: Number, a_force: Boolean): Void
	{
		_targetPercent = Math.min(1, Math.max(a_percent, 0));

		if (a_force) {
			_currentPercent = _targetPercent;
			var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_emptyIdx, _fullIdx, 0, 1, _currentPercent));
			_meterBarAnim.gotoAndStop(meterFrame);
		}
	}

	public function startFlash(a_force: Boolean): Void
	{
		// meterFlashing is set on the timeline and is false once the animation has finished
		if (_meterFlashAnim.meterFlashing && !a_force) {
			return;
		}

		_meterFlashAnim.gotoAndPlay("StartFlash");
	}

  /* PRIVATE FUNCTIONS */

	private function invalidateSize(): Void
	{
		var safeWidth: Number = _originalCapWidth * 3; // Safe width is 3* size of cap
		var safeHeight: Number;

		if (__width < safeWidth)
			//3 times cap width is our minumum
			__width = safeWidth;

		// Safe height of meter is 80% of the max height
		safeHeight = ((_originalCapHeight/_originalCapWidth) * __width/2) * 0.80;

		if (__height > safeHeight)
			__height = safeHeight;

		background._width = __width;
		background._height = __height;

		// Calculate scaling percent of the meter based on heights
		var scalePercent: Number = __height/_originalHeight;

		// Scale the meterContent based on height so the caps AR is maintained
		meterContent._xscale = meterContent._yscale = scalePercent * 100;

		// Scale inner content
		// Scale meterFrameContent instead of meterFrameHolder due to scale9Grid
		_meterFrameContent._width = __width / scalePercent; // newWidth = oldWidth * newPercent/oldPercent /. newPercent -> 100
		_meterFillHolder._xscale = ((_meterFrameContent._width - 2*_originalCapWidth)/_originalMeterFillHolderWidth) * 100;
	}

	private function invalidateFillDirection(a_restorePercent: Boolean): Void
	{
		switch(_fillDirection) {
			case FILL_DIRECTION_LEFT:
			case FILL_DIRECTION_BOTH:
			case FILL_DIRECTION_RIGHT:
				break;
			default:
				_fillDirection = FILL_DIRECTION_LEFT;
		}

		_meterFillContent.gotoAndStop(_fillDirection);
		
		drawMeterGradients();
		
		_meterBarAnim.gotoAndStop("Full");
		_fullIdx = _meterBarAnim._currentframe;
		_meterBarAnim.gotoAndStop("Empty");
		_emptyIdx = _meterBarAnim._currentframe;
		
		if (a_restorePercent || !_initialized)
			setPercent(_currentPercent, true);
		else
			setPercent(0, true); // Reset to 0, assume that if fillDirection is changed, meter data provider changed
	}

	private function drawMeterGradients(): Void
	{
		// Draws the meter
		var w: Number = _meterBar._width;
		var h: Number = _meterBar._height;
		var meterBevel: MovieClip = _meterBar.meterBevel;
		var meterShine: MovieClip = _meterBar.meterShine;
		
		var colors: Array = [0xCCCCCC, 0xFFFFFF, 0x000000, 0x000000, 0x000000];
		var alphas: Array = [10,       60,       0,        10,       30];
		//var ratios: Array = [0,        25,       25,       140,      153,      153,      255];
		var ratios: Array = [0,       115,      128,      128,      255];
		var matrix: Matrix = new Matrix();
		
		if (meterShine != undefined)
			return;
			
		meterShine = _meterBar.createEmptyMovieClip("meterShine", 2);
		
		meterBevel.swapDepths(1);
		matrix.createGradientBox(w, h, Math.PI/2);
		meterShine.beginGradientFill("linear", colors, alphas, ratios, matrix);
		meterShine.moveTo(0,0);
		meterShine.lineTo(w, 0);
		meterShine.lineTo(w, h);
		meterShine.lineTo(0, h);
		meterShine.lineTo(0, 0);
		meterShine.endFill();
		
		invalidateColor();
	}

	private function invalidateColor(): Void
	{
		var colors: Array;
		var alphas: Array;
		var ratios: Array;
		var w: Number = _meterBar._width;
		var h: Number = _meterBar._height;
		var meterGradient: MovieClip = _meterBar.meterGradient;
		var matrix: Matrix = new Matrix();
		
		if (meterGradient != undefined)
			meterGradient.removeMovieClip();


			
		meterGradient = _meterBar.createEmptyMovieClip("meterGradient", 0);
		
		switch(_fillDirection) {
			case FILL_DIRECTION_LEFT:
				colors = [_secondaryColor, _primaryColor];
				alphas = [100, 100];
				ratios = [0, 255];
				break;
			case FILL_DIRECTION_BOTH:
				colors = [_secondaryColor, _primaryColor, _secondaryColor];
				alphas = [100, 100, 100];
				ratios = [0, 127, 255];
				break;
			case FILL_DIRECTION_RIGHT:
			default:
				colors = [_primaryColor, _secondaryColor];
				alphas = [100, 100];
				ratios = [0, 255];
		}
		
		matrix.createGradientBox(w, h);
		meterGradient.beginGradientFill("linear", colors, alphas, ratios, matrix);
		meterGradient.moveTo(0,0);
		meterGradient.lineTo(w, 0);
		meterGradient.lineTo(w, h);
		meterGradient.lineTo(0, h);
		meterGradient.lineTo(0, 0);
		meterGradient.endFill();

		if (_flashColorAuto || !_initialized) {
			if (_flashColorAuto)
				_flashColor = _primaryColor;
			invalidateFlashColor();
		}
	}

	private function invalidateFlashColor(): Void
	{
		var tf: Transform = new Transform(_meterFlashAnim);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _flashColor;
		tf.colorTransform = colorTf;
	}

	private function enterFrameHandler(): Void
	{
		/*if (!_initialized) {
			_currentPercent = _targetPercent;
		} else*/ if (_targetPercent == _currentPercent) {
			return;
		}
			
		if (_currentPercent < _targetPercent) {
			_currentPercent = _currentPercent + _fillDelta;
			if (_currentPercent > _targetPercent)
				_currentPercent = _targetPercent;
		} else {
			_currentPercent = _currentPercent - _emptyDelta;
			if (_currentPercent < _targetPercent)
				_currentPercent = _targetPercent;
		}
		
		_currentPercent = Math.min(1, Math.max(_currentPercent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_emptyIdx, _fullIdx, 0, 1, _currentPercent));
		_meterBarAnim.gotoAndStop(meterFrame);
	}
}