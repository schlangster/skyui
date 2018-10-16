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
//  controllerRole: (string) ["right-hand", "left-hand"],
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

import mx.utils.ObjectUtil;
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

	static public function widgetStateLooksEmpty(state) {
		return state.length <= 2;
	}

	static public function makeEmptyWidgetStates() {
		var widgetStates = [[], []];

		for(var i = 0; i < WIDGET_MAX_COUNT; i++) {
			widgetStates[0].push({
				id: i,
				controllerRole: "left-hand",
				uninitialized: true
			});
		}

		for(var i = 0; i < WIDGET_MAX_COUNT; i++) {
			widgetStates[1].push({
			id: i,
			controllerRole: "right-hand",
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
		for (var i = 0; i < src.axis.length; i++) {
			dest.axis[i][0] = src.axis[i][0];
			dest.axis[i][1] = src.axis[i][1];
		}
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
						eventQueue.push(event);
					}
				}
				phases = ["clicked", "pressed", "touched"];
				for(var j = 0; j < phases.length; j++) {
					var phase = phases[j];
					var change = widgetDetectPhaseStop(curState, lastState, phase);
					if(change != "no-change") {
						var event = makeWidgetEvent(curState, lastState, phase, change);
						eventQueue.push(event);
					}
				}
			}

			if(eventQueue.length > 0)
				Debug.log("packetNum: " + packetNum);
			for(var i = 0; i < eventQueue.length; i++)
			{
				Debug.dump("event", eventQueue[i], false, 1);
			}

			// Record the current state
			// We'll use this as the last state when we're called again the next time.
			lastControllerStates[controllerHand-1] = curState;

			return true;
		}
		return false;
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
}
