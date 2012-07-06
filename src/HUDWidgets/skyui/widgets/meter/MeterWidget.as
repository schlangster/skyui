import skyui.widgets.WidgetBase;
import flash.geom.*
import flash.filters.BevelFilter;

class skyui.widgets.meter.MeterWidget extends WidgetBase
{
	/* CONSTANTS */
	
	var METER_PAUSE_FRAME: Number = 40;
	
	var METER_ORIENTATION_CENTER: Number = 0;
	var METER_ORIENTATION_LEFT: Number = 1;
	var METER_ORIENTATION_RIGHT: Number = 2;
	
	var METER_FILL_HEALTH: Number = 0;
	var METER_FILL_MAGICKA: Number = 1;
	var METER_FILL_STAMINA: Number = 2;
	var METER_FILL_CUSTOM: Number = 3;
	
	/* PRIVATE VARIABLES */
	
	private var _percent: Number = 0;
	private var _forced: Number = 0;
	private var _alwaysVisible: Number = 0;
	private var _fillType: Number = 0;
	private var _fillBar: Number = 0;
	private var _fillStart: Number = 0x565618;
	private var _fillEnd: Number = 0xDFDF20;
	private var _fillBlink: Number = 0xDFDF20;
	private var _flipped: Boolean = false;
	
	private var _presets: Array;
	
	
	// Meter objects
	private var _meter: Components.BlinkOnDemandMeter;
	
	/* STAGE ELEMENTS */
  
	private var _modes: Array;
	
	private var MeterBase: MovieClip;
	private var MeterBaseAnim: MovieClip;
	
	private var MeterCenter: Components.BlinkOnDemandMeter;
	private var MeterLeft: Components.BlinkOnDemandMeter;
	
	function onEnterFrame(): Void
	{
		_meter.Update();
	}

	/* INITIALIZATION */
	
	public function MeterWidget()
	{
		super();
	}
	
	// @override WidgetBase
	function onLoad()
	{
		super.onLoad();
		
		MeterCenter = new Components.BlinkOnDemandMeter(MeterBase.MeterFader.OrientationCenter, MeterBase.CustomFlashInstance);
		MeterLeft = new Components.BlinkOnDemandMeter(MeterBase.MeterFader.OrientationLeft, MeterBase.CustomFlashInstance);
		MeterBaseAnim = MeterBase;
		MeterBaseAnim.gotoAndStop(1);
		MeterBase.CustomFlashInstance.gotoAndStop(1);
		
		_modes = [{fillMode: MeterBase.MeterFader.OrientationCenter, 
				   fillParent: MeterBase.MeterFader.OrientationCenter.CenterFill,
				   fillBar: null,
				   fillOverlay: null
				  },
				  {fillMode: MeterBase.MeterFader.OrientationLeft, 
				   fillParent: MeterBase.MeterFader.OrientationLeft.LeftFill,
				   fillBar: null,
				   fillOverlay: null
				  }];
		
		_presets = [{fillStart: 0x561818, fillEnd: 0xDF2020, fillBlink: 0xFF3232},
				   {fillStart: 0x0C016D, fillEnd: 0x284BD7, fillBlink: 0x3366FF},
				   {fillStart: 0x003300, fillEnd: 0x339966, fillBlink: 0x009900},
				   {fillStart: 0x565618, fillEnd: 0xDFDF20, fillBlink: 0xDFDF20}];
		
		_meter = MeterCenter;
		
		DrawGradient(METER_ORIENTATION_CENTER, _presets[_fillBar].fillStart, _presets[_fillBar].fillEnd);
		DrawGradient(METER_ORIENTATION_LEFT, _presets[_fillBar].fillStart, _presets[_fillBar].fillEnd);
		
		DrawOverlay(METER_ORIENTATION_CENTER);
		DrawOverlay(METER_ORIENTATION_LEFT);
		
		DrawBlink(_presets[_fillBar].fillEnd);
		
		UpdateMeter(METER_ORIENTATION_LEFT, false);
		UpdateMeter(METER_ORIENTATION_CENTER, true);
		
		
		// Test Code
		//setWidgetMeterPreset(METER_FILL_CUSTOM);
		//setWidgetMeterOrientation(METER_ORIENTATION_LEFT);
		setWidgetMeterAlwaysVisible(1.0);
		//setWidgetMeterForced(1.0);
		setWidgetMeterPercent(50.0);
		
		
		//setWidgetMeterBlinkColor(0xFF00FF);
		//startWidgetMeterBlinking();
	}
	
