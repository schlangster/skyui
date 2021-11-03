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
//  pressed_raw: (boolean) // extracted from OpenVR ControllerState
//  pressed: (boolean)     // do we consider the widget pressed?
//  touched_raw: (boolean) // extracted from OpenVR ControllerState
//  touched: (boolean)     // do we consider the widget touched?
//
//  // For widgets with associated axis data
//  axisId: (int)          // extracted from OpenVR ControllerState
//  axis: (vec2)           // extracted from OpenVR ControllerState
//
//  type: (string) ["button", // has binary on/off signal
//                  "joystick", // has x,y axis
// 									"touchpad", // has x,y axis & touch
//                  "trigger"], // has x axis
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

import Shared.Platforms;
import skyui.util.Debug;
import skyui.util.GlobalFunctions;

class skyui.VRInput {
	// GLOBALS ---------------------------------------------------------
	static public var initialized = false;

	// What is the name of the controller that corresponds to the
	// current platform
	static public var controllerName: String = "";

	// Stores the right/left hand controller state that we last saw
	static public var lastControllerStates;

	// Stores state of each of the widgets on a controller
	static public var lastWidgetStates;
	static public var widgetStates;


	// CONSTANTS -------------------------------------------------------
	static public var WIDGET_MAX_COUNT = 64;

	// A controller state mirrors OpenVR's ControllerState_t
	//
	// This is the lowest level data we have access to regarding the
	// controller buttons.
	static public function makeEmptyControllerState() {
		return {
			packetNum: 0,
			buttonPressedLow: 0,
			buttonPressedHigh: 0,
			buttonTouchedLow: 0,
			buttonTouchedHigh: 0,
			axis: []
		};
	}

	static public function init() {
		if(!initialized) {
			lastControllerStates = [{}, {}];
			lastWidgetStates = makeEmptyWidgetStates();
			widgetStates = makeEmptyWidgetStates();
		}
		initialized = true;
	}

