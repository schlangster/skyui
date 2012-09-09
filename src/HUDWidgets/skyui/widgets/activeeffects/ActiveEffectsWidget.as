import skyui.widgets.WidgetBase;
import skyui.util.Defines;
import com.greensock.TweenLite;
import com.greensock.easing.Linear;

class skyui.widgets.activeeffects.ActiveEffectsWidget extends WidgetBase
{
	private var marker: Number = 1;
	private var _clipContainer: MovieClip;
	private var _clipArray: Array;
	private var _sortFlag: Boolean = true;
		
	private var _fadeInDuration: Number = 0.50;
	private var _fadeOutDuration: Number = 0.75;
	private var _effectGap: Number = 20; // pixels at 100% scale between active effects
	private var _safeWidth: Number;
	private var _safeHeight: Number;
	
	private var _yOffset: Number;
	
	//@ Config?
	public var updateInterval: Number = 150;
	public var effectScale: Number = 50;
	public var iconLocation: String = "./skyui/skyui_icons_psychosteve.swf";
	
	//@ SKSE
	public var effectList: Array;
	
	public function ActiveEffectsWidget()
	{
		super();
		
		effectList = new Array();
		_clipArray = new Array();
		
		_safeWidth = Stage.visibleRect.width - 2 * Stage.safeRect.x;
		_safeHeight = Stage.visibleRect.height - 2 * Stage.safeRect.y
		_yOffset = _root.HUDMovieBaseInstance.LocationLockBase._height;
		
		_clipContainer = createEmptyMovieClip("clipContainer", getNextHighestDepth());
		
		// DEBUG: Keep if testing
		/*effectList = [{elapsed: 5, magicType: 4294967295, duration: 7, subType: 22, id: 567786304, actorValue: 107, effectFlags: 2099458, archetype: 34},
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 60, subType: 4294967295, id: 596614304, actorValue: 135, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration:50, subType: 4294967295, id: 596613744, actorValue: 17, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 9, subType: 4294967295, id: 596613856, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3.1780076026917, magicType: 4294967295, duration: 40, subType: 4294967295, id: 596613632, actorValue: 142, effectFlags: 2099202, archetype: 34}, 
							{elapsed: 3000, magicType: 4294967295, duration: 3001, subType: 4294967295, id: 596613296, actorValue: 54, effectFlags: 4201474, archetype: 11}];
		iconLocation = "." + iconLocation;
		_safeWidth = Stage.width;
		_safeHeight = Stage.height//*/
		
		/*GameDelegate.removeCallBack("SetMagickaMeterPercent");
		GameDelegate.addCallBack("SetMagickaMeterPercent", this, "SetMagickaMeterPercent");
		
		_root.HUDMovieBaseInstance.SetMagickaMeterPercent = function (aPercent: Number, abForce: Boolean): Void
		{
			skse.Log("asdsadsadsd");
		}*/
		
		setInterval(this, "onIntervalUpdate", updateInterval);
		
	}
	
	private function onIntervalUpdate()
	{
		//wipe array
		// DEBUG: Remove if testing
		effectList.splice(0);
		skse.RequestActivePlayerEffects(effectList);//*/
		
		if (_sortFlag) {
			effectList.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			_sortFlag = false;
		}
		
		/*for (var i: Number = 0; i < effectList.length; i++) {
			skse.Log("----")
			skse.Log(""+i);
			for (var s: String in effectList[i]) {
				skse.Log(s + ": " + effectList[i][s]);
			}
			skse.Log("----")
		}*/
		
		var clip: MovieClip;
		var effect: Object;
		var iconLabel: String;
		
		for (var i: Number = 0; i < effectList.length; i++) {
			effect = effectList[i];
			clip = _clipContainer[effect.id];
			
			if(effect.effectFlags & Defines.FLAG_EFFECTTYPE_HIDEINUI) {
				// Mark for deletion (flip marker) if clip exists and pass
				if (clip != undefined)
					clip.marker = 1 - marker;
				continue;
			}
			
			// DEBUG: Keep if testing
			//effectList[i].elapsed += updateInterval/1000;
			
			if (clip == undefined) {
				// New effect
				
				var clipInfo: Object = {marker: marker,
										index: _clipArray.length,
										iconLocation: iconLocation,
										finished: false,
										effect: effect,
										_alpha: 0,
										_xscale: effectScale,
										_yscale: effectScale};
				
				clip = _clipContainer.attachMovie("activeEffect", String(effect.id), _clipContainer.getNextHighestDepth(), clipInfo);
				
				clip._x = _safeWidth - ((clip.background._width) * effectScale/100);
				clip._y = _clipArray.length * ((clip.background._height + _effectGap) * effectScale/100) + _yOffset;
				
				// Perform entry animation here
				TweenLite.to(clip, _fadeInDuration, {_alpha: 100, overwrite: "AUTO", easing: Linear.easeNone});
				
				_clipArray.push(clip);
			} else {
				// Effect exists, update its maker
				clip.marker = marker;
			}
			
			// Always update active effect
			clip.updateActiveEffect(effect);
		}
		
		for (var i: Number = 0; i < _clipArray.length; i++) {
			clip = _clipArray[i];
			
			clip.index = i;
			if (clip.marker != marker && !clip.finished) {
				clip.finished = true;
				TweenLite.to(clip, _fadeOutDuration, {_alpha: 0, onCompleteScope: this, onComplete: effectFinished, onCompleteParams: [clip], overwrite: "AUTO", easing: Linear.easeNone});
			}
		}
		
		marker = 1 - marker;
	}
	
	public function effectFinished(a_effectClip: MovieClip)
	{
		var finishedClip: MovieClip = a_effectClip;
		var finishedClipIndex: Number = finishedClip.index;
		_clipArray.splice(finishedClipIndex, 1); // Removes old clip, first clip that needs to be updated will be at clipIndex
		
		// Reset clip positions
		// Only tweens those that need to be tweened.
		var clip: MovieClip;
		var newy: Number;
		for (var i: Number = finishedClipIndex; i < _clipArray.length; i++) {
			clip = _clipArray[i];
			clip.index = i;
			newy = i * ((clip.background._height + _effectGap) * effectScale/100) + _yOffset;
			TweenLite.to(clip, 1, {_y: newy, overwrite: "AUTO", easing: Linear.easeNone});
		}
		
		 //alpha is at 0 so can remove the clip at any time
		 finishedClip.removeMovieClip();
	}
}