	function InitExtensions(): Void
	{
		MeterBaseAnim.Lock("B");
	}
	
	/* SET PROPERTIES */
	public function setWidgetMeterParams(n_type:Number, a_orient:Number, forced:Number, visibility:Number, percent:Number, fillStart:Number, fillEnd:Number, blinkColor: Number)
	{
		setWidgetMeterPreset(n_type);
		setWidgetMeterOrientation(a_orient);
		setWidgetMeterGradient(fillStart, fillEnd);
		setWidgetMeterBlinkColor(blinkColor);
		setWidgetMeterAlwaysVisible(visibility);
		setWidgetMeterForced(forced);
		setWidgetMeterPercent(percent);
	}
	
	public function setWidgetMeterPreset(newType: Number)
	{
		var fillStart, fillEnd, fillBlink;
		if(newType >= METER_FILL_HEALTH && newType <= METER_FILL_STAMINA) {			
			DrawGradient(METER_ORIENTATION_CENTER, _presets[newType].fillStart, _presets[newType].fillEnd);
			DrawGradient(METER_ORIENTATION_LEFT, _presets[newType].fillStart, _presets[newType].fillEnd);
			DrawBlink(_presets[newType].fillBlink);
			_fillBar = newType;
		} else if(newType == METER_FILL_CUSTOM){
			DrawGradient(METER_ORIENTATION_CENTER, _fillStart, _fillEnd);
			DrawGradient(METER_ORIENTATION_LEFT, _fillStart, _fillEnd);
			DrawBlink(_fillBlink);
			_fillBar = newType;
		}
				
		UpdateMeter(_fillType, true);
	}
	
	public function setWidgetMeterOrientation(newType: Number)
	{
		// Default to center
		if(newType < METER_ORIENTATION_CENTER || newType > METER_ORIENTATION_RIGHT) {
			newType = METER_ORIENTATION_CENTER;
		}
		
		// Determine meter script
		var oldType = _fillType;
		var oldMeter = _meter;
		if(newType == METER_ORIENTATION_CENTER) {
			_meter = MeterCenter;
		} else if(newType == METER_ORIENTATION_LEFT){
			_meter = MeterLeft;
		} else if(newType == METER_ORIENTATION_RIGHT) {
			_meter = MeterLeft;
		}
		
		// Changing orientation
		if(newType == METER_ORIENTATION_LEFT && _flipped) { // Flip back to Left
			_modes[1].fillMode._xscale *= -1;
			_flipped = !_flipped;
		} else if(newType == METER_ORIENTATION_RIGHT && !_flipped) { // Flip to right
			_modes[1].fillMode._xscale *= -1;
			_flipped = !_flipped;
		}
		if(newType == METER_ORIENTATION_RIGHT)
			newType = 1;
		
		_fillType = newType;
		if(oldType != newType) { // Type change, disable old meter
			UpdateMeter(oldType, false);
		}
		
		// Update new meter
		UpdateMeter(_fillType, true);
		
		// Transfer meter settings and clear old settings
		if(oldMeter != _meter) {
			_meter.CurrentPercent = oldMeter.CurrentPercent;
			_meter.TargetPercent = oldMeter.TargetPercent;
			oldMeter.CurrentPercent = 0;
			oldMeter.TargetPercent = 0;
		}
	}
	
	public function setWidgetMeterForced(a_forced: Number)
	{
		_forced = a_forced;
	}

	public function setWidgetMeterPercent(a_percent: Number)
	{
		_percent = a_percent;
		SetMeterPercent(_meter, a_percent, Boolean(_forced), Boolean(_alwaysVisible));
	}

	public function setWidgetMeterAlwaysVisible(a_shown: Number)
	{
		_alwaysVisible = a_shown;
		if(_alwaysVisible) {
			MeterBaseAnim.gotoAndStop("Pause");
		} else {
			RunMeterAnim(MeterBaseAnim);
		}
	}
	
	public function startWidgetMeterBlinking(): Void
	{
		if(_meter.BlinkMovieClip)
			_meter.StartBlinking();
	}
	
