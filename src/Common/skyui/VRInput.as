// The VRInput class is a namespace that holds all functions related
// to construction, manipulation, transformation of OpenVR's
// ControllerState_t into something meaningful and usable by the UI
//
// OpenVR gives us a few pieces of data that are packed into bit flags.
// However, in an UI, we want to know which widgets are manpulated and
// *how* they are being manipulated.
//
// What we really need is to unpack the bitfields into something that is
// reasonable for the UI to work with.
//
// Something like this looks pretty reasonable:
// {
//  id: (int) [0-64],      // OpenVR id for the widget
//  pressed: (boolean)     // do we consider the widget pressed?
//  touched: (boolean)     // do we consider the widget touched?
//
//  // For widgets with associated axis data
//  axisId: (int)          // extracted from OpenVR ControllerState
//  axis: (vec2)           // extracted from OpenVR ControllerState
//
//  type: (string) ["button",     // has binary on/off signal
//                  "thumbstick", // has x,y axis
// 									"touchpad",   // has x,y axis & touch
//                  "trigger"],   // has x axis
//
//  // Added annotation
//  widgetName: (string), // name of button or axis
//  controllerName: (string) ["vive", "knuckles", "oculus", "wmr"],
//  controllerRole: (string) ["rightHand", "leftHand"],
//
//  pressStartTime: clock time when the event started
//  touchStartTime: clock time when the event started
//
//  eventType: string "up"/"down"/"repeat"
//
//  action: (string), // probable intended action
//  }
//
//  The rough processing steps should be:
//  raw controller state data =>
//  add annotation =>
//  generate event obj =>
//  dispatch event for processing

import gfx.managers.FocusHandler;
import Shared.Platforms;
import skyui.util.Debug;
import skyui.util.GlobalFunctions;

class skyui.VRInput {
	// GLOBALS ---------------------------------------------------------
	public var initialized = false;

	// What is the name of the controller that corresponds to the
	// current platform
	public var controllerName_Game: String = "";      // Controller name reported by the game
	public var controllerName_OpenVR: String = "";    // Controller name reported by OpenVR
	public var controllerName: String = "";           // Internal logic will cue off of this

	// Stores the right/left hand controller state that we last saw
	public var lastControllerStates;

	// Stores state of each of the widgets on a controller
	public var lastWidgetStates;
	public var widgetStates;

	public var ignoreInput = false;

	public var errorPrintedFlags = {};

	// CONSTANTS -------------------------------------------------------
	static public var WIDGET_MAX_COUNT = 64;

	// A controller state mirrors OpenVR's ControllerState_t
	//
	// This is the lowest level data we have access to regarding the
	// controller buttons.
	public function makeEmptyControllerState() {
		return {
			packetNum: 0,
			buttonPressedLow: 0,
			buttonPressedHigh: 0,
			buttonTouchedLow: 0,
			buttonTouchedHigh: 0,
			axis: []
		};
	}

	private function init() {
		if(!initialized) {
			lastControllerStates = [{}, {}];
			lastWidgetStates = makeEmptyWidgetStates();
			widgetStates = makeEmptyWidgetStates();
		}
		initialized = true;
	}

	public function makeEmptyWidgetStates() {
		var widgetStates = [[], []];

		for(var i = 0; i < WIDGET_MAX_COUNT; i++) {
			widgetStates[0].push({
				id: i,
				controllerRole: "leftHand",
				axis: [],
				uninitialized: true
			});
		}

		for(var i = 0; i < WIDGET_MAX_COUNT; i++) {
			widgetStates[1].push({
			id: i,
			controllerRole: "rightHand",
			axis: [],
			uninitialized: true
			});
		}

		return widgetStates;
	}

	public function controllerNameFromPlatformEnum(platform) {
		switch(platform) {
			case Platforms.CONTROLLER_VIVE:
				return "vive";
   		case Platforms.CONTROLLER_ORBIS_MOVE:
   			return "orbis";
   		case Platforms.CONTROLLER_OCULUS:
   			return "oculus";
   		case Platforms.CONTROLLER_VIVE_KNUCKLES:
   			return "knuckles";
   		case Platforms.CONTROLLER_WINDOWS_MR:
   			return "wmr";
   		default:
   			return "unknown";
		}
	}

