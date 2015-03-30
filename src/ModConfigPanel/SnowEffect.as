import mx.utils.Delegate;
import skyui.util.Tween;

class SnowEffect extends ParticleEmitter
{
	/* Public Variables */
	public var minWindSpeed: Number = 0;
	public var maxWindSpeed: Number = 400;
	public var initialWindSpeed: Number = 0;
	public var particleRotationFactor:Number = 1;
	
	/* Private Variables */
	private var _framesPerSpawn: Number = 5;
	
	private var _windSpeed: Number;
	
	private var __currentFrame: Number = 0;
	private var _nextSpawn: Number = __currentFrame + _framesPerSpawn;

	private var _windInterval: Number;
	
	public function SnowEffect()
	{
		super();
		
		_windSpeed = initialWindSpeed;
		windLoop();
		
		onEnterFrame = emitter;
	}
	
	// @Override ParticleEmitter
	private function initParticle(a_particle: MovieClip): MovieClip
	{
		var particle: MovieClip = a_particle;
		particle._alpha = 100; //todo
		particle._x = Math.random()*(_effectWidth + 2*effectBuffer) - effectBuffer;
		particle._y = Math.random()*(_effectHeight - effectBuffer) - _effectHeight;
		particle._xscale = particle._yscale = (Math.max(0.5, Math.random())*particleScaleFactor)*100;
		xLoop(particle);
		yLoop(particle);
		return particle;
	}
	
	private function emitter(): Void
	{
		if (__currentFrame >= _nextSpawn) { // set to >= to support for non integer _framePerSpawn ?
			if (addParticle() == undefined) {
				delete onEnterFrame;
				return;
			}
			if (_particles.length % 100 == 0 && _particles.length < maxParticles)
				particleScaleFactor += 0.15; // Increase size
			if (_particles.length % 20 == 0 && _framesPerSpawn > 1)
				_framesPerSpawn--; // Speed up
			_nextSpawn += _framesPerSpawn;
		}
		__currentFrame++;
	}
	
	private function windLoop(): Void
	{
		var time: Number = Math.random()*3+1;
		var nextSpeed: Number = Math.random()*(2*maxWindSpeed-minWindSpeed)-(minWindSpeed+maxWindSpeed);
		var nextWind: Number = Math.random()*(2)+1;

		Tween.LinearTween(this, "_windSpeed", this._windSpeed, nextSpeed, time, null);

		if (_windInterval != undefined) {
			clearInterval(_windInterval);
			delete(_windInterval);
		}

		_windInterval = setInterval(this, "windLoop", nextWind);
	}
	
	private function xLoop(a_particle: MovieClip): Void {
		if (a_particle._x > _effectWidth + effectBuffer)
			a_particle._x = Math.random() * -effectBuffer;
		else if (a_particle._x < -effectBuffer)
			a_particle._x = _effectWidth + Math.random() * effectBuffer;

		var onCompleteFn: Function = Delegate.create(this, function() {xLoop(a_particle)});
		var duration: Number = Math.random()*2+1;

		// Quad.easeInOut
		Tween.LinearTween(a_particle, "_x", a_particle._x, a_particle._x+(Math.random()*80-40+_windSpeed)*(a_particle._xscale/100), duration, onCompleteFn);
		Tween.LinearTween(a_particle, "_rotation", a_particle._rotation, Math.random()*particleRotationFactor*600, duration, null);
	}

	private function yLoop(a_particle: MovieClip): Void {
		if (a_particle._y > _effectHeight + effectBuffer) {
			a_particle._y = Math.random() * -effectBuffer;
			if (Math.floor(4096*Math.random()) == 0 && _particles.length > 375)
				a_particle.gotoAndStop("snow2");
			else if (a_particle.frameLabel != particleFrameLabel)
				a_particle.gotoAndStop(particleFrameLabel);
		} else if (a_particle._y < -effectBuffer) {
			a_particle._y = _effectHeight + Math.random() * effectBuffer;
		}

		var onCompleteFn: Function = Delegate.create(this, function() {yLoop(a_particle)});
		var duration: Number = Math.random()*2+1;

		// Linear.easeInOut
		Tween.LinearTween(a_particle, "_y", a_particle._y, a_particle._y+(Math.random()*7+30)*(a_particle._xscale/100)*3, duration, onCompleteFn);
	}
}