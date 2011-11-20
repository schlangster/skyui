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
        if (abClamp)
        {
            _loc1 = Math.min(Math.max(_loc1, aTargetMin), aTargetMax);
        }
        return _loc1;
    }
    
	static function IsKeyPressed(aInputInfo, abProcessKeyHeldDown)
    {
        if (abProcessKeyHeldDown == undefined)
        {
            abProcessKeyHeldDown = true;
        }
        return (aInputInfo.value == "keyDown" || abProcessKeyHeldDown && aInputInfo.value == "keyHold");
    }
    
	static function RoundDecimal(aNumber:Number, aPrecision:Number):Number
    {
        var _loc1 = Math.pow(10, aPrecision);
        return Math.round(_loc1 * aNumber) / _loc1;
    }
    
	static function MaintainTextFormat()
    {
        TextField.prototype.SetText = function (aText, abHTMLText)
        {
            if (aText == undefined || aText == "")
            {
                aText = " ";
            } // end if
            if (abHTMLText)
            {
                var _loc4 = this.getTextFormat();
                var _loc3 = _loc4.letterSpacing;
                var _loc5 = _loc4.kerning;
                htmlText = aText;
                _loc4 = this.getTextFormat();
                _loc4.letterSpacing = _loc3;
                _loc4.kerning = _loc5;
                this.setTextFormat(_loc4);
            }
            else
            {
                _loc4 = this.getTextFormat();
                text = aText;
                this.setTextFormat(_loc4);
            } // end else if
        };
    } 
	
    static function SetLockFunction()
    {
        MovieClip.prototype.Lock = function (aPosition)
        {
            var _loc4 = {x: Stage.visibleRect.x + Stage.safeRect.x, y: Stage.visibleRect.y + Stage.safeRect.y};
            var _loc3 = {x: Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};
            _parent.globalToLocal(_loc4);
            _parent.globalToLocal(_loc3);
			
            if (aPosition == "T" || aPosition == "TL" || aPosition == "TR")
            {
                _y = _loc4.y;
            }
            if (aPosition == "B" || aPosition == "BL" || aPosition == "BR")
            {
                _y = _loc3.y;
            }
            if (aPosition == "L" || aPosition == "TL" || aPosition == "BL")
            {
                _x = _loc4.x;
            }
            if (aPosition == "R" || aPosition == "TR" || aPosition == "BR")
            {
                _x = _loc3.x;
            }
        };
    }
	
    static function AddMovieExploreFunctions()
    {
        MovieClip.prototype.getMovieClips = function ()
        {
            var _loc2 = new Array();
            for (var _loc3 in this)
            {
                if (this[_loc3] instanceof MovieClip && this[_loc3] != this)
                {
                    _loc2.push(this[_loc3]);
                } // end if
            }
			
            return (_loc2);
        };
        MovieClip.prototype.showMovieClips = function ()
        {
            for (var _loc2 in this)
            {
                if (this[_loc2] instanceof MovieClip && this[_loc2] != this)
                {
                    trace (this[_loc2]);
                    this[_loc2].showMovieClips();
                } // end if
            } // end of for...in
        };
    }
	
    static function AddReverseFunctions()
    {
        MovieClip.prototype.PlayReverse = function ()
        {
            if (_currentframe > 1)
            {
                this.gotoAndStop(_currentframe - 1);
                function onEnterFrame()
                {
                    if (_currentframe > 1)
                    {
                        this.gotoAndStop(_currentframe - 1);
                    }
                    else
                    {
                        delete this.onEnterFrame;
                    } // end else if
                } // End of the function
            }
            else
            {
                this.gotoAndStop(1);
            } // end else if
        };
        MovieClip.prototype.PlayForward = function (aFrameLabel)
        {
            delete this.onEnterFrame;
            this.gotoAndPlay(aFrameLabel);
        };
        MovieClip.prototype.PlayForward = function (aFrame)
        {
            delete this.onEnterFrame;
            this.gotoAndPlay(aFrame);
        };
    }
	
    static function GetTextField(aParentClip, aName)
    {
        if (RegisteredTextFields[aName + aParentClip._name] != undefined)
        {
            return (RegisteredTextFields[aName + aParentClip._name]);
        }
        else
        {
            trace (aName + " is not registered a TextField name.");
        } // end else if
    }
	
    static function GetMovieClip(aParentClip, aName)
    {
        if (RegisteredMovieClips[aName + aParentClip._name] != undefined)
        {
            return (RegisteredMovieClips[aName + aParentClip._name]);
        }
        else
        {
            trace (aName + " is not registered a MovieClip name.");
        } // end else if
    }
	
    static function AddRegisterTextFields()
    {
        TextField.prototype.RegisterTextField = function (aStartingClip)
        {
            if (RegisteredTextFields[_name + aStartingClip._name] == undefined)
            {
                RegisteredTextFields[_name + aStartingClip._name] = this;
            } // end if
        };
    }
	
    static function RegisterTextFields(aStartingClip)
    {
        for (var _loc2 in aStartingClip)
        {
            if (aStartingClip[_loc2] instanceof TextField)
            {
                aStartingClip[_loc2].RegisterTextField(aStartingClip);
            } // end if
        } // end of for...in
    }
	
    static function RegisterAllTextFieldsInTimeline(aStartingClip)
    {
        for (var _loc2 = 1; aStartingClip._totalFrames && _loc2 <= aStartingClip._totalFrames; ++_loc2)
        {
            aStartingClip.gotoAndStop(_loc2);
            RegisterTextFields(aStartingClip);
        } // end of for
    }
	
    static function AddRegisterMovieClips()
    {
        MovieClip.prototype.RegisterMovieClip = function (aStartingClip)
        {
            if (RegisteredMovieClips[_name + aStartingClip._name] == undefined)
            {
                RegisteredMovieClips[_name + aStartingClip._name] = this;
            } // end if
        };
    }
	
    static function RegisterMovieClips(aStartingClip)
    {
        for (var _loc2 in aStartingClip)
        {
            if (aStartingClip[_loc2] instanceof MovieClip)
            {
                aStartingClip[_loc2].RegisterMovieClip(aStartingClip);
            } // end if
        } // end of for...in
    }
	
    static function RecursiveRegisterMovieClips(aStartingClip, aRootClip)
    {
        for (var _loc3 in aStartingClip)
        {
            if (aStartingClip[_loc3] instanceof MovieClip)
            {
                if (aStartingClip[_loc3] != aStartingClip)
                {
                    RecursiveRegisterMovieClips(aStartingClip[_loc3], aRootClip);
                } // end if
                aStartingClip[_loc3].RegisterMovieClip(aRootClip);
            } // end if
        } // end of for...in
    }
	
    static function RegisterAllMovieClipsInTimeline(aStartingClip)
    {
        for (var _loc2 = 1; aStartingClip._totalFrames && _loc2 <= aStartingClip._totalFrames; ++_loc2)
        {
            aStartingClip.gotoAndStop(_loc2);
            RegisterMovieClips(aStartingClip);
        } // end of for
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
        } // end while
        _loc3 = astrText.substring(_loc2);
        for (var _loc1 = _loc3.length - 1; _loc3.charAt(_loc1) == " " || _loc3.charAt(_loc1) == "\n" || _loc3.charAt(_loc1) == "\r" || _loc3.charAt(_loc1) == "\t"; --_loc1)
        {
        } // end of for
        _loc3 = _loc3.substring(0, _loc1 + 1);
        return (_loc3);
    }
}