	public function controllerNameFromOpenVRName(name) {
		switch(name){
			case "vive_controller":
  			return "vive";
			case "knuckles":
  			return "knuckles";
			default:
  			return "unknown";
		}
		//return "knuckles";
	}

	public function getAxis(axisArray, idx) {
		return [axisArray[idx*2], axisArray[idx*2+1]];
	}

	public function updatePlatform(platform: Number) {
		//Debug.log("VRInput.updatePlatform: " + platform);
		controllerName_Game = controllerNameFromPlatformEnum(platform);
		controllerName_OpenVR = skse["plugins"]["skyui"].ControllerType();

		//Debug.log("[skyui] controllerName_Game: " + controllerName_Game);
		//Debug.log("[skyui] controllerName_OpenVR: " + controllerName_OpenVR);

		// We'll prefer controller type reported by OpenVR over the game engine
		// The game doesn't know how to deal with the index controller.
		var name = controllerNameFromOpenVRName(controllerName_OpenVR);
		//Debug.log("[skyui] OpenVR mapped name: " + name);
		if (name != "unknown")
			controllerName = name;
		else
			controllerName = controllerName_Game;

		Debug.log("[skyui] controllerName: " + controllerName);
	}

	public function widgetDetectPhaseChange(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(cur == last)
			return "no-change";
		if(cur && !last)
			return "start";
		else
			return "stop";
	}

	public function widgetDetectPhaseStart(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(cur && !last)
			return "start";

		return "no-change";
	}

	public function widgetDetectPhaseStop(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(!cur && last)
			return "stop";

		return "no-change";
	}

	public function makeWidgetEvent(curState, lastState, phaseName, eventName) {
		return {
			curState: curState,
			lastState: lastState,
			phaseName: phaseName,
			eventName: eventName
		};
	}

	public function copyWidgetState(src, dest) {
		for (var key:String in src) {
			if(key != "axis")
				dest[key] = src[key];
		}
		if(!dest.axis) {
			dest.axis = [];
		}
		dest.axis[0] = src.axis[0];
		dest.axis[1] = src.axis[1];
		return dest;
	}

	static public function axisQuadrant(vec2) {
		var angle = GlobalFunctions.vec2Angle(vec2);
		if (angle < 0)
			angle += 360;

		if(angle < 45)
			return "right";
		if(angle < 135)
			return "top";
		if(angle < 225)
			return "left";
		if(angle < 315)
			return "bottom";
		return "right";
	}

	static function axisRegion(vec2) {
		var mag = GlobalFunctions.vec2Mag(vec2);
		if(mag <= 0.30)
			return "center";

		return axisQuadrant(vec2);
	}

	public function interestingWidgetIdxs() {
			switch(controllerName) {
				case "vive":
					return [1, 2, 32, 33];
					break;
				case "knuckles":
					return [1, 2, 7, 32, 33, 34];
					break;
				default:
					if(!errorPrintedFlags["unknown-controller"]) {
						Debug.log("unknown controller: " + controllerName);
						Debug.log("controllerName_Game: " + controllerName_Game);
						Debug.log("controllerName_OpenVR: " + controllerName_OpenVR);
						Debug.log("controllerName: " + controllerName);
						errorPrintedFlags["unknown-controller"] = true;
					}
					return [1, 2, 32, 33];
			}
	}

