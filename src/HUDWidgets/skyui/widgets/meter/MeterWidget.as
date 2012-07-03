import skyui.widgets.WidgetBase;
import flash.geom.*

class skyui.widgets.meter.MeterWidget extends WidgetBase
{
  /* CONSTANTS */
	
	var METER_PAUSE_FRAME: Number = 40;
	
	
  /* PRIVATE VARIABLES */
	
	private var _percent: Number = 0;
	private var _forced: Number = 0;
	private var _alwaysVisible: Number = 0;
	private var _fillType: Number = 0;
	private var _fillBar: Number = 0;
	private var _fillStart: Number = 0x565618;
	private var _fillEnd: Number = 0xDFDF20;
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
									   {bar: null, blink: null}],
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
									 {bar: null, blink: null}]
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
		
		// Create the gradients so their visibility can be toggled properly
		CreateCustomGradient(0, _fillStart, _fillEnd);
		CreateCustomGradient(1, _fillStart, _fillEnd);
		
		// Disable both modes until a mode is set
		ChangeMeterType(0, -1, false);
		ChangeMeterType(1, -1, false);
		
		// Enable Center Health
		ChangeMeterType(_fillType, _fillBar, true);
		
		// TestCode
		/*setWidgetMeterGradient([0xFF00FF, 0x00FF00]);
		setWidgetMeterOrientation("Left");
		setWidgetMeterType("Magicka");
		setWidgetAlwaysVisible(1.0);
		setWidgetPercent(50.0);
		startWidgetMeterBlinking();
		setWidgetMeterOrientation("Center");
		setWidgetMeterType("Stamina");*/
		
		/*setWidgetMeterType("Magicka");
		setWidgetMeterOrientation("Left");
		setWidgetAlwaysVisible(1.0);
		//setWidgetMeterGradient(0xFF00FF, 0x00FFFF);
		setWidgetPercent(50.0);*/
		//startWidgetMeterBlinking();
		
	}
	
	function InitExtensions(): Void
	{
		MeterBaseAnim.Lock("B");
	}
	
	/* SET PROPERTIES */
	public function setWidgetParams(n_type:Number, a_orient:Number, forced:Number, visibility:Number, percent:Number, fillStart:Number, fillEnd:Number)
	{
		setWidgetMeterType(n_type);
		setWidgetMeterOrientation(a_orient);
		setWidgetMeterGradient(fillStart, fillEnd);
		setWidgetAlwaysVisible(visibility);
		setWidgetForced(forced);
		setWidgetPercent(percent);
	}
	
	public function setWidgetMeterType(newType: Number)
	{
		if(newType >= 0 && newType <= 3) {
			_fillBar = newType;
		} else {
			_fillBar = 0;
		}
		
		if(newType == 3) {
			_fillBar = 3;
			CreateCustomGradient(_fillType, _fillStart, _fillEnd);
		} 
		
		skse.Log("Setting meter param: " + newType + " type:" + _fillType + " fill:" + _fillBar);
		ChangeMeterType(_fillType, _fillBar, true);
	}
	
	public function setWidgetMeterOrientation(newType: Number)
	{
		if(newType < 0 || newType > 2) {
			newType = 0;
		}

		// Changing type
		if(newType == 1 && _flipped) { // Flip to RS
			_modes[1].fillMode._xscale *= -1;
			_flipped = false;
		} else if(newType == 2 && !_flipped) { // Flip to LS
			_modes[1].fillMode._xscale *= -1;
			_flipped = true;
			newType = 1;
		}
		if(_fillType != newType) { // Changing to regular type
			ChangeMeterType(_fillType, -1, false);
			_fillType = newType;
			CreateCustomGradient(_fillType, _fillStart, _fillEnd); // filltype changed, transfer custom type
		}
		
		// Enable new meter
		skse.Log("Setting orientation: " + newType + " type:" + _fillType + " fill:" + _fillBar);
		ChangeMeterType(_fillType, _fillBar, true);
		// Changing these via SetPercent cause problems, Update should handle it anyhow
		_meter.CurrentPercent = _percent;
		_meter.TargetPercent = _percent;
	}
	
	public function setWidgetForced(a_forced: Number)
	{
		_forced = a_forced;
	}

	public function setWidgetPercent(a_percent: Number)
	{
		_percent = a_percent;
		SetMeterPercent(_meter, a_percent, Boolean(_forced), Boolean(_alwaysVisible));
	}

	public function setWidgetAlwaysVisible(a_shown: Number)
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
		CreateCustomGradient(_fillType, _fillStart, _fillEnd);
	}
	
	/* PUBLIC FUNCTIONS */
  	// None

	/* PRIVATE FUNCTIONS */
	private function CreateCustomGradient(index: Number, fillStart: Number, fillEnd: Number)
	{
		// Cleanup old gradient
		if(_modes[index].fillType[3].bar) {
			_modes[index].fillType[3].bar.removeMovieClip();
		}
		
		var customFill: MovieClip = _modes[index].fillParent.createEmptyMovieClip("Custom", _modes[index].fillParent.getNextHighestDepth());
		if(index == 0) {
			with (customFill) 
			{
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
		} else if(index == 1) {
			with (customFill) 
			{
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
		
		_modes[index].fillType[3].bar = customFill;
		_modes[index].fillType[3].blink = null;
		
		if(_fillBar != 3) {
			_modes[index].fillType[3].bar.enabled = false;
			_modes[index].fillType[3].bar._visible = false;
		}
	}
	
	// Handle meter changes
	private function ChangeMeterType(index: Number, fillIndex: Number, abEnable: Boolean)
	{
		if(abEnable) {
			if(index == 0) {
				_meter = MeterCenter;
			} else if(index == 1){
				_meter = MeterLeft;
			} else if(index == 2) {
				_meter = MeterLeft;
			}
		}
		
		_modes[index].fillMode._visible = abEnable;
		_modes[index].fillMode.enabled = abEnable;
		
		_modes[index].fillParent._visible = abEnable;
		_modes[index].fillParent.enabled = abEnable;
				
		for(var n = 0; n < _modes[index].fillType.length; n++)
		{
			if(n == fillIndex) {
				_modes[index].fillType[n].bar._visible = true;
				_modes[index].fillType[n].bar.enabled = true;
				
				if(_modes[index].fillType[n].blink) {
					// Change Blink type
					if(_meter.BlinkMovieClip != _modes[index].fillType[n].blink) {
						//var lastBlink = _meter.BlinkMovieClip;
						_meter.BlinkMovieClip = _modes[index].fillType[n].blink;
						// Hotswap blink, just in case?
						/*if(lastBlink._previousframe != lastBlink._currentframe) {
							_meter.BlinkMovieClip.gotoAndPlay(lastBlink._currentframe);
							lastBlink.gotoAndStop(1);
						}*/
					}
				} else { // This may be intended?
					// Stop the old blink
					if(_meter.BlinkMovieClip) {
						_meter.BlinkMovieClip.gotoAndStop(1);
					}
					_meter.BlinkMovieClip = null;
				}
			} else {
				_modes[index].fillType[n].bar._visible = false;
				_modes[index].fillType[n].bar.enabled = false;
			}
		}
		
		if(_modes[index].baseParent) {
			_modes[index].baseParent._visible = abEnable;
			_modes[index].baseParent.enabled = abEnable;
			
			for(var b = 0; b < _modes[index].baseType.length; b++)
			{
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
