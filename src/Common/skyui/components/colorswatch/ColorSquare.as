import gfx.controls.Button;

import flash.geom.ColorTransform;
import flash.geom.Transform;

import skyui.util.ColorFunctions;

class skyui.components.colorswatch.ColorSquare extends Button
{
  /* PRIVATE VARIABLES */
	private var _color: Number;

  /* STAGE ELEMENTS */
	public var pigment: MovieClip
	public var selector: MovieClip;

	public function ColorSquare() {
		super();
	}

 /* PROPERTIES */
	public function set color(a_color: Number): Void
	{
		_color = a_color;
		setColor(_color);
	}
	public function get color(): Number
	{
		return _color;
	}

  /* PRIVATE FUNCTIONS */
	private function setColor(a_color: Number): Void
	{
		var ct: ColorTransform = new ColorTransform();
		ct.rgb = a_color;
		var t: Transform = new Transform(pigment);
		t.colorTransform = ct;

		ct.rgb = ((ColorFunctions.hexToHsv(a_color)[2] < 75)? 0xFFFFFF: 0x000000);
		t = new Transform(selector);
		t.colorTransform = ct;
		selector._alpha = 0;
	}
}