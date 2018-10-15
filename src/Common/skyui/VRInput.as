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

class skyui.VRInput {
	// GLOBALS ---------------------------------------------------------
	static public var Platform: String = "";

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

	static public function makeEmptyInputWidgetStates() {
		var inputWidgetStates = [[], []];

		for(var i = 0; i < VRInput.WIDGET_MAX_COUNT; i++) {
			inputWidgetStates[0].push({
				id: i,
				controllerRole: "left-hand"
			});
		}
		for(var i = 0; i < VRInput.WIDGET_MAX_COUNT; i++) {
			inputWidgetStates[1].push({
			id: i,
			controllerRole: "right-hand"
			});
		}

		return inputWidgetStates;
	}

	static public function platformNameFromEnum(platform) {
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
		return "unknown";
	}

	static public function getAxis(axisArray, idx) {
		return [axisArray[idx*2], axisArray[idx*2+1]];
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