	// Given the new controller state, perform some upkeep and generate
	// an array of "interesting" events.
	public function updateControllerState(
			timestamp: Number,
			controllerHand: Number, packetNum: Number,
			buttonPressedLow: Number, buttonPressedHigh: Number,
			buttonTouchedLow: Number, buttonTouchedHigh: Number,
			axis: Array): Array
	{
		var handIdx = controllerHand-1;
		var lastButtonState = lastControllerStates[handIdx];
		var curButtonState = {
			packetNum: packetNum,
			buttonPressedLow: buttonPressedLow,
			buttonPressedHigh: buttonPressedHigh,
			buttonTouchedLow: buttonTouchedLow,
			buttonTouchedHigh: buttonTouchedHigh,
			axis: axis
		};

		var eventQueue = [];
		if(lastButtonState.packetNum != curButtonState.packetNum)
		{
			//Debug.log("packetNum: " + lastButtonState.packetNum + " => " + curButtonState.packetNum);

			// Only process widgets that we know may actually be updated
			var widgetIdxs = interestingWidgetIdxs();

			// Prepare to receive a new state
			// We're about to get an update on the state of the widget,
			// move the (old) current state of the widget into the last
			// state array.
			//
			// We're just using two arrays to store the previous and
			// current state of the widgets and reusing the objects
			// used to store the information.
			{
				var lastWidgets = lastWidgetStates[handIdx];
				var curWidgets = widgetStates[handIdx];
				for(var i = 0; i < widgetIdxs.length; i++) {
					var id = widgetIdxs[i];
					var temp = lastWidgets[id];
					lastWidgets[id] = curWidgets[id];
					curWidgets[id] = temp;

					copyWidgetState(lastWidgets[id], curWidgets[id]);
				}
			}

			// Update widget states
			var widgets = widgetStates[handIdx];
			for(var i = 0; i < widgetIdxs.length; i++) {
				var id = widgetIdxs[i];
				var mask = 1 << id;
				var state = widgets[id];

				if(id < 32) {
					state.pressed = (buttonPressedLow & mask) == 0 ? false : true;
					state.touched = (buttonTouchedLow & mask) == 0 ? false : true;
					state.controllerName = controllerName;
				} else {
					state.pressed = (buttonPressedHigh & mask) == 0 ? false : true;
					state.touched = (buttonTouchedHigh & mask) == 0 ? false : true;
					state.controllerName = controllerName;
				}
				delete state["uninitialized"];
			}

			// Wire up additional Vive controller data

			switch(controllerName) {
				case "vive":
					widgets[1].widgetName = "application menu";
					widgets[1].type = "button";
					widgetAddClickWhenPressed(widgets[1]);

					widgets[2].widgetName = "grip";
					widgets[2].type = "button";
					widgetAddClickWhenPressed(widgets[2]);

					widgets[32].widgetName = "touchpad";
					widgets[32].type = "touchpad";

					widgets[32].axisId = 0;
					widgets[32].axis = getAxis(axis, 0);
					widgetAddClickWhenPressed(widgets[32]);

					widgets[33].widgetName = "trigger";
					widgets[33].type = "trigger";

					widgets[33].axisId = 1;
					widgets[33].axis = getAxis(axis, 1);
					widgetAddClickForTrigger(widgets[33]);
					widgetDetectTouchWithAxis(widgets[33]);
					break;

				case "knuckles":
					widgets[1].widgetName = "B button";
					widgets[1].type = "button";
					widgetAddClickWhenPressed(widgets[1]);

					widgets[2].widgetName = "grip";
					widgets[2].type = "button";
					widgets[2].axisId = 2;
					widgets[2].axis = getAxis(axis, 2);
					widgetAddClickWhenPressed(widgets[2]);

					widgets[7].widgetName = "A button";
					widgets[7].type = "button";
					widgetAddClickWhenPressed(widgets[7]);

					widgets[32].widgetName = "thumbstick";
					widgets[32].type = "thumbstick";
					widgets[32].axisId = 0;
					widgets[32].axis = getAxis(axis, 0);
					widgetAddClickWhenPressed(widgets[32]);

					widgets[33].widgetName = "trigger";
					widgets[33].type = "trigger";
					widgets[33].axisId = 1;
					widgets[33].axis = getAxis(axis, 1);
					widgetAddClickForTrigger(widgets[33]);
					widgetDetectTouchWithAxis(widgets[33]);

					widgets[34].widgetName = "fingers";
					widgets[34].type = "button";
					break;
			}

			// Generate events as appropriate
			var lastWidgets = lastWidgetStates[handIdx];
			var curWidgets = widgetStates[handIdx];
			for(var i = 0; i < widgetIdxs.length; i++)
			{
				var id = widgetIdxs[i];
				var lastState = lastWidgets[id];
				var curState = curWidgets[id];

				if(lastState.uninitialized) {
					copyWidgetState(curState, lastState);
					delete lastState["uninitialized"];
				}

				// Clean up event timestamps if appropriate
				if(curState.touchedStart && curState.touchedStop) {
					delete curState["touchedStart"];
					delete curState["touchedStartState"];
					delete curState["touchedStop"];
				}
				if(curState.pressedStart && curState.pressedStop) {
					delete curState["pressedStart"];
					delete curState["pressedStartState"];
					delete curState["pressedStop"];
				}
				if(curState.clickedStart && curState.clickedStop) {
					delete curState["clickedStart"];
					delete curState["clickedStartState"];
					delete curState["clickedStop"];
				}

				// Detect and generate phase events
				// Note that we take a bit of effort to make sure that the start/stop
				// events are ordered like this:
				//   touched start => pressed start => clicked start =>
				//   clicked end => pressed end => touched end
				var phases;

				phases = ["touched", "pressed", "clicked"];
				for(var j = 0; j < phases.length; j++) {
					var phase = phases[j];
					var change = widgetDetectPhaseStart(curState, lastState, phase);
					if(change != "no-change") {
						var event = makeWidgetEvent(curState, lastState, phase, change);
						curState[phase + "Start"] = timestamp;
						curState[phase + "StartState"] = copyWidgetState(curState, {});
						eventQueue.push(event);
					}
				}
				phases = ["clicked", "pressed", "touched"];
				for(var j = 0; j < phases.length; j++) {
					var phase = phases[j];
					var change = widgetDetectPhaseStop(curState, lastState, phase);
					if(change != "no-change") {
						var event = makeWidgetEvent(curState, lastState, phase, change);
						curState[phase + "Stop"] = timestamp;
						eventQueue.push(event);
					}
				}
			}

			// Generate other synthetic events
			// By reading the event queue
			if(controllerName == "vive") {
				widgetTouchpadDetectSwipe(widgets[32], eventQueue);
			}

			// Record the current state
			// We'll use this as the last state when we're called again the next time.
			lastControllerStates[handIdx] = curButtonState;
			/*
			Debug.log("handIdx " + handIdx);
			Debug.dump("lastControllerStates[handIdx]", lastControllerStates[handIdx]);
			*/
		}
		return eventQueue;
	}

