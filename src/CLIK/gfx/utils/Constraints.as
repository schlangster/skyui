dynamic class gfx.utils.Constraints
{
	static var LEFT: Number = 1;
	static var RIGHT: Number = 2;
	static var TOP: Number = 4;
	static var BOTTOM: Number = 8;
	static var ALL = gfx.utils.Constraints.LEFT | gfx.utils.Constraints.RIGHT | gfx.utils.Constraints.TOP | gfx.utils.Constraints.BOTTOM;
	var scaled: Boolean = false;
	var elements;
	var scope;

	function Constraints(scope, scaled)
	{
		this.scope = scope;
		this.scaled = scaled;
		this.elements = [];
	}

	function addElement(clip, edges)
	{
		if (clip != null) 
		{
			var __reg8 = 100 / this.scope._xscale;
			var __reg7 = 100 / this.scope._yscale;
			var __reg6 = this.scope._width;
			var __reg5 = this.scope._height;
			if (this.scope == _root) 
			{
				__reg6 = Stage.width;
				__reg5 = Stage.height;
			}
			var __reg4 = {clip: clip, edges: edges, metrics: {left: clip._x, top: clip._y, right: __reg6 * __reg8 - (clip._x + clip._width), bottom: __reg5 * __reg7 - (clip._y + clip._height), xscale: clip._xscale, yscale: clip._yscale}};
			var __reg14 = __reg4.metrics;
			this.elements.push(__reg4);
		}
	}

	function removeElement(clip)
	{
		var __reg2 = 0;
		for (;;) 
		{
			if (__reg2 >= this.elements.length) 
			{
				return;
			}
			if (this.elements[__reg2].clip == clip) 
			{
				this.elements.splice(__reg2, 1);
				return;
			}
			++__reg2;
		}
	}

	function getElement(clip)
	{
		var __reg2 = 0;
		while (__reg2 < this.elements.length) 
		{
			if (this.elements[__reg2].clip == clip) 
			{
				return this.elements[__reg2];
			}
			++__reg2;
		}
		return null;
	}

	function update(width, height)
	{
		var __reg10 = 100 / this.scope._xscale;
		var __reg9 = 100 / this.scope._yscale;
		if (!this.scaled) 
		{
			this.scope._xscale = 100;
			this.scope._yscale = 100;
		}
		var __reg8 = 0;
		for (;;) 
		{
			if (__reg8 >= this.elements.length) 
			{
				return;
			}
			var __reg5 = this.elements[__reg8];
			var __reg4 = __reg5.edges;
			var __reg2 = __reg5.clip;
			var __reg3 = __reg5.metrics;
			var __reg14 = __reg2.width == null ? "_width" : "width";
			var __reg13 = __reg2.height == null ? "_height" : "height";
			if (this.scaled) 
			{
				__reg2._xscale = __reg3.xscale * __reg10;
				__reg2._yscale = __reg3.yscale * __reg9;
				if ((__reg4 & gfx.utils.Constraints.LEFT) > 0) 
				{
					__reg2._x = __reg3.left * __reg10;
					if ((__reg4 & gfx.utils.Constraints.RIGHT) > 0) 
					{
						var __reg7 = width - __reg3.left - __reg3.right;
						if (!(__reg2 instanceof TextField)) 
						{
							__reg7 = __reg7 * __reg10;
						}
						__reg2[__reg14] = __reg7;
					}
				}
				else if ((__reg4 & gfx.utils.Constraints.RIGHT) > 0) 
				{
					__reg2._x = (width - __reg3.right) * __reg10 - __reg2._width;
				}
				if ((__reg4 & gfx.utils.Constraints.TOP) > 0) 
				{
					__reg2._y = __reg3.top * __reg9;
					if ((__reg4 & gfx.utils.Constraints.BOTTOM) > 0) 
					{
						var __reg6 = height - __reg3.top - __reg3.bottom;
						if (!(__reg2 instanceof TextField)) 
						{
							__reg6 = __reg6 * __reg9;
						}
						__reg2[__reg13] = __reg6;
					}
				}
				else if ((__reg4 & gfx.utils.Constraints.BOTTOM) > 0) 
				{
					__reg2._y = (height - __reg3.bottom) * __reg9 - __reg2._height;
				}
			}
			else 
			{
				if ((__reg4 & gfx.utils.Constraints.RIGHT) > 0) 
				{
					if ((__reg4 & gfx.utils.Constraints.LEFT) > 0) 
					{
						__reg2[__reg14] = width - __reg3.left - __reg3.right;
					}
					else 
					{
						__reg2._x = width - __reg2._width - __reg3.right;
					}
				}
				if ((__reg4 & gfx.utils.Constraints.BOTTOM) > 0) 
				{
					if ((__reg4 & gfx.utils.Constraints.TOP) > 0) 
					{
						__reg2[__reg13] = height - __reg3.top - __reg3.bottom;
					}
					else 
					{
						__reg2._y = height - __reg2._height - __reg3.bottom;
					}
				}
			}
			++__reg8;
		}
	}

	function toString()
	{
		return "[Scaleform Constraints]";
	}

}
