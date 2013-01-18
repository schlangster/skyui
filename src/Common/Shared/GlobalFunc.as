class Shared.GlobalFunc
{
	static var RegisteredTextFields: Object = new Object();
	static var RegisteredMovieClips: Object = new Object();

	function GlobalFunc()
	{
	}

	static function Lerp(aTargetMin: Number, aTargetMax: Number, aSourceMin: Number, aSourceMax: Number, aSource: Number, abClamp: Boolean): Number
	{
		var normVal: Number = aTargetMin + (aSource - aSourceMin) / (aSourceMax - aSourceMin) * (aTargetMax - aTargetMin);
		if (abClamp) 
			normVal = Math.min(Math.max(normVal, aTargetMin), aTargetMax);
		return normVal;
	}

	static function IsKeyPressed(aInputInfo: Object, abProcessKeyHeldDown: Boolean): Boolean
	{
		if (abProcessKeyHeldDown == undefined) 
			abProcessKeyHeldDown = true;
		return aInputInfo.value == "keyDown" || (abProcessKeyHeldDown && aInputInfo.value == "keyHold");
	}

	static function RoundDecimal(aNumber: Number, aPrecision: Number): Number
	{
		var significantFigures: Number = Math.pow(10, aPrecision);
		return Math.round(significantFigures * aNumber) / significantFigures;
	}

	static function MaintainTextFormat(): Void
	{
		TextField.prototype.SetText = function (aText: String, abHTMLText: Boolean)
		{
			if (aText == undefined || aText == "") 
				aText = " ";
			var textFormat: TextFormat = this.getTextFormat();
			if (abHTMLText) {
				var letterSpacing: Number = textFormat.letterSpacing;
				var kerning: Boolean = textFormat.kerning;
				this.htmlText = aText;
				textFormat = this.getTextFormat();
				textFormat.letterSpacing = letterSpacing;
				textFormat.kerning = kerning;
				this.setTextFormat(textFormat);
				return;
			}
			this.text = aText;
			this.setTextFormat(textFormat);
			return;
		};

		_global.ASSetPropFlags(TextField.prototype, "SetText" , 0x01, 0x00);
	}

	static function SetLockFunction(): Void
	{
		MovieClip.prototype.Lock = function (aPosition: String): Void
		{
			var minXY: Object = {x: Stage.visibleRect.x + Stage.safeRect.x, y: Stage.visibleRect.y + Stage.safeRect.y};
			var maxXY: Object = {x: Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};
			this._parent.globalToLocal(minXY);
			this._parent.globalToLocal(maxXY);

			//  (minXY.x, minXY.y) _____________ (maxXY.x, minXY.y)
			//                    |             |
			//                    |     THE     |
			//                    |    STAGE    |
			//  (minXY.x, maxXY.y)|_____________|(maxXY.x, maxXY.y)
			
			if (aPosition == "T" || aPosition == "TL" || aPosition == "TR") 
				this._y = minXY.y;
			if (aPosition == "B" || aPosition == "BL" || aPosition == "BR") 
				this._y = maxXY.y;
			if (aPosition == "L" || aPosition == "TL" || aPosition == "BL") 
				this._x = minXY.x;
			if (aPosition == "R" || aPosition == "TR" || aPosition == "BR") 
				this._x = maxXY.x;
		};

		_global.ASSetPropFlags(MovieClip.prototype, "Lock" , 0x01, 0x00);
	}

	static function AddMovieExploreFunctions(): Void
	{
		MovieClip.prototype.getMovieClips = function (): Array
		{
			var movieClips: Array = new Array();
			for (var i: Number = 0; i < this.length; i++)
				if (this[i] instanceof MovieClip && this[i] != this) 
					movieClips.push(this[i]);
			return movieClips;
		};
		MovieClip.prototype.showMovieClips = function (): Void
		{
			for (var i: Number = 0; i < this.length; i++)
				if (this[i] instanceof MovieClip && this[i] != this) {
					trace(this[i]);
					this[i].showMovieClips();
				}
		};

		_global.ASSetPropFlags(MovieClip.prototype, ["getMovieClips", "showMovieClips"], 0x01, 0x00);
	}

	static function AddReverseFunctions(): Void
	{
		MovieClip.prototype.PlayReverse = function (): Void
		{
			if (this._currentframe > 1) {
				this.gotoAndStop(this._currentframe - 1);
				this.onEnterFrame = function ()
				{
					if (this._currentframe > 1) {
						this.gotoAndStop(this._currentframe - 1);
						return;
					}
					delete (this.onEnterFrame);
				}
				return;
			}
			this.gotoAndStop(1);
		};
		MovieClip.prototype.PlayForward = function (aFrameLabel: String): Void
		{
			delete (this.onEnterFrame);
			this.gotoAndPlay(aFrameLabel);
		};
		MovieClip.prototype.PlayForward = function (aFrame: Number): Void
		{
			delete (this.onEnterFrame);
			this.gotoAndPlay(aFrame);
		};

		_global.ASSetPropFlags(MovieClip.prototype, ["PlayReverse", "PlayForward"], 0x01, 0x00);
	}

	static function GetTextField(aParentClip: MovieClip, aName: String): TextField
	{
		if (Shared.GlobalFunc.RegisteredTextFields[aName + aParentClip._name] != undefined) 
			return Shared.GlobalFunc.RegisteredTextFields[aName + aParentClip._name];
		trace(aName + " is not registered a TextField name.");
	}

	static function GetMovieClip(aParentClip: MovieClip, aName: String): MovieClip
	{
		if (Shared.GlobalFunc.RegisteredMovieClips[aName + aParentClip._name] != undefined) 
			return Shared.GlobalFunc.RegisteredMovieClips[aName + aParentClip._name];
		trace(aName + " is not registered a MovieClip name.");
	}

	static function AddRegisterTextFields(): Void
	{
		TextField.prototype.RegisterTextField = function (aStartingClip): Void
		{
			if (Shared.GlobalFunc.RegisteredTextFields[this._name + aStartingClip._name] == undefined) 
				Shared.GlobalFunc.RegisteredTextFields[this._name + aStartingClip._name] = this;
		};

		_global.ASSetPropFlags(TextField.prototype, "RegisterTextField", 0x01, 0x00);
	}

	static function RegisterTextFields(aStartingClip: MovieClip) : Void
	{
		for (var i: Number = 0; i < aStartingClip.length; i++)
			if (aStartingClip[i] instanceof TextField) 
				aStartingClip[i].RegisterTextField(aStartingClip);
	}

	static function RegisterAllTextFieldsInTimeline(aStartingClip: MovieClip): Void
	{
		for (var i: Number = 1; aStartingClip._totalFrames && i <= aStartingClip._totalFrames; i++) {
			aStartingClip.gotoAndStop(i);
			Shared.GlobalFunc.RegisterTextFields(aStartingClip);
		}
	}

	static function AddRegisterMovieClips(): Void
	{
		MovieClip.prototype.RegisterMovieClip = function (aStartingClip): Void
		{
			if (Shared.GlobalFunc.RegisteredMovieClips[this._name + aStartingClip._name] == undefined) 
				Shared.GlobalFunc.RegisteredMovieClips[this._name + aStartingClip._name] = this;
		};

		_global.ASSetPropFlags(MovieClip.prototype, "RegisterMovieClip", 0x01, 0x00);
	}

	static function RegisterMovieClips(aStartingClip: MovieClip): Void
	{
		for (var i: Number = 0; i < aStartingClip.length; i++)
			if (aStartingClip[i] instanceof MovieClip) 
				aStartingClip[i].RegisterMovieClip(aStartingClip);
	}

	static function RecursiveRegisterMovieClips(aStartingClip: MovieClip, aRootClip: MovieClip): Void
	{
		for (var i: Number = 0; i < aStartingClip.length; i++) {
			if (aStartingClip[i] instanceof MovieClip) {
				if (aStartingClip[i] != aStartingClip) 
					Shared.GlobalFunc.RecursiveRegisterMovieClips(aStartingClip[i], aRootClip);
				aStartingClip[i].RegisterMovieClip(aRootClip);
			}
		}
	}

	static function RegisterAllMovieClipsInTimeline(aStartingClip: MovieClip): Void
	{
		for (var i: Number = 0; aStartingClip._totalFrames && i <= aStartingClip._totalFrames; i++) {
			aStartingClip.gotoAndStop(i);
			Shared.GlobalFunc.RegisterMovieClips(aStartingClip);
		}
	}

	static function StringTrim(astrText: String): String
	{
		var i: Number = 0;
		var j: Number = 0;
		var strLength: Number = astrText.length;
		var trimStr: String = undefined;
		while (astrText.charAt(i) == " " || astrText.charAt(i) == "\n" || astrText.charAt(i) == "\r" || astrText.charAt(i) == "\t") 
			++i;
		trimStr = astrText.substring(i);
		j = trimStr.length - 1;
		while (trimStr.charAt(j) == " " || trimStr.charAt(j) == "\n" || trimStr.charAt(j) == "\r" || trimStr.charAt(j) == "\t") 
			--j;
		trimStr = trimStr.substring(0, j + 1);
		return trimStr;
	}

}