	//----------------------------------------------------------------------------
	// Native function interop
	//

	// Return a timestamp with millisecond resolution.
	static private function clock(): Number {
		// We're sure the VRInput plugin is available.
		// Just call the clock function.
		return skse["plugins"]["vrinput"].GetClock();
	}

	static private function triggerHapticPulse(controllerRole: String, strength: Number) {
		skse["plugins"]["vrinput"].TriggerHapticPulse(controllerRole == "leftHand" ? 1 : 2, strength);
	}


	//----------------------------------------------------------------------------
	// Vec2 utilities
	//
	private function cloneVec2(vec2: Array) {
		return [vec2[0], vec2[1]];
	}

	private function copyVec2(src: Array, dest: Array) {
		dest[0] = src[0];
		dest[1] = src[1];
		return dest;
	}


	// Widget synthetic attributes -------------------------------------
	//
	// Some widgets may not behave the exact same way we want,
	// these functions can be used to add some synthetic attributes
	// to help bridge these differences.

	function widgetAddClickWhenPressed(widget)
	{
		if(widget.pressed) {
			widget.clicked = true;
		} else {
			widget.clicked = false;
		}
	}

	function widgetAddClickForTrigger(widget)
	{
		if(widget.axis[0] == 1) {
			widget.clicked = true;
		} else {
			widget.clicked = false;
		}
	}

	function widgetDetectTouchWithAxis(widget)
	{
		if(widget.axis[0] != 0.0 || widget.axis[1] != 0.0) {
			widget.touched = true;
		}
	}

	var touchpadSwipeStates = {
		leftHand: {},
		rightHand: {}
	};

