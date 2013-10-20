import skyui.util.GlobalFunctions;
import uilib_2.Messages;

class uilib_2.NotificationArea extends MovieClip
{
  /* CONSTANTS */
	
	public static var UILIB_VERSION: Number = 1;
  

  /* STAGE ELEMENTS */
  
	public var messageHolder: Messages;
	

  /* INITIALIZATION */
	
	public function NotificationArea()
	{
		super();
		GlobalFunctions.addArrayFunctions();
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function onLoad(): Void
	{
		// Place it next to the original messages block
		messageHolder._x = _root.HUDMovieBaseInstance.MessagesBlock._x + 100;
		messageHolder._y = _root.HUDMovieBaseInstance.MessagesBlock._y + 100;
		
		_root.HUDMovieBaseInstance.HudElements.push(messageHolder);
		
		// Set visiblity of new message holder
		messageHolder.All = true;
		messageHolder.Favor = true;
		messageHolder.InventoryMode = true;
		messageHolder.TweenMode = true;
		messageHolder.BookMode = true;
		messageHolder.DialogueMode = true;
		messageHolder.BarterMode = true;
		messageHolder.WorldMapMode = true;
		messageHolder.MovementDisabled = true;
		messageHolder.StealthMode = true;
		messageHolder.Swimming = true;
		messageHolder.HorseMode = true;
		messageHolder.WarHorseMode = true;
		messageHolder.CartMode = true;
		
		var hudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		messageHolder._visible = messageHolder.hasOwnProperty(hudMode);
		
		GlobalFunctions.hookFunction(_root.HUDMovieBaseInstance, "ShowMessage", this, "Hook_ShowMessage");
		GlobalFunctions.hookFunction(_root.HUDMovieBaseInstance.MessagesInstance, "Update", this, "Hook_Update");
	}
	
	function ShowMessage(asMessage: String): Void
	{
		messageHolder.MessageArray.push(asMessage);
	}
	
	function Hook_ShowMessage(asMessage: String): Void
	{
		messageHolder.MessageArray.push("Hooked: " + asMessage);
	}
	
	function Hook_Update(): Void
	{
		messageHolder.Update();
	}
}