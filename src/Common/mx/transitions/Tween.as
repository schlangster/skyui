class mx.transitions.Tween
{
   var obj;
   var prop;
   var begin;
   var useSeconds;
   var _time;
   var prevTime;
   var looping;
   var _duration;
   var _fps;
   var isPlaying;
   var prevPos;
   var _pos;
   var change;
   var _intervalID;
   var _startTime;

   public var onMotionStarted;
   public var onMotionFinished;
   public var onMotionStopped;
   public var onMotionLooped;
   public var onMotionChanged;
   public var onMotionResumed;

   function Tween(obj, prop, func, begin, finish, duration, useSeconds)
   {
      if(!arguments.length)
      {
         return;
      }
      this.obj = obj;
      this.prop = prop;
      this.begin = begin;
      this.position = begin;
      this.duration = duration;
      this.useSeconds = useSeconds;
      if(func)
      {
         this.func = func;
      }
      this.finish = finish;
      this.FPS = 30;
      start();
   }
   function set time(t)
   {
      prevTime = _time;
      if(t > this.duration)
      {
         if(looping)
         {
            this.rewind(t - this._duration);
            this.update();
            if(this.onMotionLooped)
            {
               this.onMotionLooped();
            }
         }
         else
         {
            if(this.useSeconds)
            {
               this._time = this._duration;
               this.update();
            }
            this.stop();
            if(this.onMotionFinished)
            {
               this.onMotionFinished();
            }
         }
      }
      else if(t < 0)
      {
         this.rewind();
         this.update();
      }
      else
      {
         this._time = t;
         this.update();
      }
      //return this.time;
   }
   function get time()
   {
      return _time;
   }
   function set duration(d)
   {
      _duration = !(d == null || d <= 0)?d:_global.Infinity;
      //return this.duration;
   }
   function get duration()
   {
      return _duration;
   }
   function set FPS(fps)
   {
      var _loc2_ = this.isPlaying;
      this.stopEnterFrame();
      this._fps = fps;
      if(_loc2_)
      {
         this.startEnterFrame();
      }
      //return this.__get__FPS();
   }
   function __get__FPS()
   {
      return this._fps;
   }
   function set position(p)
   {
      this.setPosition(p);
      //return this.__get__position();
   }
   function setPosition(p)
   {
      this.prevPos = this._pos;
      this.obj[this.prop] = this._pos = p;
      if(this.onMotionChanged)
      {
         this.onMotionChanged(this._pos);
      }
      updateAfterEvent();
   }
   function get position()
   {
      return this.getPosition();
   }
   function getPosition(t)
   {
      if(t == undefined)
      {
         t = this._time;
      }
      return this.func(t,this.begin,this.change,this._duration);
   }
   function set finish(f)
   {
      this.change = f - this.begin;
      //return this.finish;
   }
   function get finish()
   {
      return this.begin + this.change;
   }
   function continueTo(finish, duration)
   {
      this.begin = this.position;
      this.finish = finish;
      if(duration != undefined)
      {
         this.duration = duration;
      }
      this.start();
   }
   function yoyo()
   {
      this.continueTo(this.begin,this.time);
   }
   function startEnterFrame()
   {
      this._intervalID = setInterval(this,"onEnterFrame",1000 / this._fps);
      this.isPlaying = true;
   }
   function stopEnterFrame()
   {
      clearInterval(this._intervalID);
      this.isPlaying = false;
   }
   function start()
   {
      this.rewind();
      this.startEnterFrame();
      if(this.onMotionStarted)
      {
         this.onMotionStarted();
      }
   }
   function stop()
   {
      this.stopEnterFrame();
      if(this.onMotionStopped)
      {
         this.onMotionStopped();
      }
   }
   function resume()
   {
      this.fixTime();
      this.startEnterFrame();
      if(this.onMotionResumed)
      {
         this.onMotionResumed();
      }
   }
   function rewind(t)
   {
      this._time = t != undefined?t:0;
      this.fixTime();
      this.update();
   }
   function fforward()
   {
      this.time = _duration;
      this.fixTime();
   }
   function nextFrame()
   {
      if(this.useSeconds)
      {
         this.time = (getTimer() - this._startTime) / 1000;
      }
      else
      {
         this.time = this._time + 1;
      }
   }
   function onEnterFrame()
   {
      this.nextFrame();
   }
   function prevFrame()
   {
      if(!this.useSeconds)
      {
         this.time = this._time - 1;
      }
   }
   function toString()
   {
      return "[Tween]";
   }
   function fixTime()
   {
      if(this.useSeconds)
      {
         this._startTime = getTimer() - this._time * 1000;
      }
   }
   function update()
   {
      this.position = getPosition(this._time);
   }
   function func(t, b, c, d)
   {
      return c * t / d + b;
   }
}