	function widgetTouchpadDetectSwipe(widget, eventQueue)
	{
		// Given the current state of the widget,
		// generate events if swipes are detected...

		// If the touchpad isn't being touched, do nothing
		if(!widget.touched) {
			return;
		}

		var curTime = getTimer();

		// Fetch the swipe state associated with the widget
		var hand = touchpadSwipeStates[widget.controllerRole];
		var swipeState = hand[widget.id];

		// Are we hanging on to state data from a previous swipe?
		// If so, clean it up now...
		if(widget.touchedStart && swipeState.startTime != widget.touchedStart) {
			delete touchpadSwipeStates[widget.controllerRole][widget.id];
			swipeState = undefined;
		}

		// If we don't have a swipe state either because no data
		// has been associated with said widget or because associated
		// state has been cleaned up...
		// Create empty state to hold the swipe state
		if(!swipeState) {
			swipeState = {
				startTime: widget.touchedStart,
				lastProcessTime: curTime,
				lastPosition: cloneVec2(widget.axis)
			};
			touchpadSwipeStates[widget.controllerRole][widget.id] = swipeState;
		}

		// Limit the rate at which events can be generated
		var timeDelta = curTime - swipeState.lastProcessTime;
		var curPosition = widget.axis;
		var lastPosition = swipeState.lastPosition
		var xDelta = curPosition[0] - lastPosition[0];
		var yDelta = curPosition[1] - lastPosition[1];
		var distanceDelta = Math.sqrt((xDelta * xDelta) + (yDelta * yDelta));
		var velocity = distanceDelta / timeDelta;

		var distanceThreshold;
		var timeThreshold;
		var savePosition;
		var velThreshold = 0.16;
		if(velocity > 0.005) {
			distanceThreshold = 0.1;
			timeThreshold = 10;
			savePosition = false;
		} else {
			distanceThreshold = 0.33;
			timeThreshold = 10;
			savePosition = false;
		}

		// FIXME!!! Event firing frequency is tied directly to the framerate.
		if(timeDelta < timeThreshold) {
			return;
		}

		// If the touchpad position moved a certain distance
		// within the alotted period of time...
		// Generate an appropriate event.

		// We'e going to restrict swiping to up/down/right/left
		// First, determine which direction has received more movement...
		// That is the dominate axis
		var eventFired = false;
		if(Math.abs(xDelta) > Math.abs(yDelta)) {
			if(xDelta > distanceThreshold) {
				eventQueue.push({
					eventType: "swipe",
					direction: "right",
					widget: widget
				});
				eventFired = true;
			} else if(xDelta < -1 * distanceThreshold) {
				eventQueue.push({
					eventType: "swipe",
					direction: "left",
					widget: widget
				});
				eventFired = true;
			}
		} else {
			if(yDelta > distanceThreshold) {
				eventQueue.push({
					eventType: "swipe",
					direction: "up",
					widget: widget
				});
				eventFired = true;
			} else if(yDelta < -1 * distanceThreshold) {
				eventQueue.push({
					eventType: "swipe",
					direction: "down",
					widget: widget
				});
				eventFired = true;
			}
		}

		// Only update the last position and processing time
		// if an event actually fired.
		//
		// This means that as long as the user has traveled
		// a specific distance on the touchpad, the swipe
		// will be registered.
		//
		// This emulates the behavior of the game. Though
		// it isn't ideal, it will do for now.
		if(eventFired) {
			copyVec2(widget.axis, swipeState.lastPosition);
			swipeState.lastProcessTime = curTime;
		}
	}

	public function vibrateOnSwipe(eventQueue) {
		// Look a swipe event in the event queue
		// If found, vibrate the corresponding controller...
		for(var i = 0; i < eventQueue.length; i++) {
			var event = eventQueue[i];
			if(event.eventType == "swipe") {
				triggerHapticPulse(event.widget.controllerRole, 0.25);
				break;
			}
		}
	}

	// Refactor? Do we really still need this function?
	// Is this serving the same role as `handleVRButtonUpdates`?
	public function getInputEvents(
			timestamp: Number,
			controllerHand: Number, packetNum: Number,
			buttonPressedLow: Number, buttonPressedHigh: Number,
			buttonTouchedLow: Number, buttonTouchedHigh: Number,
			axis: Array): Array
	{
		var eventQueue = updateControllerState(
				timestamp,
				controllerHand, packetNum,
				buttonPressedLow, buttonPressedHigh,
				buttonTouchedLow, buttonTouchedHigh,
				axis);

		vibrateOnSwipe(eventQueue);

		return eventQueue;
	}

	function getFocusPath() {
		// Skyrim is a single player game. So technically, we're only dealing with "one controller"
		return FocusHandler.instance.getPathToFocus(Selection.getControllerFocusGroup(0));
	}

