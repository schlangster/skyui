class gfx.events.EventDispatcher
{
	static var _instance;
	
	var _listeners;

	function EventDispatcher()
	{
	}

	static function initialize(target)
	{
		if (gfx.events.EventDispatcher._instance == undefined) 
		{
			gfx.events.EventDispatcher._instance = new gfx.events.EventDispatcher();
		}
		target.dispatchEvent = gfx.events.EventDispatcher._instance.dispatchEvent;
		target.dispatchQueue = gfx.events.EventDispatcher._instance.dispatchQueue;
		target.hasEventListener = gfx.events.EventDispatcher._instance.hasEventListener;
		target.addEventListener = gfx.events.EventDispatcher._instance.addEventListener;
		target.removeEventListener = gfx.events.EventDispatcher._instance.removeEventListener;
		target.removeAllEventListeners = gfx.events.EventDispatcher._instance.removeAllEventListeners;
		target.cleanUpEvents = gfx.events.EventDispatcher._instance.cleanUpEvents;
		_global.ASSetPropFlags(target, "dispatchQueue", 1);
	}

	static function indexOfListener(listeners, scope, callBack)
	{
		var __reg3 = listeners.length;
		var __reg2 = -1;
		while (++__reg2 < __reg3) 
		{
			var __reg1 = listeners[__reg2];
			if (__reg1.listenerObject == scope && __reg1.listenerFunction == callBack) 
			{
				return __reg2;
			}
		}
		return -1;
	}

	function addEventListener(event, scope, callBack)
	{
		if (this._listeners == undefined) 
		{
			this._listeners = {};
			_global.ASSetPropFlags(this, "_listeners", 1);
		}
		var __reg3 = this._listeners[event];
		if (__reg3 == undefined) 
		{
			this._listeners[event] = __reg3 = [];
		}
		if (gfx.events.EventDispatcher.indexOfListener(__reg3, scope, callBack) == -1) 
		{
			__reg3.push({listenerObject: scope, listenerFunction: callBack});
		}
	}

	function removeEventListener(event, scope, callBack)
	{
		var __reg2 = this._listeners[event];
		if (__reg2 != undefined) 
		{
			var __reg3 = gfx.events.EventDispatcher.indexOfListener(__reg2, scope, callBack);
			if (__reg3 != -1) 
			{
				__reg2.splice(__reg3, 1);
			}
		}
	}

	function dispatchEvent(event)
	{
		if (event.type != "all") 
		{
			if (event.target == undefined) 
			{
				event.target = this;
			}
			this.dispatchQueue(this, event);
		}
	}

	function hasEventListener(event)
	{
		return this._listeners[event] != null && this._listeners[event].length > 0;
	}

	function removeAllEventListeners(event)
	{
		if (event == undefined) 
		{
			delete this._listeners;
			return;
		}
		delete this._listeners[event];
	}

	function dispatchQueue(dispatch, event)
	{
		var __reg1 = dispatch._listeners[event.type];
		if (__reg1 != undefined) 
		{
			gfx.events.EventDispatcher.$dispatchEvent(dispatch, __reg1, event);
		}
		__reg1 = dispatch._listeners.all;
		if (__reg1 != undefined) 
		{
			gfx.events.EventDispatcher.$dispatchEvent(dispatch, __reg1, event);
		}
	}

	static function $dispatchEvent(dispatch, listeners, event)
	{
		var __reg7 = listeners.length;
		var __reg3 = 0;
		for (;;) 
		{
			if (__reg3 >= __reg7) 
			{
				return;
			}
			var __reg1 = listeners[__reg3].listenerObject;
			var __reg5 = typeof __reg1;
			var __reg2 = listeners[__reg3].listenerFunction;
			if (__reg2 == undefined) 
			{
				__reg2 = event.type;
			}
			if (__reg5 == "function") 
			{
				if (__reg1[__reg2] == null) 
				{
					__reg1.apply(dispatch, [event]);
				}
				else 
				{
					__reg1[__reg2](event);
				}
			}
			else if (__reg1.handleEvent != undefined && __reg2 == undefined) 
			{
				__reg1.handleEvent(event);
			}
			else 
			{
				__reg1[__reg2](event);
			}
			++__reg3;
		}
	}

	function cleanUp()
	{
		this.cleanUpEvents();
	}

	function cleanUpEvents()
	{
		this.removeAllEventListeners();
	}

}