	public function setWidgetMeterGradient(fillStart: Number, fillFinish: Number)
	{
		_fillStart = fillStart;
		_fillEnd = fillFinish;
		
		// Only draw if our preset is custom
		if(_fillBar == 3) {
			DrawGradient(METER_ORIENTATION_CENTER, _fillStart, _fillEnd);
			DrawGradient(METER_ORIENTATION_LEFT, _fillStart, _fillEnd);
		}
	}
	
	public function setWidgetMeterBlinkColor(fillBlink: Number)
	{
		_fillBlink = fillBlink;
		
		// Only draw if our preset is custom
		if(_fillBar == 3) {
			DrawBlink(fillBlink);
		}
	}
	
	/* PUBLIC FUNCTIONS */
  	// None

	/* PRIVATE FUNCTIONS */
	private function DrawOverlay(index: Number)
	{
		//var depth = _modes[index].fillParent.getNextHighestDepth();
		if(_modes[index].fillOverlay) {
			//depth = _modes[index].fillOverlay.getDepth();
			_modes[index].fillOverlay.removeMovieClip();
		}
		
		_modes[index].fillOverlay = _modes[index].fillParent.createEmptyMovieClip("Overlay", 2);
		if(!_modes[index].fillOverlay) {
			skse.Log("Failed to create overlay");
			return;
		}

		var size_x;
		var size_y;
		if(index == METER_ORIENTATION_CENTER) {
			size_x = 364.7;
			size_y = 17;
		} else if(index == METER_ORIENTATION_LEFT) {
			size_x = 366.4;
			size_y = 17.3;
		}
		
		var matrix = new Matrix();
		matrix.createGradientBox(size_x, size_y, Math.PI/2, 0, 0);
		_modes[index].fillOverlay.beginGradientFill("linear", [0xCCCCCC, 0xCCCCCC, 0xCCCCCC, 0xFFFFFF, 0x000000, 0x000000, 0x000000], 
											[0,        0,        10,       50,       0,        10,       30], 
											[0,        25,       25,       140,      153,      153,      255], matrix);
		_modes[index].fillOverlay.moveTo(0, 0);
		_modes[index].fillOverlay.lineTo(size_x, 0);
		_modes[index].fillOverlay.lineTo(size_x, size_y);
		_modes[index].fillOverlay.lineTo(0, size_y);
		_modes[index].fillOverlay.lineTo(0, 0);
		_modes[index].fillOverlay.endFill();
	}

	private function DrawBlink(fillColor: Number)
	{
		if(MeterBase.CustomFlashInstance.transform) {
			delete MeterBase.CustomFlashInstance.transform;
			MeterBase.CustomFlashInstance.transform = null;
		}
		var colorTrans:ColorTransform = new ColorTransform();
		colorTrans.rgb = fillColor;
		var trans:Transform = new Transform(MeterBase.CustomFlashInstance);
		trans.colorTransform = colorTrans;
		MeterBase.CustomFlashInstance.transform = trans;
	}
	
