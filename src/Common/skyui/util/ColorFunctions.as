class skyui.util.ColorFunctions
{	
  /* CONSTANTS */
	private static var RAD_TO_DEG: Number		= 57.295779513082;
	private static var DEG_TO_RAD: Number		= 0.017453292519943;									 
	private static var TWO_PI: Number			= 6.2831853071796;
	private static var SQRT_3_OVER_2: Number	= 0.86602540378444;

  /* PUBLIC FUNCTIONS */
	// Hex
	public static function hexToRgb(a_RRGGBB: Number): Array
	{
		var RRGGBB: Number = clampValue(a_RRGGBB, 0x000000, 0xFFFFFF);

		return [RRGGBB >> 0x10 & 0xFF, RRGGBB >> 0x08 & 0xFF, RRGGBB & 0xFF];
	}

	public static function hexToHsv(a_RRGGBB: Number): Array
	{
		return rgbToHsv(hexToRgb(a_RRGGBB));
	}

	public static function hexToHsl(a_RRGGBB: Number): Array
	{
		return rgbToHsl(hexToRgb(a_RRGGBB));
	}

	public static function hexToStr(a_RRGGBB: Number, a_prefix: Boolean): String
	{
		var str:String = a_RRGGBB.toString(16).toUpperCase();

		var padding: String = '';
		for (var i: Number = str.length; i < 6; i++) {
			padding += '0';
		}

		str = ((a_prefix)? "0x": "") + padding + str;

		return str;

	}

	// RGB
	public static function rgbToHex(a_RGB: Array): Number
	{
		var RGB: Array = a_RGB;
		return (RGB[0] << 0x10 ^ RGB[1] << 0x08 ^ RGB[2]);
	}

	public static function rgbToHsv(a_RGB: Array): Array
	{
		// in: [R [0-255], G [0-255], B [0-255]]
		// out: [H [0-360), S [0, 100], V [0, 100]]
		var R: Number = a_RGB[0]/255;
		var G: Number = a_RGB[1]/255;
		var B: Number = a_RGB[2]/255;

		var H, S, V: Number;

		var M: Number = Math.max(R, Math.max(G, B));
		var m: Number = Math.min(R, Math.min(G, B));
		var C: Number = M - m;
		//H = piecewise..

		var alpha: Number = (2*R - G - B)/2;
		var beta: Number = (G - B)*SQRT_3_OVER_2;
		H = Math.atan2(beta, alpha);
		V = M;
		S = ((C == 0)? 0: C/V);

		if (H < 0)
			H += TWO_PI;
		
		H *= RAD_TO_DEG;
		S *= 100;
		V *= 100;

		H = Math.round(H);
		S = Math.round(S);
		V = Math.round(V);

		return [H, S, V];
	}

	public static function rgbToHsb(a_RGB: Array): Array { return rgbToHsv(a_RGB); }

	public static function rgbToHsl(a_RGB: Array): Array
	{
		// in: [R [0-255], G [0-255], B [0-255]]
		// out: [H [0-360), S [0, 100], L [0, 100]]
		var R: Number = a_RGB[0]/255;
		var G: Number = a_RGB[1]/255;
		var B: Number = a_RGB[2]/255;

		var H, S, L: Number;

		var M: Number = Math.max(R, Math.max(G, B));
		var m: Number = Math.min(R, Math.min(G, B));
		var C: Number = M - m;
		//H = piecewise..

		var alpha: Number = (2*R - G - B)/2;
		var beta: Number = (G - B)*SQRT_3_OVER_2;
		H = Math.atan2(beta, alpha);
		L = (M + m)/2;
		S = ((C == 0)? 0: C/(1 - Math.abs(2*L - 1)));

		if (H < 0)
			H += TWO_PI;
		
		H *= RAD_TO_DEG;
		S *= 100;
		L *= 100;

		H = Math.round(H);
		S = Math.round(S);
		L = Math.round(L);

		return [H, S, L];
	}

	
	// HSV
	public static function hsvToRgb(a_HSV: Array): Array
	{
		// in: [H [0-360), S [0, 100], V [0, 100]]
		// out: [R [0-255], G [0-255], B [0-255]]
		var H: Number = a_HSV[0];
		var S: Number = a_HSV[1]/100;
		var V: Number = a_HSV[2]/100;

		var R, G, B: Number;

		var C = V * S;

		var Hdash: Number = H / 60;
		var sextant: Number = Math.floor(Hdash);

		var X: Number = C*(1 - Math.abs(Hdash % 2 - 1));

		switch(sextant) {
			case 0:
				R = C;
				G = X;
				B = 0;
				break;
			case 1:
				R = X;
				G = C;
				B = 0;
				break;
			case 2:
				R = 0;
				G = C;
				B = X;
				break;
			case 3:
				R = 0;
				G = X;
				B = C;
				break;
			case 4:
				R = X;
				G = 0;
				B = C;
				break;
			case 5:
				R = C;
				G = 0;
				B = X;
				break;
			default:
				R = 0;
				G = 0;
				B = 0;
				break;
		}

		var m: Number = V - C;

		R += m;
		G += m;
		B += m;

		R *= 255;
		G *= 255;
		B *= 255;

		R = Math.round(R);
		G = Math.round(G);
		B = Math.round(B);

		return [R, G, B];
	}
	public static function hsvToHex(a_HSV): Number { return rgbToHex(hsvToRgb(a_HSV)); }

	// HSB (alias for HSV)
	public static function hsbToRgb(a_HSB: Array): Array { return hsvToRgb(a_HSB); }
	public static function hsbToHex(a_HSB): Number { return hsvToHex(a_HSB); }

	// HSL
	public static function hslToRgb(a_HSL: Array): Array
	{
		// in: [H [0-360), S [0, 100], L [0, 100]]
		// out: [R [0-255], G [0-255], B [0-255]]
		var H: Number = a_HSL[0];
		var S: Number = a_HSL[1]/100;
		var L: Number = a_HSL[2]/100;

		var R, G, B: Number;

		var C = (1 - Math.abs(2*L - 1)) * S;

		var Hdash: Number = H / 60;
		var sextant: Number = Math.floor(Hdash);

		var X: Number = C*(1 - Math.abs(Hdash % 2 - 1));

		switch(sextant) {
			case 0:
				R = C;
				G = X;
				B = 0;
				break;
			case 1:
				R = X;
				G = C;
				B = 0;
				break;
			case 2:
				R = 0;
				G = C;
				B = X;
				break;
			case 3:
				R = 0;
				G = X;
				B = C;
				break;
			case 4:
				R = X;
				G = 0;
				B = C;
				break;
			case 5:
				R = C;
				G = 0;
				B = X;
				break;
			default:
				R = 0;
				G = 0;
				B = 0;
				break;
		}

		var m: Number = L - C/2;

		R += m;
		G += m;
		B += m;

		R *= 255;
		G *= 255;
		B *= 255;

		R = Math.round(R);
		G = Math.round(G);
		B = Math.round(B);

		return [R, G, B];
	}

	public static function hslToHex(a_HSL): Number { return rgbToHex(hslToRgb(a_HSL)); }

  /* PRIVATE FUNCTIONS */
	private static function clampValue(a_val: Number, a_min: Number, a_max: Number): Number
	{
		return Math.min(a_max, Math.max(a_min, a_val));
	}

	private static function valLoop(a_val: Number, a_max: Number): Number
	{
		// $ trace(valLoop(360.1012, 180))
		// > 0.10120000000001
		// $ trace(valLoop(-2*Math.PI, Math.PI))
		// > -3.1415926535898
		var val = Math.abs(a_val);
		var sign: Number = ((a_val > 0)? 1: ((a_val < 0) ? -1 : 0));

		return sign * (val - a_max * (Math.ceil(val/a_max) - 1));
	}

}