import skyui.widgets.WidgetBase;
import flash.geom.Matrix;
import flash.geom.Transform;
import flash.geom.ColorTransform;
import Shared.GlobalFunc;

class skyui.widgets.meter.MeterWidget extends WidgetBase
{
  /* Stage Elements */
	public var meterFader: MovieClip; // The fader
	
  /* _meterFlashAnim */
	private var _meterFlashAnim: MovieClip;
	private var _flashColor: Number;
	
  /* _meterFrameHolder */
	private var _meterFrameHolder: MovieClip;
	
  /* _meterFillHolder */
	private var _meterFillHolder: MovieClip; // The holder for the different animation types
	private var _meterFillMode: String;
	
  /* meterBarAnim */
	private var _meterBarAnim: MovieClip; // The animating meter
	private var _emptyIdx: Number;
	private var _fullIdx: Number;
	private var _currentPercent: Number;
	private var _targetPercent: Number;
	private var _fillSpeed: Number;
	private var _emptySpeed: Number;
	
  /* _meterBar */
	private var _meterBar: MovieClip;
	private var _colorA: Number;
	private var _colorB: Number;
	
	public function MeterWidget()
	{
		super();
		GlobalFunc.AddReverseFunctions();
		_meterFrameHolder = meterFader.meterFrameHolder.meterFrameContent;
		
		_meterFlashAnim = _meterFrameHolder.meterFlashAnim;
		
		_meterFillHolder = meterFader.meterFillHolder.meterFillContent;
		_meterBarAnim = _meterFillHolder.meterBarAnim;
		_meterBar = _meterBarAnim.meterBar;
	}
	
	private function onLoad()
	{
		super.onLoad();
		_global.setTimeout(this, "testFunction", 1);
	}
	
	private function doSetMeterMode(a_meterFillMode: String): Void
	{
		_meterFillMode = a_meterFillMode;
		
		switch(_meterFillMode) {
			case "left":
			case "center":
			case "right":
				_meterFillHolder.gotoAndStop(_meterFillMode);
				break;
			default:
				_meterFillHolder.gotoAndStop("right");
		}
		initMeter();
		
		_currentPercent = 100;
		_targetPercent = 100;
		_meterBarAnim.gotoAndStop("Empty");
		_emptyIdx = _meterBarAnim._currentframe;
		_meterBarAnim.gotoAndStop("Full");
		_fullIdx = _meterBarAnim._currentframe;
		_fillSpeed = 2;
		_emptySpeed = 3;
		
		drawMeterGradient();
	}
	
	private function initMeter()
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
	}
	
	private function drawMeterGradient(): Void
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
		
		switch(_meterFillMode) {
			case "left":
				colors = [_colorB, _colorA];
				alphas = [100, 100];
				ratios = [0, 255];
				break;
			case "center":
				colors = [_colorA, _colorB, _colorA];
				alphas = [100, 100, 100];
				ratios = [0, 127, 255];
				break;
			case "right":
			default:
				colors = [_colorA, _colorB];
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
	}
	
	private function setCurrentPercent(a_percent: Number): Void
	{
		_currentPercent = Math.min(100, Math.max(a_percent, 0));
		var meterFrame: Number = Math.floor(GlobalFunc.Lerp(_emptyIdx, _fullIdx, 0, 100, _currentPercent));
		_meterBarAnim.gotoAndStop(meterFrame);
	}
	
	private function setTargetPercent(a_targetPercent: Number): Void
	{
		_targetPercent = Math.min(100, Math.max(a_targetPercent, 0));
	}
	
	private function update(): Void
	{
		if (_targetPercent == _currentPercent)
			return;
			
		if (_currentPercent < _targetPercent) {
			_currentPercent += _fillSpeed;
			if (_currentPercent > _targetPercent)
				_currentPercent = _targetPercent;
		} else {
			_currentPercent -= _emptySpeed;
			if (_currentPercent < _targetPercent)
				_currentPercent = _targetPercent;
		}
		
		setCurrentPercent(_currentPercent);
	}
	
	private function startMeterFlash()
	{
		if (_meterFlashAnim.meterFlashing) // Set on the timeline
			return;
		meterFader.PlayForward(meterFader._currentframe);
		_meterFlashAnim.gotoAndPlay("StartFlash");
	}
	
  /* Public Functions */
	public function setMeterPercent(a_percent: Number, a_force: Boolean): Void
	{
		if (a_force) {
			setTargetPercent(a_percent);
			_currentPercent = _targetPercent;
			setCurrentPercent(_currentPercent);
			return;
		}
		meterFader.PlayForward(meterFader._currentframe);
		setTargetPercent(a_percent);
	}
	
	public function setMeterColors(a_colorA: Number, a_colorB: Number)
	{
		_colorA = a_colorA;
		_colorB = a_colorB;
		drawMeterGradient();
	}
	
	public function setMeterFillMode(a_fillMode: String)
	{
		if(_meterFillMode == a_fillMode)
			return;
			
	}
	
	public function setMeterFlashColor(a_flashColor: Number)
	{
		if(_flashColor == a_flashColor)
			return;
			
		_flashColor = a_flashColor;
		var tf: Transform = new Transform(_meterFlashAnim);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = _flashColor;
		tf.colorTransform = colorTf;
	}
	
	public function initWidgetNumbers(a_colorA: Number, a_colorB: Number, a_flashColor: Number)
	{
		_colorA = a_colorA;
		_colorB = a_colorB;
		setMeterFlashColor(a_flashColor);
	}
	
	public function initWidgetStrings(a_meterFillMode: String)
	{
		_meterFillMode = a_meterFillMode;
	}
	
	
	public function initWidgetCommit()
	{
		doSetMeterMode(_meterFillMode);
		
		onEnterFrame = function()
		{
			update();
		};
	}
	
	public function set width(a_width: Number)
	{
		var newWidth: Number = a_width * 100/_xscale;
		_meterFrameHolder._width = newWidth;
		_meterFillHolder._xscale = (newWidth - (33.25 + 33.25)) /  366.4 * 100;
	}
	public function get width(): Number
	{
		return _meterFrameHolder._width;
	}
	
	public function set scale(a_scale: Number)
	{
		var tmpWidth: Number = _meterFrameHolder._width;
		// _xscale = _yscale *= a_height/_meterFrameHolder._height;
		_xscale = _yscale = a_scale;
		//Restore Width
		width = tmpWidth;
	}
	public function get scale(): Number
	{
		//return _meterFrameHolder._height;
		return _yscale;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/* for Testing */
	private function testFunction()
	{
		initWidgetNumbers(0x003300, 0x339966, 0x846878);
		initWidgetStrings("right");
		initWidgetCommit();
		setMeterPercent(0);
		_global.setInterval(this, "incFunc", 1000);
	}
	
	private var c: Number = 0;
	private function incFunc()
	{
		trace(c);
		
		switch (c) {
			case 0:
				setMeterPercent(0);
				startMeterFlash();
				width = 500;
				break;
			case 2:
				setMeterPercent(50);
				scale = 200;
				break;
			case 3:
				//width = 200;
				doSetMeterMode("center");
				break;
			case 6:
				//width = 700;
				break;
			case 8:
				setMeterPercent(100);
				//width = 500;
				//c = 0;
				break;
		}
		c++;
	}
	/* --------------------- */

}