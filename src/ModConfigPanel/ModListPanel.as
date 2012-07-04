import mx.transitions.Tween;
import mx.transitions.easing.Strong;
import mx.utils.Delegate;
import skyui.components.list.ScrollingList;


class ModListPanel extends MovieClip
{
  /* CONSTANTS */
	
	private var INIT = 0;
	private var LIST_ACTIVE = 1;
	private var SUBLIST_ACTIVE = 2;
	private var TRANSITION_TO_SUBLIST = 3;
	private var TRANSITION_TO_LIST = 4;
	
	private var ANIM_LIST_FADE_OUT = 0;
	private var ANIM_LIST_FADE_IN = 1;
	private var ANIM_SUBLIST_FADE_OUT = 2;
	private var ANIM_SUBLIST_FADE_IN = 3;
	private var ANIM_DECORTITLE_FADE_OUT = 4;
	private var ANIM_DECORTITLE_FADE_IN = 5;
	private var ANIM_DECORTITLE_TWEEN = 6;
	
	
  /* PRIVATE VARIABLES */
	
	private var _state: Number = INIT;
	private var _transitionPhase: Number = 0;

	private var _titleText : String;


  /* STAGE ELEMENTS */
	
	public var decorTop: MovieClip;
	public var decorTitle: MovieClip;
	public var decorBottom: MovieClip;
	
	public var _modList: ScrollingList;
	public var _subList: ScrollingList;
	
	public var modListFader: MovieClip;
	public var subListFader: MovieClip;
	
	
  /* CONSTRUCTOR */
  
	public function ModListPanel()
	{
		_modList = modListFader.list;
		_subList = subListFader.list;
	}
	
	
  /* PUBLIC FUNCTIONS */
  

	

  /* PUBLIC FUNCTIONS */
	
	// @override MovieClip
	public function onLoad(): Void
	{
		showList();
	}
  
	public function showList(): Void
	{
		if (_state == SUBLIST_ACTIVE) {
			decorTitle.gotoAndPlay("fadeOut");
			subListFader.gotoAndPlay("fadeOut");
			_state = TRANSITION_TO_LIST;
			
		} else {
			hideDecorTitle(true);
			
			modListFader.gotoAndStop("show");
			subListFader.gotoAndStop("hide");
			_state = LIST_ACTIVE;
		}
	}
	
	public function showSublist(): Void
	{
		if (_modList.selectedClip == undefined || _modList.selectedEntry == undefined)
			return;

		

		setState(TRANSITION_TO_SUBLIST);
	}
	
	private function setState(a_state: Number): Void
	{
		switch (a_state) {
			case LIST_ACTIVE:
				modListFader.gotoAndStop("show");
				_modList.disableInput = false;
				_modList.disableSelection = false;
				break;
				
			case SUBLIST_ACTIVE:
				subListFader.gotoAndStop("show");
				_subList.disableInput = false;
				_subList.disableSelection = false;
				break;
				
			case TRANSITION_TO_SUBLIST:
				_titleText = _modList.selectedEntry.text;
				decorTitle._y = _modList.selectedClip._y;
				hideDecorTitle(false);
				decorTitle.gotoAndPlay("fadeIn");
				decorTitle.textHolder.textField.text = _titleText;
				modListFader.gotoAndPlay("fadeOut");
			
				_modList.disableInput = true;
				_modList.disableSelection = true;
				break;
				
			case TRANSITION_TO_LIST:
				_subList.disableInput = true;
				_subList.disableSelection = true;
				break;
				
			default:
				return;
		}
		
		_state = a_state;
	}
	
	public function onAnimFinish(a_animID: Number): Void
	{
		trace("onAnimFinish: state " + _state + " anim " + a_animID);
		
		switch (a_animID) {
			case ANIM_DECORTITLE_FADE_IN:
				// Should happen at the same time as ANIM_LIST_FADE_OUT, we just need to handle one of them.
				var tween = new Tween(decorTitle, "_y", Strong.easeOut, decorTitle._y, _modList._x + _modList.topBorder, 0.75, true);
				tween.FPS = 60;
				tween.onMotionFinished = Delegate.create(this, decorMotionFinishedFunc);
				tween.onMotionChanged = Delegate.create(this, decorMotionUpdateFunc);
				break;
				
			case ANIM_DECORTITLE_TWEEN:
				subListFader.gotoAndPlay("fadeIn");
				break;
				
			case ANIM_SUBLIST_FADE_IN:
				setState(SUBLIST_ACTIVE);
				break;
				
			case ANIM_SUBLIST_FADE_OUT:
				// Should happen at the same time as ANIM_DECORTITLE_FADE_OUT, we just need to handle one of them.
				modListFader.gotoAndPlay("fadeIn");
				hideDecorTitle(true);
				break;
					
			case ANIM_LIST_FADE_IN:
				setState(LIST_ACTIVE);
				break;
		}
	}


  /* PRIVATE FUNCTIONS */
	
	private function decorMotionFinishedFunc(): Void
	{
		onAnimFinish(ANIM_DECORTITLE_TWEEN);
	}
	
	private function decorMotionUpdateFunc(): Void
	{
		decorTop._y = _modList._y;
		decorTop._height = decorTitle._y - decorTop._y ;
		
		decorBottom._y = decorTitle._y + decorTitle._height;
		decorBottom._height = decorBottom._y - _modList._height;
	}
	
	private function hideDecorTitle(a_hide: Boolean): Void
	{
		if (a_hide) {
			decorTop._visible = true;
			decorTop._y = _modList._y;
			decorTop._height = _modList._height;
			decorTitle._visible = false;
			decorBottom._visible = false;
		} else {
			decorTitle._visible = true;
			decorTop._visible = true;
			decorTop._y = _modList._y;
			decorTop._height = decorTitle._y - decorTop._y ;
			decorBottom._visible = true;
			decorBottom._y = decorTitle._y + decorTitle._height;
			decorBottom._height = decorBottom._y - _modList._height;
		}
	}
}