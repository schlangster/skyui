import gfx.managers.FocusHandler;
import gfx.events.EventDispatcher;


class skyui.util.DialogManager
{
  /* CONSTANTS */
  
	public static var OPEN = 0;
	public static var CLOSED = 1;
	public static var OPENING = 2;
	public static var CLOSING = 3;
	
	
  /* PRIVATE VARIABLES */
  
	// There can only be one open dialog at a time.
	private static var _activeDialog: MovieClip;
	private static var _previousFocus: Object;
	private static var _closeCallback: Function;
	
	
  /* PUBLIC FUNCTIONS */
	
	public static function createDialog(a_target: MovieClip, a_linkageID: String, a_init: Object): MovieClip
	{
		if (_activeDialog)
			closeDialog();
		
		_previousFocus = FocusHandler.instance.getFocus(0);

		_activeDialog = a_target.attachMovie("ColumnSelectDialog", "dialog", a_target.getNextHighestDepth(), a_init);
		
		EventDispatcher.initialize(_activeDialog);
		
		_activeDialog._dialogState = -1;
		
		_activeDialog.setDialogState = function(a_newState: Number): Void
		{
			if (this._dialogState == a_newState)
				return;
				
			this._dialogState = a_newState;
			
			if (a_newState == OPENING) {
				if (this.onDialogOpening)
					this.onDialogOpening();
				
			} else if (a_newState == OPEN) {
				if (this.onDialogOpen)
					this.onDialogOpen();
				this.dispatchEvent({type: "dialogOpen"});

			} else if (a_newState == CLOSING) {
				if (this.onDialogClosing)
					this.onDialogClosing();

			} else if (a_newState == CLOSED) {
				if (this.onDialogClosed)
					this.onDialogClosed();
				this.dispatchEvent({type: "dialogClosed"});
				
				this.removeAllEventListeners();
				this.removeMovieClip();
			}
		};
		
		FocusHandler.instance.setFocus(_activeDialog, 0);
		
		_activeDialog.setDialogState(OPENING);
		_activeDialog.gotoAndPlay("open");
		
		return _activeDialog;
	}
	
	public static function closeDialog(): Void
	{
		FocusHandler.instance.setFocus(_previousFocus, 0);
		
		_activeDialog.setDialogState(CLOSING);
		_activeDialog.gotoAndPlay("close");
		_activeDialog = null;
	}
}