	private function DrawGradient(index: Number, fillStart: Number, fillEnd: Number)
	{
		// Cleanup old gradient
		/*var depth = _modes[index].fillParent.getNextHighestDepth();
		if(_modes[index].fillBar) {
			depth = 0;
			_modes[index].fillBar.removeMovieClip();
		}*/
		_modes[index].fillBar = _modes[index].fillParent.createEmptyMovieClip("Custom", 0);
		if(!_modes[index].fillBar) {
			skse.Log("Failed to create gradient");
			return;
		}
		_modes[index].fillParent.Shadow.swapDepths(1);
		_modes[index].fillOverlay.swapDepths(2);
		
		//if(_modes[index].fillParent.Shadow.getDepth() < _modes[index].fillBar.getDepth())
			//_modes[index].fillParent.Shadow.swapDepths(_modes[index].fillBar.getDepth());
			
				
		var alphas;
		var colors;
		var ratios;
		var size_x;
		var size_y;
		
		if(index == METER_ORIENTATION_CENTER) {
			colors = [fillStart, fillEnd, fillStart];
			alphas = [100, 100, 100];
			ratios = [0, 127, 255];
			size_x = 364.7;
			size_y = 17;
		} else if(index == METER_ORIENTATION_LEFT) {
			colors = [fillStart, fillEnd];
			alphas = [100, 100];
			ratios = [0, 255];
			size_x = 366.4;
			size_y = 17.3;
		}
		
		var matrix = new Matrix();
		matrix.createGradientBox(size_x, size_y, 0, 0, 0);
		_modes[index].fillBar.beginGradientFill("linear", colors, alphas, ratios, matrix);
		_modes[index].fillBar.lineTo(size_x, 0);
		_modes[index].fillBar.lineTo(size_x, size_y);
		_modes[index].fillBar.lineTo(0, size_y);
		_modes[index].fillBar.lineTo(0, 0);
		_modes[index].fillBar.endFill();
		
		
		/*var overlay = _modes[index].fillBar;
		var shadowRadius = 3.5;
		// Upper trapezoid
		matrix = new Matrix();
		matrix.createGradientBox(size_x, shadowRadius, Math.PI/2, 0, 0);
		overlay.beginGradientFill("linear", [0x000000, 0x000000], [40, 0], [0, 255], matrix);
		overlay.moveTo(0, 0);
		overlay.lineTo(size_x, 0);
		overlay.lineTo(size_x - shadowRadius, shadowRadius);
		overlay.lineTo(shadowRadius, shadowRadius);
		overlay.lineTo(0, 0);
		overlay.endFill();
		
		// Left trapezoid
		matrix = new Matrix();
		matrix.createGradientBox(shadowRadius, size_y, Math.PI, 0, 0);
		overlay.beginGradientFill("linear", [0x000000, 0x000000], [0, 40], [0, 255], matrix);
		overlay.moveTo(0, 0);
		overlay.lineTo(shadowRadius, shadowRadius);
		overlay.lineTo(shadowRadius, size_y - shadowRadius);
		overlay.lineTo(0, size_y);
		overlay.lineTo(0, 0);
		overlay.endFill();
		
		// Right trapezoid
		matrix = new Matrix();
		matrix.createGradientBox(shadowRadius, size_y, 0, size_x - shadowRadius, 0);
		overlay.beginGradientFill("linear", [0x000000, 0x000000], [0, 40], [0, 255], matrix);
		overlay.moveTo(size_x, 0);
		overlay.lineTo(size_x - shadowRadius, shadowRadius);
		overlay.lineTo(size_x - shadowRadius, size_y - shadowRadius);
		overlay.lineTo(size_x, size_y);
		overlay.lineTo(size_x, 0);
		overlay.endFill();
		
		// Lower trapezoid
		matrix = new Matrix();
		matrix.createGradientBox(size_x, shadowRadius, Math.PI/2, 0, size_y - shadowRadius);
		overlay.beginGradientFill("linear", [0x000000, 0x000000], [0, 40], [0, 255], matrix);
		overlay.moveTo(shadowRadius, size_y - shadowRadius);
		overlay.lineTo(size_x - shadowRadius, size_y - shadowRadius);
		overlay.lineTo(size_x, size_y);
		overlay.lineTo(0, size_y);
		overlay.endFill();*/
		
		var filter:BevelFilter = new BevelFilter(1, 45, 0x000000, 1, 0x000000, 1, 6, 6, 1, 3, "inner", false);
		_modes[index].fillBar.filters = new Array(filter);
	}
	
	// Handle meter changes
	private function UpdateMeter(index: Number, abEnable: Boolean)
	{
		_modes[index].fillMode._visible = abEnable;
		_modes[index].fillMode.enabled = abEnable;
		
		_modes[index].fillParent._visible = abEnable;
		_modes[index].fillParent.enabled = abEnable;
	}
		
	private function SetMeterPercent(abMeter: Components.BlinkOnDemandMeter, aPercent: Number, abForce: Boolean, abAlwaysShown: Boolean): Void
	{
		if (abForce) {
			abMeter.SetPercent(aPercent);
			return;
		}
		if (!abAlwaysShown) { // Animate visibility
			RunMeterAnim(MeterBaseAnim);
		} 
		
		abMeter.SetTargetPercent(aPercent);
	}
	
	private function RunMeterAnim(aMeter: MovieClip): Void
	{
		aMeter.PlayForward(aMeter._currentframe);
	}
	
	private function FadeOutMeter(aMeter: MovieClip): Void
	{
		if (aMeter._currentframe > METER_PAUSE_FRAME)
			aMeter.gotoAndStop("Pause");
		aMeter.PlayReverse();
	}
}
