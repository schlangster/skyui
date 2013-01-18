import Shared.GlobalFunc;

import gfx.core.UIComponent;
import gfx.utils.Constraints;

import TextField.StyleSheet;

class skyui.components.MaskedTextArea extends UIComponent
{

  /* PRIVATE VARIABLES */
	private var _constraints: Constraints;
	private var _scrollPosition:Number = 0;
	private var _scrollDelta: Number = 25;

	private var _scrollBarAutoHide: Boolean = false;

  /* STAGE ELEMENTS */
	private var textField: TextField;
	private var mask: MovieClip;

	private var _scrollBar:MovieClip;


  /* INITIALIZATION */
	function MaskedTextArea() {
		super();
		GlobalFunc.MaintainTextFormat();
	}

	public function configUI(): Void
	{
		super.configUI();

		_constraints = new Constraints(this, true);
		_constraints.addElement(textField, Constraints.ALL);

		textField.html = true;
		textField.verticalAutoSize = "top";

		Mouse.addListener(this);
		
		initSize();
		sizeIsInvalid = true;
	}

  /* PROPERTIES */
	public function get scrollBar(): Object {
		return _scrollBar;
	}
	public function set scrollBar(a_val: Object):Void {
		if (_scrollBar != null) {
			_scrollBar.removeEventListener("scroll", this, "handleScroll");
			_scrollBar.removeEventListener("change", this, "handleScroll");
			_scrollBar.focusTarget = null;
		}

		_scrollBar = MovieClip(a_val);

		invalidate();

		if (_scrollBar == null)
			return;

		if (_scrollBar.setScrollProperties != null) {
			_scrollBar.addEventListener("scroll", this, "handleScroll");
		} else {
			_scrollBar.addEventListener("change", this, "handleScroll");
		}
		_scrollBar.focusTarget = this;
		_scrollBar.tabEnabled = false;
		updateScrollBar();
	}

	public function get scrollBarAutoHide(): Boolean
	{
		return _scrollBarAutoHide;
	}
	public function set scrollBarAutoHide(a_val: Boolean): Void
	{
		_scrollBarAutoHide = a_val;

		if (_scrollBar == null)
			return;

		_scrollBar.visible = (_scrollBarAutoHide)? (textField._height > __height): true;
	}

	public function get scrollPosition(): Number
	{
		return _scrollPosition;
	}
	public function set scrollPosition(a_val: Number): Void
	{
		setScrollPosition(a_val);
	}

	private function setScrollPosition(a_val: Number, a_force: Boolean): Void
	{
		var maxscroll = (textField._height - __height);
		a_val = Math.max(0, Math.min(maxscroll, Math.round(a_val)));
		if (_scrollPosition == a_val && !a_force) { return; }
		_scrollPosition = a_val;
		textField._y = -_scrollPosition;
		updateScrollBar();
	}

	public function get text(): String
	{
		return textField.text;
	}
	public function set text(a_val: String): Void
	{
		textField.html = false;
		textField.SetText(a_val, false);
		setScrollPosition(0, true);
	}

	public function get styleSheet(): StyleSheet
	{
		return textField.styleSheet;
	}
	public function set styleSheet(a_val: StyleSheet): Void
	{
		textField.styleSheet = a_val;
	}

	public function get htmlText(): String
	{
		return textField.htmlText;
	}
	public function set htmlText(a_val: String): Void
	{
		textField.html = true;
		textField.SetText(a_val, true);
		textField.htmlText = a_val;
		setScrollPosition(0, true);
	}

  /* PRIVATE FUNCTIONS */
	private function draw(): Void
	{
		if (sizeIsInvalid) {
			textField._width = mask._width = __width;
			mask._height = __height;
			if (_constraints != undefined)
				_constraints.update(__width, textField._height); //Counter-Scales text field
		}

		updateScrollBar();
	}

	private function scrollWheel(delta:Number): Void
	{
		scrollPosition -= delta * _scrollDelta;
	}

	private function updateScrollBar(): Void
	{
		var maxscroll = (textField._height - __height);

		var max:Number = Math.max(0, maxscroll);
		if (_scrollBar.setScrollProperties != null) {
			_scrollBar.setScrollProperties(__height, 0, max);
		} else {
			_scrollBar.minimum = 0;
			_scrollBar.maximum = max;
		}
		_scrollBar.position = _scrollPosition;

		_scrollBar.trackScrollPageSize = 10*_scrollDelta;
		_scrollBar.pageScrollSize = _scrollDelta;

		_scrollBar.visible = (_scrollBarAutoHide)? (textField._height > __height): true;
	}

	private function handleScroll(event: Object): Void
	{
		var newPosition: Number = event.target.position;
		if (isNaN(newPosition)) { return; }
		scrollPosition = newPosition;
	}

	private function anchorPress(a_arguments: String): Void
	{
		var args: Array = a_arguments.split(",");
		dispatchEvent({type: args[0], args: args.slice(1)});
	}

}