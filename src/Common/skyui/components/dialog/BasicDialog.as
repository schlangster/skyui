import gfx.events.EventDispatcher;
import mx.transitions.Tween;
import mx.transitions.easing.None;
import mx.utils.Delegate;


class skyui.components.dialog.BasicDialog extends MovieClip
{	
  /* CONSTANTS */
  
	public static var OPEN = 0;
	public static var CLOSED = 1;
	public static var OPENING = 2;
	public static var CLOSING = 3;
	
	
  /* PRIVATE VARIABLES */
	
	private var _dialogState: Number = -1;
	private var _fadeTween: Tween;
	
	
  /* INITIALIZATION */
	
	public function BasicDialog()
	{
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
	}
	

  /* PUBLIC FUNCTIONS */
  
	// @mixin by EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function openDialog(): Void
	{
		setDialogState(OPENING);
		
		if (_fadeTween) {
			_fadeTween.stop();
			delete _fadeTween;
		}
		
		_fadeTween = new Tween(this, "_alpha", None.easeNone, 0, 100, 0.4, true);
		_fadeTween.FPS = 40;
		_fadeTween.onMotionFinished = Delegate.create(this, fadedInFunc);
	}
	
	public function closeDialog(): Void
	{
		setDialogState(CLOSING);
		
		if (_fadeTween) {
			_fadeTween.stop();
			delete _fadeTween;
		}
		
		_fadeTween = new Tween(this, "_alpha", None.easeNone, 100, 0, 0.4, true);
		_fadeTween.FPS = 40;
		_fadeTween.onMotionFinished = Delegate.create(this, fadedOutFunc);
	}
	
	public var onDialogOpening: Function;
	
	public var onDialogOpen: Function;
	
	public var onDialogClosing: Function;
	
	public var onDialogClosed: Function;
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setDialogState(a_newState: Number): Void
	{
		if (_dialogState == a_newState)
			return;
			
		_dialogState = a_newState;
		
		if (a_newState == OPENING) {
			if (onDialogOpening)
				onDialogOpening();
			dispatchEvent({type: "dialogOpening"});
			
		} else if (a_newState == OPEN) {
			if (onDialogOpen)
				onDialogOpen();
			dispatchEvent({type: "dialogOpen"});

		} else if (a_newState == CLOSING) {
			if (onDialogClosing)
				onDialogClosing();
			dispatchEvent({type: "dialogClosing"});

		} else if (a_newState == CLOSED) {
			if (onDialogClosed)
				onDialogClosed();
			dispatchEvent({type: "dialogClosed"});
			
			removeAllEventListeners();
			this.removeMovieClip();
		}
	}
	
	private function fadedInFunc()
	{
		setDialogState(BasicDialog.OPEN);
	}
	
	private function fadedOutFunc()
	{
		setDialogState(BasicDialog.CLOSED);
	}
}