	function handleVRButtonUpdate(
			controllerHand: Number, packetNum: Number,
			buttonPressedLow: Number, buttonPressedHigh: Number,
			buttonTouchedLow: Number, buttonTouchedHigh: Number,
			axis: Array)
	{
		//Debug.log(">>> VRInput handleVRButtonUpdate");

		// Should we update any button states at all?
		// This is useful for ignorning inputs when we're supposed to be
		// blocking, waiting for the OpenVR virtual keyboard.
		if(ignoreInput)
			return;

		var timestamp = getTimer();
		var eventQueue = getInputEvents(
				timestamp,
				controllerHand, packetNum,
				buttonPressedLow, buttonPressedHigh,
				buttonTouchedLow, buttonTouchedHigh,
				axis);

		var update = {
			timestamp: timestamp,
			controllerHand: controllerHand,
			packetNum: packetNum,
			buttonPressedLow: buttonPressedLow,
			buttonPressedHigh: buttonPressedHigh,
			buttonTouchedLow: buttonTouchedLow,
			buttonTouchedHigh: buttonTouchedHigh,
			axis: axis
		}

		var stateText = controllerStateText(update, true);
		//if(stateText.length != 0) {
		//	Debug.log("-- Button states --");
		//	Debug.log(stateText);
		//}

		var focusPath = getFocusPath();
		//if(eventQueue.length != 0) {
		//	Debug.log("focusPath: " + focusPath);
		//	Debug.dump("eventQueue", eventQueue);
		//}


		dispatchButtonUpdates(update, focusPath);
		dispatchInputEvents(eventQueue, focusPath);

		//Debug.log("<<< VRInput handleVRButtonUpdate");
	}

	public function dispatchButtonUpdates(update, focusPath: Array) {
		if(focusPath == null)
			focusPath = getFocusPath();

		for(var i = 0; i < focusPath.length; i++) {
			var obj = focusPath[i];
			if(obj.handleVRButtonUpdate != null) {
				obj.handleVRButtonUpdate(update);
			}
		}
	}

	public function dispatchInputEvents(eventQueue: Array, focusPath: Array) {
		if(focusPath == null)
			focusPath = getFocusPath();

		// Take every event in the queue
		for(var ei = 0; ei < eventQueue.length; ei++) {
			var event = eventQueue[ei];
			//if(ei == 0) {
			//	Debug.log("dispatchInputEvents");
			//	Debug.dump("focusPath", focusPath);
			//}
			//Debug.log("Dispatching event: " + ei);

			// Send the event to the "handleVRInput" function of every object in the focus path
			for(var fi = 0; fi < focusPath.length; fi++) {
				var obj = focusPath[fi];
				if(obj.handleVRInput != null) {
					//Debug.log("focusPath: " + fi + " " + obj);
					//if(obj.classname != null)
					//	Debug.log("" + fi + ": " + obj.classname());

					// An object may signal that it has already handled the event and stop the event
					// from going further in the focus path.
					var stop = obj.handleVRInput(event);
					if(stop)
						break;
				}
			}
		}
	}

	function controllerStateText(update, printFlags): String {
		var output:String = "";
		var lastLength = output.length;

		for(var i = 0; i < 32; i++)
		{
			var mask = 1 << i;

			if(update.buttonPressedLow & mask) {
				output += "pressed: " + i + "\n";
			}
		}

		if(printFlags && lastLength != output.length){
			output += "buttonPressedLow: " + update.buttonPressedLow + "\n";
			lastLength = output.length;
		}

		for(var i = 0; i < 32; i++)
		{
			var mask = 1 << i;

			if(update.buttonPressedHigh & mask) {
				output += "pressed: " + (i + 32) + "\n";
			}
		}

		if(printFlags && lastLength != output.length){
			output += "buttonPressedHigh: " + update.buttonPressedHigh + "\n";
			lastLength = output.length;
		}

		for(var i = 0; i < 32; i++)
		{
			var mask = 1 << i;

			if(update.buttonTouchedLow & mask) {
				output += "touched: " + i + "\n";
			}
		}

		if(printFlags && lastLength != output.length){
			output += "buttonTouchedLow: " + update.buttonTouchedLow + "\n";
			lastLength = output.length;
		}

		for(var i = 0; i < 32; i++)
		{
			var mask = 1 << i;

			if(update.buttonTouchedHigh & mask) {
				output += "touched: " + (i + 32) + "\n";
			}
		}

		if(printFlags && lastLength != output.length){
			output += "buttonTouchedHigh: " + update.buttonTouchedHigh + "\n";
			lastLength = output.length;
		}

		for(var i = 0; i < 5; i++)
		{
			var x = update.axis[i*2];
			var y = update.axis[i*2 + 1];

			if(x != 0.0) {
				output += "x[" + i + "] = " + x + "\n";
			}
			if(y != 0.0) {
				output += "y[" + i + "] = " + y + "\n";
			}

			if(x != 0.0 || y != 0.0) {
				var vec2 = [x, y];
				output += "mag: " + GlobalFunctions.vec2Mag(vec2) + "\n";
				output += "quadrant: " + axisQuadrant(vec2) + "\n";
				output += "region: " + axisRegion(vec2) + "\n";
			}
		}
		return output;
	}

