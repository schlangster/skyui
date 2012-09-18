class ParticleEmitter extends MovieClip
{
	
	/* Stage Elements */
	private var _particleHolder: MovieClip;
	
	/* Component Definitions */
	public var particleLinkageName: String;
	public var particleFrameLabel: String;
	public var particleScaleFactor: Number;
	
	public var maxParticles: Number;
	
	public var effectBuffer: Number;
	
	/* Private Variables */
	private var _effectWidth: Number;
	private var _effectHeight: Number;
	
	private var _particles: Array;
	
	/* Interface */
	public function set width(a_val: Number): Void
	{
		_width = a_val;
		_effectWidth = a_val * 100/_particleHolder._xscale;
	}
	public function get width(): Number { return _width; }
	
	public function set height(a_val: Number): Void
	{
		_height = a_val;
		_effectHeight = a_val * 100/_particleHolder._yscale;
	}
	public function get height(): Number { return _height; }
	
	public function set visible(a_val: Boolean): Void { _particleHolder._visible = a_val; }
	public function get visible(): Boolean { return _particleHolder._visible; }
	
	public function set alpha(a_val: Number): Void { _particleHolder._alpha = a_val; }
	public function get alpha(): Number { return _particleHolder._alpha; }
	
	public function set xscale(a_val: Number): Void
	{
		_particleHolder._xscale = a_val;
		_width = _effectWidth * a_val/100;
	}
	public function get xscale(): Number { return _particleHolder._xscale; }
	
	public function set yscale(a_val: Number): Void
	{
		_particleHolder._yscale = a_val;
		_height *= a_val/100;
	}
	public function get yscale(): Number { return _particleHolder._yscale; }
	
	public function ParticleEmitter()
	{
		// The ParticleEmitter MovieClip(this) is actually a mask, the real magic bappens in _particleHolder
		_visible = false;
		
		_effectWidth = _width;
		_effectHeight = _height;
		
		var particleHolderName: String = "_particleHolder";
		
		while (_parent[particleHolderName] != undefined)
			particleHolderName = "_" + particleHolderName;
		
		_particleHolder = _parent.createEmptyMovieClip(particleHolderName, _parent.getNextHighestDepth());
		_particleHolder.swapDepths(this); //Swap depths so the _particleHolder is on the correct "layer"
		_particleHolder.setMask(this);
		
		_particles = new Array();
	}
	
	private function setParticleFrameLabel(a_frameLabel: String): Void
	{
		particleFrameLabel = a_frameLabel;
		for (var i: Number = 0; i < _particles.length; i++) {
			if (_particles[i].frameLabel == particleFrameLabel)
				continue;
			_particles[i].frameLabel = particleFrameLabel;
			_particles[i].gotoAndStop(particleFrameLabel);
		}
	}
	
	private function addParticle(a_particleInitFunc: Function, a_forceAdd: Boolean): MovieClip
	{
		if (_particles.length >= maxParticles && !a_forceAdd)
			return undefined;
			
		var initFunc: Function = a_particleInitFunc || initParticle;
		var particle: MovieClip = _particleHolder.attachMovie(particleLinkageName, "particle" + _particles.length, _particleHolder.getNextHighestDepth());
		particle.frameLabel = particleFrameLabel;
		particle.gotoAndStop(particleFrameLabel);
		
		particle = initFunc(particle);
		
		_particles.push(particle);
		
		return particle;
	}
	
	private function initParticle(a_particle: MovieClip): MovieClip
	{
		var particle: MovieClip = a_particle;
		particle._visible = false;
		return particle;
	}
}