import skyui.widgets.WidgetBase;
import flash.geom.*

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
		
		_modes = new Array();
				
		var center:Object = {fillMode: MeterBase.MeterFader.OrientationCenter, 
							fillParent: MeterBase.MeterFader.OrientationCenter.CenterFill, 
							fillType: [{bar: MeterBase.MeterFader.OrientationCenter.CenterFill.Health, blink: MeterBase.HealthFlashInstance},
						  			   {bar: MeterBase.MeterFader.OrientationCenter.CenterFill.Magicka, blink: MeterBase.MagickaFlashInstance},
									   {bar: MeterBase.MeterFader.OrientationCenter.CenterFill.Stamina, blink: MeterBase.StaminaFlashInstance},
									   {bar: null, blink: MeterBase.CustomFlashInstance}],
							baseParent: MeterBase.MeterFader.OrientationCenter.CenterFillBase,
							baseType: [MeterBase.MeterFader.OrientationCenter.CenterFillBase.Health,
						  			   MeterBase.MeterFader.OrientationCenter.CenterFillBase.Magicka,
									   MeterBase.MeterFader.OrientationCenter.CenterFillBase.Stamina,
									   null]
							};
		var left:Object = {fillMode: MeterBase.MeterFader.OrientationLeft, 
						  fillParent: MeterBase.MeterFader.OrientationLeft.LeftFill,
						  fillType: [{bar: MeterBase.MeterFader.OrientationLeft.LeftFill.Health, blink: MeterBase.HealthFlashInstance},
						  			 {bar: MeterBase.MeterFader.OrientationLeft.LeftFill.Magicka, blink: MeterBase.MagickaFlashInstance},
									 {bar: MeterBase.MeterFader.OrientationLeft.LeftFill.Stamina, blink: MeterBase.StaminaFlashInstance},
									 {bar: null, blink: MeterBase.CustomFlashInstance}]
						  };
		
		_modes.push(center);
		_modes.push(left);
		
		MeterCenter = new Components.BlinkOnDemandMeter(MeterBase.MeterFader.OrientationCenter, MeterBase.HealthFlashInstance);
		MeterLeft = new Components.BlinkOnDemandMeter(MeterBase.MeterFader.OrientationLeft, MeterBase.HealthFlashInstance);
		MeterBaseAnim = MeterBase;
		MeterBaseAnim.gotoAndStop(1);
		MeterBase.HealthFlashInstance.gotoAndStop(1);
		MeterBase.MagickaFlashInstance.gotoAndStop(1);
		MeterBase.StaminaFlashInstance.gotoAndStop(1);
		MeterBase.CustomFlashInstance.gotoAndStop(1);
		
		// Create the gradients so their visibility can be toggled properly
		DrawGradient(METER_ORIENTATION_CENTER, _fillStart, _fillEnd);
		DrawGradient(METER_ORIENTATION_LEFT, _fillStart, _fillEnd);
		
		// Disable both modes until a mode is set
		UpdateMeter(METER_ORIENTATION_CENTER, -1, false);
		UpdateMeter(METER_ORIENTATION_LEFT, -1, false);
		
		_meter = MeterCenter;
		
		// Enable Center Health
		UpdateMeter(_fillType, _fillBar, true);	
		
		// Test Code
		/*setWidgetMeterType(METER_FILL_CUSTOM);
		setWidgetMeterOrientation(METER_ORIENTATION_CENTER);
		setWidgetAlwaysVisible(1.0);
		setWidgetForced(1.0);
		setWidgetPercent(50.0);
		setWidgetMeterBlink(0xFF00FF);
		startWidgetMeterBlinking();*/
	}
	
	function InitExtensions(): Void
	{
		MeterBaseAnim.Lock("B");
	}
	
	/* SET PROPERTIES */
	public function setWidgetMeterParams(n_type:Number, a_orient:Number, forced:Number, visibility:Number, percent:Number, fillStart:Number, fillEnd:Number, blinkColor: Number)
	{
		setWidgetMeterType(n_type);
		setWidgetMeterOrientation(a_orient);
		setWidgetMeterGradient(fillStart, fillEnd);
		setWidgetMeterBlinkColor(blinkColor);
		setWidgetMeterAlwaysVisible(visibility);
		setWidgetMeterForced(forced);
		setWidgetMeterPercent(percent);
	}
	
	public function setWidgetMeterType(newType: Number)
	{
		if(newType >= METER_FILL_HEALTH && newType <= METER_FILL_CUSTOM) {
			_fillBar = newType;
		} else { // Default to Health
			_fillBar = 0;
		}
		
		UpdateMeter(_fillType, _fillBar, true);
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
			UpdateMeter(oldType, -1, false);
		}
		
		// Update new meter
		UpdateMeter(_fillType, _fillBar, true);
		
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
		
		DrawGradient(METER_ORIENTATION_CENTER, _fillStart, _fillEnd);
		DrawGradient(METER_ORIENTATION_LEFT, _fillStart, _fillEnd);
	}
	
	public function setWidgetMeterBlinkColor(fillBlink: Number)
	{
		_fillBlink = fillBlink;
		DrawBlink(fillBlink);
	}
	
	/* PUBLIC FUNCTIONS */
  	// None

	/* PRIVATE FUNCTIONS */
	private function DrawBlink(fillColor: Number)
	{
		if(MeterBase.CustomFlashInstance.transform) {
			delete MeterBase.CustomFlashInstance.transform;
			MeterBase.CustomFlashInstance.transform = null;
		}
		var colorTrans:ColorTransform = new ColorTransform();
		colorTrans.redOffset = ( ( fillColor & 0x00FF0000 ) >>> 16);
		colorTrans.greenOffset = ( ( fillColor & 0x0000FF00 ) >>> 8);
		colorTrans.blueOffset = ( ( fillColor & 0x000000FF ));
		var trans:Transform = new Transform(MeterBase.CustomFlashInstance);
		trans.colorTransform = colorTrans;
		MeterBase.CustomFlashInstance.transform = trans;
	}
	
	private function DrawGradient(index: Number, fillStart: Number, fillEnd: Number)
	{		
		var customFill: MovieClip = _modes[index].fillParent.createEmptyMovieClip("Custom", _modes[index].fillParent.getNextHighestDepth());
		if(_fillBar != METER_FILL_CUSTOM) {
			customFill.enabled = false;
			customFill._visible = false;
		}
		
		if(index == METER_ORIENTATION_CENTER) {
			with (customFill) {
				colors = [fillStart, fillEnd, fillStart];
				fillType = "linear"
				alphas = [100, 100, 100];
				ratios = [0, 127, 255];
				matrix = new Matrix();
				matrix.createGradientBox(364.7, 17, 0, 0, 0);
				beginGradientFill(fillType, colors, alphas, ratios, matrix);
				lineTo(364.7, 0);
				lineTo(364.7, 17);
				lineTo(0, 17);
				lineTo(0, 0);
				endFill();
			}
		} else if(index == METER_ORIENTATION_LEFT) {
			with (customFill) {
				colors = [fillStart, fillEnd];
				fillType = "linear"
				alphas = [100, 100];
				ratios = [0, 255];
				matrix = new Matrix();
				matrix.createGradientBox(366.4, 17, 0, 0, 0);
				beginGradientFill(fillType, colors, alphas, ratios, matrix);
				lineTo(366.4, 0);
				lineTo(366.4, 17.3);
				lineTo(0, 17);
				lineTo(0, 0);
				endFill();
			}
		}
		
		// Cleanup old gradient
		if(_modes[index].fillType[3].bar) {
			_modes[index].fillType[3].bar.removeMovieClip();
		}
		_modes[index].fillType[3].bar = customFill;
	}
	
	// Handle meter changes
	private function UpdateMeter(index: Number, fillIndex: Number, abEnable: Boolean)
	{
		_modes[index].fillMode._visible = abEnable;
		_modes[index].fillMode.enabled = abEnable;
		
		_modes[index].fillParent._visible = abEnable;
		_modes[index].fillParent.enabled = abEnable;
			
		for(var n = 0; n < _modes[index].fillType.length; n++) {
			if(n == fillIndex) {
				_modes[index].fillType[n].bar._visible = true;
				_modes[index].fillType[n].bar.enabled = true;
				
				if(_modes[index].fillType[n].blink) { // New blink, swap it
					if(_meter.BlinkMovieClip != _modes[index].fillType[n].blink)
						_meter.BlinkMovieClip = _modes[index].fillType[n].blink;
				} else {
					if(_meter.BlinkMovieClip) // Stop the old blink if there was one
						_meter.BlinkMovieClip.gotoAndStop(1);
					_meter.BlinkMovieClip = null; // Clear blink
				}
			} else {
				_modes[index].fillType[n].bar._visible = false;
				_modes[index].fillType[n].bar.enabled = false;
			}
		}
		
		if(_modes[index].baseParent) {
			_modes[index].baseParent._visible = abEnable;
			_modes[index].baseParent.enabled = abEnable;
			
			for(var b = 0; b < _modes[index].baseType.length; b++) {
				if(b == fillIndex) {
					_modes[index].baseType[b]._visible = true;
					_modes[index].baseType[b].enabled = true;
				} else {
					_modes[index].baseType[b]._visible = false;
					_modes[index].baseType[b].enabled = false;
				}
			}
		}

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