	static public function makeEmptyWidgetStates() {
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

	static public function controllerNameFromPlatformEnum(platform) {
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

	static public function getAxis(axisArray, idx) {
		return [axisArray[idx*2], axisArray[idx*2+1]];
	}

	static public function updatePlatform(platform: Number) {
		controllerName = controllerNameFromPlatformEnum(platform);
	}

	static public function widgetDetectPhaseChange(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(cur == last)
			return "no-change";
		if(cur && !last)
			return "start";
		else
			return "stop";
	}

	static public function widgetDetectPhaseStart(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(cur && !last)
			return "start";

		return "no-change";
	}

	static public function widgetDetectPhaseStop(curState, lastState, phaseName) {
		var cur = curState[phaseName];
		var last = lastState[phaseName];

		if(!cur && last)
			return "stop";

		return "no-change";
	}

	static public function makeWidgetEvent(curState, lastState, phaseName, eventName) {
		return {
			curState: curState,
			lastState: lastState,
			phaseName: phaseName,
			eventName: eventName
		};
	}

	static public function copyWidgetState(src, dest) {
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

	static public function axisRegion(vec2) {
		var mag = GlobalFunctions.vec2Mag(vec2);
		if(mag <= 0.30)
			return "center";

		return axisQuadrant(vec2);
	}

	static public function updateControllerState(
			timestamp: Number,
			controllerHand: Number, packetNum: Number,
			buttonPressedLow: Number, buttonPressedHigh: Number,
			buttonTouchedLow: Number, buttonTouchedHigh: Number,
			axis: Array): Boolean
	{
		var lastState = lastControllerStates[controllerHand - 1];
		var curState = {
			packetNum: packetNum,
			buttonPressedLow: buttonPressedLow,
			buttonPressedHigh: buttonPressedHigh,
			buttonTouchedLow: buttonTouchedLow,
			buttonTouchedHigh: buttonTouchedHigh,
			axis: axis
		};

		if(lastState.packetNum != curState.packetNum)
		{
			var widgets = widgetStates[controllerHand-1];
			var controllerName = VRInput.controllerName;

			// Only process widgets that we know may actually
			// be updated
			var interestingWidgets;
			switch(controllerName) {
				case "vive":
					interestingWidgets = [1, 2, 32, 33];
					break;
				default:
					interestingWidgets = [];
			}

			// Prepare to receive a new state
			// We're about to get an update on the state of the widget,
			// move the (old) current state of the widget into the last
			// state array.
			//
			// We're just using two arrays to store the previous and
			// current state of the widgets and reusing the objects
			// used to store the information.
			{
				var lastWidgets = lastWidgetStates[controllerHand-1];
				var curWidgets = widgetStates[controllerHand-1];
				for(var i = 0; i < interestingWidgets.length; i++) {
					var id = interestingWidgets[i];
					var temp = lastWidgets[id];
					lastWidgets[id] = curWidgets[id];
					curWidgets[id] = temp;

					copyWidgetState(lastWidgets[id], curWidgets[id]);
				}
			}

			// Update widget states
			for(var i = 0; i < interestingWidgets.length; i++) {
				var id = interestingWidgets[i];
				var mask = 1 << id;
				var state = widgets[id];

				if(id < 32) {
					state.pressed_raw = (buttonPressedLow & mask) == 0 ? false : true;
					state.pressed = state.pressed_raw;
					state.touched_raw = (buttonTouchedLow & mask) == 0 ? false : true;
					state.touched = state.touched_raw;
					state.controllerName = controllerName;
				} else {
					state.pressed_raw = (buttonPressedHigh & mask) == 0 ? false : true;
					state.pressed = state.pressed_raw;
					state.touched_raw = (buttonTouchedHigh & mask) == 0 ? false : true;
					state.touched = state.touched_raw;
					state.controllerName = controllerName;
				}
				delete state["uninitialized"];
			}

			// Wire up additional Vive controller data
			if(controllerName == "vive") {
				widgets[1].widgetName = "application menu";
				widgets[1].type = "button";
				widgetAddClickWhenPressed(widgets[1]);

				widgets[2].widgetName = "grip";
				widgets[2].type = "button";
				widgetAddClickWhenPressed(widgets[2]);


				widgets[32].widgetName = "touchpad";
				widgets[32].type = "touchpad";

				widgets[32].axisId = 0;
				widgets[32].axis = VRInput.getAxis(axis, 0);
				widgetAddClickWhenPressed(widgets[32]);


				widgets[33].widgetName = "trigger";
				widgets[33].type = "trigger";

				widgets[33].axisId = 1;
				widgets[33].axis = VRInput.getAxis(axis, 1);
				widgetAddClickForTrigger(widgets[33]);
				widgetDetectTouchWithAxis(widgets[33]);
			}

			// Generate events as appropriate
			var lastWidgets = lastWidgetStates[controllerHand-1];
			var curWidgets = widgetStates[controllerHand-1];
			var eventQueue = [];
			for(var i = 0; i < interestingWidgets.length; i++)
			{
				var id = interestingWidgets[i];
				var lastState = lastWidgets[id];
				var curState = curWidgets[id];

				if(lastState.uninitialized) {
					copyWidgetState(curState, lastState);
					delete lastState["uninitialized"];
				}

				// Clean up event timestamps if appropriate
				if(curState.touchedStart && curState.touchedStop) {
					/* Debug.log("************ removing touched fields from widget ***********"); */
					/* Debug.dump("before curState", curState, false, 1); */
					delete curState["touchedStart"];
					delete curState["touchedStartState"];
					delete curState["touchedStop"];
					/* Debug.dump("after curState", curState, false, 1); */
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

			// Print out all of the event queue
			if(eventQueue.length > 0)
				Debug.log("packetNum: " + packetNum);
			for(var i = 0; i < eventQueue.length; i++)
			{
				Debug.log("timestamp: " + timestamp);

				var event = eventQueue[i];
				Debug.dump("event " + (i+1), event, false, 1);

				if(event.phaseName == "touched" && event.eventName == "start") {
				}
			}

			vibrateOnSwipe(eventQueue);

			// Record the current state
			// We'll use this as the last state when we're called again the next time.
			lastControllerStates[controllerHand-1] = curState;

			return true;
		}
		return false;
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
	static private function cloneVec2(vec2: Array) {
		return [vec2[0], vec2[1]];
	}

	static private function copyVec2(src: Array, dest: Array) {
		dest[0] = src[0];
		dest[1] = src[1];
		return dest;
	}


	// Widget synthetic attributes -------------------------------------
	//
	// Some widgets may not behave the exact same way we want,
	// these functions can be used to add some synthetic attributes
	// to help bridge these differences.

	static function widgetAddClickWhenPressed(widget)
	{
		if(widget.pressed) {
			widget.clicked = true;
		} else {
			widget.clicked = false;
		}
	}

	static function widgetAddClickForTrigger(widget)
	{
		if(widget.axis[0] == 1) {
			widget.clicked = true;
		} else {
			widget.clicked = false;
		}
	}

	static function widgetDetectTouchWithAxis(widget)
	{
		if(widget.axis[0] != 0.0 || widget.axis[1] != 0.0) {
			widget.touched = true;
		}
	}

	static var touchpadSwipeStates = {
		leftHand: {},
		rightHand: {}
	};
	static function widgetTouchpadDetectSwipe(widget, eventQueue)
	{
		// Given the current state of the widget,
		// generate events if swipes are detected...

		// If the touchpad isn't being touched, do nothing
		if(!widget.touched) {
			return;
		}

		var curTime = clock();

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

	static public function vibrateOnSwipe(eventQueue) {
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
}
