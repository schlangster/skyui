class Shared.GlobalFunc
{
	static var RegisteredTextFields = new Object();
	static var RegisteredMovieClips = new Object();

	var getTextFormat;
	var htmlText;
	var setTextFormat;

	var text;
	var _parent;
	var _y;
	var _x;
	var _currentframe;
	var _name;

	static function Lerp(aTargetMin:Number, aTargetMax:Number, aSourceMin:Number, aSourceMax:Number, aSource:Number, abClamp:Number):Number
	{
		var _loc1:Number = aTargetMin + (aSource - aSourceMin) / (aSourceMax - aSourceMin) * (aTargetMax - aTargetMin);

		if (abClamp) {
			_loc1 = Math.min(Math.max(_loc1, aTargetMin), aTargetMax);
		}
		return _loc1;
	}

	static function IsKeyPressed(aInputInfo, abProcessKeyHeldDown)
	{
		if (abProcessKeyHeldDown == undefined) {
			abProcessKeyHeldDown = true;
		}
		return aInputInfo.value == "keyDown" || abProcessKeyHeldDown && aInputInfo.value == "keyHold";
	}

	static function RoundDecimal(aNumber:Number, aPrecision:Number):Number
	{
		var _loc1 = Math.pow(10, aPrecision);
		return Math.round(_loc1 * aNumber) / _loc1;
	}

	static function MaintainTextFormat()
	{
		TextField.prototype.SetText = function(aText, abHTMLText)
		{
			if (aText == undefined || aText == "") {
				aText = " ";
			}

			if (abHTMLText) {
				var _loc4 = this.getTextFormat();
				var _loc3 = _loc4.letterSpacing;
				var _loc5 = _loc4.kerning;
				htmlText = aText;
				_loc4 = this.getTextFormat();
				_loc4.letterSpacing = _loc3;
				_loc4.kerning = _loc5;
				this.setTextFormat(_loc4);
			} else {
				_loc4 = this.getTextFormat();
				text = aText;
				this.setTextFormat(_loc4);
			}
		};
	}

	static function SetLockFunction()
	{
		MovieClip.prototype.Lock = function(aPosition:String)
		{
			var topLeft = {x:Stage.visibleRect.x + Stage.safeRect.x, y:Stage.visibleRect.y + Stage.safeRect.y};
			var bottomRight = {x:Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y:Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};

			_parent.globalToLocal(topLeft);
			_parent.globalToLocal(bottomRight);

			if (aPosition == "T" || aPosition == "TL" || aPosition == "TR") {
				_y = topLeft.y;
			}
			if (aPosition == "B" || aPosition == "BL" || aPosition == "BR") {
				_y = bottomRight.y;
			}
			if (aPosition == "L" || aPosition == "TL" || aPosition == "BL") {
				_x = topLeft.x;
			}
			if (aPosition == "R" || aPosition == "TR" || aPosition == "BR") {
				_x = bottomRight.x;
			}
		};
	}

	static function AddMovieExploreFunctions()
	{
		MovieClip.prototype.getMovieClips = function()
		{
			var a = new Array();
			for (var clip in this) {
				if (this[clip] instanceof MovieClip && this[clip] != this) {
					a.push(this[clip]);
				}
			}

			return a;
		};
		MovieClip.prototype.showMovieClips = function()
		{
			for (var clip in this) {
				if (this[clip] instanceof MovieClip && this[clip] != this) {
					trace(this[clip]);
					this[clip].showMovieClips();
				}
			}
		};
	}

	static function AddReverseFunctions()
	{
		MovieClip.prototype.PlayReverse = function()
		{
			if (_currentframe > 1) {
				this.gotoAndStop(_currentframe - 1);
				this.onEnterFrame = function()
				{
					if (_currentframe > 1) {
						this.gotoAndStop(_currentframe - 1);
					} else {
						delete this.onEnterFrame;
					}
				};
			} else {
				this.gotoAndStop(1);
			}// end else if
		};
		MovieClip.prototype.PlayForward = function(aFrameLabel)
		{
			delete this.onEnterFrame;
			this.gotoAndPlay(aFrameLabel);
		};
		MovieClip.prototype.PlayForward = function(aFrame)
		{
			delete this.onEnterFrame;
			this.gotoAndPlay(aFrame);
		};
	}

	static function GetTextField(aParentClip, aName)
	{
		if (RegisteredTextFields[aName + aParentClip._name] != undefined) {
			return (RegisteredTextFields[aName + aParentClip._name]);
		} else {
			trace(aName + " is not registered a TextField name.");
		}
	}

	static function GetMovieClip(aParentClip, aName)
	{
		if (RegisteredMovieClips[aName + aParentClip._name] != undefined) {
			return (RegisteredMovieClips[aName + aParentClip._name]);
		} else {
			trace(aName + " is not registered a MovieClip name.");
		}
	}

	static function AddRegisterTextFields()
	{
		TextField.prototype.RegisterTextField = function(aStartingClip)
		{
			if (RegisteredTextFields[_name + aStartingClip._name] == undefined) {
				RegisteredTextFields[_name + aStartingClip._name] = this;
			}
		};
	}

	static function RegisterTextFields(aStartingClip)
	{
		for (var _loc2 in aStartingClip) {
			if (aStartingClip[_loc2] instanceof TextField) {
				aStartingClip[_loc2].RegisterTextField(aStartingClip);
			}
		}
	}

	static function RegisterAllTextFieldsInTimeline(aStartingClip)
	{
		for (var _loc2 = 1; aStartingClip._totalFrames && _loc2 <= aStartingClip._totalFrames; ++_loc2) {
			aStartingClip.gotoAndStop(_loc2);
			RegisterTextFields(aStartingClip);
		}
	}

	static function AddRegisterMovieClips()
	{
		MovieClip.prototype.RegisterMovieClip = function(aStartingClip)
		{
			if (RegisteredMovieClips[_name + aStartingClip._name] == undefined) {
				RegisteredMovieClips[_name + aStartingClip._name] = this;
			}
		};
	}

	static function RegisterMovieClips(aStartingClip)
	{
		for (var _loc2 in aStartingClip) {
			if (aStartingClip[_loc2] instanceof MovieClip) {
				aStartingClip[_loc2].RegisterMovieClip(aStartingClip);
			}
		}
	}

	static function RecursiveRegisterMovieClips(aStartingClip, aRootClip)
	{
		for (var _loc3 in aStartingClip) {
			if (aStartingClip[_loc3] instanceof MovieClip) {
				if (aStartingClip[_loc3] != aStartingClip) {
					RecursiveRegisterMovieClips(aStartingClip[_loc3],aRootClip);
				}
				// end if  
				aStartingClip[_loc3].RegisterMovieClip(aRootClip);
			}
			// end if  
		}// end of for...in
	}

	static function RegisterAllMovieClipsInTimeline(aStartingClip)
	{
		for (var _loc2 = 1; aStartingClip._totalFrames && _loc2 <= aStartingClip._totalFrames; ++_loc2) {
			aStartingClip.gotoAndStop(_loc2);
			RegisterMovieClips(aStartingClip);
		}// end of for
	}

	static function StringTrim(astrText)
	{
		var _loc2 = 0;
		var _loc1 = 0;
		var _loc5 = astrText.length;
		var _loc3;
		while (astrText.charAt(_loc2) == " " || astrText.charAt(_loc2) == "\n" || astrText.charAt(_loc2) == "\r" || astrText.charAt(_loc2) == "\t")
		{
			++_loc2;
		}// end while
		_loc3 = astrText.substring(_loc2);
		for (var _loc1 = _loc3.length - 1; _loc3.charAt(_loc1) == " " || _loc3.charAt(_loc1) == "\n" || _loc3.charAt(_loc1) == "\r" || _loc3.charAt(_loc1) == "\t"; --_loc1) {
		}// end of for
		_loc3 = _loc3.substring(0, _loc1 + 1);
		return (_loc3);
	}
}