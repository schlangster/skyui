import gfx.managers.FocusHandler;
import gfx.events.EventDispatcher;
import skyui.components.dialog.BasicDialog;


class skyui.util.DialogManager
{
	
  /* PRIVATE VARIABLES */
  
	// There can only be one open dialog at a time.
	private static var _activeDialog: BasicDialog;
	private static var _previousFocus: Object;
	private static var _closeCallback: Function;
	
	
  /* PUBLIC FUNCTIONS */
	
	public static function open(a_target: MovieClip, a_linkageID: String, a_init: Object): MovieClip
	{
		if (_activeDialog)
			close();
		
		_previousFocus = FocusHandler.instance.getFocus(0);

		_activeDialog = BasicDialog(a_target.attachMovie(a_linkageID, "dialog", a_target.getNextHighestDepth(), a_init));
		FocusHandler.instance.setFocus(_activeDialog, 0);
		
		_activeDialog.openDialog();
		
		return _activeDialog;
	}
	
	public static function close(): Void
	{
		FocusHandler.instance.setFocus(_previousFocus, 0);
		
		_activeDialog.closeDialog();
		_activeDialog = null;
	}
}