	function widgetToString(widget: Object): String
	{
		var output = "";
		for (var key:String in widget) {
			output += key + ": " + widget[key] + "\n";
		}
		return output;
	}

	// Build a list of widgets with interesting states
	function collectInterestingWidgets(handIdx): Array {
		var idxs = interestingWidgetIdxs();
		var result = [];
		var widgets = widgetStates[handIdx];
		for(var i = 0; i < idxs.length; i++) {
			var widget = widgets[idxs[i]];
			if(widget.pressed || widget.touched || GlobalFunctions.vec2Mag(widget.axis)) {
				result.push(widget);
			}
		}
		return result;
	}

	var controllerTexts = ["", ""];
	function controllerStateString(update): String
	{
		// Output all text prepared for each hand
		var handIdx = update.controllerHand-1
		var text = controllerStateText(update);
		controllerTexts[handIdx] = text;

		var collectedWidgets = collectInterestingWidgets(handIdx);

		// Build a string representation of all interesting widgets
		var widgetText = "";
		for(var i = 0; i < collectedWidgets.length; i++) {
			var widget = collectedWidgets[i];
			widgetText += widgetToString(widget);
		}

		// Append widget text to the output for the cooresponding hand
		if(widgetText.length != 0)
			controllerTexts[handIdx] += "\n" + widgetText;

		var output = "";

		if(controllerTexts[0].length != 0 || controllerTexts[1].length != 0) {
			output += "Skryim says: " + controllerName_Game + "\n";
			output += "OpenVR says: " + controllerName_OpenVR + "\n";
			output += "Skyui will use: " + controllerName + "\n";
			output += "\n";
		}
		if(controllerTexts[0].length != 0) {
			output += "Left controller:   \n";
			output += controllerTexts[0];
		}
		if(controllerTexts[1].length != 0) {
			output += "Right controller:   \n";
			output += controllerTexts[1];
		}

		return output;
	}


	private static var _instance: VRInput;

	public static function get instance(): VRInput
	{
		if (_instance == null)
			_instance = new VRInput();

		return _instance;
	}

	private function VRInput() {
		init();
	}

	function setup() {
		Debug.log("VRInput.setup()");
		var skyui = skse["plugins"]["skyui"];
		if(skyui != undefined)
		{
			Debug.log("Registering to receive VR input");
			skyui.RegisterInputHandler(this, "handleVRButtonUpdate");
		} else {
			Debug.log("skyui plugin not available");
		}
	}

	function teardown() {
		Debug.log("VRInput.teardown()");
		var skyui = skse["plugins"]["skyui"];
		if(skyui != undefined)
		{
			Debug.log("Unregistering to receive VR input");
			skyui.UnregisterInputHandler(this, "handleVRButtonUpdate");
		}
	}


	function pauseInput(type) {
		switch(type) {
			case "self":
				ignoreInput = true;
				break;
			case "game":
				skse["plugins"]["vrinput"].ShutoffButtonEventsToGame(true);
				break;
			case "all":
				pauseInput("game");
				pauseInput("self");
				break;
		}
	}

	function resumeInput(type) {
		switch(type) {
			case "self":
				ignoreInput = false;
				break;
			case "game":
				skse["plugins"]["vrinput"].ShutoffButtonEventsToGame(false);
				break;
			case "all":
				resumeInput("game");
				resumeInput("self");
				break;
		}
	}

}
